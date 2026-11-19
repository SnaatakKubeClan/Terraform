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
    bucket         = "otms-dev-tfstate"
    key            = "dev/Priyanshu/employee-target-group/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile  = true
  }
}

provider "aws" {
  region = "ap-south-1"
}
