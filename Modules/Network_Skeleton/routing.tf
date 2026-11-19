# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-rt"
      Tier = "Public"
    }
  )
}

# Public Subnets Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table (Frontend & Backend Tiers)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[0].id
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-rt"
      Tier = "Private"
    }
  )
}

# Associate Frontend Subnets with Private Route Table
resource "aws_route_table_association" "frontend" {
  count          = length(var.frontend_subnets_cidr)
  subnet_id      = aws_subnet.frontend[count.index].id
  route_table_id = aws_route_table.private.id
}

# Associate Backend Subnets with Private Route Table
resource "aws_route_table_association" "backend" {
  count          = length(var.backend_subnets_cidr)
  subnet_id      = aws_subnet.backend[count.index].id
  route_table_id = aws_route_table.private.id
}

# Database Route Table (Isolated - Local VPC Peering/Routing Only)
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-database-rt"
      Tier = "Database"
    }
  )
}

# Associate Database Subnets with Database Route Table
resource "aws_route_table_association" "database" {
  count          = length(var.database_subnets_cidr)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
