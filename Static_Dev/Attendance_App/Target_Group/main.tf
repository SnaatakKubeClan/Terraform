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
    key          = "dev/attendance/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = "ap-south-1"
}

# Existing VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# Attendance Target Group
resource "aws_lb_target_group" "attendance_tg" {
  name        = "dev-otms-attendance-tg"
  target_type = "instance"
  protocol    = "HTTP"
  port        = 8081
  vpc_id      = data.aws_vpc.main.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port               = "traffic-port"
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name        = "dev-otms-attendance-tg"
    Application = "OTMS-dev-attendance"
    Owner       = "Anshul"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

output "attendance_target_group_arn" {
  value = aws_lb_target_group.attendance_tg.arn
}
