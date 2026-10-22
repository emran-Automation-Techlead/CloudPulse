#!/usr/bin/env bash
# PLAIN ENGLISH: Changes APP_VERSION on the live function (the honest "version bump" demo).
# Usage: ./set-version.sh 1.0.1
set -euo pipefail
# Safety gate: refuses to touch AWS unless the operator explicitly confirms after reading the identity.
echo "AWS identity: $(aws sts get-caller-identity --query Arn --output text)  region: ap-southeast-2"
[ "${CONFIRM_AWS_CHANGES:-}" = "yes" ] || { echo "Refusing: set CONFIRM_AWS_CHANGES=yes to proceed."; exit 2; }
aws lambda update-function-configuration --region ap-southeast-2 --function-name cloudpulse-demo \
  --environment "Variables={APP_VERSION=$1}" --query '[FunctionName,LastUpdateStatus]' --output text
aws lambda wait function-updated-v2 --region ap-southeast-2 --function-name cloudpulse-demo
