ARG BUILD_FROM=docker.io/bellamy/wallos:latest
FROM $BUILD_FROM

LABEL       io.hass.type="addon"       org.opencontainers.image.title="Wallos HA add-on wrapper"       org.opencontainers.image.description="Home Assistant add-on wrapping bellamy/wallos. Persists DB within chroot."

COPY run.sh /run.sh
RUN set -eux;         (sed -i '1s/^\xEF\xBB\xBF//' /run.sh || true);         (sed -i 's/\r$//' /run.sh || true);         chmod 0755 /run.sh

ENTRYPOINT ["/bin/sh", "/run.sh"]
