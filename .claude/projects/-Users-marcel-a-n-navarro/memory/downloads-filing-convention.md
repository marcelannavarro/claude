---
name: downloads-filing-convention
description: How to organize ~/Downloads — frozen Pre-Zimm archive + companion Zimmermann-PWA active structure
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 13bd3994-80de-4d8d-b62f-373df62e4eed
  modified: 2026-07-21T11:54:41.222Z
---

When organizing `~/Downloads`, the user prefers a compartmentalized project→phase structure, personal kept separate from work, original filenames preserved (don't rename), and exact duplicates sent to Trash (recoverable) rather than deleted outright.

Established layout (confirmed 2026-07-21):
- `Pre-Zimm/` — **FROZEN** snapshot of the pre-project / onboarding period. Do NOT add to it.
- `Zimmermann-PWA/` — active project work, subfoldered by phase: `Guardrails/`, `Handover/`, `Onboarding/`, `TSD-Templates/`, `Integration-Specs/` (Tryzens/MuleSoft + Global-e reference PDFs), `Delivery/`, `Screenshots/`.
- `Accenture-Admin/` — HR / IT / device admin (RIRO checklist, JAMF `.mobileconfig`, device/asset/SSO screenshots), with its own `Screenshots/`.
- `Personal/Recognition/` — kudos / recognition captures.

**Why:** the user runs periodic Downloads cleanups (a Jul 8 2026 "MIGRATION" pass created Pre-Zimm; this was the Jul 21 2026 pass) and wants new active-work artifacts filed consistently instead of piling up loose at the root.
**How to apply:** file new loose items into the matching `Zimmermann-PWA/*` phase folder (or `Accenture-Admin` / `Personal`); never modify `Pre-Zimm/`. Note: macOS screenshot filenames contain a narrow no-break space (U+202F) before AM/PM — match them with `*` globs, not literal spaces. See [[user-identity]].
