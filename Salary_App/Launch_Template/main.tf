terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "otms-dev-tfstate"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Fetch existing VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# Fetch existing Salary Security Group
data "aws_security_group" "app" {
  name   = "ot-ms-dev-salary-sg"
  vpc_id = data.aws_vpc.main.id
}

# Fetch latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Salary Launch Template
resource "aws_launch_template" "main" {
  name                   = "ot-ms-dev-salary-lt"
  image_id               = data.aws_ssm_parameter.ami.value
  instance_type          = "t3.small"
  key_name               = "ot-ms-dev-key"
  vpc_security_group_ids = [data.aws_security_group.app.id]

  update_default_version = true

  user_data = base64encode(<<-EOT
    #!/bin/bash
    set -euo pipefail

    dnf install -y docker
    systemctl enable --now docker

    docker run -d \
      --name salary \
      --restart always \
      -p 8080:8080 \
      quay.io/opstree/salary-api:latest
  EOT
  )

  iam_instance_profile {
    name = "ot-ms-dev-salary-instance-profile"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = "gp3"
      volume_size = 20
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "ot-ms-dev-salary"
      Application = "salary"
      Owner       = "Sarthak"
      Environment = "dev"
      CostCenter  = "KubeClan-DevOps"
    }
  }

  tags = {
    Name        = "ot-ms-dev-salary-lt"
    Application = "salary"
    Owner       = "Sarthak"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

# Output Launch Template ID
output "launch_template_id" {
  value = aws_launch_template.main.id
}


