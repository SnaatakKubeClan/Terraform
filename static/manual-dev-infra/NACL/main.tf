# Ticket: Terraform static code to configure NACL rules
# One NACL per tier. Ports 1024-65535 are open inbound for return traffic
# (NACLs are stateless).

# ---------------- VPC DATA SOURCE ----------------

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# ---------------- SUBNET DATA SOURCES ----------------

# Public Subnets

data "aws_subnet" "public_a" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-public-a"]
  }
}

data "aws_subnet" "public_b" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-public-b"]
  }
}

# Application Subnets

data "aws_subnet" "frontend" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-frontend"]
  }
}

data "aws_subnet" "backend" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-backend"]
  }
}

# Database Subnet

data "aws_subnet" "database" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-database"]
  }
}

# ---------------- PUBLIC NACL ----------------

resource "aws_network_acl" "public" {
  vpc_id = data.aws_vpc.main.id

  subnet_ids = [
    data.aws_subnet.public_a.id,
    data.aws_subnet.public_b.id,
  ]

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

  tags = {
    Name        = "ot-ms-dev-public-nacl"
    Application = "network"
    Owner       = "Vashishtha"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# ---------------- PRIVATE APP NACL ----------------

resource "aws_network_acl" "private_app" {
  vpc_id = data.aws_vpc.main.id

  subnet_ids = [
    data.aws_subnet.frontend.id,
    data.aws_subnet.backend.id,
  ]

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 3000
    to_port    = 3000
    cidr_block = "10.0.0.0/16"
  }

  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    from_port  = 8080
    to_port    = 8080
    cidr_block = "10.0.0.0/16"
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

  tags = {
    Name        = "ot-ms-dev-private-app-nacl"
    Application = "network"
    Owner       = "Vashishtha"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# ---------------- PRIVATE DATABASE NACL ----------------

resource "aws_network_acl" "private_db" {
  vpc_id = data.aws_vpc.main.id

  subnet_ids = [
    data.aws_subnet.database.id,
  ]

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    from_port  = 5432
    to_port    = 5432
    cidr_block = "10.0.0.0/16"
  }

  ingress {
    rule_no    = 200
    action     = "allow"
    protocol   = "tcp"
    from_port  = 6379
    to_port    = 6379
    cidr_block = "10.0.0.0/16"
  }

  ingress {
    rule_no    = 300
    action     = "allow"
    protocol   = "tcp"
    from_port  = 9042
    to_port    = 9042
    cidr_block = "10.0.0.0/16"
  }

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

  tags = {
    Name        = "ot-ms-dev-private-db-nacl"
    Application = "network"
    Owner       = "Vashishtha"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}
