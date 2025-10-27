# Use upstream prebuilt image exactly as-is
ARG BUILD_FROM=ghcr.io/mediux-team/aura:latest
FROM ${BUILD_FROM}

# Small helper that creates the /data/media link (AURA docs bind /data/media,
# but HA can’t mount arbitrary host paths there). We link the HA /media mount.
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Keep upstream entrypoint, but run our tiny shim first
ENTRYPOINT ["/bin/sh", "/run.sh"]
