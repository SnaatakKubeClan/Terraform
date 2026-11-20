# Ticket: Terraform static code to configure NAT gateway
# One NAT gateway in public-a (dev cost saving) so private subnets can reach the internet.

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

data "aws_subnet" "public_a" {
  vpc_id = data.aws_vpc.main.id

  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-public-a"]
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "ot-ms-dev-nat-eip"
    Application = "network"
    Owner       = "Rani"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = data.aws_subnet.public_a.id

  tags = {
    Name        = "ot-ms-dev-nat"
    Application = "network"
    Owner       = "Rani"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}

output "nat_eip_public_ip" {
  value = aws_eip.nat.public_ip
}
