---
name: project-story-point-calibration
description: The SFCC board's actual Fibonacci calibration ladder derived from shipped work, plus the Story+Development-Task split Hazel introduced 2026-09-21
metadata:
  type: project
---

Derived 2026-09-22 from shipped tickets, since no written estimation guide exists
in Confluence. Scale in use is Fibonacci: 1, 2, 3, 5, 8, 13.

**3 — a single self-contained component, reusing existing shell/atoms**
`global/country-language-mismatch` (SFCC-831), `Logo Masthead` (747),
`pdp/hero` (723), `searchfield` (818), `search-open` (819),
`search/suggestion-list` (845), `filter-and-sort` (846),
`EU Language Mismatch Modal` (689).

**5 — drawers / slide-outs, and multi-state UI surfaces**
`pdp/drawer` (736), `drawer/content/filters` (847), `Size Guide slide-out` (1023),
`Details & Care slide-out` (195), `Find in Boutique slide-in` (297),
`search/section-header-container` (820), `Search Results Page UI` (114),
`Filters & Facets UI` (108).

**8 — shared global components, usually multi-surface or PWA+Contentful**
`Product Card Shared Component` (236), `Footer – PWA Kit` (750),
`Navigation – PWA Kit & Contentful` (746), `Expanded Navigation` (96),
`PDP Product Image Gallery` (186), `pdp/gallery: Development` (913).

**13 — one instance only:** `Global Header UI` (SFCC-52).

**Reality check on the 3s.** SFCC-831 was pointed 3 and took ~24 commits over
2026-09-12→09-20, pulling in ZimmDrawer changes, a Contentful uiCopy seeding
pipeline and a CodeRabbit rework round — then still produced defect SFCC-1013.
Treat a 3 on a `global/*` drawer as optimistic unless the shell already exists.

**Story + Development-Task split (from ~2026-09-07, bulk-applied 2026-09-21).**
Hazel now creates a companion Task named `<Story name>: Development` as a sibling
child of the same epic, and the pair carries points separately — on 2026-09-21 the
seven Cart stories were cut 2–3 → 1 each and given 2-point Development tasks.
Development-task points are *not* fixed at 2 (SFCC-913 = 8, SFCC-1023 = 5,
SFCC-916 = 3). Before quoting any story-level number, check whether a companion
Development task exists, because the number means different things either way.

Related: [[project-story-point-ownership]], [[project-real-sprint-cadence]]

## Contentful content-type sub-ladder (verified 2026-09-22)

A Contentful *schema* story is a **1–2**, not a 3. The deliverable is one ~40-line file in
`scripts/contentful/content-types/` (all 10 existing types total 457 lines, 23–76 each),
and `useContentfulEntries(contentType, preview, locale, filter)` already supports
per-field filtering and locale, so there is no hook work.

| Ticket | Points | What it actually bought |
| --- | --- | --- |
| SFCC-117 Footer — Contentful Component | **1** | the content type alone |
| SFCC-835 Icon and Text — Contentful Component Model | **2** | *two* content types + TS types |
| SFCC-836 Icon and Text — PWA Kit Component | 2 | the PWA half of that pair |
| SFCC-912 Footer — Contentful Component: **Development & Testing** | 3 | the Dev-task half of SFCC-117, wider scope than schema |

**Do not anchor a schema story on SFCC-912's 3** — 117 and 912 are a Story(1)+DevTask(3)
pair for the same footer work, so 912 is not a standalone content-type comparable.

Related: [[project-contentful-env-state]]
