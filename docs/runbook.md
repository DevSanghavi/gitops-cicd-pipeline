# Production Rollback Runbook

## Objective
Restore the last known-good production image digest quickly when a production release fails health verification or causes a regression.

## Rollback Target
Use an immutable GHCR image digest, never a mutable tag such as `latest`.

## Required Information
- Previous good digest: stored in the GitHub variable `LAST_GOOD_PRODUCTION_DIGEST`, or found in a prior successful production `/health` response.
- GitHub workflow: `Rollback Production`.
- Production endpoint: `http://<EC2_PUBLIC_IP>/health`.

## Rollback Procedure
1. Confirm production is unhealthy or regressed.
2. Copy the previous good `sha256:` digest.
3. Run `Rollback Production` from the GitHub Actions page.
4. Enter the previous digest in `rollback_digest`.
5. Wait for the workflow to complete.
6. Confirm `/health` returns `"status":"ok"`, `"environment":"production"`, and the rollback digest.
7. Confirm temporary SSH access was revoked.
8. Create a release PR that records the restored digest in `deploy/production.env`.
9. Merge that PR so Git desired state matches the running service.

## Workflow Actions
- Validates the supplied digest.
- Authorizes SSH only for the GitHub runner IP.
- Uses EC2 Instance Connect with a short-lived key.
- Redeploys the exact previous GHCR digest.
- Verifies production health through Nginx.
- Revokes temporary SSH access even if the workflow fails.

## Timing Target
The workflow deployment and verification should complete in under two minutes.
Measure from workflow start to workflow completion, excluding local terminal waiting.

## Escalation
If rollback fails:
1. Check the failed GitHub Actions run and SNS email.
2. Inspect CloudWatch Logs in `/gitops-cicd-pipeline/production`.
3. Verify the previous digest exists in GHCR.
4. Verify the EC2 instance profile can write to CloudWatch Logs.
5. Do not delete containers, volumes, or AWS resources as a first response.
6. Restore service with the last verified digest before investigating root cause.

## Git Consistency
After every emergency rollback, update `deploy/production.env`.
If Git still records the failed digest, the next production deployment can reintroduce it.
