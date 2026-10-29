# Pipeline Flowchart

## End-to-End Flow
```text
Developer
   |
   v
feature/* branch
   |
   v
Pull request -> develop
   |
   v
Pull Request CI
   |- Node lint
   |- Database migration check
   |- Unit tests
   |- Docker build
   |
   v
Merge into develop
   |
   v
Deploy Staging workflow
   |- Build once
   |- Publish immutable GHCR digest
   |- Temporary runner-scoped SSH
   |- Run SQLite migration
   |- Deploy staging API on EC2 port 8080
   |- Verify public /health
   |- Revoke temporary SSH
   |
   v
release/* branch
   |
   v
Pull request -> protected main
   |
   v
Deploy Production workflow
   |- Read promoted digest from deploy/production.env
   |- Verify staging health
   |- Temporary runner-scoped SSH
   |- Run SQLite migration
   |- Deploy production API behind existing Nginx
   |- Verify public port 80 /health
   |- Revoke temporary SSH
   |
   v
Production available at EC2 port 80
   |
   v
Failure detected
   |
   v
Rollback Production workflow
   |- Manual digest input
   |- Redeploy previous good GHCR digest
   |- Verify public /health
   |- Revoke temporary SSH
   |
   v
Update deploy/production.env through release PR
```

## Observability
- Staging logs: `/gitops-cicd-pipeline/staging`
- Production logs: `/gitops-cicd-pipeline/production`
- Pipeline failure alerts: SNS email topic `gitops-cicd-pipeline-failures`
- CI, staging, and production workflows publish failure notifications through `notify-failure`

## Safety Boundaries
- Pull requests are required for `main`.
- Force pushes and deletion are disabled on `main`.
- CI runs on pull requests into `develop` and `main`.
- Staging deploys from merges into `develop`.
- Production deploys only from merges into `main`.
- Rollback is manually triggered and digest-based.
- Temporary SSH access is runner-scoped and revoked with `if: always()`.
- Project 1 RDS and Terraform infrastructure remain unchanged.
