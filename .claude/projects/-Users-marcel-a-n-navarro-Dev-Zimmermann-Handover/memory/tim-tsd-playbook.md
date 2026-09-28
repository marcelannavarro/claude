---
name: tim-tsd-playbook
description: "Reference file distilling Tim Lavelle's TSD review preferences into a repeatable recipe, at ~/Dev/TSD-PLAYBOOK-TIM-LAVELLE.md; consult before drafting or reviewing any TSD"
metadata: 
  node_type: memory
  type: reference
  originSessionId: d51da073-864e-43af-b27c-4d57dfdab54d
  modified: 2026-08-12T12:07:08.714Z
---

`~/Dev/TSD-PLAYBOOK-TIM-LAVELLE.md` distils Tim Lavelle's (SA) TSD review preferences into 11 principles plus a pre-submission checklist and a "patterns that trigger a comment" table. Built 12 Aug 2026 from his inline comments on Confluence 346783750 (SFCC-249, up to v42) and Jira comments on SFCC-51, SFCC-96, SFCC-123, SFCC-249. Every principle is paired with the verbatim comment it came from, so the reasoning stays checkable.

**Read this before drafting or reviewing any TSD for this project.** It exists to cut review round-trips.

The core of it: Tim reviews for **trust** and **future maintenance cost**, not completeness. His two most repeated themes are (1) "Is this verified or a Claude assumption?", never pass through unreviewed AI output, and (2) the drift rule, "link, don't replicate", raised at least four separate times on one document. His highest-leverage habit for us: an honest "undecided, pending X, owner Y" is more approvable than a confident guess.

Caveat recorded in the file itself: principle 8 (don't over-engineer distinctions) rests on the Studio-versus-coded authoring-path comment, which is still an **open disagreement**, not a settled preference. See [[sfcc-249-reformat-draft]] for that dispute's status.

Related: [[tsd-scope-principle]] (the one-problem rule, which this expands on), [[sfcc-249-reformat-draft]], [[no-assumptions-verify-with-source]].
