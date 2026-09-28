---
name: feedback-authorisation-and-scope
description: Authorisation to investigate is not authorisation to fix, and not to commit — plus the warning signs of a self-sustaining audit loop
metadata:
  node_type: memory
  type: feedback
  originSessionId: f5f727b4-7546-4aa6-9d86-ef229e247d3f
  modified: 2026-08-22T14:40:00.000Z
---

**Three levels of authorisation, and they are separate.** During SFCC-55 two commits went in
unasked; the diagnosis was *"'Run it' and the visual check were investigation requests, not commit
approvals."* Marcel's response became a standing rule: *"avoid commiting without my go signal"*,
later escalated mid-turn to *"do not commit and push until my approval."*

Correct shape: **change → verify → stop and show the diff → wait.** This sharpens AGENTS.md Hard
Rule #15 with the distinction the rule leaves implicit — investigate ≠ fix ≠ commit.

**The audit-loop failure mode.** The build became a self-sustaining audit-and-fix cycle; Marcel
called it: *"the work that we've been doing has been a nonstop audit and fix loop ... are we
overengineering and doing work that's outside of the scope."* Measured: 55 commits, a 3.0:1 rework
ratio, `footer/index.tsx` touched **32 times in 5 days**. The verdict was not that the work was
wasted but that it was mis-ordered — *"you are building in the wrong order."*

The diagnostic that separates real work from generated work: *"The six applicable ones fix things
that were actually broken. The seven others came from **reading code we'd just written**."* If a
finding's origin is your own fresh output rather than a spec, a failure, or a review, it is
probably not the next thing to do.

Two concrete correctives:
- **Read the review queue before starting a self-directed pass.** A six-hour-old Major CodeRabbit
  finding named a live security bypass while the loop was polishing comment placement.
- **Ban "it's good practice" as a justification.** A fix needs a named requirement, a reproduced
  failure, or a review comment behind it.

**Present verdicts, don't auto-fix.** Marcel repeatedly asked for findings organised for his call —
*"do not decide for me, i'll make the calls based on the findings"* — and for the ELI5-but-I'm-the-
FED-Lead register. Options with a recommendation, not a completed change.

**Why:** the expensive failures on this project were not bad code, they were unrequested work and
unrequested commits.

**How to apply:** when a task produces a list of possible improvements, separate the ones traceable
to a spec/failure/review from the ones traceable to your own just-written code, and offer the
second group rather than doing them. Related: [[feedback-prove-dont-assert]],
[[feedback-local-only-docs]].
