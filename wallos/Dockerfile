ARG BUILD_FROM=ghcr.io/hassio-addons/base:18.0.1
FROM ${BUILD_FROM}

# Copy upstream Wallos image layers
COPY --from=ghcr.io/ellite/wallos:latest / /

LABEL io.hass.name="Wallos"
LABEL io.hass.description="Self-hosted personal subscription tracker (Wallos)"
LABEL io.hass.arch="amd64 aarch64"
LABEL io.hass.type="addon"
LABEL io.hass.version="latest"
