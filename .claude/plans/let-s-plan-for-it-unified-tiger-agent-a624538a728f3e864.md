# Is a breadcrumb crumb a variant of `ZimmNavItem`, or a separate component?

> **Note on output location.** Plan mode was active for this investigation, so the only file I was
> permitted to write was this plan file. The requested scratchpad path
> (`.../scratchpad/q-crumb-atom.md`) was not written. This file is the deliverable.
>
> Read-only throughout: no repo file modified, no branch checked out. `feature/SFCC-55_global-footer-ui`
> was read via `git show origin/feature/SFCC-55_global-footer-ui:<path>`.

---

## Recommendation

**SEPARATE — and the design system answers this directly, not by inference.**

The handover component contract is explicit on both halves of the question, and it says **neither**:
there is no `zimm-breadcrumb` element, and `zimm-nav-item` is scoped in writing to navigation only.
Breadcrumbs are modelled as **consumer-supplied `<nav aria-label="Breadcrumb">` + `<a>` markup
projected into `zimm-page-toolbar`'s `crumbs` slot** (§0). The repo's current React port already
matches that contract exactly.

So: keep `Breadcrumb` as its own component, give it its own `ZimmBreadcrumb` theme recipe, and do
**not** mint a crumb atom either. The reuse between crumb and nav item belongs at the **token tier**
(`textStyles`), which is also what `globalStyles.ts` says — it registers `.zimm-text-nav`
(`overrides/app/theme/globalStyles.ts:307`), a **typography** class, and registers no
`.zimm-nav-item`, no `.zimm-breadcrumb`, no `.zimm-crumb` component class at all. "Nav" is a text
style in this design system, not a component identity.

Six of the ten arguments below are structural and hold **regardless of what the missing Figma spec
says**. Four depend on design values and are flagged as blocked.

**One thing changes the *spec*, not the verdict:** the base SFCC breadcrumb turns out to be a
**shared internal SFCC dependency** with two base consumers, so the bridge-pattern rule applies and
`#57` currently violates it. See §11a — this is the most actionable finding in the document.

---

## 0. The design system answers this in writing — it says NEITHER

This is the answer the Lead asked for ("is there a Figma component-library signal either way?"). There
is, and it is not ambiguous. It lives on the `f2r-component-registry` / `feature/pdp-token-class-spike`
branches (not HEAD), in the handover element contract.

**The handover inventory declares exactly 27 `zimm-*` elements. None is a breadcrumb.**
`f2r-component-registry:f2r/02-design/library/contract/zimm-contract.js` — verified list: `zimm-icon`,
`zimm-logo`, `zimm-add-to-wishlist`, `zimm-button`, `zimm-nav-item`, `zimm-navigation`, `zimm-footer`,
`zimm-banner`, `zimm-flag`, `zimm-logo-masthead`, `zimm-mega-menu`, `zimm-disclaimer`,
`zimm-text-input`, `zimm-select`, `zimm-search`, `zimm-input-action`, `zimm-search-overlay`,
`zimm-card-baseline`, `zimm-card-editorial`, `zimm-cat-links-aside`, `zimm-page-toolbar`,
`zimm-toolbar-category`, `zimm-product-showcase-blocks`, `zimm-hero-blocks`,
`zimm-product-detail-gallery`, `zimm-product-detail-options`, `zimm-product-detail`.
`git grep -E "zimm-breadcrumb|zimm-crumb"` across **all** local and remote refs: **zero hits.**

**And `zimm-nav-item` is scoped, in writing, to navigation only.**
`f2r-component-registry:f2r/02-design/specs/components/nav-item.md:22`:

> `<zimm-nav-item>` is a single navigation link rendered as an uppercase anchor with a bottom-border
> active/hover indicator. **Used exclusively within `<zimm-navigation>`** to render the main nav link
> set.

Its contract entry has only `label` + `active`, `slots: []`, and **no variant axis at all**
(`zimm-contract.js:75-87`). Searching `crumb` across `nav-item.md` and `elements/nav-item/*`: zero
hits. It is composed by exactly one parent — `zimm-contract.js:92`:
`composes: ["zimm-icon", "zimm-nav-item", "zimm-mega-menu"]` (that is `zimm-navigation`).

**Breadcrumbs are instead a SLOT on `zimm-page-toolbar`, with the crumb markup owned by the
consumer.** `zimm-contract.js:377-392`:

```
element: "zimm-page-toolbar",
attributes: [
  { name: "variant", type: "enum", values: ["breadcrumbs","recently-viewed","section-title"], default: "breadcrumbs" },
```

`:387` — the decisive line:

> `{ name: "crumbs", description: "Breadcrumb navigation. Consumer provides a <nav aria-label='Breadcrumb'> with <a> links. Only rendered when variant='breadcrumbs'. Slot inherits typography from host." }`

`:389`, the a11y note:

> `"No ARIA role added to host. variant=breadcrumbs: consumer provides semantic <nav aria-label='Breadcrumb'> in the crumbs slot."`

**The handover's own demo proves it uses plain anchors, not `zimm-nav-item`.**
`f2r-component-registry:f2r/02-design/library/elements/page-toolbar/demo.html:21-24`:

