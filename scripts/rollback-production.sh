#!/usr/bin/env bash
set -euo pipefail

: "${ROLLBACK_IMAGE:?ROLLBACK_IMAGE is required}"
: "${GHCR_USERNAME:?GHCR_USERNAME is required}"
: "${GHCR_TOKEN:?GHCR_TOKEN is required}"

case "$ROLLBACK_IMAGE" in
  sha256:[a-f0-9]{64}) ;;
  *) echo "FAIL: ROLLBACK_IMAGE must be a sha256 digest"; exit 1 ;;
esac

printf '%s' "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin
PRODUCTION_IMAGE="ghcr.io/devsanghavi/gitops-cicd-pipeline@$ROLLBACK_IMAGE"
PRODUCTION_IMAGE="$PRODUCTION_IMAGE" docker compose -p project2-production -f compose/production.yml up -d --wait

for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if wget -qO- http://127.0.0.1:80/health | grep -q '"environment":"production"'; then
    echo "PASS: rollback health check through Nginx"
    exit 0
  fi
  sleep 3
done

echo "FAIL: rollback health check did not pass"
exit 1
