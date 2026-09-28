# SFCC-89 — closed-loop execution workflow

**Planned 2026-08-26.** Supersedes this file's previous contents (the plan assurance pass, completed
2026-08-25 — its findings are recorded in `sfcc-89-realignment-plan.md`'s five changelogs).

---

## Context

The implementation plan is written, verified, and corrected. What is missing is a way to **execute**
it that does not rest on one agent's discipline holding across 5 commits.

Where we are:

- **The build already exists** — 29 staged files, 3,535 insertions, written 2026-08-24. tsc 0,
  Vitest 354/22, lint at develop's baseline, ACs verified against live SFCC. **Zero commits.**
- **The plan is a re-sequencing plan, not a build plan.** `AGENTS.md`'s copy-first rule requires the
  mechanical TypeScript port to land separately from the functional changes made on top; it got
  bundled (register row D5). With no commits the split is still free. After the first commit lands
  wrong, fixing it means rewriting history on a shared branch.
- **`sfcc-89-realignment-plan.md` is the spec** — 423 lines, 6 steps → 5 commits, per-step gates,
  five changelogs recording 16 verified corrections. **The loop executes it; it does not re-derive it.**
- **Step 0 is done.** Restore point `sfcc-89-wip` @ `3ae8dcd`, byte-exact (tree hash verified three
  times), never pushed. `git checkout sfcc-89-wip -- <path>` restores any single file.

Why a loop rather than just doing it: **Step 1 is a backwards reconstruction across 12 sites where no
gate can detect an omission.** The only mechanical signal is the lint *warning* count sitting at
exactly 15. A single pass that quietly misses three removal sites yields green tsc, green tests, an
unchanged error count, and a wrong commit. Independent verification and scoring is the mitigation.

## The goal, and its five authorities

Build SFCC-89 to spec — not under, not over. "Spec" is five things, and the scorer checks all five:

| # | Authority | Concretely |
|---|---|---|
| 1 | **The ticket** | Six enumerated fields (name, price, description, model copy, style code, ~~breadcrumb~~); "Contentful-sourced content" excluded; the `c_modelFit` dependency |
| 2 | **Figma** | `pdp/product-content` Desktop `40000307:14062` / Mobile `40000343:9727`; measured values only, frames/instances not TEXT nodes, no cross-file comparison |
| 3 | **The docs** | `AGENTS.md` + `.claude/rules/*` — copy-first, minimal changes, tier rules, no new packages |
| 4 | **PR #59, now in develop** | The established precedent and this branch's base: camelCase `ui-kits/`, co-located `<name>.css.ts`, `var(--zimm-*)` in recipes not JSX, registered in `theme/components/index.ts` |
| 5 | **Token / component / CSS / override structure** | `textStyle` for type · `var(--zimm-*)` for colour+spacing · recipe per component · relative imports for already-overridden components · faithful default export on shared bridges |

## Role mapping — with one honest adjustment

**No custom agents exist in this repo or at user level** (`.claude/agents/` is absent in both). All
five roles are greenfield.

| Requested role | Implemented as | Why |
|---|---|---|
| **Orchestrator + scope checker** | **The session (me)** | Only the session can dispatch subagents, hold state across iterations, run gates, and own the commit boundary. Already holds the plan, register and Jira context. |
| **Builder / implementer** | Fresh subagent per commit | Gets the step verbatim + the constraint set. Fresh, not a fork — so it cannot inherit my assumptions about what "done" looks like. |
| **Tester** | Subagent with its own fan-out | Re-runs no gate I already ran; dispatches angle-specific sub-checks and consolidates. Keeps raw output out of my context. |
| **Scorer** | Fresh subagent, independent of builder | Gets diff + gate numbers + tester report + CodeRabbit findings + the 5-authority rubric. Returns PASS or REWORK with cited defects. |
| **Retrospective / meta** | Subagent at each boundary, fed a structured log | **The adjustment:** it cannot "listen while the loop runs" — subagents cannot observe each other's traffic, and only the session sees everything. So it is invoked at each boundary with an iteration log, and its output edits the *next* iteration's briefs. Same effect, one boundary of latency. |

