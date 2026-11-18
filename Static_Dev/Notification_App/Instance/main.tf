
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
    key          = "dev/notification/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = "ap-south-1"
  
}

# Variables

variable "ami_id" {
  description = "AMI ID for Notification App"
  type        = string
  default     = "ami-09d8c1e69d114dbf7"
}

variable "key_name" {
  description = "SSH Key Pair for Notification App"
  type        = string
  default     = "ot-ms-dev-ssh-key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Existing VPC

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# Existing Subnet

data "aws_subnet" "notification" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-backend"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Existing Notification Security Group

data "aws_security_group" "notification" {
  name   = "OTMS-dev-notification-sg"
  vpc_id = data.aws_vpc.main.id
}

# Notification EC2 Instance

resource "aws_instance" "notification" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.notification.id
  vpc_security_group_ids = [data.aws_security_group.notification.id]
  key_name               = var.key_name

  tags = {
    Name        = "OTMS-dev-notification-instance"
    Application = "OTMS-dev-notification"
    Owner       = "Anshul"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

# Outputs

output "instance_id" {
  description = "Notification EC2 Instance ID"
  value       = aws_instance.notification.id
}

output "instance_type" {
  description = "Notification EC2 Instance Type"
  value       = aws_instance.notification.instance_type
}

output "private_ip" {
  description = "Notification EC2 Private IP"
  value       = aws_instance.notification.private_ip
}
