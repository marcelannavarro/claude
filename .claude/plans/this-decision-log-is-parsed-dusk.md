# Decision Record (§8) — key decisions only

_Trimmed to essentials for the reformatted SFCC-249 Contentful TSD. Full reformat plan: `if-we-execute-the-compressed-honey.md`._

| Date | Decision Maker | Decision | Rationale |
|---|---|---|---|
| Jul 2026 | Squad-A design (per TSD; endorsement TBC) | SFCC product/category IDs stored as **non-localized ShortText fields**; conditional rendering resolved in the **MRT SSR layer** — React components receive only pre-filtered entries and hold no ID-matching logic | Core design question of the spike; per-category/product conditional render, cache-keyed by the SFCC ID. Proposed design, not yet implemented in code |
| Jul 2026 | Tim Lavelle (SA) | **One Contentful Space + Environments per tier** (not multiple Spaces) | Environments already bootstrapped; correct approach |
| Jul 2026 | Tim Lavelle (SA) | **MRT-app architecture out of scope** here → separate TSD (SFCC-237) | Keep this TSD scoped to one problem |
| Jul 2026 | Jhoan + Tim | **Sprint-1 content types confirmed; Sprint-2 provisional** pending Emma & Dani authoring review | Sprint-2 fields inferred, not confirmed schema |
| Jul 2026 | Tim / Marcel | **New Relic** as observability tool; alerts recommended **pending procurement** | Per Observability deck; procurement raised with Emma/IT |

**Sign-off:** Author = Jhoan Rose Dela Cruz; Reviewers = Jasmijn Tsang (BA Lead) + Tim Lavelle (SA).

**Deliberately excluded (kept out to stay essentials-only):**
- Process/timeline (kickoff, first draft, SFCC-123→SFCC-249 spillover, "feedback incorporated") → Version History.
- Corrections/findings (SFCC-14 is an Epic; locale count = 9) → §2 Constraints / notes.
- Still-open items (product-image/DC002, PLP-inject feasibility spike, handoff boundary, cache/degradation stance) → §7 Risks — a Decision Record holds *settled* calls only.

## Execution notes (apply when reformatting)
- **§3 Options Analysis = SINGLE OPTION, and it is Option A (decided by Marcel, 2026-07-31).** Legitimate per the "one option if that's genuinely all there is" rule. Write A properly: state it, give pros/cons, give a recommendation. Constraints on how it's framed:
  - **Scope A to page-scoping only** (which Contentful entries render on which SFCC page): non-localized ShortText `sfccCategoryId`/`sfccProductId` + MRT SSR-side filtering + presentation-only components (no ID logic) + cache key includes the SFCC ID; null = show-on-all. Do NOT let §3 imply A also solves reference-resolution (ID -> commerce data) — that half is explicitly out of SFCC-123's scope and owned by **SFCC-238** (installed Contentful App for SFCC connector; ruling on SSR fetch-and-pass-down vs client-side leaf `useProduct`). Cross-reference SFCC-238; do not pre-empt its ruling.
  - **State the one genuine trade-off:** raw author-typed ShortText (typo risk, no referential integrity) vs the now-installed connector app's structured picker — SFCC-238 may revise the field mechanic. Presenting the alternative honestly is what makes a single-option §3 defensible, not padding.
  - **Still gated on Tim's explicit endorsement** before A enters the Decision Record as settled (see decision-maker note below) — silence in the 24 page comments is not sign-off.
- **Formal language:** rephrase informal/colloquial wording into formal TSD prose. The source draft uses "components remain dumb and reusable" (Key Design Decisions) — replace with e.g. "presentation-only components that hold no ID-matching logic." Scan the whole doc for similar colloquialisms, not just this row.
- **Confirm decision-maker for the SFCC-ID pattern:** currently "Squad-A design (per TSD)" with no explicit SA endorsement recorded — confirm with Tim/Jhoan before it goes in the Decision Record as a settled call.
- **Source note:** the SFCC-ID pattern is documented only in the TSD draft (Confluence 346783750, "SFCC Product & Category ID Reference Pattern" + "Key Design Decisions") — it is a proposed design, not implemented in code and not sourced from any other doc.
