#!/bin/sh
set -e

echo "[tracktor-addon] Initializing runtime"

# ---- Paths
DATA_DIR="/data/tracktor"
DB_FILE="${DATA_DIR}/tracktor.sqlite"
UPLOADS_DIR="${DATA_DIR}/uploads"

APP_DIR="/opt/tracktor"
APP_UPLOADS="${APP_DIR}/uploads"

# ---- Ensure persistence dirs exist
mkdir -p "$UPLOADS_DIR"
mkdir -p "$DATA_DIR"

# ---- Symlink uploads into app (Tracktor expects ./uploads)
if [ ! -e "$APP_UPLOADS" ]; then
  ln -s "$UPLOADS_DIR" "$APP_UPLOADS"
fi

# ---- Ensure DB file exists
if [ ! -f "$DB_FILE" ]; then
  echo "[tracktor-addon] Creating database"
  sqlite3 "$DB_FILE" 'VACUUM;' || true
fi

# ---- Force Tracktor to use persistent DB
export DATABASE_URL="file:${DB_FILE}"
export HOST=0.0.0.0
export PORT="${PORT:-3000}"

echo "[tracktor-addon] Database: $DB_FILE"
echo "[tracktor-addon] Uploads:  $UPLOADS_DIR"
echo "[tracktor-addon] Starting Tracktor"

cd /opt/tracktor
exec pnpm start
