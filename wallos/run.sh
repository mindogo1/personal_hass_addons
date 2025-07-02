#!/usr/bin/env bash
set -e
# Prepare persistence
mkdir -p /config/db /config/images/uploads/logos
# Migrate existing data
if [ -d /var/www/html/db ] && [ "$(ls -A /var/www/html/db)" ]; then
  mv /var/www/html/db/* /config/db/
fi
if [ -d /var/www/html/images/uploads/logos ] && [ "$(ls -A /var/www/html/images/uploads/logos)" ]; then
  mv /var/www/html/images/uploads/logos/* /config/images/uploads/logos/
fi
# Symlink persistence
rm -rf /var/www/html/db
ln -s /config/db /var/www/html/db
rm -rf /var/www/html/images/uploads/logos
ln -s /config/images/uploads/logos /var/www/html/images/uploads/logos
exit 0
