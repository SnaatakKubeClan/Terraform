# ==============================================================================
# Ticket       : SCRUM-427
# Component    : Route_53 (Network Skeleton)
# Purpose      : Public Ingress DNS (ALB) and Internal VPC Service Discovery
# ==============================================================================

# Fetch existing VPC dynamically
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# ------------------------------------------------------------------------------
# 1. Public Hosted Zone
# ------------------------------------------------------------------------------
resource "aws_route53_zone" "public" {
  name          = "dev.otms.opstree.com"
  comment       = "Public hosted zone for OT-MICROSERVICES external ingress"
  force_destroy = false

  tags = {
    Name        = "OTMS-dev-route53-public-zone"
    Application = "OTMS-dev-network"
    Owner       = "Anurag"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

# ------------------------------------------------------------------------------
# 2. Private Hosted Zone (Internal VPC DNS for Microservices & Databases)
# ------------------------------------------------------------------------------
resource "aws_route53_zone" "private" {
  name          = "dev.otms.internal"
  comment       = "Private hosted zone for OT-MICROSERVICES VPC internal DNS discovery"
  force_destroy = false

  vpc {
    vpc_id = data.aws_vpc.main.id
  }

  tags = {
    Name        = "OTMS-dev-route53-private-zone"
    Application = "OTMS-dev-network"
    Owner       = "Anurag"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

# ------------------------------------------------------------------------------
# 3. Internal DNS Service Records (Private Zone)
# ------------------------------------------------------------------------------

# Frontend Application (React - Port 3000)
resource "aws_route53_record" "frontend" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "frontend.dev.otms.internal"
  type    = "A"
  ttl     = 300
  records = ["10.0.0.35"]
}

# Employee Backend Service (Port 8080)
resource "aws_route53_record" "employee" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "employee.dev.otms.internal"
  type    = "A"
  ttl     = 300
  records = ["10.0.0.70"]
}

# Attendance Backend Service (Port 8081)
resource "aws_route53_record" "attendance" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "attendance.dev.otms.internal"
  type    = "A"
  ttl     = 300
  records = ["10.0.0.71"]
}

# Salary Backend Service (Port 8082)
resource "aws_route53_record" "salary" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "salary.dev.otms.internal"
  type    = "A"
  ttl     = 300
  records = ["10.0.0.72"]
}

# Notification Backend Service (Port 8085)
resource "aws_route53_record" "notification" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "notification.dev.otms.internal"
  type    = "A"
  ttl     = 300
  records = ["10.0.0.75"]
}

# Redis Database (Port 6379)
resource "aws_route53_record" "redis" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "redis.dev.otms.internal"
  type    = "A"
  ttl     = 300
  records = ["10.0.0.100"]
}

# PostgreSQL Database (Port 5432)
resource "aws_route53_record" "postgresql" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "postgresql.dev.otms.internal"
  type    = "A"
  ttl     = 300
  records = ["10.0.0.101"]
}

# ScyllaDB Database (Port 9042)
resource "aws_route53_record" "scylladb" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "scylladb.dev.otms.internal"
  type    = "A"
  ttl     = 300
  records = ["10.0.0.102"]
}

# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------
output "public_zone_id" {
  value = aws_route53_zone.public.zone_id
}

output "public_zone_name" {
  value = aws_route53_zone.public.name
}

output "public_zone_name_servers" {
  value = aws_route53_zone.public.name_servers
}

output "private_zone_id" {
  value = aws_route53_zone.private.zone_id
}

output "private_zone_name" {
  value = aws_route53_zone.private.name
}
