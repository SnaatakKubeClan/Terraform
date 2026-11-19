# SCRUM-449: Salary App Target Group

data "aws_vpc" "dev" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

resource "aws_lb_target_group" "salary" {
  name        = "ot-ms-dev-salary-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.dev.id

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/actuator/health"
    port                = "traffic-port"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "ot-ms-dev-salary-tg"
    Application = "OTMS-dev-salary"
    Owner       = "Shivam"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}

output "salary_target_group_arn" {
  description = "Salary App Target Group ARN"
  value       = aws_lb_target_group.salary.arn
}

output "salary_target_group_name" {
  description = "Salary App Target Group name"
  value       = aws_lb_target_group.salary.name
}
