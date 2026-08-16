# Meal plan builder — setup

The Meal Plan page can fill your whole week for you. You describe what you're
after ("low fat, high fiber, nothing fiddly midweek"), and it plans the meals,
works out which nights are leftovers, and builds the shopping list.

**Every recipe comes from Spoonacular** — the same database behind the Home
tab's daily pick and search. They're real, tested recipes with a link back to
the original site. Nothing is invented.

There are two keys involved, and only the first is required.

---

## Spoonacular — required

You already have this set up in `spoonacular-config.js`. If the Meal Plan page
says it needs a Spoonacular key, see SPOONACULAR-SETUP.md.

**Quota.** The free tier is 150 points per day. A generated week costs roughly
3–10 points depending on how many meal slots you're planning, so you have
plenty of headroom — but "Start over" spends more, while "Refine" is free
because it just rearranges recipes already fetched. If you exhaust it, the app
says so plainly and the quota resets at midnight UTC.

---

## OpenAI — optional, but it's what makes the brief work

Without an OpenAI key the planner still works. It reads common phrases straight
out of your notes — "low fat", "vegetarian", "high fiber", "quick", cuisine
names, and anything in the avoid box — maps them onto Spoonacular's filters,
and fills the week by rotation, repeating anything that makes enough for a
second night.

With a key, it does two jobs, and **neither of them is writing recipes**:

1. **Reads your brief properly** and turns it into search filters. "Low fat and
   high fiber, nothing over 30 minutes midweek but a proper roast on Sunday"
   becomes real `maxFat` / `minFiber` / `maxReadyTime` searches — including
   separate searches for the midweek meals and the weekend one.
2. **Chooses which of the returned recipes goes where**, balancing the week so
   you're not eating chicken four nights running, and working out the leftover
   chains based on what each recipe actually yields.

It can only pick from the recipes Spoonacular returned. If it tries to invent
one, the app throws it out.

### Getting a key

1. Go to **https://platform.openai.com/api-keys** and sign in.
2. Add a little credit at
   **https://platform.openai.com/settings/organization/billing** — a couple of
   dollars lasts a very long time here. A ChatGPT Plus subscription does *not*
   cover API usage; they're billed separately.
3. **Create new secret key**, name it `Stir Crazy`, and copy it. It starts with
   `sk-` and you only get to see it once.
4. Paste it into `ai-config.js`:

```js
window.AI_CONFIG = {
  apiKey: "sk-your-actual-key-here",
  model: "gpt-4o-mini",
  baseUrl: "https://api.openai.com/v1"
};
```

Then push and wait a minute or two for GitHub Pages.

### Cost

Both calls are small — the model reads a list of recipe titles and nutrition
figures, it doesn't write any recipe text. A generated week is well under a
tenth of a cent on `gpt-4o-mini`, and about a cent on `gpt-4o`. If plans feel
like they're not reading your brief carefully enough, switching `model` to
`"gpt-4o"` is the single biggest lever.

### About the key being in the app

`ai-config.js` is part of the front-end, so anyone who can load the app can read
the key — and because the repo is public, automated scanners will find it too.
**OpenAI revokes keys it finds in public repositories, usually within minutes.**

So before you paste a real key in, deal with that. The options, briefly:

- **A Cloudflare Worker proxy** (free) holds the key server-side; `ai-config.js`
  then only contains your Worker's URL, which is harmless.
- **Make the repo private** — but GitHub Pages then needs GitHub Pro.
- **A Firebase Cloud Function** proxy, which needs the Blaze plan.

Either way, set a monthly hard cap at
https://platform.openai.com/settings/organization/limits.

---

## Using it

Open **Meal Plan** → **Generate this week with AI**.

- **The brief** is the important bit. Plain English, be specific. The tag
  buttons underneath are just shortcuts for typing common phrases into it.
- **How many people** decides portion sizes and whether a recipe yields enough
  for a leftover night.
- **Leftovers** controls how hard it leans on batch cooking. On "lots" it
  favours big-yield recipes and stretches them across two or three sittings.
- **Which meals** — leave it on dinner unless you actually want breakfast
  planned too. Each extra slot is another search against your quota.
- **Anything to avoid** is split automatically: real allergens (shellfish,
  dairy, gluten, peanut, and so on) become Spoonacular *intolerance* filters,
  which are stricter; everything else becomes an excluded ingredient.

You get a preview before anything is saved, showing each meal with its cook
time, calories, fat and fiber per serving. **Refine** ("swap Tuesday for
something vegetarian") rearranges the same recipes without touching your
Spoonacular quota. **Start over** runs fresh searches.

**Add to my week** saves the recipes into your collection, fills the grid, and
rebuilds the shopping list.

### When the brief is too narrow

If a search comes back with nothing, the app loosens it one constraint at a
time — time limit first, then protein and calorie targets, then cuisine, then
the fat and fiber targets — and tells you in the preview exactly what it had to
let go of. If it still can't fill every slot, those slots are left empty rather
than filled with something that doesn't fit. Fill them by hand, or widen the
brief.

### Leftovers and the shopping list

Leftover nights show with a striped background and a LEFTOVERS tag. They add
nothing to the shopping list, because those ingredients were bought for the
night the dish was actually cooked.

Quantities are scaled to the portions you're actually cooking and rounded the
way you'd buy them — two-thirds of an onion becomes one onion, 166g of mince
becomes 170g. The list groups itself by aisle using Spoonacular's own
categories.

---

## When something goes wrong

**"Spoonacular's daily quota is used up"** — resets at midnight UTC.

**"Spoonacular rejected the key"** — check `spoonacular-config.js`.

**"OpenAI rejected the API key"** — wrong, truncated, or auto-revoked because it
was found in the public repo. See the section above.

**"You're out of quota"** (OpenAI) — you need credit on the account. ChatGPT
Plus doesn't count.

**"Spoonacular didn't have anything matching"** — the brief is too restrictive
even after loosening. Try dropping something from the avoid list.

**The panel still says setup is needed** — cached copy. Pull to refresh once, or
close and reopen the installed app.
