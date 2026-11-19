# SCRUM-468 - Employee Listener Rule of ALB

data "aws_lb" "main" {
  name = "ot-ms-dev-alb"
}

data "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 80
}

data "aws_lb_target_group" "main" {
  name = "ot-ms-dev-employee-tg"
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = data.aws_lb_listener.http.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["/api/v1/employee*"]
    }
  }

  tags = {
    Name        = "ot-ms-dev-employee-rule"
    Application = "employee"
    Owner       = "Shivam"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

output "listener_rule_arn" {
  value = aws_lb_listener_rule.main.arn
}
