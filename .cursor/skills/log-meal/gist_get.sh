#!/bin/bash
# Fetches the current synced meal-planner state from the private Gist and
# writes it to a local scratch file for inspection (recipe matching, checking
# what's already logged today, etc). Reads credentials from the local,
# gitignored .meal-sync-secrets.json file so the token never appears in a
# shell command or terminal history. Uses system curl (avoids python.org's
# bundled certs, which can be missing a local issuer chain).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../.."

source "$SCRIPT_DIR/load_creds.sh"

DIR=".cursor/skills/log-meal"
RAW_FILE="$DIR/.gist_raw.json"
STATE_FILE="$DIR/.current_state.json"

/usr/bin/curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/gists/${GIST_ID}" -o "$RAW_FILE"

python3 -c "
import json, sys

d = json.load(open('$RAW_FILE'))
filename = '$FILENAME'
if 'files' not in d or filename not in d.get('files', {}):
    print('ERROR:', d.get('message', d), file=sys.stderr)
    sys.exit(1)

content = d['files'][filename]['content']
wrapper = json.loads(content)
data = wrapper.get('data', wrapper)
data.setdefault('log', {})

json.dump(data, open('$STATE_FILE', 'w'), indent=2)

print('OK - current state written to', '$STATE_FILE')
print('gist updatedAt:', wrapper.get('updatedAt') or data.get('updatedAt'))
print('recipes:', len(data.get('recipes', [])))
print('logged dates:', list(data.get('log', {}).keys()))
"

rm -f "$RAW_FILE"
