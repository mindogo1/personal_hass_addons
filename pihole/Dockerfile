FROM pihole/pihole:latest

# Wrapper to set up HA persistence and env, then chain to upstream init
COPY run.sh /run.sh
RUN set -eux; \
    (sed -i '1s/^\xEF\xBB\xBF//' /run.sh || true); \
    (sed -i 's/\r$//' /run.sh || true); \
    chmod 0755 /run.sh

ENTRYPOINT ["/bin/bash", "/run.sh"]
