#!/usr/bin/env bash
set -e

# If no config.yaml yet, create a blank one for the UI to edit
if [ ! -f /config/config.yaml ]; then
  cat <<EOF > /config/config.yaml
# Cleanuparr configuration
# Use the Web UI (Ingress) to set your Radarr & Sonarr URLs/API keys below
EOF
  echo "Initialized blank /config/config.yaml"
else
  echo "/config/config.yaml already exists, skipping init"
fi

# Exit so Supervisor will launch the container's built-in ENTRYPOINT,
# which starts the Cleanuparr web server on port 11011.
exit 0
