#!/bin/sh
set -e

echo "[tracktor-addon] Initializing runtime"

DATA_DIR="/data/tracktor"
DB_DIR="$DATA_DIR"
UPLOADS_DIR="$DATA_DIR/uploads"
BACKUP_DIR="$DATA_DIR/backups"

mkdir -p "$UPLOADS_DIR" "$BACKUP_DIR"

export NODE_ENV=production
export HOST=0.0.0.0
export PORT="${PORT:-3000}"

# Tracktor expects DB_PATH to be a DIRECTORY
export DB_PATH="$DB_DIR"

echo "[tracktor-addon] Database dir: $DB_PATH"
echo "[tracktor-addon] Uploads:     $UPLOADS_DIR"

# ---- BACKUP (non-blocking)
if [ -f "$DB_DIR/tracktor.db" ]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  BK="$BACKUP_DIR/tracktor-${TS}.db"
  cp "$DB_DIR/tracktor.db" "$BK" && \
    echo "[tracktor-addon] Backup created: $(basename "$BK")" || \
    echo "[tracktor-addon] WARNING: Backup failed"
fi

# Keep only last 10 backups
ls -1t "$BACKUP_DIR"/tracktor-*.db 2>/dev/null | tail -n +11 | xargs -r rm -f

echo "[tracktor-addon] Starting Tracktor"

cd /opt/tracktor

# ---- NO npm / pnpm at runtime
exec node build
