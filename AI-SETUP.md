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

### Where the key lives

**Not in `ai-config.js`.** That file is committed to a public repo, and OpenAI's
scanners revoke keys they find in public repositories — usually within minutes.
Leave the placeholder in it alone.

Instead:

| | Gets AI? | Key stored where |
|---|---|---|
| **iOS app** (Codemagic → TestFlight) | Yes | Encrypted Codemagic variable, written into the bundle at build time |
| **Web app** (GitHub Pages) | No | Nowhere — Pages serves straight from the repo, so there's no safe place |

The web version is not broken by this. It plans from Spoonacular alone, reading
"low fat", "vegetarian", "quick", cuisine names and your avoid list out of the
form and your notes. You just don't get the careful reading of a long free-text
brief there.

### Getting a key

1. Go to **https://platform.openai.com/api-keys** and sign in.
2. Add a little credit at
   **https://platform.openai.com/settings/organization/billing** — a couple of
   dollars lasts a very long time here. A ChatGPT Plus subscription does *not*
   cover API usage; they're billed separately.
3. Set a monthly hard cap at
   **https://platform.openai.com/settings/organization/limits**. $5 means the
   worst case is $5.
4. **Create new secret key**, name it `Stir Crazy iOS`, and copy it. It starts
   with `sk-` and you only get to see it once.

### Putting it into Codemagic

1. Open your app in Codemagic → **Settings** → **Environment variables**.
2. Add:
   - **Variable name:** `OPENAI_API_KEY`
   - **Value:** your `sk-...` key
   - **Group:** `ai_credentials`  ← type this exactly; `codemagic.yaml` expects it
   - **Secure:** ticked (this is what keeps it out of build logs)
3. Optionally add `OPENAI_MODEL` to the same group with the value `gpt-4o` if
   you want the better model on iOS. Default is `gpt-4o-mini`.
4. Click **Add**, then run a build.

`codemagic.yaml` has a step called *"Inject OpenAI key for the meal planner"*
that runs before `cap sync`. It writes the real `ai-config.js` into `www/` so it
gets copied into the app bundle. If the variable isn't set, the step says so and
the build carries on without it — nothing breaks.

Nothing needs to change on your machine, and nothing needs to be gitignored:
the real key never exists locally, so it can't be committed by accident.

### Cost

Both calls are small — the model reads a list of recipe titles and nutrition
figures, it doesn't write any recipe text. A generated week is well under a
tenth of a cent on `gpt-4o-mini`, and about a cent on `gpt-4o`.

### What this does and doesn't protect

**Does:** keeps the key out of GitHub, so it won't be scanned and auto-revoked,
and won't be visible to anyone browsing the repo.

**Doesn't:** make the key secret from someone holding the app. An `.ipa` is a
zip file, and the key sits in plain-text JavaScript inside it. Anyone
determined enough to unpack a TestFlight build can read it. For a household app
that's a fair trade — the spend cap is your real protection.

If you ever want it genuinely secret, and AI working on the web version too,
the answer is a proxy holding the key server-side: a free **Cloudflare Worker**
is the usual choice, and `ai-config.js` would then contain only the Worker's
URL, which is harmless to commit.

### One iOS gotcha to watch on the first build

The app calls OpenAI from inside a WKWebView. If the web version works but the
iPhone app says *"Couldn't reach OpenAI from inside the app"*, the request is
being blocked in the WebView rather than failing on the network. The fix is to
route requests through native code by adding this to
`my-cookbook-ios/capacitor.config.json`:

```json
"plugins": { "CapacitorHttp": { "enabled": true } }
```

Only do this if you actually hit the problem — it changes how *every* network
request in the app is made, including Firebase sync and the recipe importer, so
it's worth re-testing those afterwards.

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
