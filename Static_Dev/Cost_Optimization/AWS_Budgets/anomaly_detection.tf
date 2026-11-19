# ==============================================================================
# AWS Cost Anomaly Detection (Monitor & Subscription)
# ==============================================================================

# 1. Cost Anomaly Monitor (Custom Environment Tag Monitor)
resource "aws_ce_anomaly_monitor" "service_monitor" {
  name         = "OTMS-${var.environment}-cost-anomaly-monitor"
  monitor_type = "CUSTOM"

  monitor_specification = jsonencode({
    Tags = {
      Key          = "user:Environment"
      Values       = [var.environment]
      MatchOptions = ["EQUALS"]
    }
  })

  tags = merge(
    var.tags,
    {
      Name = "OTMS-${var.environment}-cost-anomaly-monitor"
    }
  )
}

# 2. Cost Anomaly Subscription (Immediate Alerts via Amazon SNS to Email)
resource "aws_ce_anomaly_subscription" "cost_anomaly_subscription" {
  name      = "OTMS-${var.environment}-cost-anomaly-alerts"
  frequency = "IMMEDIATE"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.service_monitor.arn
  ]

  subscriber {
    type    = "SNS"
    address = aws_sns_topic.cost_alerts.arn
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [var.anomaly_threshold_amount]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "OTMS-${var.environment}-cost-anomaly-alerts"
    }
  )

  depends_on = [
    aws_sns_topic_policy.cost_alerts
  ]
}

