---
name: find-meal-ideas
description: >-
  Suggest new meal/recipe ideas from creator websites or social accounts, matching
  the user's standing nutrition/dietary rules, then (once approved) add them to the
  meal planner in index.html. Use when the user asks to find, suggest, or come up
  with new meal ideas, recipes, or foods for the planner, references food creators
  or recipe sites, or asks to add approved candidates from meal-ideas-candidates.md.
---

# Find Meal Ideas

Two workflows: **Find ideas** (research → staging file for review) and **Add approved
ideas** (staging file → `index.html`). Never skip straight from a source to
`index.html` — always stage candidates for review first.

## Workflow 1: Find ideas

1. Read [meal-ideas-rules.md](../../../meal-ideas-rules.md) for standing nutrition
   guardrails, restrictions, favourite creators, and variety notes. Combine with any
   sites/rules given in the current request (request rules take precedence for that run).
2. Build the dedupe set: recipe names already in `SEED_RECIPES` in
   [index.html](../../../index.html), plus recipe names from
   `meal-planner-backup.json` in the repo root if that file exists (an optional export
   of the user's full live library — see rules file). Skip anything that already exists.
3. For each source:
   - Normal blog/recipe site → `WebFetch` the page directly.
   - Instagram/TikTok/social post that can't be fetched (blocked, login wall, or fetch
     returns no real content) → ask the user to paste the caption/text instead, same as
     the app's existing "Import from text" flow. Don't guess at a recipe from a URL alone.
4. For each candidate recipe, extract or estimate (see
   [reference.md](reference.md) for estimation help when a source has no nutrition
   panel):
   - `name`, `baseServings`
   - Full macro panel: `calories`, `protein`, `carbs`, `fat`, `fibre`, `sugar`, `sodium`
   - `ingredients` — one shopping-list line per item
   - `instructions` — method steps (ingredients can also live at the top of this text,
     matching existing seed recipes)
5. Check each candidate against the rules from step 1 (macro ranges for its likely slot,
   restrictions/dislikes, variety notes). Drop clear misfits; note borderline ones.
6. **Provide two options per meal slot** (e.g. two per night for dinners, two per Day
   A / Day B for breakfast or lunch) rather than a single pick — source two distinct
   candidates for each slot so the user has a real choice. If a slot is a fixed staple
   (e.g. the Sunday salmon bake) that isn't being replaced, skip it entirely rather than
   forcing two options.
7. Write all surviving candidates to `meal-ideas-candidates.md` in the repo root,
   **overwriting** any previous run, using the template in [reference.md](reference.md).
   Group by slot with lettered options (1a/1b, 2a/2b, ...) so the user can reply with
   e.g. "add 1a and 2b", "add all the A options", or "add all".
8. Tell the user the file is ready for review — do not touch `index.html` yet.

## Workflow 2: Add approved ideas

Triggered when the user says which candidates to keep (by number/letter like "1a", by
name, or "add all").

1. Read `meal-ideas-candidates.md` and pull the full detail for each approved candidate.
2. For each one, build a `SEED_RECIPES` entry matching this exact shape (see
   `937:950:index.html` for a live example):

   ```js
   {
     id: "seed-<slug-of-name>",
     name: "<name>",
     baseServings: <number>,
     calories: <number>,
     protein: <number>,
     carbs: <number>,
     fat: <number>,
     fibre: <number>,
     sugar: <number>,
     sodium: <number>,
     instructions: `<ingredients + method, matching existing seed style>`,
   },
   ```

   - `id` must be unique and stable: `seed-` + lowercase-hyphenated name (check it
     doesn't collide with an existing id in `SEED_RECIPES`).
   - If any numbers were estimated rather than source-confirmed, say so in the
     `instructions` text (e.g. "Estimated from listed ingredients — tweak if it differs"),
     matching the convention already used in several seed recipes.
3. Append the new entries to the end of the `SEED_RECIPES` array in `index.html` using
   `StrReplace` (insert before the closing `];` of the array). Do not reformat or
   reorder existing entries.
4. Remove the added candidates from `meal-ideas-candidates.md` (leave any not yet
   decided on).
5. Tell the user what was added, and remind them that reloading the planner (and
   hitting Sync first, if they use cross-device sync) will merge the new recipes into
   their library automatically via `mergeSeedRecipes` — no other setup needed.

## Additional resources

- [reference.md](reference.md) — nutrition-estimation cheat sheet and the
  `meal-ideas-candidates.md` template.
