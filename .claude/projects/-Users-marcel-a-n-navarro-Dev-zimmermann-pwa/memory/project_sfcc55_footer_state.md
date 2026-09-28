---
name: project-sfcc55-footer-state
description: SFCC-55 global footer / PR #59 — CodeRabbit cleared, blocked only on human code-owner approval; plus the set of items deliberately deferred with rationale
metadata:
  node_type: memory
  type: project
  originSessionId: f5f727b4-7546-4aa6-9d86-ef229e247d3f
  modified: 2026-08-22T02:20:00.000Z
---

State as of 2026-08-22: branch `feature/SFCC-55_global-footer-ui`, HEAD `ec9d161`, clean tree.
[PR #59](https://github.com/ZimmermannAU/zimmermann-pwa/pull/59) open, not draft, `MERGEABLE`,
`reviewDecision: REVIEW_REQUIRED`. ~64 commits ahead of develop.

**The only thing blocking merge is a human code-owner approval.** CodeRabbit went through roughly
27 threads over several rounds and was cleared; Marcel cannot self-approve as author. CODEOWNERS
requested two Tier 1 owner groups because the PR touches `.claude/rules/frozenFiles.md`
(Governance) and `overrides/app/theme/foundation/fonts.ts` (UI Designer). Note
`coderabbit.yaml:32` sets `request_changes_workflow: true`, so a `COMMENTED` review cannot clear
an earlier `CHANGES_REQUESTED` — only an `APPROVED` one can.

**Deliberately deferred by Marcel, with reasoning already recorded in the PR threads** — do not
re-raise these as new findings:

- **Locale label** is hardcoded and wrong on 10 of 11 storefronts. Accepted; "the shell is the
  focus". See [[project-locale-selector-dead-end]].
- **`/checkout` demo footer** — belongs to its own PRD per `.docs/prd/homepage.md:8`, not SFCC-55.
- **i18n** — zero `react-intl` on the fr/it/es locales. Separate work.
- **AC7 schema shape** (per-locale vs per-storefront) — unresolved, out of scope.
- **`pendingSignupRef` clear on modal close** and **`aria-disabled` on the locale control** —
  deferred to HPC-035.
- **Font licence entitlement** — Marcel's call: fonts are self-hosted for development and
  testing, and all licence/entitlement text was removed from the codebase on instruction.
- **`header/index.tsx:302`** `fontSize="l"` — pre-existing, see
  [[project-chakra-scale-registration]].

Also open but not Marcel's: **BrowserStack CI fails with `Config file does not exist`** —
pre-existing infrastructure issue, owned by Integration.

**Why:** several of these were re-raised more than once across review rounds, and re-litigating a
settled deferral wastes a cycle and risks reopening a decision Marcel already made.

**How to apply:** if one of the above surfaces again, point at the existing thread rationale
rather than re-analysing it. The subscribe modal ships descoped behind `enableNameCapture`.
