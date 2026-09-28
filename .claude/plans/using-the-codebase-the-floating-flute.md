# Arche — AI-Development Foundation Framework

## Context

Every software project today bolts an "AI operating system" onto its stack by hand:
governance rules, memory files, tier-protection, session rituals, CI enforcement,
skills. The `zimmermann-pwa` repo in `/Users/marcel.a.n.navarro/Dev/` is a mature,
production example of exactly this — and its most transferable value turned out to be
**the AI-governance layer, not the Salesforce storefront it governs.** That layer is
re-invented, inconsistently, on every new engagement.

**Arche** generalizes that layer into a reusable foundation. The analogy is `ng new`:
just as angular-cli scaffolds an Angular boilerplate you then build a backend and
features on top of, `arche init` scaffolds an **AI-development foundation** — governance,
memory, enforcement, human-in-the-lead skills — and the project's actual tech stack is
then layered on top via swappable **stack packs**.

**Outcome:** a Node/TypeScript CLI (`arche` / `npx create-arche`) that lays a consistent,
opinionated-but-configurable AI-OS into any new or existing repo, decoupled from tech
stack (via packs) and from surrounding tooling (via VCS/PM/wiki provider adapters). Built
as a personal tool now, architected to become an internal Accenture Song accelerator later.

This plan is the initial architecture + full v1 roadmap. On approval, we build the **first
executable milestone** (Phases 0–3: a working `create-arche` that scaffolds the governance
layer and dogfoods on Arche's own repo). Phases 4–10 are the documented roadmap that
completes v1 (including the full Shared Brain and the PM/wiki spine).

### Confirmed decisions (settled — do not revisit)
- **Delivery:** Node/TypeScript CLI scaffolder (`arche init`, `npx create-arche`). Skills/hooks/agents are written as `.claude/` files *into the target repo*, not installed as a separate Claude Code plugin.
- **Targets:** greenfield-first, plus a non-destructive brownfield "layer onto existing repo" mode.
- **Stack content:** a stack-packs/adapters ecosystem. Core = generic engine + config schema; stack specifics live in packs. **First pack = generic TypeScript/Node** (`pack-node`), which also dogfoods Arche on itself.
- **Surrounding tooling:** fully pluggable from day one — VCS (GitHub/GitLab), PM (Jira/Linear), wiki (Confluence/Notion) behind provider interfaces. **First provider = GitHub;** others validate the seam later.
- **Opinionation:** opinionated defaults (GitFlow-ish branches, Conventional Commits, Tier 1/2/3 model, human-in-the-lead workflow), all overridable via config.
- **Shared Brain:** built fully in v1 (pgvector RAG + ingestion + MCP + `/knowledge`), sequenced late because it needs infra + the wiki provider.
- **Audience:** personal now → Song accelerator later.

---

## Architecture

### Monorepo layout (pnpm workspaces + Turborepo + tsup + changesets + Vitest)

Independent semver per pack/adapter (via changesets) is load-bearing for the update story.
Arche's own repo is itself Arche-governed (dogfooding).

```
arche/                                  # Arche-governed (AGENTS.md, .claude/, .docs/, arche.config.ts)
├── packages/
│   ├── schema/          @arche/schema          # Zod config schema + types + defineConfig()
│   ├── core/            @arche/core            # engine: resolve→compose→render→plan→apply
│   ├── cli/             @arche/cli             # `arche` binary (init/plan/apply/doctor/migrate/sync)
│   ├── create-arche/    create-arche           # thin npm-init shim → @arche/cli init
│   ├── provider-sdk/    @arche/provider-sdk    # VCS/PM/Wiki capability interfaces + registry
│   ├── pack-sdk/        @arche/pack-sdk        # StackPack contract + section-owned rule-fragment merge
│   ├── templates-base/  @arche/templates-base  # tech-agnostic .claude/ .docs/ AGENTS.md content (Eta)
│   ├── brain/           @arche/brain           # Shared Brain deployable (Phase 8)
│   └── test-kit/        @arche/test-kit        # golden-file + sandbox-repo e2e harness
├── providers/  vcs-github, vcs-gitlab, pm-jira, pm-linear, wiki-confluence, wiki-notion
├── packs/      pack-node (first), pack-next, pack-python, pack-sfcc (fidelity oracle)
└── e2e/        sandbox target repos + golden snapshots
```

**Dependency inversion (the key rule):** `@arche/core` imports *only* the three
interface packages (`schema`, `provider-sdk`, `pack-sdk`) — never a concrete pack or
provider. `@arche/cli` owns discovery/registration and injects concrete packs+providers
into core at runtime. This is what makes "pluggable from day one" real without coupling
the engine to any stack or forge.

### The engine: a five-stage pure pipeline (`@arche/core`)

Each stage is a pure function returning data, so the whole thing is golden-file testable
and `--dry-run`-able. Critical file: `packages/core/src/pipeline.ts`.

```ts
resolve(config, env): ResolvedConfig            // merge defaults, load selected packs/providers
compose(resolved): TemplateGraph                // gather + merge rule fragments, skills, workflows
render(graph, ctx): VirtualFile[]               // Eta → strings; nothing touches disk yet
plan(files, target): ChangePlan                 // 3-way diff vs disk + arche.lock.json
apply(plan, providers): ApplyResult             // write files AND call provider APIs
```

`VirtualFile` carries provenance + merge policy — this is what makes brownfield safe:

```ts
interface VirtualFile {
  path: string
  contents: string
  owner: 'arche' | `pack:${string}` | `provider:${string}` | 'user'
  merge: 'replace' | 'create-if-absent' | 'managed-region' | 'three-way' | 'append-once'
  region?: { begin: string; end: string }   // e.g. "# >>> arche:managed" / "# <<< arche:managed"
  hashOfLastGenerated?: string               // from lockfile, drives 3-way merge
}
```

**Template content = real `.eta` files** inside each pack/template package, declared by a
typed `manifest.ts` (not JSON-embedded strings, not a codegen DSL) — because governance
content is prose reviewed in PRs and dogfooded on Arche itself, so it must diff as files.
Eta gives conditionals + partials + a typed `RenderContext`.

### Config schema (`arche.config.ts` + `arche.lock.json`)

Authored in TS via `defineConfig()` + `satisfies ArcheConfig` (autocomplete, inline
comments, narrow types), validated by Zod at load (`@arche/schema`, loaded with
`jiti`/`bundle-require` — no build step). `apply` freezes the fully-resolved result into
`arche.lock.json`, the machine source of truth for idempotency + migration. Captures:
`project`, `stackPack`, `providers.{vcs,pm,wiki}` (each may be `{id:'none'}`),
`branchModel`, `commits`, `tiers` (three-tier model with owners/paths/squads),
`requirementSpine` (requirement-ID + story-key patterns + E2E naming), and `primitives`
(every extension as an explicit on/off — all-on = full v1). Critical file:
`packages/schema/src/config.ts`.

### Provider abstraction (`@arche/provider-sdk`) — capability-based

Core asks a provider "can you do X?" and either calls it or degrades to emitted manual
steps. This lets Arche ship *all* interfaces in Phase 2 with only GitHub *implemented*.
Two distinct action kinds, mirroring the reference repo's hardest-won lesson:

```ts
interface VcsProvider extends ProviderMeta {
  // FILE artifacts (returned as VirtualFile[], written by core):
  emitCodeowners(tiers): VirtualFile         // GitHub CODEOWNERS / GitLab CODEOWNERS
  emitCiWorkflows(plan): VirtualFile[]        // .github/workflows/*  |  .gitlab-ci.yml
  // SERVER-SIDE actions (the REAL gate) — may throw NotAuthenticated → core prints manual steps:
  ensureBranchProtection(rules): Promise<ActionResult>
  ensureTeam?(slug, members?): Promise<ActionResult>
  ensureLabels(labels): Promise<ActionResult>
}
interface PmProvider  { parseStoryKey; linkCommitConvention; fetchStory? }
interface WikiProvider{ requirementSource; fetchRequirements? }   // feeds Shared Brain
```

**Provider owns the envelope, pack owns the content.** GitHub adapter emits the Actions
YAML *shell*; the pack's `ciPartials` supply *which* glob groups / gate names go inside —
so a pack's "change-scoped test selection" is identical in intent across forges.

### Stack-pack contract (`@arche/pack-sdk`)

The only place tech-specific knowledge lives:

```ts
interface StackPack {
  id: string
  detect(repo): Promise<number>                 // 0..1 confidence for brownfield auto-select
  ruleFragments: RuleFragment[]                  // section-scoped, merged INTO core rule docs
  files: TemplateEntry[]                         // pack-owned standalone files (skills, ci partials)
  scaffolds: Record<string, ScaffoldDef>         // component/page/test — powers new-* skills
  toolConfig: { lint?; test?; format? }          // VirtualFile[] configs to write
  registryScanners: RegistryScanner[]            // populate .claude/registry/*.md
  ciPartials?: Record<string, TemplateEntry>
}
```

**Rules compose by section ownership, not file ownership.** Core defines a rule-doc
skeleton with named, ordered sections (`## Testing`, `## Conventions`…); each
`RuleFragment` targets `{doc, section, order}` and renders under a stable anchor with a
`<!-- arche:fragment pack:node testing -->` provenance marker (re-mergeable on update).
Base tech-agnostic content (session-start ritual, tier prose, memory templates, Hard
Rules skeleton) lives in `@arche/templates-base`, always composed first; packs layer on.
Swapping packs changes conventions/scaffolds/CI but leaves the governance spine byte-identical.

---

## Primitives being generalized (mined from `zimmermann-pwa`)

The reference repo is the fidelity oracle for every primitive. Port/generalize from:

**Core (Phase 0–3):**
- Three-layer governance: `AGENTS.md` (policy) + `.claude/rules/*` (conventions + tiers) + `.docs/` (requirements); `CLAUDE.md` = one-line `@AGENTS.md` stub. → `templates-base`.
- Living memory: `.docs/memory/{projectState,sprintScope,feedback,references}.md` + gitignored `.claude/session-notes.md`, consumed by the `session-start` 5-step ritual whose update rules live in the skill. Source: `zimmermann-pwa/.claude/skills/session-start/SKILL.md`.
- Tier model + two-layer enforcement: advisory Claude-side (`.claude/settings.json` PreToolUse branch-guard blocks edits on protected branches + non-blocking tier warnings) + authoritative server-side (CODEOWNERS + branch protection). Sources: `zimmermann-pwa/.claude/settings.json`, `zimmermann-pwa/CODEOWNERS`, `.github/workflows/protected-file-guard.yml`.
- Human-in-the-lead skills: `session-start`, `feature-spec`, `scope-check`, `audit-tier`, `code-quality`, `project-init`, `onboarding`, `pr-checklist` (clarify-one-question-at-a-time → optional parallel research → produce artifact → stop at explicit human checkpoint).

**Extensions (Phase 4–8, all in v1):**
- CI/CD templates: `protected-file-guard`, change-scoped test selection (`tj-actions/changed-files` glob groups + `since_last_remote_commit` per-push diff), gate-aggregator jobs, upstream-baseline watcher, idempotent "one labeled issue, auto-close when clean" scheduled agents. Sources: `zimmermann-pwa/.github/workflows/{qa,protected-file-guard,upstream-release-watch,weekly-agents}.yml`.
- Git hooks + static analysis: conventional-commit `commit-msg`, `.env` secret guard, derived-file/synced-from guard; `semgrep.yml` (credential-logging/XSS), ast-grep a11y rules, `coderabbit.yaml` **including the Claude-Code-provenance heightened-scrutiny rule**. Sources: `zimmermann-pwa/scripts/hooks/*`, `semgrep.yml`, `.coderabbit/`, `coderabbit.yaml`.
- Multi-AI propagation + registry: one rule source → Cursor/Copilot with `synced-from` headers + CI drift check; agent-readable codebase registry. Sources: `zimmermann-pwa/scripts/{syncCursorRules,generateRegistry}.mjs`.
- PM/wiki spine: requirement-ID ↔ story-key ↔ branch ↔ commit ↔ PR ↔ E2E linkage baked into skills + commit trailers (the `SFCC-NNN` + `REG-/PRC-/CFD-` namespace pattern).
- Shared Brain (full): pgvector/Postgres + Confluence-only ingestion + Express RAG API + MCP `query_knowledge` tool + `/knowledge` skill + conflict-flagging. Full spec: `zimmermann-pwa/.docs/planning/sharedAiBrainBrief.md`. → generalized into `@arche/brain` (wiki provider abstracts Confluence).

---

## Build sequence

### ▶ First executable milestone (build on approval)

**Phase 0 — Engine skeleton & schema.** `@arche/schema` (Zod + `defineConfig`) and
`@arche/core` pipeline with `VirtualFile`/`ChangePlan`/lockfile model, 3-way merge, Eta
rendering. Tested against a fixture pack. *Proves the idempotent write/merge engine in isolation.*

**Phase 1 — Base governance + filesystem-only CLI.** `@arche/templates-base` (AGENTS.md
skeleton, CLAUDE.md stub, `.claude/rules/*` skeleton, memory files, the 8 human-in-lead
skills) + `arche init/plan/apply` writing files only. *`npx create-arche` already lays the
full three-layer governance + living memory + skills into any repo — ~70% of the reference
value with zero provider integration.*

**Phase 2 — Provider SDK + GitHub + client-side tier hooks.** `@arche/provider-sdk`, all
three interfaces; `@arche/provider-github` (CODEOWNERS + branch-protection API + labels +
workflow envelope); `.claude/settings.json` PreToolUse branch-guard + non-blocking tier
warnings. **Encodes the CODEOWNERS-is-the-real-gate lesson:** `arche apply` emits the CI
guard *and* calls `ensureBranchProtection`/`ensureTeam`; `arche doctor` verifies the
server-side gate actually exists and fails loudly if only the CI file is present.

**Phase 3 — `pack-node` + CI extensions → working `create-arche` + dogfood.** Generic
TS/Node pack (rules, scaffolds, change-scoped test partial, registry scanners) + CI
primitives. Regenerate Arche's own governance files via `arche apply` and diff against the
hand-written originals (mini fidelity test). **Ship `create-arche`.**

### Roadmap (completes v1)

- **Phase 4 — Git hooks + static analysis.** commit-msg, secret guard, derived-file guard; semgrep + ast-grep + coderabbit incl. Claude-provenance rule. Provider-neutral, low risk.
- **Phase 5 — Multi-AI propagation + registry.** Rule source → Cursor/Copilot with `synced-from` headers; `arche sync` generator + CI drift check; registry scanners wired to `sync` + PostToolUse hook.
- **Phase 6 — PM/wiki spine.** `provider-jira` + `provider-confluence`; requirement-ID/story-key linkage baked into `feature-spec`/`qa-generate`/`pr-checklist` skills + commit trailers.
- **Phase 7 — Second provider set.** `provider-gitlab` + `provider-linear`. Success criterion: swapping `vcs: github → gitlab` in config regenerates equivalent artifacts with **zero pack changes** — the honest test of pluggability.
- **Phase 8 — Shared Brain (full v1).** `@arche/brain`: pgvector schema + ingestion (via wiki provider) + Express RAG API + MCP `query_knowledge` + `/knowledge` skill + conflict-flagging. Opt-in via `primitives.sharedBrain.enabled`; sequenced last because it needs Postgres + embeddings + the wiki provider.
- **Phase 9 — SFCC fidelity oracle.** Port Zimmermann into `pack-sfcc`, run `arche init --brownfield` against `zimmermann-pwa`, diff generated output vs. known-good. Proves generalization is lossless; fold gaps back into `templates-base`/`pack-sdk`.
- **Phase 10 — Migration & accelerator hardening.** `arche migrate` codemods, changesets discipline, `arche doctor` expansion, docs, Song-accelerator packaging (private registry, presets).

---

## Init flow (`arche init`)

`create-arche` is a ~15-line shim → `@arche/cli init`. CLI surface: `init` (interactive),
`plan` (dry-run ChangePlan), `apply` (idempotent reconcile), `doctor` (verify server-side
gates exist), `migrate` (versioned codemods), `sync` (regenerate derived artifacts + drift check).

- **Greenfield** (empty dir / only `.git`): full scaffold, Arche owns the tree.
- **Brownfield** (source detected): non-destructive — every write is `create-if-absent` /
  `managed-region` / `three-way`, never clobbers; runs pack `detect()` to pre-select the
  stack; appends `@AGENTS.md` include to an existing `CLAUDE.md` rather than overwriting.
- **Prompts** (`@clack/prompts`, one at a time): mode+stack → VCS org/repo (auto-filled from
  `git remote`/`gh auth status`) → PM+wiki (each offers `none`) → branch model → tier seeding
  (brownfield can derive from existing CODEOWNERS) → primitives (default all-on) → review plan → apply.
- **Provider auth (never runs OAuth):** resolution order = working provider CLI (`gh`/`glab`) →
  env vars → **neither present → degrade, don't block**: emit all files + an `arche-postinit.md`
  checklist of exact `gh api`/settings commands a human must run. Mirrors the reference lesson —
  the CI file is offline-emittable; the real gate needs credentials, so make the gap explicit.
- **Idempotency:** `apply` = 3-way diff between rendered files / disk / lockfile hashes →
  `unchanged`/`create`/`update-managed-region`/`conflict` (user-edited Arche region surfaced,
  never overwritten). Safe to re-run; `plan` = `--dry-run`.

---

## Key risks & how they're handled

- **Pluggable-from-day-one vs. shipping fast:** capability model — ship all interfaces in Phase 2, implement only GitHub; `none`/under-capable providers degrade to emitted manual steps. GitLab/Linear in Phase 7 *validate* the seam rather than *define* it (scheduled before the PM/wiki spine so the abstraction is stress-tested early).
- **Update/migration after a project scaffolds:** lockfile + managed-regions + versioned codemods (`arche migrate`). Three-way merge surfaces user edits inside Arche-owned regions as conflicts, never silent loss. More machinery than a one-shot scaffolder, but a governance layer that can't evolve is dead on arrival for a long engagement.
- **Server-side enforcement is load-bearing, carry it over fully:** the tier model always produces *both* the advisory CI guard *and* the authoritative provider calls; `arche doctor` answers "is the real gate on?"; emitted `AGENTS.md` carries the "Claude's confirmation is a workflow safeguard, not the security boundary" framing so downstream teams inherit the mental model. Client-side hooks stay explicitly non-blocking (`exit 0`).
- **Dogfooding:** Arche's monorepo is scaffolded and governed by Arche from Phase 3 — the fastest way to find ergonomics failures.

---

## Critical files to create first (define every downstream contract)

- `packages/schema/src/config.ts` — `ArcheConfig` Zod schema + `defineConfig`; every package types against it.
- `packages/core/src/pipeline.ts` — `resolve→compose→render→plan→apply` + `VirtualFile`/`ChangePlan`/lockfile + 3-way merge (idempotency + brownfield safety).
- `packages/provider-sdk/src/index.ts` — `VcsProvider`/`PmProvider`/`WikiProvider` capability interfaces (the pluggability seam + CODEOWNERS-is-the-gate split).
- `packages/pack-sdk/src/index.ts` — `StackPack` contract + section-owned `RuleFragment` merge.
- `packages/cli/src/commands/init.ts` — greenfield/brownfield detection, prompt flow, auth degradation, wiring packs/providers into core.

**Reference oracle (port from, don't invent):** `zimmermann-pwa/AGENTS.md`,
`.claude/settings.json`, `.claude/skills/session-start/SKILL.md`,
`.github/workflows/protected-file-guard.yml`, `scripts/syncCursorRules.mjs`,
`.docs/planning/sharedAiBrainBrief.md`.

---

## Verification

- **Per-package unit (Vitest):** schema validation (valid/invalid configs), each pipeline stage as a pure function, section-merge determinism (same fragments → identical output), provider capability degradation (no auth → manual-steps file, not a throw).
- **Golden-file snapshots (`@arche/test-kit`):** render `VirtualFile[]` for representative configs; snapshot the full tree. Catches unintended template drift on every change.
- **Sandbox-repo e2e:** run `arche init` into a temp greenfield dir and a temp brownfield dir (a fixture repo with pre-existing `CLAUDE.md`/`CODEOWNERS`); assert files land, brownfield merges non-destructively, and a second `arche apply` is a no-op (idempotency).
- **Milestone acceptance (Phase 3):** `npx create-arche` in an empty dir produces a repo that passes its own `session-start` ritual and `arche doctor`; `arche apply` re-run against Arche's own repo reproduces the hand-written governance files (diff = empty). `pack-node` scaffolds a component + test that typecheck.
- **Server-side gate check:** with a `GITHUB_TOKEN`, `arche apply` on a scratch GitHub repo actually sets branch protection + CODEOWNERS; `arche doctor` reports the gate present; removing protection makes `doctor` fail loudly.
- **Phase 8 Shared Brain:** the acceptance checklist from `sharedAiBrainBrief.md` §15 (ingestion writes chunks, conflict detection flags a known conflict, RAG `/query` returns relevant chunks, MCP `/knowledge` retrieval works end-to-end), generalized to run against the configured wiki provider.
- **Phase 9 fidelity:** `arche init --brownfield` against `zimmermann-pwa` diffed vs. the known-good hand-built layer — gaps are bugs in the generalization.
