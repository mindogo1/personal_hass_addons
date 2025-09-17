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
    GIT_REF_VAL="$(get_json_string GIT_REF)"

    [ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
    [ -n "$CORS_ORIGINS_VAL" ] && export CORS_ORIGINS="$CORS_ORIGINS_VAL"
    [ -n "$PUBLIC_API_BASE_URL_VAL" ] && export PUBLIC_API_BASE_URL="$PUBLIC_API_BASE_URL_VAL"
    [ -n "$AUTH_PIN_VAL" ] && export AUTH_PIN="$AUTH_PIN_VAL"

    # === Persistence ===
    mkdir -p /data
    chmod 0775 /data || true

    # Default DB path if not provided
    if [ -z "$DATABASE_URL" ]; then
      export DATABASE_URL="file:/data/tracktor.sqlite"
    fi

    # Link probable data dirs to /data so DB persists
    for d in /opt/tracktor/data /opt/tracktor/app/data; do
      if [ ! -e "$d" ]; then
        mkdir -p "$(dirname "$d")"
        ln -s /data "$d" || true
      fi
    done

    # Ensure minimal .env reflecting options
    ENVFILE="/opt/tracktor/.env"
    touch "$ENVFILE"
    grep -q "^PORT=" "$ENVFILE" || echo "PORT=3000" >> "$ENVFILE"
    [ -n "$AUTH_PIN_VAL" ] && { sed -i '/^AUTH_PIN=/d' "$ENVFILE"; echo "AUTH_PIN=$AUTH_PIN_VAL" >> "$ENVFILE"; }
    [ -n "$CORS_ORIGINS_VAL" ] && { sed -i '/^CORS_ORIGINS=/d' "$ENVFILE"; echo "CORS_ORIGINS=$CORS_ORIGINS_VAL" >> "$ENVFILE"; }
    [ -n "$PUBLIC_API_BASE_URL_VAL" ] && { sed -i '/^PUBLIC_API_BASE_URL=/d' "$ENVFILE"; echo "PUBLIC_API_BASE_URL=$PUBLIC_API_BASE_URL_VAL" >> "$ENVFILE"; }
    [ -n "$TZ_VAL" ] && { sed -i '/^TZ=/d' "$ENVFILE"; echo "TZ=$TZ_VAL" >> "$ENVFILE"; }
    [ -n "$DATABASE_URL" ] && { sed -i '/^DATABASE_URL=/d' "$ENVFILE"; echo "DATABASE_URL=$DATABASE_URL" >> "$ENVFILE"; }

    cd /opt/tracktor

    # === Auto-migrate with Drizzle if 'auth' table is missing ===
    need_migrate=0
    node -e "const url=process.env.DATABASE_URL; (async()=>{ try { const m=await import('@libsql/client'); const c=m.createClient({url}); const r=await c.execute(\"select name from sqlite_master where type='table' and name='auth'\"); process.exit(r.rows?.length?0:2);} catch(e){console.error(e); process.exit(3);} })()" || need_migrate=$?

    if [ "$need_migrate" -ne 0 ]; then
      log "Auth table not found; applying Drizzle migrations to $DATABASE_URL"

      # Try npm workspace migration scripts first if present
      if npm -w app/backend run | grep -qE 'db:(push|migrate)'; then
        set +e
        npm -w app/backend run db:push || npm -w app/backend run db:migrate
        status=$?
        set -e
        if [ "$status" -ne 0 ]; then
          log "Workspace migration script failed ($status); falling back to drizzle-kit CLI"
        else
          log "Workspace migration script completed"
          need_migrate=0
        fi
      fi

      if [ "$need_migrate" -ne 0 ]; then
        # Fallback: use drizzle-kit CLI via npx, prefer root config then backend config
        if [ -f drizzle.config.ts ] || [ -f drizzle.config.mts ] || [ -f drizzle.config.js ] || [ -f drizzle.config.mjs ]; then
          log "Running: npx drizzle-kit push:sqlite --config=drizzle.config.*"
          npx --yes drizzle-kit@latest push:sqlite --config=drizzle.config.ts || \
          npx --yes drizzle-kit@latest push:sqlite --config=drizzle.config.mts || \
          npx --yes drizzle-kit@latest push:sqlite --config=drizzle.config.js || \
          npx --yes drizzle-kit@latest push:sqlite --config=drizzle.config.mjs || true
        elif [ -f app/backend/drizzle.config.ts ] || [ -f app/backend/drizzle.config.mts ] || [ -f app/backend/drizzle.config.js ] || [ -f app/backend/drizzle.config.mjs ]; then
          log "Running: npx drizzle-kit push:sqlite --config=app/backend/drizzle.config.*"
          npx --yes drizzle-kit@latest push:sqlite --config=app/backend/drizzle.config.ts || \
          npx --yes drizzle-kit@latest push:sqlite --config=app/backend/drizzle.config.mts || \
          npx --yes drizzle-kit@latest push:sqlite --config=app/backend/drizzle.config.js || \
          npx --yes drizzle-kit@latest push:sqlite --config=app/backend/drizzle.config.mjs || true
        else
          log "No drizzle config file found; skipping CLI migration"
        fi
      fi
    fi

    # === Start the app ===
    # Prefer npm start if provided, else node build / common entrypoints
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
