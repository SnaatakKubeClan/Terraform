
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_organizations_policy" "service_level_policy" {
  name        = "otms-service-level-policy"
  description = "Allow required AWS services and deny unapproved services for cost optimization"

  type = "SERVICE_CONTROL_POLICY"

  content = file("${path.module}/policies/service-level-policy.json")
}

output "policy_id" {
  description = "ID of the AWS Service Control Policy"
  value       = aws_organizations_policy.service_level_policy.id
}

output "policy_arn" {
  description = "ARN of the AWS Service Control Policy"
  value       = aws_organizations_policy.service_level_policy.arn
}

output "policy_name" {
  description = "Name of the AWS Service Control Policy"
  value       = aws_organizations_policy.service_level_policy.name
}
