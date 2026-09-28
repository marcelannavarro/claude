---
name: figma-signoff-status
description: "Which storefront feature areas have Figma designs signed off vs still draft — CORRECTED 2026-08-11: two trackers now exist at different granularity/currency, check both"
metadata: 
  node_type: memory
  type: project
  originSessionId: ef996bfd-f69c-4409-8ab6-757ed14dd8b6
  modified: 2026-08-11T03:20:38.062Z
---

**Two trackers now exist, at different granularity and currency — check both, don't rely on
just one:**

1. **04.2 Design Tracker** (Confluence 258801666, page-level/feature-area granularity).
   Re-read 2026-08-11: still last-edited exactly 2026-07-13 (untouched 29 days); its own intro
   text is stale too ("Phase 2... planned by mid-July", already passed). Current content:
   Cart & Search — **100% Pending/Pending, nothing signed off.** PDP — Images/Gallery/Product
   Info/Badges/Colour&Size/Complete the Look Signed Off; Accordions/Need Assistance
   done-but-pending; Measmerize/Price&Stock/More from the Edit/Recommended for You/Recently
   Viewed/SEO fully pending. **PLP — CORRECTED: all 5 rows (Product Tile, Quick Add & Wishlist
   Popovers, Breadcrumb, Filter/Sort/View More, Editorial Blocks) are Pending/Pending.** This
   contradicts this memory's own prior claim (preserved below) that "PLP core grid" was signed
   off as of the same 2026-07-13 date — that prior claim was an error from the original
   research pass, not a subsequent design regression; don't repeat it. Also: "Primary CTAs" row
   shows an internal inconsistency (status text "PENDING" but colour-flagged/marked "SIGNED
   OFF") plus a note that the Notify Me modal changed *after* sign-off (missing name fields +
   marketing checkbox + success screen) — treat as possibly stale vs. the live Figma file even
   where marked signed off.

2. **04.7 Component Inventory** (Confluence 400195591, v13, atomic-component granularity,
   linked to Figma "Zimmermann_Design_System_2026" node 40000730-13662) — **live/current as of
   2026-08-10**, the more actionable tracker for Sprint 3 (11–24 Aug, see
   [[project_real_sprint_cadence]]). Independent Status + "Sprint Planning" columns.
   Design-confirmed and tagged "Sprint 3 for User Story Writing": Banner+Pause/Play, Button,
   Icon Button, Footer+3 subcomponents, Disclaimer, Textfield, Dropdown, Link, Logo Masthead,
   Navigation, PDP Hero, Product Card Base+2 subcomponents, Product Card Group, Product Cards
   with Lookbook, Recently Viewed. Not yet ready: Checkbox & Radio, Navigation Expanded, Title
   and Link, Cart Item (module), Editorial Cards (module) (all "Not Confirmed"), Drawer
   ("Incomplete"). Templates: only Shell (Not Confirmed) and PDP (Done) exist — no
   Cart/Search/PLP/Checkout templates yet, consistent with #1's page-level pending status there.

**Why this matters for story-writing:** the **Definition of Ready** (Confluence 313589763)
states "Stories with UI components are not Ready without approved designs." Combined with the
two trackers: Level-2 page epics (and any Contentful-linked Level-1 story, see
[[project_story_decomposition_pattern]]) for Cart/Search/PLP are currently DoR-blocked;
PWA-Kit-only atomic Level-1 component stories are buildable now, gated only against tracker #2,
regardless of their parent page's tracker-#1 status.

**How to apply:** before starting UI implementation OR writing a story for any feature area,
check BOTH trackers for current status — don't assume either is authoritative alone, and don't
trust a memory snapshot (including this one) over a live re-check: tracker #1 has proven to
drift from casual re-reads even when literally unedited.

---
*(Superseded, kept for context only — do not cite as current):* Original 2026-07-15 pass
claimed, per the 04.2 tracker's 2026-07-13 snapshot, that Homepage, PLP core grid, global
nav/footer, most PDP components, and Payments/Notify-Me CTAs were Signed Off, while Cart,
Search, Checkout, Account, Wishlist, Gift Cards, Returns, Store Locator, and Zimmerse were
Draft/In Review/Pending. The "PLP core grid" part of that claim is now confirmed wrong (see
corrected section above) — likely a misread during the original pass, not a design regression.
