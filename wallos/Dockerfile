# ALEXBELGIUM'S DOCKERFILE TEMPLATE adapted for Wallos
ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.0.1
ARG BUILD_VERSION=latest
FROM ${BUILD_FROM}

ENV BASHIO_VERSION=1.29.1     S6_CMD_WAIT_FOR_SERVICES=1     S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0     S6_SERVICES_GRACETIME=0

# Global LSIO modifications
ADD "https://raw.githubusercontent.com/alexbelgium/hassio-addons/master/.templates/ha_lsio.sh" "/ha_lsio.sh"
ARG CONFIGLOCATION="/config/addons_config/wallos"
RUN chmod 744 /ha_lsio.sh && if grep -qr "lsio" /etc; then /ha_lsio.sh "$CONFIGLOCATION"; fi && rm /ha_lsio.sh

# Copy persistence hook
COPY rootfs/ /

# Ensure permissions
RUN chmod +x /etc/cont-init.d/00_migrate.sh

# Labels
LABEL io.hass.name="Wallos" \
      io.hass.description="Self-hosted personal subscription tracker" \
      io.hass.arch="${BUILD_FROM#*:}" \
      io.hass.type="addon" \
      io.hass.version="${BUILD_VERSION}"
