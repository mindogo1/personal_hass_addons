#!/usr/bin/env bash
set -e

# Only on first run, prepare persistent storage
if [ ! -d /config/db ]; then
  mkdir -p /config/db /config/logos
  echo "Initialized /config/db and /config/logos"
fi

# Symlink into where Wallos expects them
rm -rf /var/www/html/db
ln -s /config/db /var/www/html/db

rm -rf /var/www/html/images/uploads/logos
ln -s /config/logos /var/www/html/images/uploads/logos

echo "Wallos data dirs mounted"

# Exit so Supervisor will invoke the image's own ENTRYPOINT (starting Wallos)
exit 0