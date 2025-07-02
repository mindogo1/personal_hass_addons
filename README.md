# Mindogo's Home Assistant Add-ons

A collection of custom Home Assistant add-ons maintained by **mindogo1**. This repository hosts two fully functional add-ons that you can install directly from your Home Assistant instance.

## Add-ons Included

### 1. ByteStash
- **Description**: Self-hosted code snippet server using [ByteStash](https://github.com/jordan-dalby/ByteStash).
- **Repository Path**: [`/bytestash`](./bytestash)
- **Features**:
  - Web UI accessible via Ingress or host network  
  - Persistent storage under `/config`  
  - Automated version bump workflow on GitHub Actions  

### 2. Wallos
- **Description**: Self-hosted personal subscription tracker powered by [Wallos](https://github.com/ellite/Wallos).
- **Repository Path**: [`/wallos`](./wallos)
- **Features**:
  - Built-in web UI via Ingress  
  - Persistent storage under `/config`  
  - Automated version bump workflow on GitHub Actions  

## Installation

1. In Home Assistant, go to **Settings → Add-on Store → Repositories**.  
2. Add the repository URL:

   ```text
   https://github.com/mindogo1/personal_hass_addons
