# SFCC-236: fix two live-testing regressions in ZimmProductCard

## Context

While testing PR #85 (`feature/SFCC-236_product-card-shared-component`) live, Marcel found two
real bugs in the shared `ZimmProductCard` family:

**(a) A recent hover-reveal fix broke keyboard nav and VoiceOver.** The most recent fix on this
branch (`983bddf`) replaced `:focus-within` with `:has(:focus-visible)` across five hover-reveal
sites, specifically to stop the carousel arrows (and everything else gated the same way) from
staying visible after a mouse click even once the mouse moved away — a real, correctly-diagnosed
bug, and that part of the fix is not being reverted. The regression is elsewhere: every one of
those five reveals uses `display: 'none'` as its "hidden" state, gated behind an *interaction*
heuristic (`:hover`/`:has(:focus-visible)`). `display: none` unconditionally strips an element
from the accessibility tree — it answers "is this painted," not "does this exist for assistive
tech," and this recipe has been using it to answer both questions at once. `:focus-visible` is
itself a browser heuristic for "does this focus event look keyboard-like," and VoiceOver-driven
focus (VO+Arrow, rotor, swipe) is not guaranteed to satisfy it in every engine — a real, documented
mismatch, and *not* a touch-only concern: `(hover: hover) and (pointer: fine)` is true on any Mac
trackpad, so a VoiceOver user on ordinary MacBook hardware is exactly the population this gate
applies to. If that heuristic never matches for a given user, all five reveals (carousel arrows,
Home's price reveal, PLP/Wishlist's price↔size-selector swap, notify-me) stay invisible to them
for the entire session, no matter how they navigate. A secondary, lower-severity effect confirmed
alongside it: because these controls only exist as Tab stops *while* the interaction condition is
currently true, Shift+Tab entry into the card from something after it lands on the last
unconditionally-visible stop (the bag button) — the user has already tabbed past controls that,
at that instant, didn't exist yet, and must reverse direction to reach them. (Forward-Tab is fine:
landing on the always-present scroll container triggers the reveal before reaching the arrows.)

**(b) Multi-image cards don't respond to touch swipe on mobile.** The slide indicator renders
correctly (so the image data and gallery logic are fine), but swiping the image doesn't page
through it at all. Root cause: the organism's whole-card stretched-link overlay
(`[data-card-slot="content"] a::after`, `position: absolute; inset: 0`) resolves its containing
block to the organism root — because `ZimmProductCardContent` never sets `position` anywhere —
so it's sized to the *entire* card, image included, not just the name-link row. That overlay
carries no `z-index`, and the recipe already lifts exactly three things above it (`close`,
`carousel`, buttons inside `content`) — the media/gallery scroll region was never added to that
list. A touch swipe on the image actually starts on the invisible overlay `<a>`, so the browser's
native swipe-scroll gesture never engages the real scroll container at all.

Both root causes were confirmed via direct investigation of this exact code (file/line citations
below) before any fix was designed, and both fixes reuse patterns already shipped elsewhere in
this same codebase rather than inventing anything new — `ZimmColourSwatchGroup`'s already-tested
off-page-swatch technique for (a), and this recipe's own existing z-index-lift pattern for (b).

## Fix (b) — swipe blocked by the stretched-link overlay

**File:** `overrides/app/components/ui-kits/organisms/zimmProductCard/zimmProductCard.css.ts`

- Add a fourth lift entry alongside the existing three (currently lines 240-253):
  ```
  [`[data-card-slot="${CARD_SLOT.media}"]`]: { zIndex: 1 },
  ```
  `ZimmProductCardMedia`'s own root is already `position: 'relative'` (its own recipe), so only
  `zIndex` is needed here — identical in shape to the existing `close`/`carousel` entries.
- Extend docblock point 2 (the "lifting every interactive control" explanation, ~lines 62-101)
  with a new dated fix note, continuing this file's own Fix 1/Fix 3/Fix H lettered convention,
  explaining the media/gallery region needed the same lift the click targets already got, and
  that this was missed because clicking `close`/`carousel`/content-buttons was checked live but
  swiping the image itself never was.
- Extend `index.test.tsx`'s existing z-index-lift describe block (or add a sibling one) to assert
  the new entry's object shape, matching that file's own established idiom for these proofs.

