---
name: project-locale-selector-dead-end
description: The footer country/region label cannot be derived from config — CountryConfig has no display-name field and the value is user-selected state owned by an unbuilt selector
metadata:
  node_type: memory
  type: project
  originSessionId: f5f727b4-7546-4aa6-9d86-ef229e247d3f
  modified: 2026-08-22T02:20:00.000Z
---

Investigated twice during SFCC-55 (session 652997c6) and confirmed a dead end. Don't re-derive it.

**The base SFCC `LocaleSelector` does not apply.** It renders on
`supportedLocaleIds.length > 1`, and every one of the 11 Zimmermann sites has exactly **one**
locale — so it would never render anywhere.

**The country name is not derivable from config.** `CountryConfig` carries `urlSlug`,
`sfccSiteId`, `locale`, `currency`, `shippingCountry`, `checkoutOwner`, `globalEPricing` and
`boutiqueRegion` — but **no display-name field**. `ZimmermannEU` alone serves four slugs
(`en-eu`, `fr-eu`, `it-eu`, `es-eu`), so the site ID doesn't identify a country either.

**And it isn't a derived value in the first place.** Per REG-020–REG-028 the displayed country
reflects the shopper's *selected shipping destination* — user state owned by a
country/region selector that hasn't been built. That story needs cross-storefront switching,
region grouping, currency display, search, and the REG-022 basket-loss warning; it is not a
within-site language dropdown.

Current shipped state: an inert element with a hardcoded placeholder label, documented in-code.

**Why:** two separate attempts to source this label properly both failed on the same missing
data. It reads like a small fix and isn't.

**How to apply:** treat the footer locale label as blocked on the country/region-selector story,
not as a bug. See [[project-sfcc55-footer-state]] for its deferral status on PR #59.
