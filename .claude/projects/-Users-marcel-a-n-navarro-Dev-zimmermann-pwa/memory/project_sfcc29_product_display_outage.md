---
name: project-sfcc29-product-display-outage
description: "SFCC-29 dev-env bug — PLP/PDP show no products; isolated to a backend SCAPI hook (not frontend), triggered by allImages=true on product-search"
metadata: 
  node_type: memory
  type: project
  originSessionId: 8159e0d3-ecbf-4f5d-ba0c-39a3cb289810
  modified: 2026-07-28T03:42:01.175Z
---

**ROOT CAUSE CONFIRMED, backend not frontend — but NOT a universal
"allImages=true always fails" rule (corrected 2026-07-28 after independent
re-verification).** `allImages=true` alone reliably crashes the *specific*
reported scenario: the `cgid=clothing` PLP category (product `4673TS251`,
the only product in that category) via `product-search`, and direct
`shopper-products` fetches of both `4673TS251` and a second product
`8637DS241`. All of these reproduce 100% of the time (10+ trials across
three separate sessions/tokens, including one run from a fully independent
network path — see "Independent verification" below).

**However:** `product-search?q=dress&allImages=true` — which surfaces
`8637DS241` as its only hit — returns 200, not 500, even under the full
original param set, repeated 3×. So `8637DS241` crashes via direct
`shopper-products` fetch but NOT via `product-search`, while `4673TS251`
crashes via *both*. The trigger is product-and-endpoint-dependent, not a
blanket parameter bug. Both products have similar catalog structure (1
colour, 6 sizes, 6 variants each) per earlier search-hit payloads, so it
isn't simply "one has variants, the other doesn't" — the actual
differentiator (a specific image-group/catalog-data inconsistency on the
Commerce Cloud side, most likely) isn't visible via the Shopper-facing API
and can't be narrowed further by black-box HTTP testing alone. Don't
overstate this to Integration as "every allImages=true request fails" —
it doesn't. State the two confirmed repros precisely instead (see
"How to apply").

SFCC-29 (dev environment): PLP and PDP fail to display products because
`shopper-search` (product-search) and `shopper-products` calls to the
`bkzk_002` SCAPI instance return `500 Internal Server Error` with an
`sfdc_customization: HOOK` response header — a custom SCAPI hook on the
Salesforce side is throwing, not the PWA.

**Confirmed not frontend.** Reproduced by hitting SCAPI directly with curl —
bypassing the PWA dev server and its `/mobify/proxy` layer entirely — using a
captured guest bearer token; identical 500 + HOOK with zero PWA in the path.
No override exists for `product-list`/`product-detail` in this repo
(`overrides/app/pages/` only has `experience`, `home`, `my-new-route` on this
branch) — the failing requests use `@salesforce/retail-react-app` v10's stock
default parameters, not a Zimmermann customization. Ruled out mani's
concurrent PRs #41 (`feature/storefront-preview-contentful`) and #42
(`feature/sync-env-vars-to-mrt`) as the cause — neither touches
product-search/product-detail request parameters at all; #42 is CI-only.

**PLP root cause pinpointed via query-param bisection** (direct-to-SCAPI, one
param added at a time on top of a passing baseline
`product-search?refine=cgid=clothing&currency=AUD&locale=en&limit=5` → 200):
adding only `allImages=true` flips the same call to 500. Every other param
tested individually (`expand=page_meta_tags`, `expand=custom_properties`,
`expand=prices&perPricebook=true`, `expand=variations&allVariationProperties=true`,
`sort=best-matches`) stayed 200. Note `sfdc_customization: HOOK` appears on
*successful* hooked-endpoint responses too — it marks "a custom hook is
registered on this resource," not failure by itself; the status code is the
real signal, not that header.

**PDP (`shopper-products`) confirmed to share PLP's exact root cause.**
Isolated on `4673TS251` (a real catalog product, returned by the PLP search
hits): same expand list (`availability,prices,images,variations`) +
`perPricebook=true` **without** `allImages` → 200. Fully bare fetch (zero
expand, zero `allImages`) → 200. Bare fetch + `allImages=true` alone,
nothing else → **500**. So `allImages=true` in total isolation is sufficient
to crash `shopper-products` for this product — exactly mirroring
`product-search`. `Test` (the placeholder ID used earlier in the
investigation) never broke because it evidently has no real variant/image
data for the hook to choke on; every expand-value variant tried against
`4673TS251` in the prior round 500'd regardless of which expand values were
present, because `allImages=true` was baked into all of them.

