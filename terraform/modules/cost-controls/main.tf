# ---------------------------------------------------------------------------
# PLAIN ENGLISH: This module is the "smoke detector" for your AWS bill.
# It does three things:
#   1. Sets a monthly spending budget and emails someone at 50%, 80%, and
#      100% of that budget (and if AWS forecasts you'll blow past it).
#   2. Turns on AWS's machine-learning-based Cost Anomaly Detection, which
#      catches unusual spending patterns even if you're still under
#      budget (e.g. a misconfigured resource quietly racking up charges).
#   3. Publishes both to an email topic so a human is always in the loop —
#      this is the guardrail that prevents "AWS bill shock."
# ---------------------------------------------------------------------------

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# --- Notification channel for all cost alerts ---
resource "aws_sns_topic" "cost_alerts" {
  name = "${var.name}-cost-alerts"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# --- Budget: hard ceiling with alerts at multiple thresholds ---
resource "aws_budgets_budget" "monthly" {
  name         = "${var.name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 50
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.cost_alerts.arn]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.cost_alerts.arn]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_sns_topic_arns = [aws_sns_topic.cost_alerts.arn]
  }
}

# --- Anomaly detection: catches unusual spend even under budget ---
resource "aws_ce_anomaly_monitor" "service_monitor" {
  name              = "${var.name}-service-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "weekly_summary" {
  name      = "${var.name}-anomaly-weekly-summary"
  frequency = "WEEKLY"

  monitor_arn_list = [aws_ce_anomaly_monitor.service_monitor.arn]

  subscriber {
    type    = "SNS"
    address = aws_sns_topic.cost_alerts.arn
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [tostring(var.anomaly_threshold_usd)]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
}

# --- SNS resource policy: allow Cost Anomaly Detection to publish here ---
resource "aws_sns_topic_policy" "allow_ce_publish" {
  arn = aws_sns_topic.cost_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCostAnomalyDetectionPublish"
      Effect    = "Allow"
      Principal = { Service = "costalerts.amazonaws.com" }
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.cost_alerts.arn
    }]
  })
}
