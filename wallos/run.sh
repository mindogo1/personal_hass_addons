#!/usr/bin/env bash
set -e

mkdir -p /addon_config/db
mkdir -p /addon_config/logos

if [ -d /var/www/html/db ] && [ "$(ls -A /var/www/html/db)" ]; then
  echo "Migrating existing DB files into /addon_config/db"
  mv /var/www/html/db/* /addon_config/db/
fi

rm -rf /var/www/html/db
ln -s /addon_config/db /var/www/html/db

if [ -d /var/www/html/images/uploads/logos ] && [ "$(ls -A /var/www/html/images/uploads/logos)" ]; then
  echo "Migrating existing logo files into /addon_config/logos"
  mv /var/www/html/images/uploads/logos/* /addon_config/logos/
fi

rm -rf /var/www/html/images/uploads/logos
ln -s /addon_config/logos /var/www/html/images/uploads/logos

echo "Wallos data now lives under /addon_config (persisted across restarts)"

exit 0