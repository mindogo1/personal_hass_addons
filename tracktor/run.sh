#!/bin/sh
set -e

OPTIONS="/data/options.json"

get_opt() {
  sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$OPTIONS" 2>/dev/null | head -n1
}

# ---- Read HA options
TZ_VAL="$(get_opt TZ)"
PORT_VAL="$(get_opt PORT)"
[ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
[ -z "$PORT_VAL" ] && PORT_VAL=3000

export HOST=0.0.0.0
export PORT="$PORT_VAL"

# ---- Persistent paths
DATA_DIR="/data/tracktor"
UPLOADS_DIR="$DATA_DIR/uploads"
DB_FILE="$DATA_DIR/tracktor.sqlite"

mkdir -p "$UPLOADS_DIR"
chmod 775 "$UPLOADS_DIR"

# ---- Database path (Tracktor supports DATABASE_URL)
export DATABASE_URL="file:$DB_FILE"

echo "[tracktor-addon] Data dir: $DATA_DIR"
echo "[tracktor-addon] Uploads: $UPLOADS_DIR"
echo "[tracktor-addon] DB: $DB_FILE"
echo "[tracktor-addon] Port: $PORT"

# ---- CRITICAL FIX ----
# Force Tracktor to resolve *all relative paths* under /data
cd "$DATA_DIR"

# ---- Start Tracktor (built output)
exec node /opt/tracktor/build
