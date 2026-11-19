# Base VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-igw"
    }
  )
}

# Public Subnets (DMZ Tier for ALB and NAT Gateway)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = length(var.public_subnets_cidr) > 1 ? "${var.name}-public-${substr(element(var.availability_zones, count.index), -1, 1)}" : "${var.name}-public"
      Tier = "Public"
    }
  )
}

# Frontend Subnets (Private Application Tier)
resource "aws_subnet" "frontend" {
  count                   = length(var.frontend_subnets_cidr)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.frontend_subnets_cidr[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = length(var.frontend_subnets_cidr) > 1 ? "${var.name}-frontend-${substr(element(var.availability_zones, count.index), -1, 1)}" : "${var.name}-frontend"
      Tier = "Frontend"
    }
  )
}

# Backend Subnets (Private Microservices Application Tier)
resource "aws_subnet" "backend" {
  count                   = length(var.backend_subnets_cidr)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.backend_subnets_cidr[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = length(var.backend_subnets_cidr) > 1 ? "${var.name}-backend-${substr(element(var.availability_zones, count.index), -1, 1)}" : "${var.name}-backend"
      Tier = "Backend"
    }
  )
}

# Database Subnets (Isolated Tier for PostgreSQL, ScyllaDB, Redis)
resource "aws_subnet" "database" {
  count                   = length(var.database_subnets_cidr)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.database_subnets_cidr[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = length(var.database_subnets_cidr) > 1 ? "${var.name}-database-${substr(element(var.availability_zones, count.index), -1, 1)}" : "${var.name}-database"
      Tier = "Database"
    }
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnets_cidr)) : 0
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = var.single_nat_gateway ? "${var.name}-nat-eip" : "${var.name}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnets_cidr)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = var.single_nat_gateway ? "${var.name}-nat" : "${var.name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}
