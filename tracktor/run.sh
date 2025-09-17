\
    #!/bin/sh
    set -e

    log() { echo "[tracktor-addon] $*"; }

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

    mkdir -p /data
    chmod 0775 /data || true

    # prefer upstream entrypoint if available, but PASS a command to it
    for ep in /usr/local/bin/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh /docker-entrypoint.sh; do
      if [ -x "$ep" ]; then
        # find workdir with app
        for wd in /app /usr/src/app /srv/app /; do
          if [ -d "$wd" ]; then
            cd "$wd"
            if [ -d "./build" ]; then
              log "Using upstream entrypoint with: node build (workdir=$wd)"
              exec "$ep" node build
            fi
            for f in ./build/index.js ./server.js ./index.js ./dist/index.js ./dist/server.js; do
              if [ -f "$f" ]; then
                log "Using upstream entrypoint with: node $f (workdir=$wd)"
                exec "$ep" node "$f"
              fi
            done
          fi
        done
        # As a last resort, just call entrypoint with sh to inspect
        log "Upstream entrypoint found but no build artifacts. Starting shell for debugging."
        exec "$ep" sh -lc 'ls -la; echo "No build artifacts. Container idling..."; tail -f /dev/null'
      fi
    done

    # No upstream entrypoint, try to launch directly
    for wd in /app /usr/src/app /srv/app /; do
      if [ -d "$wd" ]; then
        cd "$wd"
        if [ -d "./build" ] && command -v node >/dev/null 2>&1; then
          log "Launching directly: node build (workdir=$wd)"
          exec node build
        fi
        for f in ./build/index.js ./server.js ./index.js ./dist/index.js ./dist/server.js; do
          if [ -f "$f" ] && command -v node >/dev/null 2>&1; then
            log "Launching directly: node $f (workdir=$wd)"
            exec node "$f"
          fi
        done
      fi
    done

    log "Could not detect start command. PWD=$(pwd)"
    ls -la || true
    exec tail -f /dev/null
