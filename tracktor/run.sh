\
#!/bin/sh
set -e

log() { echo "[tracktor-addon] $*"; }

# read HA options (bashio if present, else sed)
opt="/data/options.json"
get_json_string() {
  key="$1"
  if command -v bashio >/dev/null 2>&1; then
    bashio::config "$key" 2>/dev/null || true
    return
  fi
  if [ -f "$opt" ]; then
    sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$opt" | head -n1
  fi
}

TZ_VAL="$(get_json_string TZ)"
CORS_ORIGINS_VAL="$(get_json_string CORS_ORIGINS)"
PUBLIC_API_BASE_URL_VAL="$(get_json_string PUBLIC_API_BASE_URL)"
AUTH_PIN_VAL="$(get_json_string AUTH_PIN)"
GIT_REF_VAL="$(get_json_string GIT_REF)"

[ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
[ -n "$CORS_ORIGINS_VAL" ] && export CORS_ORIGINS="$CORS_ORIGINS_VAL"
[ -n "$PUBLIC_API_BASE_URL_VAL" ] && export PUBLIC_API_BASE_URL="$PUBLIC_API_BASE_URL_VAL"
[ -n "$AUTH_PIN_VAL" ] && export AUTH_PIN="$AUTH_PIN_VAL"

# Ensure persistence & link likely data dirs to /data
mkdir -p /data
chmod 0775 /data || true

# The app may use ./data or ./app/data for SQLite.
# Link them to /data so DB survives restarts.
for d in /opt/tracktor/data /opt/tracktor/app/data; do
  if [ ! -e "$d" ]; then
    mkdir -p "$(dirname "$d")"
    ln -s /data "$d" || true
  fi
done

# If upstream expects a DATABASE_URL for SQLite, try to help:
# Point to /data/tracktor.sqlite if not already set.
if [ -z "$DATABASE_URL" ]; then
  export DATABASE_URL="file:/data/tracktor.sqlite"
fi

# If .env is used, generate a minimal one reflecting the add-on config.
ENVFILE="/opt/tracktor/.env"
touch "$ENVFILE"
grep -q "^PORT=" "$ENVFILE" || echo "PORT=3000" >> "$ENVFILE"
[ -n "$AUTH_PIN_VAL" ] && { sed -i '/^AUTH_PIN=/d' "$ENVFILE"; echo "AUTH_PIN=$AUTH_PIN_VAL" >> "$ENVFILE"; }
[ -n "$CORS_ORIGINS_VAL" ] && { sed -i '/^CORS_ORIGINS=/d' "$ENVFILE"; echo "CORS_ORIGINS=$CORS_ORIGINS_VAL" >> "$ENVFILE"; }
[ -n "$PUBLIC_API_BASE_URL_VAL" ] && { sed -i '/^PUBLIC_API_BASE_URL=/d' "$ENVFILE"; echo "PUBLIC_API_BASE_URL=$PUBLIC_API_BASE_URL_VAL" >> "$ENVFILE"; }
[ -n "$TZ_VAL" ] && { sed -i '/^TZ=/d' "$ENVFILE"; echo "TZ=$TZ_VAL" >> "$ENVFILE"; }
[ -n "$DATABASE_URL" ] && { sed -i '/^DATABASE_URL=/d' "$ENVFILE"; echo "DATABASE_URL=$DATABASE_URL" >> "$ENVFILE"; }

cd /opt/tracktor

# Prefer SvelteKit adapter-node: node build
if [ -d "./build" ] && command -v node >/dev/null 2>&1; then
  log "Starting: node build"
  exec node build
fi

# Try common Node entrypoints
for f in ./build/index.js ./server.js ./index.js ./dist/index.js ./dist/server.js; do
  if [ -f "$f" ] && command -v node >/dev/null 2>&1; then
    log "Starting: node $f"
    exec node "$f"
  fi
done

# Fallback to npm start if provided
if node -e "process.exit(!!(require('./package.json').scripts||{}).start ? 0 : 1)" 2>/dev/null; then
  log "Starting: npm start"
  exec npm start --silent
fi

log "Unable to detect start target. Listing tree for debugging:"
ls -la
exec tail -f /dev/null
