---
name: project-max-order-quantity
description: "Two independent max-quantity mechanisms now exist — cart reads c_maxOrderQuantity, PDP still hardcodes 3; the SFCC attribute is still not deployed"
metadata:
  node_type: memory
  type: project
  originSessionId: 75bd095e-159e-4981-9ce1-13fc8b267fc5
  modified: 2026-09-24T08:04:46.904Z
---

Verified 2026-09-16, **re-verified and amended 2026-09-24**.

**There are now two independent mechanisms, not one.**

- **Cart — SFCC-backed read path exists.** `overrides/app/utils/maxOrderQuantity.ts`'s
  `getMaxOrderQuantity()` reads `c_maxOrderQuantity` off the SCAPI product response and falls back
  to its own `DEFAULT_MAX_ORDER_QUANTITY = 3`. Consumed by `product-item/index.tsx`,
  `useCartMergeAndCap.ts` and `cartDrawerContainer.tsx`.
- **PDP — still hardcoded.** `const MAX_PURCHASE_QUANTITY = 3` at
  `overrides/app/pages/product-detail/index.tsx:149`, used once at `:1330`. Not wired to the util.

**The attribute is still not populated.** That util's own docblock records a live dev-sandbox probe
finding no `c_maxOrderQuantity` on any product — the `afterGET` hook is not deployed. So the read
path degrades to the hardcoded 3 today and picks up the real value the day the hook ships.
`TSD-SFCC-268` (Confluence 406913046) is still **v0.1 Draft, Technical Lead sign-off Pending**, with
unfilled `[Name]` placeholders, and its resolution order is product override → site preference →
hardcoded. **Customer group is not a tier in it at all** — which matters because SFCC-703 asks for
exactly that.

**Correction to this memory's earlier advice:** it previously said to promote the constant out of
the PDP into one shared value. That was considered and **deliberately rejected** — the util's
docblock explains a shared constant would need reworking the day the real per-site preference
ships, since the two sit at different tiers of the TSD's resolution order. Don't re-propose it.

**Three tickets, one mechanism (2026-09-24):** SFCC-703 (customer-group + SKU override),
SFCC-172 (cart SKU override, `CouldHave`), and SFCC-250 (cart enforcement, **In Progress**, whose
ACs hardcode "the configured maximum of 3"). Resolve the overlap before re-estimating any of them.

**Why:** any story saying "the configured maximum" sends someone hunting for a Business Manager
setting that does not exist yet, and the PDP/cart split means a fix in one place silently leaves
the other on 3.

**How to apply:** wire the PDP to `getMaxOrderQuantity(product)` (the `product` is already in scope
at `:1330`) rather than adding a third constant; don't treat SFCC-268 as having delivered a
readable setting; and don't assume customer-group resolution is a frontend concern until the TSD
is signed. Related: [[project-cart-bundle-decisions]], [[project-cart-merge-mechanics]],
[[project-sprint6-duplicate-stories]].
