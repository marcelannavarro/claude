---
name: tsd-scope-principle
description: "Tim's rule for what a TSD should be — tightly scoped to one problem/solution, lean, link don't reproduce"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 1559f9e3-183e-4cc9-91f8-add98b695aef
  modified: 2026-07-22T10:17:46.747Z
---

Tim's feedback on TSDs (Zimmermann SFCC): "A TSD is only focusing on the problem to solve (e.g. Contentful configuring SFCC IDs to obtain conditional rendering). It only needs to be addressing the problem/solution. Not all the other stuff."

**Why:** a TSD is a focused problem/solution design, not a catch-all briefing. Reproducing environment topology, dev-setup steps, bootstrap checklists, ownership/billing tables, CI/CD docs, etc. is out of scope and dilutes it.

**How to apply:** keep every section lean; **link** source pages (ops runbooks, env setup, other TSDs) rather than reproducing them. This exact rule is encoded as the SCOPE GUARD in the approved spike-TSD template at `~/Downloads/Zimmermann-PWA/TSD-Templates/specific-tsds/` ("a TSD addresses one problem/solution, not 'all the other stuff'... LINK the sources, do not reproduce them"; source list headed "link, don't re-type"). When drafting or judging a TSD, conformance to the approved template + this focus rule is a primary criterion. See [[sfcc-123]].
