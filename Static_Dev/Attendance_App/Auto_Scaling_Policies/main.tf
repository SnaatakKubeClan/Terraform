# -------------------------------------------------------------
# 1. SCALE-OUT POLICY & ALARM (High CPU >= 70% par +1 instance)
# -------------------------------------------------------------
resource "aws_autoscaling_policy" "attendance_scale_out" {
  name                   = "OTMS-dev-attendance-scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "OTMS-dev-attendance-asg"
}

resource "aws_cloudwatch_metric_alarm" "attendance_cpu_high" {
  alarm_name          = "OTMS-dev-attendance-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = "OTMS-dev-attendance-asg"
  }

  alarm_actions = [aws_autoscaling_policy.attendance_scale_out.arn]

  tags = {
    Name        = "OTMS-dev-attendance-high-cpu-alarm"
    Application = "attendance"
    Environment = "dev"
    Owner       = "Palak"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# -------------------------------------------------------------
# 2. SCALE-IN POLICY & ALARM (Low CPU <= 20% par -1 instance)
# -------------------------------------------------------------
resource "aws_autoscaling_policy" "attendance_scale_in" {
  name                   = "OTMS-dev-attendance-scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "OTMS-dev-attendance-asg"
}

resource "aws_cloudwatch_metric_alarm" "attendance_cpu_low" {
  alarm_name          = "OTMS-dev-attendance-low-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    AutoScalingGroupName = "OTMS-dev-attendance-asg"
  }

  alarm_actions = [aws_autoscaling_policy.attendance_scale_in.arn]

  tags = {
    Name        = "OTMS-dev-attendance-low-cpu-alarm"
    Application = "attendance"
    Environment = "dev"
    Owner       = "Palak"
    CostCenter  = "CC-OT-DEV-1001"
  }
}
