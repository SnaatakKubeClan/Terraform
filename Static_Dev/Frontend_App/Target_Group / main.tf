# Ticket: SCRUM-433 - Frontend Target Group
# Health check on /

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

resource "aws_lb_target_group" "frontend" {
  name                 = "OTMS-dev-frontend-tg"
  port                 = 3000
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = data.aws_vpc.main.id
  deregistration_delay = 30

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "OTMS-dev-frontend-tg"
    Application = "OTMS-dev-frontend"
    Owner       = "Rani"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

output "target_group_arn" {
  value = aws_lb_target_group.frontend.arn
}
