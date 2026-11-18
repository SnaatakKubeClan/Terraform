terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "ot-ms-dev-tfstate"
    key            = "dev/attendance/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_lb" "main" {
  name = "ot-ms-dev-alb"
}

data "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 80
}

data "aws_lb_target_group" "main" {
  name = "dev-otms-attendance-tg"
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = data.aws_lb_listener.http.arn
  priority     = 120

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.main.arn
  }

  condition	{
    path_pattern {
      values = ["/api/v1/attendance*"]
    }
  }

  tags = {
    Name        = "ot-ms-dev-attendance-rule"
    Application = "attendance"
    Owner       = "Maqbool"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

output "listener_rule_arn" {	
  value = aws_lb_listener_rule.main.arn
}
