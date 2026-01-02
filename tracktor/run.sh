#!/bin/sh
set -e

echo "[tracktor-addon] Initializing runtime"

DATA_DIR="/data/tracktor"
UPLOADS_DIR="$DATA_DIR/uploads"

mkdir -p "$UPLOADS_DIR"

export NODE_ENV=production
export HOST=0.0.0.0
export PORT="${PORT:-3000}"

# Tracktor expects DB_PATH to be a DIRECTORY
export DB_PATH="$DATA_DIR"

echo "[tracktor-addon] Database dir: $DB_PATH"
echo "[tracktor-addon] Uploads:     $UPLOADS_DIR"
echo "[tracktor-addon] Starting Tracktor via pnpm"

cd /opt/tracktor

exec pnpm start
