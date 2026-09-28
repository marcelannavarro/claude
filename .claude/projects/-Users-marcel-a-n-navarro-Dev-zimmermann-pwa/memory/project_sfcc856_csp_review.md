---
name: project-sfcc856-csp-review
description: "SFCC-856 CSP hardening (PR #79) approved despite not closing the named Lighthouse csp-xss audit; script-src is structurally locked by the SDK"
metadata: 
  node_type: memory
  type: project
  originSessionId: 94adc134-306f-4894-8621-6ed1afd1db48
  modified: 2026-09-01T05:51:59.860Z
---

PR #79 (TimLavelleACC, branch `fix/SFCC-856-csp-hardening-v2`, superseding stale PR #76) implemented nonce-based CSP for `style-src` in `overrides/app/ssr/contentSecurityPolicy.ts` + `overrides/app/components/_app-config/index.tsx`. Reviewed 2026-09-01 via zimmerMANNReview; approved by Marcel ("nothing but nitpicks") over my recommendation to request changes first. See [[feedback_review_verdict_severity]] for the verdict-calibration pattern this confirmed a second time.

**Why this matters going forward — two structural facts, not just this PR's bug list:**

1. **`csp-xss` (the Lighthouse audit SFCC-856 is named for) cannot be affected by any `style-src` change, in this exact installed toolchain.** Traced `node_modules/lighthouse/lighthouse-core/audits/csp-xss.js` → `csp-evaluator.js` → `csp_evaluator`'s `evaluateForFailure` → all six constituent checks are hardcoded to `DIRECTIVES_CAUSING_XSS = [script-src, object-src, base-uri]` (`csp_evaluator/checks/security_checks.ts:33-34`). `style-src`/`style-src-elem`/`style-src-attr` cannot appear in a `bypasses` finding. Also confirmed `csp-xss` isn't asserted by name in `lighthouse:recommended` or this repo's own `lighthouserc.js`, so it isn't a CI-blocking gate today either — SFCC-856 must be tracked via a manual/external Lighthouse run.
2. **`script-src`'s `'unsafe-eval'` is structurally un-removable from this repo.** `@salesforce/pwa-kit-runtime`'s `defaultPwaKitSecurityHeaders` (applied in the absolutely-frozen `overrides/app/ssr.js`) monkey-patches `res.setHeader` so that *any* later CSP header this app sets — including helmet's — gets forcibly union-merged with the SDK's own required `script-src` values (`'unsafe-eval'`, `runtimeAdmin`, `*.site.com`). No app-level change can opt out short of forking the SDK.

**How to apply:** if a future ticket revisits SFCC-856 or any `script-src`/`csp-xss` work, start from these two facts rather than re-deriving them — the real fix (if one exists at all) is a `script-src` nonce/`strict-dynamic` strategy that survives the SDK's forced merge, not more `style-src` work. Also worth revisiting: PR #79's own nonce is diluted by `s-maxage=900` CDN caching on homepage/PDP (same nonce replayed to every visitor of a cache entry for up to 15 min, confirmed live) — still strictly better than the prior blanket `unsafe-inline`, but not a true per-request secret; no code fix exists within `overrides/` for this either (would need edge-compute nonce rewriting on cache HIT, or dropping HTML caching, both bigger calls).
