# ==============================================================================
# AWS Budgets - Whole Account & Tag-Filtered Service Level Budgets
# ==============================================================================

# 1. Whole Account Monthly Budget
resource "aws_budgets_budget" "whole_account" {
  name              = "OTMS-${var.environment}-whole-account-budget"
  budget_type       = "COST"
  limit_amount      = var.account_budget_limit
  limit_unit        = "USD"
  time_period_start = "2026-01-01_00:00"
  time_unit         = "MONTHLY"

  # Alert 1: 80% Actual Spend Threshold
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  # Alert 2: 100% Actual Spend Threshold
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  # Alert 3: 100% Forecasted Spend Threshold
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  tags = merge(
    var.tags,
    {
      Name       = "OTMS-${var.environment}-whole-account-budget"
      BudgetType = "Account"
    }
  )

  depends_on = [aws_sns_topic_policy.cost_alerts]
}

# 2. Service-Level Budgets Using Tag-Based Filters
resource "aws_budgets_budget" "services" {
  for_each = var.service_budgets

  name              = "OTMS-${var.environment}-${each.key}-service-budget"
  budget_type       = "COST"
  limit_amount      = each.value.limit_amount
  limit_unit        = "USD"
  time_period_start = "2026-01-01_00:00"
  time_unit         = "MONTHLY"

  # Cost allocation tag filter: user:Application$<ServiceTag>
  cost_filter {
    name = "TagKeyValue"
    values = [
      format("%s$%s", each.value.tag_key, each.value.tag_value)
    ]
  }

  # Alert 1: 80% Actual Spend
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  # Alert 2: 100% Actual Spend
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  tags = merge(
    var.tags,
    {
      Name       = "OTMS-${var.environment}-${each.key}-budget"
      Service    = each.key
      BudgetType = "Service"
    }
  )

  depends_on = [aws_sns_topic_policy.cost_alerts]
}

