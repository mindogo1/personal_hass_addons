#!/bin/sh
set -e

OPT=/data/options.json

# --- helpers -----------------------------------------------------------
get_json() {
  key="$1"
  [ -f "$OPT" ] || { echo ""; return; }
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$OPT" | head -n1
}
has_node_mod () { [ -x "./node_modules/.bin/$1" ]; }

# --- options → env -----------------------------------------------------
TZ_VAL="$(get_json TZ)";           [ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
APP_URL_VAL="$(get_json APP_URL)"; [ -n "$APP_URL_VAL" ] && export APP_URL="$APP_URL_VAL"
ADMIN_EMAIL_VAL="$(get_json ADMIN_EMAIL)"; [ -n "$ADMIN_EMAIL_VAL" ] && export ADMIN_EMAIL="$ADMIN_EMAIL_VAL"
ADMIN_PASSWORD_VAL="$(get_json ADMIN_PASSWORD)"; [ -n "$ADMIN_PASSWORD_VAL" ] && export ADMIN_PASSWORD="$ADMIN_PASSWORD_VAL"

# Force expected listen interface/port (HA maps container 3000 → host XXXX)
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-3000}"

# --- persistence -------------------------------------------------------
DB_DIR="/data/tracktor"
DB_FILE="$DB_DIR/tracktor.sqlite"
UPLOADS_DIR="$DB_DIR/uploads"

mkdir -p "$DB_DIR" "$UPLOADS_DIR"
chmod 0775 "$DB_DIR" "$UPLOADS_DIR" || true

# Many Tracktor builds default to ./tracktor.db under /opt/tracktor
APP_DB_PATH="/opt/tracktor/tracktor.db"
# Seed empty DB file if missing
if [ ! -s "$DB_FILE" ]; then
  echo "[tracktor-addon] Creating empty SQLite DB at $DB_FILE"
  sqlite3 "$DB_FILE" 'VACUUM;' 2>/dev/null || true
fi
# Move any existing local DB into /data, then symlink back for the app
if [ -f "$APP_DB_PATH" ] && [ ! -L "$APP_DB_PATH" ]; then
  mv -f "$APP_DB_PATH" "$DB_FILE" 2>/dev/null || true
fi
ln -sf "$DB_FILE" "$APP_DB_PATH"

# Some libs read DATABASE_URL or SQLITE DB path envs
export SQLITE_DB_PATH="$DB_FILE"
export DATABASE_URL="file:$DB_FILE"

echo "[tracktor-addon] Database: $DB_FILE"

# --- migrations --------------------------------------------------------
cd /opt/tracktor

# Prefer Sequelize migrations if present
if has_node_mod sequelize || has_node_mod sequelize-cli; then
  echo "[tracktor-addon] Running Sequelize migrations (if any)…"
  npx --yes sequelize-cli db:migrate || true
fi

# Try Drizzle migrations if drizzle-kit + config exists
if has_node_mod drizzle-kit; then
  echo "[tracktor-addon] Running Drizzle push (if config present)…"
  # Try common config names/paths
  for CFG in drizzle.config.ts drizzle.config.mts drizzle.config.js drizzle.config.cjs app/backend/drizzle.config.* build/backend/drizzle.config.*; do
    if [ -f "$CFG" ]; then
      echo "Using $CFG"
      DRIZZLE_CONFIG="$CFG" npx --yes drizzle-kit push || npx --yes drizzle-kit push:sqlite || true
      break
    fi
  done
fi

# Minimal fallback schema (prevents "no such table" crashes on first boot)
if command -v sqlite3 >/dev/null 2>&1; then
  TBL_COUNT="$(sqlite3 "$DB_FILE" '.tables' | wc -w | tr -d ' ')"
  if [ "$TBL_COUNT" = "0" ] || [ -z "$TBL_COUNT" ]; then
    echo "[tracktor-addon] Applying minimal fallback schema…"
    sqlite3 "$DB_FILE" <<'SQL' || true
CREATE TABLE IF NOT EXISTS configs (
  key TEXT PRIMARY KEY,
  value TEXT,
  description TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS auth (
  id INTEGER PRIMARY KEY,
  hash TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);
SQL
  fi
else
  echo "[tracktor-addon] sqlite3 not available; skipping fallback schema."
fi

# Optional admin seed (harmless if app ignores it)
if [ -n "$ADMIN_EMAIL" ] && [ -n "$ADMIN_PASSWORD" ]; then
  if command -v node >/dev/null 2>&1; then
    node <<'JS' || true
      import * as fs from 'fs';
      const dbf = process.env.SQLITE_DB_PATH;
      if (!dbf || !fs.existsSync(dbf)) process.exit(0);
      const crypto = await import('crypto');
      const sqlite3 = await import('sqlite3');
      const { open } = await import('sqlite');
      const hash = crypto.createHash('sha256').update(process.env.ADMIN_PASSWORD).digest('hex');
      const db = await open({ filename: dbf, driver: sqlite3.Database });
      await db.exec(`CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );`);
      await db.run(`INSERT OR IGNORE INTO users(email,password) VALUES(?,?)`, [process.env.ADMIN_EMAIL, hash]);
      await db.close();
      console.log("[tracktor-addon] Admin seed attempted for", process.env.ADMIN_EMAIL);
JS
  fi
fi

echo "[tracktor-addon] Expecting app on ${HOST}:${PORT}"

# --- start server ------------------------------------------------------
# Prefer npm start if defined (many commits call ./build/start.sh inside)
if grep -q '"start"' package.json 2>/dev/null; then
  exec npm start
fi

# Else, if a start script exists in build dir
if [ -x ./build/start.sh ]; then
  exec ./build/start.sh
fi

# Else try common Node entrypoints
for CAND in ./app/backend/dist/index.js ./dist/server/index.js ./server.js; do
  if [ -f "$CAND" ]; then
    exec node "$CAND"
  fi
done

echo "[tracktor-addon] No obvious start target; idling for debug."
exec tail -f /dev/null
