# CloudPulse live AWS demo - narration script (target ~8:00)

Status key: [LOCAL] recorded from local real commands; [AWS] requires approved deployment (pending).
Rules: never say the EKS design was deployed; cost data in segment 6 is SYNTHETIC; the URL is live only if verified.

## 1. Intro [LOCAL, GitHub] 0:00-0:40
"CloudPulse is a self-healing, cost-aware AWS platform defined as code: Terraform for the network, EKS and cost controls, OPA policies that block unsafe changes, Kubernetes manifests, and canary CI/CD. In this video I show what genuinely runs. The EKS design is kept as code and is not deployed here, because my AWS account's organization policy blocks EKS. Instead I deployed a small serverless Lambda port of the sample service."

## 2. Code walkthrough [LOCAL] 0:40-1:50
"The original service, app/src/server.js, answers three routes: slash, healthz and version. Here is the Lambda port. Same three bodies, same APP_VERSION behaviour. Two deliberate differences: unknown paths return a JSON 404 and non-GET methods return 405. These are covered by five unit tests, which pass. Alongside are the Terraform modules, the OPA policies, and the Kubernetes base manifests that remain architecture, not live infrastructure."

## 3. AWS Console + endpoint [AWS - PENDING APPROVAL] 1:50-3:30
"Here is the Lambda function in the Sydney region... the Function URL... healthz returns status ok... version returns the version set in the environment... and the root returns the greeting." (Only record after verified deployment.)

## 4. Logs [AWS - PENDING] 3:30-4:35
"CloudWatch shows one structured log line per request: method, path and version. To troubleshoot a failed call, filter by path, check the status code and the log stream timestamp."

## 5. OPA enforcement [LOCAL] 4:35-5:45
"Policy as code. This input opens SSH to the whole internet. Running the repository's real policy returns a denial. This second input restricts SSH to a private range and returns an empty list: allowed. And the policy's own test suite passes four out of four."

## 6. Cost report [LOCAL, SYNTHETIC] 5:45-6:35
"The real weekly report script calls Cost Explorer. Here I run its formatting function on synthetic numbers, so no AWS call is made. This is not live billing data. The real report additionally includes anomaly detection."

## 7. Architecture and security [LOCAL/AWS] 6:35-7:20
"Least privilege: the deploy policy only allows Lambda, logs and PassRole on cloudpulse-star resources in Sydney. The organization SCP still wins over any allow. Cost: no NAT, load balancer or cluster, and a one-dollar zero-spend budget watches the account. Cleanup is one script."

## 8. Conclusion [AWS - PENDING] 7:20-8:00
"Recap of what was verified: tests, policy denial, the live endpoint and its logs. Next steps: deploy the container to EKS in an account that permits it."
