#!/usr/bin/env bash
set -e

# Only initialize once: create a blank config if none exists
if [ ! -s /config/config.yaml ]; then
  cat <<EOF > /config/config.yaml
# Cleanuparr configuration
# Use the Web UI (Ingress) to set your Radarr & Sonarr URLs/API keys below
EOF
  echo "Initialized blank /config/config.yaml"
else
  echo "/config/config.yaml already exists, skipping init"
fi

# Exit so Supervisor will launch the image's ENTRYPOINT next,
# which starts the Cleanuparr web UI on port 11011.
exit 0
