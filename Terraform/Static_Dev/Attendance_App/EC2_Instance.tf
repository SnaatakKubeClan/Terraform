
# Attendance EC2 Instance
# Ticket: SCRUM-438

# Fetch existing VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Fetch existing Backend Subnet
data "aws_subnet" "backend" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Fetch existing Attendance Security Group
data "aws_security_group" "app" {
  name   = var.security_group_name
  vpc_id = data.aws_vpc.main.id
}

# Fetch latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "ami" {
  name = var.ami_parameter
}

# Attendance EC2 Instance
resource "aws_instance" "main" {
  ami                    = data.aws_ssm_parameter.ami.value
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.backend.id
  vpc_security_group_ids = [data.aws_security_group.app.id]

  key_name = var.key_name

  # Require IMDSv2
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  # Encrypted root disk
  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
  }

  # Standard tags
  tags = {
    Name        = "OTMS-dev-attendance-ec2"
    Application = "OTMS-dev-attendance"
    Owner       = "Shivam"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
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
