# My CookBook — Recipe discovery setup (Spoonacular)

This guide turns on the **Home** tab's "today's pick" and recipe search. It pulls real recipes from real cooking sites (Bon Appétit, AllRecipes, Food Network, Serious Eats, and many more) via the Spoonacular API.

Setup time: about 2 minutes. Free forever for personal use.

---

## What you'll do

1. Sign up at spoonacular.com (free, no credit card)
2. Copy your API key
3. Paste it into `spoonacular-config.js`
4. Push to GitHub

The free tier gives 150 API points per day. Each search uses ~1-2 points, each save uses 1 point. For one person browsing recipes day-to-day, you'll use 5-20 points on a busy day. You will never hit the limit.

---

## Step-by-step

### 1. Sign up

1. Go to https://spoonacular.com/food-api/console#Dashboard
2. Click **Sign Up** (top right).
3. Use any email + password. No payment info needed.
4. Verify your email if asked.

### 2. Find your API key

After logging in, you'll land on the dashboard:

1. Look for **My Console** or **Profile** in the top nav, then **API Keys** in the sidebar.
2. Or go directly: https://spoonacular.com/food-api/console#Profile
3. Your **API Key** is a long string like `abc123def456ghi789...`. Copy it.

### 3. Paste into config

Open `spoonacular-config.js` in your CookBook folder. Replace the placeholder with your real key:

```js
window.SPOONACULAR_CONFIG = {
  apiKey: "your_actual_key_here_pasted_in"
};
```

Save the file.

### 4. Push to GitHub

In PowerShell from your CookBook folder:

```
powershell -ExecutionPolicy Bypass -File .\push-firebase.ps1
```

(The script name says "firebase" but it just commits and pushes whatever's changed.)

Wait 1-3 minutes for GitHub Pages to rebuild. Open the app on your phone. The Home tab now shows a daily pick + search.

---

## How it works day to day

**Home tab opens to:**
- "Today's pick" — a random recipe pulled once per day and cached locally. Same recipe shows all day, then refreshes the next morning.
- Search box — type something like "chicken pasta" or "vegetarian lasagna" and tap Search. Up to 12 results appear as cards.

**Each result card has:**
- Image, title, source publication, prep time
- **Save** button — adds to your recipe book (and syncs via Firebase if you're in a household)
- **Open** button — opens the original recipe on the source site

**What gets saved:**
When you tap Save, the full recipe (ingredients, steps, image, source URL, prep/cook times) is pulled from Spoonacular and added to your collection in localStorage, exactly like a recipe you imported from a URL or typed manually.

---

## Costs

**Spoonacular free tier:** 150 points per day. Resets at midnight UTC.

Typical usage:
- 1 daily pick: 1 point
- 5 searches with 12 results each: ~10 points
- 3 recipes saved: 3 points

That's ~14 points on a heavy cooking day. You'd need to do about 50 searches AND save 50 recipes in one day to hit the limit. Effectively unlimited for personal use.

If you do somehow hit the limit, search will show "Couldn't fetch — try again tomorrow" until midnight UTC. The app keeps working — just no new discoveries until the limit resets.

---

## Troubleshooting

**"Set up recipe discovery to see today's pick"** in the Home tab: your `spoonacular-config.js` still has the placeholder. Paste in your real key.

**"Search failed. Try again."**: usually a temporary connection issue. Try again in a minute. If it persists, check that your API key is correct in the Spoonacular dashboard.

**"Daily quota exceeded"**: you hit 150 points. Comes back at midnight UTC.

**Want to switch APIs later?** No problem — the discover features are in their own JS block, and switching to a different recipe API only means swapping the URLs and the response-shape mapper. Tell me if/when you want to.
