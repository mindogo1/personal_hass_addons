#!/bin/sh
set -e

OPTIONS="/data/options.json"

get_opt() {
  sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$OPTIONS" 2>/dev/null | head -n1
}

# ---- HA options
TZ_VAL="$(get_opt TZ)"
PORT_VAL="$(get_opt PORT)"
[ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
[ -z "$PORT_VAL" ] && PORT_VAL=3000

export HOST=0.0.0.0
export PORT="$PORT_VAL"

# ---- Persistent paths
DATA_DIR="/data/tracktor"
UPLOADS_DIR="$DATA_DIR/uploads"
DB_FILE="$DATA_DIR/tracktor.db"

mkdir -p "$UPLOADS_DIR"
chmod 775 "$UPLOADS_DIR"

# ---- CRITICAL ENV OVERRIDES (THIS FIXES EVERYTHING)
export NODE_ENV=production
export DB_PATH="$DB_FILE"
export FORCE_DATA_SEED=false
export DEMO_MODE=false

# ---- ENSURE CWD MATCHES DB_PATH
cd "$DATA_DIR"

echo "[tracktor-addon] Initializing runtime"
echo "[tracktor-addon] Database: $DB_PATH"
echo "[tracktor-addon] Uploads:  $UPLOADS_DIR"
echo "[tracktor-addon] Starting Tracktor"

# ---- START TRACKTOR (BUILT OUTPUT)
exec node /opt/tracktor/build
