# -----------------------------------------------------------------------
# PLAIN ENGLISH: This policy solves "zero visibility." It requires every
# workload to be labeled with what app it belongs to and what team owns
# it, so that when something goes wrong at 2am, on-call engineers (and
# cost reports) can immediately tell what it is and who to page —
# instead of an anonymous, unowned pod nobody recognizes.
# -----------------------------------------------------------------------

package kubernetes.security

import rego.v1

required_labels := {"app.kubernetes.io/name", "app.kubernetes.io/owner"}

deny contains msg if {
	input.review.object.kind == "Pod"
	labels := object.get(input.review.object.metadata, "labels", {})

	some required in required_labels
	not labels[required]

	msg := sprintf(
		"Pod '%s' is missing required label '%s'.",
		[input.review.object.metadata.name, required],
	)
}
