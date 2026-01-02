#!/bin/sh
set -e

OPT="/data/options.json"

get_opt() {
  key="$1"
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$OPT" | head -n1
}

TZ_VAL="$(get_opt TZ)"
PIN_VAL="$(get_opt PIN)"
PORT_VAL="$(get_opt PORT)"

[ -n "$TZ_VAL" ] && export TZ="$TZ_VAL"
[ -z "$PORT_VAL" ] && PORT_VAL=3000

export HOST=0.0.0.0
export PORT="$PORT_VAL"

DATA_DIR="/data/tracktor"
DB_FILE="$DATA_DIR/tracktor.sqlite"
UPLOADS_DIR="$DATA_DIR/uploads"

APP_ROOT="/opt/tracktor"
APP_UPLOADS="$APP_ROOT/uploads"

mkdir -p "$DATA_DIR" "$UPLOADS_DIR"

# ---- Database persistence
ln -sf "$DB_FILE" "$APP_ROOT/tracktor.db"

# ---- Uploads persistence
if [ ! -e "$APP_UPLOADS" ]; then
  ln -s "$UPLOADS_DIR" "$APP_UPLOADS"
fi

# ---- Optional PIN seeding (no installs)
if [ -n "$PIN_VAL" ]; then
  export TRACKTOR_PIN="$PIN_VAL"
  node <<'NODE'
const bcrypt = require("bcryptjs");
const { createClient } = require("@libsql/client");

(async () => {
  const db = createClient({ url: "file:/data/tracktor/tracktor.sqlite" });
  await db.execute(`
    CREATE TABLE IF NOT EXISTS auth (
      id INTEGER PRIMARY KEY,
      hash TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);
  const hash = await bcrypt.hash(process.env.TRACKTOR_PIN, 10);
  await db.execute({
    sql: `INSERT INTO auth (id, hash)
          VALUES (1, ?)
          ON CONFLICT(id)
          DO UPDATE SET hash=excluded.hash, updated_at=CURRENT_TIMESTAMP`,
    args: [hash]
  });
})();
NODE
fi

echo "[tracktor-addon] Starting Tracktor on port $PORT"
exec pnpm start
