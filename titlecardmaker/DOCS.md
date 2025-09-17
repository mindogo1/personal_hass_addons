# TitleCardMaker (v1 CLI) — Home Assistant Add-on (Mindogo)

- Configure **Plex/Sonarr/TMDb** and paths in the add-on UI.
- The add-on writes `/config/preferences.yml` from your settings and runs the CLI on your schedule.
- Cards are saved to **CARD_DIR** (default `/config/cards/`).

## Auto updates
This repo publishes images to GHCR. Bump `version` in `config.yaml` and push to `main`.

## ARM (aarch64) note
The workflow tries to build an `-aarch64` image. If the upstream base image doesn't support arm64, the build is skipped. The add-on `config.yaml` currently declares only `amd64` for guaranteed installability.
