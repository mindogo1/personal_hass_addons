#!/usr/bin/env bash
set -e

# 1) Generate the Home Assistant–driven config file
cat <<EOF > /config/config.yaml
radarr:
  url: "${RADARR_URL}"
  api_key: "${RADARR_API_KEY}"
sonarr:
  url: "${SONARR_URL}"
  api_key: "${SONARR_API_KEY}"
EOF

echo "Config written to /config/config.yaml"

# 2) Exit so HA’s Supervisor can launch the container normally
#    (it will invoke the image’s built-in ENTRYPOINT which starts Cleanuparr)
exit 0
