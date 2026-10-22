# ADR: Serverless (Lambda) live demo alongside the EKS design

Status: **Proposed - awaiting owner approval** (nothing deployed yet)  
Date: 2026-10-22

## Context
CloudPulse's repository defines an EKS/VPC/NAT platform (Terraform + Kubernetes). The AWS account used for
portfolio work (account ID redacted) sits under an organization SCP that explicitly denies
EKS, ECS, EC2, App Runner and S3 listing. The only identity with working credentials, `portfolio-readonly`,
has `ReadOnlyAccess` plus deployer policies scoped to `opsbridge-live` resources.

## Decision
Keep the EKS design as code and policy (not deployed). Add `deploy/serverless-demo/`, a Lambda port of
`app/src/server.js`, deployed in **ap-southeast-2** as `cloudpulse-demo`, exposed by a **Lambda Function URL**.

| Option | Verdict |
|---|---|
| A. Lambda Function URL | **Chosen.** One resource, no extra service, no per-request API charge. |
| B. API Gateway HTTP API | Rejected. Adds a second service and ~$1.00 per million requests for no demo benefit (no auth, throttling or custom domain needed). |

SCP simulation (`iam simulate-principal-policy` with `aws:RequestedRegion=ap-southeast-2` and the draft policy)
reports `allowed` and `AllowedByOrganizations=True` for Lambda create/URL/permission/log actions. Simulation
does not prove the live call succeeds; this is verified only when deployment is attempted.

## Original service vs serverless adaptation
| | `app/src/server.js` (container/EKS) | `deploy/serverless-demo/src/handler.js` |
|---|---|---|
| Runtime | Node 20 in Docker, port 8080 | Node 22 Lambda, 128 MB, 5 s timeout |
| `/healthz`, `/version`, `/` | `{"status":"ok"}`, `{"version":...}`, greeting + version | identical bodies |
| Version | `APP_VERSION` env, default `dev` | same |
| Other paths / methods | 200 greeting for everything else | **404 / 405 JSON errors** (deliberate deviation) |

The original server and Dockerfile are untouched.

## Security
- Function URL auth type `NONE` (public, read-only, returns only static JSON). Public access is **unverified until tested**.
- No secrets, no environment values besides `APP_VERSION`.
- Execution role `cloudpulse-lambda-exec` has only `AWSLambdaBasicExecutionRole` (CloudWatch Logs write).
  Creating it is an IAM mutation: `scripts/create-exec-role.sh`, for an authorized admin; the draft deployer policy only allows `iam:PassRole` for it.
- Deployer policy: `deploy/serverless-demo/iam/cloudpulse-deployer-policy.json` (resource-scoped to `cloudpulse-*`, region-conditioned; `logs:DescribeLogGroups` needs `*`). **Not attached.**
- An IAM allow cannot override the SCP. Read-only listing calls (`lambda:ListFunctions`) remain SCP-denied, so the Console function list may not render; direct links to the function should.

## Observability
CloudWatch log group `/aws/lambda/cloudpulse-demo`, 7-day retention; each request logs a JSON line (`method`, `path`, `version`).

## Cost (estimates, not verified against billing)
- Lambda: 1M requests/month and 400,000 GB-s are in the always-free tier; the demo will make tens of requests -> **$0.00**.
- Function URL: no extra charge. CloudWatch Logs: well under 1 MB -> ~$0.00 (ingestion $0.50/GB in this region range).
- No NAT, load balancer, public IPv4, database or cluster is created.
- One day: < $0.01. One month idle: < $0.01. Exposure if the public URL were abused: invocations are billed after the free tier (~$0.20 per 1M); mitigated by deleting after the recording.
- Credits: **not verified.** Cost Explorer returned `DataUnavailableException` for this identity; one budget exists (`My Zero-Spend Budget`, limit $1, actual $0.00), which would alert on any spend. Credit eligibility/balance is unknown; do not assume coverage.

## Rollback / cleanup
`deploy/serverless-demo/scripts/cleanup.sh` deletes the URL config, function and log group. Then an admin deletes `cloudpulse-lambda-exec`.
Redeploy of a version change: `aws lambda update-function-configuration --environment Variables={APP_VERSION=...}`.

## Limitations / follow-ups
Not the real EKS workload; no auth on the URL; no CI deploy yet (a GitHub OIDC role could replace manual deploy); Sydney-only; cost data not available to this identity.
