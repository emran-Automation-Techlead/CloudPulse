#!/usr/bin/env bash
# PLAIN ENGLISH: One-time IAM step for an authorized admin: creates the Lambda execution role.
# It gets an inline policy that can only write to the cloudpulse-demo log group (the log group
# is pre-created by deploy.sh), instead of the broader AWSLambdaBasicExecutionRole.
# The portfolio-readonly user is NOT given iam:CreateRole by design.
set -euo pipefail
D="$(dirname "$0")/../iam"
aws iam create-role --role-name cloudpulse-lambda-exec \
  --assume-role-policy-document file://"$D/lambda-exec-trust.json" --tags Key=project,Value=cloudpulse
aws iam put-role-policy --role-name cloudpulse-lambda-exec --policy-name write-own-logs \
  --policy-document file://"$D/lambda-exec-logs-policy.json"
