# Fix: Was/Now sale price forces horizontal overflow on mobile

## Context

On `feature/zimmproductcard-live-demo`, the live homepage demo's "Sale Price" card (Core
Component group) shows the was/now price treatment overflowing horizontally on mobile,
extending the page's scrollable width past the viewport. This is a real layout bug in the
shared `ZimmProductPrice` atom, not something specific to the demo page — the demo just
happens to be the first place it's been exercised at a genuine narrow viewport (confirmed via
direct code reading: every existing Storybook story for this treatment uses a fixed-pixel
`Box` decorator, not a real `parameters.viewport` resize, so this gap was never caught before).

## Root cause (confirmed via direct code reading, not guessed)

`zimmProductPrice/index.tsx` renders the sale treatment as one flex row
(`<chakra.p __css={styles.container}>`) containing two flex-item spans — `wasPrice`
("Was $795.00") and `nowPrice` ("Now $595.00") — separated by a literal space.

`zimmProductPrice.css.ts`'s `sale.container` (lines 45-57) sets `display: 'inline-flex'` and
`whiteSpace: 'nowrap'`, but **never sets `flexWrap`**, so it defaults to `nowrap`. This is the
actual bug: `whiteSpace: 'nowrap'` is correct and should stay — it's what keeps "Was" from
separating from its own "$795.00" — but with no `flexWrap`, the two spans are also forced to
stay on one line as flex items, regardless of available width. On a narrow mobile column, the
combined "Was $795.00 Now $595.00" row doesn't fit, and because none of its ancestors
(`priceWrapper`/`root` in `zimmProductCardContent.css.ts`, `ZimmProductCard`'s own root) set
`overflow: hidden` or a `maxWidth`, the overflow isn't clipped — it paints past the card's edges
and widens the page's actual scrollable area.

A secondary contributor: `priceWrapper` (`zimmProductCardContent.css.ts` lines 175-177) is a
direct flex item of `root`'s column flex container but sets no `minWidth` — flex items default
to `min-width: auto`, which refuses to shrink below content's min-content size. Once the price
row can't wrap, this compounds the blowout instead of containing it.

No Figma mobile-specific was/now node is cited anywhere in `zimmProductPrice.css.ts` (only one
node, `40001132:7331`, unlike `zimmProductCardContent.css.ts`'s root, which explicitly cites
separate Desktop/Mobile nodes) — there's no confirmed spec for exactly how this should wrap on
mobile. Flagging this rather than guessing a pixel-perfect answer: the fix below applies the
standard, safe default (allow the row to wrap when it doesn't fit) rather than inventing a
specific mobile treatment with no design reference.

## Fix

**1. `overrides/app/components/ui-kits/atoms/zimmProductPrice/zimmProductPrice.css.ts`**
Add `flexWrap: 'wrap'` to `sale.container` (alongside the existing `display: 'inline-flex'`).
Deliberately **unconditional**, not gated behind `DESKTOP_QUERY` — wrapping capability costs
nothing when both spans already fit (the normal desktop case, where they'll keep rendering
side by side), and this project targets WCAG 2.2 AA, which includes 1.4.10 Reflow: content
must not require horizontal scrolling at a 320px-equivalent width, including at 400% zoom on a
*desktop* viewport. Gating this to mobile-only would leave that same reflow failure reachable
on desktop at high zoom. `whiteSpace: 'nowrap'` stays exactly as-is on the same `container` —
it's still correctly keeping each individual span's own label+number together; only the
missing flex-line-wrap behavior is being added.

**2. `overrides/app/components/ui-kits/molecules/zimmProductCardContent/zimmProductCardContent.css.ts`**
Add `minWidth: 0` to `priceWrapper` (lines 175-177) — cheap, standard defensive hardening for
a flex item that has no width-related property today, so it can shrink to the space actually
available instead of being floored by its content's min-content size. Belt-and-braces
alongside fix 1, not a substitute for it.

Both files are co-located `<name>.css.ts` recipes (squad-owned per CODEOWNERS' `**/*.css.ts`
rule, not Tier 1/2 UI-designer-gated — see `overrideStyling.md`'s co-location section), so no
approval gate applies.

## Out of scope, flagged not fixed

`zimmProductContent.css.ts` (the PDP-facing consumer of the same `ZimmProductPrice` atom) has
a structurally similar flex-item gap (`alignItems: 'flex-start'`, no `minWidth` on the price's
slot) — fix 1 above (the actual root cause, in the shared atom) already resolves the overflow
for this consumer too, since it no longer produces an unwrappable wide row in the first place.
Not adding the same defensive `minWidth: 0` there in this pass since it's not the reported
context and wasn't independently confirmed broken — worth a follow-up if it turns out to matter.

## Files touched

- `overrides/app/components/ui-kits/atoms/zimmProductPrice/zimmProductPrice.css.ts` (fix)
- `overrides/app/components/ui-kits/molecules/zimmProductCardContent/zimmProductCardContent.css.ts` (defensive hardening)
- `overrides/app/components/ui-kits/atoms/zimmProductPrice/index.test.tsx` and/or a sibling
  test file — extend with a structural assertion on the recipe object for the new `flexWrap`/
  `minWidth` values, matching this codebase's existing "assert the styles object shape" pattern
  (same approach already used for this session's earlier Fix J/K test updates). Exact
  file/existing assertions to confirm at implementation time.
- No demo-file change needed — the existing "Sale Price" card in
  `liveProductCardDemoSection.tsx`'s Core Component group already exercises this treatment and
  is what to manually re-check.

## Verification

1. `npx tsc --noEmit` clean.
2. Updated/new Vitest assertions pass.
3. Manual/real-viewport check (jsdom can't prove actual flex-wrap line-breaking): resize to
   ~375px against the live demo's "Sale Price" card and the `WithSalePrice` Storybook stories
   (`zimmProductCardContent`, `zimmProductCard`) — confirm the row now wraps to two lines
   instead of overflowing, and confirm desktop-width rendering is visually unchanged (both
   spans still fit on one line there).
4. `npm run audit:tokens` not implicated — no new raw hex/px/rem values introduced, only
   keyword (`wrap`) and numeric (`0`) CSS properties.
