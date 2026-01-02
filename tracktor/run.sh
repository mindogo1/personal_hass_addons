#!/bin/sh
set -e

echo "[tracktor-addon] Initializing runtime"

DATA_DIR="/data/tracktor"
UPLOADS_DIR="${DATA_DIR}/uploads"

mkdir -p "$UPLOADS_DIR"

export NODE_ENV=production
export DB_PATH="$DATA_DIR"
export HOST=0.0.0.0
export PORT="${PORT:-3000}"

echo "[tracktor-addon] Database: ${DB_PATH}"
echo "[tracktor-addon] Uploads:  ${UPLOADS_DIR}"
echo "[tracktor-addon] Starting Tracktor"

cd /opt/tracktor
exec pnpm start
