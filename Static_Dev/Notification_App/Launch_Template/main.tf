# Ticket: Notification - Launch Template
# Uses the instance profile created by the notification-instance stack.

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

data "aws_security_group" "app" {
  name   = "OTMS-dev-notification-sg"
  vpc_id = data.aws_vpc.main.id
}

# Latest Amazon Linux 2023 AMI (AWS keeps this SSM parameter up to date)
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "main" {
  name                   = "ot-ms-dev-notification-lt"
  image_id               = data.aws_ssm_parameter.ami.value
  instance_type          = "t3.small"
  key_name               = "ot-ms-dev-key"
  vpc_security_group_ids = [data.aws_security_group.app.id]
  update_default_version = true

  user_data = base64encode(<<-EOT
    #!/bin/bash
    set -euo pipefail
    dnf install -y docker
    systemctl enable --now docker
    docker run -d --name notification --restart always -p 8080:8080 quay.io/opstree/notification-worker:latest
  EOT
  )

  iam_instance_profile {
    name = "ot-ms-dev-notification-instance-profile"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = "gp3"
      volume_size = 20
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "ot-ms-dev-notification"
      Application = "notification"
      Owner       = "Vashishtha"
      Environment = "dev"
      CostCenter  = "CC-OT-DEV-1001"
    }
  }

  tags = {
    Name        = "ot-ms-dev-notification-lt"
    Application = "notification"
    Owner       = "Vashishtha"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

output "launch_template_id" {
  value = aws_launch_template.main.id
}
