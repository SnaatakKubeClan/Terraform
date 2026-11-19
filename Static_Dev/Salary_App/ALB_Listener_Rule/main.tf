
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
    key          = "dev/salary/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Variables

variable "listener_rule_priority" {
  description = "Priority for Salary listener rule"
  type        = number
  default     = 20
}

# Existing ALB

data "aws_lb" "otms_dev" {
  name = "ot-ms-dev-alb"
}

# Existing ALB Listener

data "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.otms_dev.arn
  port              = 80
}

# Existing Salary Target Group

data "aws_lb_target_group" "salary" {
  name = "ot-ms-dev-salary-tg"
}

# Salary Listener Rule

resource "aws_lb_listener_rule" "salary" {
  listener_arn = data.aws_lb_listener.http.arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.salary.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/salary/*"]
    }
  }

  tags = {
    Name        = "ot-ms-dev-salary-listener-rule"
    Application = "salary"
    Owner       = "Anshul"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

# Outputs

output "salary_listener_rule_arn" {
  description = "Salary ALB Listener Rule ARN"
  value       = aws_lb_listener_rule.salary.arn
}

output "salary_target_group_arn" {
  description = "Salary Target Group ARN"
  value       = data.aws_lb_target_group.salary.arn
}
