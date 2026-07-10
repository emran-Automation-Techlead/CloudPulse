# ---------------------------------------------------------------------------
# PLAIN ENGLISH: This is where the individual building blocks (network,
# Kubernetes cluster, identity, cost controls) get wired together into one
# real, deployable "dev" environment. Think of the modules as pre-fab
# rooms and this file as the floor plan that arranges them into an
# actual house.
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

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = "CloudPulse"
    Environment = var.environment
    ManagedBy   = "Terraform"
    CostCenter  = var.cost_center
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = "cloudpulse-${var.environment}"
  cidr_block           = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = true # cost-optimized default for non-prod
  tags                 = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name        = "cloudpulse-${var.environment}"
  kubernetes_version  = var.kubernetes_version
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_instance_types = var.node_instance_types
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size
  tags                = local.common_tags
}

module "iam_oidc" {
  source = "../../modules/iam-oidc"

  github_org       = var.github_org
  github_repo      = var.github_repo
  allowed_branches = var.allowed_branches
  tags             = local.common_tags
}

module "cost_controls" {
  source = "../../modules/cost-controls"

  name               = "cloudpulse-${var.environment}"
  monthly_budget_usd = var.monthly_budget_usd
  alert_email        = var.alert_email
  tags               = local.common_tags
}
