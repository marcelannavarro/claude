---
name: project-coverage-threshold
description: Unit test coverage % — PWA frontend has none (risk-based); the 90% figure belongs to the separate SFCC backend cartridge repo
metadata: 
  node_type: memory
  type: project
  originSessionId: 1a29d7ed-8895-4e1e-a6f0-a9939a4a7f2d
  modified: 2026-08-31T00:00:00.000Z
---

**There is no unit-test coverage percentage for the PWA frontend repo (this repo).** Testing is deliberately risk-based, not percentage-based. Re-verified 2026-08-06 by an exhaustive triangulated scan (codebase+config, Confluence 14 CQL / full 185-page tree, Jira 22 JQL / all 4 projects) — all three surfaces agree.

- This PWA repo: `test` = `vitest run` (no `--coverage`), no `test:coverage` script, no `@vitest/coverage-*` installed, `vitest.config.ts` has no `coverage` thresholds (+ `passWithNoTests: true`), no codecov/sonar/.nycrc, and `qa.yml`'s `unit-tests` job just runs `npm test` (pass/fail, no coverage gate). SIT gate + deploy workflows reference unit tests not at all. `.claude/rules/testing.md` + AGENTS.md: "Write tests only where failure would be non-obvious or costly to debug."
- **Actual inventory — re-measured 2026-08-31 on `develop` @ `269d5d4`: 26 test files, 408 tests, all passing; `npx tsc --noEmit` clean.** This supersedes the 2026-08-06 count of 2 files / 15 tests, which is now badly stale — PR #59 (footer/ui-kits, incl. the 6-test `recipeGuards.test.ts`) and PR #64 (SFCC-89 `zimmProduct*` family) added most of it. The *policy* below is unchanged: still no coverage %, still risk-based. Re-measure rather than quoting a count; it is moving fast this sprint.
- The **90% coverage threshold** people sometimes cite lives on Confluence page "SFCC Build and Deployment Process – Headless Architecture" (264896514) — but that page **explicitly scopes itself to the SFCC *backend* cartridge repo** (`zimmermann-sfcc/`, Jest with `dw.*` mocks, `ci.yml`/`pr-check.yml`, `cartridges/`/`vendor/`). It says the frontend is documented separately. That 90% does **not** apply to the PWA. (Diagnostic proof: Confluence queries for `Jest`, `test:coverage`, and the exact phrase "branches functions lines statements" each return ONLY page 264896514.)
- PWA-specific Confluence pages (PWA CI/CD Pipeline 305561601, Development Standards 261750785, Human-in-the-Lead 305102849) require unit tests to *pass*; none state a coverage %.
- Jira: no issue defines a coverage target for either repo. **Two false positives to ignore next time:** (a) `Lighthouse CI >90` in epic SFCC-1 is a *performance* score, not coverage; (b) the sole "coverage" mention (SFCC-205) means *Figma-to-code design-handover* coverage. No dedicated Testing/QA epic exists; unit tests appear only as an unquantified pipeline step in SFCC-1.

**Why:** Both repos live in the same SFCC Confluence space, so the backend's 90% Jest threshold is easy to misread as a frontend requirement.
**How to apply:** If asked for the PWA's coverage target, answer "none — risk-based selective testing." Don't wire a coverage threshold into `vitest.config.ts`/`qa.yml` on the strength of the 90% Confluence figure. Related: [[reference-confluence-sfcc]].
