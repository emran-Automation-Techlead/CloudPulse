# CloudPulse

**A self-healing, cost-aware AWS infrastructure platform.**

CloudPulse is a reference implementation of production-grade cloud infrastructure that fixes five problems that quietly cost companies money and sleep:

| # | Problem | How CloudPulse Solves It |
|---|---------|---------------------------|
| 1 | **AWS bill shock** — surprise invoices at month end | Terraform cost-control guardrails (budgets, anomaly detection) + a weekly automated cost report posted straight to GitHub Issues |
| 2 | **Security misconfiguration** — one open S3 bucket or security group away from a breach | Policy-as-code (OPA/Rego) that blocks unsafe infrastructure *before* it's ever deployed, in CI |
| 3 | **Deployment fear** — "what if this release breaks prod?" | Canary deployments in GitHub Actions: ship to a small slice of traffic, watch it, then promote or roll back automatically |
| 4 | **Traffic spikes** — the app falls over during a sale or a viral moment | Kubernetes Horizontal Pod Autoscaler (HPA) + anti-affinity so replicas spread across nodes and scale with demand |
| 5 | **Zero visibility** — nobody knows what's running, what it costs, or whether it's secure | SBOM generation on every build, weekly cost reports, and infrastructure that is 100% defined in version-controlled code |

---

## For Hiring Managers (no technical background required)

Think of a company's cloud infrastructure like the plumbing and electrical systems of an office building. You don't see it, but if it breaks, everything stops — and if it's built carelessly, it either costs a fortune to run or becomes an easy target for a break-in.

This project demonstrates the ability to design that "plumbing" for a modern company running its software on Amazon Web Services (AWS), the most widely used cloud provider in the world. Specifically, it shows:

- **Cost discipline** — building automatic guardrails and reports so spending never becomes a surprise, and finance/leadership get a plain-language weekly summary without asking for one.
- **Security-first thinking** — instead of relying on someone remembering to "check security later," insecure infrastructure is rejected automatically before it ever goes live, the same way a spell-checker catches a typo before you hit send.
- **Safe, boring deployments** — new versions of software are rolled out gradually and automatically rolled back if something looks wrong, rather than one risky "flip the switch and hope" moment.
- **Handling growth without panic** — the system automatically adds capacity when traffic increases (think Black Friday) and scales back down when it's quiet, so the company isn't paying for capacity it doesn't need or crashing under demand it didn't expect.
- **Transparency** — every piece of software has a generated "ingredients label" (a Software Bill of Materials, or SBOM) so the security team always knows exactly what's running, which matters for audits, customer trust, and regulations like the EU Cyber Resilience Act.

Every single file in this repository, no matter how technical, opens with a short plain-English comment explaining what it does and why it matters — so anyone in the organization, technical or not, can understand the intent behind the engineering.

---

## For AWS / Cloud Engineers

- **Networking**: a VPC module with public/private subnet separation across multiple Availability Zones, NAT gateways for private egress, and no default routes to the internet from private workloads.
- **Identity**: IAM configured with an OIDC provider so GitHub Actions authenticates to AWS using short-lived, workflow-scoped credentials — **no long-lived AWS access keys stored anywhere**.
- **Cost controls**: AWS Budgets with SNS alerting, Cost Anomaly Detection monitors, and mandatory cost-allocation tags enforced at the policy layer (see `policies/opa/terraform`).
- **Compute**: an EKS module (control plane + managed node groups) built on top of the patterns used by `terraform-aws-modules/eks/aws`, with IRSA (IAM Roles for Service Accounts) so pods get least-privilege AWS permissions instead of node-wide IAM roles.

## For Terraform Engineers

- Modules live under `terraform/modules/*`, each self-contained with `main.tf` / `variables.tf` / `outputs.tf` and no hard-coded values — everything is parameterized.
- `terraform/environments/dev` is the composition root: it wires the modules together for a real deployment target. Add `environments/prod` the same way for a second environment.
- Remote state and locking are configured via `backend.tf` (S3 + DynamoDB pattern) — fill in your bucket/table before running `terraform init`.
- All infrastructure changes are expected to pass `policies/opa/terraform` policy checks (via `conftest`) in CI before `terraform apply` ever runs.

## For Kubernetes Engineers

- `k8s/base` holds the baseline manifests: Deployment, Service, HorizontalPodAutoscaler, PodDisruptionBudget, and a NetworkPolicy, composed with Kustomize.
- Pods run as non-root, with read-only root filesystems, dropped Linux capabilities, and `seccompProfile: RuntimeDefault` — aligned with the **Restricted** Pod Security Standard.
- Pod anti-affinity spreads replicas across nodes/zones so a single node or AZ failure doesn't take the whole service down.
- `policies/opa/kubernetes` contains Gatekeeper-style constraint policies that reject manifests violating these rules at admission time, as a second line of defense behind CI.

---

## Repository Layout

```
CloudPulse/
├── terraform/
│   ├── modules/
│   │   ├── vpc/              # Networking: subnets, NAT, routing
│   │   ├── eks/               # EKS control plane + managed node groups + IRSA
│   │   ├── iam-oidc/          # GitHub Actions OIDC trust + least-privilege deploy role
│   │   └── cost-controls/     # Budgets, anomaly detection, mandatory cost tags
│   └── environments/
│       └── dev/               # Composition root for the "dev" environment
├── policies/
│   └── opa/
│       ├── terraform/         # Rego policies gating `terraform plan` output
│       └── kubernetes/        # Rego/Gatekeeper policies gating K8s manifests
├── app/                        # Minimal sample service + multi-stage Dockerfile
├── k8s/                         # Kubernetes manifests (Kustomize base + overlays)
├── .github/workflows/          # CI/CD: build, scan, SBOM, canary deploy, weekly cost report
├── scripts/cost-report/        # Python script that builds the weekly cost report
└── docs/                        # Self-assessment checklist and design notes
```

## Getting Started

```bash
# 1. Review and fill in backend + variables
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars   # edit with your values

# 2. Initialize and validate
terraform init
terraform validate
terraform plan -out=tfplan

# 3. Gate the plan with policy-as-code before ever applying
terraform show -json tfplan > tfplan.json
conftest test tfplan.json -p ../../../policies/opa/terraform

# 4. Apply only after the policy gate passes
terraform apply tfplan
```

CI/CD, SBOM generation, and the weekly cost report run automatically via the workflows in `.github/workflows/` once this repository is pushed to GitHub and the required secrets (`AWS_ROLE_ARN` for OIDC, etc.) are configured in repo settings.

## Design Notes & Self-Assessment

See [`docs/SELF_ASSESSMENT.md`](docs/SELF_ASSESSMENT.md) for the 25-item quality checklist this project was built and verified against.
