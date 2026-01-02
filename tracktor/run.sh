#!/usr/bin/with-contenv sh
set -e

# --- Persistence paths ---
DATA_DIR="/data/tracktor"
UPLOADS_DIR="${DATA_DIR}/uploads"
APP_UPLOADS_DIR="/opt/tracktor/uploads"

mkdir -p "${UPLOADS_DIR}"
chmod 775 "${UPLOADS_DIR}"

# Ensure app sees uploads at ./uploads
if [ -L "${APP_UPLOADS_DIR}" ]; then
  # correct already
  :
elif [ -d "${APP_UPLOADS_DIR}" ]; then
  # remove non-symlink dir created by image/build
  rm -rf "${APP_UPLOADS_DIR}"
  ln -s "${UPLOADS_DIR}" "${APP_UPLOADS_DIR}"
else
  ln -s "${UPLOADS_DIR}" "${APP_UPLOADS_DIR}"
fi

export DB_PATH="$DB_FILE"
export NODE_ENV="production"
export HOST=0.0.0.0
export PORT=3000

echo "[tracktor-addon] Database: $DB_PATH"
echo "[tracktor-addon] Uploads:  $UPLOADS_DIR"
echo "[tracktor-addon] Starting Tracktor"

cd /opt/tracktor
exec pnpm start
