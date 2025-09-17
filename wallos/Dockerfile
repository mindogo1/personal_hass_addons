ARG BUILD_FROM=docker.io/bellamy/wallos:latest
FROM $BUILD_FROM

LABEL           io.hass.type="addon"           org.opencontainers.image.title="Wallos HA add-on wrapper"           org.opencontainers.image.description="Home Assistant add-on wrapping bellamy/wallos. Symlinks data dirs to /config."

# Copy runtime
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Default command
CMD ["/run.sh"]
