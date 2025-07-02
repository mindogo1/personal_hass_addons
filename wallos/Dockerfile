ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.0.1
FROM ${BUILD_FROM}

# Pull upstream Wallos
FROM ghcr.io/ellite/wallos:latest AS wallos_upstream

FROM ${BUILD_FROM}
COPY --from=wallos_upstream / / 

# Migrate script
COPY rootfs/etc/cont-init.d/00_migrate.sh /etc/cont-init.d/00_migrate.sh
RUN chmod +x /etc/cont-init.d/00_migrate.sh