Amendments persist to `$CLAUDE_JOB_DIR/tmp/loop-briefs.md` so improvements accumulate across all 5
commits instead of being re-learned.

## Carry-forwards from COMMIT 1 — assigned by which commit owns the file

Commit-by-path discipline means a fix belongs to the commit that already opens its file.

- **COMMIT 2** (`product-view/index.tsx`): delete the three inert `cloneElement` casts at `:594-596`
  **and** the 7-line comment at `:585-591` that exists only to explain them — proven inert by deletion
  (tsc clean, lint unchanged). Also fix `ProductViewRefScope`'s JSDoc at **`:169-170`** (*"React's own `Ref<T>` type cannot express a `this`-bound callback, so consumers assert against this type at the prop site"*) — the same claim disproved at `product-detail`. It is written as
  guidance, so it propagates.
- **COMMIT 4** (`pages/product-detail/index.tsx`): delete the inert `} as unknown as React.Ref<HTMLDivElement>`
  at `:756`. Verified the only remaining candidate in that file — `:257`/`:648` are SDK-param casts and
  `:281`/`:290`/`:492` are the three error-narrowing casts the developer ruled to leave.
- **COMMIT 4** (G5): read the **acknowledged** list, not just the unacknowledged count. Expect 21.

## Reuse, don't rebuild

Three existing skills cover parts of this. Their call sites differ and matter:

- **`/scope-check`** — a **pre-flight prompt linter**, not a diff auditor. Reads the tier rules and
  predicts what a prompt would touch, returning SAFE/RISKY/BLOCKED and rewriting the prompt when
  needed. Correct call site: orchestrator, **before** dispatching each builder. Caveat: `BLOCKED`
  means "stop and get owner approval" — a deliberate human gate.
- **`/code-quality`** — a **post-hoc convention auditor** that already fans out to 4 parallel agents
  and emits a numeric `🔴 must-fix` count, a ready-made pass signal for the scorer. Two caveats: it
  **defaults its baseline to `main`** (we need `develop` — pin it explicitly), and it audits
  conventions, not behaviour, so the tester still owns the gates.
- **`/code-review`** (CodeRabbit CLI) — **mandated, not optional.** `AGENTS.md`'s Coding Task
  Workflow step 4: *"Before committing a non-trivial code change, run a local CodeRabbit review…
  The CLI is required, not optional."* Verified available: **v0.7.5, authenticated, org
  ZimmermannAU, Pro, seat assigned.** Supports `--agent` (structured findings for agent workflows),
  `--light`, `--base`. This becomes **G7** below.

## The loop, per commit

```
  ORCHESTRATOR  pre-flight: restate the step's deliverables from the plan; confirm
                branch/HEAD/state; /scope-check the builder prompt before dispatch
        │
        ▼
  BUILDER       implement that step only → report changed files + rationale
        │
        ▼
  ORCHESTRATOR  run the deterministic gates myself (G1/G2/G3/G5) → capture real numbers
        │
        ▼
  TESTER        fan out to angle agents → consolidated findings (no gate re-runs)
        │
        ▼
  ORCHESTRATOR  G4 (Storybook) + G7 (CodeRabbit --agent) → structured findings
        │
        ▼
  SCORER        diff + gates + tester + CodeRabbit vs the 5-authority rubric
        │
        ├── REWORK ──► BUILDER (cited defects) ──► gates ──► TESTER ──► SCORER   [max 3]
        │                                                        │
        │                                          3rd REWORK ──► ESCALATE
        ▼
       PASS
        │
        ▼
  ORCHESTRATOR  scope re-check (under- AND over-delivery) → commit → G6 hard stop if due
        │
        ▼
  RETROSPECTIVE structured log → concrete brief edits → applied to the next commit
```

## Agent briefs

