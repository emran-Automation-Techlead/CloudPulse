# ---------------------------------------------------------------------------
# PLAIN ENGLISH: The ID of the alert channel, in case other tooling (like
# the weekly cost report script) needs to reference it.
# ---------------------------------------------------------------------------

output "cost_alerts_topic_arn" {
  description = "ARN of the SNS topic that receives budget and anomaly alerts."
  value       = aws_sns_topic.cost_alerts.arn
}

output "budget_name" {
  description = "Name of the monthly budget."
  value       = aws_budgets_budget.monthly.name
}
