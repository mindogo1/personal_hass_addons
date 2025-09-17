\
    #!/bin/sh
    set -e

    optfile="/data/options.json"
    get_json_string() {
      key="$1"
      if [ -f "$optfile" ]; then
        sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$optfile" | head -n1
      fi
    }

    TZ_VAL="$(get_json_string TZ)"
    APP_URL_VAL="$(get_json_string APP_URL)"

    [ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
    [ -n "$APP_URL_VAL" ] && export APP_URL="$APP_URL_VAL"

    # Persistent paths
    mkdir -p /config/db
    mkdir -p /config/logos
    mkdir -p /var/www/html/images/uploads || true

    # Link to /config
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

    # Prefer upstream startup script
    if [ -x /startup.sh ]; then
      exec /startup.sh
    fi

    # Fallbacks
    if command -v nginx >/dev/null 2>&1 && command -v php-fpm >/dev/null 2>&1; then
      # Start php-fpm in background, then nginx in foreground
      php-fpm -D
      exec nginx -g "daemon off;"
    fi
    if command -v php-fpm >/dev/null 2>&1; then
      exec php-fpm -F
    fi
    if command -v php >/dev/null 2>&1; then
      echo "Starting built-in PHP server on :80 as fallback"
      exec php -S 0.0.0.0:80 -t /var/www/html
    fi

    echo "No known web server found. Container will idle."
    exec tail -f /dev/null
