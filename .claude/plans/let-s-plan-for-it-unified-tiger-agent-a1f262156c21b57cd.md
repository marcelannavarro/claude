# Test-strategy verdict: PR #55/#59's "no co-located component test" pattern

Read-only investigation. Written here rather than the requested scratchpad path because plan mode
restricts writes to this file.

**Scope note:** PR **#55 is CLOSED**; the live PR for `feature/SFCC-55_global-footer-ui` is **#59
(OPEN)**, head `ec9d1619dbc7782c397d83afa31474cffa05a468` — identical to the local branch head, so
everything below describes the code #59 carries. VERIFIED via `gh pr list --state all`,
`gh pr view 59 --json headRefOid`, `git rev-parse`.

---

## VERDICT: sound strategy, incompletely applied

Not a coverage gap dressed up as a convention. It is the strategy that **three of the four**
governance surfaces in this repo already mandate, and it is what `testing.md`'s own stated logic
prescribes. But it is incomplete in three specific, nameable places — all of which are categories
`testing.md` itself lists as must-test, and **none of which would be fixed by writing
`footer/index.test.ts`**.

---

## 1. The premise needs correcting first

The framing was that `.claude/rules/testing.md:42` "says the opposite." Read in context, it does
not. It sits under `## Layer 1 — Vitest (unit)` → `### File layout`, immediately after:

> `.claude/rules/testing.md:33` — "Co-located with the source, `.test.ts` suffix, never `.spec.ts`:"

followed by two path examples, then:

> `.claude/rules/testing.md:42-43` — "Components use `index.test.ts` next to `index.tsx` in the
> component folder (see [components.md](./components.md) > Components)."

That is a **naming-and-location** rule for a Vitest file *if you write one*. The existence rule
lives elsewhere in the same file and points the other way:

- `testing.md:17` — "Write tests where failure would be **non-obvious** or **costly to debug**"
- `testing.md:23` — "❌ Re-exports, one-line passthroughs, type-only helpers"
- `testing.md:3` — "**Do not duplicate coverage across layers** — pick the cheapest layer that
  proves the behaviour."

The other three surfaces are explicit, and all agree with #55:

| Surface | Verbatim |
|---|---|
| `AGENTS.md:151` | "every logic-heavy feature needs a `.test.ts` **or** a story `play`." |
| `.claude/skills/new-component/SKILL.md:23` | "Storybook story is mandatory; Vitest only when the component owns non-trivial logic." |
| `.claude/skills/new-component/SKILL.md:50` | "**Optional:** if the component owns non-trivial logic, also create `index.test.ts` (Vitest) in the same folder. **Skip otherwise.**" |
| `.claude/skills/code-quality/SKILL.md:95` | "For logic-heavy components or hooks: a `*.test.ts` exists **OR** a `play` function exists in the story." |
| `.claude/skills/code-quality/SKILL.md:101` | "If a logic-heavy file has neither a `.test.ts` nor a `play` function, flag as MISSING TEST." |

`.claude/hooks/testFileRemind.sh` — PostToolUse, scoped to `/app/(components|hooks)/`, prints a
message and `exit 0` at line 55. **Reminds, never blocks.** VERIFIED. It fires on every ui-kits
atom in #55; declining it is consistent with the "optional" framing above.

**So testing.md:42 is the outlier, and it is being over-read.** #55 conforms to the majority.

---

## 2. The decisive test — break-scenario trace

Mechanism facts established first:
- `useMultiStyleConfig` returns a record; a missing key is `undefined`; `__css={undefined}` is legal
  Chakra and renders the element **unstyled, silently**. No warning, no throw.
- `test-storybook` runs **one test per story regardless of whether a `play` exists** — VERIFIED
  locally: 27 tests / 9 suites, and the current branch has exactly 27 `export const` stories and
  **zero** `play` functions. So every story is a render-smoke + axe check.
- `.storybook/preview.tsx:36` — `test: 'error'` makes axe violations fail `--ci`.

### S1 — a recipe part is renamed so `styles.someName` becomes `undefined`

`footer.ts:48-83` declares 35 parts; `footer/index.tsx` reads 35. VERIFIED by set comparison —
**zero drift in both directions today.**

