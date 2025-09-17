ARG BUILD_FROM=ghcr.io/javedh-dev/tracktor:latest
FROM $BUILD_FROM

LABEL       io.hass.type="addon"       org.opencontainers.image.title="Tracktor HA add-on wrapper"       org.opencontainers.image.description="Home Assistant add-on wrapping ghcr.io/javedh-dev/tracktor"

COPY run.sh /run.sh

# Normalize CRLF/BOM and ensure executable
RUN set -eux;         (sed -i '1s/^\xEF\xBB\xBF//' /run.sh || true);         (sed -i 's/\r$//' /run.sh || true);         chmod 0755 /run.sh

# Force our wrapper as entrypoint to export options and set perms before app starts
ENTRYPOINT ["/bin/sh", "/run.sh"]
