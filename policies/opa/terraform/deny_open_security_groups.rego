# -----------------------------------------------------------------------
# PLAIN ENGLISH: A security group is AWS's version of a firewall rule.
# This policy blocks any change that would open a sensitive port (like
# SSH/22 or RDP/3389 — the ports used to remotely control a server) to
# the entire internet (0.0.0.0/0). Leaving these open is one of the
# fastest ways servers get compromised by automated internet scanners
# within minutes of going live.
# -----------------------------------------------------------------------

package terraform.security

import rego.v1

sensitive_ports := {22, 3389}

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_security_group_rule"
	change := resource.change.after

	change.type == "ingress"
	change.cidr_blocks[_] == "0.0.0.0/0"

	some port in sensitive_ports
	change.from_port <= port
	change.to_port >= port

	msg := sprintf(
		"Security group rule '%s' opens sensitive port %d to the entire internet (0.0.0.0/0). Restrict to specific known IP ranges instead.",
		[resource.address, port],
	)
}

deny contains msg if {
	some resource in input.resource_changes
	resource.type == "aws_security_group"
	change := resource.change.after

	some rule in object.get(change, "ingress", [])
	rule.cidr_blocks[_] == "0.0.0.0/0"
	rule.from_port <= 0
	rule.to_port >= 65535

	msg := sprintf(
		"Security group '%s' allows ALL inbound ports/protocols from 0.0.0.0/0 — this is never appropriate.",
		[resource.address],
	)
}
