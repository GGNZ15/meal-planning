# Meal ideas — standing rules

This is the standing brief the `find-meal-ideas` skill reads before suggesting new meals.
Edit it any time — it persists across runs, so you don't need to repeat yourself each time you ask for ideas.

## Nutrition guardrails

Daily targets currently set in the live planner: 1800 kcal · 150g protein · 165g carbs · 60g fat · 30g fibre · 45g sugar · 2000mg sodium.

(Note: these differ from the defaults still hardcoded in `index.html`'s `defaultState`
— that's just the fallback used for a brand-new browser with no saved plan yet, and
doesn't need to match. The numbers above are the real, current ones to plan against.)

Rough per-meal ranges for the adult female's breakfast/lunch (edit to taste — dinners
are scaled separately for the whole family, see Variety notes):

- Breakfast: ~450–600 kcal, 35g+ protein
- Lunch: ~350–500 kcal, 25g+ protein
- Dinner: ~450–600 kcal, 35g+ protein (per adult serve)
- Snack / dessert: ~100–250 kcal

Hard limits (apply to any meal, regardless of slot):
- _(e.g. "no single meal over 1000mg sodium" — add your own)_

## Dietary restrictions / dislikes / must-avoid

- Shellfish — dislike (not a medical allergy); avoid as a main ingredient
- Toddler (2 years old): no known allergies/intolerances. Family dinners should still
  avoid choking hazards (whole grapes, whole nuts, hard raw veg chunks, etc.) or note
  where an ingredient needs cutting/modifying for her portion.

## Favourite creators / sites

List the sites, blogs, or Instagram/TikTok handles you want ideas pulled from. For social accounts, note that captions may need to be pasted in manually rather than fetched.

- https://www.recipetineats.com/
- https://www.bbcgoodfood.com/
- https://vjcooks.com/
- https://www.tamingtwins.com/
- https://www.mybalanceproject.co.nz/
- https://www.instagram.com/_elliewilsonfitness__/ — Instagram; caption/post text will likely need to be pasted in manually
- https://movewithus.com.au/blogs/recipes

## Variety notes

**Household**: 2 adults + 1 toddler (2 years old). The family eats dinner together.
Breakfast and lunch are meal-prepped for the adult female (36) only.

**Dinners** (default: family-friendly, quick and easy, suitable for the toddler to eat
too or easily adapted for her):
- Tuesday: prep-ahead meal (e.g. slow cooker) with enough leftovers to cover Wednesday
  night too — don't suggest a separate Wednesday dinner.
- Thursday: scale to feed 4 adults + 1 toddler.
- Sunday: salmon bake is the standing default — treat as a recurring staple rather
  than something to replace, unless a variation is specifically requested.
- Monday, Friday, Saturday: same default as above (family-friendly, quick and easy) —
  ideas wanted for these too.

**Breakfast & lunch**: for the adult female only. Meal-prep 2 breakfast options and 2
lunch options per week, matching the planner's Day A / Day B structure. Prioritise
meal-prep-friendliness and nutrition (protein-forward) over variety for its own sake.

## Practical constraints

- **Equipment available**: oven, stovetop, slow cooker, air fryer, stand mixer,
  blender / food processor. No Instant Pot / pressure cooker — don't suggest recipes
  that require one.
- **Weeknight time budget**: ~30 minutes prep for dinner, except Tuesday's
  prep-ahead meal (which can take longer since it's low-effort/hands-off, e.g. slow
  cooker).
- **Grocery locale**: shops mainly at Woolworths NZ — favour ingredients realistically
  available there.

## Output preferences

- Always include a clear ingredients list (used for the shopping list) alongside instructions.
- Flag any estimated (vs. source-confirmed) nutrition numbers.
- Prefer recipes that meal-prep well / keep 3+ days in the fridge, unless noted otherwise above.
