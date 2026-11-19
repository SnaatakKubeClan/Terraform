# Ticket: Employee - Target Group
# Health check on /api/v1/employee/health

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

resource "aws_lb_target_group" "main" {
  name                 = "ot-ms-dev-employee-tg"
  port                 = 8080
  protocol             = "HTTP"
  target_type          = "instance"
  vpc_id               = data.aws_vpc.main.id
  deregistration_delay = 30

  health_check {
    path                = "/api/v1/employee/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "ot-ms-dev-employee-tg"
    Application = "employee"
    Owner       = "Priyanshu"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}
   
output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}
