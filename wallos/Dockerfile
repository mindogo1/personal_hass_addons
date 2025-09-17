ARG BUILD_FROM=docker.io/bellamy/wallos:latest
FROM $BUILD_FROM

LABEL       io.hass.type="addon"       org.opencontainers.image.title="Wallos HA add-on wrapper"       org.opencontainers.image.description="Home Assistant add-on wrapping ellite/Wallos with HA persistence."

# Stash the template DB from the base image where the bind mount won't shadow it
RUN set -eux;         mkdir -p /opt/wallos;         if [ -f /var/www/html/db/wallos.empty.db ]; then cp -a /var/www/html/db/wallos.empty.db /opt/wallos/wallos.empty.db; fi

COPY run.sh /run.sh
# Normalize and make executable
RUN set -eux;         (sed -i '1s/^\xEF\xBB\xBF//' /run.sh || true);         (sed -i 's/\r$//' /run.sh || true);         chmod 0755 /run.sh

# Force our wrapper as entrypoint (so we can seed/migrate reliably)
ENTRYPOINT ["/bin/sh", "/run.sh"]
