---
name: project-story-decomposition-pattern
description: "How the Zimmermann team breaks UI work into user stories — formalized 2026-08-11 in Confluence 04.71 (Level 1 component epics vs Level 2 page epics), not just Tim's informal precedent"
metadata: 
  node_type: memory
  type: project
  originSessionId: 99f4b8e9-fb3d-442e-86bf-b17f48bf5ed1
  modified: 2026-08-11T03:20:18.817Z
---

The team decomposes UI work as **component-based user stories**. As of 2026-08-11 this is
formally documented, not just informal precedent — see Confluence **"04.71 Writing User
Stories for Components"** (page 400195600, v2, brand new, zero comments; child of **"04.7
Component Inventory"**, page 400195591, v13, mapped 1:1 to Figma "Zimmermann_Design_System_2026").
Formal rule set:

- **Level 1 — Component epics** (the "build" story): PWA-Kit-only components (Button,
  Textfield, Dropdown, Cart Item) get **one** story in the PWA Kit epic. Contentful+PWA-Kit
  components (Banner, Editorial Cards, Footer, Navigation) get **two** stories — one in the
  Contentful epic (content model/authoring/validation), one in PWA Kit (rendering) — "a
  Contentful component always needs a PWA Kit story too; a PWA-Kit-only component does not
  need a Contentful story."
- **Level 2 — Page epics** (the "experience" story, e.g. PDP/PLP/Checkout): shopper-perspective,
  how components work together on that page; must NOT repeat Level-1 build detail.
- Doesn't explicitly address SFCC-commerce-data-sourced components (vs. Contentful) — per
  components.md's container/presentational rule these should default to "PWA Kit only" since
  SFCC is an API contract, not editorially authored content — but confirm this reading rather
  than assuming it.

**Epic structure corrected:** the components epic is **SFCC-2 "PWA Kit Components"** (status
To Do; "the shared UI component library... consumed across all frontend epics," page-level
build carved into separate epics) — NOT SFCC-1, which is "Platform Setup & Environments" and
unrelated. Page epics: SFCC-5 PDP, SFCC-6 PLP, SFCC-7 Search & Recommendations, SFCC-11 Cart,
SFCC-19 Regional Storefronts.

**The pattern is already the dominant real-world shape, not aspirational** — confirmed across
Cart (SFCC-11, 20 stories), PLP (SFCC-6, 17), PDP (SFCC-5, 18), Search (SFCC-7, 19): nearly
every story is a single component/feature slice. Live examples: filters = SFCC-104 (BM config,
shared) → SFCC-108 (Search filter UI component) → SFCC-199 (PLP integration, Ready For Review);
Recently Viewed = SFCC-83 (shared component, Tech design, 3 SP) with consent peeled out into
SFCC-106; SFCC-195 (PDP "Details & Care" slide-out tab, Ready For Review) slices only one tab —
siblings SFCC-102/267/266/101 cover the other tabs separately.

**Surviving old-style broad stories** (good "before" examples to raise at the meeting):
SFCC-90 "Homepage Layout & Content Modules UI" (5 SP, In Refinement) bundles 6 distinct content
modules into one ticket with no sub-split. SFCC-52 "Global Header UI" / SFCC-55 "Global Footer
UI" (3 SP each, Ready for Development) are partially decomposed — self-limited to "shell and
layout only" with icon destinations/link wiring/Omneo integration carved out — but still bundle
multiple components per ticket.

**Live worked examples, seeded the morning of 2026-08-11** (hours before a "components ways of
working" meeting) by Isabel "Izzy" Chaloner (Delivery Lead), all parented under SFCC-2:
SFCC-691/692/694 (Title and Link Component × PWA Kit / Contentful / PDP) and SFCC-698/699/700
(Editorial Cards Module × Contentful / PWA Kit / PLP). Both source components are deliberately
from the design-system inventory's "Not Confirmed" rows — teaching examples, not committed work.
Note: the "— PDP"/"— PLP" (Level-2-shaped) variants are reportedly ALSO parented under SFCC-2
rather than SFCC-5/SFCC-6 — worth confirming whether that's intentional or simplified for
illustration only.

An earlier, rougher precursor predates the formal doc: SFCC-648 "pdp/size-selector" and SFCC-650
"pdp/add-to-bag" (created 2026-08-07 by Jasmijn Tsang, Lead BA, under SFCC-2), lowercase
code-path-style titles, splitting the bundled SFCC-92 "PDP — Size Selection & Add to Bag"
(Blocked, 5 SP) into atomic pieces.

My reusable heuristic for cutting a UI story (worked example: SFCC-195 PDP accordion,
2026-08-07) — still holds, now reinforced by 04.71:
1. **Slice by data source, not by UI surface** (one story per tab is the wrong cut). Group
   tabs/sections that share a data path (SFCC attr / Contentful / AP21).
2. **Split again where risk/readiness differs** — unconfirmed attribute, unauthored content,
   unbuilt integration.
3. **Every story a vertical slice** — give a "shell"/enabler story a real first slice so it's
   demoable, never a horizontal orphan.
4. **Quarantine later-sprint / other-squad work** (AGENTS.md Hard Rule #14) — carve it out as a
   deferred dependency and design the current build to **degrade gracefully** ("renders now,
   wired later"). Example: PDP Assistance tab's "Start a Chat" → Inside Chat is Squad B /
   Sprint 7, consent-gated (Didomi) — keep Assistance bundled with Shipping & Returns and defer
   only the chat trigger.
5. **Offer sub-tasks, not more stories,** when a BA wants finer granularity.
6. **Check the ticket against source-of-truth docs** — flag anything it assumes that the PRD
   still lists as open (e.g. `.docs/temp/openItems.md` #2: SFCC-vs-Contentful ownership on
   composed PDP/PLP pages is still unconfirmed — this directly blocks cleanly deciding some
   Level-1 "which epic(s) does this need a story in" calls for composed-page components).

Full write-up previously referenced as `learning/2026-08-07-user-story-breakdown.md` **no
longer exists on disk** (checked 2026-08-11, both `./learning/` and `./.docs/learning/` are
empty) — don't cite it as available; this memory file is the source of truth instead.

Related: [[project_usintl_status]], [[user_role]], [[project_real_sprint_cadence]],
[[project_figma_signoff_status]], [[reference_confluence_sfcc]].
