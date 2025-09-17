# TitleCardMaker (Web UI) — Home Assistant Add-on

This add-on runs the **official TitleCardMaker Web UI** image from GHCR:

- Image: `ghcr.io/titlecardmaker/titlecardmaker-webui:latest` (supporters-only)
- Port: `4242` (mapped to host)
- Config: mapped to `/config` (persistent HA add-on storage)

## Authentication to GHCR (required)
In Home Assistant:
1. Enable **Advanced Mode** in your profile.
2. Go to **Settings → Add-ons → Add-on store → ⋮ (top-right) → Registries**.
3. Click **Add new registry** and enter:
   - **Registry**: `ghcr.io`
   - **Username**: *your GitHub username*
   - **Password**: *a Personal Access Token (classic) with at least `read:packages`*
     - If the package is in an org that uses SSO, make sure the token is **authorized for SSO**.
4. Save, then **Reload** the Add-on Store and install this add-on.

## Options
- **TZ**: Set your timezone.
- **PUID/PGID**: Optional; set if you need specific file ownership for `/config` (TCM stores its database here).

## Notes
- The add-on `version` is set to `latest` because the upstream tag is `latest`. Updates follow upstream.
- If you still get 403/denied when installing:
  - Double-check your PAT has `read:packages` and is authorized for SSO (if applicable).
  - Confirm your GitHub account actually has access to the **titlecardmaker** GHCR package (supporter entitlement).
