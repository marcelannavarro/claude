---
name: eli5-running-mode
description: "Marcel can ask for \"ELI5BITFEDLOTP\" as a conversation-wide default, not just a one-off explanation request"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 4f143a27-bda5-4ed2-89a8-612349f0631d
  modified: 2026-09-10T07:14:46.544Z
---

When Marcel says "let's approach this conversation in ELI5BITFEDLOTP" (or similar), treat it as
a standing instruction for the rest of that session, not a single-message request. Keep every
technical explanation — findings, mechanisms, tradeoffs — in plain, simple language for the
remainder of the conversation, without watering down accuracy or skipping detail that matters.

**Why:** Earlier in the SFCC-83/84 recently-viewed session he asked for this acronym repeatedly,
once per finding. This time (2026-09-10) he front-loaded it as the conversation's running mode
instead — a shift from on-demand to default.

**How to apply:** Default to jargon-light, simple phrasing for the rest of any session where this
is invoked. This changes *how* things are explained, not how thoroughly — stay precise and
complete, just in plainer words. Revert to normal register only if Marcel says so or a new
conversation starts without the instruction being repeated.
