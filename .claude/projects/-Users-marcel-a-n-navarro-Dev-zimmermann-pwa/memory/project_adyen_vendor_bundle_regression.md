---
name: adyen-vendor-bundle-regression
description: "develop's Deploy Dev CI gate failed 2026-09-11 to 2026-09-14 (PR #71) — vendor.js exceeded its 550kB budget because Adyen landed in the shared vendor chunk; fixed via a webpack cache-group carve-out, PR #115 open awaiting tier-1-approver review"
metadata: 
  node_type: memory
  type: project
  originSessionId: c22bc5c5-f466-47ea-9583-137b87fdbef0
  modified: 2026-09-14T17:12:14.445Z
---

`develop`'s `Deploy Dev` workflow (continuous auto-deploy-on-push tier) failed from
[PR #71](https://github.com/ZimmermannAU/zimmermann-pwa/pull/71) (SFCC-662, Adyen install, merged
2026-09-11) through [PR #108](https://github.com/ZimmermannAU/zimmermann-pwa/pull/108) (SFCC-132
badges, merged 2026-09-14, commit `ece4fc5` — an innocent bystander that just landed on the
already-broken base): `vendor.js` was 878.64 KB gzip vs. a 550 KB budget.

**Root cause, verified — not the first theory tried:** it is NOT eager vs. dynamic imports.
`@adyen/adyen-salesforce-pwa`/`@adyen/adyen-web` are used in exactly 3 files —
`overrides/app/pages/checkout/partials/payment.tsx`, `overrides/app/pages/checkout-redirect/index.tsx`,
`overrides/app/pages/confirmation/index.tsx` — and all 3 are reached only through already-lazy
routes (`Checkout`/`CheckoutRedirect`/`CheckoutConfirmation`, confirmed via `loadable()` in both
this repo's `overrides/app/routes.tsx` and the base template's
`node_modules/@salesforce/retail-react-app/app/routes.jsx`). The real cause is
`node_modules/@salesforce/pwa-kit-dev/configs/webpack/config.js` lines 232-251: a `vendor`
cache-group with a **static** `name: 'vendor'` and `chunks: 'all'` that merges *every*
node_modules package — sync or async — into one physically-named file. Because that file also
carries genuinely-eager deps (React, Chakra), anything merged into it rides along as eager too,
regardless of how it's actually used.

**Why the first fix idea (dynamic `import()`) was wrong:** disprovable from the code alone — 2 of
the 3 files already lazy-load Adyen via their route, and it still ended up in `vendor.js` anyway.
Static vs. dynamic import was never the lever; the cache-group's static name was.

**CDN/script-tag loading was investigated and ruled out**, not assumed: `@adyen/adyen-web`
supports it, but `@adyen/adyen-salesforce-pwa` (the package actually used here) does not — its
compiled `dist/app/index.js` does a literal `require("@adyen/adyen-web")` and destructures 5 named
exports (`AdyenCheckout`, `ApplePay`, `GooglePay`, `PayPal`, `Donation`), a shape a CDN script's
single global can't provide without dropping the official wrapper and reimplementing Adyen's SFCC
glue by hand.

**Status: PR open, awaiting merge.** [PR #115](https://github.com/ZimmermannAU/zimmermann-pwa/pull/115)
(`fix/adyen-vendor-chunk-split`, commit `f61ef3d`), opened 2026-09-15. CodeRabbit's one finding
(Tier 1 owner-approval confirmation on `package.json`) was verified INVALID — the verified-session
exception was already correctly applied and documented in the PR body — and replied to in-thread;
no code change needed. Still needs: CI green + an approving review from
`@ZimmermannAU/tier-1-approvers` (CODEOWNERS-enforced) before it can merge to `develop`. Before
relying on any of this in a future session, check `gh pr view 115` for current state rather than
assuming this snapshot still holds.

**The fix, implemented and verified locally on branch `fix/adyen-vendor-chunk-split`
(2026-09-14):**
- New root `webpack.config.js` (plain `.js` — PWA Kit hard-requires this exact filename, checked
  in both `bin/pwa-kit-dev.js`'s build command and `ssr/server/build-dev-server.js`'s dev-server
  path). Requires the base config array (`@salesforce/pwa-kit-dev/configs/webpack/config`), finds
  the `client` entry by `.name === 'client'`, adds a new `adyen` cache group (`test` matching
  `node_modules/@adyen/`, `chunks: 'all'`, `priority: 10` — must outrank the default vendor
  group's implicit 0). Zero application-code changes.
- `package.json`'s `bundlesize` array gained a third entry, `build/adyen.js` at `400 kB` max
  (measured actual: 363.34 KB gzip) — this chunk had no budget watching it before.
- **Measured result:** `vendor.js` 878.64 KB → 515.21 KB gzip (under its 550 KB budget again);
  `adyen.js` 363.34 KB (new, under its 400 KB budget); `main.js` unaffected at 132.94 KB. Full
  `npm run test:max-file-size` (the exact CI command) passes: 3/3 checks. `npx tsc --noEmit`
  clean. `npm run test` (Vitest): 1188/1188 passing, 80/80 files. `npm run lint` shows ~880
  pre-existing problems — all pre-existing, unrelated, and outside its own scan glob
  (`overrides/**/*.{ts,tsx}` never touches either changed file).
- **Gotcha hit during verification:** `npm run build` regenerates translation-extraction files as
  a side effect — see [[feedback-build-regenerates-translations]]. Discarded before treating the
  branch as clean; don't mistake that regeneration for something this fix caused.

**Why this happened at all:** `Deploy Dev`'s bundle-size job only runs post-merge, continuously,
on every push to `develop` — there's no PR-time bundle-size gate for `develop`-targeted PRs — so
PR #71 merged clean and only broke once landed.

**How to apply / governance flag, still open:** the new `webpack.config.js` isn't listed in
`frozenFiles.md`/`protectedFiles.md` — flagged to Marcel as a real gap (this file controls
code-splitting for every production bundle, same blast-radius class as the
`overrides/app/request-processor.js` "add here when populated" precedent already in
`frozenFiles.md`) rather than resolved unilaterally. This session's GitHub identity
(`marcelannavarro`) was verified as both a `@ZimmermannAU/tier-1-approvers` member and repo admin
before touching `package.json` (Tier 1) — see AGENTS.md's Tier 1 Approval section for why that
check, not a second confirmation prompt, was sufficient.

Full run record (audit, sweep, CodeRabbit round, DevImprover pass) at
`~/Dev/zimmerMANN-skills/.runs/adyen-vendor-chunk-split/postbuild.md`. One process finding came
out of this: `zimmerMANNPostBuild`'s Phase 4 PR-drafting step used a colleague's merged PR
(`#89`, authored by `TimLavelleACC`) as a format exemplar without checking authorship — caught by
Marcel, corrected, and the skill itself patched (added an authorship-verification step) so it
doesn't repeat.
