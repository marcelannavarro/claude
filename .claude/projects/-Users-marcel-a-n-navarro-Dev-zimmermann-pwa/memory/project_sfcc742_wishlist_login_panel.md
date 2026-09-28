---
name: project-sfcc742-wishlist-login-panel
description: "SFCC-742 gated twice (2026-09-01), plan amended for a ZimmTextInput atom gap; the shared-atom-gap pattern recurs on SFCC-588/347/590"
metadata: 
  node_type: memory
  type: project
  originSessionId: f28e1e9e-072a-43d6-a661-f8b33f1cdfb7
  modified: 2026-09-01T08:42:24.407Z
---

**SFCC-742 "Wishlist – Login Panel Content"** (Sprint 4, 3 pts, epic SFCC-2, assignee Jersey Perez Jr)
was PreBuild-gated **twice on 2026-09-01** — first pass 14:25 (adjudicated with Marcel, 2 × 🔴 cleared,
plan written 14:31), second independent pass ~16:30. Artefacts:
`~/Dev/zimmerMANN-skills/.runs/SFCC-742/` — `findings.md`, `findings-addendum-2.md`, `plan.md`
(amended; `plan.md.bak-preamend` holds the pre-amendment copy).

**The recurring trap this surfaced: Zimmermann's shared `ui-kits/atoms/` do not cover the design
system's full variant surface, and the gap is invisible to every automated gate.** Two instances on
this one story:

- `ZimmButton` — `primary`/`secondary` render `{label}` only, **no icon slot**; the `icon` variant is
  icon-only. Cannot build "SIGN IN WITH APPLE" (glyph + label).
- `ZimmTextInput` — the recipe has `parts` + `baseStyle` and **no `variants` key at all**; its only
  border is `borderBottom` (flush underline). Cannot build a boxed field. No `variant` prop exists.

Both were resolved the same way (Marcel, 2026-09-01): **extend the atom, additive, defaulting to the
existing behaviour** so no current consumer changes. Expect the same gap on **SFCC-588** (Login – OTP
Verification Input), **SFCC-590** (Login – Social Sign-In Buttons) and **SFCC-347** (Checkout – Social
Sign-In Buttons) — all Squad-A, all To Do, all needing these same controls. Adding `leadingIcon` under
SFCC-742 **pre-empts SFCC-590**, which should be re-pointed to "consume the atom" rather than
re-estimated as "build the buttons."

**Why no gate catches it:** `tsc`, eslint, vitest, CodeRabbit and the Storybook a11y run all pass with
the wrong border or a missing glyph slot. Only rendering beside Figma finds it — consistent with
[[prove-dont-assert]] and the FED handbook's "no automated gate in this stack catches a layout defect."

Two token conflicts confirmed live on this panel, both pre-existing and **not this story's to fix**:
`zimmButton.css.ts` `BTN_HEIGHT_LG = 50px` vs Figma/Handover **52px** (`actionSizes.height.lg`), and
Figma `alias/color/border/secondary` **#dddddd** vs repo `grey[200]` **#d1d1d1** — same alias name,
two values, both citing the 2026 Design System, provenance unresolved. Both are UI-designer calls.
See [[project-styling-layer-boundary]] and [[project-chakra-scale-registration]].

Dependency: **PR #67** (`feature/sfcc-736-pdp-drawer-tabs`, SFCC-736 `pdp/drawer`) is
`REVIEW_REQUIRED` **and `mergeable: CONFLICTING`** as of 2026-09-01. The plan correctly builds from
`develop` and only designs the seam against #67. ACs 1/2/9/10/11 are shell-satisfied by Chakra's
`Drawer` inside `ZimmDrawer` and must not be reimplemented in the content component.
