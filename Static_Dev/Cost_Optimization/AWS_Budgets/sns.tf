# SNS Topic for Cost Alerts
resource "aws_sns_topic" "cost_alerts" {
  name = "OTMS-${var.environment}-cost-anomaly-budget-alerts"

  tags = merge(
    var.tags,
    {
      Name = "OTMS-${var.environment}-cost-anomaly-budget-alerts"
    }
  )
}

# IAM Policy Document allowing AWS Budgets and Cost Anomaly Detection to publish to SNS
data "aws_iam_policy_document" "sns_policy" {
  statement {
    sid       = "AllowAWSBudgetsPublish"
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.cost_alerts.arn]

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowCostAnomalyDetectionPublish"
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [aws_sns_topic.cost_alerts.arn]

    principals {
      type        = "Service"
      identifiers = ["costalerts.amazonaws.com"]
    }
  }
}

# Attach IAM Policy to SNS Topic
resource "aws_sns_topic_policy" "cost_alerts" {
  arn    = aws_sns_topic.cost_alerts.arn
  policy = data.aws_iam_policy_document.sns_policy.json
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
