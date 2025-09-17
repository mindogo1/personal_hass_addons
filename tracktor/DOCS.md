# Tracktor — Home Assistant Add-on (from source)

This add-on **builds Tracktor from the GitHub source** and runs it inside Home Assistant.

## Web UI
- Container port: **3000**
- Default host port: **3339** (editable in Add-on → Configuration → Network)
- `webui: http://[HOST]:[PORT:3000]/` keeps the “Open Web UI” button in sync.

## Persistence
- The add-on’s `/data` is persistent across restarts/updates.
- We symlink common app data dirs (`/opt/tracktor/data`, `/opt/tracktor/app/data`) to `/data` so the SQLite DB lives there.

## Options
- `TZ` (e.g., `Europe/Vilnius`)
- `AUTH_PIN` (optional)
- `CORS_ORIGINS` (optional, e.g., `http://<HA-IP>:<host-port>`)
- `PUBLIC_API_BASE_URL` (optional, e.g., `http://<HA-IP>:<host-port>`)
- `GIT_REF` branch/tag/commit to build (default `dev`).

## Notes
- The project uses SvelteKit + Node/Express + SQLite (Sequelize). Build time dependencies for sqlite native bindings are included.
- If upstream changes their build/start scripts, the launcher tries reasonable fallbacks and logs what it’s doing.
