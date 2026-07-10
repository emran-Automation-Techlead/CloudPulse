# ---------------------------------------------------------------------------
# PLAIN ENGLISH: This file exposes the IDs of the network pieces this
# module built, so other modules (like the EKS module) can plug into the
# same network instead of building their own.
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets (one per AZ)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (one per AZ) — this is where EKS worker nodes should live."
  value       = aws_subnet.private[*].id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC, useful for security group rules."
  value       = aws_vpc.this.cidr_block
}
