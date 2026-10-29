# LinkedIn Post Draft

I completed a 10-day hands-on GitOps-style CI/CD project using GitHub Actions, Docker, GHCR, AWS EC2, CloudWatch, and Amazon SNS.

The pipeline:

- Runs lint, migration checks, unit tests, and Docker builds on every pull request.
- Builds one immutable container image and promotes its exact digest.
- Deploys merged changes automatically to a staging environment on EC2 port 8080.
- Promotes the verified staging digest to production through the existing Nginx proxy on port 80.
- Runs database migrations before the application container starts.
- Restores the previous good image digest through a manual rollback workflow.
- Streams staging and production container logs to CloudWatch Logs.
- Sends SNS email alerts when CI or deployment workflows fail.

Key practices I applied:

- Protected main branch and pull-request-only releases.
- Separate staging and production Compose projects, networks, and database volumes.
- Temporary runner-scoped SSH access, revoked automatically after deployment.
- Immutable GHCR digests instead of mutable tags for production releases.
- Git-recorded desired state for production rollbacks.
- Least-privilege AWS permissions for deployment and logging.

This project strengthened my practical DevOps skills in CI/CD design, Docker deployment, GitHub Actions, AWS security, observability, and incident response.

#DevOps #AWS #GitHubActions #Docker #CI/CD #CloudComputing #GitOps #CloudWatch #SNS
