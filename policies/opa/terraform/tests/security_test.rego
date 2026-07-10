# -----------------------------------------------------------------------
# PLAIN ENGLISH: These are automated tests FOR the security policies
# themselves — they prove the guardrails actually catch bad
# configurations (and don't false-positive on good ones), the same way
# you'd test any other piece of code. Run with: opa test policies/opa
# -----------------------------------------------------------------------

package terraform.security_test

import rego.v1
import data.terraform.security.deny

test_open_ssh_is_denied if {
	results := deny with input as {"resource_changes": [{
		"address": "aws_security_group_rule.bad",
		"type": "aws_security_group_rule",
		"change": {"after": {
			"type": "ingress",
			"cidr_blocks": ["0.0.0.0/0"],
			"from_port": 22,
			"to_port": 22,
		}},
	}]}

	count(results) > 0
}

test_restricted_ssh_is_allowed if {
	results := deny with input as {"resource_changes": [{
		"address": "aws_security_group_rule.good",
		"type": "aws_security_group_rule",
		"change": {"after": {
			"type": "ingress",
			"cidr_blocks": ["10.0.0.0/16"],
			"from_port": 22,
			"to_port": 22,
		}},
	}]}

	count(results) == 0
}

test_public_s3_block_disabled_is_denied if {
	results := deny with input as {"resource_changes": [{
		"address": "aws_s3_bucket_public_access_block.bad",
		"type": "aws_s3_bucket_public_access_block",
		"change": {"after": {
			"block_public_acls": false,
			"block_public_policy": true,
			"ignore_public_acls": true,
			"restrict_public_buckets": true,
		}},
	}]}

	count(results) > 0
}

test_locked_down_s3_block_is_allowed if {
	results := deny with input as {"resource_changes": [{
		"address": "aws_s3_bucket_public_access_block.good",
		"type": "aws_s3_bucket_public_access_block",
		"change": {"after": {
			"block_public_acls": true,
			"block_public_policy": true,
			"ignore_public_acls": true,
			"restrict_public_buckets": true,
		}},
	}]}

	count(results) == 0
}
