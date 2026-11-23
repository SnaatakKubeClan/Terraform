terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "otms-dev-tfstate"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}


provider "aws" {
  region = "ap-south-1"
}


data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Name        = "OTMS-dev-igw"
    Application = "network"
    Owner       = "Sarthak"
    Environment = "dev"
    CostCenter  =  "KubeClan-DevOps"

  }
}

output "igw_id" {
  value = aws_internet_gateway.main.id
}
