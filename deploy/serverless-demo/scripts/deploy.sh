#!/usr/bin/env bash
# PLAIN ENGLISH: Creates the cloudpulse-demo Lambda + public Function URL in Sydney.
# DO NOT RUN until the IAM policy is attached, the role exists and the cost plan is approved.
# Usage: AWS_PROFILE=<profile> APP_VERSION=1.0.0 ./deploy.sh
set -euo pipefail
export MSYS_NO_PATHCONV=1   # Git Bash must not rewrite /aws/lambda/... into a Windows path
export AWS_REGION=ap-southeast-2 AWS_DEFAULT_REGION=ap-southeast-2
FN=cloudpulse-demo
# Safety gate: refuses to touch AWS unless the operator explicitly confirms after reading the identity.
echo "AWS identity: $(aws sts get-caller-identity --query Arn --output text)  region: ap-southeast-2"
[ "${CONFIRM_AWS_CHANGES:-}" = "yes" ] || { echo "Refusing: set CONFIRM_AWS_CHANGES=yes to proceed."; exit 2; }
cd "$(dirname "$0")/.."
ACCT=$(aws sts get-caller-identity --query Account --output text)
ZIP="build/$FN.zip"; mkdir -p build
python -c "import zipfile;z=zipfile.ZipFile('$ZIP','w',zipfile.ZIP_DEFLATED);z.write('src/handler.js','handler.js')"
aws logs create-log-group --log-group-name /aws/lambda/$FN
aws logs put-retention-policy --log-group-name /aws/lambda/$FN --retention-in-days 7
aws lambda create-function --function-name $FN --runtime nodejs22.x --handler handler.handler \
  --role arn:aws:iam::$ACCT:role/cloudpulse-lambda-exec --zip-file fileb://$ZIP \
  --memory-size 128 --timeout 5 --environment "Variables={APP_VERSION=${APP_VERSION:-1.0.0}}" \
  --tags project=cloudpulse,purpose=demo
aws lambda wait function-active-v2 --function-name $FN
aws lambda create-function-url-config --function-name $FN --auth-type NONE
# Public access needs BOTH statements; the second is limited to calls made through the URL.
# The installed AWS CLI (2.23) lacks --invoked-via-function-url, so boto3 is used.
python - <<PY
import boto3
c = boto3.client("lambda", region_name="ap-southeast-2")
c.add_permission(FunctionName="$FN", StatementId="url-public", Action="lambda:InvokeFunctionUrl",
                 Principal="*", FunctionUrlAuthType="NONE")
c.add_permission(FunctionName="$FN", StatementId="url-public-invoke", Action="lambda:InvokeFunction",
                 Principal="*", InvokedViaFunctionUrl=True)
PY
aws lambda get-function-url-config --function-name $FN --query FunctionUrl --output text
