#!/bin/sh
set -e

OPT="/data/options.json"

# --- tiny json reader for HA options (no jq in base images) ---
get_opt() {
  key="$1"
  [ -f "$OPT" ] || { echo ""; return; }
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$OPT" | head -n1
}

# --- read options ---
TZ_VAL="$(get_opt TZ)"
PIN_VAL="$(get_opt PIN)"
PORT_VAL="$(get_opt PORT)"

[ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
[ -n "$PORT_VAL" ] || PORT_VAL=3000
export HOST=0.0.0.0
export PORT="$PORT_VAL"

# --- persistence: single SQLite file under /data/tracktor ---
DATA_DIR="/data/tracktor"
DB_FILE="${DATA_DIR}/tracktor.sqlite"
mkdir -p "$DATA_DIR"

# Ensure DB exists (upstream will create if missing; harmless if already there)
if [ ! -f "$DB_FILE" ]; then
  echo "[tracktor-addon] Creating SQLite DB at $DB_FILE"
  # If sqlite is present, init a valid file; otherwise app will create it at first connect
  command -v sqlite3 >/dev/null 2>&1 && sqlite3 "$DB_FILE" 'VACUUM;' || true
fi

# Tracktor's backend (per Docker method) runs from build/backend and uses ./tracktor.db (relative).
# Symlink that path to our persistent file so app and seeder use the same DB.
BACKEND_DIR="/opt/tracktor/build/backend"
mkdir -p "$BACKEND_DIR"
rm -f "$BACKEND_DIR/tracktor.db" 2>/dev/null || true
ln -s "$DB_FILE" "$BACKEND_DIR/tracktor.db"

# Also export DATABASE_URL for any internal tooling/migrations to hit the same file.
export DATABASE_URL="file:${DB_FILE}"

echo "[tracktor-addon] Using database: $DB_FILE"
echo "[tracktor-addon] Exposing server on :${PORT}"

# --- optional: seed PIN into 'auth' table so first login works ---
if [ -n "$PIN_VAL" ]; then
  echo "[tracktor-addon] Seeding PIN…"
  # Use upstream libs present in the image so the hash format matches the app.
  node <<'NODE' || true
    const bcrypt = require('bcryptjs');
    const libsql = require('@libsql/client');

    const pin = process.env.TRACKTOR_PIN || '';
    if (!pin) process.exit(0);

    const url = process.env.DATABASE_URL || '';
    if (!url) process.exit(0);

    (async () => {
      const db = libsql.createClient({ url });
      // Minimal schema expected by backend
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
fi
export TRACKTOR_PIN="$PIN_VAL"

# --- start the app the same way the Docker guide does ---
# Upstream Docker method runs the compiled app via the build scripts.
# Their start script also runs migrations before serving.
echo "[tracktor-addon] Starting Tracktor…"
exec npm start --prefix /opt/tracktor/build
