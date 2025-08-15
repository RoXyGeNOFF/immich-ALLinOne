#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${REPO_DIR}/immich-app"
if [ ! -f "${APP_DIR}/docker-compose.yml" ]; then
  echo "docker-compose.yml not found in ${APP_DIR}"
  exit 1
fi
if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  echo "ERROR: docker compose not found."
  exit 1
fi
echo "Stopping Immich..."
${COMPOSE} -f "${APP_DIR}/docker-compose.yml" down
echo "Stopped. To remove data, delete folder: ${APP_DIR}"
