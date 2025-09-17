\
    #!/usr/bin/env sh
    set -e

    # Export options to env
    if [ -f /data/options.json ]; then
      EXPORTS=$(python3 - <<'PY'
import json, shlex
o = json.load(open('/data/options.json','r'))
pairs = {
  'TZ': o.get('TZ'),
  'APP_URL': (o.get('APP_URL') or None),
}
print("\n".join([f"export {k}={shlex.quote(str(v))}" for k,v in pairs.items() if v]))
PY
)
      eval "$EXPORTS"
    fi

    # Persistent paths
    mkdir -p /config/db
    mkdir -p /config/logos
    mkdir -p /var/www/html/images/uploads || true

    # Link app paths to /config
    if [ ! -L /var/www/html/db ]; then
      rm -rf /var/www/html/db || true
      ln -sf /config/db /var/www/html/db
    fi
    if [ ! -L /var/www/html/images/uploads/logos ]; then
      rm -rf /var/www/html/images/uploads/logos || true
      ln -sf /config/logos /var/www/html/images/uploads/logos
    fi

    # If APP_URL provided, try to write to .env
    if [ -f /var/www/html/.env ] && [ -n "${APP_URL:-}" ]; then
      if grep -q '^APP_URL=' /var/www/html/.env; then
        sed -i "s|^APP_URL=.*$|APP_URL=${APP_URL}|g" /var/www/html/.env || true
      else
        echo "APP_URL=${APP_URL}" >> /var/www/html/.env || true
      fi
    fi

    # Launch upstream entrypoint
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
