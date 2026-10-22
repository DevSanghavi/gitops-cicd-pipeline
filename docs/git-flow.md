# Git Flow

## Branch Roles
- main: production-ready release history; pull requests required.
- develop: integration branch for upcoming staging changes.
- feature/*: focused changes opened as pull requests into develop.
- release/*: release preparation branches created from develop and opened into main.

## Pipeline Mapping
- Day 128: pull-request lint, unit-test, and build checks.
- Day 129: merged changes into develop trigger staging deployment.
- Day 130: a release PR into main promotes the verified staging image.
- Promote the exact tested image digest; do not rebuild for production.
- Never commit secrets or runtime environment files.

## Protection
- main requires pull requests, including for the repository administrator.
- Force pushes and branch deletion are disabled on main.
- Review conversations must be resolved before merging.
- Zero mandatory approvals are used for this solo lab.
- Required CI checks are added on Day 128 after their names exist.
- A team repository should require approval from another reviewer.

## Release Procedure
1. Integrate feature pull requests into develop.
2. Verify the staging release when the deployment workflow exists.
3. Create release/* from the verified develop commit.
4. Open a pull request from release/* into main.
5. Review the diff and merge using a merge commit.
6. Merge origin/main back into develop and push develop.
7. Keep release branches for this project's evidence.

## Day 127 Demonstration
Release branch: release/day-127.
Change: this Git Flow document.
No deployment occurs because deployment workflows do not exist yet.

## Working Commands
git switch develop
git pull --ff-only origin develop
git switch -c release/day-127
git push -u origin release/day-127
gh pr create --base main --head release/day-127
gh pr diff
gh pr merge --merge
git switch main
git pull --ff-only origin main
git switch develop
git merge --no-edit origin/main
git push origin develop

## Safety
Do not push directly to main.
Do not bypass branch protection.
Do not change AWS infrastructure or running EC2 services for this lesson.
