# -----------------------------------------------------------------------
# PLAIN ENGLISH: This policy makes sure sensitive data is encrypted
# "at rest" (while stored on disk), so that if a physical disk or backup
# is ever mishandled, the data on it is unreadable without the
# encryption key. It blocks unencrypted databases and unencrypted disk
# volumes from being deployed.
# -----------------------------------------------------------------------

package terraform.security

import rego.v1

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_db_instance"
	resource.change.after.storage_encrypted == false

	msg := sprintf(
		"RDS database '%s' has storage_encrypted=false — databases must be encrypted at rest.",
		[resource.address],
	)
}

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_ebs_volume"
	resource.change.after.encrypted == false

	msg := sprintf(
		"EBS volume '%s' has encrypted=false — all volumes must be encrypted at rest.",
		[resource.address],
	)
}
