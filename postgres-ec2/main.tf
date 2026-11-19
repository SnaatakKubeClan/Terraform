# -----------------------------
# VPC
# -----------------------------
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# -----------------------------
# Database Subnet
# -----------------------------
data "aws_subnet" "database" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-database"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# -----------------------------
# PostgreSQL Security Group
# -----------------------------
data "aws_security_group" "postgres" {
  name   = "ot-ms-dev-postgres-sg"
  vpc_id = data.aws_vpc.main.id
}

# -----------------------------
# Latest Amazon Linux 2023 AMI
# -----------------------------
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# -----------------------------
# PostgreSQL EC2 Instance
# -----------------------------
resource "aws_instance" "main" {
  ami                    = data.aws_ssm_parameter.ami.value
  instance_type          = "t3.medium"
  subnet_id              = data.aws_subnet.database.id
  vpc_security_group_ids = [data.aws_security_group.postgres.id]

  # Existing IAM Instance Profile for SSM
  iam_instance_profile = "otms-ssm-role"

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail

    dnf install -y docker xfsprogs
    systemctl enable --now docker

    # Wait for the data disk
    while [ ! -b /dev/nvme1n1 ]; do
      sleep 2
    done

    # Format disk only if it is not already formatted
    blkid /dev/nvme1n1 || mkfs -t xfs /dev/nvme1n1

    # Mount data disk
    mkdir -p /data
    mount /dev/nvme1n1 /data
    mkdir -p /data/postgres

    # Run PostgreSQL container
    docker run -d \
      --name postgres \
      --restart always \
      -p 5432:5432 \
      -v /data/postgres:/var/lib/postgresql/data \
      -e POSTGRES_PASSWORD=password \
      -e POSTGRES_DB=attendance_db \
      postgres:15
  EOT

  user_data_replace_on_change = true

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  # Encrypted Root Disk
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  # Separate Encrypted PostgreSQL Data Disk
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = {
    Name        = "ot-ms-dev-postgres"
    Application = "postgres"
    Owner       = "Vashishtha"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# -----------------------------
# Output
# -----------------------------
output "private_ip" {
  value = aws_instance.main.private_ip
}
