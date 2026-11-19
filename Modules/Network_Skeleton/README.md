# Terraform AWS Network Skeleton Module

<p align="center">
  <img src="https://img.shields.io/badge/AWS-Network%20Skeleton-orange?style=for-the-badge&logo=amazon-aws" />
  <img src="https://img.shields.io/badge/Terraform-%3E%3D%201.5.0-blue?style=for-the-badge&logo=terraform" />
  <img src="https://img.shields.io/badge/Architecture-3--Tier%20VPC-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Cost%20Center-KubeClan--DevOps-purple?style=for-the-badge" />
</p>

Terraform module to provision a secure, parameterized **3-Tier AWS Network Skeleton** (VPC, Public Subnets, Private Frontend/Backend Subnets, Database Subnets, Internet Gateway, NAT Gateway, Route Tables, Network ACLs, and Route 53 DNS Zones).

---

## Author & Reviewers

| **Author** | **Created On** | **Version** | **Last Updated By** | **Last Edited On** | **L0 Reviewer** | **L1 Reviewer** | **L2 Reviewer** |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Anurag Maurya** | 19-11-2026 | 1.0 | Anurag Maurya | 19-11-2026 | Divya M / Vishal Tyagi | Aayush Verma | Mahesh Kumar / Varun |

---

## Requirements

| Name | Version |
| :--- | :--- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

---

## Providers

| Name | Version |
| :--- | :--- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

---

## Modules

No external modules required.

---

## Resources

| Name | Type |
| :--- | :--- |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.private_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |

---

## Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for all resources created by this module | `string` | `"dev-otms"` | no |
| <a name="input_cidr_block"></a> [cidr_block](#input\_cidr\_block) | CIDR block for the VPC | `string` | `"10.0.0.0/24"` | no |
| <a name="input_enable_dns_hostnames"></a> [enable_dns_hostnames](#input\_enable\_dns\_hostnames) | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable_dns_support](#input\_enable\_dns\_support) | Enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_availability_zones"></a> [availability_zones](#input\_availability\_zones) | List of Availability Zones in which to create subnets | `list(string)` | `["ap-south-1a", "ap-south-1b"]` | no |
| <a name="input_public_subnets_cidr"></a> [public_subnets_cidr](#input\_public\_subnets\_cidr) | CIDR blocks for public subnets (DMZ / ALB / NAT) | `list(string)` | `["10.0.0.0/27", "10.0.0.128/27"]` | no |
| <a name="input_frontend_subnets_cidr"></a> [frontend_subnets_cidr](#input\_frontend\_subnets\_cidr) | CIDR blocks for frontend application private subnets | `list(string)` | `["10.0.0.32/28"]` | no |
| <a name="input_backend_subnets_cidr"></a> [backend_subnets_cidr](#input\_backend\_subnets\_cidr) | CIDR blocks for backend microservices private subnets | `list(string)` | `["10.0.0.64/27"]` | no |
| <a name="input_database_subnets_cidr"></a> [database_subnets_cidr](#input\_database\_subnets\_cidr) | CIDR blocks for isolated database private subnets | `list(string)` | `["10.0.0.96/27"]` | no |
| <a name="input_enable_nat_gateway"></a> [enable_nat_gateway](#input\_enable\_nat\_gateway) | Provision NAT Gateway for private subnets | `bool` | `true` | no |
| <a name="input_single_nat_gateway"></a> [single_nat_gateway](#input\_single\_nat\_gateway) | Provision a single shared NAT Gateway across all private networks | `bool` | `true` | no |
| <a name="input_enable_network_acl"></a> [enable_network_acl](#input\_enable\_network\_acl) | Provision dedicated 3-tier Network Access Control Lists | `bool` | `true` | no |
| <a name="input_enable_route53_private_zone"></a> [enable_route53_private_zone](#input\_enable\_route53\_private\_zone) | Whether to create a Route 53 private hosted zone | `bool` | `true` | no |
| <a name="input_private_domain_name"></a> [private_domain_name](#input\_private\_domain\_name) | Domain name for the Route 53 private hosted zone | `string` | `"dev.otms.internal"` | no |
| <a name="input_enable_route53_public_zone"></a> [enable_route53_public_zone](#input\_enable\_route53\_public\_zone) | Whether to create a Route 53 public hosted zone | `bool` | `true` | no |
| <a name="input_public_domain_name"></a> [public_domain_name](#input\_public\_domain\_name) | Domain name for the Route 53 public hosted zone | `string` | `"dev.otms.opstree.com"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all resources | `map(string)` | Standard Tags | no |

---

## Outputs

| Name | Description |
| :--- | :--- |
| <a name="output_vpc_id"></a> [vpc_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_arn"></a> [vpc_arn](#output\_vpc\_arn) | The ARN of the VPC |
| <a name="output_vpc_cidr_block"></a> [vpc_cidr_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_public_subnet_ids"></a> [public_subnet_ids](#output\_public\_subnet\_ids) | List of IDs of public subnets |
| <a name="output_public_subnet_arns"></a> [public_subnet_arns](#output\_public\_subnet\_arns) | List of ARNs of public subnets |
| <a name="output_frontend_subnet_ids"></a> [frontend_subnet_ids](#output\_frontend\_subnet\_ids) | List of IDs of frontend application subnets |
| <a name="output_frontend_subnet_arns"></a> [frontend_subnet_arns](#output\_frontend\_subnet\_arns) | List of ARNs of frontend application subnets |
| <a name="output_backend_subnet_ids"></a> [backend_subnet_ids](#output\_backend\_subnet\_ids) | List of IDs of backend microservices subnets |
| <a name="output_backend_subnet_arns"></a> [backend_subnet_arns](#output\_backend\_subnet\_arns) | List of ARNs of backend microservices subnets |
| <a name="output_database_subnet_ids"></a> [database_subnet_ids](#output\_database\_subnet\_ids) | List of IDs of isolated database subnets |
| <a name="output_database_subnet_arns"></a> [database_subnet_arns](#output\_database\_subnet\_arns) | List of ARNs of isolated database subnets |
| <a name="output_internet_gateway_id"></a> [internet_gateway_id](#output\_internet\_gateway\_id) | The ID of the Internet Gateway |
| <a name="output_internet_gateway_arn"></a> [internet_gateway_arn](#output\_internet\_gateway\_arn) | The ARN of the Internet Gateway |
| <a name="output_nat_gateway_ids"></a> [nat_gateway_ids](#output\_nat\_gateway\_ids) | List of IDs of NAT Gateways |
| <a name="output_nat_public_ips"></a> [nat_public_ips](#output\_nat\_public\_ips) | List of public Elastic IP addresses of the NAT Gateways |
| <a name="output_public_route_table_id"></a> [public_route_table_id](#output\_public\_route\_table\_id) | The ID of the public route table |
| <a name="output_private_route_table_id"></a> [private_route_table_id](#output\_private\_route\_table\_id) | The ID of the private route table |
| <a name="output_database_route_table_id"></a> [database_route_table_id](#output\_database\_route\_table\_id) | The ID of the database route table |
| <a name="output_public_nacl_id"></a> [public_nacl_id](#output\_public\_nacl\_id) | The ID of the public subnets NACL |
| <a name="output_private_app_nacl_id"></a> [private_app_nacl_id](#output\_private\_app\_nacl\_id) | The ID of the private application subnets NACL |
| <a name="output_database_nacl_id"></a> [database_nacl_id](#output\_database\_nacl\_id) | The ID of the database subnets NACL |
| <a name="output_private_hosted_zone_id"></a> [private_hosted_zone_id](#output\_private\_hosted\_zone\_id) | The ID of the Route 53 Private Hosted Zone |
| <a name="output_private_hosted_zone_name"></a> [private_hosted_zone_name](#output\_private\_hosted\_zone\_name) | The name of the Route 53 Private Hosted Zone |
| <a name="output_public_hosted_zone_id"></a> [public_hosted_zone_id](#output\_public\_hosted\_zone\_id) | The ID of the Route 53 Public Hosted Zone |
| <a name="output_public_hosted_zone_name"></a> [public_hosted_zone_name](#output\_public\_hosted\_zone\_name) | The name of the Route 53 Public Hosted Zone |
| <a name="output_public_hosted_zone_name_servers"></a> [public_hosted_zone_name_servers](#output\_public\_hosted\_zone\_name\_servers) | The name servers of the Route 53 Public Hosted Zone |

---

## Usage Example

```hcl
module "network_skeleton" {
  source = "../../Modules/Network_Skeleton"

  name               = "dev-otms"
  cidr_block         = "10.0.0.0/24"
  availability_zones = ["ap-south-1a", "ap-south-1b"]

  public_subnets_cidr   = ["10.0.0.0/27", "10.0.0.128/27"]
  frontend_subnets_cidr = ["10.0.0.32/28"]
  backend_subnets_cidr  = ["10.0.0.64/27"]
  database_subnets_cidr = ["10.0.0.96/27"]

  enable_nat_gateway          = true
  single_nat_gateway          = true
  enable_network_acl          = true
  enable_route53_private_zone = true
  private_domain_name         = "dev.otms.internal"
  enable_route53_public_zone  = true
  public_domain_name          = "dev.otms.opstree.com"

  tags = {
    Name        = "OTMS-dev-network"
    Application = "OTMS-dev-network"
    Owner       = "Anurag"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}
```

---

## Cost Allocation Tags

All provisioned resources automatically inherit the standard cost allocation tags passed into `var.tags`:
- `Name`: `OTMS-dev-network`
- `Application`: `OTMS-dev-network`
- `Owner`: `Anurag`
- `Environment`: `dev`
- `CostCenter`: `KubeClan-DevOps`
