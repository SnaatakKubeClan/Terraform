data "aws_vpc" "ot-ms-dev-vpc" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

data "aws_security_group" "ot-ms-dev-attendance-sg" {
  name   = "ot-ms-dev-attendance-sg"
  vpc_id = data.aws_vpc.ot-ms-dev-vpc.id
}

resource "aws_security_group" "ot-ms-dev-postgres-sg" {
  name        = "ot-ms-dev-postgres-sg"
  description = "Postgres security group"
  vpc_id      = data.aws_vpc.ot-ms-dev-vpc.id

  ingress {
    description     = "Postgres port from app security groups only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.ot-ms-dev-attendance-sg.id]
  }

  egress {
    description = "HTTP out (image pull)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTPS out (image pull)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ot-ms-dev-postgres-sg"
    Application = "postgres"
    Owner       = "Rani"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

output "security_group_id" {
  value = aws_security_group.ot-ms-dev-postgres-sg.id
}
