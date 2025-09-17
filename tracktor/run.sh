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

    # Put DB under app/backend/data (which points to /data) so backend sees it
    APP_DATA_DIR="/opt/tracktor/app/backend/data"
    mkdir -p /opt/tracktor/app/backend || true
    if [ ! -L "$APP_DATA_DIR" ]; then
      rm -rf "$APP_DATA_DIR" 2>/dev/null || true
      ln -s /data "$APP_DATA_DIR"
    fi

    # Canonical DB file path (persisted)
    DB_FILE="$APP_DATA_DIR/tracktor.sqlite"

    # Export several envs in case backend reads a different one
    export DATABASE_URL="file:$DB_FILE"
    export LIBSQL_URL="$DATABASE_URL"
    export TURSO_DATABASE_URL="$DATABASE_URL"
    export SQLITE_URL="$DATABASE_URL"

    # Minimal .env reflecting options (for dotenv)
    ENVFILE="/opt/tracktor/.env"
    touch "$ENVFILE"
    grep -q "^PORT=" "$ENVFILE" || echo "PORT=3000" >> "$ENVFILE"
    sed -i '/^AUTH_PIN=/d' "$ENVFILE"; [ -n "$AUTH_PIN_VAL" ] && echo "AUTH_PIN=$AUTH_PIN_VAL" >> "$ENVFILE" || true
    sed -i '/^CORS_ORIGINS=/d' "$ENVFILE"; [ -n "$CORS_ORIGINS_VAL" ] && echo "CORS_ORIGINS=$CORS_ORIGINS_VAL" >> "$ENVFILE" || true
    sed -i '/^PUBLIC_API_BASE_URL=/d' "$ENVFILE"; [ -n "$PUBLIC_API_BASE_URL_VAL" ] && echo "PUBLIC_API_BASE_URL=$PUBLIC_API_BASE_URL_VAL" >> "$ENVFILE" || true
    sed -i '/^TZ=/d' "$ENVFILE"; [ -n "$TZ_VAL" ] && echo "TZ=$TZ_VAL" >> "$ENVFILE" || true
    sed -i '/^DATABASE_URL=/d' "$ENVFILE"; echo "DATABASE_URL=$DATABASE_URL" >> "$ENVFILE"

    cd /opt/tracktor

    # === Pre-create required tables (idempotent) ===
    log "Ensuring DB and base tables exist at $DATABASE_URL"
    node <<'NODE'
const url = process.env.DATABASE_URL;
(async () => {
  const { createClient } = await import('@libsql/client');
  const c = createClient({ url });
  // auth table (for PIN)
  await c.execute(`CREATE TABLE IF NOT EXISTS auth (
    id INTEGER PRIMARY KEY,
    hash TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
  )`);
  // configs table (for /api/config)
  await c.execute(`CREATE TABLE IF NOT EXISTS configs (
    key TEXT PRIMARY KEY,
    value TEXT,
    description TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
  )`);
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
