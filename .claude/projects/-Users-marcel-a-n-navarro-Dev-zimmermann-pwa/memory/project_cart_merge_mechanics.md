---
name: project-cart-merge-mechanics
description: "SFCC basket merge takes higher-of-two by default, not sum; on develop no Zimmermann code merges and passwordless drops the basket, but FIXED on feature/SFCC-11_cart (commit 1e7fde75) pending merge"
metadata: 
  node_type: memory
  type: project
  originSessionId: 6017b702-06fb-4295-9164-1c708495531a
  modified: 2026-09-20T15:57:34.011Z
---

Verified 2026-09-16 against `commerce-sdk-isomorphic` types and the base template.

**`mergeBasket`'s `productItemMergeMode`** is `higher_quantity` (default) | `sum_quantities` |
`saved_quantity` | `separate_item`. Default means **guest 2 + account 2 → 2, not 4** — quantities
never sum unless the mode is passed explicitly, and it can only be passed at the call site.

**Same-product matching** requires all of: shipment · productId · option values · wishlist
reference · inventory list id · gift flag & message · ad-hoc price adjustments. Any mismatch
copies the item to a **new line item** instead of merging — so one SKU can exceed a per-order cap
across two lines without either line doing so. For Zimmermann the realistic differentiators are
Collect in Boutique (separate shipment) and boutique vs warehouse inventory lists.

**Four base call sites**, all passing only `createDestinationBasket: true`: `hooks/use-auth-modal`,
`pages/login`, `pages/social-login-redirect`, `pages/checkout/partials/contact-info`. The merge is
deliberately **login-only, not register** — a new customer's guest basket simply becomes theirs.

**UPDATE 2026-09-20 — the passwordless gap below is fixed, on the `feature/SFCC-11_cart` branch,
not yet on `develop`.** Commit `1e7fde75` added a `mergeBasket.mutate()` call to
`useWishlistAuthDrawer.ts`'s own `isRegistered` effect, using `productItemMergeMode:
'sum_quantities'` (a deliberate departure from the server default described below — see
[[project-cart-bundle-decisions]]) and `createDestinationBasket: true`, called unconditionally
(no `hasBasketItem`/`usePrevious` guard — Marcel's call, the cheaper failure mode). Two things
still genuinely open, disclosed not fixed: no `onError`/`isPending` handling (a failed merge
surfaces nothing to the shopper — matches base SFCC's own shipped behaviour, not a regression),
and live end-to-end verification is deferred post-build (only reproducible against a real
sandbox, not the Vitest harness). Until this branch merges to `develop`, the paragraph below
describing "passwordless OTP merges nothing" is still what's live in production.

**No Zimmermann code calls `mergeBasket`** *(on `develop`, as of 2026-09-16 — see update above for
the feature-branch fix)*, and `commerce-sdk-react` does not auto-merge (it only defines the
mutation). Of `useWishlistAuthDrawer`'s three routes: social redirects through the base page that
merges; create-account correctly skips it; **passwordless OTP merges nothing** — so a recurring
shopper signing in that way has their guest basket orphaned and **loses their items**. This was
code-inferred originally; the SFCC-11 build's own Tester independently mutation-tested the fix
twice and confirmed the merge-args assertion and the create-account non-call each time.

**Why:** any cart/checkout work touching sign-in inherits this. Assuming the server sums, or
assuming a merge happens at all, both produce silently wrong baskets. Until SFCC-11 merges, this
is still live behaviour on `develop`.

**How to apply:** check what mode a merge call passes before reasoning about quantities. On
`develop` today, still treat "a guest signed in via passwordless" as "the basket may have been
orphaned." On `feature/SFCC-11_cart`, the merge now happens, but a *failed* merge is still silent
— don't assume success without checking for that follow-up fix too.
Related: [[project-cart-bundle-decisions]], [[project-max-order-quantity]],
[[project-cart-sale-pricing-gaps]].
