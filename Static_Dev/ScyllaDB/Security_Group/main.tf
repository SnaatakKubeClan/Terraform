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
    key          = "dev/scylladb/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

data "aws_security_group" "bastion" {
  filter {
    name   = "group-name"
    values = ["ot-ms-dev-bastion-sg"]
  }

  vpc_id = data.aws_vpc.main.id
}

resource "aws_security_group" "db" {
  name        = "OTMS-dev-scylladb-sg"
  description = "Syclla DB security group"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description     = "Syclla DB port from app security groups only"
    from_port       = 9042
    to_port         = 9042
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  ingress {
	  description     = "SSH from Bastion"
	  from_port       = 22
	  to_port         = 22
	  protocol        = "tcp"
	  security_groups = [data.aws_security_group.bastion.id]
	}

   egress {
	  description = "Allow all outbound traffic"
	  from_port   = 0
	  to_port     = 0
	  protocol    = "-1"
	  cidr_blocks = ["0.0.0.0/0"]
	}

  tags = {
    Name        = "OTMS-dev-scylladb-sg"
    Application = "scylladb"
    Owner       = "Maqbool"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

output "security_group_id" {
  value = aws_security_group.db.id
}
