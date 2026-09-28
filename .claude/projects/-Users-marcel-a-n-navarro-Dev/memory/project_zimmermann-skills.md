---
name: project_zimmermann-skills
description: zimmerMANN-skills — Marcel's personal FED Lead workflow skills, 1 of 8 built, evidence-derived from a full transcript read
metadata:
  type: project
---

Building 8 personal workflow skills at `~/Dev/zimmerMANN-skills`, symlinked into `~/.claude/skills`
and `~/.claude/agents`. Order: PreBuild → Build → PostBuild → Review → DevOps → Sprinter →
DevImprover → RevImprover, then a wiring pass. **One at a time; integration last** (his call).

As of 2026-08-30: **all eight skills built**, plus five loop agents. The wiring pass is what remains.

**They are derived from evidence, not invented.** On 2026-08-30 all 459 sessions / 12,242 user
turns / 309 agent transcripts were read in full via 13 parallel agents. `.research/FINDINGS.md`
holds the evidence; `.research/DECISIONS.md` holds his rulings on it — what was applied, what is
held for later skills, and what was rejected with reasons. **Read DECISIONS.md before touching any
skill, and do not re-litigate what it records.**

**Standing rule: nothing lands unapproved.** Every change to a skill or agent is proposed with its
rationale and waits for an explicit go. Set after I added an agent and rewrote six others
unilaterally — his correction: the transcripts are what happened, and much of what happened was the
failure mode; learn from them, do not transcribe them.

Three things that dictate the design and are easy to get wrong:
- **Scope is his #1 correction (~265), ~1.9× the next.** Not tokens/components/CSS. Those lead
  only on live build work, where design conformance leads.
- **Two different closed loops exist and both worked** — the five-role loop with a scorer return
  path (SFCC-89 PDP Static, PR #57) and a 4-stage prove→implement→adversary pipeline (SFCC-55
  footer, PR #55, 97 agents). The prove-first stage rejected ~1 in 3 claims and is the higher-yield
  half.
- **He never gave a research agent write access** (0 of 171). Only the BUILDER role writes.

Constraints: never write to `zimmermann-pwa/.claude/**` or any Tier 1 file · human-in-the-lead,
no hooks · his local-only docs must never be cited in a PR, commit, or code comment.

Related: [[project_zimmermann-pwa]], [[user_profile]]
