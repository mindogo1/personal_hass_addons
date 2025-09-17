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

    # Detect web user
    detect_user() {
      for u in www-data nginx apache; do
        if id "$u" >/dev/null 2>&1; then
          echo "$u"; return
        fi
      done
      echo "root"
    }
    WEB_USER="$(detect_user)"
    WEB_UID="$(id -u "$WEB_USER" 2>/dev/null || echo 0)"
    WEB_GID="$(id -g "$WEB_USER" 2>/dev/null || echo 0)"
    umask 0002

    # Ensure db dir (this is the add-on persistent mount point)
    mkdir -p /var/www/html/db
    chown -R "$WEB_UID:$WEB_GID" /var/www/html/db || true
    chmod -R 0775 /var/www/html/db || true

    # Ensure logos under db for persistence
    mkdir -p /var/www/html/db/logos
    chown -R "$WEB_UID:$WEB_GID" /var/www/html/db/logos || true
    chmod -R 0775 /var/www/html/db/logos || true

    # Point uploads/logos to db/logos (within chroot)
    mkdir -p /var/www/html/images/uploads
    if [ ! -e /var/www/html/images/uploads/logos ]; then
      ln -s ../../db/logos /var/www/html/images/uploads/logos
    fi

    # Precreate SQLite DB file if missing
    if [ ! -f /var/www/html/db/wallos.db ]; then
      echo "Precreating SQLite DB at /var/www/html/db/wallos.db"
      install -o "$WEB_UID" -g "$WEB_GID" -m 0664 /dev/null /var/www/html/db/wallos.db || true
    fi

    # Apply APP_URL if available
    if [ -n "$APP_URL_VAL" ] && [ -f /var/www/html/.env ]; then
      if grep -q '^APP_URL=' /var/www/html/.env; then
        sed -i "s|^APP_URL=.*$|APP_URL=${APP_URL_VAL}|g" /var/www/html/.env || true
      else
        echo "APP_URL=${APP_URL_VAL}" >> /var/www/html/.env || true
      fi
    fi

    # Start Wallos
    if [ -x /startup.sh ]; then
      exec /startup.sh
    fi
    if command -v nginx >/dev/null 2>&1 && command -v php-fpm >/dev/null 2>&1; then
      php-fpm -D
      exec nginx -g "daemon off;"
    fi
    if command -v php-fpm >/dev/null 2>&1; then
      exec php-fpm -F
    fi
    if command -v php >/dev/null 2>&1; then
      echo "Starting PHP built-in server on :80"
      exec php -S 0.0.0.0:80 -t /var/www/html
    fi
    echo "No server found. Idling..."
    exec tail -f /dev/null
