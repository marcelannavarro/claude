---
name: project-cart-sale-pricing-gaps
description: "Cart drawer never shows a was/now strikethrough price or a discount-off label, even once SFCC-11 ships — two separate causes, both disclosed and deferred to post-build tickets"
metadata: 
  node_type: memory
  type: project
  originSessionId: 6017b702-06fb-4295-9164-1c708495531a
  modified: 2026-09-20T15:57:11.375Z
---

Verified 2026-09-20 by reading `overrides/app/components/item-variant/item-price.tsx` and
`overrides/app/pages/cart/cartItemMapper.ts` directly, not inferred from the plan.

**Was/now strikethrough price — blocked by missing API data, not a wiring gap.**
`item-price.tsx` hardcodes `listPrice: null` for every real basket line, carrying Salesforce's
own original comment: "listPrice is not available via basket pricing." Confirmed against
`commerce-sdk-isomorphic`'s generated `ProductItem` type — no list-price field exists, and
`getBasket` has no `expand` param to request one. A real fix means fetching each line's full
product/pricebook data separately (an extra per-line API call) and computing the delta
client-side — architecturally belongs in `cartItemMapper.ts`, not the leaf component. Genuine
new scope, not something SFCC-11 budgeted for.

**Discount label ("X% off") — the opposite shape: the data exists, nobody's specified the
copy.** `ProductItem`'s `discountLabel` prop and its render slot (a `ZimmInlineMessage`,
`success` variant) are both built and wired. The inputs needed to compute a real value
(`price` vs `priceAfterItemDiscount`) are already present on every real basket line today —
nothing missing here. It's inert only because no card/spec in this epic ever defined what the
label should say, and Marcel declined to invent copy without a real requirement (2026-09-18).

Already logged in `~/Dev/zimmerMANN-skills/.runs/SFCC-11/handoff.md`'s "Follow-up tickets to
file" section — no Jira ticket exists yet for either as of this writing.

**Why:** whoever scopes the post-SFCC-11 follow-up needs to know these are two independently-
blocked problems, not one "just wire it up" task — treating them as one risks scoping a single
ticket that can only ever half-ship.

**How to apply:** file as two separate tickets. Was/now needs a data-fetching architecture
decision first (extra API calls per cart line, cost/latency tradeoff). Discount label needs a
copy/format decision from design or marketing, then is a small, low-risk front-end change.
Related: [[project-cart-bundle-decisions]], [[project-max-order-quantity]],
[[project-cart-merge-mechanics]].
