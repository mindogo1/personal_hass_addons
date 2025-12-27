#!/bin/sh
set -e

OPT="/data/options.json"

get_opt() {
  key="$1"
  [ -f "$OPT" ] || { echo ""; return; }
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$OPT" | head -n1
}

# ---- read HA options
TZ_VAL="$(get_opt TZ)"
PIN_VAL="$(get_opt PIN)"
PORT_VAL="$(get_opt PORT)"
[ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
[ -z "$PORT_VAL" ] && PORT_VAL=3000
export HOST=0.0.0.0
export PORT="$PORT_VAL"

# Ensure uploads directory exists and is writable
UPLOADS_DIR="/data/tracktor/uploads"
APP_UPLOADS_DIR="/opt/tracktor/uploads"

mkdir -p "$UPLOADS_DIR"
chmod 775 "$UPLOADS_DIR"
chown -R root:root "$UPLOADS_DIR" || true

# Symlink into app if not already present
if [ ! -e "$APP_UPLOADS_DIR" ]; then
  ln -s "$UPLOADS_DIR" "$APP_UPLOADS_DIR"
fi

# ---- persistence: single SQLite file under /data/tracktor
DATA_DIR="/data/tracktor"
DB_FILE="${DATA_DIR}/tracktor.sqlite"
mkdir -p "$DATA_DIR"

if [ ! -f "$DB_FILE" ]; then
  echo "[tracktor-addon] Creating SQLite DB at $DB_FILE"
  command -v sqlite3 >/dev/null 2>&1 && sqlite3 "$DB_FILE" 'VACUUM;' || true
fi

# Tracktor often uses a relative ./tracktor.db. Point any such path at our persistent file.
ROOT_DIR="/opt/tracktor"
BACKEND_DIR="/opt/tracktor/build/backend"

ln -sf "$DB_FILE" "$ROOT_DIR/tracktor.db"
mkdir -p "$BACKEND_DIR" 2>/dev/null || true
ln -sf "$DB_FILE" "$BACKEND_DIR/tracktor.db" 2>/dev/null || true

# Ensure all tooling points to the same file
export DATABASE_URL="file:${DB_FILE}"
echo "[tracktor-addon] Using database: $DB_FILE"
echo "[tracktor-addon] Exposing server on :${PORT}"

# ---- seed PIN (if provided) using bcrypt; install libs on-the-fly if missing
seed_pin() {
  if [ -z "$PIN_VAL" ]; then
    return 0
  fi

  echo "[tracktor-addon] Seeding PIN…"
if ! node -e "require('bcryptjs'); require('@libsql/client');" 2>/dev/null; then
  echo "[tracktor-addon] WARNING: bcryptjs or @libsql/client missing. PIN seeding skipped."
  return 0
fi

  node <<'NODE' || true
    const bcrypt = require('bcryptjs');
    const libsql = require('@libsql/client');

    const pin = process.env.TRACKTOR_PIN || '';
    const url = process.env.DATABASE_URL || '';
    if (!pin || !url) process.exit(0);

    (async () => {
      const db = libsql.createClient({ url });
      await db.execute(`
        CREATE TABLE IF NOT EXISTS auth (
          id INTEGER PRIMARY KEY,
          hash TEXT NOT NULL,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
      `);
      const hash = bcrypt.hashSync(pin, 10);
      await db.execute(`
        INSERT INTO auth (id, hash) VALUES (1, ?)
        ON CONFLICT(id) DO UPDATE SET hash=excluded.hash, updated_at=CURRENT_TIMESTAMP;
      `, [hash]);
      console.log("[tracktor-addon] PIN seeded/updated.");
    })().catch(e => {
      console.error("[tracktor-addon] PIN seed failed:", e?.message || e);
      process.exit(0); // never block app start
    });
NODE
}
export TRACKTOR_PIN="$PIN_VAL"
seed_pin

# ---- start the app (auto-detect)
cd /opt/tracktor

# Prefer npm start at repo root if defined
if command -v pnpm >/dev/null 2>&1 && grep -q '"start"' package.json 2>/dev/null; then
  echo "[tracktor-addon] Starting via pnpm start…"
  exec pnpm start
fi

# Else if build script exists, use it
if [ -x ./build/start.sh ]; then
  echo "[tracktor-addon] Starting via ./build/start.sh…"
  exec ./build/start.sh
fi

# Else try a preview/dev server commonly used by Vite/SvelteKit
if grep -q '"preview"' package.json 2>/dev/null; then
  echo "[tracktor-addon] Starting via npm run preview…"
  exec npm run preview -- --host 0.0.0.0 --port "$PORT"
fi

# Else try common Node entrypoints
for CAND in ./app/backend/dist/index.js ./backend/dist/index.js ./dist/server/index.js ./server.js; do
  if [ -f "$CAND" ]; then
    echo "[tracktor-addon] Starting Node server: $CAND"
    exec node "$CAND"
  fi
done

echo "[tracktor-addon] No obvious start target; idling for debug."
exec tail -f /dev/null
