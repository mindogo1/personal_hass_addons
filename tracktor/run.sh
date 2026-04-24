#!/usr/bin/with-contenv bash
set -e

echo "[tracktor-addon] Initializing runtime"

DATA_ROOT="/data/tracktor"
DB_FILE="${DATA_ROOT}/tracktor.db"
UPLOADS_DIR="${DATA_ROOT}/uploads"

APP_ROOT="/opt/tracktor"
APP_UPLOADS="${APP_ROOT}/uploads"

mkdir -p "$DATA_ROOT"
mkdir -p "$UPLOADS_DIR"

chmod 755 "$DATA_ROOT"
chmod 755 "$UPLOADS_DIR"

# Fix uploads symlink
if [ -e "$APP_UPLOADS" ] && [ ! -L "$APP_UPLOADS" ]; then
  rm -rf "$APP_UPLOADS"
fi

if [ ! -e "$APP_UPLOADS" ]; then
  ln -s "$UPLOADS_DIR" "$APP_UPLOADS"
fi

# DB
if [ ! -f "$DB_FILE" ]; then
  touch "$DB_FILE"
fi

export DB_PATH="$DB_FILE"
export NODE_ENV="production"

cd "$APP_ROOT"

echo "[tracktor-addon] Starting Tracktor"

# Try common entrypoints
if [ -f "build/index.js" ]; then
  exec node build/index.js
elif [ -f "dist/index.js" ]; then
  exec node dist/index.js
else
  echo "ERROR: Could not find built entrypoint"
  ls -la
  exit 1
fi