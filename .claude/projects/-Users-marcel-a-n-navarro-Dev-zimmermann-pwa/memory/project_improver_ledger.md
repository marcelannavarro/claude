---
name: project-improver-ledger
description: "Where zimmerMANN improver runs are recorded (gitignored .runs/_improver/), and the 2026-09-11 catch-up state"
metadata: 
  node_type: memory
  type: project
  originSessionId: 936e8a1d-369c-4c54-9c6e-2c7295b8b654
  modified: 2026-09-11T01:35:36.579Z
---

The zimmerMANN skills live in **`~/Dev/zimmerMANN-skills`** (a separate git repo, symlinked into
`~/.claude/skills/`), not in `zimmermann-pwa`. Two things there are easy to miss:

**The improver run ledger is `~/Dev/zimmerMANN-skills/.runs/_improver/`** — `2026-MM-DD.md` for
Dev, `rev-2026-MM-DD.md` for Rev. **It is gitignored** (`.runs/*`), so it exists only on this
machine and never appears in the repo's history. It is the only record of *when* an improver
actually ran. Git log shows only when its output was **committed**, which is a different date —
in September 2026 the two diverged by nine days.

**Checking "when did the improvers last run" needs both sources.** Transcript invocations are
findable with `grep -o '"skill":"zimmerMANN[A-Za-z]*"' *.jsonl` and
`grep -o '<command-name>/zimmerMANN[A-Za-z]*<'` across
`~/.claude/projects/-Users-marcel-a-n-navarro-Dev-zimmermann-pwa/`. A bare grep for the skill name
is useless — every session's system prompt lists all skills, so ~129 of 541 files match.

**State as of 2026-09-11 catch-up** (commits `8234e22`, `b755513`, `e53634b`, `8b3935f`, `efc7896`,
pushed): three prior runs (Rev 09-02, Dev 09-05, Dev 09-07) had applied accepted proposals that
were **never committed** — 94 lines sitting in the working tree. Baselined first, then six new
proposals applied across `zimmerMANNBuild`, `zimmerMANNReview` and `zm-tester`.

**Two things left open for Marcel, neither fixable by an improver** (each skill is barred from
editing itself):
- `.runs/_improver/2026-09-07.md` contains two false, load-bearing statements — it claims no
  in-scope file was invoked (`zimmerMANNBuild` was, and aborted on its no-plan rule) and
  attributes the pipeline bypass to Marcel when Claude proposed it. That misattribution is what
  moved the wrong-branch incident out of scope via the skill's own never-argue-with-a-decision bar.
- `.research/DECISIONS.md` is untouched since 2026-08-30 despite eight improvement commits, and
  still lists the Review phrasing rule as "Still held" when it has been applied.

**Why:** the run/commit divergence and the gitignored ledger together make "have the improvers been
run?" unanswerable from the repo alone — which is exactly the question that started this.

**How to apply:** read the ledger before proposing anything, to tell a second occurrence from a
first. Related: [[project-review-findings-never-posted]], [[feedback-prove-dont-assert]].
