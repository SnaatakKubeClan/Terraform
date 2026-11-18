# Ticket: Frontend - Listener rule of ALB
# Path /* -> frontend target group (priority 900).

data "aws_lb" "main" {
  name = "ot-ms-dev-alb"
}

data "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 80
}

data "aws_lb_target_group" "main" {
  name = "dev-otms-attendance-tg"
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = data.aws_lb_listener.http.arn
  priority     = 900

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  tags = {
    Name        = "ot-ms-dev-frontend-rule"
    Application = "frontend"
    Owner       = "Vashishtha"
    Environment = "dev"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

output "listener_rule_arn" {
  value = aws_lb_listener_rule.main.arn
}
