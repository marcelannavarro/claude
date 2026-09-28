---
name: project-sprint6-duplicate-stories
description: All three Sprint 6 stories Marcel was asked to point in Sep 2026 duplicate another live ticket; this is a systemic board problem, not three coincidences
metadata:
  type: project
---

Verified 2026-09-22. Each of the three stories handed to Marcel for estimation
overlaps another open ticket:

| Story | Overlaps | Evidence |
| --- | --- | --- |
| **SFCC-801** country-currency-selector (Squad-A, Sp6, 3pts) | **SFCC-688** "Regional Storefronts — Country & Language Selector" (Squad-A, Sp6, Tech design, unpointed) | SFCC-688 carries REG-020,021,022,023,**024**,025,**026**,**027** — a strict superset of SFCC-801's REG-020,021,022,023,025. |
| **SFCC-749** Breadcrumb and SEO (Squad-A, epic SFCC-3, Sp6, 5pts) | **SFCC-578, 95, 577, 579, 573** (all Squad-B, epic SFCC-22) | See [[project-seo-epic-duplication]]. |
| **SFCC-874** Card Group with Lookbook (Sp6) | **SFCC-887** and **SFCC-920** — two competing Contentful stories for one component, with contradictory `cardType` models (group-level vs per-slot) | Confluence 04.71 mandates exactly one Contentful story per component. |

Context that makes this predictable rather than random: **17 of 34 tickets in epic
SFCC-2 are unpointed**, and Confluence 04.71's Level-1/Level-2 decomposition pattern
is only half-applied.

**The real dataset dependency for SFCC-801 is SFCC-49 "Country List Configuration"**
(Tim Lavelle, Sprint 6, Tech design, unpointed) — and it is only linked `relates to`,
not `blocks`, so it does not show as a blocker on the board.

**Why:** pointing these stories without resolving ownership first means two people
build the same thing, or one builds against an AC the other's ticket contradicts.

**How to apply:** before quoting a number on any Sprint 6 component story, search the
board for the same REG-/DMU-/SPR- requirement IDs on other tickets. Label overlap is
the fastest duplication detector on this board.

Related: [[project-seo-epic-duplication]], [[project-story-point-calibration]]
