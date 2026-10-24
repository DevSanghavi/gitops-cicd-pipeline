#!/usr/bin/env bash
set -euo pipefail

: "${STAGING_IMAGE:?STAGING_IMAGE is required}"
: "${GHCR_USERNAME:?GHCR_USERNAME is required}"
: "${GHCR_TOKEN:?GHCR_TOKEN is required}"

printf '%s' "$GHCR_TOKEN" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin
OLD_CONTAINER_IDS="$(docker ps -q --filter publish=8080 || true)"
if [ -n "$OLD_CONTAINER_IDS" ]; then
  docker stop $OLD_CONTAINER_IDS
fi
STAGING_IMAGE="$STAGING_IMAGE" docker compose -p project2-staging -f compose/staging.yml up -d
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if wget -qO- http://127.0.0.1:8080/health | grep -q '"status":"ok"'; then
    echo "PASS: staging container health check"
    exit 0
  fi
  sleep 3
done
echo "FAIL: staging health check did not pass"
exit 1
