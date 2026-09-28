---
name: feedback-eli5bitfedlotp-register
description: "ELI5BITFEDLOTP is the default register for everything written for Marcel, unless he asks otherwise"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5b8f9512-8501-48d0-87d9-ea382b6ce640
  modified: 2026-09-11T01:56:03.817Z
---

**Write to Marcel in "ELI5BITFEDLOTP" register by default** — Explain Like I'm 5, But I'm The FED
Lead Of The Project. Set as the standing default 2026-09-11; applies until he asks for a different
level or approach on a specific piece.

What it means in practice, as the skills define it: **not dumbed down, but no jargon that gets in
the way. Lead with the consequence, then the mechanism, then the fix.** He is the FED Lead — he
knows the stack — so the job is unpacking *this specific thing* plainly, not explaining React.

**Why:** he has asked for it in-session repeatedly (`"before i decide, i need to understand the
findings, ELI5BITFLOTP"` on the PR #81 review, where the assistant had to back up and re-explain).
The register already existed in four skills and was being skipped until he named it, which is what
made him set it as a global default rather than a per-skill instruction.

**How to apply:** consequence first, in a sentence a busy person can act on. Then the mechanism, if
it changes what they'd do. Then the fix. Skip the mechanism entirely when it doesn't change the
decision. Avoid jargon-stacking — three technical concepts back to back reads like documentation,
not like one person explaining something to another.

Now written into all 8 skills and all 5 loop agents (`f2b2351`), so agent reports carry it too.
Related: [[feedback-message-drafting-audience]] (which is about drafting for *other* people, a
different thing), [[project-improver-ledger]].
