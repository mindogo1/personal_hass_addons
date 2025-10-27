#!/bin/sh
set -e

# Ensure AURA binds externally
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-3000}"

# If HA’s special /media mount exists, give AURA the path it expects
# (/data/media as in upstream docker-compose). Safe & idempotent.
if [ -d /media ] && [ ! -e /data/media ]; then
  mkdir -p /data
  ln -s /media /data/media
fi

# Hand off to upstream entrypoint/CMD
# Most images are /init (s6) or /entrypoint.sh or just a CMD.
if [ -x /init ]; then
  exec /init
elif [ -x /entrypoint.sh ]; then
  exec /entrypoint.sh
else
  # Fall back to whatever the image’s default CMD is
  exec sh -lc 'exec "$@"' _ "$(cat /proc/1/cmdline 2>/dev/null | tr "\000" " ")"
fi
