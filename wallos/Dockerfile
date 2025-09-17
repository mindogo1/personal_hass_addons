ARG BUILD_FROM=docker.io/bellamy/wallos:latest
FROM $BUILD_FROM

LABEL       io.hass.type="addon"       org.opencontainers.image.title="Wallos HA add-on wrapper"       org.opencontainers.image.description="Home Assistant add-on wrapping bellamy/wallos. Symlinks data dirs to /config."

COPY run.sh /run.sh
# Normalize Windows CRLF if present and make executable
RUN sed -i 's/\r$//' /run.sh && chmod +x /run.sh

CMD ["/run.sh"]
