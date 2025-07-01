#!/usr/bin/env bash
set -e

# Generate the Home Assistant–driven config file
cat <<EOF > /config/config.yaml
radarr:
  url: "${RADARR_URL}"
  api_key: "${RADARR_API_KEY}"
sonarr:
  url: "${SONARR_URL}"
  api_key: "${SONARR_API_KEY}"
EOF

echo "Config written to /config/config.yaml"

# Hand off to the real Cleanuparr binary on $PATH
exec Cleanuparr "$@"
