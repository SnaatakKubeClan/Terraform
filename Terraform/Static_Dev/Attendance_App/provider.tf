
terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "otms-dev-tfstate"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "team"
}

variable "vpc_name" {
  description = "Existing VPC name"
  type        = string
  default     = "ot-ms-dev-vpc"
}

variable "subnet_name" {
  description = "Existing backend subnet name"
  type        = string
  default     = "dev-otms-backend"
}

variable "security_group_name" {
  description = "Existing Attendance Security Group"
  type        = string
  default     = "ot-ms-dev-attendance-sg"
}

variable "ami_parameter" {
  description = "Amazon Linux 2023 AMI parameter"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "instance_type" {
  description = "Attendance EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Existing EC2 key pair"
  type        = string
  default     = "ot-ms-dev-ssh-key"
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
