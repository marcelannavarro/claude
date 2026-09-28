---
name: project-component-structure-decided
description: ui-kit component placement, casing, tiering and styling surface are all DECIDED — camelCase folders under components/ui-kits/{atoms,molecules,organisms}/, theme recipe always
metadata:
  node_type: memory
  type: project
  originSessionId: f5f727b4-7546-4aa6-9d86-ef229e247d3f
  modified: 2026-08-22T02:55:00.000Z
---

Supersedes an earlier note of mine that called this unsettled and said "build flat, don't create
`atoms/`". **That was wrong** — it came from a 19 Aug analysis that was superseded later in the
same session once the decision landed.

**Placement — decided.** Zimmermann design-system components live at:
`overrides/app/components/ui-kits/{atoms,molecules,organisms}/<camelCase>/index.tsx`
(today: `zimmButton`, `zimmIcon`, `zimmLogo`, `zimmNavItem`, `zimmTextInput` as atoms;
`zimmInputAction` as the one molecule; no organisms yet).

**Casing — three families, each correct in its own, don't generalise between them:**

| Family | Casing |
|---|---|
| SFCC override | `product-tile/` kebab — must match upstream's import path |
| **ui-kit component** | **`zimmButton/` camelCase — Zimmermann-authored, the default rule** |
| `shared/ui` primitive | `Button/` PascalCase — mirrors upstream exactly |

Kebab-case applies *only* to files mirroring a base Salesforce file. Note also the theme key is
PascalCase (`ZimmTextInput`) while its recipe file is camelCase (`zimmTextInput.ts`).

**Tier — by what the component's own template renders**, not visual size. Atom = renders no other
component; Molecule = only atoms; Organism = ≥1 molecule. An icon passed as a prop doesn't count
(`icon="close"` keeps a Button an atom), and slotted children don't count. When porting from the
F2R library the tier is already recorded as `composes: [...]` — use it rather than re-deriving,
and add `@see f2r/02-design/library/elements/<name>` in the JSDoc.

**Styling surface — decided: a theme recipe, always.** Not inline styles, not a `.zimm-*` class,
not co-located CSS. For a bespoke component wrapping a native element, the `chakra()` factory is
the bridge — native semantics plus recipe styling, read via `useMultiStyleConfig`. **Register the
recipe in `theme/components/index.ts` or destructuring throws at runtime.** F2R `.styles.ts` files
using `.zimm-*` classes are a faithful Figma→CSS transcription and good raw material — *convert
them to a recipe, don't copy the pattern*; never reintroduce `.zimm-btn-*`.

The reasoning against co-located CSS is worth keeping: a stylesheet can only see `var(--zimm-*)`,
which is **derived output at the bottom of the token pipeline**. Author there and you lose
`textStyle`, the named `theme.space` scale, semantic colour tokens, responsive arrays, and the
theme drift-guard tests. Not bad CSS — the wrong end of the pipeline.

**Planning fact:** `overrides/app/components/` contains only **seven** directories
(`_app-config`, `button`, `contentful`, `foundation`, `header`, `icons`, `pageContainer`).
`product-tile`, `display-price`, `swatch-group`, `image-gallery`, `link`, `footer`, `list-menu`,
`drawer-menu`, `seo` are all still `Origin = Base` despite being referenced throughout
`.claude/rules/`. **Assume most stories pay copy-first**, and expect a rules file's worked example
not to exist yet.

**Why:** getting this wrong adds a fifth competing structure, and my own stale version of it would
have sent a future build in the opposite direction from the agreed one.

**How to apply:** source is Marcel's `~/Dev/fedBuild-manual.md` §2–§3 — **local-only, never
cite it in a PR, commit or code comment** ([[feedback-local-only-docs]]). Cite `conventions.md` /
`components.md` / `overrideStyling.md` instead. Related: [[project-styling-layer-boundary]].
