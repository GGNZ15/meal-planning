# Reference: nutrition estimation & candidate template

## Estimating nutrition when a source has no macro panel

Use these to build a reasonable per-serve estimate from an ingredients list, then flag
it as estimated in the candidate. Don't spend excessive effort on precision — order-of-
magnitude accuracy that the user can tweak later is fine, matching several existing
seed recipes (e.g. "Estimated from listed ingredients — tweak if your brands differ").

**Energy from macros**: `kcal ≈ protein_g × 4 + carbs_g × 4 + fat_g × 9` (+ alcohol_g × 7
if relevant). Use this to sanity-check a calorie figure against its stated macros —
if they're inconsistent, trust the macros and recompute calories.

**Common per-100g rough references** (kcal / P / C / F):
- Chicken breast, cooked: 165 / 31 / 0 / 3.6
- Lean beef mince, cooked: 215 / 27 / 0 / 11
- Salmon, cooked: 208 / 22 / 0 / 13
- Eggs (whole): 143 / 13 / 1 / 10 (per 100g ≈ 2 large eggs)
- Greek yoghurt (plain, standard): 97 / 9 / 4 / 5
- Cottage cheese: 98 / 11 / 3 / 4
- Cooked rice (white): 130 / 2.7 / 28 / 0.3
- Cooked rice (brown): 123 / 2.7 / 26 / 1
- Dry pasta/noodles (cooked): ~150 / 5 / 30 / 1
- Oats (dry): 389 / 17 / 66 / 7
- Mixed vegetables (non-starchy): 25–40 / 2 / 5 / 0.3
- Olive oil / cooking oil: 884 / 0 / 0 / 100 (1 tbsp ≈ 14g ≈ 120 kcal)
- Peanut butter: 588 / 25 / 20 / 50
- Cheese (cheddar-style): 400 / 25 / 1 / 33

Scale each ingredient by its gram weight in the recipe, sum, divide by number of
servings. For fibre/sugar/sodium, estimate from the same ingredient list where
plausible (e.g. legumes/veg for fibre, sauces/cured meats/cheese for sodium) or leave
at a conservative low estimate and flag it clearly rather than guessing wildly.

## `meal-ideas-candidates.md` template

Use this structure for every "find ideas" run — overwrite the whole file each time.
Group by meal slot (e.g. by night for dinners), with two lettered options per slot so
the user has a real choice:

```markdown
# Meal idea candidates — <date>

Generated from: <sources/creators used this run>
Reply with which to add, e.g. "add 1a and 2b", "add all the A options", "add all".

## 1. <Slot label, e.g. "Monday">

### 1a. <Recipe name>

- Source: <URL or "pasted caption from <creator>">
- Serves: <baseServings>
- Macros (per serve): <cal> kcal · P <g>g · C <g>g · F <g>g · Fibre <g>g · Sugar <g>g · Sodium <mg>mg
  <add "(estimated)" next to any figure that wasn't source-confirmed>
- Fit check: <one line — which rules it satisfies, and any borderline call-outs>
- Ingredients:
  - <item 1>
  - <item 2>
- Instructions:
  1. <step>
  2. <step>

### 1b. <Recipe name>
...same fields as 1a...

## 2. <Slot label, e.g. "Tuesday">

### 2a. <Recipe name>
...
### 2b. <Recipe name>
...
```

Skip the second option only for a slot the user has explicitly marked as a fixed
staple they don't want replaced (e.g. a recurring Sunday meal) — omit that slot from
the file entirely rather than forcing two options on it.

Keep each candidate self-contained so Workflow 2 can lift it straight into a
`SEED_RECIPES` entry without re-fetching anything.
