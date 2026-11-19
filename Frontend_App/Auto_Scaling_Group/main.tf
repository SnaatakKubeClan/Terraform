terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "otms-dev-tfstate"
    key          = "dev/frontend-asg/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

# -----------------------------------------
# EXISTING FRONTEND SUBNET
# -----------------------------------------

data "aws_subnet" "frontend" {
  filter {
    name   = "tag:Name"
    values = ["dev-otms-frontend"]
  }

  filter {
    name   = "vpc-id"
    values = ["vpc-043631a3468ade621"]
  }
}

# -----------------------------------------
# EXISTING FRONTEND LAUNCH TEMPLATE
# -----------------------------------------

data "aws_launch_template" "frontend" {
  name = "ot-ms-dev-frontend-lt"
}

# -----------------------------------------
# EXISTING FRONTEND TARGET GROUP
# -----------------------------------------

data "aws_lb_target_group" "frontend" {
  name = "OTMS-dev-frontend-tg"
}

# -----------------------------------------
# FRONTEND AUTO SCALING GROUP
# -----------------------------------------

resource "aws_autoscaling_group" "frontend" {

  name             = "ot-ms-dev-frontend-asg"

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  vpc_zone_identifier = [
    data.aws_subnet.frontend.id
  ]

  target_group_arns = [
    data.aws_lb_target_group.frontend.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = data.aws_launch_template.frontend.id
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
    value               = "ot-ms-dev-frontend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
    value               = "frontend"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "Sarthak Bhatnagar"
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
}


