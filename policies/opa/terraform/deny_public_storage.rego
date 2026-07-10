# -----------------------------------------------------------------------
# PLAIN ENGLISH: This policy is an automatic checkpoint that runs before
# any infrastructure change is applied. It blocks the deployment if it
# would create an S3 bucket (AWS's file storage service) that is
# publicly readable or writable — the single most common cause of
# accidental data breaches in the cloud. Think of it as a security
# guard who checks the blueprint before construction starts, rather
# than after the building is already open to the public.
#
# Run with: conftest test <plan.json> -p policies/opa/terraform
# -----------------------------------------------------------------------

package terraform.security

import rego.v1

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_s3_bucket_public_access_block"
	change := resource.change.after

	some field in ["block_public_acls", "block_public_policy", "ignore_public_acls", "restrict_public_buckets"]
	change[field] == false

	msg := sprintf(
		"S3 bucket public access block '%s' has %s=false — this can expose data publicly. All four block-public settings must be true.",
		[resource.address, field],
	)
}

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_s3_bucket_acl"
	acl := resource.change.after.acl

	acl in ["public-read", "public-read-write"]

	msg := sprintf(
		"S3 bucket ACL '%s' is set to '%s' — public bucket ACLs are not allowed.",
		[resource.address, acl],
	)
}
