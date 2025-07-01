#!/usr/bin/env bash
set -e

# Ensure persistent dirs exist under /config
mkdir -p /config/db /config/logos

# Symlink to the container’s expected locations
rm -rf /var/www/html/db
ln -s /config/db /var/www/html/db

rm -rf /var/www/html/images/uploads/logos
ln -s /config/logos /var/www/html/images/uploads/logos

echo "Wallos data dirs mounted"

# Exit so Supervisor runs the upstream ENTRYPOINT
exit 0
