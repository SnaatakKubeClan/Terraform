
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
  region  = "ap-south-1"
  profile = "team"
}

# --------------------------------------------------
# Variables
# --------------------------------------------------

variable "vpc_name" {
  description = "Name tag of the existing development VPC"
  type        = string
  default     = "ot-ms-dev-vpc"
}

variable "nat_gateway_name" {
  description = "Name tag of the existing NAT Gateway"
  type        = string
  default     = "ot-ms-dev-nat"
}

variable "private_route_table_name" {
  description = "Name tag of the existing private route table"
  type        = string
  default     = "OTMS-dev-network-private-rt"
}

# --------------------------------------------------
# Existing VPC - Dynamic lookup by Name tag
# --------------------------------------------------

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }

  state = "available"
}

# --------------------------------------------------
# Existing Internet Gateway
# --------------------------------------------------

data "aws_internet_gateway" "main" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# --------------------------------------------------
# Existing NAT Gateway
# --------------------------------------------------

data "aws_nat_gateway" "main" {
  vpc_id = data.aws_vpc.main.id
  state  = "available"

  filter {
    name   = "tag:Name"
    values = [var.nat_gateway_name]
  }
}

# --------------------------------------------------
# Existing Public Route Table (Main Route Table)
# --------------------------------------------------

data "aws_route_table" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

# --------------------------------------------------
# Existing Private Route Table
# --------------------------------------------------

data "aws_route_table" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = [var.private_route_table_name]
  }
}

# --------------------------------------------------
# Private Route through Existing NAT Gateway
# --------------------------------------------------

resource "aws_route" "private_nat" {
  route_table_id         = data.aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = data.aws_nat_gateway.main.id
}

# --------------------------------------------------
# Outputs
# --------------------------------------------------

output "vpc_id" {
  description = "Dynamically discovered VPC ID"
  value       = data.aws_vpc.main.id
}

output "public_route_table_id" {
  description = "Existing main public route table ID"
  value       = data.aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Existing private route table ID"
  value       = data.aws_route_table.private.id
}

output "nat_gateway_id" {
  description = "Existing available NAT Gateway ID"
  value       = data.aws_nat_gateway.main.id
}

output "internet_gateway_id" {
  description = "Existing Internet Gateway ID"
  value       = data.aws_internet_gateway.main.id
}
