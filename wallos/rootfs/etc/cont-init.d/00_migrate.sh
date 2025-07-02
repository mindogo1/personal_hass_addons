#!/usr/bin/with-contenv bash
set -e

# Prepare persistence directories
mkdir -p /data/db
mkdir -p /data/images/uploads/logos

# Migrate DB if first run
if [ -d /var/www/html/db ] && [ ! -L /var/www/html/db ]; then
  mv /var/www/html/db/* /data/db/ 2>/dev/null || true
  rm -rf /var/www/html/db
fi
ln -sf /data/db /var/www/html/db

# Migrate logos if first run
if [ -d /var/www/html/images/uploads/logos ] && [ ! -L /var/www/html/images/uploads/logos ]; then
  mv /var/www/html/images/uploads/logos/* /data/images/uploads/logos/ 2>/dev/null || true
  rm -rf /var/www/html/images/uploads/logos
fi
ln -sf /data/images/uploads/logos /var/www/html/images/uploads/logos

echo "✔️ Wallos data migrated"
