#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

for file in README.md docs/blueprint.md docs/deployment-contract.md; do
  test -s "$file"
done

git check-ignore -q .env
grep -q '8080' docs/deployment-contract.md
grep -q 'port 80' docs/deployment-contract.md
grep -q 'Migration' docs/blueprint.md
grep -q 'CloudWatch' docs/blueprint.md
grep -q 'SNS' docs/blueprint.md

for day in {126..135}; do
  grep -q "^| $day |" docs/blueprint.md
done

echo "PASS: blueprint, ports, database migrations, CloudWatch monitoring, SNS alerts, and day map"
