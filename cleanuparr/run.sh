#!/usr/bin/env bash

echo "Creating Cleanuparr config.yaml..."
cat <<EOF > /config/config.yaml
radarr:
  url: "${RADARR_URL}"
  api_key: "${RADARR_API_KEY}"

sonarr:
  url: "${SONARR_URL}"
  api_key: "${SONARR_API_KEY}"
EOF

echo "Generated /config/config.yaml:"
cat /config/config.yaml

# Start main container entrypoint
/cleanuparr
