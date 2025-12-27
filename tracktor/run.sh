#!/command/with-contenv sh
set -e

echo "[tracktor-addon] Starting Tracktor…"

# Ensure data dir exists
mkdir -p /data/tracktor

# Safety check (prevents silent crash loops)
if [ ! -d "/opt/tracktor/build" ]; then
  echo "[tracktor-addon] ERROR: build directory missing"
  exit 1
fi

exec node /opt/tracktor/build
