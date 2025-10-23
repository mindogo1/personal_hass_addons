# Home Assistant add-on wrapper for BeaverHabits
# We base ON the upstream image and use a tiny wrapper to map HA options → env,
# ensure persistence at /app/.user, and then chain to upstream start.
ARG BUILD_FROM=docker.io/daya0576/beaverhabits:latest
FROM ${BUILD_FROM}

LABEL io.hass.type="addon" \
      org.opencontainers.image.title="BeaverHabits HA add-on" \
      org.opencontainers.image.description="Home Assistant add-on wrapping daya0576/beaverhabits with HA persistence and options."

COPY run.sh /run.sh
RUN set -eux; \
    sed -i '1s/^\xEF\xBB\xBF//' /run.sh || true; \
    sed -i 's/\r$//' /run.sh || true; \
    chmod 0755 /run.sh

# Ensure the data dir exists (the add-on maps your config dir here)
RUN mkdir -p /app/.user

# Use our wrapper so we can export HA options as environment variables
ENTRYPOINT ["/bin/sh", "/run.sh"]