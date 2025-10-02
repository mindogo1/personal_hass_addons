#!/bin/sh
set -e

OPT=/data/options.json

# Read a string option from HA options.json
get_json() {
  key="$1"
  [ -f "$OPT" ] || { echo ""; return; }
  # minimal parser: grabs the first matching key's value
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$OPT" | head -n1
}

# Options → ENV
TZ_VAL="$(get_json TZ)"; [ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
APP_URL_VAL="$(get_json APP_URL)"; [ -n "$APP_URL_VAL" ] && export APP_URL="$APP_URL_VAL"
ADMIN_EMAIL_VAL="$(get_json ADMIN_EMAIL)"; [ -n "$ADMIN_EMAIL_VAL" ] && export ADMIN_EMAIL="$ADMIN_EMAIL_VAL"
ADMIN_PASSWORD_VAL="$(get_json ADMIN_PASSWORD)"; [ -n "$ADMIN_PASSWORD_VAL" ] && export ADMIN_PASSWORD="$ADMIN_PASSWORD_VAL"

# Persistent paths
DB_DIR="/data/tracktor"
DB_FILE="$DB_DIR/tracktor.sqlite"
UPLOADS_DIR="$DB_DIR/uploads"

mkdir -p "$DB_DIR" "$UPLOADS_DIR"
chmod 0775 "$DB_DIR" "$UPLOADS_DIR" || true

# Common envs used by sqlite drivers
export SQLITE_DB_PATH="${DB_FILE}"
export DATABASE_URL="file:${DB_FILE}"

# Try to detect which toolchain this commit uses and migrate accordingly
cd /opt/tracktor

has_bin () { command -v "$1" >/dev/null 2>&1; }
has_node_mod () { [ -x "./node_modules/.bin/$1" ]; }

echo "[tracktor-addon] Database: ${DB_FILE}"
if [ ! -s "$DB_FILE" ]; then
  echo "[tracktor-addon] Creating empty SQLite DB…"
  node -e "require('fs').closeSync(require('fs').openSync(process.env.SQLITE_DB_PATH, 'a'))" || true
fi

# Prefer Sequelize if present (repo README mentions Sequelize)
if has_node_mod sequelize || has_node_mod sequelize-cli; then
  echo "[tracktor-addon] Running Sequelize migrations if available…"
  npx --yes sequelize-cli db:migrate || true
fi

# If Drizzle is present (older commits you tested referenced Drizzle)
if has_node_mod drizzle-kit; then
  echo "[tracktor-addon] Running Drizzle push if config present…"
  # Try typical config filenames
  for CFG in drizzle.config.ts drizzle.config.mts drizzle.config.js drizzle.config.cjs app/backend/drizzle.config.*; do
    if [ -f "$CFG" ]; then
      DRIZZLE_CONFIG="$CFG" npx --yes drizzle-kit push || npx --yes drizzle-kit push:sqlite || true
      break
    fi
  done
fi

# As a last resort, create a minimal table to break “no such table” loops (used to block you earlier)
if [ ! -f "$DB_FILE" ] || ! (sqlite3 "$DB_FILE" '.tables' >/dev/null 2>&1); then
  echo "[tracktor-addon] sqlite3 not available; skipping fallback schema."
else
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
fi

# Seed an admin if upstream uses email/password seeding via envs
if [ -n "$ADMIN_EMAIL" ] && [ -n "$ADMIN_PASSWORD" ] && command -v node >/dev/null 2>&1; then
  node <<'JS' || true
    import * as fs from 'fs';
    const db = process.env.SQLITE_DB_PATH;
    if (!db || !fs.existsSync(db)) process.exit(0);
    // bcrypt may not be in runtime deps; try a lightweight sha as a placeholder
    const crypto = await import('crypto');
    const hash = crypto.createHash('sha256').update(process.env.ADMIN_PASSWORD).digest('hex');
    const sqlite3 = await import('sqlite3');
    const { open } = await import('sqlite');
    const dbh = await open({ filename: db, driver: sqlite3.Database });
    // Create a generic users table if upstream doesn't have one yet
    await dbh.exec(`CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE,
      password TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );`);
    await dbh.run(`INSERT OR IGNORE INTO users(email,password) VALUES(?,?)`, [process.env.ADMIN_EMAIL, hash]);
    await dbh.close();
    console.log("[tracktor-addon] Admin seed attempted for", process.env.ADMIN_EMAIL);
JS
fi

# Start the app:
# Detect common start scripts; prefer npm start if defined, else try vite/sveltekit preview, else node server
echo "[tracktor-addon] Starting Tracktor…"
if grep -q '"start"' package.json 2>/dev/null; then
  exec npm start
fi

if grep -q '"preview"' package.json 2>/dev/null; then
  exec npm run preview -- --host 0.0.0.0 --port 5173
fi

# Try common entrypoints
for CAND in ./app/backend/dist/index.js ./dist/server/index.js ./server.js; do
  if [ -f "$CAND" ]; then
    exec node "$CAND"
  fi
done

echo "[tracktor-addon] No obvious start target; idling for debug."
exec tail -f /dev/null