**Verification:** jsdom cannot prove this (no stacking-context resolution — this file's own
"KNOWN LIMITATION" docblock already says so). Needs a real touch check: Playwright's
`mobile-chrome` project with a real drag/swipe gesture on the image, or Marcel's own device,
confirming the gallery pages and the indicator updates.

## Fix (a) — hover-reveal content invisible to VoiceOver / skipped on Shift+Tab

**Files:** `zimmProductCard.css.ts` (all 5 reveal sites) and
`overrides/app/components/ui-kits/molecules/zimmProductCardMedia/zimmProductCardMedia.css.ts`
(carousel's own base state)

**Recommended fix** — keep every one of the five reveal targets permanently present in the DOM,
focusable, and in the accessibility tree at all times. Stop using `display` to express "hidden";
use the exact technique `ZimmColourSwatchGroup` already ships for its own off-page swatches
(confirmed real, `molecules/zimmColourSwatchGroup/index.tsx:215`:
`{ position: 'absolute', clipPath: 'inset(50%)' }`):

- **Hidden (default) state:** `position: 'absolute'`, `clipPath: 'inset(50%)'` instead of
  `display: 'none'` — out of flow (no layout gap, same as today), paints nothing, but stays in
  the DOM/tab order/accessibility tree.
- **Revealed state** (same `&:hover [...]` / `&:has(:focus-visible) [...]` selectors, byte-for-byte
  unchanged): `position: 'static'`, `clipPath: 'none'` instead of `display: 'block'/'flex'`.
- Applies at all 5 sites in `zimmProductCard.css.ts`: Home price reveal (~293-297, 323-325),
  PLP/Wishlist price hide (~330-332, 338-340), PLP/Wishlist size-selector reveal (~344-346,
  348-350), notify-me reveal (~359-362, 364-366), carousel arrow reveal (~379-384).
- `zimmProductCardMedia.css.ts`'s `carousel` part: its own unconditional base `display: 'none'`
  becomes the same clip-path equivalent (already `position: 'absolute'` unconditionally, so only
  the hidden-state property changes).
- **Carousel-specific addition:** the wrapper deliberately sets `pointerEvents: 'none'` with each
  `arrowButton` individually re-enabling `pointerEvents: 'auto'` (so clicks in the empty centre
  pass through to the image). Once the wrapper is no longer `display:none`, add an explicit
  belt-and-braces rule in the organism recipe — `[data-card-slot="carousel"] button` gets
  `pointerEvents: 'none'` by default and `'auto'` only in the two revealed selectors — rather than
  relying on clip-path's hit-testing suppression alone. (Price/size-selector/notify-me need no
  equivalent — none of them sets `pointerEvents` at all today.)

**Why this is the recommended path, not one of several open options** (a JS-tracked hover/focus
state was considered and rejected): there is no signal exposed to page-level JavaScript, any more
than to CSS, that says "this focus event was AT-originated." A hand-rolled heuristic (e.g.
flagging `focusin` as non-keyboard when preceded by `pointerdown`) has exactly the same blind spot
as the native `:focus-visible` heuristic it would be reimplementing. It would also break this
organism's own stated design principle ("CSS alone decides what is visible... no JS-tracked reveal
state," `index.tsx` ~349-350) and introduce real SSR/hydration-mismatch risk pure CSS structurally
can't have, for no correctness gain.

**Why this doesn't reintroduce the `983bddf` stuck-open bug:** that bug was entirely about *when*
`:has(:focus-visible)` matches (a click-focused button not un-matching on mouseout until focus
moved elsewhere) — a selector-matching-timing question, completely orthogonal to which property
the matched rule sets. The trigger selectors aren't touched at all; only the property values
inside the already-existing blocks change.

**Docblock updates:** extend/rewrite docblock points 3 and 6 and the "Fix H" note with a new dated
fix note (continuing the lettered sequence), stating explicitly that Fix H's `:focus-within` →
`:has(:focus-visible)` swap was and remains correct for the paint-timing question it solved, and
that the actual defect was using `display` (an AT-tree-removal property) to answer a different
question than the one it should answer. Explicitly out of scope, left as `display:none`: the
permanent, non-hover-capable-pointer hides (`sizeSelectorUnavailable`'s unconditional size-chip
hide, the PLP-mobile bag-icon hide) — separate, correct, Figma-confirmed, non-regressed decisions,
since nothing about them is gated behind an interaction heuristic.

