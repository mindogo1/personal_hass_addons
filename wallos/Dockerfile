ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.0.1
FROM ${BUILD_FROM}

# Copy the upstream Wallos image contents
COPY --from=ghcr.io/ellite/wallos:latest / /

LABEL io.hass.name="Wallos" \
      io.hass.description="Self-hosted subscription tracker" \
      io.hass.arch="amd64 aarch64" \
      io.hass.type="addon" \
      io.hass.version="latest"
