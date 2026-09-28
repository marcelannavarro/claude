# zimmerMANN-skills — build plan

## Context

Marcel is FED Lead on the Zimmermann PWA Kit. Across 399 sessions the same work has been
re-typed by hand ~99 times — the "execute an in-depth analysis across the codebase, confluence,
and JIRA" formula — with the depth wording drifting each time ("in-depth", "in-depth full-on
exhaustive", "in-depth, verbose, and authoritative"). That drift is the inconsistency risk: the
same question asked twice gets researched to two different standards.

The repo already has 14 skills, but they were authored by TimLavelle and Hardi (zero commits
from Marcel) and encode *the codebase's* needs — scaffolding, onboarding, changelogs. Nine of
them have never been invoked once, because they describe IC and setup work, not lead work. The
gap is a **personal layer**: how Marcel works, not how the project works.

Outcome: eight `zimmerMANN*` skills that wrap Marcel's real workflow, **call** the repo's
existing skills rather than duplicate them, and never modify the repo's Claude Code config.

---

## Architecture

### Locations

| What | Source of truth | Discovery |
|---|---|---|
| Skills | `~/Dev/zimmerMANN-skills/skills/<name>/SKILL.md` | symlink each into `~/.claude/skills/<name>` |
| Agents | `~/Dev/zimmerMANN-skills/agents/<name>.md` | symlink each into `~/.claude/agents/<name>.md` |
| Run state | `~/Dev/zimmerMANN-skills/.runs/<TICKET>/` | not symlinked; read by skills directly |

Symlinks because a bare folder in `~/Dev` is not on Claude Code's skill search path. Source
stays in `~/Dev` so it is git-able and yours; the symlink makes it invocable from any project.

### Hard constraints (confirmed)

- **Never write** to `zimmermann-pwa/.claude/**`, `AGENTS.md`, `CLAUDE.md`, `CODEOWNERS`,
  `.docs/memory/**`, `.docs/prd/**` — all Tier 1 Governance (`frozenFiles.md:128-138`).
- Feature code, commits and PRs **are** in scope. Config is not.
- Human-in-the-lead: every skill is invoked manually. No hooks, no triggers, no auto-fire.
- **Stop before push.** PostBuild commits freely, then presents diff + audit + PR body and waits.

---

## The shared loop

Five roles, defined once as agent files and reused by every skill that runs a loop. Each skill
supplies its own goal statement and pass criteria; the roles stay constant.

| Role | Agent file | Model / effort | Job |
|---|---|---|---|
| Orchestrator | `zm-orchestrator.md` | inherit | Owns the loop; doubles as scope checker — delivers to spec, neither under nor over |
| Implementer | `zm-implementer.md` | sonnet, high | Executes the plan step |
| Tester | `zm-tester.md` | sonnet, high | Fans out subagents across angles; returns findings, never fixes |
| Scorer | `zm-scorer.md` | sonnet, high | Scores code + output + tester findings; PASS, or return to Implementer |
| Tracker | `zm-tracker.md` | sonnet, high | Watches the loop, writes improvements to `.runs/<TICKET>/loop-log.md` while it runs |

Model and effort are pinned in **agent** frontmatter — they are not skill-level controls. The
Opus-5-for-PreBuild split is achieved by PreBuild's own planner agent, not by the loop roles.

Loop exit: Scorer returns PASS, **or** three failed rounds → stop and surface to Marcel. An
unbounded loop is the main failure mode; the round cap is the guard.

---

## Build order

One skill at a time, each usable standalone. Wiring is a final pass once all eight exist.

1. **zimmerMANNPreBuild** — the gate and planner (Opus 5, max effort)
2. **zimmerMANNBuild** — the executor
3. **zimmerMANNPostBuild** — own senior dev; audits, commits, stops before push
4. **zimmerMANNReview** — others' PRs; gather → audit → verdict → inline comments; loops to approval
5. **zimmerMANNDevOps** — deploys, release cuts, tagging
6. **zimmerMANNSprinter** — planning, standups, refinement, retros
7. **zimmerMANNDevImprover** — post-build learning → tunes 1–3
8. **zimmerMANNRevImprover** — post-review learning → tunes 4
9. **Wiring pass** — handoff contracts, run-state schema, end-to-end dry run

---

## Skill 1 — zimmerMANNPreBuild (this session's deliverable)

