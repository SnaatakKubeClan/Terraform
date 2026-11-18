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

resource "aws_key_pair" "ssh_key" {
  key_name   = "ot-ms-dev-ssh-key"
  public_key = file("${path.module}/ot-ms-dev-ssh-key.pub")

  tags = {
    Name        = "ot-ms-dev-ssh-key"
    Application = "network"
    Owner       = "Anshul"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

output "ssh_key_name" {
  value = aws_key_pair.ssh_key.key_name
}
