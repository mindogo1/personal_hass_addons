#!/usr/bin/with-contenv bash
set -e

mkdir -p /data/db
mkdir -p /data/images/uploads/logos

if [ -d /var/www/html/db ] && [ ! -L /var/www/html/db ]; then
  mv /var/www/html/db/* /data/db/ || true
  rm -rf /var/www/html/db
fi
ln -sf /data/db /var/www/html/db

if [ -d /var/www/html/images/uploads/logos ] && [ ! -L /var/www/html/images/uploads/logos ]; then
  mv /var/www/html/images/uploads/logos/* /data/images/uploads/logos/ || true
  rm -rf /var/www/html/images/uploads/logos
fi
ln -sf /data/images/uploads/logos /var/www/html/images/uploads/logos

exit 0
