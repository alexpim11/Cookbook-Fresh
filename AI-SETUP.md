# AI meal plans — setup

The Meal Plan page can write your whole week for you: you describe what you're
after ("low fat, high fiber, something quick on Thursday"), it plans the meals,
writes the recipes, works out which nights are leftovers, and hands you the
shopping list.

That needs an OpenAI API key. It's about three minutes to set up, and it stays
set up.

---

## 1. Get a key

1. Go to **https://platform.openai.com/api-keys** and sign in (or sign up).
2. If you've never used the API before, add a little credit first at
   **https://platform.openai.com/settings/organization/billing** — $5 goes a
   very long way here. A ChatGPT Plus subscription does *not* cover API usage;
   they're billed separately.
3. Click **Create new secret key**. Name it something like `Stir Crazy` so you
   can tell it apart later.
4. Copy the key. It starts with `sk-`. **You only get to see it once** — if you
   lose it, delete that key and make another.

## 2. Paste it in

Open `ai-config.js` and replace the placeholder:

```js
window.AI_CONFIG = {
  apiKey: "sk-your-actual-key-here",
  model: "gpt-4o-mini",
  baseUrl: "https://api.openai.com/v1"
};
```

Save, then push the same way you push everything else:

```powershell
cd "C:\Users\h22alex\Documents\Claude\Projects\CookBook"
powershell -ExecutionPolicy Bypass -File .\push-mobile.ps1
```

Give GitHub Pages a minute or two, then open the app and go to **Meal Plan**.
The "Generate this week with AI" panel should now have an active button instead
of a setup notice.

---

## About the key being in the app

This key sits in the app's front-end code, which means anyone who can load the
app can read it. For a personal household app that's a reasonable trade — it's
the same arrangement as the Spoonacular key. But do two things to keep it boring:

- **Set a spend limit.** At
  https://platform.openai.com/settings/organization/limits, set a monthly hard
  cap. Something like $5 means the worst case is $5.
- **Use a dedicated key**, so if you ever need to revoke it you're not breaking
  anything else.

If you'd rather the key never left a server, the alternative is a Firebase
Cloud Function that proxies the request — that needs the Blaze plan and a
separate deploy step, so it wasn't worth it for a household app.

---

## What it costs

Roughly, per week generated:

| Model | Cost per generation |
|---|---|
| `gpt-4o-mini` (default) | about a fifth of a cent |
| `gpt-4o` | about 5–8 cents |

Planning a week of dinners is one request. Planning breakfast, lunch and dinner
is a bigger one. Each "Refine" is another request.

If the plans feel a bit generic or it isn't respecting your brief closely
enough, change `model` in `ai-config.js` to `"gpt-4o"`. That's the single
biggest quality lever, and even at 8 cents a week it's not going to hurt.

---

## Using it

Open **Meal Plan** → **Generate this week with AI**.

- **The brief** is the important bit. Plain English, be specific. "Low fat and
  high fiber. Nothing fiddly midweek — Thursday needs to be on the table in 20
  minutes. A proper roast on Sunday." The tag buttons underneath are just
  shortcuts for typing common things into it.
- **How many people** scales the recipes.
- **Leftovers** controls how hard it leans on batch cooking. On "lots" it'll
  deliberately cook a big pot on Sunday and spread it across two or three
  meals.
- **Which meals** — leave it on dinner only unless you actually want it
  planning breakfast too. Planning all three is a much bigger request.
- **Anything to avoid** is treated as a hard rule and checked against every
  ingredient.

You get a preview before anything is saved. If it's close but not right, type a
correction into the refine box ("swap Tuesday for something vegetarian", "the
Sunday one is too much work") and it'll redo the whole plan with that in mind.

**Add to my week** then saves the recipes into your collection, fills the grid,
and adds the shopping to your list grouped by aisle.

Leftover nights show with a striped background and a LEFTOVERS tag. They don't
add anything to the shopping list, because those ingredients were already
bought for the night the dish was actually cooked.

---

## When something goes wrong

**"OpenAI rejected the API key"** — the key is wrong, expired, or got truncated
when you pasted it. Make a fresh one.

**"You're out of quota"** — you need credit on the account. Having ChatGPT Plus
doesn't count; the API bills separately.

**"The model isn't available on your account"** — newer models sometimes need a
bit of billing history. Put `"gpt-4o-mini"` in `ai-config.js`.

**"The reply got cut off"** — you asked for too much at once. Plan fewer meal
slots, or switch to a model with more room.

**The panel still says setup is needed** — the browser is serving you a cached
copy. Pull to refresh once, or close and reopen the installed app.

---

## A word on the recipes

These are written by a language model, not tested in a kitchen. They're
generally sensible, but read one through before you commit to cooking it —
particularly quantities, and particularly if anyone eating has an allergy.
Recipes it wrote are marked with an "✨ Written by AI" badge on the recipe page
so you can tell them apart from ones you imported. They're ordinary recipes
once saved, so you can edit anything that looks off.
