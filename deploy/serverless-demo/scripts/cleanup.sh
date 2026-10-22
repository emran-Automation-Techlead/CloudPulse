#!/usr/bin/env bash
# PLAIN ENGLISH: Removes everything deploy.sh created. Safe to re-run.
set -uo pipefail
export MSYS_NO_PATHCONV=1   # Git Bash must not rewrite /aws/lambda/... into a Windows path
export AWS_REGION=ap-southeast-2 AWS_DEFAULT_REGION=ap-southeast-2
FN=cloudpulse-demo
# Safety gate: refuses to touch AWS unless the operator explicitly confirms after reading the identity.
echo "AWS identity: $(aws sts get-caller-identity --query Arn --output text)  region: ap-southeast-2"
[ "${CONFIRM_AWS_CHANGES:-}" = "yes" ] || { echo "Refusing: set CONFIRM_AWS_CHANGES=yes to proceed."; exit 2; }
aws lambda delete-function-url-config --function-name $FN
aws lambda delete-function --function-name $FN
aws logs delete-log-group --log-group-name /aws/lambda/$FN
# Role cloudpulse-lambda-exec is removed separately by whoever created it:
#   aws iam delete-role-policy --role-name cloudpulse-lambda-exec --policy-name write-own-logs
#   aws iam delete-role --role-name cloudpulse-lambda-exec
