#!/usr/bin/env bash
set -e

# Prepare persistent storage
mkdir -p /data/db
mkdir -p /data/images/uploads/logos

# Migrate DB data
if [ -d /var/www/html/db ] && [ "$(ls -A /var/www/html/db)" ]; then
    mv /var/www/html/db/* /data/db/
fi
rm -rf /var/www/html/db
ln -s /data/db /var/www/html/db

# Migrate logos
if [ -d /var/www/html/images/uploads/logos ] && [ "$(ls -A /var/www/html/images/uploads/logos)" ]; then
    mv /var/www/html/images/uploads/logos/* /data/images/uploads/logos/
fi
rm -rf /var/www/html/images/uploads/logos
ln -s /data/images/uploads/logos /var/www/html/images/uploads/logos

echo "✔️ Wallos data persisted"
