#!/bin/sh
set -e

echo "[tracktor-addon] Initializing runtime"

# ----------------------------
# Persistent paths
# ----------------------------
DATA_ROOT="/data/tracktor"
DB_FILE="${DATA_ROOT}/tracktor.db"
UPLOADS_DIR="${DATA_ROOT}/uploads"

APP_ROOT="/opt/tracktor"
APP_UPLOADS="${APP_ROOT}/uploads"

# ----------------------------
# Ensure persistence exists
# ----------------------------
mkdir -p "$DATA_ROOT"
mkdir -p "$UPLOADS_DIR"

chmod 755 "$DATA_ROOT"
chmod 755 "$UPLOADS_DIR"

# ----------------------------
# Ensure uploads path matches app expectations
# Tracktor writes to ./uploads (relative)
# ----------------------------
if [ -e "$APP_UPLOADS" ] && [ ! -L "$APP_UPLOADS" ]; then
  rm -rf "$APP_UPLOADS"
fi

if [ ! -e "$APP_UPLOADS" ]; then
  ln -s "$UPLOADS_DIR" "$APP_UPLOADS"
fi

# ----------------------------
# Database handling
# Tracktor uses DB_PATH
# ----------------------------
if [ ! -f "$DB_FILE" ]; then
  echo "[tracktor-addon] Creating database file"
  touch "$DB_FILE"
fi

export DB_PATH="$DB_FILE"
export NODE_ENV="production"
export LOG_LEVEL="info"

echo "[tracktor-addon] Database: $DB_PATH"
echo "[tracktor-addon] Uploads:  $UPLOADS_DIR"

# ----------------------------
# Start Tracktor
# IMPORTANT:
# - MUST be run from /opt/tracktor
# - MUST NOT use pnpm/npm at runtime
# ----------------------------
cd "$APP_ROOT"

echo "[tracktor-addon] Starting Tracktor"
exec node build
