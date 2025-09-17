\
    #!/bin/sh
    set -e

    # --- Read minimal options from /data/options.json without python/jq ---
    optfile="/data/options.json"
    get_json_string() {
      # naive string extractor for simple JSON keys (double-quoted values only)
      key="$1"
      if [ -f "$optfile" ]; then
        sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$optfile" | head -n1
      fi
    }

    TZ_VAL="$(get_json_string TZ)"
    APP_URL_VAL="$(get_json_string APP_URL)"

    [ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
    [ -n "$APP_URL_VAL" ] && export APP_URL="$APP_URL_VAL"

    # --- Persistent paths ---
    mkdir -p /config/db
    mkdir -p /config/logos
    mkdir -p /var/www/html/images/uploads || true

    # Link app paths to /config
    if [ ! -L /var/www/html/db ]; then
      rm -rf /var/www/html/db 2>/dev/null || true
      ln -s /config/db /var/www/html/db
    fi
    if [ ! -L /var/www/html/images/uploads/logos ]; then
      rm -rf /var/www/html/images/uploads/logos 2>/dev/null || true
      ln -s /config/logos /var/www/html/images/uploads/logos
    fi

    # Apply APP_URL to .env if available
    if [ -n "$APP_URL_VAL" ] && [ -f /var/www/html/.env ]; then
      if grep -q '^APP_URL=' /var/www/html/.env; then
        sed -i "s|^APP_URL=.*$|APP_URL=${APP_URL_VAL}|g" /var/www/html/.env || true
      else
        echo "APP_URL=${APP_URL_VAL}" >> /var/www/html/.env || true
      fi
    fi

    # --- Launch upstream ---
    if command -v docker-php-entrypoint >/dev/null 2>&1; then
      exec docker-php-entrypoint apache2-foreground
    elif command -v apache2-foreground >/dev/null 2>&1; then
      exec apache2-foreground
    elif command -v php-fpm >/dev/null 2>&1; then
      exec php-fpm -F
    elif command -v nginx >/dev/null 2>&1; then
      exec nginx -g "daemon off;"
    else
      echo "Could not detect upstream entrypoint; container will idle."
      exec tail -f /dev/null
    fi
