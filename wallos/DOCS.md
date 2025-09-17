# Wallos — Home Assistant Add-on

This add-on wraps the public Docker image `bellamy/wallos` and exposes the Web UI in Home Assistant.

## Defaults
- Web UI: **http://HOST:8282/**
- Data persistence: the add-on maps `/config` (persistent), then symlinks:
  - `/var/www/html/db` → `/config/db` (database)
  - `/var/www/html/images/uploads/logos` → `/config/logos` (uploaded logos)

These paths mirror common Docker Compose examples for Wallos. 

## Configuration
- **TZ**: Timezone (e.g., `Europe/Vilnius`).
- **APP_URL** *(optional)*: Base URL if running behind a reverse proxy (e.g., `https://wallos.example.com`).

## Migration from Docker/Portainer
If coming from a previous setup:
- Copy your **db** folder into this add-on’s `/config/db`.
- Copy your **logos** folder (if any) into `/config/logos`.
Then start the add-on and browse to the Web UI.

## Notes
- The add-on supports both `amd64` and `aarch64` (the upstream image is multi-arch).
