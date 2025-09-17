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

    # Detect web user (php-fpm / nginx image variants)
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

    # Ensure db dir (mounted inside chroot)
    mkdir -p /var/www/html/db
    chown -R "$WEB_UID:$WEB_GID" /var/www/html/db || true
    chmod -R 0775 /var/www/html/db || true

    # Ensure logos persisted under db
    mkdir -p /var/www/html/db/logos
    chown -R "$WEB_UID:$WEB_GID" /var/www/html/db/logos || true
    chmod -R 0775 /var/www/html/db/logos || true

    # Point uploads/logos to db/logos (inside chroot)
    mkdir -p /var/www/html/images/uploads
    if [ ! -e /var/www/html/images/uploads/logos ]; then
      ln -s ../../db/logos /var/www/html/images/uploads/logos
    fi

    DB="/var/www/html/db/wallos.db"
    TEMPLATE="/opt/wallos/wallos.empty.db"

    # If DB is missing or suspiciously small (likely empty), seed from template
    if [ ! -f "$DB" ] || [ ! -s "$DB" ] || [ "$(stat -c%s "$DB" 2>/dev/null || echo 0)" -lt 4096 ]; then
      echo "Seeding database from template..."
      if [ -f "$DB" ]; then
        mv -f "$DB" "${DB}.bak.$(date +%s)" || true
      fi
      if [ -f "$TEMPLATE" ]; then
        cp -a "$TEMPLATE" "$DB"
      else
        # As a last resort, create a valid empty SQLite file via PHP
        php -r 'new SQLite3(getenv("DB"));' || true
      fi
      chown "$WEB_UID:$WEB_GID" "$DB" || true
      chmod 0664 "$DB" || true
    fi

    # Run official migrations once (idempotent)
    if command -v php >/dev/null 2>&1; then
      echo "Running Wallos DB migrations..."
      php /var/www/html/endpoints/db/migrate.php || true
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
