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

## This is the canonical meal planner

`closet-mixer/public/meals.html` is a stale fork of this file, taken 2026-07-28.
Five commits of feature work landed here on 2026-08-22 and never reached it, so
this copy is roughly a month ahead.

Make all meal planner changes here. When `meals.html` is regenerated from this
file it needs its bundle-import adaptation re-applied — about 55 lines that seed
an empty planner from `/meal-planner-backup.json`. See `closet-mixer/AGENTS.md`
for why that fork exists (same-origin `localStorage` sharing).
