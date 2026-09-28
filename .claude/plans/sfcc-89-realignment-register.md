# SFCC-89 — three-way divergence register (verified)

Docs (154 checkable rules) × PR #59 as merged (`8362b3c`) × our 29 staged files.
Built and verified 2026-08-25. Every row below reproduced from source by an independent pass.

**Measured this session:** `audit:tokens` 19 unacknowledged — 14 pre-existing on develop, 5 in our ported `product-view`. `tsc` 0 · Vitest 354 · Storybook 100 · lint at develop's 17-error baseline.

---

## MUST-FIX

| # | Finding | Evidence | Note |
|---|---|---|---|
| **D1** | **An absent price renders an empty styled node.** `productInfo.ts:58` emits `price: ''`; `zimmProductPrice/index.tsx:22-25` renders `<chakra.p>` unconditionally with no guard. An empty `<p>` **is** an element child and therefore a flex item, so `zimmProductContent.css.ts:23-29`'s `gap` produces **two** 20px gaps instead of one — a doubled gap with nothing in it. Reachable in production via `product-detail/index.tsx:715`, where the `headerProduct ?? { name }` fallback carries no `priceData`. | verified end-to-end incl. the flex-item question | **Fix in the atom or molecule, not the mapper.** `productInfo.test.ts:70-73` asserts `''` deliberately — editing `productInfo.ts` breaks a passing test that encodes a considered decision. |
| **D9** | **Same failure class, second site.** `product-detail/index.tsx:881` — `<Stack spacing="l" paddingTop="l">` wraps two atoms that both return `null` whenever `staticInfo` is null, which is every render while the product loads (`productInfo.ts:54` returns `null` on `!product?.name`). Chakra's `Stack` null-filters children but **always renders the wrapper**, leaving a 20px empty padded box below the accordions. | Chakra 2.7.0 `getValidChildren` | Missed on the first pass — the same line was inspected for token usage and R71 was never applied to it. |
| **D7** | **SUPERSEDED — `useUiCopy` removed entirely (plan 4e), so no Contentful entry is needed.** Original finding: **`pdp.styleCodeLabel` exists nowhere.** One occurrence repo-wide: the consuming call site at `zimmProductStyleCode/index.tsx:33`. No seed, fixture, migration or content-type defines it. Until an entry exists the label is the hardcoded English fallback everywhere. | grep, whole repo | Affects **3 non-English locales** (`es`, `fr`, `it`) of the 11 configured — not 10, as first written. Whether an entry exists in any Contentful environment is **unverified**; no network call was made. |

---

## MUST-FIX — added by the V&V pass (2026-08-25)

| # | Finding | Evidence |
|---|---|---|
| **D17** | **Loading-state layout shift.** Base sizes its title placeholder with `` {`${name}`} `` — `${undefined}` stringifies to `"undefined"`, so the shimmer is always a line of 2xl text tall (base `index.jsx:80-82`, ported at `product-view/index.tsx:200-202`). Ours passes `null` into `<Skeleton isLoaded={Boolean(info)}>` (`pages/product-detail/index.tsx:725-733`), and SFCC's Skeleton baseStyle is `{borderRadius, opacity}` with **no height** — so the shimmer is 0px and the title pops in with no reserved space. Ours-only code; missed by three prior passes. |
| **D18** | **Bundle price gate dropped.** Base gates *both* price and promo behind `!isProductPartOfBundle` (`index.jsx:84-95`); `renderStaticProductHeader` gates only the promo, leaving the price inside `ZimmProductContent` ungated. Currently unreachable — only the standard-product `<ProductView>` at `pages/product-detail/index.tsx:861` receives `renderHeader`, and the prop has zero occurrences in the base package — but `AGENTS.md:133` is unconditional, and the breadcrumb and promo callout are already reproduced in the same function for exactly this reason. |

### Numbering note
There is no **D8**. The original D8 (the `routes.tsx` Tier 2 PR-body declaration) was reclassified during verification as a to-do rather than a divergence and moved to NOTE without renumbering. Left as a gap deliberately rather than resequencing rows other documents already cite.

---
## SHOULD-FIX

