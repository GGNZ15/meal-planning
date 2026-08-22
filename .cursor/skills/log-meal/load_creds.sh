#!/bin/bash
# Shared credential loader for the log-meal scripts. Sourced (not executed)
# by the other scripts, so it must be run from a script that already `cd`'d
# to the repo root.
#
# Resolves credentials from either source, in order:
#   1. .meal-sync-secrets.json in the repo root (local/laptop use — gitignored)
#   2. MEAL_SYNC_GITHUB_TOKEN / MEAL_SYNC_GIST_ID / MEAL_SYNC_GIST_FILENAME
#      environment variables (cloud agent use — set as Secrets in the Cursor
#      Cloud Agents dashboard, never committed anywhere)
#
# Sets: TOKEN, GIST_ID, FILENAME

SECRETS=".meal-sync-secrets.json"

if [ -f "$SECRETS" ]; then
  TOKEN=$(python3 -c "import json; print(json.load(open('$SECRETS'))['githubToken'])")
  GIST_ID=$(python3 -c "import json; print(json.load(open('$SECRETS'))['gistId'])")
  FILENAME=$(python3 -c "import json; print(json.load(open('$SECRETS'))['gistFilename'])")
elif [ -n "${MEAL_SYNC_GITHUB_TOKEN:-}" ] && [ -n "${MEAL_SYNC_GIST_ID:-}" ]; then
  TOKEN="$MEAL_SYNC_GITHUB_TOKEN"
  GIST_ID="$MEAL_SYNC_GIST_ID"
  FILENAME="${MEAL_SYNC_GIST_FILENAME:-meal-planner-state.json}"
else
  echo "ERROR: no credentials found. Need either .meal-sync-secrets.json in the repo root (local use), or MEAL_SYNC_GITHUB_TOKEN + MEAL_SYNC_GIST_ID environment variables (cloud agent use)." >&2
  exit 1
fi
