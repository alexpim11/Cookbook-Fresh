# Accounts setup — email/password + Sign in with Apple

The app now uses real Firebase accounts instead of anonymous sessions. This guide covers the one-time console configuration. The code is already done — nothing here requires editing files.

What changed in the app:

- The header button now says **Sign in**. From there you can create an account with email + password, or use **Sign in with Apple**.
- Households live under your account. Inside the modal you can create a household, join with an 8-char code, or **invite someone by email** — they'll see the invite in the app after signing in with that email and can accept or decline.
- Your existing household: the first time you sign in on a device that was already in a household, the app automatically claims that household for your new account. Do this on your phone before clearing anything.

---

## 1. Firebase console — enable sign-in methods (5 min)

1. Go to https://console.firebase.google.com/ → project **cookbook-83ff4** → **Build → Authentication → Sign-in method**.
2. Enable **Email/Password** (just the first toggle; "Email link" can stay off).
3. **Disable Anonymous** (it was used by the old version; the new security rules reject it anyway).
4. Leave the **Apple** provider for step 3 below — it needs Apple Developer setup first.

## 2. Firebase console — update Firestore rules (2 min)

1. **Build → Firestore Database → Rules**.
2. Replace everything with the contents of `firestore.rules` (in this repo) and click **Publish**.

After publishing, the old anonymous-auth app version can no longer write. Make sure both phones get the new app version (the service worker auto-updates on next launch).

## 3. Apple Developer — Sign in with Apple (15 min)

You need this for both the iOS app and Apple login on the web/PWA.

### 3a. App ID (for the iOS app)

1. Go to https://developer.apple.com/account/resources/identifiers/list.
2. Open (or create) the App ID **com.alex.mycookbook**.
3. Check the **Sign In with Apple** capability → Save.
   (If Codemagic created the App ID for you, you still need to toggle this manually.)

### 3b. Services ID (for web/PWA login)

1. Same page → **+** → **Services IDs** → e.g. `com.alex.mycookbook.web`.
2. After creating it, open it, enable **Sign In with Apple**, click **Configure**:
   - Primary App ID: `com.alex.mycookbook`
   - Domains: `cookbook-83ff4.firebaseapp.com`
   - Return URLs: `https://cookbook-83ff4.firebaseapp.com/__/auth/handler`
3. Save.

### 3c. Key

1. **Keys** → **+** → name it (e.g. "CookBook Apple Auth"), check **Sign in with Apple**, configure it with the primary App ID `com.alex.mycookbook`.
2. Download the `.p8` file (only downloadable once) and note the **Key ID** and your **Team ID** (top-right of the developer site).

### 3d. Connect to Firebase

1. Firebase console → **Authentication → Sign-in method** → **Apple** → Enable.
2. Services ID: `com.alex.mycookbook.web`; fill in Team ID, Key ID, and paste the `.p8` contents. Save.

### 3e. PWA domain

If the PWA is served from a domain other than `cookbook-83ff4.firebaseapp.com` (e.g. GitHub Pages), add that domain under **Authentication → Settings → Authorized domains**, and also add it to the Services ID's domain list in 3b.

## 4. iOS app

Everything is already wired up in `my-cookbook-ios/`:

- `www/index.html` is now the same app as the PWA (it was an outdated copy).
- `www/firebase-config.js` + `www/spoonacular-config.js` were added (the app loads them).
- `package.json` gained `@capacitor-community/apple-sign-in`.
- `codemagic.yaml`'s signed workflow now writes the Sign in with Apple entitlement before building.

Building locally instead of CI: `npm install && npx cap sync ios && npx cap open ios`, then in Xcode add the **Sign In with Apple** capability under Signing & Capabilities (CI does this via the entitlements step).

On iOS the app uses the native Apple sheet (via the Capacitor plugin) and hands the token to Firebase — same account either way, so you can sign in with Apple on your phone and with the same Apple account on the web.

## How invites work (no email is actually sent)

Inviting `person@example.com` writes an invite record to Firestore. Nothing is emailed — when that person signs in to the app **with that exact email**, the invite appears in their Account modal with Accept/Decline buttons. Two things to know:

- Tell the person which email you invited, since they must sign in with it.
- If they use Sign in with Apple with "Hide My Email", their account's email is a `@privaterelay.appleid.com` address, so an invite to their real address won't match. In that case just share the household code instead — codes always work.

## Security notes

- The household code is the key: any signed-in user who types a valid code can join that household. Codes are 8 chars from a 32-char alphabet (~1.1 trillion combinations), so guessing is impractical, but treat the code like a house key.
- Members can see each other's name and sign-in email in the member list.
- `FIREBASE-SETUP.md` is now partly outdated (anonymous auth, old rules) — this file supersedes those sections.
