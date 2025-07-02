#!/usr/bin/env bash
set -e

# 1) Make sure our host‐mounted /config has the folders Wallos needs
mkdir -p /config/db
mkdir -p /config/images/uploads/logos

# 2) Remove the built‐in (ephemeral) directories and symlink in our persistent ones
rm -rf /var/www/html/db
ln -s /config/db /var/www/html/db

rm -rf /var/www/html/images/uploads/logos
ln -s /config/images/uploads/logos /var/www/html/images/uploads/logos

echo "Mounted /config/db and /config/images/uploads/logos"

# 3) Exit so Supervisor can run the container’s normal entrypoint
exit 0
