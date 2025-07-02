# HA Community Add-on for Wallos (Overseerr pattern)
ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.0.1
ARG BUILD_VERSION=latest
FROM ${BUILD_FROM}

ENV BASHIO_VERSION=1.29.1     S6_CMD_WAIT_FOR_SERVICES=1     S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0     S6_SERVICES_GRACETIME=0

# Install LSIO helper
ADD "https://raw.githubusercontent.com/alexbelgium/hassio-addons/master/.templates/ha_lsio.sh" "/ha_lsio.sh"
ARG CONFIGLOCATION="/config/addons_config/wallos"
RUN chmod 744 /ha_lsio.sh && /ha_lsio.sh "$CONFIGLOCATION" && rm /ha_lsio.sh

# Pull Wallos image
ENV WALLS0S_IMAGE="ghcr.io/ellite/wallos:latest"
RUN bashio::info "Pulling Wallos image $WALLS0S_IMAGE" &&     docker pull "$WALLS0S_IMAGE"

# Copy entrypoint and files
COPY rootfs/ /

# Ensure permissions
RUN chmod +x /etc/cont-init.d/00_migrate.sh

# Start Wallos
CMD ["bashio-service", "/init"]
