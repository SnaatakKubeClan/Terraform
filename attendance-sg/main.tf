# Ticket: Attendance - Security Group
# Outbound: HTTP/HTTPS + Data Store ports.

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

# Fetch existing VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# Attendance Application Security Group
resource "aws_security_group" "app" {
  name        = "ot-ms-dev-attendance-sg"
  description = "Attendance application security group"
  vpc_id      = data.aws_vpc.main.id

# INBOUND RULES

  ingress {
    description = "Allow Attendance API access from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OUTBOUND RULES

  egress {
    description = "HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "PostgreSQL outbound"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Redis outbound"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name        = "ot-ms-dev-attendance-sg"
    Application = "attendance"
    Owner       = "Vashishtha"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# Output Security Group ID
output "security_group_id" {
  description = "Attendance Security Group ID"
  value       = aws_security_group.app.id
}
