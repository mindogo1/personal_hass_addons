#!/usr/bin/with-contenv sh

echo "[tracktor-addon] Starting Tracktor…"

cd /opt/tracktor

exec node build/index.js
