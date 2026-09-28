---
name: feedback-surface-gaps-prebuild
description: "During prebuild/planning and when running 'the improver', explicitly surface what Marcel might be missing — not just validate his stated assumptions."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3062b85f-ee32-4350-ae00-30fe2f595ef5
  modified: 2026-09-07T17:32:25.421Z
---

When running "the improver" (Marcel's own term, given 2026-09-08 mid-build on SFCC-83/84 — exactly
which tool/skill/process this refers to was not confirmed at the time; clarify when it's actually
invoked rather than assume) and, more generally, during any prebuild/planning/feasibility phase,
explicitly ask and answer "what am I (Marcel) missing here" as its own named step — not just
execute or validate the stated plan/request at face value.

**Why:** given as a standing process instruction, not a one-off correction. It matches a pattern
already visible across the SFCC-83/84 build session: the most valuable findings (Einstein
confirmed "Not Deployed" platform-wide, the `getProducts` 24-ID-per-request cap, the
`recommended-products` dead-check-ordering bug that would have silently broken the Recently-Viewed
branch) all surfaced only because gaps in the stated plan/assumptions were actively hunted for —
not because a stated requirement was mechanically checked off. See [[prove-dont-assert]] — a
related but distinct discipline: that one is about not trusting an unverified claim of *my own*;
this one is about actively surfacing what *the requester* hasn't accounted for.

**How to apply:** during any prebuild/feasibility/planning pass — and specifically once "the
improver" step is identified — include an explicit pass whose purpose is finding what Marcel (or
whoever is directing the work) hasn't accounted for, not just confirming what he already knew to
ask about. Surface these proactively, before implementation starts, rather than waiting to be
asked or letting them surface as mid-build surprises.
