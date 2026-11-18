terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote State Configuration
  backend "s3" {
    bucket  = "otms-dev-tfstate"
    key     = "dev/Vashishtha/frontend-listener-rule/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true

    # Enable if DynamoDB lock table is configured
    # dynamodb_table = "ot-ms-dev-tflock"
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "ap-south-1"
}
