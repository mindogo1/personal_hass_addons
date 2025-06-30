#!/usr/bin/env bash
set -e

# Define logger function for consistent output
log() {
    local type="$1"
    local message="$2"
    echo "$(date +"%Y-%m-%d %H:%M:%S") [${type^^}] ${message}"
}

log info "Starting Cleanuparr Addon service..."

if ! command -v jq &> /dev/null
then
    log error "jq could not be found. Please ensure it's installed in the base image or add it to Dockerfile."
    exit 1
fi

# Load addon configuration from /data/options.json
LOG_LEVEL=$(jq --raw-output ".log_level // \"Information\"" /data/options.json)
DRY_RUN=$(jq --raw-output ".dry_run // true" /data/options.json)
PATHS_TO_CLEANUP_JSON=$(jq --raw-output ".paths_to_cleanup" /data/options.json) # array of strings

log info "Configuration loaded from options.json:"
log info "  Log Level: $LOG_LEVEL"
log info "  Dry Run: $DRY_RUN"
log info "  Paths to Cleanup JSON: $PATHS_TO_CLEANUP_JSON"


# Construct the appsettings.json file dynamically
# This is a basic structure. Cleanuparr has many other options (ArrClient, DownloadClient, etc.)
# which would need to be exposed in addon.json and mapped here if desired.
# For simplicity, we only map log_level, dry_run, and paths_to_cleanup.
APPSETTINGS_CONTENT=$(cat <<EOF
{
  "Logging": {
    "LogLevel": {
      "Default": "$LOG_LEVEL",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://*:11011"
      }
    }
  },
  "Cleanuparr": {
    "ConfigPaths": $PATHS_TO_CLEANUP_JSON,
    "DryRun": $DRY_RUN
    // Other Cleanuparr settings (ArrClient, DownloadClient, etc.) would go here
    // You would expose them as options in addon.json and parse them from options.json
    // just like log_level and dry_run.
  }
}
EOF
)

# Write the generated appsettings.json to /app/appsettings.json
# Cleanuparr expects this file in its working directory.
echo "$APPSETTINGS_CONTENT" > /app/appsettings.json
log info "Generated appsettings.json:"
cat /app/appsettings.json

# If you also need a separate config directory for Cleanuparr (e.g. for database, logs etc.)
# based on Cleanuparr's official docker-compose example, map it to /config.
# The appsettings.json goes to /app/appsettings.json

# Start the Cleanuparr .NET application
# The official image's ENTRYPOINT is likely already set up to run dotnet Cleanuparr.dll
# We'll explicitly run it here to ensure it uses our generated appsettings.json
log info "Executing: dotnet Cleanuparr.dll"
dotnet Cleanuparr.dll --urls "http://+:11011" &

# Capture the PID of the Cleanuparr process
CLEANUPARR_PID=$!

log info "Cleanuparr service started with PID $CLEANUPARR_PID. Monitoring logs..."

# Keep the script running to keep the container alive and output logs
# We'll tail the standard output from the dotnet process.
wait $CLEANUPARR_PID