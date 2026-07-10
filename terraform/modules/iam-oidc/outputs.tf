# ---------------------------------------------------------------------------
# PLAIN ENGLISH: The one value GitHub Actions needs — the ARN (unique ID)
# of the role it should ask AWS to assume.
# ---------------------------------------------------------------------------

output "deploy_role_arn" {
  description = "ARN of the IAM role GitHub Actions assumes via OIDC. Set this as the AWS_ROLE_ARN repository secret/variable."
  value       = aws_iam_role.github_actions_deploy.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider registered in this AWS account."
  value       = aws_iam_openid_connect_provider.github.arn
}
