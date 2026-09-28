---
name: confluence-sfcc-space
description: "Confluence SFCC space structure — where PWA Kit project docs live (onboarding, architecture, standards, QA, setup checklists)"
metadata: 
  node_type: memory
  type: reference
  originSessionId: ef996bfd-f69c-4409-8ab6-757ed14dd8b6
  modified: 2026-08-11T03:21:18.366Z
---

Zimmermann PWA Kit's Confluence space key is `SFCC` (https://zimmermannworkboard.atlassian.net/wiki/spaces/SFCC/), under root page "SFCC Migration" (id 241434627). 146 pages total, numbered 01-09 + 99 Archive (two root-level stub pages, `01. PMO`/`02. Onboarding`, are unused templates — ignore them). Key pages for a React/frontend dev:

- 256835585 — Technical Solution Design – PWA (canonical architecture doc: integration boundary classes, multi-site/session model, SSR vs CSR per page type, env-var security table, Didomi consent-gate table)
- 268075023 / 258801666 — 1.5 Web Design (UX) / 04.2 Design Tracker — tracks Figma sign-off status per feature area; see [[project-figma-signoff-status]]
- 261750785 / 261881857 — Development Standards / Component Override Strategy — day-to-day conventions, has known conflicts with AGENTS.md, see [[project-confluence-repo-conflicts]]
- 304906242 — Technical Environment Setup — local machine setup, flagged stale, see [[project-confluence-repo-conflicts]]
- 304840733 — Branching Guide (GitFlow) — approval counts per branch, release tagging scripts
- 305561601 / 304840754 — PWA CI/CD Pipeline (GitHub Actions) / SIT Quality Gates — thresholds & secrets list
- 277544962 + Guides 1-4 (277577757, 277708807, 277676053, 305528833) — AI-Assisted QA six-stage pipeline (Story→AC→Zephyr→Playwright→BrowserStack→Triage)
- 259358732 / 259686402 / 268337165 / 305430530 — 7.1 Platform & Tool Access / 7.1a Tracker / 7.1b Third-Party Credentials / 7.1c CI-CD & Env Setup Checklist
- 261586947 / 297959425 / 304775192 — 1.2 Team Overview (contacts) / Claude Code Skills Reference / Claude Code CLI Developer Onboarding Guide

**04 Business Documentation family, component-story pages (found 2026-08-11, sit after 04.6
Consent Management as the newest pages in that series)** — 400195591 04.7 Component Inventory /
400195600 04.71 Writing User Stories for Components (the Level-1-component-epic vs
Level-2-page-epic methodology doc — see [[project-story-decomposition-pattern]]); also
313589763 Definition of Ready ("Stories with UI components are not Ready without approved
designs"), 322207767 Meeting Cadences (forum/attendee reference; Tuesday = Sprint Planning day),
274137093 "Creating User Stories with Claude" (BA guide for Jira story mechanics — Given/When/
Then AC, labels, FE/BE split — NOT cross-linked to 04.71, a doc-consolidation gap), 396656658 /
396656649 "A - Sprint 3" / "B - Sprint 3" squad tracking pages (see
[[project-real-sprint-cadence]]).

Full hierarchy and a prioritized reading list for a React dev were produced via a deep-read research pass on 2026-07-15 — re-run that kind of pass (or check `/session-start`, `/onboarding`) if this index goes stale rather than trusting these page contents as current.

**05.3 — Integration section** (parent 277643268, missed in the initial 2026-07-15 pass — added 2026-07-15 during a SFCC-122/123 spike audit, see [[project-spike-122-123-audit]]):
- 257687582 — Integration Register (hub) → children include 256933898 Integration Overview, 257949718 MuleSoft Integration — Overview (Experience/Process/System API layering; order/stock touchpoints only, not product/price/category)
- 292847624 — MuleSoft Integration — Functional Solution Designs (parent) → 292061208 TSD: Product — SFCC Catalogue & Data Integration, 312377345 TSD: Product Attributes, 292388871 TSD: Price — Pricebooks & Global-e, 312508418 TSD: Catalogue Sync (file-based, recommended), 315490342 TSD: Catalogue Sync — SCAPI Admin API Design (alternative pattern — the closest existing doc to "MRT API capabilities"), 292749334 TSD: Inventory, 292061187 TSD: Orders, 320602113 MuleSoft Integration — Open Questions for SFCC/PWA Design, 330235905 Global-e Open Questions
- 305659907 — Mulesoft API Spec - Hub — **empty stub, no content**
- 307134467 — Integration Reconciliation — Working Doc (Pre-Jira) — draft, not yet reviewed
- 318472193 — Contentful CMS — Setup & Operations (under 05.2, not 05.3) — environment topology, locale table (9 locale codes), token scoping, content-type management, Human Setup Checklist (several items still incomplete)
- 310050860 — Dependencies (child of 309690396 2.5 PI 1 Planning) — technical dependency tracker; rows T1 (Contentful CMS Readiness) and T2 (SFCC MRT API Capabilities) exist but SME Owner/Status/Notes are all blank
