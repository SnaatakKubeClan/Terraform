
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

variable "vpc_name" {
  description = "Name tag of the development VPC"
  type        = string
  default     = "ot-ms-dev-vpc"
}

variable "nat_gateway_name" {
  description = "Name tag of the existing NAT Gateway"
  type        = string
  default     = "ot-ms-dev-nat"
}

variable "public_route_table_name" {
  description = "Name tag for the public route table"
  type        = string
  default     = "dev-otms-public-rt"
}

variable "private_route_table_name" {
  description = "Name tag for the private route table"
  type        = string
  default     = "dev-otms-private-rt"
}

variable "owner" {
  description = "Owner of the route table configuration"
  type        = string
  default     = "Shivam"
}

variable "cost_center" {
  description = "Development infrastructure cost center"
  type        = string
  default     = "CC-OT-DEV-1001"
}

locals {
  common_tags = {
    Application = "network"
    Owner       = var.owner
    Environment = "dev"
    CostCenter  = var.cost_center
  }
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }

  state = "available"
}

data "aws_internet_gateway" "main" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_nat_gateway" "main" {
  vpc_id = data.aws_vpc.main.id
  state  = "available"

  filter {
    name   = "tag:Name"
    values = [var.nat_gateway_name]
  }
}

data "aws_subnet" "public_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-public-a"]
  }
}

data "aws_subnet" "public_b" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-public-b"]
  }
}

data "aws_subnet" "frontend" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["dev-otms-frontend"]
  }
}

data "aws_subnet" "backend" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["dev-otms-backend"]
  }
}

data "aws_subnet" "database" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["dev-otms-database"]
  }
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = var.public_route_table_name
    }
  )
}

# Create Private Route Table
resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = var.private_route_table_name
    }
  )
}

# Public Route through Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.main.id
}

# Private Route through NAT Gateway
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = data.aws_nat_gateway.main.id
}

# Public Subnet Associations
resource "aws_route_table_association" "public_a" {
  subnet_id      = data.aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = data.aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Private Subnet Associations
resource "aws_route_table_association" "frontend" {
  subnet_id      = data.aws_subnet.frontend.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "backend" {
  subnet_id      = data.aws_subnet.backend.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  subnet_id      = data.aws_subnet.database.id
  route_table_id = aws_route_table.private.id
}

output "vpc_id" {
  value = data.aws_vpc.main.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "internet_gateway_id" {
  value = data.aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  value = data.aws_nat_gateway.main.id
}
