#!/bin/sh
set -e

OPTS="/data/options.json"

get_json_string() {
  key="$1"
  [ -f "$OPTS" ] && sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$OPTS" | head -n1
}
get_json_bool() {
  key="$1"
  [ -f "$OPTS" ] && sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\\(true\\|false\\).*/\\1/p" "$OPTS" | head -n1
}
get_json_int() {
  key="$1"
  [ -f "$OPTS" ] && sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\\([0-9]\\+\\).*/\\1/p" "$OPTS" | head -n1
}

# Map HA options → env expected by BeaverHabits
TZ_VAL="$(get_json_string TZ)"; [ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
export HABITS_STORAGE="${HABITS_STORAGE:-$(get_json_string HABITS_STORAGE)}"
[ -z "$HABITS_STORAGE" ] && HABITS_STORAGE="USER_DISK"
export TRUSTED_LOCAL_EMAIL="$(get_json_string TRUSTED_LOCAL_EMAIL)"
export ENABLE_IOS_STANDALONE="$(get_json_bool ENABLE_IOS_STANDALONE)"
IDC="$(get_json_int INDEX_HABIT_DATE_COLUMNS)"; [ -n "$IDC" ] && export INDEX_HABIT_DATE_COLUMNS="$IDC"
FDW="$(get_json_int FIRST_DAY_OF_WEEK)"; [ -n "$FDW" ] && export FIRST_DAY_OF_WEEK="$FDW"

# Persisted data dir (matches upstream docs)
DATA_DIR="/app/.user"
mkdir -p "$DATA_DIR"

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

# Upstream listens on 8080
export PORT="${PORT:-8080}"

echo "[beaverhabits-addon] DATA_DIR=$DATA_DIR HABITS_STORAGE=$HABITS_STORAGE PORT=$PORT"

# Chain to upstream start script even if not executable
if [ -f /start.sh ]; then
  echo "[beaverhabits-addon] Launching upstream /start.sh"
  exec sh /start.sh
fi

# Fallback: try python module
if command -v python3 >/dev/null 2>&1; then
  if python3 - <<'PY' >/dev/null 2>&1
import importlib
importlib.import_module("beaverhabits")
PY
  then
    echo "[beaverhabits-addon] Launching via python module"
    exec python3 -m beaverhabits
  fi
fi

echo "[beaverhabits-addon] No start command found. Idling…"
exec tail -f /dev/null
