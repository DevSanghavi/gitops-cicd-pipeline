# Project 2 Evidence

## Implemented Pipeline
- Git Flow: protected `main`, integration `develop`, feature branches, and `release/*` promotion branches.
- CI: lint, migration check, unit tests, and Docker build on pull requests.
- Staging CD: merge into `develop` builds once, publishes a GHCR digest, deploys to EC2 port 8080, and verifies public health.
- Production CD: merge into `main` promotes the digest recorded in `deploy/production.env` behind existing Nginx on port 80.
- Database migrations: versioned SQLite migrations run as a one-shot service before each API starts.
- Rollback: manual workflow restores a previous immutable GHCR digest and verifies production health.
- Monitoring: staging and production container logs stream to separate CloudWatch Logs groups.
- Notifications: SNS email alerts fire when CI, staging, or production workflows fail.

## Verified Outcomes
- Staging endpoint: `http://<EC2_PUBLIC_IP>:8080/health`
- Production endpoint: `http://<EC2_PUBLIC_IP>/health`
- Staging and production use separate Compose projects, networks, database volumes, and CloudWatch log groups.
- Temporary SSH rules are runner-scoped and revoked after deployment or rollback.
- Project 1 EC2, RDS, VPC, and Terraform stack remain running and are not destroyed.

## Key Artifacts
- `.github/workflows/ci.yml`
- `.github/workflows/deploy-staging.yml`
- `.github/workflows/deploy-production.yml`
- `.github/workflows/rollback-production.yml`
- `compose/staging.yml`
- `compose/production.yml`
- `scripts/deploy-staging.sh`
- `scripts/deploy-production.sh`
- `scripts/rollback-production.sh`
- `deploy/production.env`
- `docs/pipeline-flowchart.md`
- `docs/runbook.md`

## Interview Summary
This project demonstrates a Git-driven CI/CD pipeline with immutable image promotion, environment isolation, automated migrations, digest-based rollback, CloudWatch Logs, and SNS failure alerts.
It uses GitHub Actions for orchestration and deploys to an existing EC2 target without recreating infrastructure.
