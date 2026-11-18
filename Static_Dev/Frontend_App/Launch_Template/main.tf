data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

data "aws_security_group" "app" {
  name   = "ot-ms-dev-frontend-sg"
  vpc_id = data.aws_vpc.main.id
}

# Latest Amazon Linux 2023 AMI (AWS keeps this SSM parameter up to date)
data "aws_ami" "frontend" {
  most_recent = true
  owners      = ["self"]   # use your AWS account ID if the AMI is shared from another account

  filter {
    name   = "name"
    values = ["ami-frontend"]
  }
}

data "aws_iam_instance_profile" "ssm" {
  name = "otms-ssm-role"
}

resource "aws_launch_template" "main" {
  name                   = "ot-ms-dev-frontend-lt"
  image_id               = data.aws_ami.frontend.id
  instance_type          = "t3.medium"
  key_name               = "ot-ms-dev-ssh-key"
  vpc_security_group_ids = [data.aws_security_group.app.id]
  update_default_version = true

  iam_instance_profile {
    name = data.aws_iam_instance_profile.ssm.name  
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
      Name        = "ot-ms-dev-frontend"
      Application = "frontend"
      Owner       = "Priyanshu"
      Environment = "dev"
      CostCenter  = "KubeClan-DevOps"
    }
  }

  tags = {
    Name        = "ot-ms-dev-frontend-lt"
    Application = "frontend"
    Owner       = "Priyanshu"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

output "launch_template_id" {
  value = aws_launch_template.main.id
}
