# Tracktor — Home Assistant Add-on

Wraps **ghcr.io/javedh-dev/tracktor:latest** and exposes the Web UI via a configurable host port.

## Web UI
- Container port: **3000**
- Default host port: **3339** (editable in Add-on → Configuration → Network)
- `webui: http://[HOST]:[PORT:3000]/` — the Open Web UI button tracks your chosen host port.

## Persistence
- The add-on's persistent folder is `/data` (mounted by Supervisor).
- Tracktor also uses `/data` → your DB and uploads live across restarts/updates.

## Options (Environment variables)
- `TZ`: Timezone, e.g. `Europe/Vilnius`
- `CORS_ORIGINS`: e.g. `http://<HA-IP>:<host-port>`
- `PUBLIC_API_BASE_URL`: e.g. `http://<HA-IP>:<host-port>`
- `AUTH_PIN`: 6-digit PIN used by the app

## Notes
- Upstream listens on **port 3000** and stores data in **/data**.
- If you change the host port, update `CORS_ORIGINS` and `PUBLIC_API_BASE_URL` to match.
