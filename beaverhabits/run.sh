#!/bin/sh
set -e

OPTS="/data/options.json"

jstr() { [ -f "$OPTS" ] && sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$OPTS" | head -n1; }
jbool(){ [ -f "$OPTS" ] && sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\\(true\\|false\\).*/\\1/p" "$OPTS" | head -n1; }
jint() { [ -f "$OPTS" ] && sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\\([0-9]\\+\\).*/\\1/p" "$OPTS" | head -n1; }

# Map HA options → env used by BeaverHabits
TZ_VAL="$(jstr TZ)"; [ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
export HABITS_STORAGE="${HABITS_STORAGE:-$(jstr HABITS_STORAGE)}"; [ -z "$HABITS_STORAGE" ] && HABITS_STORAGE="USER_DISK"
export TRUSTED_LOCAL_EMAIL="$(jstr TRUSTED_LOCAL_EMAIL)"
export ENABLE_IOS_STANDALONE="$(jbool ENABLE_IOS_STANDALONE)"
IDC="$(jint INDEX_HABIT_DATE_COLUMNS)"; [ -n "$IDC" ] && export INDEX_HABIT_DATE_COLUMNS="$IDC"
FDW="$(jint FIRST_DAY_OF_WEEK)"; [ -n "$FDW" ] && export FIRST_DAY_OF_WEEK="$FDW"

# Persisted data (matches upstream)
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

export PORT="${PORT:-8080}"

echo "[beaverhabits-addon] DATA_DIR=$DATA_DIR HABITS_STORAGE=$HABITS_STORAGE PORT=$PORT"

# --- Robust upstream launcher -----------------------------------------------
# Try common locations for start.sh used by the upstream image
try_start() {
  d="$1"
  [ -z "$d" ] && return 1
  if [ -f "$d/start.sh" ]; then
    echo "[beaverhabits-addon] Launching $d/start.sh"
    cd "$d"
    # run via sh to ignore missing +x
    exec sh ./start.sh
  fi
  return 1
}

# 1) Wherever it may have been copied
try_start "/"          || \
try_start "/app"       || \
try_start "/usr/src/app" || \
try_start "/workspace" || true

# 2) If there’s a top-level /start.sh regardless of cwd
if [ -f /start.sh ]; then
  echo "[beaverhabits-addon] Launching /start.sh"
  exec sh /start.sh
fi

# 3) Python module fallback (several tags support this)
if command -v python3 >/dev/null 2>&1; then
  if python3 - <<'PY' >/dev/null 2>&1
import importlib; import sys
m = importlib.util.find_spec("beaverhabits")
sys.exit(0 if m else 1)
PY
  then
    echo "[beaverhabits-addon] Launching via python module"
    exec python3 -m beaverhabits
  fi
fi

echo "[beaverhabits-addon] No start command found. Idling…"
exec tail -f /dev/null
