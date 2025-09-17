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

    # === Persistence ===
    mkdir -p /data
    chmod 0775 /data || true
    if [ -z "$DATABASE_URL" ]; then
      export DATABASE_URL="file:/data/tracktor.sqlite"
    fi

    # Link probable data dirs to /data so DB persists
    for d in /opt/tracktor/data /opt/tracktor/app/data; do
      if [ ! -e "$d" ]; then
        mkdir -p "$(dirname "$d")"
        ln -s /data "$d" 2>/dev/null || true
      fi
    done

    # Minimal .env reflecting options
    ENVFILE="/opt/tracktor/.env"
    touch "$ENVFILE"
    grep -q "^PORT=" "$ENVFILE" || echo "PORT=3000" >> "$ENVFILE"
    if [ -n "$AUTH_PIN_VAL" ]; then sed -i '/^AUTH_PIN=/d' "$ENVFILE"; echo "AUTH_PIN=$AUTH_PIN_VAL" >> "$ENVFILE"; fi
    if [ -n "$CORS_ORIGINS_VAL" ]; then sed -i '/^CORS_ORIGINS=/d' "$ENVFILE"; echo "CORS_ORIGINS=$CORS_ORIGINS_VAL" >> "$ENVFILE"; fi
    if [ -n "$PUBLIC_API_BASE_URL_VAL" ]; then sed -i '/^PUBLIC_API_BASE_URL=/d' "$ENVFILE"; echo "PUBLIC_API_BASE_URL=$PUBLIC_API_BASE_URL_VAL" >> "$ENVFILE"; fi
    if [ -n "$TZ_VAL" ]; then sed -i '/^TZ=/d' "$ENVFILE"; echo "TZ=$TZ_VAL" >> "$ENVFILE"; fi
    if [ -n "$DATABASE_URL" ]; then sed -i '/^DATABASE_URL=/d' "$ENVFILE"; echo "DATABASE_URL=$DATABASE_URL" >> "$ENVFILE"; fi

    cd /opt/tracktor

    # Helper: returns 0 if 'auth' table exists
    check_auth_table() {
      node <<'NODE' >/dev/null 2>&1
const url=process.env.DATABASE_URL;
(async()=>{
  try {
    const {createClient} = await import('@libsql/client');
    const c = createClient({ url });
    const r = await c.execute("select name from sqlite_master where type='table' and name='auth'");
    process.exit(r.rows && r.rows.length ? 0 : 2);
  } catch (e) {
    console.error(e);
    process.exit(3);
  }
})();
NODE
    }

    # === Try migrations if 'auth' missing ===
    if ! check_auth_table; then
      log "Auth table not found; applying migrations to $DATABASE_URL"

      # 1) Compiled migration runner (JS) if present
      for mf in app/backend/dist/src/db/migrate.js app/backend/dist/db/migrate.js app/backend/dist/migrate.js; do
        if [ -f "$mf" ]; then
          log "Found compiled migration runner: $mf"
          set +e
          node "$mf" migrate || node "$mf" push || node "$mf"
          status=$?
          set -e
          if check_auth_table; then
            log "Migrations applied via compiled runner."
          else
            log "Compiled runner finished (status=$status) but 'auth' still missing."
          fi
          break
        fi
      done

      # 2) Drizzle CLI: cd into directory that has drizzle.config.* and run `npx drizzle-kit push`
      if ! check_auth_table; then
        DRZ_CFG=""
        for cfg in app/backend/drizzle.config.ts app/backend/drizzle.config.mts app/backend/drizzle.config.js app/backend/drizzle.config.mjs \
                   drizzle.config.ts drizzle.config.mts drizzle.config.js drizzle.config.mjs; do
          if [ -f "$cfg" ]; then
            DRZ_CFG="$cfg"
            break
          fi
        done
        if [ -n "$DRZ_CFG" ]; then
          DRZ_DIR="$(dirname "$DRZ_CFG")"
          log "Running drizzle-kit push in $DRZ_DIR (config $(basename "$DRZ_CFG"))"
          set +e
          ( cd "$DRZ_DIR" && npx --yes drizzle-kit@latest push )
          status=$?
          set -e
          if check_auth_table; then
            log "drizzle-kit push completed and 'auth' table exists."
          else
            log "drizzle-kit push exited ($status) and 'auth' still missing."
          fi
        else
          log "No drizzle config file found; skipping drizzle-kit."
        fi
      fi

      # 3) Last resort: create minimal 'auth' table with libsql (heredoc to avoid shell quoting)
      if ! check_auth_table; then
        log "Creating minimal 'auth' table directly as last resort."
        node <<'NODE'
const url=process.env.DATABASE_URL;
(async()=>{
  const {createClient} = await import('@libsql/client');
  const c = createClient({ url });
  await c.execute("CREATE TABLE IF NOT EXISTS auth (id INTEGER PRIMARY KEY, hash TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP, updated_at TEXT DEFAULT CURRENT_TIMESTAMP)");
  process.exit(0);
})().catch(e => { console.error(e); process.exit(1); });
NODE
        if check_auth_table; then
          log "Created 'auth' table directly."
        else
          log "Failed to create 'auth' table directly."
        fi
      fi
    fi

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
