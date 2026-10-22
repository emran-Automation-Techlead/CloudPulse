#!/usr/bin/env bash
# PLAIN ENGLISH: Kill switch. Removes the two public-access statements so the Function URL stops
# answering anonymous callers (it returns 403) while the function and logs remain for inspection.
set -uo pipefail
export AWS_REGION=ap-southeast-2 AWS_DEFAULT_REGION=ap-southeast-2
FN=cloudpulse-demo
# Safety gate: refuses to touch AWS unless the operator explicitly confirms after reading the identity.
echo "AWS identity: $(aws sts get-caller-identity --query Arn --output text)  region: ap-southeast-2"
[ "${CONFIRM_AWS_CHANGES:-}" = "yes" ] || { echo "Refusing: set CONFIRM_AWS_CHANGES=yes to proceed."; exit 2; }
aws lambda remove-permission --function-name $FN --statement-id url-public
aws lambda remove-permission --function-name $FN --statement-id url-public-invoke
