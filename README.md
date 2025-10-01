# Mindogo's Home Assistant Add-ons

A collection of custom Home Assistant add-ons maintained by **mindogo1**. This repository hosts fully functional add-ons that you can install directly from your Home Assistant instance.

Add‑ons Included
## Add-ons Included

1. ByteStash
### 1. ByteStash
- **Description**: Self-hosted code snippet server using [ByteStash](https://github.com/jordan-dalby/ByteStash).
- **Repository Path**: [`/bytestash`](./bytestash)
- **Features**:
  - Web UI accessible via Ingress or host network  
  - Persistent storage under `/config`  
  - Automated version bump workflow on GitHub Actions  

Description: Self‑hosted code snippet server using ByteStash.
### 2. Wallos
- **Description**: Self-hosted personal subscription tracker powered by [Wallos](https://github.com/ellite/Wallos).
- **Repository Path**: [`/wallos`](./wallos)
- **Features**:
  - Built-in web UI via Ingress  
  - Persistent storage under `/config`  
  - Automated version bump workflow on GitHub Actions  

## Installation


In Home Assistant, go to Settings → Add‑on Store → Repositories.

Add the repository URL:

https://github.com/mindogo1/personal_hass_addons

Wait 30–60 seconds for Supervisor to fetch the index.

The add‑ons ByteStash and Wallos will appear in your Add‑on Store.

Usage

Select the desired add‑on and click Install.

After installation, click Start to launch the container.

Use the Open Web UI button to configure and use the service.

Updates

Each add‑on is configured with a GitHub Actions workflow (.github/workflows/) to automatically bump its version: in the manifest when a new upstream release is available:

ByteStash: .github/workflows/update-bytestash-version.yml

Wallos:   .github/workflows/update-wallos-version.yml

When a new version is detected and committed, Home Assistant will show an Update button in the Add‑on Store for that add‑on.

License

This repository is licensed under the MIT License.
1. In Home Assistant, go to **Settings → Add-on Store → Repositories**.  
2. Add the repository URL:

   ```text
   https://github.com/mindogo1/personal_hass_addons