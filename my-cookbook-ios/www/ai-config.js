// ai-config.js
//
// ⚠️  LEAVE THE PLACEHOLDER BELOW ALONE. Do not paste your real key here.
//
// This file is committed to a public GitHub repo. A real OpenAI key put in
// here would be found by automated scanners and revoked by OpenAI within
// minutes — and would be readable by anyone in the meantime.
//
// Where the real key actually lives:
//
//   iOS app  — an encrypted Codemagic environment variable (OPENAI_API_KEY,
//              in the "ai_credentials" group). The build overwrites this file
//              with the real one before packaging. See AI-SETUP.md.
//
//   Web app  — nowhere. GitHub Pages serves straight from the repo, so there
//              is no safe place to put it. The web version therefore runs
//              without AI, which is fine: the meal planner still works from
//              Spoonacular alone. It reads "low fat", "vegetarian", "quick"
//              and so on out of your notes and plans the week from those.
//
// If you later want AI on the web version too, the answer is a proxy that
// holds the key server-side (a free Cloudflare Worker is the usual choice) —
// see the "About the key" section of AI-SETUP.md.
//
// To try a real key locally without risking a commit, run:
//     git update-index --skip-worktree ai-config.js
// ...then edit freely. Undo it with --no-skip-worktree.

window.AI_CONFIG = {
  apiKey: "PASTE_YOUR_OPENAI_API_KEY_HERE",

  // Which model reads your brief and arranges the week. It never writes
  // recipes — those always come from Spoonacular.
  //   gpt-4o-mini  — the default. Well under a tenth of a cent per plan.
  //   gpt-4o       — reads a complicated brief more carefully. About a cent.
  // Override for the iOS build with an OPENAI_MODEL variable in Codemagic.
  model: "gpt-4o-mini",

  // Leave this alone unless you're pointing at a proxy.
  baseUrl: "https://api.openai.com/v1"
};
