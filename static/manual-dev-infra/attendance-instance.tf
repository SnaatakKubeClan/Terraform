
# Attendance Dev EC2 Instance
# Ticket: SCRUM-438

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Fetch existing Attendance Security Group
data "aws_security_group" "attendance" {
  id = "sg-0b4d540a8017c15b6"
}

# Fetch existing Attendance Backend Subnet
data "aws_subnet" "backend" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-backend"]
  }

  filter {
    name   = "vpc-id"
    values = ["vpc-043631a3468dae621"]
  }
}

# Fetch latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Attendance EC2 Instance
resource "aws_instance" "attendance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnet.backend.id
  vpc_security_group_ids = [data.aws_security_group.attendance.id]

  tags = {
    Name        = "ot-ms-dev-attendance-ec2"
    Application = "Attendance"
    Owner       = "Shivam"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }

  lifecycle {
    precondition {
      condition = (
        data.aws_subnet.backend.vpc_id ==
        data.aws_security_group.attendance.vpc_id
      )
      error_message = "Attendance Security Group and Subnet must belong to the same VPC."
    }
  }
}

# Outputs
output "attendance_instance_id" {
  description = "Attendance EC2 Instance ID"
  value       = aws_instance.attendance.id
}

output "attendance_private_ip" {
  description = "Attendance EC2 Private IP"
  value       = aws_instance.attendance.private_ip
}

