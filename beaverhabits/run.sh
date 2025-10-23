#!/bin/sh
set -e

OPTS="/data/options.json"

# tiny helpers (no jq in base image)
get_json_string() {
  key="$1"
  if [ -f "$OPTS" ]; then
    sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$OPTS" | head -n1
  fi
}
get_json_bool() {
  key="$1"
  if [ -f "$OPTS" ]; then
    sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\\(true\\|false\\).*/\\1/p" "$OPTS" | head -n1
  fi
}
get_json_int() {
  key="$1"
  if [ -f "$OPTS" ]; then
    sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\\([0-9]\\+\\).*/\\1/p" "$OPTS" | head -n1
  fi
}

# Map HA options → environment variables expected by BeaverHabits
TZ_VAL="$(get_json_string TZ)"; [ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
export HABITS_STORAGE="$(get_json_string HABITS_STORAGE || echo USER_DISK)"
export TRUSTED_LOCAL_EMAIL="$(get_json_string TRUSTED_LOCAL_EMAIL)"
export ENABLE_IOS_STANDALONE="$(get_json_bool ENABLE_IOS_STANDALONE)"
IDC="$(get_json_int INDEX_HABIT_DATE_COLUMNS)"; [ -n "$IDC" ] && export INDEX_HABIT_DATE_COLUMNS="$IDC"
FDW="$(get_json_int FIRST_DAY_OF_WEEK)"; [ -n "$FDW" ] && export FIRST_DAY_OF_WEEK="$FDW"

# Upstream stores user data at /app/.user (we persist this via add-on 'map')
DATA_DIR="/app/.user"
mkdir -p "$DATA_DIR"

# Make sure the runtime user can write (upstream container usually runs as 'nobody')
detect_user() {
  for u in beaver nobody nginx www-data; do
    if id "$u" >/dev/null 2>&1; then echo "$u"; return; fi
  done
  echo "nobody"
}
RUSER="$(detect_user)"
RUID="$(id -u "$RUSER" 2>/dev/null || echo 65534)"
RGID="$(id -g "$RUSER" 2>/dev/null || echo 65534)"
chown -R "$RUID:$RGID" "$DATA_DIR" || true
chmod -R 0775 "$DATA_DIR" || true

# BeaverHabits listens on :8080 by default per upstream docs
export PORT="${PORT:-8080}"

echo "[beaverhabits-addon] DATA_DIR=$DATA_DIR HABITS_STORAGE=$HABITS_STORAGE PORT=$PORT"

# Chain to upstream start if present; otherwise try a Python module fallback
if [ -x /start.sh ]; then
  exec /start.sh
fi

if command -v python3 >/dev/null 2>&1; then
  if python3 - <<'PY' >/dev/null 2>&1
import importlib
importlib.import_module("beaverhabits")
PY
  then
    exec python3 -m beaverhabits
  fi
fi

echo "[beaverhabits-addon] Could not find upstream start command; idling for debug."
exec tail -f /dev/null
