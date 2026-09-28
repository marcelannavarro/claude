---
name: project-spike-122-123-audit
description: "Confluence audit findings for Jira spikes SFCC-122 (MRT API Capabilities) and SFCC-123 (Contentful Integration TSD), done 2026-07-15"
metadata: 
  node_type: memory
  type: project
  originSessionId: ebdb86f8-4358-451a-b4b4-facd67197720
---

Audited the SFCC Confluence space for existing documentation/support for two assigned spikes. Full page inventory in [[reference-confluence-sfcc-space]]. Key findings:

**SFCC-122 (MRT API Capabilities):** No single canonical doc exists — the spike is genuinely needed, not duplicative. Closest existing material is "TSD: Catalogue Sync — SCAPI Admin API Design (Alternative Pattern)" (315490342), which documents SCAPI Admin APIs for Product/Inventory as an alternative to the recommended WebDAV file-based import. Critical finding baked into that doc: **no SCAPI Admin API exists for writing pricebook/price data** — price sync must always go through file-based WebDAV import regardless of pattern chosen. That doc's own Open Items (rate limits, bulk-operation support, Anypoint MQ sequencing) are still unanswered. "Mulesoft API Spec - Hub" (305659907) is a completely empty stub. Dependencies tracker row T2 "SFCC MRT API Capabilities" has blank SME Owner/Status.

**SFCC-123 (Contentful Integration TSD):** Strong head start already exists. "Contentful CMS — Setup & Operations" (318472193) covers environment topology, alias/release workflow, token scoping, and locale config (9 locale codes across 8 storefronts) — largely answers the spike's environment/locale tasks. "TSD: Product — SFCC Catalogue & Data Integration" (292061208) §6 already states the handoff boundary: Contentful owns only editorial content (banners/collection pages/lookbook/rich PDP copy) via Delivery API; all product/price/inventory data stays in SFCC via AP21→MuleSoft, never Contentful. That same TSD's Open Item #3 ("Define Contentful content model and connector customisation scope | Frontend Dev | Open") is effectively the same deliverable as SFCC-123 — worth cross-linking. Still genuinely open: Sprint 1/2 required content types beyond the current `shoppableImage`/`CollectionHero`/`ImageText` set, and which specific Contentful fields/rendering logic SFCC needs to consume. Several Human Setup Checklist items on the ops page are incomplete (MRT env vars per tier not set, cache-purge webhook not configured, content-type-editing roles not restricted, CI CMA token not added as a GH secret) — worth flagging as blockers per the spike's own task list.

**Discrepancy found:** Both Confluence locale tables (Contentful ops page and the Product TSD's multi-locale table) agree on 9 unique locale codes for the 8 storefronts (en, en-GB, en-US, fr, it, es, en-CH, en-HK, en-AE). This conflicts with AGENTS.md/testing.md's "11 active locales" figure for the same 8 storefronts — a real inconsistency that should be resolved as part of SFCC-123's locale task, since it affects Contentful locale bootstrap scope. Not yet raised with the user.

**Why:** these two spikes were the user's active assigned work as of 2026-07-15; both link to the Dependencies tracker (310050860) rows T1/T2, which are Sprint 1 blockers for Squad A.
**How to apply:** when picking this work back up, start from the specific pages named above rather than re-searching from scratch — they cover most of each spike's DoD already. Flag the locale-count discrepancy to the user before it gets baked into a finalized TSD.
