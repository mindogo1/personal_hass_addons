#!/usr/bin/env bash
# s6 cont-init.d script for data persistence
set -e

# Migrate DB
mkdir -p /data/db
if [ -d /var/www/html/db ] && [ "$(ls -A /var/www/html/db)" ]; then
  mv /var/www/html/db/* /data/db/
fi
rm -rf /var/www/html/db
ln -s /data/db /var/www/html/db

# Migrate logos
mkdir -p /data/images/uploads/logos
if [ -d /var/www/html/images/uploads/logos ] && [ "$(ls -A /var/www/html/images/uploads/logos)" ]; then
  mv /var/www/html/images/uploads/logos/* /data/images/uploads/logos/
fi
rm -rf /var/www/html/images/uploads/logos
ln -s /data/images/uploads/logos /var/www/html/images/uploads/logos

echo "✔️ Migrated Wallos data to /data"
