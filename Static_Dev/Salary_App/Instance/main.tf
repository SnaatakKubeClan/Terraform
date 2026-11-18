data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

data "aws_subnet" "private_app_a" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-backend"]
  }
}

data "aws_security_group" "app" {
  name   = "ot-ms-dev-salary-sg"
  vpc_id = data.aws_vpc.main.id
}

# Existing custom AMI, looked up by name
data "aws_ami" "salary" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["otms-salary-ami"]
  }
}


# Existing instance profile (contains the SSM role)
data "aws_iam_instance_profile" "existing" {
  name = "otms-ssm-role"
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.salary.id
  instance_type          = "t2.medium"
  subnet_id              = data.aws_subnet.private_app_a.id
  vpc_security_group_ids = [data.aws_security_group.app.id]
  key_name               = "ot-ms-dev-ssh-key"
  iam_instance_profile   = data.aws_iam_instance_profile.existing.name

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "ot-ms-dev-salary-instance"
    Application = "salary"
    Owner       = "Priyanshu"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

output "instance_id" {
  value = aws_instance.main.id
}
