variable "aws_region" {
  description = "Target AWS region for deploying resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "Email address to receive Budget and Cost Anomaly alerts"
  type        = string
  default     = "anurag.maurya.snaatak@mygurukulam.co"
}

variable "account_budget_limit" {
  description = "Whole account monthly cost budget limit in USD"
  type        = string
  default     = "100.0"
}

variable "service_budgets" {
  description = "Map of microservices with individual budget limits and cost allocation tags"
  type = map(object({
    limit_amount = string
    tag_key      = string
    tag_value    = string
  }))
  default = {
    "network" = {
      limit_amount = "30.0"
      tag_key      = "user:Application"
      tag_value    = "OTMS-dev-network"
    }
    "attendance" = {
      limit_amount = "15.0"
      tag_key      = "user:Application"
      tag_value    = "attendance"
    }
    "notification" = {
      limit_amount = "15.0"
      tag_key      = "user:Application"
      tag_value    = "notification"
    }
    "scylladb" = {
      limit_amount = "20.0"
      tag_key      = "user:Application"
      tag_value    = "scylladb"
    }
    "salary" = {
      limit_amount = "15.0"
      tag_key      = "user:Application"
      tag_value    = "salary"
    }
    "employee" = {
      limit_amount = "15.0"
      tag_key      = "user:Application"
      tag_value    = "employee"
    }
    "frontend" = {
      limit_amount = "15.0"
      tag_key      = "user:Application"
      tag_value    = "frontend"
    }
  }
}

variable "anomaly_threshold_amount" {
  description = "Absolute threshold amount in USD to trigger a Cost Anomaly alert"
  type        = string
  default     = "10.0"
}

variable "tags" {
  description = "Standard cost allocation and organizational tags"
  type        = map(string)
  default = {
    Name        = "OTMS-dev-cost-alerts"
    Application = "OTMS-dev-cost-optimization"
    Owner       = "Anurag"
    Environment = "dev"
    CostCenter  = "KubeClan-DevOps"
  }
}
