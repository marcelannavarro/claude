# Incident Investigation: PDP 500 on "Illuminate Fitted Blouse" (product 4673TS251, ZimmermannAU dev)

## Context

A PDP crash was reported on the dev MRT environment (`zimmermann-dev.sfdc-8tgtt5-ecom1.exp-delivery.com`): the product "Illuminate Fitted Blouse" appears correctly in search results, but clicking through to its PDP returns a full-page `HTTPError 500` ("This page isn't working"). The user asked for an investigation, not a fix. Three parallel research passes (frontend data-fetching trace, `.docs`/memory context, repo/config confirmation) plus my own direct reads of the key files converged on a single, fully-explained root cause chain. The user has confirmed the deliverable for this task is **a diagnostic report only — no code changes in this repo.**

## Root cause chain (confirmed by direct code inspection, not inference)

**1. Backend: an SFCC custom hook throws 500 for this product/customer context.**

Both failing requests return HTTP 500 with response headers `sfdc_customization: HOOK` and `sfdc_customization_error: 1`:
- `GET .../customer/shopper-customers/v1/organizations/f_ecom_bkzk_002/customers/{guestId}/baskets?siteId=ZimmermannAU`
- `GET .../product/shopper-products/v1/organizations/f_ecom_bkzk_002/products/4673TS251?expand=availability,promotions,options,images,prices,variations,set_products,bundled_products,page_meta_tags&...&siteId=ZimmermannAU`

These headers are SFCC's own signal that a server-side hook/customization (Business Manager cartridge code, using `dw.*` Rhino APIs) threw an exception while processing the request — this happens entirely inside the Commerce Cloud instance, before/around the standard SCAPI resource logic. **Confirmed: no cartridge code, `hooks.json`, `dw/*` import, or hook-manifest of any kind exists anywhere in this repo** (exhaustive grep, zero hits) — this repo is a PWA Kit frontend/BFF only. Whatever throws is deployed to Business Manager for org `f_ecom_bkzk_002` (short code `qmyt7hks`, confirmed in `config/default.js` / `.env`), entirely outside this repository's boundary. `.docs/integration/01-sfcc.md` §1 explicitly scopes "Business Manager configuration" and cartridge-level logic as out of this document's (and this repo's) scope.

Both failing calls share the identical `correlation-id: c69950bf-f417-4c8b-8a7d-5793b8b81f3d` (while `cf-ray`/`x-amz-cf-id` differ, as expected per-request) — this is the PWA/MRT-generated trace key for this one page-load attempt, and is the header the Integration/SI Partner team should search Business Manager error logs by to pull the actual hook stack trace.

**2. Frontend: PDP's own error handling turns that upstream 500 into a hard page crash.**

Neither the PDP nor PLP page is yet overridden in this repo (`overrides/app/pages/product-detail/` does not exist — confirmed; Sprint 2, in progress now, is the first sprint scoping "PDP Part 1" work). Both currently run stock `@salesforce/retail-react-app@10.0.0` base code. In that base file (`node_modules/@salesforce/retail-react-app/app/pages/product-detail/index.jsx:193-199`):

```js
if (isProductError) {
    const errorStatus = productError?.response?.status
    switch (errorStatus) {
        case 404:
            throw new HTTPNotFound('Product Not Found.')
        default:
            throw new HTTPError(errorStatus, `HTTP Error ${errorStatus} occurred.`)
    }
}
```

A 500 from the product fetch is explicitly re-thrown during render. This is caught by PWA Kit SDK's global `AppErrorBoundary`, which on SSR propagates through `pwa-kit-react-sdk`'s `react-rendering.js` and causes the server to emit a genuine HTTP 500 for the whole document — rendering retail-react-app's stock `_error` component ("This page isn't working", not overridden in this repo). This fully explains the symptom with no SFCC-side code involved on the PWA side — it's the SDK/base-template working as designed for an unhandled non-404 product error.

**3. Why PLP survives the same basket-endpoint 500, and why the basket 500 is a red herring for the crash itself.**

