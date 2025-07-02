ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.0.1
FROM ${BUILD_FROM} AS base

# Pull upstream wallos into an intermediate image
FROM ghcr.io/ellite/wallos:latest AS wallos_upstream

# Copy app directory and relevant config files from upstream
COPY --from=wallos_upstream /var/www/html /var/www/html
COPY --from=wallos_upstream /etc/nginx /etc/nginx
COPY --from=wallos_upstream /etc/cron.d /etc/cron.d
COPY --from=wallos_upstream /usr/local/etc/php-fpm.d /usr/local/etc/php-fpm.d

# Set permissions and cron
RUN dos2unix /etc/cron.d/cronjobs && \
    chmod 0644 /etc/cron.d/cronjobs && \
    /usr/bin/crontab /etc/cron.d/cronjobs && \
    mkdir -p /var/log/cron && \
    chown -R www-data:www-data /var/www/html && \
    chmod +x /var/www/html/startup.sh

# Final image
FROM base
COPY --from=wallos_upstream /var/www/html /var/www/html
COPY --from=wallos_upstream /etc/nginx /etc/nginx
COPY --from=wallos_upstream /etc/cron.d /etc/cron.d
COPY --from=wallos_upstream /usr/local/etc/php-fpm.d /usr/local/etc/php-fpm.d
