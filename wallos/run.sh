#!/usr/bin/env bash
set -e

# Prepare persistent data dirs on first run
mkdir -p /config/db /config/logos

# Symlink into where Wallos expects them
rm -rf /var/www/html/db
ln -s /config/db /var/www/html/db

rm -rf /var/www/html/images/uploads/logos
ln -s /config/logos /var/www/html/images/uploads/logos

echo "Wallos data dirs mounted"

# Exit so Supervisor will launch the container’s ENTRYPOINT next
exit 0