`useCurrentBasket()` is called globally (base `_app`, this repo's `header/index.tsx` override, `cart/index.jsx`, and PDP) but **its error state (`isError`/`error`) is never destructured or checked anywhere in the codebase** — a failed basket fetch is silently treated identically to "still loading" (`basket` stays `undefined`, all consumers use optional chaining / truthy guards). PLP (`product-list/index.jsx`) never calls `useCurrentBasket` at all. So the baskets-endpoint 500 is real and is happening on every page load site-wide, but it has zero visible effect anywhere — the PDP crash is caused solely by the *product* fetch's explicit throw, not the basket fetch.

**4. The Einstein 400 is very likely unrelated.** `viewed-recently-einstein` (PDP's "Recently Viewed" widget) fires with no `products` payload and no `shouldFetch` gate — it's structurally decoupled from product-fetch success/failure, and since PDP throws before reaching its `return (...)`, that widget never even mounts on the crashed render. The 400 seen ~90s later almost certainly came from a different page/moment in the session (e.g. Cart, which uses the identical recommender name) rather than this PDP load.

## Secondary finding, noted but not being fixed in this task

`.docs/integration/01-sfcc.md` §8 ("Failure modes and graceful degradation") documents that a `SCAPI catalogue 5xx` should retry 3× with exponential backoff, then show cached data or "an error state with a 'Try again' CTA" — never a hard page crash. In practice: the global QueryClient config (`overrides/app/components/_app-config/index.tsx:222-236`) has `retry: false` (and `retryOnMount: false` server-side) — inherited PWA Kit boilerplate, not a deliberate Zimmermann customization — and PDP has no graceful error state at all, only the hard `throw` shown above. Two independent gaps exist against the documented contract:
- Global retry policy off — Tier 2 "Global Shell" (`_app-config`, "coordinate before touching," affects every query app-wide) — high blast radius, and wouldn't actually help *this* incident since the hook fails deterministically for this product, not transiently.
- PDP's own hard-throw-on-any-non-404-error — would only be in scope once PDP is copied into `overrides/` (already planned for Sprint 2 "PDP Part 1").

Per the user's explicit choice this session, this is **reported as a recommendation only** — no override/copy-first work is being done now. It's a natural fit to fold into Squad A's already-scoped PDP Part 1 work.

## Recommended next steps (for handoff, not for this repo)

1. **Escalate to Integration/SI Partner (Accenture)** with: product ID `4673TS251`, org `f_ecom_bkzk_002` / short code `qmyt7hks`, site `ZimmermannAU`, correlation ID `c69950bf-f417-4c8b-8a7d-5793b8b81f3d`, and both failing resource paths above. Ask them to pull the Business Manager error log / hook stack trace keyed on that correlation ID — that will show exactly which custom hook is throwing and why (this is not retrievable from this repo).
2. **Check blast radius**: try another product's PDP on the same dev environment. If it also 500s, the hook is broken globally (e.g. a shared/global hook, or a recent bad cartridge deploy); if only this SKU is affected, the hook is likely choking on this product's specific data (the `page_meta_tags` expand param is the most distinctive one requested here, and per `.docs/prd/dataMigrationSeo.md` DMU-031/032/035, PDP meta-tag rules are BM-configured — a good first place to check this product's SEO/meta-tag configuration for something malformed or missing).
3. **Check whether the guest basket already contains this product** (session `ablHw2lrEWkrARxHhIxGYYxboX`) from a prior add-to-cart attempt — if so, basket hydration would touch the same product-level data as the product-detail call, which would unify both 500s under one root cause (bad data/hook logic on this one SKU) rather than two coincidental failures.

## Verification

This is a report, not a code change — "verification" here means confirming the diagnosis is sound before handoff:
- Re-open the PDP in devtools and confirm both 500s still show `sfdc_customization: HOOK` / `sfdc_customization_error: 1` (rules out a transient blip).
- Load a second, unrelated product's PDP to establish whether this is SKU-specific or global (see step 2 above) — this single check most efficiently narrows where the Integration team should start looking.
- No `npm run build` / `tsc` / test run is applicable — no files in this repo are being changed.
