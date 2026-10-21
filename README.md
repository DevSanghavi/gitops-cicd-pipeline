# GitOps CI/CD Pipeline

## Objective
Build, test, publish, stage, promote, verify, and roll back a containerized API using GitHub Actions and the existing Project 1 EC2 following the new 10-day sprint plan.

## Target
- Infrastructure source: ../terraform-aws-infra.
- Obtain EC2 IP and security-group IDs from Terraform outputs, never hardcode them.
- Staging entrypoint: http://EC2_IP:8080/health.
- Production entrypoint: http://EC2_IP/health through Nginx on port 80.
- No new EC2, RDS, VPC, or Terraform stack.
- Existing Project 1 infrastructure remains running.

## Architecture & Sprint Plan (Days 126–135)
- Day 126: Project Planning (Design staging on port 8080 and production on port 80)
- Day 127: Git Flow (Protect main, use develop and release/* branches)
- Day 128: CI Pipeline (Lint, unit test, and build on every pull request)
- Day 129: CD Pipeline (Deploy merged PR to staging automatically)
- Day 130: CD Pipeline (Promote staging image to production Nginx proxy on port 80)
- Day 131: Database Migrations (Add automated migration step before container start)
- Day 132: Rollback (Script to re-deploy last good GHCR tag in under 2 minutes)
- Day 133: Monitoring (Stream application logs to CloudWatch Logs)
- Day 134: Notifications (Send pipeline failure alerts via SNS email)
- Day 135: Documentation (Pipeline flowchart, rollback runbook, and LinkedIn post draft)

## Release Contract
- Registry: ghcr.io/devsanghavi/gitops-cicd-pipeline.
- Build once and promote the same sha256 image digest.
- Release manifests contain no credentials.
- Production requires an explicit reviewed promotion.
- Serialize deployment jobs to prevent overlapping releases.

## Documentation
- docs/blueprint.md: final file tree and updated daily build map.
- docs/deployment-contract.md: ports, isolation, and deployment safety.
- docs/runbook.md: deployment and rollback procedures.
- docs/evidence.md: end-to-end evidence.

## Day 126 Commands
1. Initialize the separate repository and ignore .env.
2. Write the blueprint and deployment contract.
3. Run bash scripts/validate-plan.sh.
4. Commit and publish the repository.
5. Commit the Cloud-Core-180 marker separately.

## Validation
bash scripts/validate-plan.sh

## Cleanup
NONE. Project resources stay running.
Never execute infrastructure destruction or resource deletion.
