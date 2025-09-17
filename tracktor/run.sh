\
    #!/bin/sh
    set -e

    # Read options from /data/options.json
    opt="/data/options.json"
    get_json_string() {
      key="$1"
      if [ -f "$opt" ]; then
        sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$opt" | head -n1
      fi
    }

    export TZ="$(get_json_string TZ || echo "")"
    export CORS_ORIGINS="$(get_json_string CORS_ORIGINS || echo "")"
    export PUBLIC_API_BASE_URL="$(get_json_string PUBLIC_API_BASE_URL || echo "")"
    export AUTH_PIN="$(get_json_string AUTH_PIN || echo "")"

    # Ensure persistent data dir exists and is writable
    mkdir -p /data
    chmod 0775 /data || true
    # If the app expects a sqlite file in /data, ensure dir perms allow it.

    # Some upstream images bind to 0.0.0.0:3000; nothing to change here.
    # If Tracktor honors AUTH_PIN/CORS/Public base URL via envs, we're set.

    # Start upstream CMD/ENTRYPOINT; if not available, try common Node starts.
    # We exec the original entrypoint if we can find it; otherwise fall back.
    if [ -x /startup.sh ]; then
      exec /startup.sh
    fi

    # If the image defines CMD ["node","server.js"] it will be used when we exec "container's default"
    # Try common commands:
    if command -v dumb-init >/dev/null 2>&1 && [ -f /usr/local/bin/docker-entrypoint.sh ]; then
      exec /usr/local/bin/docker-entrypoint.sh "$@"
    fi

    # Worst-case: try npm start or node if present
    if command -v npm >/dev/null 2>&1; then
      exec npm start --prefix /usr/src/app 2>&1
    fi
    if command -v node >/dev/null 2>&1 && [ -f /usr/src/app/server.js ]; then
      exec node /usr/src/app/server.js
    fi

    echo "Could not detect upstream entrypoint; container will idle."
    exec tail -f /dev/null