Why: took a full session of curl-based isolation to separate from unrelated
"pending build/integration" noise in the same console log (Einstein
`Failed to fetch`, Data Cloud `ERR_NAME_NOT_RESOLVED`, Contentful
`unknownContentType`) — all separately broken/unconfigured in dev but
unrelated to this outage — and from an initial wrong guess (`page_meta_tags`)
that the bisection data corrected.

**Verification pass (2026-07-28).** Independently re-audited the verdict
rather than just re-confirming it. Re-grepped the vendored base template:
`allImages: true` is a hardcoded, unconditional literal in both
`product-list/index.jsx:171` and `product-detail/index.jsx:126` — not
derived from any Zimmermann config/override — closing off any indirect
frontend-influence theory. Re-pulled current PR #41/#42 state: #42 gained
5 more commits since original review but the file set is unchanged (still
just the workflow YAML + README); #41 unchanged. Widened the check to *all*
of mani060689's PRs (not just #41/#42) and found PR #19
("fix(icons): export original icon names to fix blank PLP with products",
merged 2026-07-08) — investigated the diff and ruled it out: a JS
module-export crash, already fixed weeks earlier, zero code overlap with
product-search/hooks, and categorically inconsistent with a curl repro that
bypasses React/webpack entirely and still gets a 500 from Salesforce's
servers. No Jira/Atlassian tool is available in-session (checked via
ToolSearch) to cross-read the actual SFCC-29 comment — this whole
investigation was built from the pasted console log only; that gap is
acknowledged, not closed. Reproducibility: `allImages=true` present in 12+
independent trials (100% failure) vs. absent in 5+ (100% success), across
~1hr and three separate guest tokens — substantially mitigates
single-sample/flakiness concern. Confirmed this agent's own sandbox can
reach the real SCAPI host directly (`qmyt7hks.api.commercecloud.salesforce.com`
responds), so a fully independent repro (not relying on the user's machine)
is possible if a fresh token is ever supplied.

How to apply: if "products not displaying in dev" comes up again before this
is fixed upstream, don't re-investigate from scratch — it's confirmed
backend on the `bkzk_002` SCAPI hook, owned by Integration/SI partner, but
state it precisely (see correction above), not as a blanket claim. Confirmed
minimal repros for the ticket (guest token — both re-verified from an
independent network path on 2026-07-28, not just the developer's machine):
- PLP: `GET .../shopper-search/v1/organizations/f_ecom_bkzk_002/product-search?siteId=ZimmermannAU&refine=cgid=clothing&currency=AUD&locale=en&allImages=true` → 500 (`cgid=clothing` is the actual category from the original bug report)
- PDP: `GET .../shopper-products/v1/organizations/f_ecom_bkzk_002/products/4673TS251?siteId=ZimmermannAU&currency=AUD&locale=en&allImages=true` → 500
- PDP (second product, generalizes the PDP finding): same call with `products/8637DS241` → also 500
- Counterexample, do NOT claim this fails: `product-search?q=dress&allImages=true` (surfaces `8637DS241`) → 200, confirmed 3× — the bug does not reproduce on every product-search query, only some.
Removing `allImages` fixes the two confirmed-failing repros above. That's a
viable *temporary* frontend mitigation (drop `allImages=true` from the PLP/
PDP requests) but do NOT implement it without explicit user approval —
`allImages` controls per-variant image completeness (a real UX regression,
e.g. colour swatches showing the wrong image), and `product-list`/
`product-detail` have no override yet in this repo, so adding one is a
Copy-first-rule task, not a quick patch.

**Independent verification (2026-07-28):** ran the full repro battery a
second time from this agent's own sandbox — a network path entirely separate
from the developer's machine/browser — after confirming general internet
egress and direct reachability of `qmyt7hks.api.commercecloud.salesforce.com`.
All previously-confirmed failures/successes reproduced identically from this
independent source, PLUS one new test that had never been run before (PDP
full original expand list minus `allImages` → 200, closing the last
untested PDP combination) PLUS the `q=dress` counterexample above, discovered
specifically *because* this pass deliberately tested generalization across a
second product/category rather than re-running only the already-confirmed
cases.
