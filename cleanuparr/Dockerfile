# syntax=docker/dockerfile:1.4

ARG BUILD_FROM
# Use the official Cleanuparr image as base
FROM ghcr.io/cleanuparr/cleanuparr:latest AS cleanuparr_base

FROM $BUILD_FROM

# Copy Cleanuparr application from its official base image
COPY --from=cleanuparr_base /app /app

WORKDIR /app

# Ensure jq is installed in the Home Assistant base image for run.sh
# For Alpine-based HA images:
RUN apk add --no-cache jq

# For Debian/Ubuntu-based HA images (if applicable, e.g., if using a custom base for BUILD_FROM):
# RUN apt-get update && apt-get install -y jq --no-install-recommends \
#  && rm -rf /var/lib/apt/lists/*

# Copy addon run script
COPY run.sh /usr/bin/run.sh
RUN chmod a+x /usr/bin/run.sh

# Set entrypoint to our run.sh script
CMD ["/usr/bin/run.sh"]