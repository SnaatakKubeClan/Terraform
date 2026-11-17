# ==============================================================================
# Ticket       : SCRUM-473
# Component    : ScyllaDB EC2 Instance
# Architecture : dev-otms-vpc (10.0.0.0/24) in ap-south-1
# ==============================================================================

# Fetch existing VPC dynamically
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# Fetch database subnet
data "aws_subnet" "db" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-database", "ot-ms-dev-private-db-a", "ot-ms-dev-database"]
  }
}

# Fetch ScyllaDB Security Group
data "aws_security_group" "db" {
  filter {
    name   = "group-name"
    values = ["OTMS-dev-scylladb-sg", "ot-ms-dev-scylladb-sg"]
  }
  vpc_id = data.aws_vpc.main.id
}

# Latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ------------------------------------------------------------------------------
# IAM Role and Instance Profile for SSM Session Manager (No open SSH ports)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "scylladb" {
  name = "OTMS-dev-scylladb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name        = "OTMS-dev-scylladb-role"
    Application = "OTMS-dev-scylladb"
    Owner       = "Anurag"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.scylladb.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "scylladb" {
  name = "OTMS-dev-scylladb-instance-profile"
  role = aws_iam_role.scylladb.name

  tags = {
    Name        = "OTMS-dev-scylladb-instance-profile"
    Application = "OTMS-dev-scylladb"
    Owner       = "Anurag"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

# ------------------------------------------------------------------------------
# ScyllaDB EC2 Instance
# ------------------------------------------------------------------------------
resource "aws_instance" "scylladb" {
  ami                    = data.aws_ssm_parameter.ami.value
  instance_type          = "t3.large"
  subnet_id              = data.aws_subnet.db.id
  vpc_security_group_ids = [data.aws_security_group.db.id]
  key_name               = "scylladb-keypair"
  iam_instance_profile   = aws_iam_instance_profile.scylladb.name

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail
    dnf install -y docker xfsprogs
    systemctl enable --now docker

    # wait for the data disk, format it once and mount it
    while [ ! -b /dev/nvme1n1 ]; do sleep 2; done
    blkid /dev/nvme1n1 || mkfs -t xfs /dev/nvme1n1
    mkdir -p /data
    mount /dev/nvme1n1 /data
    mkdir -p /data/scylla

    docker run -d --name scylla --restart always -p 9042:9042 -v /data/scylla:/var/lib/scylla scylladb/scylla:5.4 --smp 1 --overprovisioned 1 --developer-mode 1
  EOT

  user_data_replace_on_change = true

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
    tags = {
      Name        = "OTMS-dev-scylladb-root-vol"
      Application = "OTMS-dev-scylladb"
      Owner       = "Anurag"
      Environment = "dev"
      CostCenter  = "KubeClan-DevOps"
    }
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
    tags = {
      Name        = "OTMS-dev-scylladb-data-vol"
      Application = "OTMS-dev-scylladb"
      Owner       = "Anurag"
      Environment = "dev"
      CostCenter  = "KubeClan-DevOps"
    }
  }

  tags = {
    Name        = "OTMS-dev-scylladb-ec2"
    Application = "OTMS-dev-scylladb"
    Owner       = "Anurag"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------
output "instance_id" {
  value = aws_instance.scylladb.id
}

output "private_ip" {
  value = aws_instance.scylladb.private_ip
}

