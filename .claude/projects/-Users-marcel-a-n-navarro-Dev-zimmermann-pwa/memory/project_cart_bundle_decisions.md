---
name: project-cart-bundle-decisions
description: Seven Sprint 5 Cart stories planned as one bundled build; full decision record lives in .claude/session-notes.md
metadata:
  type: project
---

2026-09-16: ran a card-by-card requirements pass over the seven Sprint 5 Cart stories
(SFCC-315, 270, 795, 271, 272, 250, 275 — all Epic SFCC-11, Squad-A, Marcel). No code written.

**The full decision record — every AC adjudicated, every verified finding with its evidence, the
Jira comments to post, follow-up stories to file, and build order — is in
`.claude/session-notes.md`** (gitignored, auto-read by the session-start skill). Read that rather
than re-deriving any of it.

Headlines: one gather pass and one plan, but **staged PRs, not one mega-PR** — except SFCC-250 and
SFCC-272, which are welded at the cart's `onAuthSuccess` seam. **SFCC-315 ships first and
standalone** because SFCC-316 (Jhoan, same sprint) depends on it. Cart PRs currently get **no
PR-time E2E** — `qa.yml` has no `cart` area, so they resolve to `e2e_scope: skip`.

**Reading lesson worth keeping:** a `see SFCC-NNN` or "Relates to" inside an AC usually points at
where the design or detail lives, **not** at a gate. Treat it as a dependency only when the card
says so outright. I wrongly called SFCC-271, SFCC-275 and one of SFCC-272's ACs blocked on that
basis and had to correct each.

**How to apply:** before planning any further cart story, read `.claude/session-notes.md` first.
Related: [[project-cart-merge-mechanics]], [[project-max-order-quantity]],
[[reference-jira-ac-field]].
