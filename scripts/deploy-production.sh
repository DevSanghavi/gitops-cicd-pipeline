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

# Project 1 mounts default.conf read-only, so write to the host source file instead.
CONF_SRC="$(docker inspect "$NGINX_CONTAINER" --format '{{range .Mounts}}{{if eq .Destination "/etc/nginx/conf.d/default.conf"}}{{.Source}}{{end}}{{end}}')"
if [ -z "$CONF_SRC" ]; then
  CONF_DIR="$(docker inspect "$NGINX_CONTAINER" --format '{{range .Mounts}}{{if eq .Destination "/etc/nginx/conf.d"}}{{.Source}}{{end}}{{end}}')"
  [ -n "$CONF_DIR" ] && CONF_SRC="$CONF_DIR/default.conf"
fi
[ -n "$CONF_SRC" ] || { echo "FAIL: cannot locate Nginx config mount"; exit 1; }
echo "Nginx config source on host: $CONF_SRC"

# Keep the original Project 1 config once, never overwrite the backup.
[ -f "$CONF_SRC.project1-backup" ] || sudo cp -p "$CONF_SRC" "$CONF_SRC.project1-backup"

# tee writes in place (same inode), so the bind mount sees the change.
sudo tee "$CONF_SRC" < nginx/production.conf > /dev/null

if ! docker exec "$NGINX_CONTAINER" nginx -t; then
  echo "FAIL: nginx config invalid, restoring Project 1 config"
  sudo tee "$CONF_SRC" < "$CONF_SRC.project1-backup" > /dev/null
  exit 1
fi
docker exec "$NGINX_CONTAINER" nginx -s reload

for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if curl -fsS http://127.0.0.1:80/health | grep -q '"environment":"production"'; then
    echo "PASS: production health check through Nginx"
    exit 0
  fi
  sleep 3
done
echo "FAIL: production health check did not pass"
exit 1
