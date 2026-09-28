---
name: project-sfcc266-pr111-review
description: "PR #111 (SFCC-266, EU Environmental Qualities PDP tab) review findings that outlive the PR itself"
metadata: 
  node_type: memory
  type: project
  originSessionId: f4400464-2081-4e6b-a2cf-b7c0c8f6b68e
  modified: 2026-09-15T11:33:44.290Z
---

Reviewed 2026-09-15 (zimmerMANNReview). Approved with 2 non-blocking asks (missing test for the
tab gating/fallback logic, lint fix). Two structural gaps found don't belong to this PR and were
deliberately kept off its review thread — tracked here instead so they aren't rediscovered cold.

**`overrides/app/utils/richText.tsx`'s tag allow-list has no `<a>`.** Any hyperlink inside
SFCC-sourced rich text (AP21 `environmentalNotes`, BM site-pref `environmentalMessage`, and
presumably any other field routed through `ZimmProductDescription`) gets silently unwrapped to
plain unclickable text — confirmed live, no security implication (attributes never reach
`createElement`), just a fidelity gap. First real case that needed it was SFCC-266's "Packaging"
link (Figma shows it underlined; Jira SFCC-765 comment 14498 authors it as a real link). Whoever
picks this up next should extend `ALLOWED_TAGS` with `'a'` plus `href`/`target` attribute
handling — it's shared code, not scoped to one PR.
**Why it matters:** will resurface on any future ticket that routes a real link through this
parser, not just SFCC-266.
**How to apply:** flag it the moment a new ticket's content needs a working link; don't assume
it already works because the tag renders.

**`ZimmProductDescription`'s own recipe (`zimmProductDescription.css.ts`) owns paragraph
spacing (currently 20px, explicitly flagged there as provisional/pending UI-designer sign-off),
but `environmentalQualitiesContent.tsx` overrides it to 64px from outside via a `sx` selector
reaching into the atom's internal markup.** Confirmed live: it's also a no-op whenever the
content renders as a single text run (no siblings for `* + *` to select), which is the likely
case for the BM fallback message and possibly for AP21 notes too (SFCC-26's sample value reads
as plain/markdown text, not `<p>`-tagged HTML) — unconfirmed end-to-end, no product in the test
catalog currently has real `environmentalNotes` populated to check.
**Why it matters:** the correct fix is a variant on `ZimmProductDescription`'s own recipe, not
another consumer-side override — see [[project_styling_layer_boundary]] for the same class of
mistake elsewhere in this codebase.
**How to apply:** next time this recipe's spacing value comes up for actual designer sign-off,
resolve both the 20px-vs-64px question and this override in the same pass.

**Squad-ownership docs contradict the real gate.** `.claude/rules/squadA.md` and `squadB.md`
both claim `overrides/app/pages/product-detail/` and `product-list/` as Squad A territory.
CODEOWNERS actually routes both to `@ZimmermannAU/pwa-squad-b` — confirmed this is what's really
enforced (explains why GitHub auto-requested Squad B review on a PR whose own body table claimed
Squad A ownership). Nobody has reconciled this; flagged to Marcel, no ticket raised yet.
**Why it matters:** CODEOWNERS is what actually gates merges, so nothing is unsafe, but the two
draft docs will keep misdirecting whoever reads them for "who do I notify" purposes.
**How to apply:** don't trust squadA.md/squadB.md for `product-detail/`/`product-list/`
ownership without cross-checking CODEOWNERS first.

**Locale-key mismatch, unresolved.** Jira SFCC-266/SFCC-765 and the SFCC-side PR
(zimmermann-sfcc#39) describe the BM site preference as seeded with `en_FR`/`fr_FR`. This repo's
`config/sites.overlay.js` routes `/en-eu/` → locale `en-GB`, `/fr-eu/` → locale `fr`. The feature
empirically still works correctly on the live PR preview for both routes, so either the SFCC-side
docs are stale or there's a normalization step invisible from this repo. Not verified either way.
**Why it matters:** if it's really a mismatch and not normalization, it's fragile — a future BM
preferences change matching the *documented* locale keys instead of the *real* ones could
silently break the gate.
**How to apply:** worth a two-minute confirmation with Integration before it's built on top of
again; don't assume either side is correct.
