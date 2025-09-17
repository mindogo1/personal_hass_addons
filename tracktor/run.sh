\
    #!/bin/sh
    set -e

    log() { echo "[tracktor-addon] $*"; }

    # === Read HA options ===
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

    [ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
    [ -n "$CORS_ORIGINS_VAL" ] && export CORS_ORIGINS="$CORS_ORIGINS_VAL"
    [ -n "$PUBLIC_API_BASE_URL_VAL" ] && export PUBLIC_API_BASE_URL="$PUBLIC_API_BASE_URL_VAL"
    [ -n "$AUTH_PIN_VAL" ] && export AUTH_PIN="$AUTH_PIN_VAL"

    # === Persistence & DB path ===
    mkdir -p /data
    chmod 0775 /data || true
    if [ -z "$DATABASE_URL" ]; then
      export DATABASE_URL="file:/data/tracktor.sqlite"
    fi

    # Minimal .env reflecting options (for dotenv)
    ENVFILE="/opt/tracktor/.env"
    touch "$ENVFILE"
    grep -q "^PORT=" "$ENVFILE" || echo "PORT=3000" >> "$ENVFILE"
    if [ -n "$AUTH_PIN_VAL" ]; then sed -i '/^AUTH_PIN=/d' "$ENVFILE"; echo "AUTH_PIN=$AUTH_PIN_VAL" >> "$ENVFILE"; fi
    if [ -n "$CORS_ORIGINS_VAL" ]; then sed -i '/^CORS_ORIGINS=/d' "$ENVFILE"; echo "CORS_ORIGINS=$CORS_ORIGINS_VAL" >> "$ENVFILE"; fi
    if [ -n "$PUBLIC_API_BASE_URL_VAL" ]; then sed -i '/^PUBLIC_API_BASE_URL=/d' "$ENVFILE"; echo "PUBLIC_API_BASE_URL=$PUBLIC_API_BASE_URL_VAL" >> "$ENVFILE"; fi
    if [ -n "$TZ_VAL" ]; then sed -i '/^TZ=/d' "$ENVFILE"; echo "TZ=$TZ_VAL" >> "$ENVFILE"; fi
    if [ -n "$DATABASE_URL" ]; then sed -i '/^DATABASE_URL=/d' "$ENVFILE"; echo "DATABASE_URL=$DATABASE_URL" >> "$ENVFILE"; fi

    cd /opt/tracktor

    # === Always ensure 'auth' table exists (idempotent) ===
    log "Ensuring 'auth' table exists in $DATABASE_URL"
    node <<'NODE'
const url = process.env.DATABASE_URL;
(async () => {
  const { createClient } = await import('@libsql/client');
  const c = createClient({ url });
  await c.execute("CREATE TABLE IF NOT EXISTS auth (id INTEGER PRIMARY KEY, hash TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP, updated_at TEXT DEFAULT CURRENT_TIMESTAMP)");
  process.exit(0);
})().catch(e => { console.error(e); process.exit(1); });
NODE

    # === Start the app ===
    if node -e "process.exit(!!(require('./package.json').scripts||{}).start ? 0 : 1)" 2>/dev/null; then
      log "Starting: npm start"
      exec npm start --silent
    fi
    if [ -d "./build" ] && command -v node >/dev/null 2>&1; then
      log "Starting: node build"
      exec node build
    fi
    for f in ./build/index.js ./server.js ./index.js ./dist/index.js ./dist/server.js; do
      if [ -f "$f" ] && command -v node >/dev/null 2>&1; then
        log "Starting: node $f"
        exec node "$f"
      fi
    done
    log "Unable to detect start target. Listing tree for debugging:"
    ls -la
    exec tail -f /dev/null
