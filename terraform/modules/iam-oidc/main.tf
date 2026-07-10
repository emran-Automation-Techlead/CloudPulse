# ---------------------------------------------------------------------------
# PLAIN ENGLISH: This is the module that lets GitHub Actions (our CI/CD
# robot) log in to AWS WITHOUT storing a password or secret access key
# anywhere. Instead, GitHub proves its identity with a short-lived,
# cryptographically signed token every time a workflow runs, and AWS
# trusts that token only if it came from this specific GitHub repository
# and branch. If those long-lived AWS keys were used instead and ever
# leaked (committed to git by accident, stolen from a laptop), an
# attacker would have standing access to the AWS account forever. This
# approach removes that risk entirely — there is nothing long-lived to
# steal.
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

data "aws_caller_identity" "current" {}

# GitHub's OIDC thumbprint is stable and published by GitHub; AWS also
# validates the token signature independently, so this is a defense-in-depth
# check rather than the sole trust boundary.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = var.tags
}

# --- Trust policy: only THIS repo, on THESE branches, can assume this role ---
data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [for b in var.allowed_branches : "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${b}"]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name                 = var.role_name
  assume_role_policy   = data.aws_iam_policy_document.trust.json
  max_session_duration = 3600

  tags = var.tags
}

# --- Permissions: least privilege for what CI/CD actually needs to do ---
# Scoped to the actions required to plan/apply Terraform, push images to
# ECR, and deploy to EKS. Broad AWS-managed "*FullAccess" policies are
# deliberately avoided.
data "aws_iam_policy_document" "deploy_permissions" {
  statement {
    sid    = "TerraformStateAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = ["*"] # Scope to specific state bucket/table ARNs in the real environment.
  }

  statement {
    sid    = "ECRPush"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EKSDeploy"
    effect = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CostExplorerRead"
    effect = "Allow"
    actions = [
      "ce:GetCostAndUsage",
      "ce:GetCostForecast",
      "ce:GetAnomalies",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "deploy_permissions" {
  name   = "${var.role_name}-permissions"
  role   = aws_iam_role.github_actions_deploy.id
  policy = data.aws_iam_policy_document.deploy_permissions.json
}
