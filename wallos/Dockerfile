ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.0.1
FROM ${BUILD_FROM} as runtime

# Pull upstream Wallos image
FROM ghcr.io/ellite/wallos:latest as wallos_upstream

# Copy Wallos files into the HA base image
FROM runtime
COPY --from=wallos_upstream /var/www/html /var/www/html
COPY --from=wallos_upstream /etc/nginx /etc/nginx
COPY --from=wallos_upstream /etc/cron.d /etc/cron.d
COPY --from=wallos_upstream /usr/local/etc/php-fpm.d /usr/local/etc/php-fpm.d
COPY --from=wallos_upstream /usr/local/bin /usr/local/bin

# Copy cont-init script
COPY rootfs/etc/cont-init.d/00_migrate.sh /etc/cont-init.d/00_migrate.sh
RUN chmod +x /etc/cont-init.d/00_migrate.sh
