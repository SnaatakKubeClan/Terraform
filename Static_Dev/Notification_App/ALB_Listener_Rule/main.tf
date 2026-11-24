# main.tf
# Ticket: Notification - Listener rule of ALB
# Path /api/v1/notification* -> notification target group (priority 140).

data "aws_lb" "main" {
  name = "ot-ms-dev-alb"
}

data "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 80
}

data "aws_lb_target_group" "main" {
  name = "ot-ms-dev-notification-tg" # port 8080, vpc-043631a3468ade621
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = data.aws_lb_listener.http.arn
  priority     = 140

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      # Base path and everything beneath it (avoids matching /api/v1/notifications-old)
      values = ["/api/v1/notification", "/api/v1/notification/*"]
    }
  }

  tags = {
    Name        = "ot-ms-dev-notification-rule"
    Application = "notification"
  }
}

output "listener_rule_arn" {
  description = "ARN of the notification listener rule"
  value       = aws_lb_listener_rule.main.arn
}

output "alb_dns_name" {
  description = "ALB DNS name, use for the demo curl test"
  value       = data.aws_lb.main.dns_name
}