| # | Finding | Evidence |
|---|---|---|
| **D2** | Recipe keys inlined at the call site (`zimmProductPrice:20`, `zimmProductDescription:18`, `zimmProductStyleCode:27`, `zimmProductContent:29`) where #59 hoists 8 to `ZIMM_*_RECIPE` module constants. (#59 authored 2 inline; a 3rd, `header/index.tsx:179`, pre-existed.) |
| **D3** | 5 unacknowledged raw literals in `product-view/index.tsx` (`'120px'`×3 at 722-724, `'32px'` at 775, `'200px'` at 833), each verbatim from base `index.jsx:636-638, 689, 754`. An `audit-allow:` comment takes the repo 19 → 14. **Not a regression** — see the baseline note below. |
| **D4** | `renderHeader` was added to `product-view`'s **default** export. The bridge rule binds: four base modules import it (`product-view-modal/index.jsx:17`, `.../bundle.jsx:21`, `bonus-product-view-modal/index.jsx:22`, `pages/product-detail/index.jsx:41`). The rule's literal wording is "full original prop surface", which an additive optional prop satisfies — so this is a judgement call, not a break. `product-view/index.tsx:13-17` asserts its own compliance without mentioning the added prop. |
| **D5** | Copy-first bundled with functional change in one set. `AGENTS.md:134`: *"Never skip this step or bundle it silently with functional changes."* No commits exist yet, so splitting into two is still available. |
| **D12** | **No test evidence that the ports behave identically.** Neither ported file has a test, and `vitest.config.ts:11` includes only `overrides/**/*.test.ts(x)` — so the base's own `product-view/index.test.js` and `product-detail/index.test.js` never run against our TypeScript ports. "Callers are byte-identical" is asserted in a comment and verified by nothing. `renderStaticProductHeader` itself branches (`headerProduct ?? { name }`, `info &&`) and is untested. |

---

## SHOULD-FIX — added by amendment (2026-08-25)

Two Step 1 changes originally had no register row, so the plan was extending its own basis. Both were independently verified; recorded here to close that gap.

| # | Finding | Evidence |
|---|---|---|
| **D13** | **`product-view/index.tsx:19` asserts a protection that does not exist.** The line reads *"Tier 2 (Shared Product Components, owner Squad B — see .claude/rules/protectedFiles.md)."* Four sources contradict it: `protectedFiles.md:29-36` lists six directories and not this one; `CODEOWNERS` has no matching entry and no catch-all `*`, so nobody is auto-requested; `protected-file-guard.yml:215-220`'s tier2 glob omits it; `.claude/registry/components.md:54` says Tier 4. The harm is specific — a reviewer trusts the label and skips a check nobody is performing, on the largest file in the PR. |
| **D14** | **The port's "full original prop surface" claim is false at two props.** Machine-diffed: base \ ours is exactly `['alignItems','promotionId']`; ours \ base is exactly `['renderHeader']`. Base declares both (`index.jsx:1046,1049`) and `bonus-product-view-modal/index.jsx:473,477` passes both. Runtime is unaffected — neither is read, and the destructure has no rest spread — but the file's own header states the opposite of what it does. |

---

## Decisions settled (2026-08-25)

| Ref | Decision | Basis given |
|---|---|---|
| **X1 / X2** | **Two recipes.** `zimmProductName` and `zimmProductModelInfo` each get a co-located `.css.ts`; the colour leaves JSX entirely. | PR #59 as sole basis: **zero** bare token keys in its component JSX, and **zero** brand colours declared outside a recipe. Its only two `var()`-in-JSX uses (`footerNavColumn:44,62`) are conditional spreads a static recipe cannot express; an unconditional colour has no such excuse. |
| **X4** | **No page story. Story the extracted partial instead.** | #59's own precedent: `footer/index.stories.tsx:4,9` stories the presentational `Footer`, not the fetching `FooterContainer`. Our page is the container. Reinforced by Tim's PR #52 direction — a page story would stub ~30 hook call sites including `useProduct`, which is the opposite of pulling from SF hooks; the partial stubs none. |
| **D13** | **Delete the tier self-label.** | #59 never badges a file with its own tier. Its three tier mentions are all constraints on *another* file (`footerNavColumn/index.test.tsx:11`, `footer/index.tsx:170`, `zimmTextInput.css.ts:37`). **Decided 2026-08-25: delete the line outright — no replacement text and no `.claude/rules/` amendment.** The V&V established that a rules note would have precedent (#59 made three `docs(rules)` commits and wrote the analogous `overrideStyling.md:224-225` passage itself), so this is a deliberate scope choice, not an oversight. |

