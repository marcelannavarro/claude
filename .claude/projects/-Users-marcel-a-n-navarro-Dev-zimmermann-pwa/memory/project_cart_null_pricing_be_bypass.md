---
name: project-cart-null-pricing-be-bypass
description: "Cart's $0.00/null pricing bug is BE-confirmed (Gideon) — a custom calculate hook with no tax logic yet is masked by a temporary bypass; prices will go null again on the next BE redeploy"
metadata: 
  node_type: memory
  type: project
  originSessionId: 6017b702-06fb-4295-9164-1c708495531a
  modified: 2026-09-22T03:43:11.836Z
---

Confirmed 2026-09-22 by Gideon (backend/SFCC dev) directly to Marcel, right after this session
independently diagnosed the same symptom via live API testing — a freshly-created guest basket's
price/tax/total fields all null the instant a real item was added.

Gideon's own explanation, verbatim: "i implemented a bypass, there is a custom calculate feature
that overrides the ootb calculate by sfcc, and it does nothing right now because we don't have
logic for custom tax yet but since i implemented a bypass that's why it works for now, a
redeploy of the backend will result back to the prices missing since the bypass will disappear,
but this confirms that the issue is on the BE and not FE."

**Why:** prices appearing to "just start working" mid-session (independently re-confirmed same
day via a fresh live-basket API probe — real `productTotal`/`orderTotal`/item `price` values, not
zero) is NOT a fix. It's a temporary, undeployed bypass sitting on top of a custom SFCC
`calculate` hook that has no real tax logic behind it yet. The underlying bug is confirmed
backend twice over now — this session's own independent live-API diagnosis, and Gideon's direct
account of the cause.

**How to apply:** do not treat cart pricing as resolved, and do not remove or adjust any frontend
price-display code on the assumption the bug is gone — nothing on the frontend caused this to
start working, so nothing on the frontend can keep it working either. Expect prices to go back to
null/zero the next time the backend redeploys. Re-verify live (don't assume from a past session)
before relying on cart pricing being correct in any future session. Distinct from
[[project-cart-sale-pricing-gaps]] (was/now strikethrough + discount label) — that's a separate,
narrower, structural API-data-availability gap, not this basket-wide calculate-hook failure.
