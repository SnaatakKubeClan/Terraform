
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "ot-ms-dev-tfstate"
    key          = "dev/Shivam/frontend-scaling-policies/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region              = "ap-south-1"
  profile             = "team"
  allowed_account_ids = ["638151077851"]
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "application" {
  description = "Application name"
  type        = string
  default     = "frontend"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "Shivam"
}

variable "cost_center" {
  description = "Cost allocation identifier"
  type        = string
  default     = "KubeClan-DevOps"
}

variable "autoscaling_group_name" {
  description = "Existing frontend Auto Scaling Group"
  type        = string
  default     = "ot-ms-dev-frontend-asg"
}

variable "cpu_target_value" {
  description = "Target average CPU utilization percentage"
  type        = number
  default     = 60

  validation {
    condition     = var.cpu_target_value > 0 && var.cpu_target_value <= 100
    error_message = "CPU target must be greater than 0 and at most 100."
  }
}

locals {
  common_tags = {
    Application = var.application
    Owner       = var.owner
    Environment = var.environment
    CostCenter  = var.cost_center
  }
}

data "aws_autoscaling_group" "frontend" {
  name = var.autoscaling_group_name
}

resource "aws_autoscaling_policy" "frontend_cpu_target_tracking" {
  name                   = "ot-ms-dev-frontend-cpu-target-tracking"
  autoscaling_group_name = data.aws_autoscaling_group.frontend.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = var.cpu_target_value
    disable_scale_in = false
  }
}

output "scaling_policy_arn" {
  description = "Frontend CPU target tracking policy ARN"
  value       = aws_autoscaling_policy.frontend_cpu_target_tracking.arn
}

output "autoscaling_group_name" {
  description = "Existing frontend Auto Scaling Group"
  value       = data.aws_autoscaling_group.frontend.name
}

output "cpu_target_value" {
  description = "Configured CPU target percentage"
  value       = var.cpu_target_value
}
