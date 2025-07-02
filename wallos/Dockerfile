ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.0.1
FROM ${BUILD_FROM}

# Pull upstream Wallos
FROM ghcr.io/ellite/wallos:latest AS wallos_upstream

# Start from HA base again
FROM ${BUILD_FROM}

# Copy only application files, not the entire rootfs, to preserve /init and services
COPY --from=wallos_upstream /var/www/html /var/www/html
COPY --from=wallos_upstream /etc/nginx /etc/nginx
COPY --from=wallos_upstream /etc/cron.d /etc/cron.d
COPY --from=wallos_upstream /usr/local/etc/php-fpm.d /usr/local/etc/php-fpm.d
COPY --from=wallos_upstream /usr/local/bin /usr/local/bin

# Ensure startup script is executable
RUN chmod +x /var/www/html/startup.sh

# Add persistence hook
COPY rootfs/etc/cont-init.d/00_migrate.sh /etc/cont-init.d/00_migrate.sh
RUN chmod +x /etc/cont-init.d/00_migrate.sh