**Test updates:** the existing `.matches()`-based selector-proof describe block in
`index.test.tsx` needs no change (it doesn't depend on which property the matched rule sets). Any
structural/object-shape assertions elsewhere in the same file checking the recipe's declared
`display` values for these 5 sites need updating to the new property values — identify the exact
assertions at implementation time against the real current file, don't guess line numbers here.

**New real-browser verification** (jsdom can't prove any of this): this repo already has
scaffolded-but-empty Playwright a11y projects (`playwright.config.js`'s `a11y-desktop` →
`e2e/tests/a11y/desktop`, `a11y-mobile` → `e2e/tests/a11y/mobile`; both Chromium-only, no WebKit
project configured — not touching `playwright.config.js` itself, only adding specs inside the
already-existing target directories). Add specs for:

1. **Accessibility-tree presence** — load a card in its default (non-hovered, non-focused) state
   and assert, via a real Chromium accessibility-tree snapshot, that the size-chip radiogroup,
   notify-me button, and carousel arrow buttons are present with correct role/name — proving
   AT-tree presence no longer depends on any hover/focus-visible condition having matched.
2. **Tab-order parity** — forward-Tab from before the card and Shift+Tab from after it, asserting
   the stop set/sequence is now identical in both directions (today Shift+Tab skips the
   reveal-gated controls entirely).
3. **No regression on the original stuck-open bug** — real mouse click on an arrow button, move
   the mouse off the card, assert the control is no longer visually painted by reading
   `getComputedStyle(el).clipPath` directly (Playwright's default `toBeVisible()` is primarily a
   bounding-box/`visibility` check and may not reliably catch clip-path-based hiding).

**Honest limitation, not skippable:** the actual disputed claim — does real VoiceOver announce and
activate these controls — can't be fully closed out by any automated check above. Chromium's
accessibility tree isn't the engine VoiceOver actually talks to (WebKit), no WebKit Playwright
project exists in this repo, and Playwright can't drive real VoiceOver at all. The automated specs
give strong, real regression-prevention signal (AT-tree presence + tab-order parity are both real,
previously-uncaught bugs), but final confirmation needs one manual pass from Marcel: navigate a
card via VO+Right-Arrow/rotor only (no mouse, no literal Tab keypress) on real macOS Safari +
VoiceOver, confirming price, the size-chip radiogroup, notify-me, and the carousel arrows are all
announced and activatable via VO+Space.

## Verification (both fixes)

1. `npx tsc --noEmit` clean.
2. Full local Storybook build + `test-storybook --ci` — same pattern used earlier on this branch
   for the axe-contrast fix; confirms no regression across the whole story set.
3. Updated/new Vitest assertions in both `index.test.tsx` files pass.
4. New Playwright a11y specs (AT-tree presence, tab-order parity, stuck-open non-regression) pass.
5. Real-device/manual checks, both required before calling this done:
   - Real touch swipe (device or Playwright mobile-chrome touch simulation) confirms gallery
     paging works.
   - Real VoiceOver + Safari pass (Marcel, one-time) confirms AT reachability/activation for all
     five previously-broken controls.

## Files touched

All within one protection tier — squad-owned `ui-kits` component recipes/tests, no Tier 1/2 file:

- `overrides/app/components/ui-kits/organisms/zimmProductCard/zimmProductCard.css.ts`
- `overrides/app/components/ui-kits/organisms/zimmProductCard/index.test.tsx`
- `overrides/app/components/ui-kits/molecules/zimmProductCardMedia/zimmProductCardMedia.css.ts`
- `overrides/app/components/ui-kits/molecules/zimmProductCardMedia/index.test.tsx` (only if the
  carousel base-state change needs an assertion update there too — confirm at implementation time)
- New: `e2e/tests/a11y/desktop/*.spec.ts`, `e2e/tests/a11y/mobile/*.spec.ts` (exact filenames
  follow this repo's existing spec-naming convention, decided at implementation time)
