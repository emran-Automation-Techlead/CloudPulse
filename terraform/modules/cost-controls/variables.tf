# ---------------------------------------------------------------------------
# PLAIN ENGLISH: Settings for how much this environment is allowed to
# spend before someone gets alerted, and who receives that alert.
# ---------------------------------------------------------------------------

variable "name" {
  description = "Name prefix for cost-control resources, e.g. 'cloudpulse-dev'."
  type        = string
}

variable "monthly_budget_usd" {
  description = "Monthly spend budget in USD. Alerts fire as actual/forecasted spend approaches this number."
  type        = number
  default     = 200
}

variable "alert_email" {
  description = "Email address that receives budget and anomaly alerts."
  type        = string
}

variable "anomaly_threshold_usd" {
  description = "Dollar-impact threshold above which an unusual spend pattern triggers an anomaly alert."
  type        = number
  default     = 25
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
