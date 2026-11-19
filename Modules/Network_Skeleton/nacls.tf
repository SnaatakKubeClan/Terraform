# ==============================================================================
# Network Access Control Lists (NACLs) - Tiered Security Boundaries
# ==============================================================================

# Public Subnets NACL (DMZ / ALB / NAT)
resource "aws_network_acl" "public" {
  count  = var.enable_network_acl ? 1 : 0
  vpc_id = aws_vpc.this.id

  subnet_ids = aws_subnet.public[*].id

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 300
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-nacl"
      Tier = "Public"
    }
  )
}

# Private Application Subnets NACL (Frontend & Backend Microservices)
resource "aws_network_acl" "private_app" {
  count  = var.enable_network_acl ? 1 : 0
  vpc_id = aws_vpc.this.id

  subnet_ids = concat(aws_subnet.frontend[*].id, aws_subnet.backend[*].id)

  # Frontend HTTP Port
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 3000
    to_port    = 3000
    cidr_block = var.cidr_block
  }

  # Backend Microservices Ports (Employee: 8080, Attendance: 8081, Salary: 8082, Notification: 8085)
  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    from_port  = 8080
    to_port    = 8085
    cidr_block = var.cidr_block
  }

  # Ephemeral Return Traffic
  ingress {
    rule_no    = 300
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-app-nacl"
      Tier = "Private"
    }
  )
}

# Database Subnets NACL (Isolated Tier: PostgreSQL 5432, ScyllaDB 9042, Redis 6379)
resource "aws_network_acl" "database" {
  count  = var.enable_network_acl ? 1 : 0
  vpc_id = aws_vpc.this.id

  subnet_ids = aws_subnet.database[*].id

  # PostgreSQL
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 5432
    to_port    = 5432
    cidr_block = var.cidr_block
  }

  # Redis
  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    from_port  = 6379
    to_port    = 6379
    cidr_block = var.cidr_block
  }

  # ScyllaDB
  ingress {
    rule_no    = 300
    action     = "allow"
    protocol   = "tcp"
    from_port  = 9042
    to_port    = 9042
    cidr_block = var.cidr_block
  }

  # Ephemeral Inbound Return Traffic
  ingress {
    rule_no    = 400
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-database-nacl"
      Tier = "Database"
    }
  )
}
