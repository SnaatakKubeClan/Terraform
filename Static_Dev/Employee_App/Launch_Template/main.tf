# 1. VPC Fetch karna
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["ot-ms-dev-vpc"]
  }
}

# 2. Employee Security Group Fetch karna (Direct ID se)
data "aws_security_group" "employee" {
  id = "sg-01c0b21fd09746473"
}

# 3. Running Instance se GOLDEN AMI banana (Automated)
resource "aws_ami_from_instance" "employee" {
  name                    = "ot-ms-dev-employee-ami"
  source_instance_id      = "i-027de9bcdd4527e3e"   # Aapka running employee instance
  snapshot_without_reboot = true                    # Instance ko restart kiye bina image banegi

  tags = {
    Name        = "ot-ms-dev-employee-ami"
    Application = "employee"
    Environment = "dev"
    Owner       = "Palak"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# 4. Launch Template Banana (Upar wali nayi AMI ID use karega)
resource "aws_launch_template" "employee" {
  name_prefix   = "ot-ms-dev-employee-lt-"
  image_id      = aws_ami_from_instance.employee.id   # <── Direct nayi bani AMI ki ID lega
  instance_type = "t3.small"
  key_name      = "ot-ms-dev-key"

  vpc_security_group_ids = [data.aws_security_group.employee.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "ot-ms-dev-employee"
      Application = "employee"
      Environment = "dev"
      Owner       = "Palak"
      CostCenter  = "CC-OT-DEV-1001"
    }
  }

  tags = {
    Name        = "ot-ms-dev-employee-lt"
    Application = "employee"
    Environment = "dev"
    Owner       = "Palak"
    CostCenter  = "CC-OT-DEV-1001"
  }
}

# Outputs
output "golden_ami_id" {
  value = aws_ami_from_instance.employee.id
}

output "launch_template_id" {
  value = aws_launch_template.employee.id
}
