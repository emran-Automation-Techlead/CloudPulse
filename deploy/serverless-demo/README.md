# CloudPulse serverless demo

A Lambda port of `app/src/server.js` for a live demonstration in an account where EKS is blocked by an SCP.
It is **not** the EKS deployment described in the root README. See `docs/architecture/ADR-CloudPulse-Serverless-Demo.md`.

## Layout
- `src/handler.js` / `src/handler.test.js` - handler and tests (`node --test src/handler.test.js`, Node 20+)
- `iam/cloudpulse-deployer-policy.json` - draft least-privilege policy for `cloudpulse-*` in ap-southeast-2 (review before attaching)
- `iam/lambda-exec-trust.json` - trust policy for the execution role
- `scripts/` - `create-exec-role.sh` (admin, once), `deploy.sh`, `cleanup.sh`, `cost_report_synthetic.py`

## Run locally
    cd deploy/serverless-demo && npm test

## Deploy (only after approval)
    scripts/create-exec-role.sh    # admin identity
    APP_VERSION=1.0.0 scripts/deploy.sh
    curl "$URL/healthz"; curl "$URL/version"; curl "$URL/"
    scripts/cleanup.sh

## Differences from the container service
Same `/`, `/healthz`, `/version` bodies and `APP_VERSION` semantics. Unknown paths return 404 and non-GET
methods return 405 (JSON), where `server.js` returns 200 for everything else.
