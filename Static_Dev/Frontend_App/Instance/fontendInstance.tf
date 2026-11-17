terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "otms-dev-tfstate"
    key          = "dev/frontend/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

# ---------------------------------------
# AWS Provider
# ---------------------------------------

provider "aws" {
  region = "ap-south-1"
}

# ---------------------------------------
# AMI ID - Manual Input
# ---------------------------------------

variable "ami_id" {
  description = "AMI ID of existing EC2 instance"
  type        = string
  default = "ami-09dc5eddf5641f8cc"
}

# ---------------------------------------
# Existing VPC
# ---------------------------------------

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# ---------------------------------------
# Existing Frontend Subnet
# ---------------------------------------

data "aws_subnet" "frontend" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-frontend"]
  }

  vpc_id = data.aws_vpc.main.id
}

# ---------------------------------------
# Existing Frontend Security Group
# ---------------------------------------

data "aws_security_group" "frontend" {
  name   = "ot-ms-dev-frontend-sg"
  vpc_id = data.aws_vpc.main.id
}

# ---------------------------------------
# Frontend EC2 Instance
# ---------------------------------------

resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = "t2.small"

  subnet_id = data.aws_subnet.frontend.id

  vpc_security_group_ids = [
    data.aws_security_group.frontend.id
  ]

  key_name = "kubeclan"

  associate_public_ip_address = false

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "OTMS-dev-frontend-instance"
    Application = "OTMS-dev-frontend"
    Owner       = "Maqbool"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

# ---------------------------------------
# Outputs
# ---------------------------------------

output "instance_id" {
  value = aws_instance.main.id
}

output "instance_private_ip" {
  value = aws_instance.main.private_ip
}

output "frontend_subnet_id" {
  value = data.aws_subnet.frontend.id
}

output "frontend_security_group_id" {
  value = data.aws_security_group.frontend.id
}

output "vpc_id" {
  value = data.aws_vpc.main.id
}
