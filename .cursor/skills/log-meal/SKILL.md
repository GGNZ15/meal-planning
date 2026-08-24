---
name: log-meal
description: >-
  Log what the user actually ate into the meal planner's Daily Log, via the
  synced Gist (works the same locally or from a mobile/cloud agent — no
  browser needed). Use when the user tells you what they had for a meal or
  snack (e.g. "I had the baked bean bake for breakfast", "log a coffee and a
  muffin for morning snack", "I ate X for lunch today"), or asks to fix/remove
  something they logged by mistake.
---

# Log Meal

Writes directly into the same private Gist the app's "Sync phone & laptop" feature
uses, so a logged item shows up next time the app syncs — no need to open a browser.

## Setup check (every run)

1. Credentials resolve automatically via `load_creds.sh` (sourced by every script),
   in this order:
   - `.meal-sync-secrets.json` in the repo root (gitignored — local/laptop runs).
   - `MEAL_SYNC_GITHUB_TOKEN` + `MEAL_SYNC_GIST_ID` (+ optional
     `MEAL_SYNC_GIST_FILENAME`) environment variables — for a cloud agent, these come
     from Secrets configured in the Cursor Cloud Agents dashboard, injected at
     runtime. Never write these to a file inside the cloud agent's checkout.
   If neither is available, the scripts fail with a clear error — stop and tell the
   user which one is missing rather than guessing or falling back to editing
   `index.html` directly (that would bypass sync entirely).
2. Run `.cursor/skills/log-meal/gist_get.sh`. This fetches the current synced state
   and writes it to `.cursor/skills/log-meal/.current_state.json` (gitignored scratch
   file — read it with the Read/Grep tools, don't cat secrets around).

## Workflow 1: Log an entry

1. **Determine the date.** Default to **today in Pacific/Auckland (NZ)** — not UTC.
   Cloud agents often run in UTC, so always convert: e.g. 23 Aug 11pm UTC is already
   **24 Aug in NZ**. Resolve relative references ("yesterday", "Friday") against NZ
   local date. Format as `YYYY-MM-DD`. When in doubt, ask the user which NZ date they
   mean.
2. **Determine the slot.** Map the user's wording to one of: `breakfast`,
   `morningSnack`, `lunch`, `afternoonSnack`, `dinner`, `dessert`. If they just say
   "snack" with no time-of-day context, ask which one (or infer from time of day if
   the message implies it, e.g. "before lunch" → morning).
3. **Match against the recipe library.** Search `recipes` in `.current_state.json`
   (case-insensitive, allow partial/rephrased matches — e.g. "baked bean bowl" should
   match "Baked bean bake"). If you find a confident match:
   - Ask for servings if not stated (default 1).
   - Scale macros the same way the app does: `value * (servings / baseServings)` for
     each of `calories, protein, carbs, fat, fibre, sugar, sodium`.
   - Set `recipeId` to that recipe's `id`.
   If there's no confident match (something not in the library, e.g. a cafe order,
   a one-off meal), or the match is ambiguous, ask the user to confirm rather than
   guessing which recipe they mean.
4. **For anything not in the library**, try to find real numbers before estimating:
   - Branded/packaged products or well-known restaurant/chain menu items → try a quick
     `WebSearch`/`WebFetch` lookup for the nutrition panel first (same approach
     `find-meal-ideas` uses for recipe sites) — a sourced number beats an estimate.
   - Homemade or ad hoc items with nothing findable online → estimate using the same
     heuristics as the `find-meal-ideas` skill (see
     [../find-meal-ideas/reference.md](../find-meal-ideas/reference.md) for the
     nutrition-estimation cheat sheet).
   - Either way, you can also just ask the user for known values (e.g. a cafe receipt
     or packet label) — often faster than a lookup.
   Always tell the user which numbers are sourced vs. estimated rather than confirmed.
5. **Check against standing rules** in
   [../../../meal-ideas-rules.md](../../../meal-ideas-rules.md) if relevant (e.g. flag
   if something conflicts with a dislike/restriction) — informational only, never
   block logging on this.
6. If the message describes multiple distinct items for the same slot (e.g. "coffee
   and a muffin for morning snack"), log them as **separate entries**, not one merged
   entry — makes later fixes/removals easier.
7. For each entry, write a small JSON file (fields: `name`, `calories` required;
   `servings`, `protein`, `carbs`, `fat`, `fibre`, `sugar`, `sodium`, `recipeId`
   optional) to a scratch path like `.cursor/skills/log-meal/.entry.json`, then run:

   ```bash
   .cursor/skills/log-meal/gist_append.sh <date> <slot> .cursor/skills/log-meal/.entry.json
   ```

   This re-fetches the latest gist first (so it never clobbers a concurrent edit from
   the browser), appends the entry, and pushes the merged result back. It prints
   `DATE_TOTALS` and `TARGETS` as JSON — use these to report back.
8. Delete the scratch entry file after each successful append.
9. **Report back**: what was logged (with macros, noting anything estimated), and the
   running totals for that date vs. targets from the script's output — call out
   anything already over or close to a daily target (calories, protein, sodium
   especially), similar in tone to the app's own progress indicators.
10. **Grow the database.** For any entry that had no `recipeId` (i.e. it wasn't a
    library match — a new food, cafe order, or estimate), offer to save it into the
    `Foods / Recipes` library too, e.g. "Want me to save '<name>' to your library so
    it's an instant match next time?" If yes:
    - Check for a name/id collision against existing `SEED_RECIPES` entries in
      [index.html](../../../index.html) first — if a close match already exists, don't
      duplicate it, just mention that it'll match automatically next time.
    - Back out **per-serving** macros before saving (the logged entry's values are
      already scaled by `servings`, but `SEED_RECIPES` stores per-`baseServings`
      values) — divide each nutrient by `servings` and set `baseServings: 1`, unless
      the user specifies a different base.
    - Build the entry in the exact shape `find-meal-ideas` uses — see
      [../find-meal-ideas/SKILL.md](../find-meal-ideas/SKILL.md) Workflow 2, step 2 for
      the object shape and the `seed-<slug>` id convention — and append it to
      `SEED_RECIPES` in `index.html` with `StrReplace` (before the closing `];`). Note
      in `instructions` if any numbers were estimated rather than sourced, same
      convention as existing seed recipes.
    - This is a personal, non-collaborative repo, so commit and push this directly
      (`git add index.html && git commit -m "..." && git push`) rather than staging it
      in `meal-ideas-candidates.md` for review — that staging step is only for the
      batches `find-meal-ideas` generates, not single items logged in passing. If a
      push isn't possible in the current environment, just say the entry was logged
      but not saved to the library.
    - This only ever *adds* a new library entry — never touch `state.log` (the actual
      consumption record) as part of this step; that was already written in step 7.
11. Mention (briefly, not every time) that this will show up in the app next time it
    syncs — automatically if the tab is open and regains focus, or via the Sync button
    otherwise.

## Workflow 2: Fix a mislogged entry

Triggered when the user says they logged something wrong (wrong item, wrong slot,
wrong date, or just "remove that").

1. Run `gist_get.sh` and look at `log[date][slot]` in `.current_state.json` to find
   the matching entry (by name/date/slot — confirm with the user if more than one
   entry could match).
2. Run:

   ```bash
   .cursor/skills/log-meal/gist_remove_entry.sh <date> <slot> <entryId>
   ```

3. Confirm removal and, if they wanted to log something different instead, continue
   into Workflow 1.

## Notes

- The actual log entry (`state.log`) always lives only in the synced state
  (localStorage + Gist), never in git — logging never touches `index.html` by itself.
  The *only* time this skill edits `SEED_RECIPES` in git is the opt-in "grow the
  database" step (Workflow 1, step 10), and only to add a reusable library entry —
  never to record what was eaten on a given date.
- All scripts read credentials from `.meal-sync-secrets.json` directly — never pass
  the token as a command-line argument or print it.
- The Daily Log is intentionally separate from the Day A / Day B planning template —
  logging a meal never changes what's planned for Day A/B.
