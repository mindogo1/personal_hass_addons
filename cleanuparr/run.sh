#!/usr/bin/env bash

export RADARR_URL="${RADARR_URL}"
export RADARR_API_KEY="${RADARR_API_KEY}"
export SONARR_URL="${SONARR_URL}"
export SONARR_API_KEY="${SONARR_API_KEY}"

/cleanuparr/cleanuparr
