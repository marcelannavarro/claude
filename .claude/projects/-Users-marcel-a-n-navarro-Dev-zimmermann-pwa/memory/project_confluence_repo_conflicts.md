---
name: confluence-repo-conflicts
description: "Known conflicts and staleness between Confluence SFCC docs and the repo's AGENTS.md/.claude/rules, found during a 2026-07-15 Confluence deep-read"
metadata: 
  node_type: memory
  type: project
  originSessionId: ef996bfd-f69c-4409-8ab6-757ed14dd8b6
  modified: 2026-09-23T23:10:16.954Z
---

Confluence's "Development Standards" (261750785) and "Component Override Strategy" (261881857) — see [[reference-confluence-sfcc-space]] — contradict current repo rules in two places:

1. **Icons.** Confluence says import from `@salesforce/retail-react-app/app/components/icons` directly; AGENTS.md says the opposite — always use `overrides/app/components/icons` as the single source of truth. Treat AGENTS.md as current; Confluence looks like the pre-override-pattern draft.
2. **New component location.** Confluence says brand-new components go under `overrides/app/components/custom/<name>/`; the repo's actual convention (`.claude/rules/conventions.md`, `/new-component` skill, onboarding guide's worked example) puts them directly under `overrides/app/components/<name>/` with no `custom/` layer.

Confluence's "Technical Environment Setup" (304906242) still describes a flat `cp .env.sample .env` setup with no mention of the tiered `.env.shared`/`.env.<tier>` system or `scripts/switchEnv.mjs` — almost certainly stale, since `feature/env-switching` (the branch that built that tooling) was still active as of 2026-07-15.

**Why:** these were surfaced by a deep Confluence read done for onboarding/setup purposes; Confluence is meant to mirror the repo but isn't being kept in sync as the repo evolves.
**How to apply:** when Confluence and the repo disagree, trust the repo (AGENTS.md/.claude/rules) as source of truth for code conventions, but flag the Confluence page as needing an update per AGENTS.md's doc-integrity rule rather than silently ignoring the mismatch — especially once `feature/env-switching` merges, since 304906242 will then be actively wrong for new hires.

4. **Stage vs. UAT tier order (found 2026-08-04, opposite direction — repo is stale here, not Confluence).** [.docs/architecture.md](../../.docs/architecture.md) §Environments lists the six-tier order as Local → Dev → SIT → **UAT → Stage** → Prod. Confluence's [Environment Topology & Promotion Path](https://zimmermannworkboard.atlassian.net/wiki/spaces/SFCC/pages/304840708) (the page with the actual gating logic — entry criteria, GitHub Environment secret scope, branch→tier matrix) explicitly orders it Local → Dev → SIT (parallel) → **Stage → UAT** → Prod, with Stage as the convergence point (needs Digital SIT Gate green + NewStore OMS SIT sign-off) and UAT strictly after Stage (business sign-off only). [.docs/memory/projectState.md](../../.docs/memory/projectState.md)'s 2026-07-16 entry claims "Stage/UAT promotion order reconciled across docs," but architecture.md itself still shows the old (wrong) order — the reconciliation evidently didn't touch that file, or regressed. Treat Confluence's Stage-before-UAT order as correct until architecture.md is fixed; flag to the user/Integration lead per doc-integrity rather than silently picking one.

5. **SEO requirement (DMU-0xx) numbering drift, found 2026-09-24 while sizing SFCC-724.** [.docs/prd/dataMigrationSeo.md](../../.docs/prd/dataMigrationSeo.md) (last updated 2026-06-11) numbers its SEO section DMU-021–DMU-042 with no gaps. The live Confluence page *"04.1.19 Data Migration / SEO / Analytics Requirements - Mapping"* (478248974, version 9) is off by one from DMU-022 onward — its table jumps straight from DMU-020 to DMU-022 with no DMU-021 row at all — so local DMU-022 (filtered/faceted PLP canonicalises to base) = Confluence DMU-023; local DMU-035 (CMS-editable PLP SEO field) = Confluence DMU-036; and so on down the list. **The real Jira tickets (SFCC-562, SFCC-563, SFCC-724) carry Confluence's numbers as literal labels** (`DMU-023`, `DMU-022`), not the local PRD's — so for anything anchored to an actual ticket, Confluence's number is the operative one, even though the local PRD file otherwise reads as the more carefully curated document (clean sequential open-items list, explicit "Resolved since previous version" section).
**Why:** surfaced while confirming what SFCC-724's `DMU-023` label actually refers to — using the local PRD's numbering alone would have pointed at the PDP-hreflang requirement instead of the PLP-canonical one.
**How to apply:** when citing a DMU number against a real Jira ticket/label, trust Confluence's number. Flag the drift per AGENTS.md's doc-integrity rule rather than silently reconciling either doc — unresolved as of this writing, Marcel hasn't said which source to correct. Related: [[project-story-point-calibration]].
