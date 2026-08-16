// ai-config.js
//
// Paste your OpenAI API key here, then save and push to GitHub.
// See AI-SETUP.md for how to get the key (about 3 minutes).
//
// This key sits in the app's front-end code, which means anyone who can open
// the app can read it. That's fine for a personal / household app, but you
// should:
//   - set a monthly spend limit on the key at platform.openai.com/limits
//   - use a key created just for this app, so you can revoke it on its own
//
// If you leave the placeholder below as-is, the Meal Plan page simply shows a
// "set this up to generate plans" message — the rest of the app still works.

window.AI_CONFIG = {
  apiKey: "PASTE_YOUR_OPENAI_API_KEY_HERE",

  // Which model writes the plan.
  //   gpt-4o-mini  — cheapest, roughly a fifth of a cent per week generated. Good default.
  //   gpt-4o       — noticeably better recipes and more careful about your brief.
  //   gpt-4.1      — also fine if your account has it.
  model: "gpt-4o-mini",

  // Leave this alone unless you're pointing at a compatible proxy.
  baseUrl: "https://api.openai.com/v1"
};
