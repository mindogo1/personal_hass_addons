# Wallos — Home Assistant Add-on

Wraps `bellamy/wallos` and exposes the Web UI on port 8282.

## Persistence
The add-on maps `/config` (HA persistent storage), then symlinks:
- `/var/www/html/db` → `/config/db`
- `/var/www/html/images/uploads/logos` → `/config/logos`

## Configuration
- `TZ`: Timezone (e.g., Europe/Vilnius)
- `APP_URL`: Optional base URL if running behind a reverse proxy (e.g., https://wallos.example.com)

## Migrate existing data
- Copy your prior Wallos `db` directory to this add-on's `/config/db`
- Copy your prior `logos` directory to `/config/logos`
Then start the add-on and open `http://HOST:8282/`.
