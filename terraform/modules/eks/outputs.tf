# ---------------------------------------------------------------------------
# PLAIN ENGLISH: Details about the cluster that CI/CD and other tooling
# need in order to connect to it and deploy applications.
# ---------------------------------------------------------------------------

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the cluster, needed to configure kubectl."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider used for IRSA (IAM Roles for Service Accounts)."
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "Issuer URL of the cluster's OIDC provider (without the https:// prefix), used when writing IRSA trust policies."
  value       = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

output "node_role_arn" {
  description = "IAM role ARN used by worker nodes."
  value       = aws_iam_role.node.arn
}
