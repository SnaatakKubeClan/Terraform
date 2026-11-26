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
    key            = "dev/Vashishtha/notification-template/terraform.tfstate"
    region         = "ap-south-1"
    #dynamodb_table = "ot-ms-dev-tflock"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
}
