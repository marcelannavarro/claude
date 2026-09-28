---
name: project-chakra-scale-registration
description: Only space/colors/fonts/borderWidths/breakpoints/textStyles are registered in the Chakra theme — sizes, fontSizes, lineHeights and letterSpacings are NOT, so bare token keys on those props silently misresolve
metadata:
  node_type: memory
  type: project
  originSessionId: f5f727b4-7546-4aa6-9d86-ef229e247d3f
  modified: 2026-08-22T02:20:00.000Z
---

`overrides/app/theme/index.ts` registers the Zimmermann scale as **`space` only**
(`space: spacing`, line 56). `sizes`, `fontSizes`, `lineHeights` and `letterSpacings` are
deliberately **not** registered. Consequences, both measured during SFCC-55 (session 652997c6):

- **Sizing props** (`width`/`height`/`boxSize`/`min|maxWidth|Height`) resolve through
  `theme.sizes`, so a bare key falls through to Chakra's defaults — measured blow-up range
  **8×–112×** (`width: 'xl'` rendered footer contact icons at **576px**). Worse, `s`/`m`/`l` are
  **absent** from Chakra's `sizes`, so those declarations are dropped entirely and silently.
- **Typography props** have the same twin: `fontSize: '2xs'` emits 0.625rem where 0.875rem was
  intended, and `'4xs'` emits nothing at all.

**Always use the CSS var on those props** — `width: 'var(--zimm-scale-xl)'`, never `width: 'xl'`.
Spacing props (`margin`/`padding`/`gap`) are fine with bare keys.

Two related traps from the same work: Chakra resolves a token only as the **entire** value, so
`padding: 'xs 0'` is emitted verbatim and dropped by the browser (use axis props); and a
shorthand declared *after* a longhand resets it (`padding: 0` after `paddingBlock` — use
`paddingInline`).

**Live unfixed instance:** `overrides/app/components/header/index.tsx:311` has
`fontSize="l"`, which emits nothing. Pre-existing, outside the footer scope, still there as of
2026-08-22.

**Why:** these fail silently — no error, no warning, just wrong or absent CSS. The 576px icon
bug destroyed the entire footer layout before the cause was found.

**How to apply:** `recipeGuards.test.ts` guards the first two cases (bare key on a sizing prop,
bare key in a compound shorthand) and is mutation-verified — run it after touching any recipe.
`theme/index.ts`'s own header comment lists what is and isn't registered.
