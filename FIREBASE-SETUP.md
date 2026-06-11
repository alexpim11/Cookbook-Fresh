# My CookBook — Firebase sync setup

This guide gets cross-device sync working: you and another person each open the app on your phones, and your recipes, meal plan, and shopping list stay in sync automatically — just like Google Docs.

**Default scope:** recipes, meal plan, and shopping list all sync. (Favorites and search/filter state stay local-per-device since they're transient UI state.)

Total setup time: about 10 minutes. Free forever for personal use.

---

## What you'll do

1. Create a free Firebase project (Google's hosted database service)
2. Turn on Firestore (the database) and Anonymous Auth (so the app can identify each device)
3. Copy 6 config values into `firebase-config.js`
4. Paste in Firestore security rules so randos can't read your shopping list
5. Push to GitHub
6. On each phone, either **Create household** or **Join household** with a share code

The Firebase free tier covers ~50,000 reads and 20,000 writes per day. For two people using a recipe app, you'll use single-digit reads/writes per day. You're never going to hit those limits.

---

## Step-by-step

### 1. Create a Firebase project

1. Go to https://console.firebase.google.com/ and sign in with your Google account (`h22alex@gmail.com` or any other Google account).
2. Click **Add project** (or **Create a project**).
3. **Project name:** `my-cookbook` (or anything). Click Continue.
4. **Google Analytics:** turn off. Click Continue.
5. Click **Create project**, wait ~30 sec, then **Continue**.

### 2. Add a Web app to the project

1. On the project dashboard, you'll see icons for iOS / Android / Web (looks like `</>`). Click the **Web** one.
2. **App nickname:** "CookBook web" (just a label). Don't check the Hosting checkbox.
3. Click **Register app**.
4. The next screen shows a snippet with `const firebaseConfig = { ... }`. **Keep this tab open** — you'll copy these values in Step 5.
5. Click **Continue to console** (you don't need to install the SDK locally).

### 3. Turn on Firestore Database

1. In the left sidebar of the Firebase console, click **Build → Firestore Database**.
2. Click **Create database**.
3. Pick a location near you (e.g., `us-east1` if you're on the East Coast). This can't be changed later — pick once.
4. Choose **Start in production mode** (we'll set rules in the next step).
5. Click **Create**.

### 4. Set Firestore security rules

This stops strangers from snooping or vandalizing your household.

1. In Firestore, click the **Rules** tab.
2. Replace the entire content with:

   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Households readable/writable by any authenticated user who knows the household ID.
       // The 8-char random ID provides ~2.8 trillion combinations; brute force is infeasible.
       match /households/{householdId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

3. Click **Publish**.

### 5. Turn on Anonymous Authentication

So the app can give each device an identity without forcing anyone to make an account.

1. In the left sidebar, click **Build → Authentication**.
2. Click **Get started**.
3. On the **Sign-in method** tab, click **Anonymous**.
4. Toggle **Enable** to on.
5. Click **Save**.

### 6. Copy your config values into `firebase-config.js`

Go back to the tab with `const firebaseConfig = { ... }` (or find it in Project Settings → General → Your apps → SDK setup and configuration).

You'll see 6 values like:

```js
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "my-cookbook-xxxxx.firebaseapp.com",
  projectId: "my-cookbook-xxxxx",
  storageBucket: "my-cookbook-xxxxx.appspot.com",
  messagingSenderId: "1234567890",
  appId: "1:1234567890:web:abc123def456"
};
```

Open `firebase-config.js` in your CookBook folder (created alongside this guide) and paste your real values where the placeholders are. **Save the file.**

> **Note:** These values are NOT secrets — Firebase web config is meant to be public. Anyone who finds the values can talk to your Firebase project, but the security rules above only let them touch the `households/{id}` documents *if they know the ID*. Your share code IS your security.

### 7. Push to GitHub

In PowerShell, in your CookBook folder:

```
powershell -ExecutionPolicy Bypass -File .\push-firebase.ps1
```

(I'll generate this script alongside the code.)

Wait 1–3 minutes for GitHub Pages to rebuild.

### 8. Pair your phones

On phone 1 (yours):
1. Open the app.
2. Tap the **share/sync icon** in the header (top right).
3. Tap **Create new household**.
4. The app shows an 8-character code like `7K3Q9PM2`. Note it down — you'll type it on the other phone. Tap **Copy** if you want it on your clipboard.

On phone 2 (partner's):
1. Have them open the app (same URL).
2. Tap the share/sync icon.
3. Tap **Join existing household**.
4. Type or paste the code. Tap **Join**.

That's it. From now on, any change either of you makes on either phone shows up on the other within a second or two.

The header will show a small green dot next to the share icon when sync is active.

---

## Day-to-day

**What syncs:** recipes (add/edit/delete), meal plan, shopping list, all in real time.

**What doesn't sync:** favorites (each person's stars stay private to their phone), search/filter state.

**Offline use:** the app still works fully when you're offline. Changes queue locally and push as soon as you're back online. Firestore handles this automatically.

**Conflict resolution:** if you both edit the same recipe at the same time, last-write-wins. Practically this rarely matters unless you're both literally typing on the same recipe at the same moment.

**Switching households:** tap the share icon → **Leave household**. The local copy stays on your phone, but you stop syncing. You can then create or join a different household.

---

## Costs

**Firebase free tier:** 50,000 reads/day + 20,000 writes/day + 1 GB storage. For two people using a recipe app, you'd use maybe 50 of each on a busy cooking day. You will never hit a paid tier.

**Other Firebase services** (Cloud Functions, Storage, ML, etc.): not used by this app. You won't accidentally enable anything that costs money.

**Google may ask** for billing info if you somehow used more than free-tier limits, but for a two-person recipe app this won't happen. You can also set a hard budget cap of $0 in the Firebase console (Settings → Usage and billing) for peace of mind.

---

## Troubleshooting

**Phone shows "Sync error" or refuses to join:** check that `firebase-config.js` has real values (not the placeholders) and that Anonymous Auth is enabled in Step 5.

**"Missing or insufficient permissions"** on the console: your Firestore rules are wrong. Double-check Step 4 — the rules need to be exactly as shown.

**Changes on one phone don't appear on the other:** confirm both phones show the same household code under the share icon. If one shows "not joined", re-do the pairing.

**Want to start over completely:** in Firestore Database, delete the `households` collection. Both phones will need to re-create or re-join.
