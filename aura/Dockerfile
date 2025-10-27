ARG BUILD_FROM=ghcr.io/mediux-team/aura:latest
FROM ${BUILD_FROM}

# Make sure the app binds externally (not just 127.0.0.1)
ENV HOST=0.0.0.0 PORT=3000 TZ=${TZ}
