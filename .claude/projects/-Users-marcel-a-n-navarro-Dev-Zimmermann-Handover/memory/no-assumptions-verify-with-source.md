---
name: no-assumptions-verify-with-source
description: "Angelo requires no assumptions/inference: state only verified facts, cite the source, and ask the owner for anything unknown"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 9a628348-0759-4729-b6a4-ddd73c8b9a2a
  modified: 2026-07-24T03:25:31.699Z
---

Angelo (front-end lead) consistently pushes for rigor and sourcing over inference. Concrete trigger (2026-07-23): he corrected me for inferring HOW the dev sandbox data got loaded, saying "we must not assume anything ... we could ask victor that."

**Why:** he authors engineering docs (TSDs) that others build from; an unsourced inference becomes a defect and erodes trust.

**How to apply:** In analysis and deliverables, separate observed/verified facts (each with a source: codebase file:line, Confluence page id, Jira key, or a live run) from unknowns. Convert unknowns into explicit questions for the owner rather than filling them with plausible guesses. Do not label things in ways that presume unverified provenance (e.g. do not call sandbox data a "seed" or "sample" until confirmed). Related: [[tsd-scope-principle]], [[sfcc-122]].
