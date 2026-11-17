
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
    key          = "dev/redis/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region  = "ap-south-1"
}

# Existing VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# Existing Bastion Security Group
data "aws_security_group" "bastion" {
  name   = "ot-ms-dev-bastion-sg"
  vpc_id = data.aws_vpc.main.id
}

# Redis Security Group
resource "aws_security_group" "redis" {
  name        = "dev-otms-redis-sg"
  description = "Security Group for OTMS Redis"
  vpc_id      = data.aws_vpc.main.id

  # Redis access - temporarily open to anywhere
  ingress {
    description = "Redis access"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access only from Bastion
  ingress {
    description     = "SSH access from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [data.aws_security_group.bastion.id]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "OTMS-dev-redis-sg"
    Application = "OTMS-dev-redis"
    Owner       = "Anshul"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

output "redis_security_group_id" {
  value = aws_security_group.redis.id
}
