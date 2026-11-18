terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state (create this bucket + DynamoDB table once in the central account)
  #backend "s3" {
    #bucket         = "ot-ms-dev-tfstate"
    #key            = "dev/Palak/network-vpc/terraform.tfstate"
    #region         = "ap-south-1"
  
}

provider "aws" {
  region = "ap-south-1"
}
