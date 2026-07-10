# ---------------------------------------------------------------------------
# PLAIN ENGLISH: This file lists the "settings" someone can change when they
# use this networking module — things like which AWS region, how many
# availability zones (data centers) to spread across, and what IP address
# ranges to use. Nothing here creates any resources by itself.
# ---------------------------------------------------------------------------

variable "name" {
  description = "Name prefix applied to all VPC resources, e.g. 'cloudpulse-dev'."
  type        = string
}

variable "cidr_block" {
  description = "IPv4 CIDR block for the VPC, e.g. '10.0.0.0/16'."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of availability zones to spread subnets across. At least 2 recommended for high availability."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ), used for load balancers and NAT gateways."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ), used for EKS nodes and other workloads with no direct internet exposure."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "If true, use one shared NAT Gateway (cheaper, less resilient) instead of one per AZ. Good default for a dev environment to control cost."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common resource tags applied to every resource this module creates, including cost-allocation tags."
  type        = map(string)
  default     = {}
}
