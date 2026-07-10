# ---------------------------------------------------------------------------
# PLAIN ENGLISH: The specific values used to build the "dev" environment.
# Copy terraform.tfvars.example to terraform.tfvars and fill in real
# values before running Terraform.
# ---------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name, used in tags and resource names."
  type        = string
  default     = "dev"
}

variable "cost_center" {
  description = "Cost-allocation tag value, used to attribute spend in cost reports."
  type        = string
  default     = "engineering"
}

variable "vpc_cidr" {
  description = "CIDR block for the dev VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones for the dev environment."
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per AZ."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per AZ."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.35"
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 6
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "github_org" {
  description = "GitHub org/user that owns the CloudPulse repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
  default     = "CloudPulse"
}

variable "allowed_branches" {
  description = "Branches allowed to deploy via GitHub Actions OIDC."
  type        = list(string)
  default     = ["main"]
}

variable "monthly_budget_usd" {
  description = "Monthly AWS budget for the dev environment, in USD."
  type        = number
  default     = 200
}

variable "alert_email" {
  description = "Email address that receives cost and anomaly alerts."
  type        = string
}
