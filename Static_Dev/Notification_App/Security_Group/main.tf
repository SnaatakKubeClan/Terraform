# ==============================================================================
# Ticket       : SCRUM-455
# Component    : Notification Application Security Group
# ==============================================================================

# Fetch existing VPC dynamically
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# Notification Application Security Group
resource "aws_security_group" "notification" {
  name        = "OTMS-dev-notification-sg"
  description = "Notification application security group"
  vpc_id      = data.aws_vpc.main.id

  # Inbound traffic from ALB & Internal VPC on application port 8085
  ingress {
    description = "Allow Notification API traffic on port 8085 from ALB and internal VPC"
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  # Outbound traffic for notification dispatch (SES, SMTP, Slack, FCM, SQS, SNS, DBs)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "OTMS-dev-notification-sg"
    Application = "OTMS-dev-notification"
    Owner       = "Anurag"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "security_group_id" {
  value = aws_security_group.notification.id
}
