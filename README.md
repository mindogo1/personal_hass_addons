# Mindogo Personal Add-ons

Custom Home Assistant add-ons maintained by **Mindogo**.

## Add this repo to Home Assistant
Settings → Add-ons → Add-on store → ⋮ → **Repositories** → paste your repo URL → **Add** → **Reload**.

## Auto updates
- Bump `version` in the add-on’s `config.yaml`.
- Push to `main`. GitHub Actions builds & pushes container images to GHCR.
- HA will show the update (or auto-update if enabled).
