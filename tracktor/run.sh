#!/bin/sh
set -e

echo "[tracktor-addon] Initializing runtime"

# ---- Home Assistant options
OPT="/data/options.json"

get_opt() {
  key="$1"
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$OPT" | head -n1
}

TZ_VAL="$(get_opt TZ)"
PORT_VAL="$(get_opt PORT)"

[ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
[ -z "$PORT_VAL" ] && PORT_VAL=3000

# ---- HARD PERSISTENCE (this is what was missing)
export NODE_ENV=production
export HOST=0.0.0.0
export PORT="$PORT_VAL"

# Tracktor uses DB_PATH as a DIRECTORY
export DB_PATH="/data/tracktor"

# Prevent demo reseeding
export DEMO_MODE=false
export FORCE_DATA_SEED=false

echo "[tracktor-addon] Database: $DB_PATH"
echo "[tracktor-addon] Uploads:  $DB_PATH/uploads"

# Ensure persistent dirs
mkdir -p "$DB_PATH/uploads"

cd /opt/tracktor

echo "[tracktor-addon] Starting Tracktor"
exec node build/server/index.js
