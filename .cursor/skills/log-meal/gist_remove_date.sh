#!/bin/bash
# One-off cleanup helper: deletes an entire date's log data (e.g. a test
# date used to verify gist_append.sh). Not part of the normal chat-logging
# workflow — the app's own "Clear day" button covers this in the UI. Reads
# credentials from the local, gitignored .meal-sync-secrets.json file.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../.."

DATE="${1:-}"
if [[ ! "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "ERROR: date must be YYYY-MM-DD, got: '$DATE'" >&2
  exit 1
fi

source "$SCRIPT_DIR/load_creds.sh"

DIR=".cursor/skills/log-meal"
RAW_FILE="$DIR/.gist_raw.json"
PAYLOAD_FILE="$DIR/.gist_payload.json"

/usr/bin/curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/gists/${GIST_ID}" -o "$RAW_FILE"

python3 -c "
import json, datetime, sys

d = json.load(open('$RAW_FILE'))
filename = '$FILENAME'
wrapper = json.loads(d['files'][filename]['content'])
data = wrapper.get('data', wrapper)
data.setdefault('log', {})
removed = data['log'].pop('$DATE', None)
if removed is None:
    print('Nothing to remove for $DATE', file=sys.stderr)

now = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='milliseconds').replace('+00:00', 'Z')
data['updatedAt'] = now
payload = {'updatedAt': now, 'data': data}
json.dump({'files': {filename: {'content': json.dumps(payload, indent=2)}}}, open('$PAYLOAD_FILE', 'w'))
print('Removed log for $DATE' if removed is not None else 'No-op')
"

/usr/bin/curl -s -X PATCH -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" \
  --data @"$PAYLOAD_FILE" \
  "https://api.github.com/gists/${GIST_ID}" -o "$RAW_FILE"

python3 -c "
import json, sys
d = json.load(open('$RAW_FILE'))
if 'files' not in d:
    print('ERROR pushing to gist:', d.get('message', d), file=sys.stderr)
    sys.exit(1)
print('OK - pushed cleanup to gist.')
"

rm -f "$RAW_FILE" "$PAYLOAD_FILE"