**Builder** (fresh, per commit) — gets the step verbatim; the 5-authority constraint set; the gate
numbers it must leave behind; the restore command; an explicit *do-not* list (no commits, no package
installs, no Tier 1 files, no `npm start`, no test-config edits, **never append args to
`npm run lint`**). Returns changed files with a one-line rationale each, plus anything it could not
do and why. **Never commits.**

**Tester** (per iteration) — gets the diff, the step's acceptance criteria, and the gate numbers
already measured. Fans out to four angles: (a) rules/tier compliance, (b) design-token and recipe
fidelity, (c) test/story coverage of this step's own contract, (d) base-parity regression — did
anything the plan did not name change? Returns findings with `file:line`, each CONFIRMED or
PLAUSIBLE, and **a mandatory "what I could not verify" section** — D17 survived eight invocations
because every pass reported only what it had checked.

**Scorer** (fresh, independent) — gets diff, gate numbers, tester report, CodeRabbit findings, the
step's plan text, the rubric. Returns per-axis PASS/REWORK with cited defects. Overall PASS only if
every axis passes **and** every gate number matches the plan exactly. **Must state what it tried to
falsify** — a PASS with no falsification attempt is not a PASS.

**Retrospective** (per boundary) — gets the iteration log: rework rounds, what the scorer caught,
what the tester missed that the scorer found (or vice versa), any gate surprise. Returns concrete
brief edits ("builder brief: add X to the do-not list"), not sentiments.

## The five commits

| | Subject | Steps | G6 |
|---|---|---|---|
| 1 | `refactor(product-view): copy-first TypeScript port of product-view and product-detail` | 1 + 2 (+ `routes.tsx`, `vendor.d.ts`) | **hard stop** |
| 2 | `feat(product-view): add renderHeader slot for caller-supplied header content` | 3 | — |
| 3 | `feat(ui-kits): add PDP static product information atoms and molecules` | 4a–4f | — |
| 4 | `feat(pdp): render static product information on the product detail page` | 5 | **hard stop** |
| 5 | `refactor(pdp): extract the static product header into a testable partial` | 6 | — |

## Gates — orchestrator-run, per commit

All 29 files stay on disk throughout; each commit selects contents **by path**. Timings measured on
this machine.

