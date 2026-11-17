# Ticket: Frontend - security group
# Only the ALB can reach port 3000. Outbound: 80/443 (image pull) + data store ports.

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

#data "aws_security_group" "alb" {
#  name   = "ot-ms-dev-alb-sg"
#  vpc_id = data.aws_vpc.main.id
#}

resource "aws_security_group" "app" {
  name        = "ot-ms-dev-frontend-sg"
  description = "Frontend application security group"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "Allow Frontend API access from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP out"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTPS out"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ot-ms-dev-frontend-sg"
    Application = "frontend"
    Owner       = "Palak"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

output "security_group_id" {
  value = aws_security_group.app.id
}
