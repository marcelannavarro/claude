---
name: project-playbook-set
description: The FED playbook set is three docs in ~/Dev, not four — the philosophy doc was retired 2026-08-25
metadata:
  type: project
---

**Three live documents**, all at `/Users/marcel.a.n.navarro/Dev/` (moved off Desktop):

| file | role |
|---|---|
| `fedLead-playbook.md` | the role — process, judgement, governance, release, Jira, vendors |
| `fedBuild-manual.md` | the procedure — story to merged PR |
| `uiBuild-knowledge.md` | codebase truths — why the machine behaves as it does |

`zimmermann_frontend_lead_playbook.md` is **ARCHIVED** (25 Aug 2026) with a pointer header. It
was July training material on a Next.js/Tailwind stack; its durable principles moved to
`fedLead-playbook.md` §3–§4. Don't update it, don't cite it.

**The boundary rule that decides where a fact goes:** the document whose reader would act on
it, at the moment they'd act. `uiBuild-knowledge.md` answers *why does the machine do that*;
`fedBuild-manual.md` answers *what do I type, in what order*; `fedLead-playbook.md` answers
*what do I say, to whom, and when*. A named human, a Jira key, or a cadence forces the
playbook.

All three are **local-only** — never cite them in a PR, commit, or code comment
([[feedback-local-only-docs]]).

**Why:** a future session updating "the four core documents" would edit a retired file and miss
the live one.

**How to apply:** the set is three. Check the archive header before touching the fourth.
