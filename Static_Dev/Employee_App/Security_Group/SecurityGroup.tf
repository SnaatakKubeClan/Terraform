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

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

resource "aws_security_group" "app" {
  name        = "OTMS-dev-employee-sg"
  description = "Employee application security group"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description     = "App port from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
  }

  egress {
	  description = "Allow all outbound traffic"
	  from_port   = 0
	  to_port     = 0
	  protocol    = "-1"
	  cidr_blocks = ["0.0.0.0/0"]
	}

  tags = {
    Name        = "OTMS-dev-employee-sg"
    Application = "OTMS-dev-employee"
    Owner       = "Maqbool"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

output "security_group_id" {
  value = aws_security_group.app.id
}
