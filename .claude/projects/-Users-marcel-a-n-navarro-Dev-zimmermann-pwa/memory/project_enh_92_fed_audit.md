---
name: project-enh-92-fed-audit
description: 9.2 Enhancements tracker carries 49 FED days against a 20-day budget; all 18 sized tickets have zero ACs; five rows are duplicates/mis-attributions rather than estimate errors
metadata:
  node_type: memory
  type: project
  originSessionId: 75bd095e-159e-4981-9ce1-13fc8b267fc5
  modified: 2026-09-25T01:16:56.294Z
---

Audited 2026-09-24 against Confluence page 385318913 (v17), Jira, `.docs/` and the codebase.
Full write-up produced as a standalone document, not stored here.

**The numbers.** FED budget 20 days (2 sprints × 1 FED), 12.5 booked consumed, **7.5 remaining**.
Tracker carries **49 FED days as written**, 53–88 after audit. Approved-but-unbooked rows alone
(SFCC-135, 704, 724, 859, 946) are 17.5 days against that 7.5 — a **10-day hole**. BA finishes
~11 days spare: the capacity model treats four disciplines as interchangeable and the work mix
is FED-heavy.

**All 18 sized tickets have `customfield_10231` null** — zero acceptance criteria, every figure
estimates a paragraph. None is in any sprint.

**Five rows are not estimate problems:**
- **SFCC-946** (Avalara) — PRC-07, signed off 24 June by Emma/Rebecca, already puts AU/EU/US/UK
  in the baseline this "expansion" targets. Conflicts with PAY-067 and architecture.md. FE is
  payload-driven (`order-summary` not overridden, renders `basket.taxTotal`), so ~0.5 day.
- **SFCC-950** — reverses signed-off PAY-039 ("HK, ME, EU Intl **cannot** redeem online");
  deliverable is inside Global-E's iframe; zero affected customers per its own note.
- **SFCC-174** duplicates **SFCC-572** (7 real ACs, epic SFCC-22) — this one holds.
  **Correction:** SFCC-724 does *not* ≈ SFCC-563 + SFCC-577 as first reported. SFCC-563 is a dead
  shell (merged into SFCC-562 on 2026-09-14, 0 ACs); SFCC-577 has 0 ACs and is scoped per-category
  not per-filter. Only SFCC-562's AC5/AC6 genuinely overlap SFCC-724 (the BM opt-in + canonical
  override) — the per-filter clean URL/title/meta-description have no home anywhere, since
  SFCC-568/569 both source metadata from the SFCC category object and a facet combo isn't a
  category. Recoverable duplication is **~4.5 FED days, not 6** — SFCC-174's 3 plus ~1.5 of
  SFCC-724's 5.
- **SFCC-156** is linked `Blocks`, **not** Duplicate, to SFCC-135 — High, 7 ACs, 3 front-end.
- **SFCC-710** is a *reversal* of SFCC-434, which `product-detail/index.tsx:590` records Jasmijn
  as having confirmed ("PDP badge has no confirmation message").

**Two live defects found in passing:** the `/social-callback` route gap
([[project-routes-static-export-trap]]), and SFCC-947 — a real WCAG 2.2 AA duplicate-CTA defect
in `zimmSizeSelector` on `develop`, which the tracker dismisses by pointing at SFCC-101, the
ticket whose AC9 *mandates* it.

**Why:** the page's "Approved" column doesn't distinguish approved-to-spend from
approved-in-principle, so the capacity table treats unspecified and contradicted work as booked
cost.

**How to apply:** don't re-estimate individual rows before the scope questions close — the net
delta is small and cuts both ways. The decisions worth chasing are: what comes off the plan,
whether Enhancements owns any SEO, and the Avalara baseline. Related:
[[project-sprint6-duplicate-stories]], [[project-max-order-quantity]],
[[project-review-findings-never-posted]].

**2026-09-25 addendum — client pushback on SFCC-857/858, sense-checked, both revised down.**
Natasha Lay relayed the client believes little/no FED is needed on either. Both turned out to
have real merit, not just pressure:

- **SFCC-857 (Emarsys Web Extend):** `.docs/integration/13-gtm.md` §5's AAB-002 data layer
  (unconfirmed, pending TNL sign-off, but already spec'd) already carries `add_to_cart`,
  `view_cart`, `view_item`, `purchase` (transaction_id/value/items/hashed email), `login` — every
  field Web Extend needs. If Tell No Lies configures it as a GTM Custom HTML tag reading that
  data layer (same pattern as GA4/Meta), FED cost is genuinely near zero. **Revised: 0.5–1 day**,
  down from table's 3 and my own 6 the day before — conditional on that delivery mechanism; if
  Web Extend needs bespoke on-page SDK calls instead, ~4 days (still down from 6, since the
  loader/consent-gating cost is shared infra under SFCC-107, not this ticket's).
- **SFCC-858 (co-browsing):** client confirmed co-browsing will be done via InsideChat — this is
  exactly what the unread `Manual - INSIDE - Co-Browse.pdf` (Confluence 264765445) already
  implied. Session mechanics are vendor-owned once confirmed. **Revised: 0–1 day**, down from
  table's 3 and my own 4.5 — 0 if Zimmermann accepts InsideChat's native consent/masking UI, ~1
  if they want a Zimmermann-branded consent modal wrapping the vendor trigger.
- Both numbers were produced with Atlassian MCP down — built from this file's own prior research
  plus a fresh full read of `13-gtm.md` and `14-inside-chat.md`, not a live re-check. Re-verify
  against the actual tickets once Atlassian is back, and before either lands in a sprint, get
  Tell No Lies to confirm the one condition each number rests on.
- **Systemic note:** watch for the same pattern on other GTM/vendor-managed rows on this tracker
  (Optimizely, Crazy Egg, Didomi itself) — if a client challenges one of those next, the same
  "does it ride the existing data layer / is the capability already vendor-native" question is
  likely to collapse the estimate the same way, and is worth checking proactively rather than
  waiting for each row to be individually pushed back on.
