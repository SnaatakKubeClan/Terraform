# SNS Outputs
output "sns_topic_arn" {
  description = "The ARN of the SNS topic for cost alerts"
  value       = aws_sns_topic.cost_alerts.arn
}

output "sns_topic_name" {
  description = "The name of the SNS topic for cost alerts"
  value       = aws_sns_topic.cost_alerts.name
}

# AWS Budgets Outputs
output "whole_account_budget_name" {
  description = "Name of the whole account budget"
  value       = aws_budgets_budget.whole_account.name
}

output "whole_account_budget_id" {
  description = "ID of the whole account budget"
  value       = aws_budgets_budget.whole_account.id
}

output "service_budget_names" {
  description = "Names of the service-level tag-filtered budgets"
  value       = { for k, v in aws_budgets_budget.services : k => v.name }
}

output "service_budget_ids" {
  description = "IDs of the service-level tag-filtered budgets"
  value       = { for k, v in aws_budgets_budget.services : k => v.id }
}

# Cost Anomaly Outputs
output "cost_anomaly_monitor_arn" {
  description = "The ARN of the Cost Anomaly Monitor"
  value       = aws_ce_anomaly_monitor.service_monitor.arn
}

output "cost_anomaly_subscription_arn" {
  description = "The ARN of the Cost Anomaly Subscription"
  value       = aws_ce_anomaly_subscription.cost_anomaly_subscription.arn
}