```html
<zimm-page-toolbar variant="breadcrumbs">
  <nav slot="crumbs" aria-label="Breadcrumb">
    <a href="#">Home</a>&nbsp; / &nbsp;<a href="#">Collections</a>&nbsp; / &nbsp;<span>Swim and Resort</span>
```

Note the trailing `<span>` for the current page — the handover made the same terminal-item decision
`#57` did, and used a bare anchor for the links rather than the nav-item element that was available to
it.

**Conclusion.** The design system's position is not "crumb is a nav-item variant" and not "crumb is
its own atom" — it is *"the toolbar is the styled component; the crumb trail is markup the consumer
supplies."* `overrides/app/components/ui-kits/atoms/zimmPageToolbar/index.tsx:66` renders exactly
that (`<Box opacity={0.8}>{props.children}</Box>`), and `product-detail/index.tsx:85-87` composes it
exactly that way. **The architecture already on the branch is correct.** The remaining work is
styling-layer, not structural.

Corroborating record: `.claude/registry/components.md:15` already classifies `Breadcrumb` as its own
`Override` component, and `:84` records `ZimmPageToolbar` as a separate `Custom` entry. On the f2r
branches the pre-port registry listed Breadcrumb as `Base` — i.e. it went `Base` → `Override` without
ever being modelled as a handover `zimm-*` element at all.

## 1. The decisive argument: the two disagree about what `aria-current="page"` MEANS

This is the crux, and it is not a styling matter.

