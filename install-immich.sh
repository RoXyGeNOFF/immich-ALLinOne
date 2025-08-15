#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="${REPO_DIR}/immich-app"

echo "==> Immich One‑Minute Setup"
echo "Repo: ${REPO_DIR}"
echo "App dir: ${APP_DIR}"
echo ""

# --- Checks ---
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found. Install Docker first: https://docs.docker.com/engine/install/"
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  # Fallback (not recommended by Immich docs, but usable)
  COMPOSE="docker-compose"
else
  echo "ERROR: docker compose not found. Install Docker Compose plugin."
  echo "See: https://docs.docker.com/compose/install/"
  exit 1
fi

mkdir -p "${APP_DIR}"
cd "${APP_DIR}"

echo "==> Downloading docker-compose.yml and .env from latest Immich release..."
curl -fsSL -o docker-compose.yml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
curl -fsSL -o .env https://github.com/immich-app/immich/releases/latest/download/example.env

# Minimal env tuning
echo "==> Patching .env ..."
# ensure upload/db locations
grep -q '^UPLOAD_LOCATION=' .env && sed -i 's|^UPLOAD_LOCATION=.*|UPLOAD_LOCATION=./library|' .env || echo 'UPLOAD_LOCATION=./library' >> .env
grep -q '^DB_DATA_LOCATION=' .env && sed -i 's|^DB_DATA_LOCATION=.*|DB_DATA_LOCATION=./postgres|' .env || echo 'DB_DATA_LOCATION=./postgres' >> .env

# IMMICH_VERSION=release
if grep -q '^IMMICH_VERSION=' .env; then
  sed -i 's|^IMMICH_VERSION=.*|IMMICH_VERSION=release|' .env
else
  echo 'IMMICH_VERSION=release' >> .env
fi

# DB_PASSWORD random (A-Za-z0-9)
DB_PASS="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20 || true)"
if [ -z "${DB_PASS}" ]; then DB_PASS="postgres"; fi
if grep -q '^DB_PASSWORD=' .env; then
  sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|" .env
else
  echo "DB_PASSWORD=${DB_PASS}" >> .env
fi

# Timezone
if [ -f /etc/timezone ] && TZ_VAL="$(cat /etc/timezone)"; then
  :
else
  TZ_VAL="Europe/Berlin"
fi
if grep -q '^\s*#\s*TZ=' .env; then
  sed -i "s|^\s*#\s*TZ=.*|TZ=${TZ_VAL}|" .env
elif grep -q '^TZ=' .env; then
  sed -i "s|^TZ=.*|TZ=${TZ_VAL}|" .env
else
  echo "TZ=${TZ_VAL}" >> .env
fi

# make data dirs
mkdir -p library postgres

echo "==> Launching Immich containers..."
${COMPOSE} up -d

echo ""
echo "==> Done!"
IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
[ -z "${IP}" ] && IP="localhost"
echo "Open Immich:   http://${IP}:2283"
echo "Data folder:   ${APP_DIR}/library"
echo "DB password:   ${DB_PASS}"
echo ""
echo "First registered user will be admin."
