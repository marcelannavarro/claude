---
name: project-tsd-templates
description: "Official Zimmermann TSD template (single source of truth): Confluence page 352419841 + local mirror + the 'one TSD = one problem' rule"
metadata: 
  node_type: memory
  type: project
  originSessionId: ff8d1882-1a8e-402b-8286-b8b0ae44f081
  modified: 2026-08-10T08:50:16.922Z
---

The Zimmermann team's **single source of truth** for TSDs is the Confluence page **"Technical
Solution Document (TSD) Template"** (page 352419841, SFCC space). A local mirror is kept at
`~/Downloads/Zimmermann-PWA/TSD-Templates/TSD-Template.md` — if the two diverge, Confluence wins.

**Structure (8 sections, verbatim-confirmed 2026-08-10, page version 2):** Document Information
(table: Document ID `TSD-[JIRA-KEY]`, Author(s), Reviewer(s), Created, Version `v0.1 — Draft`,
Status, Related Jira) + Version History (table) → **1. Problem Statement** (1.1 Context, 1.2
Problem, 1.3 Impact if Not Solved, 1.4 Success Criteria) → **2. Constraints & Assumptions** (2.1
Constraints table, 2.2 Assumptions table w/ "Risk if Wrong" column) → **3. Options Analysis** (3.1
Options Summary table incl. a discarded/non-viable option, 3.2 Option Detail per viable + one-line
discard reason for non-viable) → **4. Recommended Option & Rationale** (4.1 Recommended Option, 4.2
Rationale, 4.3 Trade-offs Accepted) → **5. Technical Implementation** — chosen option only (5.1
High-Level Sequence numbered steps incl. error path, 5.2 Component/API Changes table, 5.3 Data
Structures/Interfaces as JSON/pseudocode, 5.4 Error Handling & Edge Cases table, 5.5 Configuration
& Environment Notes) → **6. Testing & Validation** (6.1 Test Coverage table: Unit/Integration/
E2E-Playwright rows, 6.2 Regression Risk) → **7. Risks & Mitigations** (table: Risk/Likelihood/
Mitigation/Owner) → **8. Decision Record** (table of dated decisions + Sign-off table: Author row +
Technical Lead/Reviewer row, each Name/Date/Status). It's an ADR / options-driven format; a TSD is
**not approved for implementation** until Section 8 is signed off by the Technical Lead.

**Key instructional callouts on the template itself (Confluence enforces these as grey/amber boxes
to delete before submitting — don't skip them when drafting):**
- Copy the page per new TSD; delete all instruction callouts before review.
- §1 Problem Statement: **no options, implementation detail, or recommended approach** — a reader
  who knows nothing about the ticket should understand exactly what's broken/missing after reading
  it alone.
- §2 Constraints & Assumptions come **before** the options analysis — options are evaluated against
  them. If an assumption turns out wrong, the TSD must be updated and re-reviewed; do not proceed to
  implementation on a changed constraint.
- §3 Options Analysis: list every viable approach **including "do nothing" if relevant**; discarded
  options still get a brief entry so reviewers can see they were considered; **no implementation
  steps here** — that's §5, chosen option only.
- §4: if there's genuine author/reviewer disagreement on the recommendation, **don't resolve it in
  §4** — escalate to the Lead and record the outcome in §8 Decision Record instead.
- §5 is forward-looking implementation detail for the chosen option only — **don't copy-paste §3's
  option description into it.**
- §7: **"No risks identified" is almost never correct** — every implementation has at least one
  dependency, unknown, or constraint that could cause a problem; think harder before writing that.
- §8 Decision Record exists specifically to capture decisions made in meetings/Slack that aren't
  obvious from the document itself, so they don't get relitigated later.
- Confluence tiny-link `/wiki/x/AYABFQ` resolves to this same page (352419841) — confirmed
  2026-08-10 by decoding and by direct fetch; both point at the identical template.

**Governing rule (Tim, project lead):** **one TSD = one problem** — "it only needs to be addressing
the problem/solution, not all the other stuff." Writing "and also…" in the Problem Statement means
it's a second TSD.

**Superseded:** an earlier exploratory set of 4 genre templates (problem-solution / integration /
architecture / component) plus an SFCC-123 spike skeleton were created in that folder, then
**removed 2026-07-23** once this official template was adopted. Do not recreate them. The Confluence
TSD corpus that informed that exploration is inventoried in [[project-spike-122-123-audit]].

**Why:** the official template is the team standard and is not recorded anywhere in the repo.
**How to apply:** when asked to write or review a TSD, use the official 8-section structure, hold to
"one problem per TSD", and treat the Confluence page as canonical over any local copy.
