# Deployment Contract

## Port Ownership
| Environment | Public entrypoint | Application |
| --- | --- | --- |
| Staging | EC2 port 8080 | Independent staging container |
| Production | Existing Nginx on EC2 port 80 | Independent production container |

Production application upstream is loopback-only.
Do not start another service on port 80.
Inspect existing port 8080 ownership before configuring staging.
An occupied port is a deployment blocker, not permission to stop an existing service.

## Isolation & Network
- Use separate Compose project names: `project2-staging` and `project2-production`.
- Use independent container networks and runtime configurations.
- Both environments share one EC2 failure domain (CPU/memory).
- Run container builds on GitHub Actions runners, not on the EC2 instance.

## Database Migrations (Day 131)
- Run automated database migration steps before starting new application containers.
- Ensure migration failures halt the deployment pipeline before traffic is routed.

## Monitoring & Notifications (Days 133–134)
- Stream container runtime logs directly to CloudWatch Logs.
- Send automated SNS email notifications on any pipeline failure.

## Access & Security
- Read EC2 IP and security-group IDs from Project 1 Terraform outputs. Do not modify Project 1 Terraform.
- Do not open SSH port 22 to the public (`0.0.0.0/0`).
- Keep all credentials inside repository/environment secrets, never in release manifests.

## Deployment Safety & Rollback
- Deploy staging and verify `/health` before promoting to production.
- Keep the last good image tag/digest in GHCR for fast rollback (< 2 minutes).
- No AWS infrastructure removal or destruction is permitted.

## Day 126 Boundary
Planning and local validation only.
No SSH connection, container replacement, Nginx edits, or AWS mutations today.
