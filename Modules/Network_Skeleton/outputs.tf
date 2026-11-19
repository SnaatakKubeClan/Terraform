output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public[*].arn
}

output "frontend_subnet_ids" {
  description = "List of IDs of frontend application subnets"
  value       = aws_subnet.frontend[*].id
}

output "frontend_subnet_arns" {
  description = "List of ARNs of frontend application subnets"
  value       = aws_subnet.frontend[*].arn
}

output "backend_subnet_ids" {
  description = "List of IDs of backend microservices subnets"
  value       = aws_subnet.backend[*].id
}

output "backend_subnet_arns" {
  description = "List of ARNs of backend microservices subnets"
  value       = aws_subnet.backend[*].arn
}

output "database_subnet_ids" {
  description = "List of IDs of isolated database subnets"
  value       = aws_subnet.database[*].id
}

output "database_subnet_arns" {
  description = "List of ARNs of isolated database subnets"
  value       = aws_subnet.database[*].arn
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "internet_gateway_arn" {
  description = "The ARN of the Internet Gateway"
  value       = aws_internet_gateway.this.arn
}

output "nat_gateway_ids" {
  description = "List of IDs of NAT Gateways"
  value       = aws_nat_gateway.this[*].id
}

output "nat_public_ips" {
  description = "List of public Elastic IP addresses of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

output "database_route_table_id" {
  description = "The ID of the database route table"
  value       = aws_route_table.database.id
}

output "public_nacl_id" {
  description = "The ID of the public subnets NACL"
  value       = try(aws_network_acl.public[0].id, null)
}

output "private_app_nacl_id" {
  description = "The ID of the private application subnets NACL"
  value       = try(aws_network_acl.private_app[0].id, null)
}

output "database_nacl_id" {
  description = "The ID of the database subnets NACL"
  value       = try(aws_network_acl.database[0].id, null)
}

output "private_hosted_zone_id" {
  description = "The ID of the Route 53 Private Hosted Zone"
  value       = try(aws_route53_zone.private[0].zone_id, null)
}

output "private_hosted_zone_name" {
  description = "The name of the Route 53 Private Hosted Zone"
  value       = try(aws_route53_zone.private[0].name, null)
}

output "public_hosted_zone_id" {
  description = "The ID of the Route 53 Public Hosted Zone"
  value       = try(aws_route53_zone.public[0].zone_id, null)
}

output "public_hosted_zone_name" {
  description = "The name of the Route 53 Public Hosted Zone"
  value       = try(aws_route53_zone.public[0].name, null)
}

output "public_hosted_zone_name_servers" {
  description = "The name servers of the Route 53 Public Hosted Zone"
  value       = try(aws_route53_zone.public[0].name_servers, [])
}
