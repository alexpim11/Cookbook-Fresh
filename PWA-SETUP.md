# My CookBook — PWA setup & install guide

The app is now installable as a Progressive Web App on iPhone, iPad, and Android. To actually install it, you need a public URL (Safari won't install a PWA from a `file:///` URL). The easiest free option is GitHub Pages.

This guide does **not** touch the `my-cookbook-ios/` folder — that stays as your Codemagic/App Store route. The PWA is a separate, free alternative that uses the same `cookbook-fresh.html`.

---

## What's been added

```
CookBook/
├── cookbook-fresh.html      ← your app, now with PWA meta tags + SW registration
├── cookbook.html            ← same patches, kept in sync
├── manifest.json            ← tells iOS / browsers the app name, icons, colors
├── sw.js                    ← service worker (offline support after first visit)
├── icons/
│   ├── icon-120.png
│   ├── icon-152.png
│   ├── icon-167.png
│   ├── icon-180.png
│   ├── icon-192.png
│   ├── icon-512.png
│   ├── icon-maskable-512.png  ← Android adaptive icons
│   └── favicon-32.png
└── my-cookbook-ios/         ← (untouched — your App Store route)
```

Open `cookbook-fresh.html` locally and it works exactly as before. The service worker won't activate (`file://` doesn't allow it), but everything else still works fine. The PWA features kick in once the app is served from a real URL.

---

## Host it on GitHub Pages (~5 minutes, free)

### 1. Create a GitHub account if you don't have one

https://github.com/join — free.

### 2. Create a new repository

- Click the **+** in the top right → **New repository**
- Name: `cookbook` (or anything you like — this becomes part of your URL)
- Set to **Private** if you don't want strangers seeing your recipes, or **Public** if you don't care
- Don't add a README; we already have files to upload
- Click **Create repository**

### 3. Upload the files

The easiest way without learning git: use GitHub's web uploader.

- On your new empty repo page, click **uploading an existing file** (the link in the middle)
- Drag these files and folders from your `CookBook` folder into the upload area:
  - `cookbook-fresh.html`
  - `manifest.json`
  - `sw.js`
  - The entire `icons/` folder
- **Do not upload** `my-cookbook-ios/` — that's for the App Store route, not PWA
- Click **Commit changes** at the bottom

If you'd rather use git from your terminal:
```bash
cd C:\Users\h22alex\Documents\Claude\Projects\CookBook
git init
git add cookbook-fresh.html manifest.json sw.js icons/
git commit -m "Initial PWA"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/cookbook.git
git push -u origin main
```

### 4. Turn on GitHub Pages

- In your repo, click **Settings** (top nav)
- In the left sidebar, click **Pages**
- Under "Source", select **Deploy from a branch**
- Branch: `main`, folder: `/ (root)`
- Click **Save**

GitHub will show you a URL like:
```
https://YOUR_USERNAME.github.io/cookbook/
```

It usually takes 1–2 minutes to go live the first time. You'll see a green checkmark when it's ready.

### 5. Visit the URL to confirm it works

Open the URL in any browser. If you see your CookBook app — done. **Important:** add `/cookbook-fresh.html` to the end of the URL when you visit, or set up a redirect (see "Quality of life" below).

So the full URL is:
```
https://YOUR_USERNAME.github.io/cookbook/cookbook-fresh.html
```

---

## Install on iPhone / iPad

1. Open Safari on your iPhone or iPad (must be Safari — Chrome on iOS doesn't support Add to Home Screen for PWAs).
2. Visit your GitHub Pages URL.
3. Tap the **Share** icon (square with arrow up) at the bottom (iPhone) or top (iPad).
4. Scroll down and tap **Add to Home Screen**.
5. The name will be pre-filled as "My CookBook". Tap **Add** in the top right.

Your home screen now has a CookBook icon. Tap it and the app opens fullscreen — no Safari address bar, no browser chrome. Looks and feels exactly like a native app.

### What works after install

- ✅ All recipes, meal plans, shopping lists save to localStorage and persist
- ✅ Works offline (service worker caches the app shell after first visit)
- ✅ Launches fullscreen with splash screen
- ✅ Has its own app switcher entry
- ✅ Can be installed on Android too (Chrome → menu → "Install app")

### What doesn't work vs native

- Push notifications (iOS 16.4+ supports limited Web Push, but you'd need to add the code)
- Discoverability on the App Store (people have to know your URL)
- iOS-native UI controls (the app uses its own styling, which is fine for this app)

---

## Updating the app later

When you change `cookbook-fresh.html`:

1. Replace it on GitHub (Upload files button on the repo, or `git push`).
2. **Bump the cache version in `sw.js`** — change `'cookbook-v1'` to `'cookbook-v2'`, etc. This forces installed instances to fetch the new version instead of serving the cached one.
3. Upload the updated `sw.js` too.

On users' devices, the new version is picked up the next time they open the app (or within a few minutes of being online).

If you forget to bump the cache version and someone is stuck on the old version, they can force a refresh by deleting the app from their home screen and re-adding it.

---

## Quality-of-life: make the root URL go straight to the app

Right now, visiting `https://YOU.github.io/cookbook/` shows a directory listing or a 404. To make it open the app directly, you have two options.

**Option A — rename the file.** Rename `cookbook-fresh.html` to `index.html`. Then the root URL works. (Update the `start_url` in `manifest.json` to `"./index.html"` and the cache list in `sw.js` to match.)

**Option B — add a redirect.** Create a tiny file called `index.html` in your repo with this content:
```html
<!DOCTYPE html>
<html><head>
<meta http-equiv="refresh" content="0; url=cookbook-fresh.html">
</head></html>
```
Now the root URL auto-redirects to the app.

If you'd like, ask me to do option A — I can update the files in place.

---

## Custom domain (optional, ~$12/year)

If you'd rather have `cookbook.alex.com` than `alex.github.io/cookbook`:

1. Buy a domain from Namecheap, Cloudflare Registrar, or any registrar.
2. In your GitHub Pages settings, add the custom domain.
3. Add a CNAME DNS record at your registrar pointing to `YOUR_USERNAME.github.io`.

Not necessary — the github.io URL works fine for personal use.

---

## Troubleshooting

**"Service worker registered" message but app doesn't work offline.** Service workers cache on the *first* visit. Load the URL once with a network connection, then it'll work offline thereafter.

**Updated the HTML but device still shows the old version.** Bump the cache version in `sw.js` (see "Updating the app later").

**iOS doesn't show "Add to Home Screen" option.** You're not in Safari. Chrome on iOS can't install PWAs — it's an Apple restriction.

**App icon looks blurry on home screen.** Make sure all the icon files uploaded to GitHub (check the `icons/` folder in your repo). iOS picks the closest size match.

**"Can't reach this page" when offline.** First-time offline use requires a successful online visit first (so the SW can cache things). Open the app once with Wi-Fi/cellular, then it'll work offline.
