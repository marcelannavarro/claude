---
name: project-footer-pr69-parked
description: "STALE as of 2026-09-01 — PR #69's branch has since moved on to unrelated content (see note at top). Original note kept below for history."
metadata: 
  node_type: memory
  type: project
  originSessionId: 113175e9-2496-4539-9640-84df14f78583
  modified: 2026-09-01T08:45:39.107Z
---

**STALE — corrected 2026-09-01.** Checked PR #69 live (`gh pr view 69`) while reviewing the
unrelated PR #65: its current title/body is "fix(footer): remove the 860px tablet-wide
breakpoint" — a different, self-contained, already-CodeRabbit-clean fix (removes
`BP.tabletWide`/`footerShared.ts`'s `tabletWide` entry). No mention of the `946px`/
`SIZE_SUBSCRIBE_SLOT`/Kiera-questions work described below anywhere in the live PR. Either the
stash was abandoned/superseded or the branch was reused — unconfirmed which. **Don't cite the
"parked, blocked on Kiera" state below as PR #69's current status without re-checking `gh pr
view 69` first** — a PR #65 review sub-agent cited this file as if it still described PR #69 and
that claim didn't survive checking the live PR. Original note preserved below for history only.

---

**State at pause (2026-08-28) — historical, may no longer be true, see above.** Branch
`fix/footer-tablet-wide-breakpoint`, one commit pushed (`21fca2f`), PR #69 OPEN and
**APPROVED** but explicitly not to be merged. Three files modified **stashed** (2026-08-28) as
`stash@{0}`, message beginning *"PR #69 footer: 946px stack…"*:
`footer/footer.css.ts`, `theme/components/footerShared.ts`, `footer/bottomBar/bottomBar.css.ts`
— 3 files, +62/−21. Recover with `git stash pop stash@{0}`; verify by grepping the stash for
`sitemapInline`, `SIZE_COL_MAP_TABLET` and `flexWrap: 'wrap'`. **Stash numbering shifted** — the
older SFCC-89 PDP WIP is now `stash@{1}`, so index by message, not number. All gates were green (tsc 0, 379 Vitest, 98 Storybook,
lint/audit at develop's baseline, CodeRabbit no findings).

**Pushing will dismiss the approval** — `develop` has `dismissesStaleReviews: true`.

**Three questions block the commit, all for Kiera:**

1. **Bottom bar tablet padding.** Figma Legel (40000407:23786) is `px-[32px]`; we render 40px.
   The 40 is **Tim's** deliberate call (`5ecd515`, 23 Aug) with a written rationale that treats
   the 8px offset as a bug — Figma says it's intent (Content and Logo 40, Legel 32, tablet only;
   desktop is 40 everywhere). Not reverted, because overriding the lead's documented decision on
   a design read is a stop-and-ask under AGENTS.md's doc-integrity rule.
2. **`SIZE_SUBSCRIBE_SLOT`.** Already flagged provisional at 45px; Figma's success state implies
   59px. Neither covers the **67px** the validation-error state actually needs.
3. **Does the field's error message sit inside the Textfield's box or below it?** We append
   below, which is what grows the slot. If the design keeps it inside a 320×44 box, no
   reservation change is needed at all. The four error-state nodes Marcel found
   (`QQ427wHWEUjsjP7H8v48Rs` 8107:723/724/725/729) are **all deleted** — that file now has one
   page named `-----`, so there is nothing to reference.

**Measured, so it doesn't need re-deriving:** the validation error grows the control slot
45→67px (+22) at every breakpoint. Stacked (<946) everything below shifts down; inline (946+)
the site map holds and only logo/bar move. `SubscribePlaceholder`'s shift guard passes because
it exercises the *submit-unavailable* path (36px, fits) — the validation path was never covered.
Root cause is that the 45px reservation was derived from the idle state alone, so bumping the
number without a test across **all** states repeats the defect.

**Why:** three separate threads are parked mid-flight on one branch, and the approval on #69 is
stale relative to what's now in the working tree.

**How to apply:** don't commit or push until Kiera answers; when she does, batch all three.
See [[project-styling-layer-boundary]] and [[project-figma-metrics-rule]] — the two-Figma-file
trap applies here, the deleted nodes were from the composed-page file, not the design system.
