# Follow Tracktor's Docker method: run the upstream image and start its app.
# We wrap the image only to wire HA persistence and PIN seeding.
ARG BUILD_FROM=ghcr.io/javedh-dev/tracktor:latest
FROM ${BUILD_FROM}

LABEL io.hass.type="addon" \
      org.opencontainers.image.title="Tracktor HA add-on wrapper" \
      org.opencontainers.image.description="Home Assistant add-on wrapping javedh-dev/tracktor with HA persistence and PIN seeding."

# Our wrapper that:
# - points the app to a persistent SQLite file under /data/tracktor
# - symlinks backend ./tracktor.db → that file (as the docs use a relative path)
# - seeds PIN if you set one in add-on options
COPY run.sh /run.sh
RUN set -eux; \
    (sed -i '1s/^\xEF\xBB\xBF//' /run.sh || true); \
    (sed -i 's/\r$//' /run.sh || true); \
    chmod 0755 /run.sh

# Upstream listens on 3000 per Docker install method.
EXPOSE 3000

ENTRYPOINT ["/bin/sh", "/run.sh"]
