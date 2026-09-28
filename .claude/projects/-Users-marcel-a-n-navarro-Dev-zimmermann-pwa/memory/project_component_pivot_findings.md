---
name: project-component-pivot-findings
description: "Verified findings from the 2026-08-11 'Executive Readout' meeting on the component-driven delivery pivot — spike status, Navigation epic split, regional selectors, component-reuse gap"
metadata: 
  node_type: memory
  type: project
  modified: 2026-08-11T11:02:06.304Z
  originSessionId: ca118e83-50ee-4df0-a734-d83474ec83ec
---

An exec-level "Executive Readout" meeting on 2026-08-11 discussed restructuring the whole
project plan around component-first delivery (vs. page-first), with the user ("Angelo" =
Marcel Angelo Navarro, FED Lead) positioned as validating frontend execution feasibility. No
Confluence page documents this meeting itself (checked "Executive Readout"/"Steering"/"Program
Update"/etc. — nothing found); its decisions exist only in notes relayed to Claude, and neither
squad's Sprint 3 Confluence page (see [[project_real_sprint_cadence]]) reflects it yet (both
still Status NOT STARTED / Goal TBD) — worth someone writing this back before it evaporates.

**Figma-to-React spike (SFCC-240) — status more nuanced than the meeting framing suggested.**
Actually marked **Done**, transitioned 2026-08-11 (same day as the meeting). Its Sprint field
was set once to Sprint 2 on 2026-07-27 and never reassigned — so "targeted for end of Sprint 3"
(what the meeting notes said) doesn't match Jira; it landed right at the Sprint 2/3 boundary,
not a Sprint 3 deliverable. Real completed work per its closing comment: a `/sync-design-tokens`
and `/convert-to-uikit` pipeline. Real **pending** items, explicitly listed in that same
comment: (1) the new skills/rules need PR review from both squad leads + Integration lead since
they touch Tier 1 files (`.claude/rules/`, `.claude/settings.json`); (2) an ongoing, continuous
designer-sync loop; (3) a proposed Handover gate awaiting formal lead approval. **Could not
independently verify the actual diff** — searched all local/remote branches and PRs in this
repo for anything matching the spike (figma-to-react, sync-design-tokens, convert-to-uikit) and
found nothing; the artifact isn't located anywhere checkable from this repo. Given it touches
governance-critical Tier 1 config and a routine safety scan flagged instruction-shaped content
while researching this ticket (neutralized, nothing acted on, likely just the ticket's own
description of its config changes) — **look at the actual proposed diff directly before
approving**, don't take "Done" + ticket-text description at face value.

**Navigation epic split is half-done, not complete as the meeting implied.** SFCC-701
"Homepage" (new epic, created 2026-08-11 by Izzy Chaloner, To Do) explicitly excludes
"Header, footer, megamenu — covered in Navigation epic." But **no standalone Navigation epic
exists yet** — that content is still sitting in the old, unchanged, still-open **SFCC-3
"Homepage & Navigation"** (In Progress since 2026-06-11). So only the Homepage half of the
split has actually happened in Jira. Separately, SFCC-90 "Homepage Layout & Content Modules UI"
(still In Refinement, unchanged since 2026-07-14) was checked across its full changelog and has
**never** included navigation/header/footer/menu content at any revision — nothing needed
trimming there despite the meeting's cleanup framing.

**Regional Storefront selectors — Kiera's claim partially holds, with a duplication risk.**
**SFCC-688** "Regional Storefronts — Country & Currency Selector and Country Mismatch" (To Do,
Jasmijn Tsang, created 2026-08-11) is the closest match to "Country Selector," but folds
language into the same story rather than a distinct Language Selector — **no standalone
Language Selector ticket exists anywhere in the project.** SFCC-689 "EU Language Mismatch
Modal" is a different thing (a warning modal, not a selector). Three tickets covering similar
ground are open simultaneously: SFCC-79 "Global Header - Country/Region Selector" (created
Jun 19), SFCC-467 "Country/Currency Selector — PWA Component" (created Aug 5), and SFCC-688
(today) — not confirmed duplicates, but worth reconciling before a fourth gets created. None of
Country/Language/Currency Selector appear in 04.7 Component Inventory at all — untracked for
design-readiness, a real gap in the tool meant to gate Sprint 3 story-writing.

**The shared-component-reuse mapping gap Tim raised is real — but the data to fix it already
exists, just not synced.** Confirmed: 04.7's "Pages" column for Product Card Base/Group/
Lookbook (and Recently Viewed, PDP Hero, Image Gallery, Product Content) lists **only "PDP"**
everywhere — it's a single-owning-page field, not a reuse map, and the page has no Owner column
at all (matches the meeting's "no owner assigned" claim) and zero comments (nobody, including
Tim, has engaged with it). But **SFCC-236 "Product Card Shared Component"** (Ready For Review,
created 2026-07-24) already documents the real cross-page reuse Tim's asking for — "Variations
in scope: Homepage, PLP, Wish List, Recently Viewed" — it just hasn't been reflected back into
04.7. **This is a low-effort, concrete fix** (sync SFCC-236's info into 04.7's Pages column)
rather than a build-new-tooling problem — worth offering to do or delegate rather than treating
it as unsolved.

Related: [[project_real_sprint_cadence]], [[project_story_decomposition_pattern]],
[[project_figma_signoff_status]], [[user_role]].
