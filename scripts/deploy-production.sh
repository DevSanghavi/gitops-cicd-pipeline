#!/usr/bin/env bash
set -euo pipefail

: "${PRODUCTION_IMAGE:?PRODUCTION_IMAGE is required}"
NGINX_CONTAINER="terraform-aws-infra-nginx"
API_CONTAINER="project2-production-api"

printf '%s' "${GHCR_TOKEN:?GHCR_TOKEN is required}" | docker login ghcr.io -u "${GHCR_USERNAME:?GHCR_USERNAME is required}" --password-stdin
PRODUCTION_IMAGE="$PRODUCTION_IMAGE" docker compose -p project2-production -f compose/production.yml up -d

NGINX_NETWORK="$(docker inspect "$NGINX_CONTAINER" --format '{{range $name, $network := .NetworkSettings.Networks}}{{$name}} {{end}}' | awk '{print $1}')"
test -n "$NGINX_NETWORK"
docker network connect "$NGINX_NETWORK" "$API_CONTAINER" 2>/dev/null || true

for attempt in 1 2 3 4 5; do
  if docker exec "$API_CONTAINER" wget -qO- http://127.0.0.1:3000/health 2>/dev/null | grep -q '"status":"ok"'; then
    echo "PASS: container internal health check"
    break
  fi
  sleep 2
done

docker exec "$NGINX_CONTAINER" sh -c 'cp /etc/nginx/conf.d/default.conf /tmp/default.conf.project1-backup 2>/dev/null || true'
docker cp nginx/production.conf "$NGINX_CONTAINER":/tmp/production.conf
docker exec "$NGINX_CONTAINER" sh -c 'rm -f /etc/nginx/conf.d/default.conf && cp /tmp/production.conf /etc/nginx/conf.d/default.conf'
docker exec "$NGINX_CONTAINER" nginx -t
docker exec "$NGINX_CONTAINER" nginx -s reload

for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if wget -qO- http://127.0.0.1:80/health | grep -q '"environment":"production"'; then
    echo "PASS: production health check through Nginx"
    exit 0
  fi
  sleep 3
done
echo "FAIL: production health check did not pass"
exit 1
