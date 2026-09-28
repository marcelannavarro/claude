---
name: feedback-build-regenerates-translations
description: npm run build (and therefore npm run test:max-file-size) regenerates translations/en-*.json and overrides/app/static/translations/compiled/*.json as a side effect — discard before committing unrelated work
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c22bc5c5-f466-47ea-9583-137b87fdbef0
  modified: 2026-09-14T15:29:23.251Z
---

Running `npm run build` locally runs a `build-translations` step first (extract-default-messages
→ compile-folder → compile-pseudo), which rewrites `translations/en-US.json`, `translations/en-GB.json`,
and every file under `overrides/app/static/translations/compiled/` — picking up any `defaultMessage`/`id`
react-intl strings added by recent merges that were never re-extracted and committed. This happens
on *every* local build, not just the first one.

**Why:** discovered while verifying an unrelated fix (the Adyen vendor.js bundle-size regression,
2026-09-14) — `npm run build` (called internally by `npm run test:max-file-size`) left 6 translation
files showing as modified in `git status`, despite the fix touching only `webpack.config.js` and
`package.json`. These files are Tier 2 ("Translations", Integration/SI-Partner-owned per
[[project-adyen-vendor-bundle-regression]]'s sibling protectedFiles.md) — committing them alongside
unrelated work would silently cross into someone else's ownership domain and bloat the diff with
noise that has nothing to do with the actual change.

**How to apply:** after any local `npm run build`, `npm start` equivalent, or `test:max-file-size`
run, check `git status` before staging anything. If translation files show as modified and the task
at hand isn't actually about translations, discard them (`git checkout -- translations/en-*.json
overrides/app/static/translations/compiled/*.json`) before committing — don't assume a clean-looking
diff just because you only *edited* two files yourself. This will keep happening on every future
local build in this repo; it is not a one-off fluke to investigate further.
