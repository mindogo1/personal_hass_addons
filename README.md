# Mindogo1's Personal Home Assistant Addons

This repository serves as a collection of Home Assistant Addons developed and maintained by Mindogo1. You can add this single repository URL to your Home Assistant Add-on Store to access all the addons contained within.

## Included Addons
* **[Cleanuparr](https://github.com/mindogo1/personal_hass_addons/tree/main/cleanuparr)**: A powerful Python script for tidying up leftover media files from applications like Sonarr, Radarr, and Lidarr. Automatically updated from upstream.
* *(Future Addons will be listed here)*

## How to Add This Addon Collection to Home Assistant

1.  **Add This Repository URL to Home Assistant**:
    * In your Home Assistant instance, navigate to `Settings` -> `Add-ons`.
    * Click on the `Add-on Store` button in the bottom right corner.
    * Click on the three dots menu in the top right corner and select `Repositories`.
    * Enter the URL of this GitHub repository:
        `https://github.com/mindogo1/personal_hass_addons`
    * Click `Add`.
    * Close the "Manage add-on repositories" dialog.

2.  **Install Individual Addons**:
    * After adding the repository, refresh the `Add-on Store` page (e.g., by clicking the browser refresh button or navigating away and back to Add-on Store).
    * You should now see "Mindogo1's Personal Home Assistant Addons" as a new section.
    * Scroll down or use the search bar to find the specific addon you want (e.g., "Cleanuparr").
    * Click on the addon and then click the `Install` button.

Each addon within this collection will have its own `README.md` within its respective folder (`cleanuparr/README.md`) detailing its specific configuration and usage.

---

### Step-by-Step Installation Guide (for you and your users)

This guide assumes you have already:
1.  Created the `https://github.com/mindogo1/personal_hass_addons` repository.
2.  Arranged all the files exactly as shown above in that repository.
3.  **Crucially, confirmed that your GitHub Actions workflow (`.github/workflows/build-all-addons.yml`) has run successfully at least once**, building and pushing the Docker images (e.g., `ghcr.io/mindogo1/cleanuparr-amd64:latest`) to GitHub Container Registry. Without this, Home Assistant won't find the images to install.

---

#### Installation Steps in Home Assistant:

**Estimated Time:** 5-15 minutes (depending on internet speed for image download)

1.  **Open Home Assistant:**
    * Access your Home Assistant interface in your web browser.

2.  **Navigate to the Add-on Store:**
    * In the Home Assistant sidebar, click on **Settings** (the gear icon).
    * From the Configuration menu, click on **Add-ons**.
    * On the Add-ons page, in the bottom right corner, click the **Add-on Store** button.

3.  **Add Your Custom Addon Repository:**
    * In the Add-on Store, click the **three dots** menu in the top right corner.
    * Select **Repositories**.
    * In the "Add repository" field, paste the URL of your new collection repository:
        `https://github.com/mindogo1/personal_hass_addons`
    * Click the **Add** button.
    * Close the "Manage add-on repositories" dialog.

4.  **Find and Install the Cleanuparr Addon:**
    * You might need to refresh the Add-on Store page. You can do this by navigating away and back to "Add-on Store", or simply by refreshing your web browser page (Ctrl+F5 or Cmd+R).
    * Scroll down the Add-on Store page. You should now see a new section titled **"Mindogo1's Personal Home Assistant Addons"**.
    * Under this section, you will find the **"Cleanuparr"** addon listed.
    * Click on the **"Cleanuparr"** addon.
    * Click the **Install** button. Home Assistant will now download and install the addon's Docker image. This process can take several minutes.

5.  **Configure the Cleanuparr Addon:**
    * Once the installation is complete, stay on the Cleanuparr addon's page.
    * Click on the **Configuration** tab.
    * You will see the configurable options for Cleanuparr.
    * **`cleanup_paths`**: This is critical. Click the `+ Add Item` button to add each directory that Cleanuparr should scan and clean.
        * **Remember to use paths accessible *within the Docker container***. Common examples are `/share/downloads/incomplete` or `/media/tv/.grab`, assuming your Home Assistant has these host paths mapped to `/share` and `/media` inside its Docker environment.
    * **`dry_run`**: **For your first runs, leave this set to `true`!** This is a safety measure. It will simulate deletions and show you what *would* be deleted in the logs without actually deleting anything.
    * **`log_level`**: (Optional) `info` is usually fine, `debug` provides more verbose output for troubleshooting.
    * **`schedule`**: (Optional) This field is purely for your reference in `addon.json` and `config.yaml`. The addon itself doesn't use it for scheduling. It's a reminder for your Home Assistant automation.
    * After making your changes, click the **Save** button.

6.  **Perform an Initial Test (Dry Run):**
    * Go back to the **Info** tab of the Cleanuparr addon.
    * Click the **Start** button.
    * Immediately go to the **Logs** tab.
    * Review the logs carefully. Look for messages from Cleanuparr indicating what files it found and what actions it *would* take.
    * **Crucially, ensure there are no errors about paths not existing or permission denied.** If there are, go back to Step 5 to correct your `cleanup_paths` or verify volume mappings in your Home Assistant setup.
    * If the dry run looks correct and safe, you can go back to the **Configuration** tab, change `dry_run` to `false`, and click **Save**. Then, run it manually again if you wish to perform the actual cleanup.

7.  **Set Up Automation for Periodic Runs (Highly Recommended):**
    Since the addon runs once and then stops, you need a Home Assistant automation to trigger it periodically.
    * In Home Assistant, go to **Settings** -> **Automations & Scenes**.
    * Click the **Automations** tab.
    * Click **Create Automation** (usually a blue button in the bottom right).
    * Select **Start with an empty automation**.
    * **Name your automation** (e.g., "Daily Cleanuparr Run").
    * **Configure the Trigger**:
        * Click `+ Add Trigger`.
        * Select **Time**.
        * In the "At" field, enter the time you want Cleanuparr to run (e.g., `03:00:00` for 3 AM). This can align with the `schedule` value you set in the addon config.
    * **Configure the Action**:
        * Click `+ Add Action`.
        * Select **Call service**.
        * In the "Service" field, type `hassio.addon_start` and select it from the list.
        * Under "Service data", add an item:
            * Key: `addon`
            * Value: `cleanuparr` (This is the `slug` from the `cleanuparr/addon.json` file).
    * Click **Save automation** (bottom right).
    * Ensure the automation toggle is **enabled** (it should be green).

You now have a fully functional Home Assistant addon collection!