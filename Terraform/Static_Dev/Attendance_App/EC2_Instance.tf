
# Attendance EC2 Instance
# Ticket: SCRUM-438

# Fetch existing VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# Fetch existing Backend Subnet
data "aws_subnet" "backend" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-backend"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Fetch existing Attendance Security Group
data "aws_security_group" "app" {
  name   = "ot-ms-dev-attendance-sg"
  vpc_id = data.aws_vpc.main.id
}

# Fetch latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# IAM Role for EC2
resource "aws_iam_role" "this" {
  name = "ot-ms-dev-attendance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "ot-ms-dev-attendance-role"
    Application = "attendance"
    Owner       = "Shivam"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# Attach SSM Managed Policy
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "this" {
  name = "ot-ms-dev-attendance-instance-profile"
  role = aws_iam_role.this.name

  tags = {
    Name        = "ot-ms-dev-attendance-instance-profile"
    Application = "attendance"
    Owner       = "Shivam"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# Attendance EC2 Instance
resource "aws_instance" "main" {
  ami                    = data.aws_ssm_parameter.ami.value
  instance_type          = "t3.small"
  subnet_id              = data.aws_subnet.backend.id
  vpc_security_group_ids = [data.aws_security_group.app.id]

  key_name             = "ot-ms-dev-key"
  iam_instance_profile = aws_iam_instance_profile.this.name

  # Install Docker and run Attendance API
  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail

    dnf install -y docker
    systemctl enable --now docker

    docker run -d \
      --name attendance \
      --restart always \
      -p 8080:8080 \
      quay.io/opstree/attendance-api:latest
  EOT

  user_data_replace_on_change = true

  # Require IMDSv2
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  # Encrypted root disk
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "ot-ms-dev-attendance-instance"
    Application = "attendance"
    Owner       = "Shivam"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }

  lifecycle {
    precondition {
      condition = (
        data.aws_subnet.backend.vpc_id ==
        data.aws_security_group.app.vpc_id
      )
      error_message = "Attendance subnet and security group must belong to the same VPC."
    }
  }
}

# Outputs
output "instance_id" {
  description = "Attendance EC2 Instance ID"
  value       = aws_instance.main.id
}

output "private_ip" {
  description = "Attendance EC2 Private IP"
  value       = aws_instance.main.private_ip
}
