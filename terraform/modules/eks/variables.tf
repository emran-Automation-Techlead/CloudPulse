# ---------------------------------------------------------------------------
# PLAIN ENGLISH: Settings for the Kubernetes cluster itself — its name,
# version, which network to live in, and how the worker machines (nodes)
# should scale up and down.
# ---------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster, e.g. 'cloudpulse-dev'."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes control-plane version."
  type        = string
  default     = "1.35"
}

variable "vpc_id" {
  description = "VPC ID (from the vpc module) the cluster and nodes live in."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (from the vpc module) for worker nodes — nodes never sit in public subnets."
  type        = list(string)
}

variable "endpoint_public_access" {
  description = "Whether the Kubernetes API endpoint is reachable from the public internet. Keep false in production; true is convenient for a portfolio/dev demo."
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "If public access is enabled, the CIDR blocks allowed to reach the API server. Never leave this as 0.0.0.0/0 in a real environment."
  type        = list(string)
  default     = []
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Minimum number of worker nodes (floor for cost control)."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes (ceiling for cost control during traffic spikes)."
  type        = number
  default     = 6
}

variable "node_desired_size" {
  description = "Starting number of worker nodes."
  type        = number
  default     = 2
}

variable "tags" {
  description = "Common resource tags, including mandatory cost-allocation tags."
  type        = map(string)
  default     = {}
}
