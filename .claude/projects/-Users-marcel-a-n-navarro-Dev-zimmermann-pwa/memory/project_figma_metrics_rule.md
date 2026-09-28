---
name: project-figma-metrics-rule
description: Figma TEXT nodes report a cap-height box and aren't comparable to CSS line boxes; frames and instances report real boxes and ARE comparable — check node type before calling a delta an artifact
metadata:
  node_type: memory
  type: project
  originSessionId: f5f727b4-7546-4aa6-9d86-ef229e247d3f
  modified: 2026-08-22T14:05:00.000Z
---

**The discriminator is node type, not a fudge factor.** An earlier version of this memory said
simply "Figma reports the glyph box, CSS reports the line box." That's only true of **text nodes**,
and the missing half is what makes the rule usable:

- **Text nodes** report a **cap-height box** (`text-box-trim: trim-both`, `text-box-edge:
  cap_alphabetic`). **Not comparable** to a CSS line box. Measured artifacts: "KEEP IN TOUCH" 8 vs
  18, body copy 26 vs 36, `errorText` 9 vs 18.
- **Frames and instances** report a **real box**. **Directly comparable** — so a delta here is a
  genuine defect. The `Textfield` *instance* at 44/59 against our 45/68 was a real gap, and the
  naive "it's just cap height" rule would have wrongly dismissed it.

**Supporting heuristic:** a *uniform* residual across siblings is measurement; a *varying* one is a
defect. Three contact items all sitting at +7 after every real cause was removed = the heading's
cap box.

**Transfer the rule, not the numbers.** In shipped `zimmNavItem.ts`, deriving from `lineHeight` +
4.5px padding produced 24/24/24/24/38 = 134 — exactly Figma's `Links` frame.

**There are TWO Figma files and comparisons must be like-for-like from one:**
`wPiWmZZOVKnrENUWk2XWWm` (design system) and `QQ427wHWEUjsjP7H8v48Rs` (composed page states).
Comparing an initial state from the design-system symbol against an error state from the page file
produced two wrong conclusions in a row — first "the slot is 59px in both states" (actually
`Subscribed=False` 320×44 vs `Subscribed=True` 308×59, with a compensating gap change 40→24: the
design **repositions**, it doesn't reserve), then a "reserve the slot" fix that suppressed intended
growth when the 68px padded box was already design-correct.

**Frames are not breakpoints.** Frames exist at 402/1023/1440; breakpoint tokens are 768/860/1024.
The unframed **768–1022 band was genuinely broken** (18px horizontal scroll, 7 wrapped labels) and
covers three iPad models in portrait. `flexWrap: nowrap` prevents *breaking*, not *shrinking* — the
row refused to break so the words broke instead.

**No automated gate in this stack catches a layout defect.** `width: 'xl'` resolving through
`theme.sizes` (36rem) blew contact icons to 576px and destroyed the footer on every page while
passing tsc, eslint, vitest, local *and* remote CodeRabbit, and Storybook a11y. Only rendering
beside Figma found it.

**Method notes:** measure `y` relative to the component root (Figma reports frame-relative
coordinates); use `domcontentloaded`, never `networkidle`, on a dev server; dismiss the consent
banner first; `Range.getClientRects()` gives per-line widths to *prove* a wrap point;
`document.fonts.check()` returns `true` for unavailable families and is useless — compare widths
instead; and **mutation-test layout fixes at mobile**, since two fixes read as Δ0 at 1440 only
because a taller sibling column masked them.

**How to apply:** before calling any Figma-vs-code delta an artifact, check the node type. Text →
likely artifact, verify uniformity. Frame or instance → treat as real. See
[[feedback-prove-dont-assert]] and [[project-chakra-scale-registration]].
