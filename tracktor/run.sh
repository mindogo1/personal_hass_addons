\
    #!/bin/sh
    set -e

    log() { echo "[tracktor-addon] $*"; }

    # Read options from /data/options.json using bashio if available, sed fallback otherwise
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

    # Ensure persistent data directory exists and is writable
    mkdir -p /data
    chmod 0775 /data || true

    # If upstream provided a CMD, it is passed to this ENTRYPOINT as "$@".
    if [ "$#" -gt 0 ]; then
      log "Starting Tracktor with upstream CMD: $@"
      exec "$@"
    fi

    log "No upstream CMD detected; attempting common start targets..."

    # Try to honour an upstream entrypoint script if present
    for ep in /usr/local/bin/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh /docker-entrypoint.sh; do
      if [ -x "$ep" ]; then
        log "Found upstream entrypoint $ep; chaining to it"
        exec "$ep"
      fi
    done

    # Try known workdirs
    for wd in /app /usr/src/app /srv/app /; do
      if [ -d "$wd" ]; then
        cd "$wd"
        # 1) SvelteKit adapter-node common: `node build` (build is a dir)
        if [ -d "./build" ]; then
          if command -v node >/dev/null 2>&1; then
            log "Launching: node build (workdir=$wd)"
            exec node build
          fi
        fi
        # 2) Explicit file paths
        for f in \
          ./build/index.js \
          ./server.js \
          ./index.js \
          ./dist/index.js \
          ./dist/server.js \
        ; do
          if [ -f "$f" ] && command -v node >/dev/null 2>&1; then
            log "Launching Node: $f (workdir=$wd)"
            exec node "$f"
          fi
        done
      fi
    done

    # Last resort: log and idle to allow inspection via bash
    log "Could not detect start command. Environment:"
    log "  PWD=$(pwd)"
    log "  Files in PWD:"
    ls -la || true
    log "  Node version:"
    node -v || true
    log "  which node:"
    which node || true
    log "Container will idle for debugging."
    exec tail -f /dev/null
