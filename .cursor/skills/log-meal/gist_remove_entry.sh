#!/bin/bash
# Removes a single logged entry (by id) from a date/slot in the synced state,
# then pushes the result back to the private Gist. Always re-fetches the
# latest gist content first (read-merge-write). Reads credentials from the
# local, gitignored .meal-sync-secrets.json file.
#
# Usage: gist_remove_entry.sh <date YYYY-MM-DD> <slotId> <entryId>
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../.."

DATE="${1:-}"
SLOT="${2:-}"
ENTRY_ID="${3:-}"

if [[ ! "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "ERROR: date must be YYYY-MM-DD, got: '$DATE'" >&2
  exit 1
fi

case "$SLOT" in
  breakfast|morningSnack|lunch|afternoonSnack|dinner|dessert) ;;
  *)
    echo "ERROR: slot must be one of breakfast, morningSnack, lunch, afternoonSnack, dinner, dessert — got: '$SLOT'" >&2
    exit 1
    ;;
esac

if [ -z "$ENTRY_ID" ]; then
  echo "ERROR: entry id required" >&2
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

date_plan = data['log'].get('$DATE')
if not date_plan or not date_plan.get('$SLOT'):
    print('Nothing found for $DATE / $SLOT', file=sys.stderr)
    sys.exit(1)

before = len(date_plan['$SLOT'])
date_plan['$SLOT'] = [e for e in date_plan['$SLOT'] if e.get('id') != '$ENTRY_ID']
after = len(date_plan['$SLOT'])
if before == after:
    print('ERROR: no entry with id $ENTRY_ID found in $DATE / $SLOT', file=sys.stderr)
    sys.exit(1)

# Tidy up: drop the whole date entry once every slot for it is empty again.
if not any(date_plan.values()):
    data['log'].pop('$DATE', None)

now = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='milliseconds').replace('+00:00', 'Z')
data['updatedAt'] = now
payload = {'updatedAt': now, 'data': data}
json.dump({'files': {filename: {'content': json.dumps(payload, indent=2)}}}, open('$PAYLOAD_FILE', 'w'))
print('Removed entry $ENTRY_ID from $DATE / $SLOT')
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
print('OK - pushed removal to gist.')
"

rm -f "$RAW_FILE" "$PAYLOAD_FILE"
