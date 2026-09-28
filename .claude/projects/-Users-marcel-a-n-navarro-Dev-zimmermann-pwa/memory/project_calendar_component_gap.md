---
name: project-calendar-component-gap
description: "No out-of-the-box calendar/date-picker exists anywhere — not in code/Jira/Confluence, not in Chakra 2.7.0, not in the base retail-react-app template; the Figma screen showing a date+time booking calendar doesn't match any currently-scoped feature"
metadata: 
  node_type: memory
  type: project
  modified: 2026-08-11T06:10:45.181Z
  originSessionId: 0f890293-1d3d-4726-bb0d-646b77d58f77
---

**Triggered by:** Kiera asking the user ("Angelo" — Marcel Angelo Navarro) whether an "out of
the box" calendar solution was decided for a Figma screen (file "Zimmermann_Designs", node-id
3193-47937) showing "CHOOSE A DATE" (month calendar grid) + "AVAILABLE TIMES" (time-slot
buttons) + "CONTINUE", filed under a "Find in Boutique" Figma page/layer grouping.

**Clean negative result, checked across all four surfaces:** no calendar/date-picker npm
package is installed (`package.json`), no calendar code exists anywhere in `overrides/`, no
Jira ticket names a library (react-day-picker/react-datepicker/react-calendar/flatpickr/
react-dates all zero hits, full-text across summary+description+comments), and no Confluence
page discusses one either. **04.7 Component Inventory** (400195591, the design-system
catalogue) has no Calendar/DatePicker entry at all. Nobody has written this decision down
anywhere the team keeps records — if Kiera/Angelo discussed it, it never made it past verbal/
Slack.

