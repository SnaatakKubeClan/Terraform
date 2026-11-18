# Ticket: Terraform static code to configure VPC
# Creates the dev VPC (10.0.0.0/16) and locks down its default security group.

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "ot-ms-dev-vpc"
    Application = "network"
    Owner       = "Palak"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# The default SG is emptied (no rules) so nothing can accidentally use it
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "ot-ms-dev-default-sg-locked"
    Application = "network"
    Owner       = "Palak"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}

