---
name: pr107_demo_only_never_merges
description: "PR #107 (interim Recently Viewed mechanism) is a demo/QA vehicle only and will never merge — the Einstein-wiring branch's own PR is the real merge candidate"
metadata: 
  node_type: memory
  type: project
  originSessionId: 4f143a27-bda5-4ed2-89a8-612349f0631d
  modified: 2026-09-15T02:57:56.529Z
---

PR #107 (`feature/SFCC-83-84_recently-viewed`, the interim browser-tracked Recently Viewed
mechanism, SFCC-83/84) exists solely to demonstrate the UI/behaviour on the live MRT Preview and
to facilitate QA testing — it will never merge to `develop`. Confirmed directly by Marcel,
2026-09-15.

**Why this matters:** `feature/SFCC-83-84_recently-viewed-einstein` was forked from PR #107 at
`c14ee9f` and carries its entire diff forward, on top of which it swaps the interim mechanism for
real Einstein wiring. The Einstein-wiring branch's own PR is the actual candidate for review and
merge — not #107.

**How to apply:** Any real bug found in PR #107's own code (e.g. via a local CodeRabbit pass, or
manual review) that also exists unchanged in the Einstein-wiring branch is not "someone else's
problem" deferred to a future PR #107 review cycle — that cycle will never happen, since #107
itself never merges. A finding like this ships for real the moment the Einstein-wiring PR merges.
Don't file it as out-of-scope against #107; treat it as in-scope for whichever branch is actually
going to merge.