| | Command | Time | C1 | C2 | C3 | C4 | C5 |
|---|---|---|---|---|---|---|---|
| G1 | `npx tsc --noEmit` | 15s | 0 | 0 | 0 | 0 | 0 |
| G2 | `npx vitest run` | 15s | 354/22 | 354/22 | ≥355/24 | ≥355/24 | ≥355/24 |
| G3 | `npm run lint` | 15s | 17 / **16 warn** | 17/**16** | 17/15 | 17/15 | 17/15 |
| G4 | Storybook interaction + a11y | **8s** (static) | 100/22 | 100/22 | 102/23 | 102/23 | 105/24 |
| G5 | `npm run audit:tokens` | 0.4s | 19→**14** | 14 | 14 | 14 | 14 |
| G7 | `cr review --light --agent --base develop` | ~1-3 min | required | required | required | required | required |
| G6 | Developer, live PDP | — | **stop** | — | — | **stop** | — |

**G3 is load-bearing at COMMIT 1** — the only signal that can catch a missed Step 1 removal.
**Corrected during execution — measured 16 at COMMIT 1, not 15.** Under the constant-tree rule all 29 files are on disk, so `zimmProductStyleCode/index.test.tsx:33`'s `_key` counts at C1–C2; it goes at C3 when 4e deletes that test. Baseline **16 at C1–C2 (ceiling 26), 15 from C3**. Error count is a 17 invariant throughout. What actually matters is **zero `no-unused-vars` in the files the step edits** — the headline total is a proxy.

**Inner loop (~45s, offline, zero repo writes)** — G1 → scoped G2 → G3 → G5. A scoped Vitest run is
**8× faster**: `npx vitest run overrides/app/pages/product-detail` is 1.8s vs 15s. Full G2 before
every commit, always.

**G4 needs neither `http-server` nor `build-storybook`.** The CI recipe uses `npx http-server
storybook-static`, and `http-server` is genuinely absent from `package.json`, `node_modules`, and
global. But `test-storybook`'s default `--url` is already `http://127.0.0.1:6006` — exactly what
`npm run storybook` serves:

```
python3 -m http.server 6007 --directory storybook-static &   # any free port
npx wait-on http://127.0.0.1:6007 --timeout 30000
node_modules/.bin/test-storybook --ci --url http://127.0.0.1:6007
```
**Measured 8.07s / 7.66s, not the ~2 min estimated.** The `storybook dev` recipe previously written
here is the *slow* path and touches a developer-owned process; this one does neither.

**Precondition — this shortcut is CONDITIONAL, not general.** Reusing an existing `storybook-static`
is valid only when the diff touches nothing in a story's import graph:
`grep -rln "<changed-path>" --include="*.stories.tsx" overrides/` must return **nothing**. That held at
COMMIT 1 and holds at COMMIT 2. **It is VOID at COMMIT 3 and COMMIT 5** — both rewrite files inside the
story graph, so `test-storybook` against a stale build would render the *old* components and report a
green count while exercising nothing new. **Rebuild there.**

Nothing written to `storybook-static/`, and incremental rebuilds between iterations instead of a
2-4 min cold build each time. `test-storybook`, `wait-on` and **Playwright's chromium
(`chromium-1223`) are all present** — verified, so no network needed. It is a long-lived background
process the loop must own and reap. Zero-dependency fallback: `python3 -m http.server 6006
--directory storybook-static`.

**G4 is more aggressive than it looks.** `.storybook/preview.tsx` sets `a11y: { test: 'error' }`, so
**all 100 stories are a11y assertions**, not just the 37 carrying a `play`.

**Playwright is out of the loop entirely.** No PDP spec exists — `e2e/tests/` holds one file (two
homepage smoke tests). `ProductPage.js` scaffolding exists unused, there is no `e2e_pdp` allow-list
group, and change-scoping for our diff falls back to the full suite (those same two tests). Writing
one is blocked by a hard human gate: the Gherkin-first workflow requires Lead QA sign-off *before*
any Playwright code. Not a gap this loop can close.

**Two gates the loop is the sole enforcement for.** Neither `tsc --noEmit` nor `audit:tokens` is
wired into any CI workflow — `qa.yml` has no typecheck job. G1 and G5 are not extra diligence; they
are the only place those checks happen before merge.

## Loop hazards — hard-code these as guardrails

Five ways an automated loop silently corrupts its own signal here. All verified in source.

1. **`npm run lint` can be turned into a writer.** `package.json` has
   `"lint:fix": "npm run lint -- --fix"`, and `pwa-kit-dev lint` forwards `--`-args verbatim into a
   shell `execSync`. Plain `npm run lint` is confirmed non-mutating, but **any appended argument**
   changes that. Pin the literal string, no interpolation. `lint:fix` and `pwa-kit-dev format` are
   **forbidden** in the verify phase — auto-formatting would erase the very prettier errors that
   make the 17-error count an invariant.
2. **`vitest.config.ts` sets `passWithNoTests: true`.** A typo'd path filter exits **0** having run
   nothing. **Assert on the reported test count, never the exit code.**
3. **G3 and G5 exit non-zero at a healthy baseline** — lint exits 1 with its 17 pre-existing
   prettier errors, `audit:tokens` exits 1 with its 19. **Diff the counts; ignore the exit code.**
   Two pre-existing `Could not parse CSS stylesheet` stderr lines from `theme/index.test.tsx` are
   noise on a *passing* suite — stderr is not failure.
4. **`PostToolUse` hooks mutate what the builder wrote.** `Write` triggers `prettier --write` on the
   new file; `Edit|Write` triggers `registryUpdate.sh` → `generateRegistry.mjs --file=<path>`, which
   rewrites `.claude/registry/*.md` **on every single edit**. So registry churn appears in
   `git status` continuously, not just at commit time. The scorer must expect and ignore both.
5. **`.claude/hooks/session-reflect.sh` is a `Stop` hook that blocks on a dirty tree.** Verified: it
   returns `{"decision":"block"}` whenever `git status --porcelain` is non-empty, on any branch,
   instructing Claude to write a proposal to `.docs/agents-proposals/` and *"end the session — do
   not start new work."* It has a `stop_hook_active` re-entry guard. Our tree is never clean during
   the loop, so it fires at every turn boundary.

   **This is why the loop is orchestrator-driven and does not use the `ralph-loop` plugin.**
   `ralph-loop` drives iteration via its *own* `Stop` hook returning `decision: block` — two
   blocking Stop hooks racing on one turn with contradictory instructions. Fixing that would mean
   editing `.claude/settings.json`, which is **Tier 1**. Dispatching subagents from within a single
   orchestrator turn per commit sidesteps it entirely: the Stop hook then fires only at commit
   boundaries, where a pause is wanted anyway.

## Decisions settled by the developer, 2026-08-26

1. **All 5 commits pre-authorised** — the loop commits at each boundary, but *only* after the scorer
   returns PASS and the scope re-check clears. The five subjects above are the authorisation of
   record; anything else needs a fresh ask. Note `git add`/`commit`/`push` are not in either
   permissions allowlist, so commits may prompt — the scratch-branch commit did succeed earlier, so
   this is a verify-at-runtime item, not a blocker.
2. **Hard stop at both G6 points** — after COMMIT 1 and COMMIT 4. COMMIT 1's G6 proves the
   TypeScript override renders at all; everything after it assumes that.
3. **3 rework rounds per commit**, then escalate rather than loop again.
4. **Over-delivery is flagged, not auto-reverted** — anything beyond the plan's enumerated
   deliverables is reported with the diff, and the scorer withholds PASS until the developer rules.

## Termination and escalation

The loop stops — not retries — on any of:
- 3 rework rounds on one commit
- A gate number the plan does not predict that the scorer cannot explain
- Any Tier 1 path, `package.json`, or test-config file appearing in a diff
- `/scope-check` returning BLOCKED
- Scope divergence needing a developer ruling
- Either G6 hard stop
- `pre-commit` failing for a reason unrelated to the change (it has four independent `exit 1` paths)

## Verification — how we know the loop itself worked

1. `git diff sfcc-89-wip -- <the 29 paths>` shows **only** the plan's enumerated deltas.
2. Every commit's gate numbers match the table above, recorded per commit.
3. Every scorer PASS cites what it tried to falsify.
4. Every tester "could not verify" section is non-empty or explicitly reasoned empty.
5. `loop-briefs.md` shows at least one concrete brief amendment — a retrospective that changed
   nothing across 5 commits did not observe anything.
6. G7 ran on every commit, per `AGENTS.md`'s requirement, with each finding either fixed or
   explicitly dispositioned.

## What this does not do

- It does not re-plan. The realignment plan is the spec; disagreeing with its **scope** escalates, not
  forks. **Narrow carve-out, added after COMMIT 1:** a role may decline a specific *instruction* when
  following it would make a file's own documentation false, or would reproduce the defect the step
  exists to fix — provided it reports `REFUSED: <instruction> — <why> — <what I did instead>`. This
  happened at COMMIT 1 and the refusal was correct; the scorer independently confirmed it beat the
  instruction. The orchestrator's instruction is not more authoritative than the file's observable state.
- **Scorer input package format is mandatory:** every attribution is marked `MEASURED: <n> (<exact
  command>)` or `CLAIMED: <assertion> (source: builder|tester)`. The scorer may not treat CLAIMED as
  established. A COMMIT 1 error lived entirely inside this artefact.
- It does not push, open a PR, or write the PR body. The breadcrumb note is deferred and there is
  nothing to write it against yet.
- It does not resolve the four open items — `c_modelFit` (owner Dani, two-step), breadcrumb ACs
  (developer), open item (b) (scoped out), (d) SFCC-723, (e) PRC-12.
- It does not add PDP E2E coverage — human-gated, see Gates.
- It does not guarantee nothing is missed. D17 survived eight invocations of a comparable loop.
