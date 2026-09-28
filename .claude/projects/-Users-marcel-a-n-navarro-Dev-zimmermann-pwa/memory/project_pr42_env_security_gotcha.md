---
name: project-pr42-env-security-gotcha
description: "GitHub Actions security gotcha found reviewing PR #42 (sync-env-vars-to-mrt): choice-type dropdown restrictions and repo-level secret inheritance can silently undermine an 'ungated target' fix"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1003f0f2-2096-43b9-999b-9b4f47361210
  modified: 2026-07-28T06:15:38.210Z
---

While independently re-reviewing PR #42 (`feature/sync-env-vars-to-mrt` — on-demand workflow
to sync `.env.sample`-tagged GitHub Environment Variables to MRT), found a pattern worth
checking on any future workflow that uses a `workflow_dispatch` `type: choice` input as its
only restriction on which environment/target gets touched.

**The gotcha, in two parts:**
1. GitHub's own docs describe `choice` input validation only in terms of the Actions UI
   dropdown. They do not confirm (and I could not otherwise confirm) whether a `gh workflow
   run` / REST API dispatch with an arbitrary string for a `choice` input is rejected
   server-side, or silently accepted and passed through as a plain string. Treat this as
   unverified, not proven-safe, for any workflow where the choice list is meant to be a
   security boundary (e.g. "prod excluded from the dropdown").
2. Independent of (1): a job's `environment: ${{ inputs.target }}` only gives *that specific
   environment's own* secrets/protection-rules priority — it does **not** stop the job from
   also inheriting repo-level secrets of the same name. If `FOO_API_KEY` is set at the repo
   level (not per-environment), a job resolving to *any* environment string — including one
   never intended to be reachable, or one that doesn't even exist yet — still gets that
   credential. Removing a value from a `choice` list does not change this.

**Why it mattered here:** PR #42's original review found `prod` had an ungated path (empty
environment protection rules). The fix removed `prod` from the `target` choice list. On
independent re-check: `MRT_USER`/`MRT_API_KEY` (the credentials this workflow uses to write to
MRT) turned out to be **repo-level** secrets (`gh api repos/.../actions/secrets`), not
per-environment — so a bypassed dispatch to `prod` would still authenticate fine. The only
thing making this inert *today* is that `prod`'s GitHub Environment happens to have zero
Variables provisioned yet (`gh api repos/.../environments/prod/variables` → `total_count: 0`)
— a coincidence of current rollout state, not a designed safeguard, and it stops being true
the moment prod gets onboarded like `dev`/`test`/`sit`/`uat`/`staging` already are (7–16
variables each).

**How to apply:** for any workflow gating a destructive/sensitive target via `type: choice`
alone, check (a) whether the excluded value could still be reached via API/CLI dispatch, and
(b) `gh api repos/{repo}/actions/secrets` vs `gh api repos/{repo}/environments/{env}/secrets`
to see whether the credentials in play are actually scoped per-environment or repo-wide. If
repo-wide, the `choice` list is cosmetic, not a security boundary — recommend an explicit
allow-list check inside the script itself as defense-in-depth, independent of the YAML-level
restriction.

See [[user_role]] for the tier-1-approver / reviewer-identity context this review was done
under.
