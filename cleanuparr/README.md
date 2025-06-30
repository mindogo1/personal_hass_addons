# Home Assistant Cleanuparr Addon

This is the Home Assistant Addon for [Cleanuparr](https://github.com/Cleanuparr/Cleanuparr), a powerful .NET application with a Web UI designed to manage and clean up leftover media files from applications like Sonarr, Radarr, and Lidarr. This addon runs Cleanuparr as a continuous service, directly leveraging its official Docker image for seamless updates.

## Features

* **Persistent Service:** Runs continuously in the background, managing its own internal tasks.
* **Web User Interface (UI):** Access Cleanuparr's dashboard directly from your Home Assistant sidebar via Ingress.
* **Automated Cleanup:** Efficiently removes unwanted or blocked files from your specified media download directories.
* **Configurable Paths:** Define specific directories for Cleanuparr to monitor and clean.
* **Dry Run Mode:** Test your cleanup configurations safely without making any actual file deletions.
* **Seamless Home Assistant Integration:** Install, configure, and manage Cleanuparr directly through the Home Assistant Supervisor.
* **Always Automatically Updated:** This addon uses the official Cleanuparr Docker image as its base, ensuring you're always running the latest upstream version.

## Installation

This addon is part of the **Mindogo1's Personal Home Assistant Addons** collection.
To install this addon, you first need to add the main repository to your Home Assistant Add-on Store.

1.  **Add the Collection Repository to Home Assistant:**
    * In Home Assistant, navigate to `Settings` -> `Add-ons`.
    * Click on the `Add-on Store` button (bottom right).
    * Click the **three dots** menu (top right) and select `Repositories`.
    * Enter the URL for the collection repository:
        `https://github.com/mindogo1/personal_hass_addons`
    * Click `Add`, then close the dialog.

2.  **Install the Cleanuparr Addon:**
    * Refresh the Add-on Store page.
    * You should now see a new section: "Mindogo1's Personal Home Assistant Addons".
    * Locate and click on the **"Cleanuparr"** addon.
    * Click the **Install** button.

## Configuration

After installation, go to the **Configuration** tab of the Cleanuparr addon.

* **`log_level`**: (Optional) Sets the verbosity of Cleanuparr's logs. Options (matching .NET log levels): `Trace`, `Debug`, `Information`, `Warning`, `Error`, `Critical`, `None`.
    * Default: `Information`
* **`paths_to_cleanup`**: (Required) A list of **full paths** to the directories that Cleanuparr should scan and clean.
    * **CRITICAL**: These paths must be accessible from within the addon's Docker container. For common Home Assistant shared storage, use paths like `/share/your_folder` or `/media/your_downloads`.
    * **Example:**
        ```yaml
        paths_to_cleanup:
          - "/share/downloads/incomplete_torrents"
          - "/media/tv_shows/.grab"
        ```
* **`dry_run`**: (Optional) Set to `true` to run Cleanuparr in simulation mode. No files will be deleted. This is **highly recommended for initial testing** to ensure your paths and configurations are correct before any deletions occur.
    * Default: `true`

#### Example Addon Configuration:

```yaml
log_level: Information
paths_to_cleanup:
  - "/share/data/downloads/torrent_temp"
  - "/media/movies/orphaned_files"
dry_run: false # Set to 'true' for testing!