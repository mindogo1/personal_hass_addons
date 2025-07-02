ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.0.1
FROM ${BUILD_FROM} AS base

# Pull Wallos upstream image
FROM ghcr.io/ellite/wallos:latest AS upstream

# Copy entire upstream filesystem
FROM base
COPY --from=upstream / /

# Add persistence hook
COPY rootfs/etc/cont-init.d/00_migrate.sh /etc/cont-init.d/00_migrate.sh
RUN chmod +x /etc/cont-init.d/00_migrate.sh