---

## Design-system verification (2026-08-25)

Measured directly from `pdp/product-content` in `Zimmermann_Design_System_2026` — Desktop Default `40000307:14062` and Mobile Default `40000343:9727`. Per the two-file rule these are **not** cross-compared with the `Zimmermann_Designs` page frames. Only frame/instance boxes are used; text nodes report cap-height and are excluded from every measurement below.

**Confirmed, no change needed**

218px info column on all four desktop states · `Content` frame exactly **218 × 82** · 20px internal rhythm twice over (name-block bottom 24 → price 44; price bottom 53 → description 73), identical on mobile · `styleCode` is **two nodes**, label w=57 at x=0 and value at x=61, so the 4px gap is right, and it renders `Style Code: 7300JS261` — matching our two-node-plus-space implementation exactly · composition order exactly as built (name+wishlist → price → description → colour → size → CTAs → drawers → model line → style code) · `Badge` is a hidden layer in Default, correctly out of scope · `heading3` carries `textTransform: uppercase`, so the design's "PRODUCT NAME" is the transform and our atom already produces it · `pdp/price` has `Sale` (143 wide) and `Default` (37 wide) states, justifying SFCC-194's extension point.

**D15 — the meta-block rhythm is 28px, not 20px.** Identical on both breakpoints:

| | Desktop | Mobile |
|---|---|---|
| Drawer bottom → model line | 534 → 562 = **28** | 550 → 578 = **28** |
| Model line → style code | 570 → 598 = **28** | 586 → 614 = **28** |

`spacing.ts` brackets it (`xl` 24, `2xl` 32) with no 28 step. `--zimm-scale-700` holds the value but `theme/index.ts:47-49` confines the numeric aliases to `.zimm-*` global classes, so it is unavailable to a recipe. **Genuine token gap.**

**D16 — returns-eligibility notice. OUT OF SCOPE (settled 2026-08-25).** `Content` holds a hidden container (`Icon_info_solid` + message) reading *"This item is not eligible for return or exchange"*. **Only the `Warning` state reveals it** — `Unavailable` (`40003021:102385`) and `Coming soon` (`40003021:102773`) both have `Content` at 218×82 with the container hidden and every child at Default's y-positions, so neither touches our component; their difference lives in the Size selector / Button / Link instance properties (SFCC-92). Scoped out: not one of the ticket's enumerated fields. **Route to PRC-12, not SFCC-748/749** — the earlier ground was wrong: `.docs/prd/pricing-currency-globale.md:38` documents `is_returnable` and `final_sale` as **confirmed**, so the data source exists and is named. Designer batch: that same PRD line says *"no final-sale icon in design yet"* while the DS `Warning` state carries `Icon_info_solid`. Deferring is structurally free — the molecule's existing 20px `gap` and null-collapsing children already accommodate a fourth child.

**Open item (b) now has a design answer.** The five drawers are **Details & Care · Size & Fit · Shipping & Returns · Assistance · Label**. None is the base's "Product Detail" panel. The description therefore appears exactly **once** in the Zimmermann design — in the content group. The duplication is an artefact of retaining an untouched base accordion that renders a panel the design does not contain, not an unresolved design question.

**Two for the designer batch.** The DS mobile component uses a **32px** gutter (338 content at x=32 in 402); the composed page was recorded at 30px — a third DS-vs-page inconsistency alongside Button 50-vs-52 and the style-code question, and not cross-comparable. And the **768–1279 band is confirmed undesigned** — `pdp/hero` and `pdp/product-content` each ship exactly two sizes, 1440 and 402.

**Incidental corroboration for D1.** `Content` is reused in the Desktop Expanded gallery header (`40001999:3064`) with **only** the product name — no price, no description — independently supporting making `price` optional.

**Not ours.** The 44px gap is `Content` → `Colour Options`, i.e. SFCC-91's boundary.

---

## NOTE — record, don't necessarily act

