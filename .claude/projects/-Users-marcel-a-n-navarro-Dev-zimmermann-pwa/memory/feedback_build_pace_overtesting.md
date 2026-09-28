---
name: feedback_build_pace_overtesting
description: "Marcel corrected excessive per-step Tester/Scorer agent overhead during zimmerMANNBuild loop execution — verify directly, don't ritually spin up exhaustive sub-agent audits"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3062b85f-ee32-4350-ae00-30fe2f595ef5
  modified: 2026-09-07T02:44:40.027Z
---

During `zimmerMANNBuild` (or any similar multi-agent implement→test→score loop), don't treat "this step gets the full loop" as license to dispatch a maximally exhaustive Tester agent every time — especially not one that itself spins up 4+ of its own sub-agents and runs 20-30 minutes per step. Verify the plan's own stated pass criteria directly first (tsc/test/lint/grep/read the diff — usually 5-10 concrete, fast checks). Only dispatch a separate Tester/Scorer agent for a piece of logic with real, specific ambiguity or risk — not as a blanket per-step ritual just because the plan's loop-configuration table says "full loop."

**Why:** Marcel said mid-build (SFCC-83/84, 2026-09-07): *"the build is taking too long... we have 20+ mins running tests, and this is not even the full implementation/feature test... can't we just run the actual tests that we need, not overthink, and do more building than testing?"* This was a direct correction after A1/A2 each burned through multiple full agent rounds (implementer → tester → rework → scorer, sometimes with the tester itself fanning out 4 parallel sub-agents) totaling well over an hour combined for what the plan itself explicitly scoped as a "mid-size build" of ~22 files. The skill's own instructions already say *"Scale to the work... over-scaled machinery is a defect, not thoroughness"* — I wasn't actually honoring that in practice, even though I was technically following the plan's textual "full loop" assignment per step. "Full loop" describes which roles are involved, not a mandate that the Tester role itself be maximally thorough every single time regardless of actual risk.

**How to apply:** Default to self-verification against the plan's stated pass criteria. Reserve a dedicated Tester/Scorer dispatch for genuinely high-risk or subtle logic the implementer itself flagged as uncertain — not as an automatic step. When about to dispatch a verification agent, ask first: "is this the actual test we need, or padding?" Applies to `zimmerMANNBuild` specifically, but the principle (verification effort should scale to real risk, not to a rote process checklist) generalizes to any multi-agent build/review loop on this project.
