#!/usr/bin/env bash
set -e

# Generate config file
cat <<EOF > /config/config.yaml
radarr:
  url: "${RADARR_URL}"
  api_key: "${RADARR_API_KEY}"
sonarr:
  url: "${SONARR_URL}"
  api_key: "${SONARR_API_KEY}"
EOF

echo "Config written to /config/config.yaml"

# Execute Cleanuparr binary
# Adjust the path below if needed, e.g., /usr/local/bin/Cleanuparr
exec /cleanuparr "$@"
