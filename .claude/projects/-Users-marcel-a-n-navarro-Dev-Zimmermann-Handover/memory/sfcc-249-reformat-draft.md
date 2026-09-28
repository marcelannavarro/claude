---
name: sfcc-249-reformat-draft
description: "SFCC-249 Contentful TSD, PUBLISHED to Confluence page 346783750 as v31 (01 Aug 2026), now at v42 after a comment-driven refinement round with Tim Lavelle; pending BA-Lead + SA sign-off. Local mirror + extracted drift-risk content on Marcel's Desktop"
metadata: 
  node_type: memory
  type: project
  originSessionId: 01fb0dfa-fa41-471c-88f9-4d3bc8b4a857
  modified: 2026-08-04T09:57:07.458Z
---

The Contentful Integration TSD (source Confluence **346783750 v30**) was restructured into the prescribed 8-section TSD template (Confluence **352419841**) and **PUBLISHED to Confluence page 346783750 as v31** on 01 Aug 2026 (updated in place, replacing v30; v30 retained in the page's Confluence version history; page title kept as "Contentful Integration Technical Design & Content Model (SFCC-249)"). Local mirror at `~/Desktop/SFCC-249-contentful-integration-tsd-REFORMAT-DRAFT.md`. Approach = best-fit "Option 2": template spine §1-8 clean, ticket-required breadth in Appendices A/B/C.

**Scope guardrails held (per Marcel's explicit boundary):** no PWA TSD §12.1 edit (linked, not restated); no Jira cards raised; owner-pending items captured in §7, not resolved. Only in-lane decisions made: the counts and the Studio-vs-coded rule.

**Substantive changes beyond a reformat (all validated against source):** corrected the preview-token boundary to the decided **client-side Live Preview** design (per PR #41/#43 + `.docs/integration/02-contentful.md`); reconciled locale/storefront counts; scoped the SFCC-ID pattern as the single **Option A** (page-scoping) and routed reference-resolution to **SFCC-238**; established the **Studio Experiences vs coded-component** authoring rule (§5.5); flagged doc inconsistencies (CMA-token; CPA server-vs-client) in §7.

**Key verified facts baked in (2 recursive V&V rounds, 4 audit agents + mechanical passes):**
- **Counts:** 8 storefronts = 8 SFCC sites at target (1:1); **7 SFCC sites wired today**, US-International pending as a **separate** site `ZimmermannUSIntl` (currently a filtered-out stub in `countries.ts`, no locale assigned — may add a 10th Contentful locale when wired). EU-domestic's one SFCC site serves 4 language routes, so routes(11) > sites(8). **9 Contentful locales** (`en,en-US,en-GB,fr,it,es,en-CH,en-HK,en-AE`); 11 storefront-locale routes (10 wired). PWA TSD 256835585 + Product TSD 292061208 already count 8 SFCC sites. (Round-1 wrongly claimed US-dom+intl share one site → 7; round-2 corrected it. See [[sfcc-123]].)
- **Code state:** SFCC-ID fields (`sfccCategoryId`/`sfccProductId`) NOT in code (proposed). `useContentful.ts` = client-side REST `include=2`; SSR-first/GraphQL/webhook receiver NOT built. SDK `contentful@11.12.4` axios-based (`CreateClientParams` has httpsAgent/httpAgent/adapter, NO dispatcher). `connectionPools.ts` = 7 undici pools, defined-but-unwired, no Contentful pool. CPA token client-side per PR #43 (OPEN, base `develop`); PR #41 CLOSED (Marcel raised CPA, mani060689 ruled "intentional by design"). Both #3 spikes (PLP pagination; PDP accordion mixed-content) genuinely UNCARDED.

**Credit:** Marcel Angelo Navarro = reformat author + technical review + validation + open-item triage; Jhoan Rose Dela Cruz = original spike draft (SFCC-123). Version History itemises the substantive work ("technical review and restructure, not only a reformat"). Sign-off = **Jasmijn Tsang (BA Lead) + Tim Lavelle (SA)**, both Pending. Document Information = exactly the template's 7 fields (no Contributors row).

**Status (01 Aug 2026): PUBLISHED as page 346783750 v31.** V&V-converged (2 recursive rounds); template-conformant (only deviation = the intentional Appendices breadth). Page content Status = "Draft - for review, not approved for implementation"; sign-off (Jasmijn Tsang BA Lead + Tim Lavelle SA) still **Pending**. SFCC-249 is in **Code Review**; its DoD = review + feedback + BA-Lead/SA sign-off (reformatting itself was not a ticket requirement). **Caveats from publishing in place:** (a) updating the body may have marked some of Jhoan's inline comments on the page as "outdated" (their anchored text changed); (b) the planned one-line heads-up to Tim on the shape was NOT sent first — Marcel published directly. Next: BA-Lead + SA review/sign-off; the §7 open items remain owner-pending (not ours to close).

**Process files (not loaded at session start):** `~/.claude/plans/if-we-execute-the-compressed-honey.md` (reformat plan + full 16-item concern triage with dispositions) and `~/.claude/plans/this-decision-log-is-parsed-dusk.md` (trimmed 5-decision record + execution notes).

**Post-publish comment-driven refinement round (04 Aug 2026), page now at v42:** Working through Tim Lavelle's inline review comments one at a time. Resolved so far: the 10th-locale ambiguity (clarified as genuinely undecided, `en-CA` a plausible not-confirmed candidate, tied to `.docs/planning/regionalConfigSyncPlan.md`); the SSR-cache-keys and centralized-filtering-logic cons bullets in §3.1 (tightened wording, grounded in the `01-sfcc.md:93` cache-key precedent); and Tim's 3 flagged **drift-risk rows, all removed**:
- §2.2 Assumptions: the Sprint-2 field-sets row.
- §5.2 Component/API Changes: the sfccCategoryId/sfccProductId field-definition row, and the one-component-per-content-type row.

Each removal got a posted Confluence reply of the form "agreed, this is a drift risk, removing this row." **The removed content is not lost**: it still exists in-document (Sprint-2 caveat survives independently in Appendix C's own header, §7, and §8; SFCC-ID field defs survive in §5.3; the one-component rule survives in §5.5) **and** is separately extracted to two local files for centralized tracking, not published, not pointed to from the TSD:
- `~/Desktop/SFCC-249-component-content-model-reference-LOCAL.md`
- `~/Desktop/SFCC-249-content-model-STAGING.md`

These two files overlap almost entirely (same Sprint-2 table, same field defs) and should be consolidated into one when there's time; the STAGING file's own header still says "the TSD now points here", that line is stale, no pointer was ever added to the TSD, extraction-as-a-published-destination was explicitly ruled out as infeasible (no live page to point to, wouldn't even solve the clogging problem).

**Known gaps this removal round introduced (reported, not yet fixed):** (a) §5.2 no longer states an explicit build task for adding the SFCC-ID fields to content types, only descriptive coverage remains (§5.3's example, Appendix B's generic checklist line); (b) the 3 resolved comment threads are now orphaned/unanchored in Confluence since their anchor text was deleted, worth marking Resolved in the UI so Tim doesn't re-raise them thinking they're unaddressed.

**Full comment tracker:** `~/Desktop/SFCC-249-tim-feedback-tracker.md`, an 18-row table of every distinct review comment (Tim Lavelle + Jasmijn Tsang) found on the page with status. Built after cross-checking the page's raw storage-format inline-comment markers against comment content, surfaced 3 newly-found open items beyond what was previously tracked: a Jesse C. Pagaduan input request on §5.2's MRT SSR layer row (not actioned), Jasmijn's unanswered "does Global-e own the entire US checkout path" question on §2.2's US-International row, and Tim's "what can we work on while the MRT approach is decided" question on §6.1 (only partially answered, routed to SFCC-237 but the actual question unanswered). Also flagged one **unverified** item: a possible 4th "move this elsewhere, drift risk" comment near §5.2 that doesn't match the 3 rows already removed, anchor not yet pinned down. Check this file first before re-auditing the page's comments from scratch.

**Still open, untouched by this round:** §5.5's Studio-vs-coded authoring-path rule and heuristic (Tim's comments #13/#14), no TSD edit made yet, blocked on Tim's direct scope answer; Tim's broader suggestion of dedicated "component requirement pages" instead of specifics in the TSD (SFCC-323, Contentful's own org-level Content Model Templates, is a possible alternative, not yet evaluated); Appendix A Handoff Boundary still `[FOR UPDATE]`; sign-off still Pending for both Jasmijn Tsang (BA Lead) and Tim Lavelle (SA); and the recurring bookkeeping gap where Document Information's "Version" field and the Version History table are still stuck at "v31" despite the page now being at v42.

Related: [[sfcc-123]], [[sfcc-123-review-marcel-actions]], [[tsd-scope-principle]].
