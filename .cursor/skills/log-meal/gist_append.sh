#!/bin/bash
# Appends one logged-meal entry into the synced meal-planner state's Daily
# Log, then pushes the result back to the private Gist. Always re-fetches
# the latest gist content first (read-merge-write) so it never clobbers
# edits made from the browser/phone in between runs, and never touches any
# field except data.log — recipes, targets, and day plans pass through
# untouched.
#
# Usage: gist_append.sh <date YYYY-MM-DD> <slotId> <entry-json-file>
#
# entry-json-file should contain an object with:
#   name (required), calories (required), servings (default 1),
#   protein, carbs, fat, fibre, sugar, sodium (default 0),
#   recipeId (optional, set when this matches an existing library recipe)
#
# Credentials are read from the local, gitignored .meal-sync-secrets.json
# file so the token never appears in a shell command or terminal history.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/../../.."

DATE="${1:-}"
SLOT="${2:-}"
ENTRY_FILE="${3:-}"

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

if [ ! -f "$ENTRY_FILE" ]; then
  echo "ERROR: entry file not found: $ENTRY_FILE" >&2
  exit 1
fi

source "$SCRIPT_DIR/load_creds.sh"

DIR=".cursor/skills/log-meal"
RAW_FILE="$DIR/.gist_raw.json"
PAYLOAD_FILE="$DIR/.gist_payload.json"

/usr/bin/curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/gists/${GIST_ID}" -o "$RAW_FILE"

python3 -c "
import json, uuid, datetime, sys

d = json.load(open('$RAW_FILE'))
filename = '$FILENAME'
if 'files' not in d or filename not in d.get('files', {}):
    print('ERROR:', d.get('message', d), file=sys.stderr)
    sys.exit(1)

wrapper = json.loads(d['files'][filename]['content'])
data = wrapper.get('data', wrapper)

entry = json.load(open('$ENTRY_FILE'))
if not entry.get('name') or entry.get('calories') is None:
    print('ERROR: entry json needs at least name and calories', file=sys.stderr)
    sys.exit(1)

clean = {
    'id': str(uuid.uuid4()),
    'recipeId': entry.get('recipeId') or None,
    'name': str(entry['name'])[:200],
    'servings': float(entry.get('servings', 1) or 1),
    'source': 'chat',
}
for k in ('calories', 'protein', 'carbs', 'fat', 'fibre', 'sugar', 'sodium'):
    clean[k] = float(entry.get(k, 0) or 0)

data.setdefault('log', {})
date_plan = data['log'].setdefault('$DATE', {})
for slot_id in ('breakfast', 'morningSnack', 'lunch', 'afternoonSnack', 'dinner', 'dessert'):
    date_plan.setdefault(slot_id, [])
date_plan['$SLOT'].append(clean)

now = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='milliseconds').replace('+00:00', 'Z')
data['updatedAt'] = now

payload = {'updatedAt': now, 'data': data}
json.dump({'files': {filename: {'content': json.dumps(payload, indent=2)}}}, open('$PAYLOAD_FILE', 'w'))

totals = {k: 0.0 for k in ('calories', 'protein', 'carbs', 'fat', 'fibre', 'sugar', 'sodium')}
for slot_items in date_plan.values():
    for item in slot_items:
        for k in totals:
            totals[k] += float(item.get(k, 0) or 0)

print('ENTRY_ADDED:', clean['name'])
print('DATE_TOTALS:', json.dumps(totals))
print('TARGETS:', json.dumps(data.get('targets', {})))
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
print('OK - pushed to gist. updated_at:', d.get('updated_at'))
"

rm -f "$RAW_FILE" "$PAYLOAD_FILE"
