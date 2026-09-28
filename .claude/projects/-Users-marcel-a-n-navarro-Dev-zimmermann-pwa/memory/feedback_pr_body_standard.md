---
name: feedback-pr-body-standard
description: "Match PR title+body to accepted PRs #46/#47 (CI) or #59 (story-backed feature) as the basis — not the literal PULL_REQUEST_TEMPLATE.md"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 79d42a29-60f8-4650-8225-19c556de706b
  modified: 2026-09-14T16:07:46.419Z
---

When opening a PR, match the **actual accepted PRs #46 and #47** as the house-style basis — NOT a freehand body and NOT the literal `.github/PULL_REQUEST_TEMPLATE.md` (the template's `type(scope): SFCC-### desc` title rule is aspirational; the real PRs don't follow it).

**The real convention (from #46/#47):**
- **Title:** plain Conventional Commits. **Whether the SFCC key goes in the title is conditional, not a blanket no** — corrected 2026-08-26:
  - **No key** when the PR has no single user story behind it — all of #44–#54 (`feat(ci):`, `chore(ci):`) and #56. Their ticket was a workstream under epic SFCC-1, so there was no key to name. This is the case #46/#47 established.
  - **Key in the title** when the PR implements one story — `feat(footer): SFCC-55 global footer UI — shell, layout, and ui-kit component structure` (#59, merged, and the precedent for every story-backed feature PR since). #58 puts it in trailing parens, #61 uses a bare `SFCC-751:` prefix; the #59 form is the one to copy for a `feat`.
- **Body sections, in order:** `# Description` → `# Linked` → `# Squad ownership` → `# Types of Changes` → `# Changes` → `# How to test-drive this PR` → `# Protection-tier check` → `# Testing`. **Omit** Accessibility / Localisation / Third-party-integrations entirely when they don't apply (don't pad them as "n/a"). No tier *table*, no separate "CodeRabbit pre-merge gates" block.
- **Linked:** `- Ticket: <workstream> under epic **SFCC-1** (Platform Setup & Environments); design in Confluence *Proposed: Tag-Based Environment Promotion (GitFlow)* (335216656)` and `- Sprint: SFCC Sprint 2`. (The env/CI/tag-based-promotion work is tracked under **epic SFCC-1** + Confluence 335216656 — NOT SFCC-254 in the PR body, and NOT in the title.)
- **Changes:** plain bullet list.
- **Types of Changes:** tick **New feature** for a `feat(...)`, even CI ones.
- **Protection-tier check:** a `> ⚠️ **Tier 1 change** — <file> ... Authenticated as marcelannavarro, member of @ZimmermannAU/tier-1-approvers; CODEOWNERS auto-requests review` blockquote, then affirmative `- [x] Tier 1 file(s) modified — owner review required (...)`.
- **Testing:** `[x] ... — N/A` lines + a final `N/A: Storybook / Vitest / Playwright (...)`.

**Why (title rule):** the original "no key in the title" reading generalised from #46/#47, which were CI PRs with no story to reference. Applying it to a story-backed feature PR would drop the key that links the PR to Jira — the same `SFCC-\d+` signal the GitHub-for-Jira app and `qa.yml`'s BrowserStack story scoping both read from the PR title/body/branch (see [[project-test-harness-gaps]]).

**Why (body structure):** 2026-08-06, PR #48. First I opened it with a freehand body (bypassed the standard); the user flagged "not abiding by standards, particularly the body — this was bypassed from me." Then I over-corrected to the literal template (added SFCC-254 to the title, tier table, padded a11y/l10n sections). User: "still off — look into PR 46 and 47 as basis." Fixed by matching #46/#47 exactly.

**How to apply:** Before `gh pr create`, pull the body of the nearest precedent — **#59** for a story-backed feature PR, **#46/#47** for CI/infra — (`gh pr view 59 --json title,body`) and mirror its structure/wording. #59 adds two sections worth reusing on a feature PR: a "N points worth surfacing before review" bullet list in `# Description`, and a closing paragraph naming pre-existing issues that surface in the changed-files view but predate the PR. Keep the honesty rule ([[project-pr42-env-security-gotcha]] style): don't tick a box for a step not actually done — mark it N/A explicitly.

**Corrected 2026-09-15, after actually shipping this wrong once:** two failure modes found doing
a zimmerMANNPostBuild PR draft for the Adyen vendor-chunk fix, both worth naming so they don't
repeat.

1. **A PR merged in this repo is not automatically a Marcel-style exemplar — verify authorship
   before copying its format.** Went looking for "recent ticket-less CI fix" via `gh pr list
   --search`, found #89/#99/#101, copied their (lighter, no-`# Linked`) structure — without
   checking who wrote them. #89's own body says "Authenticated as `TimLavelleACC`" — a
   colleague's session, not Marcel's. Always check the `author` field (`gh pr view N --json
   author`) or an explicit self-identifying line in the body before treating a PR as house style,
   especially when it was found by keyword search rather than by number from a memory note that
   already named the right one.
2. **The `# Linked` section's "epic SFCC-1 + Confluence 335216656" framing is specific to planned,
   scoped workstream PRs (#46-50, all part of the named tag-based-promotion rollout) — it does
   not apply to a genuinely ad-hoc fix found through direct investigation with no workstream
   behind it.** For that case, match **#33** instead (`fix(deps): sync package-lock.json...` —
   found via a local `npm ci` failure, not a story): `- Ticket: none — found via direct
   investigation of <specific problem>, not from a story` and `- Sprint: N/A — infra fix, not
   sprint-scoped feature work`. #33 predates the 2026-08-06 a11y/l10n-padding correction below, so
   don't copy its Accessibility/Localisation/Third-party-integrations sections (it includes them
   with reasoned ticks; #46-50, written *after* the correction, omit them entirely) — but its
   `# Linked` approach is a different dimension the correction never touched, and is still the
   right model for this specific case. #33 is also the reference for how to word an ambiguous
   Tier gap: package-lock.json wasn't literally listed as Tier 1 either, and #33 flagged it as
   "Tier 1 in spirit" rather than resolving it unilaterally — the same move this repo's actual
   `frozenFiles.md` precedent (`request-processor.js`, "add here when populated") already
   endorses for exactly this situation.