`ZimmNavItem` — `overrides/app/components/ui-kits/atoms/zimmNavItem/index.tsx:39,53` (on #55):

```tsx
aria-current={active ? 'page' : undefined}
```

…with the recipe coupling that attribute to a permanent decoration —
`overrides/app/theme/components/zimmNavItem.ts:49-52`:

```ts
// Active (aria-current="page"): permanent underline regardless of hover
'&[aria-current="page"] > span': {
  borderBottomColor: 'currentColor',
},
```

So in `ZimmNavItem`, `aria-current="page"` means **"this nav link is the page you're on, and it is
still a link — draw the selected-state underline."**

In a breadcrumb it means the opposite. `overrides/app/components/breadcrumb/index.tsx:73-77` (HEAD):

```tsx
{currentPage && (
  <Box as="li" display={{ base: 'block', md: 'inline' }}>
    <Text as="span" aria-current="page" {...BASE_STYLE}>
      {currentPage}
    </Text>
  </Box>
)}
```

Here `aria-current="page"` marks the **terminal, non-interactive** crumb — a `<span>`, no link, no
decoration, and (correctly) no separator after it.

A Chakra `variant` changes **style only**. It cannot change the rendered element, cannot remove
interactivity, and cannot re-point what an ARIA attribute signifies. So the single state that most
defines a crumb trail is structurally unreachable through the variant axis. **VERIFIED, and
independent of Figma.**

## 2. `ZimmNavItem`'s element choice is driven by href-safety, not by role

`zimmNavItem/index.tsx:35-61`:

```tsx
if (href && isSafeHref(href)) {
  return ( <chakra.a href={href} … /> );
}
return ( <chakra.button type="button" … /> );
```

Its own JSDoc (`:28-30`) states the contract:

> Renders an `<a>` when `href` is provided and safe, a `<button>` otherwise (no scroll, no redirect
> for placeholder items).

For a crumb the correct no-href fallback is a `<span>`, never a `<button>`. A `<button>` announces
"clickable" to assistive tech for an element that is by definition *where you already are* — a WCAG
2.2 SC 4.1.2 name/role/value defect, on a page in a WCAG 2.2 AA project. Producing a `<span>` from
`ZimmNavItem` needs a **third render branch**, i.e. a change to the atom's contract, not a variant.
**VERIFIED, independent of Figma.**

## 3. The atom's reason to exist is the hover underline — the crumb rejects it

`zimmNavItem/index.tsx:28`: *"Atom — navigation link with bottom-border underline on hover/active."*
The `& > span` border machinery is ~40% of `zimmNavItem.ts` (`:42-52`), including a dedicated inner
`<span>` that exists only to host that border (`:45,59`).

`#57`'s crumb hover is `opacity`, not a border — `breadcrumb/index.tsx:28-35`:

```ts
const LINK_PROPS = {
  ...BASE_STYLE,
  textDecoration: 'none',
  _hover: { opacity: 0.6 },
  sx: {
    transition: 'opacity var(--zimm-motion-duration-fast) var(--zimm-motion-easing-standard)',
  },
};
```

Strip the underline from `ZimmNavItem` and nothing substantive remains except typography — which the
token tier already owns. **Caveat: this argument is Figma-dependent** (see §6). If the real spec
shows an underline-on-hover crumb, this one weakens; §1, §2 and §4 do not.

## 4. No SPA routing — a performance regression, not a style difference

`ZimmNavItem` emits a plain anchor with a raw string href (`zimmNavItem/index.tsx:37-38`) and its
prop surface (`:9-26`) has **no `as` and no `to`**:

```ts
type ZimmNavItemProps = {
  label: string; href?: string; active?: boolean; inverse?: boolean;
  onClick?: …; style?: CSSProperties; sx?: SystemStyleObject;
};
```

Crumbs must be `react-router-dom` links — `#57` uses `as={RouteLink} to={…}`
(`breadcrumb/index.tsx:54,64`). Routing a crumb through `ZimmNavItem` makes every crumb click a full
document reload, against AGENTS.md > Performance ("LCP budget is tight (≤ 2s at p75 mobile)").
Adding `as`/`to` widens the atom's API for a consumer it was not built for. **VERIFIED, independent
of Figma.**

## 5. The variant axis is genuinely blocked, and unblocking it costs speculative variants

`zimmNavItem/index.tsx:32-33`:

```tsx
const variant = inverse ? 'inverse' : 'light';
const styles = useStyleConfig('ZimmNavItem', { variant });
```

A third variant is unreachable from outside. `zimmButton` solves the same problem by concatenation —
`overrides/app/components/ui-kits/atoms/zimmButton/index.tsx:57-60`:

```tsx
const variant = props.variant ?? 'primary';
const size = props.size === 'medium' ? 'sm' : 'lg';
// Maps inverse prop to the *Inverse variant suffix defined in button.ts.
const chakraVariant = `${variant}${inverse ? 'Inverse' : ''}`;
```

**The pattern transfers mechanically** — you would get `light | inverse | crumbLight | crumbInverse`.
But there is no Figma for an inverse crumb, so two of the four would be invented. That is against
`overrideStyling.md` ("don't guess at design values") and `conventions.md` ("resist speculative
abstractions"). Mechanically possible ≠ correct. **VERIFIED.**

## 6. Empirically, `ZimmNavItem` is a *footer* atom, not a nav atom

Exhaustive consumer sweep of `#55` (every `.ts`/`.tsx` in `overrides/`): the **only two real call
sites are both in the footer** — `overrides/app/components/footer/index.tsx:386` (legal links) and
`:493` (site-map links). Everything else is the atom itself, its story, its recipe, and two comments
in `footer.ts`.

The header — the obvious "nav item" consumer — **did not adopt it.** It has a parallel treatment
with its own underline animation and its own letter-spacing constant. `overrides/app/theme/components/header.ts:76-88`:

```ts
desktopActionButton: {
  fontFamily: 'var(--zimm-font-family-heading)',
  fontSize: 'var(--zimm-font-size-3xs)',
  fontWeight: 'var(--zimm-font-weight-medium)',
  letterSpacing: NAV_LETTER_SPACING,
  …
```

And `overrides/app/theme/components/navConstants.ts:1-5` records that this value **disagrees with the
token**:

```ts
// Shared prototype nav letter-spacing value — used by header.ts's desktopActionButton
// and listMenu.ts's listMenuTriggerLink. The design system's .zimm-text-nav /
// textStyles.navigation both specify 0px — unresolved with the UI designer, so this
// prototype value is kept rather than silently switched. See PR description.
export const NAV_LETTER_SPACING = '0.02em';
```

An atom that has not yet absorbed the header, and whose "nav" letter-spacing is still unresolved with
the designer, is not the right place to absorb a PDP breadcrumb. **VERIFIED.**

## 7. The `legalLink` precedent argues the other way once you read what it changes

This was the strongest case *for* reuse, so it deserves the closest reading.

`overrides/app/theme/components/footer.ts:396-404`:

```ts
legalLink: {
  textStyle: 'footer',
  color: 'var(--zimm-color-text-muted)',
  justifyContent: 'flex-start',
  // No height override — ZimmNavItem's baseStyle uses minHeight, so the py-8px
  // below grows the item naturally. Figma Small/Default: py-[8px].
  paddingY: 'xs',
  paddingX: 0,
},
```

…passed in from outside at `footer/index.tsx:386-394`:

```tsx
<ZimmNavItem
  key={link.label}
  href={link.href}
  label={link.label}
  inverse
  // Figma Small/Default: py-[8px] — override base h-[24px] with height:auto + vertical padding
  // width is applied via legalGrid's '& > a' child selector in footer.ts
  sx={styles.legalLink}
/>
```

What that override **changes**: textStyle (`navigation` 12px → `footer` 10px), colour, justification,
padding. What it **keeps**: the underline indicator, the `<a>`/`<button>` fallback, the `aria-current`
behaviour. That is a legitimate *same behaviour, different context* override — the exact case the
pattern exists for.

A crumb **inverts** it: keep the typography, replace the behaviour. So `legalLink` is the test the
crumb **fails**, not the precedent it passes.

Second point on the same precedent: `legalLink` already sits at the edge of `overrideStyling.md`'s
own rule, because it means `ZimmNavItem`'s appearance is defined in two files:

> **One canonical styling surface per component type.** Only one place should define how a given
> interactive component looks: its `theme/components/<name>.ts` config […] nothing stops its values
> from disagreeing with the real theme config over time.

`legalLink` is within the *spirit* of that (a positional/contextual tweak). Extending it to a crumb —
where the delta is behavioural — pushes it past the line. The footer's other call site
(`footer/index.tsx:493-498`) reinforces this: its `sx` is a one-property positional fix
(`width: 'min-content'`), gated on an NBSP in the label. Both existing `sx` uses are *layout* nudges.
Neither changes what the component *is*.

## 8. What the base SFCC breadcrumb models — and it does not model a crumb as a link variant

`node_modules/@salesforce/retail-react-app/app/components/breadcrumb/index.jsx:32-56` composes
Chakra's `Breadcrumb` / `BreadcrumbItem` / `BreadcrumbLink` and reads a **dedicated multipart
recipe**:

```jsx
const styles = useStyleConfig('Breadcrumb')
…
separator={<ChevronRightIcon {...styles.icon} aria-hidden="true" />}
```

`node_modules/@salesforce/retail-react-app/app/theme/components/project/breadcrumb.js:7-25` —
its own recipe with `parts: ['container', 'icon', 'link']`:

```js
baseStyle: {
    container: { minHeight: 4, fontSize: 'sm' },
    icon: { display: 'flex', boxSize: 4, color: 'grey' },
    link: { paddingTop: 3, paddingBottom: 3, textDecoration: 'none' }
}
```

So base treats a breadcrumb as **its own multipart component with its own `link` part** — explicitly
*not* a variant of any shared link/nav component. Note also what base does **not** model: no
current-page/terminal item at all (it links every category), and no `aria-current`. `#57` is
*better* than base on exactly that point.

`Breadcrumb` is registered in the base theme at
`node_modules/@salesforce/retail-react-app/app/theme/index.js:38,89`. **That matters for naming — see
§11.**

## 9. The repo's own category table names Breadcrumb as its own component

`.claude/rules/components.md` > Storybook > Categorisation, verbatim:

> | `Layout/` | Global chrome, navigation, and structural components — Header, Footer, DrawerMenu,
> ListMenu, **Breadcrumb**, Pagination, Seo |

Breadcrumb is enumerated as a first-class component alongside Header and ListMenu — not as a nav-item
state. `#57` already files it correctly: `overrides/app/components/breadcrumb/index.stories.tsx:8` →
`title: 'Layout/Breadcrumb'`, while `ZimmNavItem` sits at
`zimmNavItem/index.stories.tsx:8` → `title: 'Elements/ZimmNavItem'`. **Two different sidebar
categories, already, in the repo's own rules.** That is the clearest in-repo design-system signal
available.

---

## 10. Concrete style diff — `#57`'s crumb vs what `ZimmNavItem` provides

`#57` sets ten style properties in total (`breadcrumb/index.tsx:22-35`, plus `:38` for the separator).

| Property | `#57` crumb | `ZimmNavItem` effective | Verdict |
|---|---|---|---|
| font family | `FONT_MEDIUM` (via `caption`) | `var(--zimm-font-family-body)` — `zimmNavItem.ts:18` overrides the textStyle | **CONFLICT** |
| font size | 12px (`fontSizes.3xs`) | 12px | match |
| font weight | 500 | 500 | match |
| letter-spacing | `0` (`letterSpacings.sm`) | `0` | match |
| text-transform | `uppercase` — `:24` | `uppercase` (from `navigation`) | match *(but unsourced — §12)* |
| line-height | **18px** (`caption`) | **14px** (`zimmNavItem.ts:28` overrides `navigation`'s `normal`) | **CONFLICT** |
| colour | `text.default` — `:25` | `var(--zimm-color-text-default)` — `zimmNavItem.ts:57` | match |
| text-decoration | `none` — `:30` | `none` — `zimmNavItem.ts:39` | match |
| hover | `opacity: 0.6` — `:31` | inner-span `borderBottomColor: currentColor` — `zimmNavItem.ts:46-48` | **CONFLICT** |
| `aria-current` | terminal `<span>`, undecorated | permanent underline on an `<a>` — `zimmNavItem.ts:50-52` | **CONFLICT** |
| separator | `<span aria-hidden>/</span>`, `mx="2xs"` — `:37-41` | not expressible | **crumb-only** |
| focus ring | **absent** | `outline: var(--zimm-focus-ring)` — `zimmNavItem.ts:58-62` | **navItem-only (a real gain — see §13)** |

Unwanted extras `ZimmNavItem` would drag in, all from `zimmNavItem.ts:19-41`: `display: inline-flex`,
`minHeight: var(--zimm-scale-xl)` (24px), `paddingBlock: '4.5px'`, `justifyContent/alignItems: center`,
`cursor: pointer`, `background: none`, `border: none`, `paddingInline: 0`, plus the inner `<span>`
wrapper. The `inline-flex` + 24px `minHeight` pair is actively hostile to `#57`'s layout, which
relies on `display: inline` on the `<li>` (`breadcrumb/index.tsx:53,63`) so the terminal crumb can
break to its own line on mobile via `display={{ base: 'block', md: 'inline' }}` (`:73`).

**Tally: 5 match, 4 conflict, 9 unwanted extras, 2 properties each side can't express.** Four of the
five matches are just "12px / 500 / ls-0 / text.default" — i.e. the shared *tokens*, which is exactly
where the sharing should live.

### The typography finding worth acting on independently

- `textStyles.navigation` (`overrides/app/theme/foundation/typography.ts:211-218`): `FONT_MEDIUM` /
  12px / 500 / `lineHeight: 'normal'` / ls `0` / `uppercase`.
- `textStyles.caption` (`:143-149`): `FONT_MEDIUM` / 12px / 500 / lineHeight **18px** / ls `0` — **not
  uppercase**.
- `#57` writes `textStyle: 'caption'` + `textTransform: 'uppercase'` (`breadcrumb/index.tsx:23-24`).

**`caption + uppercase` differs from `navigation` in exactly one property: line-height.** `#57`
hand-rebuilt `navigation` out of `caption`. That is a real duplication to fix regardless of this
decision — say `textStyle: 'navigation'` and set line-height explicitly if 18px is wanted.

Note also that `ZimmNavItem` overrides *both* of `navigation`'s distinctive properties (family →
body, line-height → 14px), so the atom's effective type is **not** `textStyles.navigation` either.
Neither component actually renders the `navigation` text style as defined.

---

## 11. The recommendation, concretely

### Files

| Path | Action |
|---|---|
| `/Users/marcel.a.n.navarro/Dev/zimmermann-pwa/overrides/app/components/breadcrumb/index.tsx` | **Keep at this path.** Strip the module-level style consts; consume the recipe. |
| `/Users/marcel.a.n.navarro/Dev/zimmermann-pwa/overrides/app/components/breadcrumb/index.stories.tsx` | Keep. `title: 'Layout/Breadcrumb'` is already correct per `components.md`. |
| `/Users/marcel.a.n.navarro/Dev/zimmermann-pwa/overrides/app/theme/components/zimmBreadcrumb.ts` | **NEW** — the recipe. |
| `/Users/marcel.a.n.navarro/Dev/zimmermann-pwa/overrides/app/theme/components/index.ts` | Register `ZimmBreadcrumb`. |

**Do not move it to `ui-kits/molecules/zimmBreadcrumb/`.** The path
`overrides/app/components/breadcrumb/` *shadows* the base SFCC module
(`package.json`'s `ccExtensibility: {extends: '@salesforce/retail-react-app', overridesDir: 'overrides'}`),
and `conventions.md` is explicit:

> **Override files (mirroring a base Salesforce file):** keep the original kebab-case filename and
> folder name exactly (e.g. `product-tile.tsx`).

Moving it un-shadows the base module, and any base SFCC file importing
`@salesforce/retail-react-app/app/components/breadcrumb` silently reverts to the unstyled base
breadcrumb. This does create tension with the recorded `ui-kits/{atoms,molecules,organisms}/` decision
— resolution: **the shadow path wins for anything mirroring a base SFCC file; `ui-kits/` is for
Zimmermann-only components with no base counterpart.** Worth the Lead confirming explicitly, since
it's a general rule, not a breadcrumb-specific one.

### Recipe key: `ZimmBreadcrumb` — **not** `Breadcrumb`

Base **does** register `Breadcrumb` (§8). `overrides/app/theme/components/recipeGuards.test.ts:212-217`
(on #55) is explicit:

```ts
test('no recipe silently inherits a base SFCC recipe of the same name', () => {
    // extendTheme DEEP MERGES. These three intentionally share a base key: Button wants the
    // base variants, and Header/ListMenu are partial overrides of components whose other
    // parts we still rely on. Anything else must be namespaced (e.g. ZimmFooter, not Footer).
    const INTENTIONAL_MERGES = ['Button', 'Header', 'ListMenu'];
```

A recipe named `Breadcrumb` would deep-merge base's `container.minHeight: 4`, `container.fontSize:
'sm'`, `icon.boxSize: 4`, `icon.color: 'grey'`, `link.paddingTop/Bottom: 3` in underneath ours, and
this test would fail. `ZimmBreadcrumb` avoids it. **Caveat: `recipeGuards.test.ts` exists only on
`#55`, not on HEAD** — so the guard will not actually fire until `#55` merges. Follow the rule anyway;
the deep-merge hazard is real with or without the test.

### Parts

`list` · `item` · `link` · `separator` · `current` — deliberately *not* base's
`container`/`icon`/`link`, so nothing reads as a base part even if someone mis-keys the recipe name.

The recipe holds: the `<ol>` reset (`listStyle`, `margin`, `padding`, `paddingInlineStart`); `item`
display, including the responsive `{base: 'block', md: 'inline'}` for the terminal item; `link`
typography + colour + `textDecoration` + `_hover` + `_focusVisible` + `transition`; `separator`
typography + `marginInline: '2xs'`; `current` typography + colour.

**Port `#57`'s current values verbatim** so the move is a pure refactor with zero visual change, and
mark every unconfirmed value with the same provisional comment convention `button.ts` and `footer.ts`
already use, pending the Figma node.

### Props surface — keep `#57`'s

```ts
type BreadcrumbProps = {
  categories: readonly BreadcrumbCategory[];
  currentPage?: string;
};
```

Already correct: `readonly` per `typescript.md`, `currentPage` optional per `components.md`. One open
question: base is `({categories, ...rest})` and spreads `rest` onto `ChakraBreadcrumb`; `#57` drops
`...rest`. If base SFCC imports this component internally, `overrideStyling.md`'s bridge rule applies
— *"its default export must stay a faithful, undecorated port — full original prop surface"* — and
`...rest` should be restored. Flagged; depends on the base-consumer check.

### How the current-page item renders

Exactly as `#57` already does it (`breadcrumb/index.tsx:73-77`): an `<li>` containing
`<Text as="span" aria-current="page">` — no link, no button, and **no separator emitted after it**
(the `isLastCrumb` guard at `:61,67`). This matches the WAI-ARIA APG breadcrumb pattern and is the
one behaviour `ZimmNavItem` structurally cannot produce. Keep the markup; move only its styling into
the recipe's `current` part.

### Changes required to `#55`'s files: **NONE**

This is the biggest practical argument for the recommendation.

`#55` is **unmerged** (`origin/feature/SFCC-55_global-footer-ui`, tip `ec9d161`) and per project
memory is *CodeRabbit-cleared and blocked only on human code-owner approval.* Touching it restarts
that review.

- **Separate route:** touches `theme/components/index.ts` only — a one-line registry add. `#55` also
  edits that file, so expect a trivial merge conflict there and nothing else.
- **Variant route:** requires editing `zimmNavItem/index.tsx` (third variant + concatenation),
  `zimmNavItem.ts` (new variant block), and `zimmNavItem/index.stories.tsx` (new stories) — i.e.
  re-opening an approved PR to serve a component in a different epic.

There is also a **hard sequencing dependency** on the variant route: `ZimmNavItem` imports
`isSafeHref` from `app/utils/safeHref` (`zimmNavItem/index.tsx:3`), and that util **does not exist on
HEAD** — verified, `overrides/app/utils/` on HEAD contains only `productData.ts` and `sfccImage.ts`;
`safeHref.ts` + `safeHref.test.ts` arrive with `#55`. So the variant route makes the PDP breadcrumb
un-shippable until `#55` merges. The separate route has no such dependency.

---

## 11a. IMPORTANT — the base breadcrumb IS a shared SFCC dependency, and `#57` breaks the bridge

This changes the **spec**, not the verdict. I initially assumed the override had no base consumers.
It has two. `grep -rn "components/breadcrumb" node_modules/@salesforce/retail-react-app/app/`:

- `node_modules/@salesforce/retail-react-app/app/components/product-view/index.jsx:45` (call site `:75`
  — `<Breadcrumb categories={category} />`)
- `node_modules/@salesforce/retail-react-app/app/pages/product-list/partials/page-header.jsx:14`
  (call site `:20` — `{category && <Breadcrumb categories={category.parentCategoryTree} />}`)
- plus the base's own `components/breadcrumb/index.test.js:8`

Neither `product-view` nor `product-list/partials/page-header` is overridden in `overrides/app/`, so
**both still resolve to `#57`'s component** through `ccExtensibility`. That triggers the rule at
`.claude/rules/overrideStyling.md:133-139`, verbatim:

> **The SFCC bridge pattern (shared components only).** If the component is used internally by SFCC's
> own base components […] its **default export must stay a faithful, undecorated port** — full
> original prop surface, same `forwardRef` behaviour […] Put Zimmermann-only styling behind a **named
> export** that wraps the default and adds brand-specific defaults.

`#57` does the opposite — `breadcrumb/index.tsx:84-86` exports the *same* branded component as both
`{ Breadcrumb }` and `default`. Verified divergences from the module it shadows:

| # | Divergence | Consequence for the two base consumers |
|---|---|---|
| 1 | **Hardcoded `Home` crumb injected** (`:54-56`); base never rendered one | PLP and `product-view` both gain an unrequested "Home" link |
| 2 | `...rest` dropped — base is `({categories, ...rest})` spreading onto `ChakraBreadcrumb` (base `:32,41`); override is `({categories, currentPage})` (`:47`) | any extra prop from a base caller is silently discarded |
| 3 | `className="sf-breadcrumb"` and `data-testid="sf-crumb-item"` dropped (base `:38,44`) | base's own `index.test.js` and any selector on those hooks break |
| 4 | `useStyleConfig('Breadcrumb')` dropped (base `:34`) | the theme's `Breadcrumb` recipe is no longer consulted at all |
| 5 | `<ChevronRightIcon>` separator → `/` text (base `:40`) | visual change on PLP, which had no Zimmermann breadcrumb design signed off |
| 6 | `Breadcrumb.displayName` dropped (base `:58`) | React DevTools / snapshot names change |

**Correction to my own earlier concern:** I flagged a possible locale/routing regression from `#57`'s
local `categoryUrlBuilder`. **There is none.** I read the base util directly —
`node_modules/@salesforce/retail-react-app/app/utils/url.js:90`:

```js
export const categoryUrlBuilder = (category) => encodeURI(`/category/${category.id}`)
```

It takes one parameter and **ignores** the `intl.locale` the base breadcrumb passes it (base `:47`).
`#57`'s local copy is behaviourally identical. It is a DRY nit only — not a multi-site boundary
breach. Flagging explicitly because a locale regression here *would* have been a Multi-site &
Routing stop-and-ask, and it is worth being clear that it is not one.

### What this adds to the spec

Fold the bridge split into the same refactor:

- **`default export`** — faithful port of the base contract: `({categories, ...rest})`, no injected
  `Home`, keeps `sf-breadcrumb` / `sf-crumb-item`, keeps `displayName`, consumes `ZimmBreadcrumb` for
  neutral styling. This is what `product-view` and PLP `page-header` get.
- **named export** (e.g. `ZimmBreadcrumb`, mirroring `product-tile`'s `CardBaseline` precedent cited
  in the rule) — the Zimmermann PDP treatment: `Home` crumb, `currentPage` terminal item, `/`
  separator. `product-detail/index.tsx:8` switches from the default to this named import.

Also worth correcting: `.claude/registry/components.md:15` records Breadcrumb's tier as
**`4 — Feature-local`**. With two base consumers that understates its blast radius. Note that
`overrides/app/components/breadcrumb/` is **not** currently listed in `protectedFiles.md`'s Shared
Product Components block (which does list `product-tile`, `display-price`, `image-gallery`,
`swatch-group`) — arguably it belongs there on the same reasoning. Flagging for the Lead, not
proposing an edit: `protectedFiles.md` is Tier 1 governance.

---

## 12. Where the missing Figma blocks a firm answer

**The Figma gap is wider than "one missing node."** Verified across all refs:

- There is **no Figma node id for the PDP breadcrumb**, and **none for its parent
  `zimm-page-toolbar`** either — `zimm-page-toolbar` has no spec file at all. It is named in the
  missing-specs list: `f2r-component-registry:.claude/design-registry/components.md:74` — *"Missing
  specs (12): `zimm-card-baseline`, `zimm-select`, `zimm-search`, `zimm-cat-links-aside`,
  **`zimm-page-toolbar`**, `zimm-input-action`, …"* — and `:42` records it `Pending` with `✗` in the
  Spec column.
- `zimm-nav-item` has **no Figma node either** —
  `f2r-component-registry:f2r/02-design/specs/components/nav-item.md:2-3`: *"2026-07-15 | /handover |
  Initial spec generated from library element (**Figma unavailable at handover pass**)"*. So neither
  side of this comparison has a signed-off Figma source. That is worth knowing before anyone treats
  `ZimmNavItem`'s current values as the authoritative baseline.
- On HEAD there are **no Figma references at all** (`grep -rn "figma.com\|node-id="` → zero hits).

**The PRD requirement is one line, with no format.** `.docs/prd/pdp.md:9`:

> `- Breadcrumb navigation displayed on all PDP pages (PRD-001, confirmed)`

That is the entire UI requirement — no category-path detail, no separator, no styling.

**The only breadcrumb *format* on record is for SRP, and it conflicts with `#57`.**
`.docs/prd/search.md:51`:

> `| SPR-46 | Confirmed | Breadcrumb: \`HOME > SEARCH RESULTS FOR '[QUERY]'\` |`

That is a **`>`** separator and an uppercase `HOME`; `#57` renders a **`/`** separator and
title-case `Home` (`breadcrumb/index.tsx:39,55`), while base SFCC uses a `ChevronRightIcon`. Three
different separators across the codebase and docs, and no PDP spec to arbitrate. This is a concrete
question for the Lead to put to the designer alongside the node request — **do not silently pick
one.**

(For completeness: `.docs/prd/dataMigrationSeo.md:61` and `.docs/vendor/sparroSchema.md:415,435-436`
cover `BreadcrumbList` JSON-LD, and are **PLP-scoped only** — there is no PDP `BreadcrumbList` schema
requirement. Not a styling input, but relevant if SEO markup comes up.)

These remain open and must not be guessed:

1. **Is the crumb uppercase at all?** `#57` asserts it (`breadcrumb/index.tsx:24`) but `caption` /
   `.zimm-text-caption` is *not* uppercase, so the `textTransform` is an **unsourced addition**.
2. **Line-height:** 18px (`caption`), 14px (what `ZimmNavItem` actually renders), or `normal`
   (`navigation` as declared)? All three are live candidates.
3. **Hover treatment:** `opacity: 0.6` or an underline? This is the only input that would materially
   change the analysis — see §3.
4. **Does an inverse/dark crumb exist?** Determines whether the recipe needs a variant axis at all.
5. **Separator glyph:** `#57` uses `/`; base SFCC uses `ChevronRightIcon`. Unsourced either way.
6. **Alternative text style worth checking against the spec:** `textStyles.linkSm`
   (`typography.ts:162-170`) — `FONT_MEDIUM` / 12px / 500 / lh 14px / ls `-0.12px` / **capitalize** +
   **underline** — is the design system's actual "small link" style. Plausible match for a crumb.
   Do not pick one without the node.

**Not blocked by Figma:** §1, §2, §4, §5, §6, §8, §9. The recommendation stands on those alone.

---

## 13. Also found (out of scope, worth a follow-up)

1. **`#57`'s breadcrumb has no theme recipe at all.** All styling is module-level consts in the
   component file (`BASE_STYLE`, `LINK_PROPS`, `breadcrumb/index.tsx:22-35`). That sits below level 3
   of `overrideStyling.md`'s hierarchy and against the recorded "theme recipe always" structural
   decision. The recommended refactor fixes this as a side effect.
2. **`var(--zimm-*)` in component JSX** — `breadcrumb/index.tsx:33` puts
   `var(--zimm-motion-duration-fast)` / `var(--zimm-motion-easing-standard)` in the component file.
   The recorded styling-layer boundary is that `--zimm-*` vars live in theme recipes, never component
   JSX. Same refactor fixes it.
3. **Missing focus indicator (a11y, WCAG 2.4.7 / 2.4.11).** `#57`'s crumb links have neither
   `_focusVisible` nor `className="zimm-focus-visible"` — despite `.zimm-focus-visible` being
   registered at `overrides/app/theme/globalStyles.ts:328`, and despite the sibling
   `zimmPageToolbar/index.tsx:55` using exactly that class for its CTA link. `ZimmNavItem` *does*
   ship a focus ring (`zimmNavItem.ts:58-62`) — the one thing the variant route would have got for
   free. Fix it in the new recipe.
4. **Duplicated `categoryUrlBuilder` — no routing bug.** See the correction in §11a: `#57`'s local
   copy is behaviourally identical to base's, which ignores its own locale argument. DRY nit only,
   low priority.
5. **The bridge-pattern violation in §11a is the highest-priority finding in this document** — higher
   than the atom question itself, because it currently changes what renders on the **PLP** and in
   base `product-view`, neither of which was in `#57`'s scope.
6. **`.zimm-focus-visible` has exactly one consumer repo-wide** (`zimmPageToolbar/index.tsx:55`),
   despite being registered at `globalStyles.ts:328`. Consistent with `overrideStyling.md:174-176`'s
   own note that *"`globalStyles.ts` adoption is currently near zero."* Not a defect — context for
   why reaching for the class in the breadcrumb recipe is a small, safe adoption step.
7. `globalStyles.ts` is **byte-identical** on HEAD and `#55` (same blob hash), so nothing in this
   analysis depends on which branch you read it from.

---

## 14. Verified vs inferred

**VERIFIED (read directly, either by me or by a delegated read-only sweep):** every code quote and
`path:line` above. The 27-element handover contract and the absence of any `zimm-breadcrumb` /
`zimm-crumb` across all refs. `nav-item.md:22`'s "used exclusively within `<zimm-navigation>`".
`zimm-page-toolbar`'s `crumbs` slot description and `demo.html`'s plain-anchor markup. `ZimmNavItem`'s
two consumers (exhaustive sweep of every `.ts`/`.tsx` in `overrides/` on `#55`). The two base
consumers of the breadcrumb module. `Breadcrumb` registered in the base theme.
`recipeGuards.test.ts`'s `INTENTIONAL_MERGES` list and its absence from HEAD. `safeHref.ts` absent
from HEAD. `globalStyles.ts` containing no breadcrumb/crumb/nav-item component class.
`components.md`'s category table naming Breadcrumb. Base `categoryUrlBuilder` ignoring its locale
arg. The absence of any Figma node for the PDP breadcrumb, `zimm-page-toolbar`, or `zimm-nav-item`.

**INFERRED (judgement, not fact):** that §3's weight depends on the unseen hover spec. That the
`ui-kits/` vs shadow-path tension resolves in favour of the shadow path (rule-derived, but the Lead
should ratify it as a general rule). That `Breadcrumb` arguably belongs in `protectedFiles.md`'s
Shared Product Components block. That the named export should be called `ZimmBreadcrumb` — a naming
choice, not a rule.

**NOT INVENTED:** no design value is proposed anywhere in this document. Every concrete number cited
is quoted from an existing file. Where a value is unsourced (separator glyph, uppercase, line-height,
inverse variant) it is listed in §12 as an open question rather than resolved.

---

## Appendix — one-line summary of the axis

| Option | Verdict |
|---|---|
| Variant of `ZimmNavItem` | **No.** The handover scopes `zimm-nav-item` to `<zimm-navigation>` in writing; the variant axis cannot express a non-interactive terminal crumb; requires re-opening approved PR #55 and depends on #55 merging for `safeHref`. |
| New separate crumb *atom* | **No.** Nothing in the handover models a crumb as an element; the reusable unit is the trail, and a crumb link is a `RouteLink` + a textStyle. |
| Reuse-with-`sx` (footer `legalLink` precedent) | **No.** `legalLink` changes tokens and keeps behaviour; a crumb keeps tokens and replaces behaviour — it fails the test that precedent sets. |
| **`Breadcrumb` stays its own component + gains a `ZimmBreadcrumb` recipe; reuse lives in `textStyles`** | **YES — recommended.** Matches the handover contract, the repo registry, and `components.md`'s category table. Zero changes to #55. |
