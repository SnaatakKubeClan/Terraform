# Ticket: Notification - Auto Scaling Policies
# TargetTracking: keep average CPU near 60%. (Scaling policies cannot be tagged by AWS.)

data "aws_autoscaling_group" "main" {
  name = "ot-ms-dev-notification-asg"
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "ot-ms-dev-notification-cpu-target-tracking"
  autoscaling_group_name = data.aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 60

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

output "policy_arn" {
  value = aws_autoscaling_policy.cpu.arn
}
