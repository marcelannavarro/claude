# Ship the footer `tabletWide` breakpoint removal as a PR

## Context

The tester and Kiera both flagged the footer misbehaving on tablet. Investigation found three
symptoms — the email field crowding the nav groups, nav labels wrapping, and the bottom bar
growing taller — with one shared root cause: fixed-width pieces in a shrinking box with
`flexWrap: nowrap` closing the only escape route.

Inside that, one thing was **our own invention rather than a design constraint**:
`BP.tabletWide` (53.75em / 860px). Kiera confirmed the Figma Footer component has exactly three
size variants — Mobile 320–767, Tablet 768–1023, Desktop 1024+ — read off the comps' own
min/max widths. There is no fourth variant. The breakpoint had a single call site and was
actively harmful: the nav columns reach their natural width around 836px, but at 860px this rule
spent 40px more on gaps than the row had, squeezing them back below content width and re-wrapping
labels that had just recovered.

**Intended outcome:** delete the unbacked breakpoint. Measured across 768–1024 in 2px steps
against a built Storybook, this takes the broken span from ~124px to ~68px of the 256px tablet
band, and eliminates the 860–912 zone entirely.

The remaining 768–834 breakage is **out of scope** — it needs a design decision from Kiera about
which element flexes, and is tracked separately.

## Current state

Branch `fix/footer-tablet-wide-breakpoint`, cut from `develop` @ `04039a9`. Edits are already
made and verified; nothing is committed.

```
overrides/app/components/footer/footer.css.ts   |  3 ---
overrides/app/theme/components/footerShared.ts  | 17 +++++++++++++----
```

- **`footer.css.ts`** — removed the `@media (min-width: ${BP.tabletWide})` block on `linksInner`
  (a `gap` step from `3xl` to `5xl`).
- **`footerShared.ts`** — removed the `tabletWide` entry from `BP` and recorded why, so it isn't
  reintroduced. The `audit-allow:` comment was re-verified as still associating after the edit.

### Evidence already gathered

| check | result |
|---|---|
| `npx tsc --noEmit` | exit 0 |
| `npm run test` | 379 passed / 25 files |
| `npm run audit:tokens` | 4 on `develop`, 4 on branch — **zero added** |
| Browser measurement | broken span ~124px → **~68px**; 856–864 now holds 115/135/106 with no wrapping |

The wrap detector used for those numbers is falsification-checked: it reports the by-design
"Acknowledgement of Country" wrap at 1440 and nothing else, and correctly reports 2 lines when an
anchor is forcibly narrowed. An earlier detector was discarded for reporting every label as
wrapped.

## Plan

### 1. Pre-commit review gates

Run in order, on the branch as it stands:

- `npm run lint` — **capture the `develop` baseline first** (`git stash`, run, `git stash pop`).
  Lint is gated nowhere in CI and is known to fail repo-wide on pre-existing prettier errors; the
  only question is whether this change *adds* any.
- `/code-quality` — read-only audit of the branch diff against `.claude/rules/`.
- `cr review --light --base develop` — CodeRabbit CLI 0.7.5 is installed and `cr` is on PATH.
  Required by AGENTS.md before a non-trivial commit. Confirm `coderabbit auth status` first.
- `node_modules/.bin/test-storybook --ci --url http://127.0.0.1:6006` against a **built**
  Storybook — this is what CI runs (`qa.yml:405-411`); there is no npm script for it.
  `storybook-static` is already built from this branch. Serve it on 6006 first.

The Storybook run matters because `index.stories.tsx` has a `play` function that measures layout
stability. It compares *before/after* heights rather than absolute values, so a breakpoint change
should not affect it — but that is an assumption to test, not state.

Fix anything these surface, then re-run the affected gate.

### 2. Commit

One commit, conventional format per `scripts/hooks/commit-msg`. **No `Co-Authored-By` trailer.**

Proposed subject:

```
fix(footer): remove the unbacked 860px tablet-wide breakpoint
```

Body should state: the breakpoint had no Figma variant (confirmed by the UI designer against the
comps' min/max widths), it had one call site, and removing it takes the broken tablet span from
~124px to ~68px measured in 2px steps against a built Storybook.

### 3. Push and open the PR

Match the house style from merged PRs #46/#47 — **not** the literal template, which is
aspirational. Plain conventional title, no SFCC key in the title.

Body sections in order: `# Description` → `# Linked` → `# Squad ownership` →
`# Types of Changes` → `# Changes` → `# How to test-drive this PR` → `# Protection-tier check` →
`# Testing`. Omit Accessibility / Localisation / Third-party sections entirely rather than
padding them with "n/a".

**Linked** (decided with the user):

```
- Follows up: SFCC-55 (Global Footer UI, merged in PR #59)
- Sprint: SFCC Sprint 5
```

No live ticket. Note the consequence honestly in the PR: with no `SFCC-\d+` key in the title,
body or branch name, `e2e-browserstack` will not run at all. That is by design in `qa.yml`, not a
failure — there is nothing to attribute results to in Zephyr.

**Protection-tier check** — this change spans two tiers and the PR must say so:

| file | CODEOWNERS rule | owner |
|---|---|---|
| `footer/footer.css.ts` | line 186 (last match wins) | `@pwa-squad-a @pwa-squad-b` — Tier 3 |
| `theme/components/footerShared.ts` | line 117 | `@tier-2-approvers` — **Tier 2** |

### 4. Notifications owed

- **Squad B** — `footer/` is Tier 2 Global Shell, owned by both squads.
- **Kiera / UI designer** — `theme/components/` is designer-owned, and this change is a direct
  result of her variant-spec message. Send the drafted reply covering the 768–834 options at the
  same time.

## Verification

After the PR is open:

```bash
gh pr checks <n>          # read for "skipping", not just green
```

Both changed files fall inside `qa.yml`'s watched paths (`overrides/app/components/**` and
`overrides/app/theme/**`), so `unit-tests` and `storybook-test` should genuinely run rather than
skip. If either reports `skipping`, that is a signal to investigate, not to merge.

End-to-end confirmation that the fix holds:

```bash
npm run build-storybook
python3 -m http.server 6099 --directory storybook-static &
# then measure Layout/Footer → Default across 768–1024
```

Expected: no unplanned label wrapping from **836px** upward, gap steady at 40px across 856–864,
columns holding 115/135/106. The only wrap at any width should be "Acknowledgement of Country",
which is by design.

## Explicitly out of scope

- **768–834 still breaks.** Needs Kiera to choose which element flexes. Three measured options
  exist (narrow the email field to 240px; let the nav wrap to two rows; tighten everything).
- **Bottom bar** — "Terms & Conditions" wraps below ~909px, making that bar 14px taller.
- **`BP.desktop` (1024) vs `gridSystem.xl` (1280)** — the footer changes layout 256px before the
  page grid does. May be intentional; `gridSystem.ts` is Tier 1, so it is a separate conversation.

## Approval gate

Do not commit, push, or open the PR without explicit approval. Run the review gates, report what
they find, show the diff and the drafted commit message and PR body, then stop.
