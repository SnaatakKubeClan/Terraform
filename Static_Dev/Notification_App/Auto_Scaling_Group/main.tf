# Ticket: Notification - Auto Scaling Group
# 1 to 2 instances across dev-otms-backend subnet, ELB health checks, rolling instance refresh.

# 1. Dev VPC
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# 2. Actual Backend Subnet in AWS
data "aws_subnet" "backend" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-backend"]
  }
}

# 3. Vashishtha's Launch Template
data "aws_launch_template" "main" {
  name = "ot-ms-dev-notification-lt"
}

# 4. Maqbool's Target Group 
data "aws_lb_target_group" "main" {
  name = "ot-ms-dev-notification-tg"
}

# 5. Notification Auto Scaling Group (Ticket: SCRUM-458)
resource "aws_autoscaling_group" "main" {
  name                      = "ot-ms-dev-notification-asg"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  vpc_zone_identifier       = [data.aws_subnet.backend.id]
  target_group_arns         = [data.aws_lb_target_group.main.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120

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
    value               = "ot-ms-dev-notification"
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
    value               = "notification"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "Palak"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = true
  }

  tag {
    key                 = "CostCenter"
    value               = "CC-OT-DEV-1001"
    propagate_at_launch = true
  }

  lifecycle {
    # The scaling policy changes desired capacity at runtime
    ignore_changes = [desired_capacity]
  }
}

output "asg_name" {
  value       = aws_autoscaling_group.main.name
  description = "Name of the Notification Auto Scaling Group"
}
