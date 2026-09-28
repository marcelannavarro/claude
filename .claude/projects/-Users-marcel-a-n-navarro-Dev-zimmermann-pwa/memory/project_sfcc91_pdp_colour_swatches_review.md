---
name: project_sfcc91_pdp_colour_swatches_review
description: "PR #70 (SFCC-91 PDP colour swatches) reworked by Jhoan 2026-09-01/02 — CI green, Marcel's 3 findings appear structurally fixed via a render-prop rewrite, but Marcel has not yet re-reviewed/approved"
metadata: 
  node_type: memory
  type: project
  modified: 2026-09-02T03:11:38.425Z
  originSessionId: 62d27430-c67e-4777-87a2-a835a9db58ab
---

PR #70 "feat(pdp): colour swatches and variation selection (SFCC-91)", authored by Jhoan Dela
Cruz (`JhoanDelaCruz`), targets `develop` from
`feature/SFCC-91_pdp-ui-colour-swatches-variation-selection`. **This entry supersedes the
2026-09-01 version, which was stale on both open findings** — verified fresh against the PR's
live HEAD (`92dbf97`, 2026-09-02) after discovering local was ~70 commits behind origin.

**Timeline:** Marcel left CHANGES_REQUESTED 2026-08-31 with 3 blocking findings (sold-out-
everywhere regression, broken new E2E spec, square swatches leaking into shared `product-view`).
Jhoan's immediate follow-ups (836a77b, a9999ec, 2026-09-01 morning) only fixed CodeRabbit nits —
matching what the old memory entry recorded. But later the same day (`ecd64cc`..`842a77f`,
2026-09-01 17:33–19:28) Jhoan pushed a substantial rework that the old entry never saw.

**Current state of the 3 findings, verified at the code level (not re-tested live):**
1. **Sold-out-everywhere** — the old `suppressColourAttribute` boolean flag is gone entirely.
   `product-view/index.tsx` now takes a `renderVariationAttribute` render-prop; the PDP
   (`product-detail/index.tsx:916`) always returns the new `ZimmColourSwatchGroup` molecule for
   the colour attribute (never falls through to the old picker). The molecule has an explicit
   regression test — "renders nothing when every value fails the imageUrl/orderable filter"
   (`zimmColourSwatchGroup/index.test.tsx`) — asserting `container.firstChild` is null. Looks
   fixed by construction, not by patching the old flag.
2. **Broken E2E spec** — deleted outright in `7513571` (chore commit, predates even the stale
   memory). Resolved by removal, not by fixing the fixtures.
3. **Square swatches leaking into `product-view`** — the base `SwatchGroup` fallback path (still
   used by cart-edit/wishlist/bonus-product callers that don't pass `renderVariationAttribute`)
   now reads `variant={id === 'color' ? 'circle' : 'square'}` — correctly scoped again.

**CI and review status (live, 2026-09-02):** All PR #70 checks green, including Storybook
interaction/a11y (the old memory's "SevenColours pagination" failure is gone — not root-caused,
just no longer reproducing after the rework). Every one of Marcel's 3 review-thread comments
shows `isResolved: true` via the GraphQL API. **But** `reviewDecision` is still
`CHANGES_REQUESTED` — thread resolution doesn't clear a PR-level review verdict, only a fresh
review does, and no `marcelannavarro` review exists after the 2026-08-31 CHANGES_REQUESTED one.

**Why:** branch protection blocks merge on the outstanding CHANGES_REQUESTED regardless of what
CI or thread-resolution shows.
**How to apply:** the code-level read above is a diff review, not a live-UI verification — treat
it as "very likely fixed," not confirmed, until someone actually exercises the sold-out-everywhere
case and the cart/wishlist/modal swatch shape in a running app. The natural next step on this PR
is a fresh review pass (re-check `gh pr view 70 --json reviewDecision,statusCheckRollup` first in
case Jhoan or CodeRabbit moved it again) and, if it holds up, Marcel clearing his own
CHANGES_REQUESTED. Also note: the branch's HEAD (`92dbf97`) is a merge of `develop` that pulled in
the entire unrelated SFCC-52 global header epic (PR #65) — a large, separate diff sitting in the
same branch history, not part of SFCC-91's own change.