- **D6** — runtime `propTypes` removed from both ports (`product-view:1043-1048`, `product-detail:945-950`). Dev-only validation, replaced by TS types, but it is base behaviour removed.
- **D10** — bare Chakra token keys in **our own** stories: `zimmProductName/index.stories.tsx:36,46`, `zimmProductPrice/index.stories.tsx:28`. We indict #59 for exactly this. Invisible to both gates (`auditTokenUsage.mjs:62` excludes `*.stories.tsx`; `recipeGuards` walks recipes only).
- **D11** — the port also carries `fontSize="2xl"` (`product-view:201`) and `color="blue.600"`×5 / `orange.600"`×3. All verbatim from base and invisible to `audit:tokens` (it greps px/rem/em/hex only), but `fontSize="2xl"` is literally recipeGuards' documented failure mode 2: `fontSizes` is unregistered (`theme/index.ts:29`) and `2xl` is not a Zimmermann key (`typography.ts:6-12`), so it silently reads Chakra's default.
- **PR-body items, not code:** `routes.tsx` is Tier 2 Global Shell (`protectedFiles.md:20`) and must be declared; no PR exists yet.

---


## CONFLICT — developer decides

**X1 — `var(--zimm-*)` in component JSX: required, or itself the smell?** The docs support both readings. Reading A: a bare token string is the finding, rewrite as `var()`. Reading B: design values shouldn't be in JSX at all, so the fix is to move them into a recipe. Sites: `zimmProductName:20`, `zimmProductModelInfo:23` (`color="text.default"`), `product-detail/index.tsx:881` (`spacing="l" paddingTop="l"`). **A = three rewrites; B = two new recipes.** Interacts with X2.

**X2 — must every component have a recipe?** R34 says styling always lives in a registered recipe; #59 ships `zimmIcon`, `zimmLogo`, `zimmInputAction` with none. Our `zimmProductName` and `zimmProductModelInfo` have none, justified in JSDoc. Resolving X1 toward Reading B forces recipes here.

**X4 — do pages need a Storybook story?** `Pages/` is a listed category; no page in the repo has one. We have none for `pages/product-detail`. #57 does.

---

## #59's own deviations — all confirmed, citations exact

`header.ts:59` and `listMenu.ts:17,33,65,84` use numeric `--zimm-scale-NNN` aliases in recipes · `header.ts:56,59` still uses Chakra array shorthand · `zimmSubscribeModal/index.tsx:64,98,99` hardcodes `Join Us`/`Cancel`/`Continue` and never calls `useUiCopy` · story decorators use bare Chakra keys throughout · `footer/index.tsx:169-171` self-flags that its fetch violates `components.md`.

---

## CONFORMS — sampled and checked, not assumed

16 registered recipe keys, all four ours `Zimm`-prefixed and clearing recipeGuards' namespacing guard · `var(--zimm-*)` in all four `.css.ts` · placement, naming, `<Name>Props` at file top, JSDoc across all six · `Default` export and `Commerce/` title in all six stories · `storybook/test` import path · three test files for the three branching atoms · `recipeParts.test.ts:85-90` vacuity guard real and passing · no `package.json`, foundation, test-config or `.scss` change · relative `product-view` import with `isFromExtends` cited · copy-first markers gone.

**One CONFORMS claim was over-broad and is corrected:** *"`textStyle` for all type, no raw `fontSize`"* holds for our six authored components but not for the diff as a whole — see D11.

---

## Baseline note (was logged as a conflict; it is not one)

The first draft recorded a conflict between a documented baseline of 19 and a measured 14. There is no conflict. `uiBuild-knowledge.md:724` states verbatim: *"19 unacknowledged violations, 14 pre-existing plus 5 in `product-view/index.tsx`"* — the docs already count our five and name the file. `fedBuild-manual.md:345`'s *"Don't add to it"* means don't exceed 19; we are exactly at 19. D3 is therefore an improvement available to us, not a regression we introduced.

**Two process notes worth carrying forward.** The verification pass judged this row "fabricated — no document states 19", which was wrong: the statement lives in the `~/Dev` docs, and the verifier had been told not to read them. The scoping error was mine, not the agent's. Separately, the same pass was correct on the locale count where the register was wrong. Both directions are why the numbers were re-checked by hand rather than either report being taken at face value.

## Dropped as non-findings

- The Tier 2 `routes.tsx` declaration reads identically whatever the code says — a to-do, not a divergence. Moved to NOTE.
- "Tier read off imports vs rendered template" resolves the same way for `zimmProductContent` either way. No practical impact.
