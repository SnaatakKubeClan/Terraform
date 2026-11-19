# Route 53 Private Hosted Zone for Internal VPC Service Discovery
resource "aws_route53_zone" "private" {
  count = var.enable_route53_private_zone ? 1 : 0

  name = var.private_domain_name

  vpc {
    vpc_id = aws_vpc.this.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-hosted-zone"
    }
  )
}

# Route 53 Public Hosted Zone for External Ingress (ALB)
resource "aws_route53_zone" "public" {
  count = var.enable_route53_public_zone ? 1 : 0

  name = var.public_domain_name

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-hosted-zone"
    }
  )
}
