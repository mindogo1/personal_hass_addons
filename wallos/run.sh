#!/usr/bin/env bash
set -e

# Prepare persistent data dirs under /config
mkdir -p /config/db
mkdir -p /config/logos

# Symlink to the container’s expected locations
rm -rf /var/www/html/db
ln -s /config/db /var/www/html/db

rm -rf /var/www/html/images/uploads/logos
ln -s /config/logos /var/www/html/images/uploads/logos

echo "Wallos data dirs mounted. Handing off to upstream startup…"

# Exit so Supervisor runs the container’s built-in ENTRYPOINT (startup.sh)
exit 0
