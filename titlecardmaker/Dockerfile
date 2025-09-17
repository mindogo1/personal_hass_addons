ARG BUILD_FROM=docker.io/collinheist/titlecardmaker:latest
FROM $BUILD_FROM

LABEL       io.hass.version="0.3.0"       io.hass.type="addon"       io.hass.arch="amd64"       org.opencontainers.image.title="TitleCardMaker add-on wrapper"       org.opencontainers.image.source="https://github.com/mindogo1/personal_hass_addons"       org.opencontainers.image.description="Home Assistant add-on wrapper around collinheist/titlecardmaker (v1 CLI)"

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
