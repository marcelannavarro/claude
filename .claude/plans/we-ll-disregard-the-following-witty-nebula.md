# Realign PR #68's body and title with what the branch actually ships

## Context

PR #68 (`feature/SFCC-194_pdp-was-now-price` → `develop`) has moved four times since its body was
written: the `variantScopedPrice.ts` extraction, a registry regen, the Figma token corrections
(`fd249e4`), and an a11y-test suppression (`beb63bd`). The body was rewritten along the way and is
mostly good, but a set of claims are now factually wrong against the diff at `beb63bd`.

Two of the errors are mine. My posted review told Jersey the sale colours "aren't specced", which
is false — Figma's `pdp/price` component (`40001132:7332`) binds them explicitly. He repeated that
claim in the body in good faith, in three places. Correcting the body is also how that error gets
retired.

This is a documentation-only change. **No source files are touched.**

---

## Verified misalignments

Checked against `git diff origin/develop...origin/feature/SFCC-194_pdp-was-now-price` at `beb63bd`.

### A. Factually wrong

| # | Body claims | Reality |
|---|---|---|
| A1 | *"original list price **struck through** as 'Was'"* (opening sentence) | No strikethrough. `grep -ciE "textDecoration\|line-through"` on the recipe → **0**. Figma specs greyed (`alias/color/text/subtlest`), not struck. |
| A2 | *"`theme/components/index.ts` — registers `ZimmProductPrice` recipe"* | That file is **not in the diff**. Registration pre-existed from SFCC-89 (#64). |
| A3 | Storybook renders *"`Default`, `OnSale`, `Loading`"* — stated twice | Actual exports: `Default`, `OnSale`, `AcrossStorefrontCurrencies`. **There is no `Loading` story.** |
| A4 | *"Sprint: SFCC — Sprint 5"* | Jira `customfield_10020` = **SFCC Sprint 4** (active, 25 Aug – 7 Sep 2026). |
| A5 | *"`productInfo` (22 tests total)"* | Static count: 16 blocks, one `test.each` of 3 → **18**. Needs a run to confirm. |

### B. Stale since `fd249e4` / `beb63bd`

| # | Body claims | Reality |
|---|---|---|
| B1 | Accessibility: *"`text.secondary` (#666666) **5.74:1** … Both pass AA for 14px/**400**"* | Now `--zimm-color-text-muted` **#969696 = 2.95:1**, which **fails** AA — deliberately, to match Figma. Weight is **500**, not 400. |
| B2 | No mention of the a11y suppression | `beb63bd` adds `parameters: { a11y: { test: 'off' } }` to **both** `OnSale` stories. This disables the a11y smoke-test for those stories entirely, not just the contrast rule. Needs stating plainly — it is the kind of thing a reviewer must not discover by accident. |
| B3 | Recipe described as *"flex row"* | Now `display: inline-flex`, `align-items: center` — matching Figma's `state=Sale` node. |

### C. My error, repeated in three places

*"PRC-09 specifies no colour"* / *"No colour or strike-through is specified in PRC-09"* /
*"`status.success` is a provisional sale-price token"*.

Figma **does** specify both, in `Zimmermann_Design_System_2026` node `40001132:7331`:

```
Was  →  alias/color/text/subtlest   #969696
Now  →  alias/color/text/success    #2d5a3d
gap  →  alias/space/200             8px       font → Futura Round 14/18/500/0
```

The correct framing: the values are design-system-specified and correctly implemented. What
remains outstanding is that Figma names the Now colour `text/success` while we source it from
`status.success` — a Tier 1 alias addition in `foundation/colour.ts`, gated to the UI designer by
AGENTS.md Hard Rule #3. That is a token-hygiene follow-up with **no visual difference**, not a
provisional stand-in.

### D. Minor

- **D1** — "How to test-drive" says to use `E2E_SALE_PRODUCT_SKU`, which is **blank** in `.env`,
  `.env.dev` and `.env.sample`. The instruction cannot be followed as written.
- **D2** — *"`npm run lint` — no new errors introduced"* was false at `70bb525` (2 new
  `prettier/prettier` errors in `variantScopedPrice.ts:84,115`). Must be re-run at `beb63bd`.
- **D3** — Test total *"407 passed / 26 files"* measured 408 at `70bb525`. Must be re-run.

### E. Title — no change (decided)

`feat(pdp): SFCC-194 Was/Now sale price — variant-scoped pricing and PRC-09 sale display` stays
as-is. Nothing in it is factually wrong, and it is already surfaced in Jira's dev panel and in
reviewer notifications. **Body-only edit.**

---

## Approach

**Step 1 — Get the two runtime numbers.** Tree is clean at `beb63bd`, so run in place:

```
npx tsc --noEmit
npm run test                     # → real total + file count for D3 and A5
npx eslint --resolve-plugins-relative-to node_modules/@salesforce/pwa-kit-dev \
  "overrides/**/*.{ts,tsx}"      # → confirm/deny D2
```

If D2 still shows the two `variantScopedPrice.ts` errors, the body's lint claim must say so rather
than assert a held baseline.

**Step 2 — Edit the body**, applying A1–A5, B1–B3, C and D1–D3. Preserve everything that is
already accurate — the extraction rationale, the unreachable-mechanism note, the `isRange`
explanation, the stale-`pid` write-up, the localisation section, the known-gaps list. This is
surgical correction, not a rewrite.

Specific edits:

- Opening sentence: *"struck through"* → *"greyed"*.
- Drop the `theme/components/index.ts` line from **Changes**.
- `Loading` → `AcrossStorefrontCurrencies` in both places; add that no `isLoading` story exists.
- Sprint 5 → **Sprint 4**.
- Rewrite the **Accessibility** contrast bullet: `#969696`, 2.95:1, 14px/**500**, states the
  divergence is deliberate to match Figma, and names the `a11y: { test: 'off' }` suppression with
  its two story locations.
- Replace the `status.success` bullet and the two matching lines in *Linked* and *Known gaps* with
  the Figma-specified framing from section C.
- Fix the `E2E_SALE_PRODUCT_SKU` instruction — note the var is unset and that Storybook is
  currently the only way to see the sale treatment.
- Correct test counts and the lint line to whatever Step 1 measures.

**Step 3 — Apply** via `gh pr edit 68 --body-file <path>`. Title is unchanged (see E). Draft to a
local file first for review; nothing reaches GitHub without sign-off.

---

## Out of scope

- **No source changes.** The two `variantScopedPrice.ts` prettier errors are a code fix for Jersey.
- **My two correction replies** (`~/Desktop/SFCC-194-corrections-draft.md`) are still unposted and
  now need rewriting — `fd249e4` already implemented the token change, so the retraction should
  confirm the outcome rather than request it. Separate task.
- **`text.success` Tier 1 alias**, **REG-042**, and **SFCC-778's strikethrough ACs** are all
  tracked follow-ups, not body edits.

---

## Verification

1. `gh pr view 68 --json body` — re-read after editing.
2. Re-check each corrected claim against the diff: no `line-through` in the recipe; no
   `theme/components/index.ts` in `--name-only`; three story exports; `a11y: { test: 'off' }`
   present in both `.stories.tsx`.
3. Confirm the test/lint figures quoted match the Step 1 output exactly.
4. Confirm no source file changed: `git status --short` clean, `git diff origin/develop...HEAD
   --stat` unchanged at 16 files / 864 insertions.
