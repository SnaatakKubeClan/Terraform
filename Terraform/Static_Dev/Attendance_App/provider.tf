
terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "otms-dev-tfstate"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "key_name" {
  description = "Existing EC2 key pair"
  type        = string
  default     = "ot-ms-dev-ssh-key"
}
