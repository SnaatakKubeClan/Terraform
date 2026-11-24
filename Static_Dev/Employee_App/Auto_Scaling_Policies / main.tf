# Ticket: Employee - Auto Scaling Group
# 1 to 2 instances in the private backend subnet (dev-otms-backend), ELB health checks, rolling instance refresh.

data "aws_subnet" "dev-otms-backend" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-backend"]
  }

  filter {
    name   = "vpc-id"
    values = ["vpc-043631a3468ade621"]
  }
}

data "aws_launch_template" "main" {
  name = "ot-ms-dev-employee-lt-20261120035737453900000001"
}

data "aws_lb_target_group" "main" {
  name = "ot-ms-dev-employee-tg"
}

resource "aws_autoscaling_group" "main" {
  name                      = "ot-ms-dev-employee-asg"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  vpc_zone_identifier       = [data.aws_subnet.dev-otms-backend.id]
  target_group_arns         = [data.aws_lb_target_group.main.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = data.aws_launch_template.main.id
    version = data.aws_launch_template.main.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "ot-ms-dev-employee"
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
    value               = "employee"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "Rani"
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
    # the scaling policy changes desired capacity at runtime
    ignore_changes = [desired_capacity]
  }
}

output "asg_name" {
  value = aws_autoscaling_group.main.name
}
