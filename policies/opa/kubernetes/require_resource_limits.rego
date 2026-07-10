# -----------------------------------------------------------------------
# PLAIN ENGLISH: This policy prevents one misbehaving or buggy
# application from consuming an entire server's CPU or memory and
# starving every other application on it — a "noisy neighbor" problem.
# It requires every container to declare both a resource request (what
# it normally needs) and a resource limit (the hard ceiling it can
# never exceed). This is also a cost-control measure: requests are what
# the autoscaler uses to decide how many servers you actually need.
# -----------------------------------------------------------------------

package kubernetes.security

import rego.v1

deny contains msg if {
	input.review.object.kind == "Pod"
	some container in input.review.object.spec.containers
	not container.resources.requests

	msg := sprintf(
		"Container '%s' has no resource requests set. CPU/memory requests are required for correct autoscaling and cost control.",
		[container.name],
	)
}

deny contains msg if {
	input.review.object.kind == "Pod"
	some container in input.review.object.spec.containers
	not container.resources.limits

	msg := sprintf(
		"Container '%s' has no resource limits set. Limits are required to prevent a single container from starving the node.",
		[container.name],
	)
}
