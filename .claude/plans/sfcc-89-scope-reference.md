# SFCC-89 — scope reference

Recovered 2026-08-25. The original build plan was overwritten when the workflow plan was written to the same file; this preserves the parts the register and realignment plan still cite. **Authoritative source is the Jira ticket** — where this and the ticket disagree, the ticket wins.

## In scope (Jira)

Product name · full price in the active storefront's currency (single/full price only) · product description · "Model is…" copy · Style Code · ~~breadcrumb navigation~~ — **ruled out of scope 2026-08-25**, no design exists anywhere; the two breadcrumb ACs should move to SFCC-578.

## Out of scope, with owners

| Item | Owner |
|---|---|
| Breadcrumb | SFCC-578 (Squad B) — no design exists |
| Disclaimer band | SFCC-749 / SFCC-748 (Isabel, Squad A, epic SFCC-3) |
| Returns-eligibility notice | **PRC-12** — `is_returnable` / `final_sale`, confirmed in `.docs/prd/pricing-currency-globale.md:38` |
| Colour swatches | SFCC-91 |
| Size selector, add-to-bag | SFCC-92 |
| Image gallery | SFCC-186 / 187 / 188 |
| Accordions | SFCC-195 / 102 / 267 / 266 |
| Badges | SFCC-132 / 225 |
| Was/now pricing | SFCC-194 |
| Wishlist | SFCC-434 |
| Find in Boutique | SFCC-297 |
| `pdp/hero` layout metrics | SFCC-723 |

Ticket also excludes: Contentful-sourced content.

## Locked decisions carried forward

Branch cut from `develop`, rebased when #59 landed · clean build, #57 read as reference never copied · **copy-first the PDP page**, non-negotiable · `product-view` gets one optional `renderHeader`, no speculative slots · treat `product-view/` as Tier 2 and notify Squad B (note: no tier list or CODEOWNERS entry actually covers it) · model line reads **`c_modelFit`**, no `c_sizeFit` scraping · sanitiser SSR crash was a hard gate — resolved, engine replaced · the page composes, no container mirroring `pdp/product-content` · unresolved values get a named const + comment naming the measured value, missing token and owner · recipes only where a variant, state or responsive behaviour exists · test shape follows #59 · #57 stays open until superseded — **closed 2026-08-25** · the atom/molecule/organism taxonomy stays informal.

## Findings raised, still live

**AC-6 asked for a breadcrumb that was never designed** — checked the design system by name, both PDP components, both PLP bars at both breakpoints, both non-archived PDP designs, and the footer. Now resolved as out of scope; the ACs still need moving off the ticket.

**Duplicate scope, three instances, all created 17 Aug** — SFCC-89 ↔ SFCC-737 (`pdp/product-content`, now *Ready for Development*); SFCC-89's breadcrumb ↔ SFCC-578; SFCC-55/PR #59 footer ↔ SFCC-750. Systemic decomposition drift, not three coincidences.

**No page server-renders on the MRT preview or the `test` tier** — every route returns 200 with a `loadable` fallback. Pre-existing, storefront-wide, defeats the ≤2s p75 LCP budget. Tier 1 / Integration only. Note: SSR verified working *locally* during this work, so the fault is environment-specific.

**Ownership contradiction on `pages/product-detail/`** — `CODEOWNERS:162` says Squad B; `squadA.md` and `squadB.md:41` both say Squad A. CODEOWNERS is the enforced surface.

**Repo rules wrong or missing** — `testing.md`'s broken `@storybook/test` import; `.claude/rules/overrides.md` cross-referenced but absent from `develop`; no i18n rule despite 11 configured locales. (`scripts/auditTokenUsage.mjs` was also listed as missing — it now exists, shipped with #59.)

## Designer batch

Canonical node (five in circulation) · Button **50 vs 52** (DS vs composed pages) · style code **one node or two** (DS says two, composed pages show one string) · the **28px** and **44px** gaps — now measured and confirmed, still need tokenising · `FONT_REGULAR` vs `FONT_MEDIUM` for price and meta copy · the **768–1279px band is undesigned** (DS ships 402 and 1440 only) · `body2Strong` letter-spacing reads −0.12px where Figma says −0.14px, and `letterSpacings['2xs']` already holds −0.14 · `#000000` vs `text.default` on two labels · **DS mobile gutter 32px vs the composed page's 30px** · **PRD says "no final-sale icon in design yet" while the DS `Warning` state carries `Icon_info_solid`**.
