# syntax=docker/dockerfile:1.4

# Start directly from the official Cleanuparr image.
# This image includes the .NET runtime and the Cleanuparr application.
FROM ghcr.io/cleanuparr/cleanuparr:latest

# The official Cleanuparr image is based on dotnet/aspnet:8.0, which uses Debian/Ubuntu (apt-get).
# Install jq, which is needed by your run.sh script to parse options.json.
RUN apt-get update && apt-get install -y jq --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# Set the working directory to /app, where the Cleanuparr application resides in the base image.
WORKDIR /app

# Copy your custom run.sh script into the container.
COPY run.sh /usr/bin/run.sh
RUN chmod a+x /usr/bin/run.sh

# --- ADD THIS LINE ---
USER root
# --- END ADDITION ---

# Set the entrypoint to your run.sh script.
CMD ["/usr/bin/run.sh"]