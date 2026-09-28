# Closed-Loop Review — PR #61 (SFCC-751)

## Context

PR #61 "SFCC-751: BrowserStack/Zephyr Scale QA automation pipeline" is up for our review.
42 files, +2886/−266, 20 commits, `feature/browserstack-ci-automation` → `develop`,
author TimLavelleACC. CodeRabbit has approved after several CHANGES_REQUESTED rounds; no
human review yet (`reviewDecision: REVIEW_REQUIRED`).

We are running it as a four-stage closed loop: I hold ground truth and adjudication,
delegated agents do only the reading. The reason this PR warrants the full loop rather
than a normal read is established below — **this repo's automated gates are effectively
blind to it**, so the usual "CI is green" signal carries almost no information here.

Confirmed operating constraints:
- **No branch checkout.** The working tree has 29 staged/modified SFCC-89 files. All PR
  access is via the already-fetched read-only ref `pr/61` (`git show pr/61:<path>`).
- **No local gates, no worktree** (user's call, made knowing the coverage finding below).
  The gate table is harvested from the PR's existing CI runs instead. Consequence: **no
  base-vs-head baseline comparison exists**, so we cannot mechanically separate introduced
  from inherited failures. This is a forfeited control and goes in the report's gaps section.
- Four Stage 1 reviewers, all on Opus, fresh contexts (not forks).
- **Nothing is posted to the PR.** Report is delivered here only. AGENTS.md Hard Rule 15
  forbids commenting/committing absent an explicit ask in the current prompt.

---

## Stage 0 — Ground truth (COMPLETE)

### Frame

| | |
|---|---|
| Base (merge-base w/ develop) | `8362b3c` |
| Head | `74e2b82` |
| Diff | 42 files, +2886 / −266, 3842 diff lines / 209 KB, verified untruncated |
| Access | 41/42 files readable at head; `.browserstack.yml` deleted, readable at base |

Cross-checked: `gh pr diff` and local `git diff 8362b3c pr/61` report identical
file/line counts, so the two sources agree independently.

### Acceptance criteria

SFCC-751 supplied verbatim by the user (Atlassian MCP was disconnected this session).
Stored for the briefs; three deliverables (spec / sync workflow / end-to-end validation)
and four AC clauses. **Passed to reviewers verbatim, uncompressed and un-annotated** — my
own scope reading is deliberately withheld so their scope findings stay independent.

### Gate table — the finding that reframes the review

PR #61 touches **zero files under `overrides/`**. Nearly every gate in this repo is scoped
there:

| Gate | Scope | PR files covered | CI result |
|---|---|---|---|
| `npm run lint` | `overrides/**/*.{ts,tsx}` | **0 / 42** | not run in qa.yml |
| `npm run audit:tokens` | `overrides/app/{components,theme/components}/**` | **0 / 42** | not wired to CI; exits 1 at baseline (14 known pre-existing) |
| `npx tsc --noEmit` | tsconfig `include: ['overrides/**/*','vitest.config.ts','vitest.setup.ts']` | **1 / 42** | not run in qa.yml |
| Unit tests (Vitest) | `include: ['overrides/**/*.test.ts(x)']`, `passWithNoTests: true` | **0 / 42** | pass, 1m46s |
| Storybook a11y/interaction | `overrides/**/*.stories.*` | **0 / 42** | pass, 2m57s |
| Playwright E2E (localhost) | — | — | **skipping** |
| Cross-browser E2E (BrowserStack) | — | — | **skipping** |
| Deploy Preview | — | — | pass, 5m2s |
| File Tier & Squad Boundary | — | — | pass |

The two green test jobs fired only because `detect-changes` watches `vitest.config.*` and
`package.json` — both changed. They ran the pre-existing `overrides/` suites, which this PR
does not touch. That is worth exactly one thing: evidence the `vitest.config.ts` edit did
not break collection for the existing suite. It is not evidence about any of the 42 files.

**Net: the automated gates verify approximately one file in forty-two, and the PR that
introduces an E2E pipeline has never executed a single E2E test.**

### Why both E2E jobs skipped (mechanism, not guess)

- `e2e-localhost`: `detect-changes` sets `e2e_scope=homepage` only if *every* e2e-relevant
  changed file sits inside the `e2e_homepage` allow-list. This PR also changes `qa.yml`,
  `.github/workflows/**` and more, so it falls to `e2e_scope=skip`, and the job's `if:`
  excludes `skip`.
- `e2e-browserstack` (qa.yml): gated on `contains(github.base_ref, 'release/')`. This PR
  targets `develop`, so it cannot run.
- Per `qa.yml`'s own header comment and prior project notes, **a skipped required check
  reads as passing** on the merge button.

### Trap audit (all three of the named traps are live here)

1. **Non-zero at healthy baseline** — `audit:tokens` exits 1 on a clean tree (14 documented
   pre-existing violations); `test:max-file-size` exits 1 (actual `main.js` ~352 kB vs
   180 kB budget, `vendor.js` ~2 MB vs 550 kB). Neither is in CI. Reviewers must not read
   these exit codes as PR failures.
2. **Passes having run nothing** — `passWithNoTests: true` (`vitest.config.ts:12`);
   Playwright `--grep` with no match exits 0 "0 passed"; `test:contracts` is a permanent
   `echo && exit 0` stub; skipped CI jobs count as passing.
3. **Stderr noise** — none measured locally this run (no local gates); reviewers are told
   not to treat CI log warnings as findings.

### Rubric

House rules are read at **base `8362b3c`**, not head — this PR edits two of the rule files
it would be judged against (`.claude/rules/frozenFiles.md`, `.claude/rules/testing.md`).
Rule-file changes are reviewed separately, as changes.

Tier map at base: **12 of 42 paths are Tier 1** (`.browserstack.yml`, `vitest.config.ts`,
`package.json`, `CODEOWNERS`, `scripts/hooks/pre-commit`, both edited `.claude/rules/*`,
and all five `.github/workflows/*`). Zero Tier 2. Nine `e2e/**` paths owned by
`@ZimmermannAU/pwa-qa-team` (untiered). 21 with no CODEOWNERS entry.

### Already settled by me (do not re-litigate)

- **`.browserstack.yml` → `browserstack.yml` is handled, not dropped.** At head,
  `frozenFiles.md:114` re-lists the un-dotted path with the rename rationale
  (browserstack-node-sdk requires that exact filename) and `CODEOWNERS:60` routes it to
  tier-1-approvers. My earlier concern is withdrawn. Still open: `protected-file-guard.yml`
  has no `browserstack` entry at base *or* head, so the CI guard stays blind — pre-existing,
  but this PR edits that guard, which is what makes it arguable.

---

## Stage 1 — Fan out (4 reviewers, Opus, parallel, fresh contexts)

Each reviewer receives: the diff, the **verbatim** AC, the gate table above, the trap audit,
the "already settled" list, and the base-commit rubric instruction. Each is **forbidden from
re-running gates** — budget goes entirely to what gates cannot see.

### Constraints imposed on all four (verbatim in every brief)

- Falsify, do not confirm. Attack each claim the PR makes about itself.
- Cite `file:line`. Label every finding **CONFIRMED** (reproduced) or **PLAUSIBLE**
  (reasoned, unproven).
- Severity: **BLOCKER** / **DEFECT** / **NOTE**.
- When a count moves, prove *which items* moved, not how many. Enumerate identity where the
  set is small enough.
- For any check whose pass you rely on, try to make it pass wrongly — inject a decoy that
  should fail and confirm it does. A check never made to fail has not been shown able to fail.
- Any "X exists nowhere" claim must state its search scope **in the same sentence**.
- Separate author-introduced from pre-existing. Pre-existing → NOTE, unless the PR's own
  premise makes it a defect.
- Mandatory closing section **"What I could not verify"** — name what you could not reach
  and why. If you believe the space is covered, show the search. An empty section with no
  reasoning is a failed brief.

### R1 — Correctness & regression (CI control flow)

Does the pipeline do what the AC says? Trace every path through `qa.yml`,
`e2e-browserstack-preview.yml`, `deploy-preview.yml`, `zephyr-results-sync.yml`. Enumerate
every route to a green run that executes zero tests. Specific targets: the
`e2e_scope=homepage` allow-list vs. this PR's own file set; the `--grep` zero-match exit-0
path; `computeBuildName.mjs`'s `unknown-{key}` fallback feeding a build-name lookup that
then finds nothing and exits 0; whether `deploy-preview.yml` firing on every `feature/**`
push contends for a shared MRT target.

### R2 — Conventions, tier & ownership

Rubric = base `8362b3c`. Classify all 42 paths. Adjudicate against AGENTS.md Hard Rules —
**#8** (`vitest.config.ts` is explicitly named never-modify and is modified, +18),
**#7** (`@vitest/coverage-v8` added to devDependencies), **#2/#4** (12 Tier 1 paths).
Check `.docs/temp/SFCC-751-*.md` (+418 lines, author's own AI briefs) are intended as
tracked files. Verify the `.claude/rules/*.md` → `.cursor/rules/*.mdc` mirror is
regenerated, not hand-edited, per `scripts/hooks/pre-commit` §3 and `syncCursorRules.mjs`.

### R3 — Contract fidelity

This PR rewrites its own rubric and moves a Tier 1 file. Diff `.claude/rules/testing.md`
(+163/−20) and `frozenFiles.md` at base vs head and confirm **every delta is deliberate and
describes behaviour that actually exists** — a rules doc asserting a guard that isn't wired
is worse than silence. Same treatment for `browserstack.yml` (46 → 144 lines, not scored as
a rename: what did the rewrite change?), `protected-file-guard.yml`, and the AC's stated
contracts — secret **names**, the Zephyr **EU** endpoint, and the spec **naming convention**.

### R4 — Failure modes & security

Error handling, silent failures, fail-open behaviour, secrets. Targets: every `warn()`-and-
continue path in `zephyrBrowserstackSync.mjs` (359 lines); its documented-unverified
BrowserStack `hierarchy[]` response shape; the `ZEPHYR_API_URL` `/testcases`→`/testexecutions`
suffix rewrite when the URL doesn't match the expected pattern; `e2e-browserstack-preview.yml`
defaulting `relevant=true` when the relevance artifact can't be read (fail-open onto a
paid BrowserStack run); the new `GH_ENV_READ_TOKEN` secret; `.env.sample` changes against the
pre-commit secret guard; and the script's **automatic Jira Bug creation with auto-assignment**
on every failed test — an outward-facing side effect.

---

## Stage 2 — Adjudication (mine alone, not delegated)

- Reviewers agreeing independently → accept.
- Reviewers disagreeing → go to source myself. Do not average, do not defer to the more
  confident. Record what settled it.
- Conclusion broader than its search → downgrade. Expect this to be the most common defect.
- Expect ~⅓ of findings to be confidently wrong. A reviewer refuting its own sub-finding is
  the system working.
- Treat inherited attributions as claims. In particular, several of this PR's own source
  comments narrate prior CodeRabbit rounds and design rationale; a reviewer repeating one is
  quoting the author, not measuring. Verify before promoting to fact.
- Scope in **both** directions — under-delivery and over-delivery — and surface every
  over-delivery for a human ruling rather than accepting or demanding removal.

**Shared premise to attack (the highest-yield move):** everyone in the chain — author,
CodeRabbit's approval, the green check marks — has proceeded as if *this pipeline has been
demonstrated to work*. Nothing in the evidence supports that: zero E2E tests ran on this PR,
the BrowserStack response shape is documented in the script as never exercised against a real
payload, and the build-name and sync paths both degrade silently to no-ops. I will assign one
reviewer to attack that premise directly and will not let convergence on it substitute for
evidence.

**Pre-registered adjudication checkpoints** (things I will verify at source regardless of
what reviewers say, so a miss is visible):
1. Whether the two shipped specs satisfy Deliverable 1 as written, on every axis the AC
   specifies — path, extension, filename convention, Jira tag, Zephyr key, scenario coverage.
2. Whether `SFCC-751_mobile-header-nav-gap.spec.js` is a live unannotated failing assertion
   (`expect(...).toBeGreaterThan(0)` at :42 under a plain `test(` at :26, with a comment
   saying it is expected to fail today) and, if so, what it does to a `release/**` full-suite
   run — where it is in scope for both `e2e-localhost` and `e2e-browserstack`.
3. The Zephyr endpoint region and the `ZEPHYR_API_TOKEN` vs `ZEPHYR_API_KEY` secret name.
4. Deliverable 3 (end-to-end validation) — whether any evidence of it exists anywhere.

---

## Stage 3 — Report (delivered in chat, posted nowhere)

1. **Gate table** — as measured, with coverage-of-diff stated alongside pass/fail, and the
   absent baseline called out explicitly.
2. **Findings**, ranked, BLOCKERs first. Each: `file:line`, one-sentence defect statement,
   a concrete failure scenario (inputs → wrong output), and the fix.
3. **What nobody verified** — union of the four reviewers' gaps minus what I closed, plus
   the forfeited baseline comparison and anything needing a human in a browser or a live
   BrowserStack/Zephyr/Jira account.
4. **My adjudications** — every disagreement and what settled it.

---

## Verification

The loop is self-verifying if these hold; check each before I deliver:

- [ ] Every reviewer returned a non-empty **"What I could not verify"** with reasoning.
- [ ] Every finding carries `file:line` + CONFIRMED/PLAUSIBLE + severity.
- [ ] At least one decoy-injection result is reported for any check we lean on.
- [ ] Every "exists nowhere" claim states its search scope inline.
- [ ] All four pre-registered checkpoints answered at source, independent of reviewer output.
- [ ] The shared premise was attacked by name, with a result — not merely restated.
- [ ] Every disagreement is recorded with what settled it, not averaged away.
- [ ] Nothing was pushed, committed, or posted to the PR.

Re-runnable evidence commands (all read-only, no checkout):
`git show pr/61:<path>` · `git diff 8362b3c pr/61 -- <path>` · `gh pr diff 61` ·
`gh pr checks 61` · `gh pr view 61 --json reviews,comments`