- No `footer.test.ts` exists (VERIFIED: the footer folder holds only `contentfulFixture.ts`,
  `contentfulSchema.placeholder.ts`, `index.stories.tsx`, `index.tsx`).
- `recipeGuards.test.ts` walks recipe *values* for bad token usage — not part-name/consumer
  agreement.
- `theme/index.test.tsx` has no `parts` assertion (VERIFIED by grep).
- Plays query by role/accessible name, which survive unstyled rendering.
- axe has no "unstyled" rule.
- `footer/index.stories.tsx:236-237` (`SubscribePlaceholder`) does measure geometry — but it asserts
  before/after *stability* within one render, not against a baseline, so a uniformly-wrong height
  passes.

**NOT CAUGHT.** Highest-value gap.

Partial exception: `ZimmTextInput` *does* have a guard —
`zimmTextInput.test.ts:81-84`, `expect(parts.sort()).toEqual([...ZimmTextInput.parts].sort())`. But
it compares `parts` to `baseStyle` keys, so a rename applied to **both** stays green while the
component's `styles.oldName` goes undefined. Even the one guard that exists does not close S1; it
closes a narrower internal-consistency failure. The missing artifact is a **recipe-parts ↔
consumer-usage** assertion, which nothing in #55 has.

### S2 — a conditional render inverts

| Site | Caught? | By what |
|---|---|---|
| `footer/index.tsx:237` `submitState === 'idle' &&` | **CAUGHT** | `SubscribeSubmit` play — `getByRole('textbox', {name:/email/i})` throws |
| `footer/index.tsx:506` `showContactChannels &&` | **CAUGHT** both directions | always-false → `Default` play's `getByRole('link',{name:/whatsapp/i})` throws; always-true → 3 matches, `getBy*` throws on multiple |
| `footer/index.tsx:317` `isSafeHref(href) ? <a> : <span>` | **CAUGHT** both directions | `Default` asserts the anchor branch; `ContactChannelFallbacks:196-197` asserts the span branch (`queryByRole('link')` absent + `getByRole('img')` present). Strongest play in the set. |
| `footer/index.tsx:194` `initialSubscribed ? 'success' : 'idle'` | **CAUGHT** | inverted → `SubscribeSubmit`'s `getByRole('textbox')` throws |
| `zimmNavItem/index.tsx:35` `href && isSafeHref(href)` → a/button | **CAUGHT** | `PlaceholderButton` asserts button-no-href; `KeyboardFocus` asserts a link |
| `footer/index.tsx:461,479` `showContactChannels ? {paddingLeft:'2xs'} : {}` | **NOT CAUGHT** | pure geometry |

Verdict on S2: the plays are **better** here than a typical co-located render test would be. They
assert real `rel`/`target` hardening, real accessible-name suffixes, and real post-submit state.

### S3 — a prop stops being passed down through the molecule to the atom

| Prop | Caught? | By what |
|---|---|---|
| `trailing` (`zimmInputAction:69` → `zimmTextInput:119`) | **CAUGHT** | three plays lose `getByRole('button',{name:/submit/i})` |
| `errorText` (`zimmInputAction:67`) | **CAUGHT** | `Error`/`EmptySubmitValidation`/`InvalidEmailValidation` all lose `getByRole('alert')` |
| `name` (`zimmInputAction:64`) | **CAUGHT** | `namedItem` → null → value `''` → validation path → `SubmitInteraction`'s `toHaveBeenCalledWith` fails |
| **`inverse`** (`zimmInputAction:65`, `footer:244`) | **NOT RELIABLY CAUGHT** | threaded 4 levels (footer → molecule → atom → recipe), purely visual. axe `color-contrast` *might* fire, but it is unreliable against `var()`-driven Chakra styles in a headless build. |
| `disabled` (`zimmInputAction:66`) | **NOT CAUGHT** | no play exercises disabled at molecule level |

`inverse` is the second real gap and the most likely in practice.

### S4 — an `aria-label` or `aria-current` is dropped

