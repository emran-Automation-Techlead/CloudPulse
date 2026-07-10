# ---------------------------------------------------------------------------
# PLAIN ENGLISH: Settings that control which GitHub repository is trusted
# to deploy into this AWS account, and what that deploy process is allowed
# to do.
# ---------------------------------------------------------------------------

variable "github_org" {
  description = "GitHub organization or username that owns the repository, e.g. 'my-org'."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name, e.g. 'CloudPulse'."
  type        = string
}

variable "allowed_branches" {
  description = "Branches allowed to assume the deploy role, e.g. ['main']. Keep this tight — anyone who can push to these branches can deploy."
  type        = list(string)
  default     = ["main"]
}

variable "role_name" {
  description = "Name of the IAM role GitHub Actions will assume."
  type        = string
  default     = "cloudpulse-github-actions-deploy"
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
