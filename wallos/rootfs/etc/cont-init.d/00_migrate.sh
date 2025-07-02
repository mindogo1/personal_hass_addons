#!/usr/bin/with-contenv bash
# Migrate Wallos data into persistent config folder
set -e
mkdir -p /config/db
mkdir -p /config/images/uploads/logos

if [ -d /var/www/html/db ] && [ ! -L /var/www/html/db ]; then
  mv /var/www/html/db/* /config/db/ || true
  rm -rf /var/www/html/db
fi
ln -sf /config/db /var/www/html/db

if [ -d /var/www/html/images/uploads/logos ] && [ ! -L /var/www/html/images/uploads/logos ]; then
  mv /var/www/html/images/uploads/logos/* /config/images/uploads/logos/ || true
  rm -rf /var/www/html/images/uploads/logos
fi
ln -sf /config/images/uploads/logos /var/www/html/images/uploads/logos
