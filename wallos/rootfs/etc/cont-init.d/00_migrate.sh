#!/usr/bin/with-contenv bash
set -e

# Ensure persistence dirs exist
mkdir -p /data/db
mkdir -p /data/images/uploads/logos

# Migrate DB only if original directory exists and is not a symlink
if [ -d /var/www/html/db ] && [ ! -L /var/www/html/db ]; then
  if [ "$(ls -A /var/www/html/db)" ]; then
    mv /var/www/html/db/* /data/db/
  fi
  rm -rf /var/www/html/db
fi
ln -sf /data/db /var/www/html/db

# Migrate logos only if original directory exists and is not a symlink
if [ -d /var/www/html/images/uploads/logos ] && [ ! -L /var/www/html/images/uploads/logos ]; then
  if [ "$(ls -A /var/www/html/images/uploads/logos)" ]; then
    mv /var/www/html/images/uploads/logos/* /data/images/uploads/logos/
  fi
  rm -rf /var/www/html/images/uploads/logos
fi
ln -sf /data/images/uploads/logos /var/www/html/images/uploads/logos

echo "✔️ Wallos data migrated to /data"
