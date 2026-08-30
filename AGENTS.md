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

`index.html` is the single source of truth. `closet-mixer/public/meals.html` is
generated from it — make every planner change here, then run:

```bash
./scripts/sync-meal-planner.sh
```

Forgetting this is how the two drifted apart before (a fork taken 2026-07-28
missed five commits of features through 2026-08-22). `--check` will tell you if
the generated copy is stale.

### The embedder hook

Near the end of the script, `runBootstrapHook()` awaits an optional
`window.__mealPlannerBootstrap` before the first `render()`. Standalone, it does
nothing. closet-mixer defines it to seed an empty planner from a bundled backup.

If you change `defaultState`, `normalizeDayPlan`, `saveState`, or the shape of
`state`, check `closet-mixer/public/meal-bundle-import.js` — it receives those
through the hook's context object and will break silently otherwise, since the
hook swallows its own errors by design.
