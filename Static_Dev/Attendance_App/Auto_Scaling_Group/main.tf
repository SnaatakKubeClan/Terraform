# ==============================================================================
# Ticket       : SCRUM-442
# Component    : Attendance App Auto Scaling Group
# Architecture : dev-otms-vpc (10.0.0.0/24) in ap-south-1
# ==============================================================================

# Fetch existing VPC dynamically
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# Fetch private application subnets
data "aws_subnets" "private_app" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Tier"
    values = ["private-app"]
  }
}

# Fetch existing Attendance Launch Template
data "aws_launch_template" "main" {
  filter {
    name   = "launch-template-name"
    values = ["attendance-launch-template", "ot-ms-dev-attendance-lt", "OTMS-dev-attendance-lt"]
  }
}

# Target group data source (attach when attendance-tg is deployed)
# data "aws_lb_target_group" "main" {
#   name = "ot-ms-dev-attendance-tg"
# }

# ------------------------------------------------------------------------------
# Attendance Application Auto Scaling Group
# ------------------------------------------------------------------------------
resource "aws_autoscaling_group" "attendance" {
  name                      = "OTMS-dev-attendance-asg"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  vpc_zone_identifier       = data.aws_subnets.private_app.ids
  health_check_type         = "EC2"
  health_check_grace_period = 120

  # target_group_arns         = [data.aws_lb_target_group.main.arn]

  launch_template {
    id      = data.aws_launch_template.main.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "OTMS-dev-attendance-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
    value               = "OTMS-dev-attendance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "Anurag"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = true
  }

  tag {
    key                 = "CostCenter"
    value               = "KubeClan-DevOps"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------
output "asg_name" {
  value = aws_autoscaling_group.attendance.name
}

output "asg_arn" {
  value = aws_autoscaling_group.attendance.arn
}

