# meal-planning

Meal planner, ideas library, and daily log. A single self-contained
`index.html` — no build step, open it directly.

## Files

- `index.html` — the whole app
- `meal-ideas-rules.md` — the rules new meal ideas must satisfy
- `meal-ideas-candidates.md` — staging area for ideas not yet accepted
- `.cursor/skills/` — `log-meal` and `find-meal-ideas` skills

## Sync and secrets

State syncs between phone and laptop via a GitHub Gist. Credentials live in
`.meal-sync-secrets.json`, which is gitignored and has never been committed —
keep it that way.

## Known duplication

`closet-mixer/public/meals.html` is an older, drifted copy of this app, and
closet-mixer reads meal state from the same browser storage keys. Changes here
may need mirroring there, or the two should be reconciled into one canonical
copy. See `closet-mixer/AGENTS.md`.
