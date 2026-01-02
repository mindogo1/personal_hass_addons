#!/usr/bin/with-contenv sh
set -e

DATA_DIR="/data/tracktor"
DB_FILE="${DATA_DIR}/tracktor.db"
UPLOADS_DIR="${DATA_DIR}/uploads"

mkdir -p "$UPLOADS_DIR"

export DB_PATH="$DB_FILE"
export NODE_ENV="production"
export HOST=0.0.0.0
export PORT=3000

echo "[tracktor-addon] Database: $DB_PATH"
echo "[tracktor-addon] Uploads:  $UPLOADS_DIR"
echo "[tracktor-addon] Starting Tracktor"

cd /opt/tracktor
exec pnpm start
