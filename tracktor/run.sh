#!/usr/bin/with-contenv sh
set -e

DATA_DIR="/data/tracktor"
DB="$DATA_DIR/tracktor.sqlite"

mkdir -p "$DATA_DIR"

cd /opt/tracktor

echo "[tracktor-addon] Starting Tracktor (pnpm)…"
exec pnpm start
