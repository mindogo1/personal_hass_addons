#!/bin/sh
set -e

echo "[tracktor-addon] Initializing runtime"

# ---- Persistent paths
DATA_DIR="/data/tracktor"
DB_PATH="${DATA_DIR}/tracktor.db"
UPLOADS_DIR="${DATA_DIR}/uploads"

APP_DIR="/opt/tracktor"
APP_UPLOADS="${APP_DIR}/uploads"

# ---- Ensure persistence dirs exist
mkdir -p "$DATA_DIR" "$UPLOADS_DIR"

# ---- Tracktor expects ./uploads relative to app root
if [ ! -e "$APP_UPLOADS" ]; then
  ln -s "$UPLOADS_DIR" "$APP_UPLOADS"
fi

# ---- Export EXACT variable Tracktor uses
export DB_PATH="$DB_PATH"
export HOST="0.0.0.0"
export PORT="${PORT:-3000}"
export NODE_ENV=production

echo "[tracktor-addon] Database: $DB_PATH"
echo "[tracktor-addon] Uploads:  $UPLOADS_DIR"
echo "[tracktor-addon] Starting Tracktor"

cd "$APP_DIR"
exec pnpm start
