# My CookBook — iOS deployment guide

This folder wraps your existing `cookbook.html` web app in a [Capacitor](https://capacitorjs.com/) shell and builds it as a real iOS app via [Codemagic](https://codemagic.io/).

Your 2015 MacBook Pro never has to compile anything. All the iOS build work happens on Codemagic's Mac cloud.

---

## What's in this folder

```
my-cookbook-ios/
├── www/index.html        ← your existing app (copied from cookbook-fresh.html)
├── package.json          ← Node dependencies (Capacitor)
├── capacitor.config.json ← app name, bundle ID, web folder
├── codemagic.yaml        ← build instructions for Codemagic
├── .gitignore
└── README.md             ← this file
```

When Codemagic runs, it adds an `ios/` folder containing a real Xcode project. You don't need to look at that folder — it's generated.

---

## One-time setup

### 1. Apple Developer Program — $99/year, ~24 hr approval

Go to https://developer.apple.com/programs/ and sign up. You'll need:

- An Apple ID (the one tied to your iPhone is fine)
- A debit/credit card for the $99/year
- Your legal name and address
- Two-factor authentication enabled on your Apple ID

Apple usually approves individual accounts within a day. Until you're approved, you can still develop and run the verification build (see below) — you just can't install on a real device or submit.

### 2. GitHub account + create a repository

- Sign up at https://github.com/ if you don't have an account.
- Create a new repository called `my-cookbook` (or whatever you like). Keep it **Private** unless you want the world to see your recipes.

### 3. Push this folder to your GitHub repo

From your computer, open a terminal/PowerShell in this `my-cookbook-ios` folder and run:

```bash
git init
git add .
git commit -m "Initial Capacitor wrapper"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/my-cookbook.git
git push -u origin main
```

(Replace `YOUR_USERNAME` with your actual GitHub username.)

### 4. Codemagic account + connect repo

- Sign up at https://codemagic.io/ (use "Sign in with GitHub" — it's the smoothest).
- Click **Add application** → select your `my-cookbook` repo.
- Codemagic will detect the `codemagic.yaml` and offer the workflows defined in it.

### 5. Update the bundle ID

The bundle ID is currently set to `com.alex.mycookbook`. This is your app's permanent unique identifier on the App Store and **cannot be changed later** without making it a new app. Pick something you're happy with now.

Common formats:
- `com.YOURLASTNAME.mycookbook`
- `com.YOURDOMAIN.mycookbook` (if you own a domain)
- `com.alex.mycookbook` (the default — fine if you don't have a domain)

To change it, edit two places:
1. `capacitor.config.json` → `"appId": "com.YOU.mycookbook"`
2. `codemagic.yaml` → both occurrences of `com.alex.mycookbook`

Commit and push the changes:
```bash
git add capacitor.config.json codemagic.yaml
git commit -m "Set bundle ID"
git push
```

---

## First build — verify everything works (no Apple Dev needed)

The `ios-unsigned-build` workflow in `codemagic.yaml` builds the app without signing. It's just a sanity check that everything compiles.

In Codemagic:
1. Open your app.
2. Click **Start new build**.
3. Select **iOS unsigned verification build** as the workflow.
4. Click **Start build**.

You should see ~10 minutes of Codemagic running through:
- `npm install` (downloads Capacitor)
- `npx cap add ios` (generates the Xcode project)
- `pod install` (iOS dependencies)
- `xcodebuild` (compiles the app)

If it ends in green ✓ — your app builds. Move on. If it errors out, copy the failing step's log and ping me.

---

## Real build — install on your iPhone/iPad via TestFlight

Once your Apple Developer account is approved, you can do real signed builds and install on your devices via TestFlight (Apple's beta-testing app).

### 6. Register the bundle ID with Apple

At https://developer.apple.com/account/resources/identifiers/list:
- Click **+** → **App IDs** → **App**
- Description: "My CookBook"
- Bundle ID: Explicit → enter the same bundle ID from your `capacitor.config.json`
- Capabilities: leave all unchecked for now
- Click Continue → Register.

### 7. Create the App in App Store Connect

At https://appstoreconnect.apple.com/:
- Click **My Apps** → **+** → **New App**
- Platform: iOS
- Name: "My CookBook"
- Primary Language: English
- Bundle ID: select the one you just registered
- SKU: anything unique, e.g., `my-cookbook-001`
- Click Create.

### 8. Generate App Store Connect API key for Codemagic

This lets Codemagic upload builds on your behalf without storing your Apple password.

In App Store Connect → **Users and Access** → **Integrations** tab → **App Store Connect API**:
- Click **+** to create a key
- Name: "Codemagic"
- Access: **App Manager**
- Click Generate.
- **Download the .p8 file immediately** — Apple only lets you download it once.
- Note the **Issuer ID** and **Key ID** shown on the page.

### 9. Connect the API key to Codemagic

In Codemagic, go to **Teams** (top right) → your team → **Integrations** → **App Store Connect**:
- Click **Add key**
- Name: anything (e.g., "codemagic")
- Issuer ID: paste from step 8
- Key ID: paste from step 8
- API Key (.p8 file): upload the file you downloaded

### 10. Enable automatic code signing

Back in your Codemagic app settings, go to **iOS code signing**:
- Choose **Automatic**
- Select the App Store Connect integration you just created
- Bundle identifier: same as your `capacitor.config.json`
- Distribution type: **App Store**

### 11. Run the signed build

Start a new build, this time picking the **`iOS signed build + TestFlight upload`** workflow. It will:
- Build your app
- Sign it with your Apple certificate (fetched automatically)
- Increment the build number
- Upload to TestFlight

### 12. Install on your iPhone/iPad

- Install Apple's **TestFlight** app from the App Store on your iPhone/iPad.
- Sign in with the same Apple ID as your developer account.
- After TestFlight finishes processing the build (usually 10–30 minutes after upload), you'll see "My CookBook" appear.
- Tap **Install**.

That's it — your web app is now a real iOS app on your home screen.

---

## Making changes later

Workflow once everything's set up:

1. Edit `www/index.html` (it's the same as your existing `cookbook.html`).
2. Commit and push to GitHub:
   ```bash
   git add www/index.html
   git commit -m "Add new feature"
   git push
   ```
3. Codemagic auto-builds and uploads to TestFlight.
4. Open TestFlight on your device → tap **Update**.

Roughly 15 minutes from push to installed update.

---

## Submitting to the public App Store

When you're ready to publish (not just TestFlight):

1. In App Store Connect, fill out the app's metadata (screenshots, description, keywords, age rating, privacy policy URL).
2. Submit the latest build for review.
3. Apple usually reviews in 24–48 hours.

Note: Apple requires a privacy policy URL even for apps that don't collect data. You can use a free generator like https://app-privacy-policy-generator.firebaseapp.com/ and host it on GitHub Pages or your own site.

---

## Costs summary

| Item | Cost | Notes |
|---|---|---|
| Apple Developer Program | $99/year | Required for App Store + TestFlight |
| GitHub | Free | Private repos included |
| Codemagic | Free | 500 build minutes/month; iOS build ~10 min |
| Codemagic (paid) | ~$28+/mo | Only if you exceed 500 min/month |

For a personal app you build occasionally, you should never need the paid Codemagic tier.

---

## Troubleshooting

**"Build failed — pod install error"**: Usually transient. Re-run the build. If persistent, the CocoaPods cache might be stale — toggle off caching in `codemagic.yaml` temporarily.

**"Code signing error"**: Make sure the bundle ID in `capacitor.config.json`, `codemagic.yaml`, your Apple Developer registered App ID, and your App Store Connect app all match exactly.

**App opens to blank screen on device**: The `webDir` setting in `capacitor.config.json` is `www`. Make sure your latest `index.html` is in `www/` and you ran `npx cap sync` (Codemagic does this automatically).

**Want to update the cookbook HTML**: just overwrite `www/index.html` with your latest version, commit, push.