| Site | Caught? | By what |
|---|---|---|
| `footer:325` contact anchor `aria-label` | **CAUGHT twice** | only child is `aria-hidden` icon → link with no accessible name → axe `link-name` (serious) fails under `test:'error'`; independently, `Default`'s `getByRole('link',{name:/whatsapp/i})` throws |
| `footer:523` logo button `aria-label="Zimmermann home"` | **NOT CAUGHT** | `ZimmLogo` is `<svg role="img" aria-label="Zimmermann">`, so the button still computes *a* name — axe `button-name` passes, name silently changes |
| `footer:366` locale button `aria-label="Change locale"` | **NOT CAUGHT** | text span child supplies a name |
| `zimmNavItem:39,53` **`aria-current`** | **NOT CAUGHT** | no axe rule; `Active`/`InverseActive` stories render it and assert nothing |
| `aria-modal` + focus trap | **OVER-covered** | `SubscribeModalOpen:126-161` asserts `aria-modal`, initial focus, fwd+back tab wrap, Escape, focus restore, scroll-lock restore — **and** `useSubscribeModal.test.tsx:85-121` asserts the same trap + scroll-lock at unit level. Violates `testing.md:3`. |

### S5 — the footer's Contentful data mapping produces the wrong shape

| Failure | Caught? | By what |
|---|---|---|
| `navGroups` absent | **CAUGHT (crudely)** | `.map` throws → story render fails → `test-storybook` fails |
| `legalLinks.map(e => ({label: e.fields.label}))` keyed wrong | **CAUGHT incidentally** | empty `<span>` in an `<a>` → axe `link-name`. By accident, not intent. |
| `phoneHref`/`emailHref` keyed wrong | **CAUGHT** | all channels fall to span branch → `Default` play throws |
| **`subscribeHeading`/`subscribeBody` keyed wrong** | **NOT CAUGHT** | `?? ''` → empty `<p>`s; no axe rule, no play |

And: **no test anywhere ties `FooterConfigEntry` / `FOOTER_FIXTURE` to
`contentfulSchema.placeholder.ts`.** VERIFIED — `git grep -l 'FooterConfigEntry|FOOTER_FIXTURE'
-- '*.test.*'` on the branch returns nothing. `testing.md:19` lists "Data mapping: Contentful →
component props" as the **first** must-test bullet. This is the one place #55 genuinely contradicts
its own rules, and the divergence is not defensible on the rules' logic.

---

## 3. What CI actually enforces

VERIFIED via `gh api repos/ZimmermannAU/zimmermann-pwa/branches/develop/protection`:

Required status checks on `develop` (`strict: true`, 1 approving review):
1. `Storybook interaction & a11y tests`
2. `Unit tests (Vitest)`
3. `🔴 Branch Target Check`

**So `play` + a11y IS a required, merge-blocking gate.** Strongest single fact in favour of #55.

- `.github/workflows/qa.yml:236-273` — `storybook-test` builds Storybook, serves it, runs
  `test-storybook --ci`. Confirmed locally: **9 suites / 27 tests passed**, exit 0.
- `vitest.config.ts:11` — `include: ['overrides/**/*.test.ts', 'overrides/**/*.test.tsx']`.
  **Vitest does NOT collect `play` functions — CONFIRMED.**
- `vitest.config.ts:12` — `passWithNoTests: true`. A zero-file Vitest run is green.
- Neither `scripts/hooks/pre-commit` nor `scripts/hooks/pre-push` runs any test suite (VERIFIED).
  So `.test.ts` files at least run on `npm test`; **plays only ever run in that one CI job.**

### The hole that matters most

`qa.yml`'s `detect-changes` uses `since_last_remote_commit: true`, and both required jobs are
`if:`-gated on path filters. `qa.yml`'s own inline comment states: *"a 'skipped' job counts as
passing."*