**Files:** `~/Dev/zimmerMANN-skills/skills/zimmerMANNPreBuild/SKILL.md` + the five agent files.

**Input:** a Jira key (`$ARGUMENTS`), or asks for one.

**Phase 1 — gather, in parallel.** Five source checks, each ending in a findings block:

| Source | Checks | Tool |
|---|---|---|
| Jira | story, requirements, ACs, linked design, attachments, linked work items, comments | `mcp__mcp-atlassian__jira_get_issue` |
| Confluence | TSDs and related docs | `confluence_search`, `confluence_get_page` |
| Handbook | `~/Dev/fed-handbook.md` — the build approach | Read |
| Codebase | branch state, tier of every likely-touched file, blast radius | `git`, `/audit-tier` |
| Figma | variants, states, tokenisation, viewports | Figma MCP; **ask Marcel for node links if the file URLs aren't enough** |

**Phase 2 — reuse, don't reimplement.** Call in order:
`/session-start` → `/feature-spec` → `/scope-check` on the resulting prompt.
`/audit-tier` per file when scope-check flags one.

**Phase 3 — flag.** Every gap, misalignment or ambiguity, per source, with severity. This is the
gate: BLOCKED items stop the handoff.

**Phase 4 — plan.** Writes `.runs/<TICKET>/plan.md`: goal statement, commit or branch breakdown,
per-step pass criteria, and the loop configuration Build will run.

**Depth is a parameter, not an adverb** — `quick` / `standard` / `exhaustive`, defaulting to
standard. This is the fix for the drift in the 99 hand-typed prompts.

---

## Findings that shape the skills

Discovered during exploration; each changes how a skill must behave.

- **`code-quality` diffs against `main`; `pr-checklist` diffs against `develop`.** Different file
  sets on a feature branch. Always pass an explicit scope.
- **`pr-checklist` already calls `code-quality`.** Calling both doubles the audit.
- **No existing skill emits machine-readable output.** All prose. Any branching on a result
  (e.g. "did scope-check say BLOCKED?") needs our own wrapper to re-specify the output format.
- **`PreToolUse` blocks all Write/Edit on `develop`/`main`.** PreBuild must confirm a feature
  branch exists before Build can do anything.
- **`PostToolUse` regenerates `.claude/registry/*.md`** on every edit under `overrides/app/`.
  Unavoidable and expected — not our write, but it will show in `git status`.
- **The `Stop` hook is broken** — `session-reflect.sh:24` has a shell-quoting bug that makes its
  `jq` program fail to compile; `settings.json`'s `|| true` hides it. Zero artifacts in 7 weeks.
  No design impact. **Raise with Tim rather than fix — `.claude/` is off-limits.**
- **atoms/molecules/organisms is undocumented** — implied only by folder placement and a JSDoc
  first word. Two rules a skill could mechanically enforce: JSDoc opens `Atom —`/`Molecule —`/
  `Organism —` matching the parent folder, and an atom imports nothing from `../molecules/`.
- **`.docs/architecture.md:130` is stale** — prescribes `components/custom/`, which has never
  existed. The real home for custom components is `ui-kits/{atoms,molecules,organisms}/`.
- **`squadA.md` and `squadB.md` disagree** on who owns PDP/PLP. Both are drafts. Never infer
  squad ownership programmatically — read `CODEOWNERS`.
- **`recipeGuards.test.ts` is the only hard styling gate** (fails `npm run test`).
  `audit:tokens` is advisory and not in CI.

---

## Verification

Skill 1 is done when, run against a real Jira key on a feature branch:

1. `/zimmerMANNPreBuild SFCC-NNN` is discoverable and invokes without error.
2. All five sources are queried and each produces a findings block.
3. `/session-start`, `/feature-spec` and `/scope-check` are actually called — confirm in the
   transcript, not by assertion.
4. A missing AC or an absent Figma variant is **flagged**, not silently defaulted.
5. `.runs/<TICKET>/plan.md` exists, names files with tiers, and carries per-step pass criteria.
6. Nothing under `zimmermann-pwa/.claude/` is modified — `git status` proves it.
7. Re-running with `depth: quick` vs `exhaustive` produces visibly different research effort.

---

## Open items

- Trello is named for Sprinter but there is no Trello MCP connector in this session.
- The Improver skills rewrite skills 1–4. Proposed guardrail: they write a diff proposal to
  `.runs/`, and Marcel applies it — never a silent self-edit.
