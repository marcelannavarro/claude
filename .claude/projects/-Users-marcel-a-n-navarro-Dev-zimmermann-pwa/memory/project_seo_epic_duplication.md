---
name: project-seo-epic-duplication
description: SFCC-749 (Squad-A, Sprint 6) overlaps five Squad-B tickets in epic SFCC-22, and its AC contradicts three confirmed PRD lines
metadata:
  type: project
---

Verified 2026-09-22. **SFCC-749 "Breadcrumb and SEO – PWA Kit Component"** (Squad-A,
epic SFCC-3 Navigation, Sprint 6, 5 pts) duplicates work already scoped to **Squad-B
in epic SFCC-22 "SEO & Analytics & A/B Testing"**:

| Squad-B ticket | Covers |
| --- | --- |
| SFCC-578 | SEO — Breadcrumb Component (PLP & PDP). Unassigned, no points. |
| SFCC-95 | Read More SEO Text Block & Conditional Background. Bianca Morley, `DesignDependent`. |
| SFCC-577 | PLP SEO Copy Content Field (CMS-Editable, **BM-Configurable**). |
| SFCC-579 | Shop By Keyword Tag Links in SEO Copy Accordion. |
| SFCC-573 | CollectionPage, BreadcrumbList & ItemList Schema (PLP). |

Per Confluence 04.72, epic SFCC-22's stories are not dev-ready until **2 Nov,
Sprint 7/8** — so Squad-A is scheduled to build in Sprint 6 what Squad-B is
scheduled to build in Sprint 7/8.

**SFCC-749's AC contradicts three confirmed PRD lines**, all quotable:
- `.docs/prd/plp.md:18` (Confirmed 2026-05-08): *"read more expand action (**not
  collapsible** — confirmed per 24.06 design review); **positioned below YMAL /
  Recently Viewed**"* and *"Configurable title, description, and hero image per
  category page **via Business Manager**"*. The AC mandates READ LESS, places the
  block above the footer next to the breadcrumb, and sources it from Contentful.
- `.docs/prd/dataMigrationSeo.md:57` (DMU-035): *"**SEO rules and attributes will
  live in SFCC per storefront** (not Contentful)"*.

Also: the base PWA Kit breadcrumb **already renders in production today**, unstyled,
via `overrides/app/components/product-view/index.tsx:349` and the base `page-header`
on PLP. So this is restyle-and-relocate with three call sites to reconcile, not a
greenfield build.

**Why:** the story looks sizeable and is marked Ready for Development, but committing
it means two squads building the same component and building against an AC that
contradicts a confirmed PRD.

**How to apply:** don't accept SFCC-749's 5 points at face value. Resolve ownership
vs SFCC-578/95 and the Contentful-vs-BM question first.

Related: [[project-story-point-calibration]], [[project-story-point-ownership]]
