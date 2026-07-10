# -----------------------------------------------------------------------
# PLAIN ENGLISH: This policy tackles "AWS bill shock" at the source. If
# resources aren't tagged with which project and cost center they belong
# to, nobody can answer "why did the bill go up?" when it happens. This
# rule blocks any billable resource that's missing the required cost
# tags, forcing cost accountability to be part of deploying
# infrastructure, not an afterthought.
# -----------------------------------------------------------------------

package terraform.cost

import rego.v1

required_tags := {"Project", "Environment", "CostCenter"}

billable_resource_types := {
	"aws_instance",
	"aws_eks_cluster",
	"aws_eks_node_group",
	"aws_nat_gateway",
	"aws_db_instance",
	"aws_s3_bucket",
}

deny contains msg if {
	some resource in input.resource_changes
	billable_resource_types[resource.type]
	tags := object.get(resource.change.after, "tags", {})

	some required in required_tags
	not tags[required]

	msg := sprintf(
		"Resource '%s' (%s) is missing required cost-allocation tag '%s'.",
		[resource.address, resource.type, required],
	)
}
