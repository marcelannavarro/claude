---
name: feedback-build-faster-not-thinner
description: "Cut redundant re-verification, not real testing — and always surface what Marcel is missing"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5b8f9512-8501-48d0-87d9-ea382b6ce640
  modified: 2026-09-11T01:56:20.014Z
---

Two standing instructions set 2026-09-11, both now written into all 8 skills and 5 loop agents
(`f2b2351`).

**1. Build faster without thinning quality.** His words: there is a difference between *being
robust to ship production-ready code* and *redundant testing that costs time* — especially when
full-scale testing runs at the end of the build anyway. Do not run the whole loop on a simple task.

The distinction that makes this actionable: the waste was never "too much testing", it was
**re-doing work that had not changed.** Measured across the September sessions — an identical
four-angle agent wave re-run 90 minutes later against a diff with no commits in between, then a
wave to validate it, then one to "audit the audit"; the same finding set re-synthesised six times
and posted zero times; twelve claims verified then all thirteen re-verified on demand, changing
nothing; yield on one session decaying 55% → 47% → 8%. Meanwhile the *cheap* high-yield checks —
opening a browser, the Scorer's design-fidelity axis — were skipped entirely.

So the rule is: **stop paying for the expensive low-yield thing so you can afford the cheap
high-yield one.** Never re-run an angle or check against an unchanged diff. Never re-present an
unchanged conclusion.

Deliberately **not** a yield-floor / stop-below-X% rule — `.research/DECISIONS.md` rejects that
("the yield calculation is itself a judgement that could go wrong"). Do not re-propose it.

**2. "Tell me what I'm missing."** Every skill and agent now closes with a `## What Marcel is
missing` section. It is explicitly *not* the existing "what I could not verify" blind-spot
section. It is his: what he hasn't thought to ask, a decision about to be made on a stale premise,
a risk just outside the task, a call that needs him rather than you. "Nothing this pass" is only
allowed after actually looking.

**Why:** he wants the areas needing his involvement surfaced, not just his asks validated — the
same instinct already recorded in [[feedback-surface-gaps-prebuild]], now generalised to every
skill.

**How to apply:** in chat too, not only in skill output. Practise it on your own work — including
naming the limits of what you just did.

**Known open:** the two biggest measured time sinks are *not* fixable by skill wording — ~78% of
one PR's transcript was replayed context from session restarts, and ~10h30m of an 18h44m review
was idle time waiting on Marcel's own adjudication. Raise those separately if velocity stays a
problem. Related: [[feedback-prove-dont-assert]], [[feedback-authorisation-and-scope]].
