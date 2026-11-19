variable "name" {
  description = "Name prefix for all resources created by this module"
  type        = string
  default     = "dev-otms"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of Availability Zones in which to create subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets (DMZ / ALB / NAT)"
  type        = list(string)
  default     = ["10.0.0.0/27", "10.0.0.128/27"]
}

variable "frontend_subnets_cidr" {
  description = "CIDR blocks for frontend application private subnets"
  type        = list(string)
  default     = ["10.0.0.32/28"]
}

variable "backend_subnets_cidr" {
  description = "CIDR blocks for backend microservices private subnets"
  type        = list(string)
  default     = ["10.0.0.64/27"]
}

variable "database_subnets_cidr" {
  description = "CIDR blocks for isolated database private subnets"
  type        = list(string)
  default     = ["10.0.0.96/27"]
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all private networks"
  type        = bool
  default     = true
}

variable "enable_network_acl" {
  description = "Whether to create dedicated 3-tier Network Access Control Lists (NACLs)"
  type        = bool
  default     = true
}

variable "enable_route53_private_zone" {
  description = "Whether to create a Route 53 private hosted zone for internal DNS"
  type        = bool
  default     = true
}

variable "private_domain_name" {
  description = "Domain name for the Route 53 private hosted zone"
  type        = string
  default     = "dev.otms.internal"
}

variable "enable_route53_public_zone" {
  description = "Whether to create a Route 53 public hosted zone for external ingress"
  type        = bool
  default     = true
}

variable "public_domain_name" {
  description = "Domain name for the Route 53 public hosted zone"
  type        = string
  default     = "dev.otms.opstree.com"
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default = {
    Name        = "OTMS-dev-network"
    Application = "OTMS-dev-network"
    Owner       = "Anurag"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}