**VERIFIED LIVE on PR #59 at head `ec9d161`:**
```
Unit tests (Vitest)                    → SKIPPED
Storybook interaction & a11y tests     → SKIPPED
Playwright E2E (localhost)             → SKIPPED
```
Because the last commit touched only `.claude/registry/components.md` and
`scripts/generateRegistry.mjs`. Both required checks are **green-by-skip at the merge SHA.**
(PR #55's earlier rollup shows both SUCCESS, so the suites did run earlier in the PR's life —
this is a harness gap, not a #55 authorship failure.)

**What a component with only `play` coverage is genuinely protected by:** a required CI job that
runs every story as a render-smoke + axe check under `test: 'error'`, plus whatever the `play`
asserts — *conditional on that job not being skipped by the path filter*, and with no local
pre-commit/pre-push equivalent.

---

## 4. Suite run — real output

`npx vitest run --reporter=dot` on the current branch (`feature/SFCC-89`):
```
Test Files  4 passed (4)
Tests       146 passed (146)
Duration    17.91s
```
(Two benign `stderr | Could not parse CSS stylesheet` lines from `theme/index.test.tsx`'s rendered-
output tests.)

`test-storybook --ci` against the local static build:
```
Test Suites: 9 passed, 9 total
Tests:       27 passed, 27 total
Exit: 0
```

Note the current branch carries only 3 of #55's 9 test files; the 6 new ones
(`useSubscribeModal`, `useZimmTextInputState`, `recipeGuards`, `zimmTextInput`, `fontFace`,
`safeHref`) exist only on the footer branch — #55/#59 is **not** merged to `develop` (VERIFIED
via `git merge-base --is-ancestor`).

### Vacuous-pass audit

| File | Anti-vacuity protection |
|---|---|
| `recipeGuards.test.ts:168-174` | **Explicit self-test.** Gold standard: `expect(Object.keys(components).length).toBeGreaterThan(0)` + `expect(collect().length).toBeGreaterThan(0)`, with a comment saying exactly why. |
| `fontFace.test.tsx` | Guarded by construction — `expect(urls).toHaveLength(2)` in 4 of 6 tests |
| `theme/index.test.tsx:77,86,188,275` | Guarded by exact literal counts + one `toBeGreaterThan(0)` |
| `safeHref.test.ts` | Non-vacuous — 20 explicit case rows, each asserting a concrete boolean. Strongest file in the set. |
| `useZimmTextInputState.test.ts` | Non-vacuous — 8 concrete value assertions |
| `useSubscribeModal.test.tsx` | Non-vacuous — concrete focus/overflow assertions |
| `zimmTextInput.test.ts:81-84` | **Soft spot** — `parts.sort()` vs `[...parts].sort()` is vacuously true if both go empty. Low risk (literal array), but it is the same hazard class `collect()` guards, with no guard. |
| `footer` `SubscribePlaceholder:236-237` | Deliberately guarded — `toBeGreaterThan(0)` before comparing, with a comment explaining that a collapsed container would otherwise pass vacuously |
| plays in `zimmIcon:128-131`, `zimmLogo:19-22,37-40`, `zimmNavItem:62-70` | Near-tautological — `getBy*` already throws, so the trailing `toBeInTheDocument()` adds nothing. Not wrong, just no stronger than rendering the story at all. |

**Answer:** yes, the other suites are adequately protected — but **by construction, not by design**.
Only `recipeGuards` and `SubscribePlaceholder` do it deliberately. `zimmTextInput.test.ts:81` is the
one cheap fix.

---

## 5. What to adopt for the new build

For ~4 presentational atoms, one composing molecule, a sanitiser util, and a theme recipe:

| Artifact | Location | Must assert | Required? |
|---|---|---|---|
| `utils/<sanitiser>.test.ts` | co-located | Every **rejection** case as an explicit row, including any that regressed before. Model: `safeHref.test.ts`. | **Yes** — `testing.md:19` + conventions.md "≥1 conditional branch" |
| `theme/components/<recipe>.test.ts` | co-located with the recipe | (a) each exported resolver's branch precedence, one test per branch — including the branch only distinguishable in one state; (b) `Object.keys(baseStyle(props))` deep-equals `parts`; (c) **NEW: `parts` ⊇ the part names the component actually reads** | **Yes** |
| `<atom>/index.stories.tsx` | per atom | Story alone = render + axe. Add a `play` **only** where there is real interaction or an a11y contract (`aria-current`, accessible name). Do **not** write tautological `getByRole(...); expect(...).toBeInTheDocument()` plays. | Story yes, `play` conditional |
| `<molecule>/index.stories.tsx` with `play` | molecule | Full submit path, empty-submit validation, invalid-input validation — each asserting the callback **was / was not** called. Model: `zimmInputAction` stories. This is what replaces a co-located molecule test. | **Yes** |
| `hooks/use<X>.test.ts` | co-located | Only if state was extracted. Assert ownership/lifecycle, not rendering. Model: `useZimmTextInputState.test.ts`. | If extracted |
| `<component>/index.test.ts` | co-located | **Only for the external-data-shape mapping seam.** See below. | Conditional |
| **No** co-located test for the 4 atoms | — | They are prop→JSX passthroughs — `testing.md:23` explicitly excludes "one-line passthroughs" | **No** |

