terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state (create this bucket + DynamoDB table once in the central account)
  backend "s3" {
    bucket       = "ot-ms-dev-tfstate"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
provider "aws" {
  region = "ap-south-1"
}
# Target tracking: keep average CPU near 60%. (Scaling policies cannot be tagged by AWS.)
# Cost-allocation tags: Application=employee Owner=Sarthak Environment=dev CostCenter=CC-OT-DEV-1001

data "aws_autoscaling_group" "main" {
  name = "ot-ms-dev-employee-asg"
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "ot-ms-dev-employee-cpu-target-tracking"
  autoscaling_group_name = data.aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 60

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

output "policy_arn" {
  value = aws_autoscaling_policy.cpu.arn
}
