# Project 2 Blueprint

## Final File Tree
```text
gitops-cicd-pipeline/
├── .env                         # local only; ignored
├── .env.example
├── .gitignore
├── .dockerignore
├── README.md
├── package.json
├── package-lock.json
├── Dockerfile
├── src/
│   └── server.js
├── test/
│   └── health.test.js
├── compose/
│   ├── staging.yml
│   └── production.yml
├── deploy/
│   ├── staging.env
│   └── production.env
├── nginx/
│   └── production.conf.example
├── scripts/
│   ├── validate-plan.sh
│   ├── validate-release.sh
│   ├── deploy.sh
│   ├── verify.sh
│   └── rollback.sh
├── docs/
│   ├── blueprint.md
│   ├── deployment-contract.md
│   ├── target-inventory.md
│   ├── runbook.md
│   └── evidence.md
└── .github/
    └── workflows/
        ├── ci.yml
        ├── publish.yml
        ├── deploy-staging.yml
        └── deploy-production.yml
```

## Pipeline Diagram
```text
Feature branch -> develop -> release/* -> main (protected)
                         |
                 CI: lint + unit tests + Docker build
                         |
                 CD: deploy merged PR to staging automatically (port 8080)
                         |
                 CD: promote staging image to production Nginx proxy (port 80)
                         |
                 Automated Database Migration step before container start
                         |
                 Monitoring: stream application logs to CloudWatch Logs
                         |
                 Notifications: send pipeline failure alerts via SNS email
                         |
                 Rollback script: re-deploy last good GHCR tag in under 2 minutes
```

## Day-by-Day Build Map
| Day | Sprint step | Working verification |
| --- | --- | --- |
| 126 | Project Planning: Design staging (port 8080) and production (port 80) on one EC2 instance | Blueprint validation passes |
| 127 | Git Flow: Protect main, use develop and release/* branches | Branch protection and workflow setup verified |
| 128 | CI Pipeline: Lint, unit test, and build on every pull request | GitHub PR checks pass successfully |
| 129 | CD Pipeline: Deploy merged PR to staging environment automatically | EC2:8080/health passes |
| 130 | CD Pipeline: Promote staging image to production Nginx proxy on port 80 | EC2:80/health passes |
| 131 | Database Migrations: Add an automated migration step before container start | Migration job completes before container initialization |
| 132 | Rollback: Script to re-deploy the last good GHCR tag in under 2 minutes | Previous stable GHCR tag restored successfully |
| 133 | Monitoring: Stream application logs to CloudWatch Logs | Log groups and streams populated in CloudWatch |
| 134 | Notifications: Send pipeline failure alerts via SNS email | Test alert email successfully received via SNS |
| 135 | Documentation: Pipeline flowchart, rollback runbook, and LinkedIn post draft | Final evidence and documentation reviewed |

## Day 127 Inventory Gate
Inspect Terraform output names before selecting EC2 IP and security-group values.
Inspect existing containers, Nginx ownership, port mappings, and available memory.
Record the existing Project 1 deployment location and preservation plan.
Choose a free loopback production upstream port.
If staging port 8080 is occupied, document a controlled application integration before proceeding.
Do not create replacement infrastructure to bypass an unresolved conflict.

## Tool Policy
Use existing WSL, Git, GitHub CLI, Docker, Terraform, and AWS CLI.
Select and document a supported Node runtime before creating the API on Day 127.
Provide setup steps before introducing dependencies or a new runtime.
No paid service or subscription is required by the design.
Check account-specific AWS usage and GitHub Actions/package quotas before execution.

## Scope Limits
No Kubernetes, Argo CD, extra EC2, new database, or load balancer.
No Terraform changes in Project 1.
No infrastructure destruction.