### The one case where a co-located component test IS warranted

When the component owns a **mapping from an external data shape to props** — exactly the footer's
`data.fields` destructure plus `legalLinks.map(e => ({label: e.fields.label, href: e.fields.href}))`.

Why no other layer can own it: `testing.md:19` puts it first on the must-test list; a `play` only
sees *rendered output*, so a field that silently maps to `''` is invisible to it; and axe catches
only the subset that happens to produce a nameless **interactive** element. Extracting the mapping
to a pure function and testing that is equally acceptable — and more in the spirit of #55 — but it
must not be left to a `play`.

### Also adopt, explicitly

1. **Anti-vacuity self-test** as a required element of any test asserting an empty offender list
   (`recipeGuards.test.ts:168-174`).
2. **Name the failure mode in a file-level docstring**, not the mechanism. Every #55 test file does
   this; it is why the suite reads as a design rather than a checklist.
3. **Do not double-cover.** `useSubscribeModal`'s focus trap is asserted at both layers. Keep the
   unit test (cheaper, faster, runs on `npm test`) and let the `play` assert only what the unit test
   cannot — that the modal is actually wired to the trigger.

---

## 6. Corrections #55/#59 needs — follow-up, not blockers

1. **`overrides/app/theme/components/footer.test.ts`** — parts↔consumer contract for the 35-part
   `ZimmFooter` recipe. Highest value; zero drift today so it lands green as a pure regression net.
2. **Footer Contentful mapping coverage** — `footer/index.test.ts` over the `data.fields`→props
   mapping, or extract and test the function. Closes the one place #55 contradicts `testing.md:19`.
3. **`aria-current` assertion** on `zimmNavItem`'s `Active` story — one line, closes S4.
4. **`inverse` threading** — assert it in the molecule's `Inverse` play, or record it as
   visual-only. Currently silent across four levels.
5. **Anti-vacuity guard** at `zimmTextInput.test.ts:81` —
   `expect(ZimmTextInput.parts.length).toBeGreaterThan(0)`.
6. **De-duplicate focus-trap coverage** between `useSubscribeModal.test.tsx` and
   `SubscribeModalOpen`'s play (`testing.md:3`).
7. **Not #55's to fix** — the skipped-required-check hole. Raise separately; `.github/workflows/`
   is Tier 1.

---

## 7. Should `.claude/rules/testing.md` change?

**Yes — one line, and it is a clarification, not a policy change.** `.claude/rules/` is **Tier 1
governance** (`frozenFiles.md`, owner: Both Squad Leads + Integration Lead), so it needs that
approval and cannot ride along in a feature PR.

Current, `.claude/rules/testing.md:42-43`:
> Components use `index.test.ts` next to `index.tsx` in the component folder
> (see [components.md](./components.md) > Components).

Proposed replacement:
> When a component warrants a Vitest file, it goes at `index.test.ts` next to `index.tsx` in the
> component folder (see [components.md](./components.md) > Components). This is a **location** rule,
> not an existence rule — per **What to test** above and AGENTS.md > Testing, a component needs a
> Vitest file only when it owns logic a `play` cannot observe. The clearest case is a mapping from an
> external data shape (Contentful entry → props): a `play` sees rendered output, so a field that
> silently maps to `''` is invisible to it. Presentational prop→JSX components are covered by their
> story (render + axe) plus a `play` where there is interaction.

This (a) removes the misreading, (b) states the one positive case where a co-located test *is*
required, and (c) aligns `testing.md` with `AGENTS.md:151`, `new-component/SKILL.md:23,50`, and
`code-quality/SKILL.md:95`, which already all agree with each other.
