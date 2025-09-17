\
    #!/bin/sh
    set -e

    # Read options from /data/options.json (simple extractor for quoted strings)
    opt="/data/options.json"
    get_json_string() {
      key="$1"
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
    # Prefer to exec that, so we don't guess how to start the app.
    if [ "$#" -gt 0 ]; then
      echo "Starting Tracktor with upstream CMD: $@"
      exec "$@"
    fi

    # Fallbacks only if no CMD was passed from upstream
    echo "No upstream CMD detected; trying common start targets..."

    if command -v node >/dev/null 2>&1; then
      # Try common locations
      for f in \
        /usr/src/app/server.js \
        /usr/src/app/build/index.js \
        /app/server.js \
        /app/build/index.js \
        /server.js \
        /build/index.js \
      ; do
        if [ -f "$f" ]; then
          echo "Launching Node: $f"
          exec node "$f"
        fi
      done
    fi

    # Last resort: idle to let you inspect the container
    echo "Could not detect start command. Container will idle."
    exec tail -f /dev/null
