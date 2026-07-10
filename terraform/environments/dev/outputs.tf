# ---------------------------------------------------------------------------
# PLAIN ENGLISH: The values you'll need after `terraform apply` finishes —
# e.g. to configure kubectl or to set the GitHub Actions secret that
# points at the deploy role.
# ---------------------------------------------------------------------------

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "github_actions_deploy_role_arn" {
  description = "Set this as the AWS_ROLE_ARN GitHub Actions repository variable."
  value       = module.iam_oidc.deploy_role_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
