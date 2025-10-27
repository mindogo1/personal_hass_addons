# We wrap the upstream image but do not override its entrypoint.
# Supervisor pulls our image from a local build, and the UI version is shown
# from config.yaml (kept in sync by the workflow).
ARG BUILD_FROM=ghcr.io/mediux-team/aura:latest
FROM ${BUILD_FROM}

# Pass through timezone if set (no harm if unused)
ENV TZ=${TZ}

# Create a friendly hint at startup showing where config lives
# (non-breaking; upstream startup remains intact)
RUN printf '\nAURA add-on: config is persisted at /config\n\n' >/etc/motd
