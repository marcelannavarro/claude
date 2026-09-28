---
name: project-css-bundle-budget-gap
description: No CSS bundle budget exists in CI despite projectState.md claiming main.css < 50 kB — verified 2026-08-14
metadata: 
  node_type: memory
  type: project
  originSessionId: 8cf64a04-ef40-4b49-a79a-32fbb09f6f33
  modified: 2026-08-14T01:25:06.630Z
---

There is **no CSS size budget in CI**. `package.json`'s `bundlesize` array has exactly two
entries — `build/main.js` (180 kB) and `build/vendor.js` (550 kB). Both the Test gate
(`.github/workflows/deploy-test.yml`) and the SIT gate (`.github/workflows/digital-sit.yml`)
run the same `npm run test:max-file-size` → `bundlesize`, so neither gates CSS.

`.docs/memory/projectState.md` (in the CI workflow split bullet) claims the SIT gate enforces
`main.css < 50 kB`. That is wrong — it was never implemented.

**Why:** matters because the design-token work (`feature/design-tokens-implementation-to-dev`)
adds a ~3.9 kB `:root` custom-property block plus 36 `.zimm-*` global classes that emit on
every page, and mobile LCP (≤ 2s p75) is a top project priority. That growth is currently
ungated in both directions — nothing fails if CSS doubles.

**How to apply:** don't cite the 50 kB CSS budget as an existing gate. If CSS size needs
enforcing, it's a new `bundlesize` entry (Tier 1 — `package.json` root), not a config that
already exists. Fix the stale `projectState.md` line at the same time.

Related: [[project-env-topology-doc-conflicts]]
