# Wallos — Home Assistant Add-on (Local Build)

This variant **builds locally** on your Home Assistant host (no GHCR pull). Supervisor will rebuild when `version` changes.

## Persistence
- `/var/www/html/db` → `/config/db`
- `/var/www/html/images/uploads/logos` → `/config/logos`

## Options
- `TZ`: Timezone (e.g., Europe/Vilnius)
- `APP_URL`: Optional base URL (e.g., https://wallos.example.com)

## Migrate existing data
- Copy your previous `db` into `/addon_configs/<...wallos...>/db`
- Copy `logos` into `/addon_configs/<...wallos...>/logos`
Then install/start the add-on and open `http://HOST:8282/`.
