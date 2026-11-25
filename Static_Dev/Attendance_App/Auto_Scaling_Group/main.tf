# Attendance App Auto Scaling Group Infrastructure
resource "aws_autoscaling_group" "attendance_asg" {
  name                = "OTMS-dev-attendance-asg"
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = ["subnet-0a1b2c3d4e5f6g7h8"] # Dev Private Subnet

  # Linked Launch Template (EC2 Size + Python AMI + Security Group)
  launch_template {
    id      = "lt-02b975f086114ac26" # attendance-launch-template
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "OTMS-dev-attendance-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
    value               = "attendance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "Palak"
    propagate_at_launch = true
  }

  tag {
    key                 = "CostCenter"
    value               = "CC-OT-DEV-1001"
    propagate_at_launch = true
  }
}
