---
name: project-styling-layer-boundary
description: Where brand values belong — recipes, not JSX — and the var() rule that inverted; corrected 2026-08-25
metadata:
  type: project
---

**CORRECTED 2026-08-25.** An earlier version of this memory said *"`var(--zimm-*)` in component
JSX is the violation."* That is **no longer the rule** and following it now fails review.
`.claude/rules/overrideStyling.md` hierarchy point 2 and `css.md` both say the opposite: in an
override component, **never** a bare Chakra/theme token string (`color="text.default"`,
`gap="m"`) — use the raw `var(--zimm-*)` reference. The stated reason is house style, not
correctness: a bare key resolves identically but forces a reviewer to check `theme/index.ts`'s
registered-scale list to know whether it happens to be right.

**What survives from the old note, and is still the main point:** brand values mostly shouldn't
be in JSX *at all*. Measured on `develop` 2026-08-25 — `var(--zimm-*)` appears in **18 recipe
files** (14 co-located `<name>.css.ts` + 4 `theme/components/*.ts`) and in exactly **one**
component `.tsx` (`footer/footerNavColumn/index.tsx`, for a conditional `paddingLeft` that no
Chakra prop expresses). So the practice is: type via `textStyle`, everything else in the recipe,
`var()` in JSX only for a genuine prop-system gap.

**Live violations right now:** `ui-kits/atoms/zimmProductName/index.tsx:20` and
`zimmProductModelInfo/index.tsx:23` both use `color="text.default"`. Both are in the staged,
uncommitted product-view work — worth fixing before that lands.

**Enforcement is half-covered.** `theme/components/recipeGuards.test.ts` fails the build on a
bare token key, but it walks the registered recipe map only — it cannot see the same mistake made
as a JSX or `sx` prop. That half is manual review.

**The original PR #56 lesson still stands:** the token pipeline is `foundation/*.ts` (Tier 1
source) → `zimmTokens.ts` (**derived — never hand-edit**) → recipes. Two PRs recreated the
duplication #56 deleted (PR #55's `cssVars.ts`, 241 lines mirroring `zimmTokens.ts`, removed).
Ask *"is this value typed more than once?"* — not *"is this a `var()`?"*

**Why:** this is the single most-repeated instruction in the playbook set, and it had inverted
without the docs noticing. Getting it backwards means every component built to the old note
fails review on style.

**How to apply:** `textStyle` for type (bare key — the one legitimate exception, there's no var
for the composite). Colour and spacing into the recipe. If it must be in JSX, `var(--zimm-*)`.
See [[project-chakra-scale-registration]] for the sizing-prop trap that is a correctness issue,
not a style one.
