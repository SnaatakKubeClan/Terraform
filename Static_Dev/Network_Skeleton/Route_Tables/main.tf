

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
}

# Variables
variable "vpc_id" {
  description = "Existing development VPC ID"
  type        = string
  default     = "vpc-043631a3468ade621"
}

variable "public_subnet_a_name" {
  type    = string
  default = "ot-ms-dev-public-a"
}

variable "public_subnet_b_name" {
  type    = string
  default = "ot-ms-dev-public-b"
}

variable "frontend_subnet_name" {
  type    = string
  default = "dev-otms-frontend"
}

variable "backend_subnet_name" {
  type    = string
  default = "dev-otms-backend"
}

variable "database_subnet_name" {
  type    = string
  default = "dev-otms-database"
}

variable "nat_gateway_name" {
  type    = string
  default = "ot-ms-dev-nat"
}

# Existing VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

# Existing Internet Gateway
data "aws_internet_gateway" "main" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Existing NAT Gateway
data "aws_nat_gateway" "main" {
  vpc_id = data.aws_vpc.main.id
  state  = "available"

  filter {
    name   = "tag:Name"
    values = [var.nat_gateway_name]
  }
}

# Existing Public Subnets
data "aws_subnet" "public_a" {
  filter {
    name   = "tag:Name"
    values = [var.public_subnet_a_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_subnet" "public_b" {
  filter {
    name   = "tag:Name"
    values = [var.public_subnet_b_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Existing Private Subnets
data "aws_subnet" "frontend" {
  filter {
    name   = "tag:Name"
    values = [var.frontend_subnet_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_subnet" "backend" {
  filter {
    name   = "tag:Name"
    values = [var.backend_subnet_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_subnet" "database" {
  filter {
    name   = "tag:Name"
    values = [var.database_subnet_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Standard Cost Allocation Tags
locals {
  common_tags = {
    Application = "network"
    Owner       = "Shivam"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "ot-ms-dev-public-rt"
  })
}

# Public Route through Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = data.aws_internet_gateway.main.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "ot-ms-dev-private-rt"
  })
}

# Private Route through existing NAT Gateway
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

# Outputs
output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}
