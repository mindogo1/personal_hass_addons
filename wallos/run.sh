#!/usr/bin/env bash
set -e

# Prepare persistent folders under addon_config
mkdir -p /addon_config/db
mkdir -p /addon_config/logos

# Migrate existing DB files
if [ -d /var/www/html/db ] && [ "$(ls -A /var/www/html/db)" ]; then
  mv /var/www/html/db/* /addon_config/db/
fi

# Migrate existing logos
if [ -d /var/www/html/images/uploads/logos ] && [ "$(ls -A /var/www/html/images/uploads/logos)" ]; then
  mv /var/www/html/images/uploads/logos/* /addon_config/logos/
fi

# Symlink persistent storage
rm -rf /var/www/html/db
ln -s /addon_config/db /var/www/html/db

rm -rf /var/www/html/images/uploads/logos
ln -s /addon_config/logos /var/www/html/images/uploads/logos

echo "Wallos data directories mounted"

exit 0