**The screen doesn't match "Find in Boutique" as currently scoped — confirmed at the API level,
not just PRD prose.** Find in Boutique's actual MuleSoft contract (Confluence "Find In Store —
Boutique Stock Availability" TSD, id 292487173) is literally `{ProductId, CountryCode} →
[{StoreId, qty}]` — no date/time field exists in the integration at all. Every PRD source
(pdp.md §8, cart.md §7, orderManagement.md, Jira SFCC-297/308/458/307) agrees: it's a
location-search + geolocation + per-boutique stock/hours/maps flyout, nothing else.

**What the screen most likely actually is: Booxi appointment booking — but that's scoped
read-only history only, not self-service booking.** CRM-165/166/167 (Confirmed) cover only
displaying appointment *history* in My Account (Jira: SFCC-72 "Booxi Appointment History
Integration," description literally "Placeholder story"; SFCC-626 "My Account – Services Page
Layout" describes a "Book an Appointment" link that just *routes to Booxi* externally).
**The only currently-documented booking mechanism at all is a human handoff**: Confluence
"Store Details" register (258441217), **INT-027 Inside Chat** — "Live chat widget available on
Store Detail page for click-and-collect queries and boutique appointment booking" (Status:
Under Review) — not a self-service calendar. The whole Loyalty & Appointments design area is
Phase 2, tracker status PENDING/PENDING, no Figma link populated in the tracker at all.

**Most likely explanation (inference, not confirmed by any source):** the Figma file probably
groups this screen under "Find in Boutique" by *UI pattern* (both are boutique-related side-out
panels) rather than by requirement/epic — i.e. it's a design-file IA artifact, not evidence that
booking is now in scope. Worth confirming directly with whoever owns the Figma file / Booxi
scope rather than assuming either way.

**Confirmed 2026-08-11 it's not a Zimmermann-specific oversight either — the underlying stack
has no calendar solution at any layer.** Checked `node_modules` directly: Chakra UI 2.7.0 is
installed (transitively via `@salesforce/retail-react-app`, not a direct top-level dependency)
and has **no Calendar/DatePicker package among its ~70 `@chakra-ui/*` sub-packages** — Chakra
has never shipped one natively, by design (confirmed by direct inspection, not assumption).
`date-fns` is present (transitive, formatting only). The base `@salesforce/retail-react-app`
template itself — Salesforce's own reference storefront — has zero calendar-related code or
dependency anywhere in its source or `package.json` either, per user-provided reference docs
`~/Dev/pwa-kit-overview.md` and `~/Dev/pwa-kit-special-components.md` (the latter confirms
`ChakraProvider` is wired into the `AppConfig` special component — overridden here at
`overrides/app/components/_app-config/index.tsx` — as the sole source of theming/component
system; neither doc mentions a calendar special component). **So whatever gets used here will
be a genuinely new decision** — either a new npm dependency (needs integration-team approval
per AGENTS.md Hard Rule #7 — common Chakra-ecosystem options: `react-day-picker`,
`chakra-dayzed-datepicker`, react-aria's `Calendar`/`DateField`) or a custom Chakra-primitives
build — not a "did we miss an existing option" gap.

**Related, smaller data point:** the only other confirmed calendar requirement in the entire
project is the gift-card delivery date picker (GC-005/GC-006, Jira SFCC-386, date-only, no time
slots, "restrict to 3 months, grey out beyond"). It **also** has zero library/technical
decision on record and its own Design Tracker row is Pending/Pending — so even the one calendar
UI the project does confirm hasn't had a "how do we build this" conversation captured anywhere
either. If a library ever does get chosen, GC-005/006 is the natural first place to apply it,
and reuse it for any future boutique-booking calendar too.

**How to apply:** don't tell a colleague a library was "already decided" — it wasn't, anywhere.
If in-storefront Booxi booking scope gets confirmed later (superseding INT-027's chat-handoff
plan), this is the first place to record which calendar library gets chosen, since nothing
currently exists to point to.

**Update 2026-08-11 — the screen is actually "Find in Boutique → Book a Fitting" (per the
frontend lead directly), and this is exhaustively confirmed undocumented anywhere.** A
second, deeper research pass (local grep + full Confluence/Jira sweep including Jira's
separate Acceptance-Criteria custom field and synonym variants) found **zero mentions of
"fitting"/"Book a Fitting" anywhere** — not one page, ticket, or AC field, under any phrasing.
"Find in Boutique" itself is re-confirmed, now even more exhaustively, as stock-check-only
across all three tickets that implement it (SFCC-297 PDP panel, SFCC-308 real-time stock,
SFCC-458 buffer-stock exclusion) — none has a calendar, time slot, booking step, or
signed-in-customer display in its Acceptance Criteria.

**Closest existing relative in the backlog: "Personal Styling → Book an Appointment"**
(epic SFCC-16, stories SFCC-72/626, plus SFCC-525 on the Store Detail page) — but this lives
under **My Account** and **Store Detail**, not PDP/Find in Boutique, and every instance
describes a CTA that **routes externally** to Booxi/Booksy rather than an embedded
calendar+time-slot+Continue UI. SFCC-16 explicitly flags the whole Appointments section as
"TBC"; SFCC-626 and SFCC-525 both have **zero Acceptance Criteria written**.

**The Booxi/Booksy naming split may be more than a typo — treat as genuinely unresolved, not
settled.** "Booksy" (CRM-165/166, Third Party Integrations, epic SFCC-16 itself) and "Booxi"
(Third Party Overview, TSD, SFCC-72/626, and Confluence's "04.6 Consent Management — Business
Overview" — the one place describing it as "**boutique appointment booking | Required |
Functional booking tool**," not just history) are used inconsistently across both Confluence
and Jira, with no page/ticket reconciling them. An earlier pass recorded "TT confirmed Booxi,
Booksy is the typo" — that likely still holds (Booxi is a retail/luxury clienteling platform,
a natural fit for a fashion brand; Booksy is a mass-market salon/beauty booking app, a poor
fit) — but it has evidently never been corrected consistently, so don't assume it's fully
settled without asking. This doesn't change the earlier Booxi Booking Widget research (still
the most likely candidate "out of the box" answer if in-storefront booking is real), but the
naming ambiguity itself is worth surfacing.

**People, now confirmed:**
- **Charmaine Lew** (`charmaine.lew@accenture.com`) — Product Designer, Accenture, Melbourne,
  works across both squads ("Squad Oversight"). Actively engaged on PDP-adjacent design calls
  in Jira around the same time as her Figma sticky note (subtasks dated 2026-07-21, note dated
  ~2026-07-30): accordion behaviour (SFCC-207), error messaging (SFCC-211), chat placement
  (SFCC-208). A credible, legitimate source — her "Dev team to confirm Out of the box calendar"
  note reflects a genuine open question, not confusion on her part.
- **Kiera Rikard-Bell** (`kiera.rikard-bell@accenture.com`) — real Accenture person, confirmed
  resolvable in both Confluence and Jira user directories, but **zero formal footprint** in
  either (no roster entry, no assignee/reporter role, no authored page). Referenced only
  informally as someone the team consults for UX judgment calls: SFCC-255 (size-selector
  recommendation wording) and SFCC-236 (product-card behaviour on Recently Viewed) — both
  unrelated to fitting/Booxi/calendars. Her actual role/seniority can't be pinned down from
  these systems — genuinely unknown, not worth guessing.

**Highest-value next step, more true now than before:** the Figma comment thread on this exact
screen (Charmaine's note, ~2026-07-30, tagging Kiera + the user, **1 reply already posted**)
is now confirmed to likely be the *only* record of this decision anywhere — Jira and
Confluence have both been exhaustively searched and come back empty. Reading that reply
directly is worth more than further repo/Jira/Confluence digging at this point.

**Update 2026-08-11 (MS Copilot sweep of Teams/Outlook) — the single most valuable finding of
the whole investigation, and it changes the bottom line.** Per a Teams thread in "ZIMM - PM/BA
Team", **Friday 7 Aug 2026** (Tim Lavelle, Jasmijn Tsang, Isabel Chaloner):
- Tim Lavelle: "Do you know where I can view the book an appointment functionality on the zimm
  site?" → Jasmijn Tsang: "I dont think you can today right? Design's for future scope I
  think" → **Isabel Chaloner: "Noo, booking appointments was agreed in scope for go-live via
  Booxi. They were supposed to go live on Magento before, but Emma has now told me that it
  won't be live on Magento. They don't currently seem to have clear timelines on this, and
  sitting with marketing team."** → Tim Lavelle: "Right, ok - we'll need to have a session with
  Booxi on implementation approach. I will send an email."

**This confirms in-storefront Booxi booking (not just history) IS agreed in scope for
go-live** — more definite than Confluence/Jira's "TBC" framing. But **the implementation
approach (widget vs. custom UI vs. API) was explicitly still unresolved as of 7 Aug**, four
days before Kiera's question — Tim was arranging a dedicated session with Booxi specifically
to settle it. No record of that session happening, or of Tim's promised follow-up email,
turned up anywhere Copilot could search. **So Kiera's question is a genuinely live, unanswered
open question as of today, not something anyone dropped the ball on.**

**People — corrected/completed via Copilot (Teams/Outlook directory, more current than
Confluence/Jira rosters):**
- **Charmaine Lew** — title is **Visual Design Manager** (Melbourne), not "Product Designer" as
  Confluence's roster listed — a more senior title; same person, same design authority.
- **Kiera Rikard-Bell** — **Digital Product Design Specialist**, based in **Canberra** (resolves
  the "role unknown" gap from the Confluence/Jira pass). She's an **attendee of today's "[Sprint
  3] Components, components, components" meeting** (11:00 AM, organiser Natasha Lay/Tash —
  the same meeting from earlier in this session — alongside Tim Lavelle, Isabel Chaloner,
  Bianca Morley, Jasmijn Tsang, and the user). Very likely why she asked today: probably
  chasing context ahead of/around that meeting, not out of the blue.

**Booxi vs. Booksy — now definitively resolved, and a real contract-level issue found.** Hardi
Sempuno corrected this explicitly in Teams on **27 May 2026**: *"'Booksy' → 'Booxi'. Wrong
vendor name (Booxi is the appointments platform; Booksy is unrelated). Ref: account.md
CRM-165."* So Booxi is confirmed correct, Booksy confirmed wrong — but **the error was never
fully corrected and persists in the signed SOW** ("2026.07.21 - Zimmermann x Accenture -
Implementation SOW - Execution copy.docx"), which lists "Booksy" among **out-of-scope
third-party vendors for build/configuration** — meaning Accenture builds the PWA-side
integration to the vendor's endpoint but does **not** configure the vendor's own platform
(so if the widget-embed path is chosen, wiring it in is dev work, but configuring Booxi itself
— business hours, staff, availability rules — is Zimmermann's own responsibility, not this
team's). Worth flagging as a genuine, if minor, contract-hygiene issue, separate from the
calendar question itself.

**Other confirmed, consistent with everything above:** a 9 Jul Teams message (Jasmijn Tsang)
already flagged Booxi missing from the Confluence integration register — Hardi Sempuno replied
"It is in my TSD (just FYI)," implying a more detailed Hardi-authored Booxi TSD may exist
outside Confluence (not yet located). Isabel Chaloner was chasing Booxi API/vendor docs as of
22 Jun. No Teams/Outlook message anywhere names a specific calendar library or the Booxi
Booking Widget as a chosen approach — full alignment with the Jira/Confluence findings above.
Figma comment-reply content (including the "1 reply" on this exact screen) does not reliably
reach Outlook/Teams at all — confirmed by Copilot finding only an unrelated 23 Jul Figma-comment
email (a 32px margin note, different file: "Zimmermann_Design_System_2026") — so opening Figma
directly remains the only way to see that reply.

Related: [[reference_confluence_sfcc]], [[project_real_sprint_cadence]].
