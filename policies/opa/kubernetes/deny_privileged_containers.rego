# -----------------------------------------------------------------------
# PLAIN ENGLISH: This is a second, independent security checkpoint that
# runs INSIDE the Kubernetes cluster itself (via OPA Gatekeeper), not
# just in CI. Even if something slipped past the CI check, the cluster
# itself will refuse to run a container that asks for "privileged" mode
# (full access to the host machine) or root access — the container
# equivalent of refusing to let a guest borrow your house keys.
#
# Deploy as a Gatekeeper ConstraintTemplate + Constraint in the cluster;
# this file expresses the same Rego logic used to build that template.
# -----------------------------------------------------------------------

package kubernetes.security

import rego.v1

deny contains msg if {
	input.review.object.kind == "Pod"
	some container in input.review.object.spec.containers
	container.securityContext.privileged == true

	msg := sprintf(
		"Container '%s' requests privileged mode, which grants full host access. Not allowed.",
		[container.name],
	)
}

deny contains msg if {
	input.review.object.kind == "Pod"
	some container in input.review.object.spec.containers
	not container.securityContext.runAsNonRoot == true

	msg := sprintf(
		"Container '%s' does not set securityContext.runAsNonRoot=true. All containers must run as a non-root user.",
		[container.name],
	)
}

deny contains msg if {
	input.review.object.kind == "Pod"
	some container in input.review.object.spec.containers
	container.securityContext.allowPrivilegeEscalation == true

	msg := sprintf(
		"Container '%s' allows privilege escalation. Set allowPrivilegeEscalation: false.",
		[container.name],
	)
}
