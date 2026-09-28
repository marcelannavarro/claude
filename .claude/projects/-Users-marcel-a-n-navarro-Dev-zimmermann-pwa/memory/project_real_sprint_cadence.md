---
name: project-real-sprint-cadence
description: Ground-truth Jira sprint dates/scope for SFCC board (id 500) as of 2026-08-11 — corrects the stale local .docs/memory/sprintScope.md draft; also key people for component-story work
metadata: 
  node_type: memory
  type: project
  modified: 2026-08-11T11:01:47.146Z
  originSessionId: ca118e83-50ee-4df0-a734-d83474ec83ec
---

**`.docs/memory/sprintScope.md` (repo file, dated draft 2026-06-23) is confirmed stale/wrong —
both dates AND scope** — verified against Jira board 500 ("SFCC board", project SFCC) on
2026-08-11:

| Sprint | Jira state | Real dates | sprintScope.md's claim |
|---|---|---|---|
| Sprint 1 (id 497) | closed | 7–27 Jul 2026 | not really addressed |
| Sprint 2 (id 567) | active (closing today) | 28 Jul–10 Aug 2026 | claimed as "Sprint 3, 27 Jul–7 Aug" |
| Sprint 3 (id 568) | **future, starts today** | **11–24 Aug 2026** | claimed as "Sprint 4, 10 Aug–21 Aug" |

Real Sprint 2 (just closing) was almost entirely spikes/config/QA, not feature-build: SFCC-254
(env setup DEV/TEST/SIT/UAT), SFCC-240 (Spike: Figma-to-React workflow), SFCC-237 (Spike: MRT
app architecture), SFCC-126 (Global Customer List Setup), SFCC-26 (Product Attributes – PDP) —
zero PDP/PLP/Cart/Search feature-build stories, which matches this repo's own git/PR history
(51 PRs, 268 commits as of 2026-08-11 — essentially all CI/CD/governance/config, no shipped
PDP/PLP/Cart/Search UI). Real Sprint 3 (starting today) is per Confluence's own **04.7 Component
Inventory** (400195591) "Sprint Planning" column literally scoped as **"Sprint 3 for User Story
Writing"** — its declared purpose is writing/refining component-level stories against the
already-built design-system inventory, not shipping page features yet. Both squads' Confluence
Sprint 3 pages ("A - Sprint 3" 396656658 / "B - Sprint 3" 396656649) show Status NOT STARTED,
Goal TBD, empty committed-stories table as of today. Per Confluence "Meeting Cadences"
(322207767), Tuesday is the team's defined "Sprint Planning (First day of Sprint)" ceremony day
— 2026-08-11 is a Tuesday, so the "Components" meeting almost certainly **is**, or directly
feeds, that Sprint Planning ceremony — not a Sprint 3 retro/wrap-up as the stale local doc's
dates would have implied.

**Epic structure:** SFCC-1 = "Platform Setup & Environments" (unrelated to components, despite
the low number — don't assume epic 1 = the components epic). SFCC-2 = "PWA Kit Components"
(status To Do) is the actual shared-component epic. Page epics: SFCC-5 PDP, SFCC-6 PLP, SFCC-7
Search & Recommendations, SFCC-11 Cart, SFCC-19 Regional Storefronts.

**Sprint 4 (id 569):** 2026-08-24 – 2026-09-07. **Sprint 5 (id 570):** 2026-09-07 – 2026-09-21
(UTC boundaries; effectively 21-22 Sep Sydney-local). Any "complete by end of Sprint 5" business
commitment means **2026-09-21**, not the stale local doc's ~24 Aug-4 Sep window.

**Key people** (triangulated from Team Overview 261586947, Tool Access Tracker 259686402,
Meeting Cadences 322207767, confluence_search_user, and live ticket activity):
- **Tash Lay = Natasha Lay**, ACN (Accenture) Delivery Lead, covering for Izzy/Isabel Chaloner,
  Accenture Onshore, **Sydney** (explains a meeting invite's "For those in Sydney - we'll be in
  the Zimm office" line). Named in the weekly "Key Outstanding Actions" forum, itself scoped
  "up to Sprint 3" — i.e. wrapping up around now. Not a Scrum Master or BA — a live Jira comment
  on SFCC-420 by Hazel Cacalda cites "Tash's advice" on a Definition-of-Ready/approval question,
  confirming she's an active process/governance decision-maker, consistent with Delivery Lead.
- **Isabel "Izzy" Chaloner** — the other ACN Delivery Lead (Tash covers for her) — personally
  authored all 6 "EXAMPLE:" component-story tickets (SFCC-691/692/694/698/699/700, see
  [[project_story_decomposition_pattern]]) the morning of 2026-08-11, hours before this meeting
  — appears to be operationally driving the new component-story framework into Jira. Also
  created the new SFCC-701 "Homepage" epic the same day (see [[project_component_pivot_findings]]).
- **Hazel Marie Cacalda** — Scrum Master, both Squad A and Squad B.
- **Jasmijn Tsang** — Lead BA; authored the earlier informal precursor split (SFCC-648/650,
  2026-08-07) and the new SFCC-688/689 regional-selector stories (2026-08-11).
- **Victor T. Crisostomo** — Dev Lead / "Offshore Dev Lead" / "SFCC Lead" (Delivery Squad 1).
  Confirmed via confluence_search_user + multiple Jira assignments (SFCC-48, 421, 420, 676).
- **Gideon "Gids" Linsangan** — Offshore SFCC BM Configurator/Coordinator (Delivery Squad 2).
  Nickname is self-attested in-project: SFCC-128's own description reads "Victor and Gids to
  lead this review with the broader squad," and SFCC-128's assignee is Gideon R. Linsangan.
- **Kiera Rikard-Bell** (`kiera.rikard-bell@accenture.com`) — a real Accenture Atlassian
  identity confirmed via confluence_search_user, but **zero findable role/team/squad**: not in
  Team Overview, not in Tool Access Tracker, zero Jira issues (assignee/reporter/mentioned),
  zero Confluence search hits by name. Unusual gap — flag rather than assume a role.
- **"Epsom"** — **could not be identified from any Confluence or Jira source** as of 2026-08-11
  (checked confluence_search_user, site-wide search, Jira issue/comment text, Project Executive
  Council roster). Appears to be senior (directs an "Executive Readout," calls out named
  individuals for scrutiny) but nothing ties the name to a specific person in searchable
  project content — likely someone outside Jira/Confluence's tracked population (external
  stakeholder, very new, or a name/nickname variant). Ask directly rather than re-searching.

**Recommendation:** `.docs/memory/sprintScope.md` should be refreshed against this — flagged to
the user 2026-08-11, not yet edited (repo project-doc edit needs the user's go-ahead per
AGENTS.md's "propose, wait for approval" norm, not an auto-memory edit call).

Related: [[project_story_decomposition_pattern]], [[project_figma_signoff_status]],
[[reference_confluence_sfcc]], [[user_role]].
