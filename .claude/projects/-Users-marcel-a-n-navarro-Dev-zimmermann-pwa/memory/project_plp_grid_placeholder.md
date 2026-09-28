---
name: project-plp-grid-placeholder
description: "PLP still renders through a placeholder SimpleGrid, not the final Zimm grid — card-width symptoms (e.g. size-chip overflow) trace back to this, not to the shared card components"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4f143a27-bda5-4ed2-89a8-612349f0631d
  modified: 2026-09-10T11:14:06.414Z
---

PLP's product grid (`overrides/app/pages/product-list/index.tsx`) still renders via a placeholder
`SimpleGrid columns={[2, 2, 4, 5]}`, not the finished Zimm-designed grid (4 columns, cards capped
at exactly 288px) that Full History (`ZimmRecentlyViewedGrid`) and the Rail already use. At a
typical desktop viewport this produces cards roughly ~200px wide — meaningfully narrower than the
~288px the shared product card (and everything inside it, e.g. the size-chip row) is actually
designed against.

**Why:** PLP was explicitly built as a "quick test integration" (SFCC-83/84) to exercise
`ZimmProductCard` on a real page before a dedicated PLP grid component existed — the page's own
code comment already says this. Confirmed concretely 2026-09-10 while investigating a reported
size-chip-group regression: computed PLP's actual available card content width from its own layout
math (sidebar width, gaps, page padding) and showed that six fixed-28px chips (168px minimum, even
at zero gap) already exceed the ~122px of content-box width a ~200px placeholder card leaves after
its own 40px×2 padding. The chip row was never going to fit — not because of a chip-spacing bug,
but because the card itself is too narrow. Marcel confirmed: leave as-is, waiting on the real Zimm
PLP grid implementation; this is a known, already-accepted interim state, not a regression.

**How to apply:** if a future card-content overflow/spacing symptom shows up specifically on PLP
(not on Full History or the Rail, which already use the real grid), check PLP's own card width
first before assuming the shared card/size-chip components are broken — they may be completely
correct and simply not have enough room on PLP's current placeholder grid. The real fix is
building PLP's own final grid (a separate, larger piece of work), not re-touching the shared card
components. See [[project_sfcc55_footer_state]]-style precedent: don't re-diagnose a known,
already-explained gap from scratch.
