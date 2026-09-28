---
name: project-sfcc237-mrt-topology-spike
description: "SFCC-237/SFCC-681 spike — MRT app topology TSD. SFCC-237 marked Done 2026-08-11 (Sprint 2 close) and CLONED to SFCC-681 (Sprint 3, active, due 2026-08-12) — the TSD itself was never written, work continues under SFCC-681. Literal per-integration MRT app is NOT platform-supported (Mani + Salesforce ISV FAQ) — real comparison is single app vs. single modular app. Full research pass 2026-08-10/11, blast-radius/undici-pool findings exhaustively re-verified, zero contradicting evidence found."
metadata: 
  node_type: memory
  type: project
  originSessionId: 78f0fd67-7a4d-4e0f-8272-98deb75147ca
  modified: 2026-08-13T02:18:08.597Z
---

## TICKET STATUS — SFCC-237 closed, SFCC-681 is now the live ticket (found 2026-08-11)

**SFCC-237 was marked Done on 2026-08-11 at 15:40 (Hazel: In Progress → Code Review → Done,
same-minute back-to-back), but the actual DoD — a written TSD with recommendation + Tim's
sign-off — still does not exist anywhere (not in the repo, not on Confluence).** This is Sprint-2
close-out bookkeeping, not a claim the work is finished: at 00:59 the same day, Hazel had already
**cloned SFCC-237 into SFCC-681** (identical title/description), added it to **SFCC Sprint 3**
(which starts 2026-08-11, confirmed via [[project_real_sprint_cadence]]), assigned to Squad A,
re-estimated from 3 points down to **1 point** (11:36 — likely reflecting that most of the
research is already done via this session's work), and set due **2026-08-12**. SFCC-681 sits in
"Ready for Development." **CONFIRMED BY USER 2026-08-11: track everything under SFCC-681 going forward** —
the eventual TSD's "Related Jira" field should point there (reference SFCC-237 as the origin/prior
ticket, matching how SFCC-249 cites its own origin spike SFCC-123 in its Document Information
table). A new Confluence remote-link (id 10526) was also added to SFCC-681 at 13:16 — could
not identify the specific page (Confluence's search tool returned empty/generic results for both
this and SFCC-237's earlier link — a demonstrated tool limitation, not evidence no page exists);
worth asking the user directly if they know what was linked, rather than treating the search
failure as conclusive.

## Ticket text (for reference — unchanged across the clone)

SFCC-237 / SFCC-681 ("Spike: MRT Application Architecture Strategy (Single vs Per-Integration MRT
Apps)", label Squad-A, epic SFCC-1 "Platform Setup & Environments", assignee me/Marcel Angelo
Navarro, reporter Hazel Marie Cacalda). DoD: a TSD
comparing Option A (single app) vs Option B (per-integration app) vs a middle option (single
modular app), scored on deploy/rollback, failure isolation (event-loop/memory/process, not just
sockets), secrets/security blast radius, performance/LCP, cost, ownership — with an agreed as-is
baseline, a recommendation, and Technical Lead (Tim) sign-off. Tim asked me + Gideon R. Linsangan
(SFCC squad; currently active on SFCC-241 "Validate MuleSoft Sync Process") to collaborate. No
linked branches/PRs/commits on the ticket (pure docs deliverable). Complements
[[project-spike-122-123-audit]] (SFCC-122 = what MRT can *consume*, Done; this = how many MRT apps
we *deploy*).

## Pre-draft refresh 2026-08-12 — ticket + template both re-pulled

**SFCC-681 status changed today.** Hazel moved it **"Ready for Development" → "In Progress" at
11:48 AM** and **ranked it higher** in the same minute. **Due date is TODAY (2026-08-12).** 1 story
point, SFCC Sprint 3, Squad A, parent SFCC-1, formally linked as "clones SFCC-237". Description is
**verbatim identical** to SFCC-237's — including the "isolates upstream integrations only at the
network level (per-origin undici pools)" claim already corrected by Discrepancy #2, and the
"…and any viable middle option (single modular app)" phrasing. The unidentified Confluence
RemoteWorkItemLink (id 10526, added 08-11 13:16) is still there and still unresolved.

**Reconciling the ticket's "middle option" with the user's explicit 2-option direction:** the user
ruled exactly two options (A viable, B included-then-invalidated). The ticket's "middle option
(single modular app)" is not being dropped — **it is what Option A properly implemented already is**
(one app, integration code in separated modules, each with its own undici pool / timeout / error
boundary). So it belongs in **§5 Technical Implementation** as the shape of the chosen option, not
as a third row in §3. State this explicitly in the TSD so a reviewer diffing against the ticket text
doesn't think a required option was skipped.

**Template re-pulled: still version 2, structurally unchanged** from the record below — that record
is accurate. Three precise things to carry into drafting:

1. **§2.1's pre-filled constraints are generic boilerplate and are WRONG for Zimmermann — replace,
   never inherit.** The template ships with: "Storefront scope | Solution must work across all **7
   storefronts (AU, UK, US Dom, US Intl, EU, ME)**" — which says 7 but lists only **6**, while
   Zimmermann actually has **8** (AU, UK, US Dom, US Intl, EU Dom, EU Intl, HK, ME). It also ships
   "Integration layer | **All backend system calls must route through MuleSoft.** No new direct
   point-to-point connections from SFCC" — also wrong for us: `architecture.md` §7 documents five
   boundary classes, several of which deliberately bypass MuleSoft (browser-direct Contentful/Didomi,
   MRT-mediated Google Places/Booxi, SFCC cartridges for Adyen/Avalara).
2. **§3 gives the exact mechanism for handling Option B.** The summary table has a **"Viable?"**
   column (template example: Option A Yes, Option B Yes, **Option C No** with "[Disqualifying reason
   — be specific]"), and §3.2 has an **"Option C — [Short name] *(Discarded)*"** subsection. So our
   Option B takes the structural position of the template's Option C: **Viable? = No** in 3.1, with a
   full §3.2 subsection. Deliberate justified deviation: the template asks only "one sentence on why
   this was discarded", but the user wants Option B genuinely *explored* then invalidated — so give
   it real substance (more than one sentence) rather than the minimum. Do **not** invent a phantom
   third option to fill the template's Option C slot.
3. **§6 must map directly back to §1.4 Success Criteria** (template says so explicitly), and asks for
   "at minimum: unit test coverage, one P0 Playwright scenario (**if user-facing**), and any
   integration test requirements". This TSD is an architecture decision with no user-facing surface,
   so there is no P0 Playwright row — **say why rather than silently omitting it**. Also §6.2: "If
   regression risk is low, state why — do not just write 'low'."

## Deliverable format — do NOT reuse tsd-architecture.md's structure

Must follow the official 8-section TSD template (Confluence page 352419841 — see
[[project-tsd-templates]]: Document Info → 1 Problem Statement → 2 Constraints & Assumptions →
3 Options Analysis → 4 Recommended Option & Rationale → 5 Technical Implementation →
6 Testing & Validation → 7 Risks & Mitigations → 8 Decision Record/sign-off), governed by Tim's
"one TSD = one problem" rule. `.docs/temp/tsd-architecture.md` (581 lines, "Technical Solution
Design — PWA (Architecture)", content last substantively touched 2026-07-16) is a *different*,
older, pre-template document covering the whole PWA architecture — it is **background/baseline
source material** for this TSD (its §12.1 Blast-Radius Containment and §14 CI/CD & Environments
are directly relevant), **not** the SFCC-237 deliverable itself. Its own §14 opens with "this
section probably belongs to a DevOps TSD... temporarily until we have one" — it already
self-identifies as a placeholder pending exactly this kind of proper split-out. `.docs/temp/
openItems.md` (companion file, 18-integration open-items register) has nothing on MRT app count —
its items are all per-vendor credentials/contracts, not deploy topology.

## As-is baseline — fully re-verified 2026-08-10 against live codebase (not just docs)

- **One PWA Kit project**, slug `zimmermann` (from `package.json`'s `"name"` field), **six push
  targets** (`npm run push:{dev,test,sit,uat,staging,prod}` → `pwa-kit-dev push -t <target>`),
  each bound to its own GitHub Environment + `deploy-*.yml`, all deploying the *same* build
  artifact. Today's only deploy-topology axis is **environment tier**, not integration domain.
  Repo-wide grep for "per-integration", "per-app", "MRT app(lication)", "multiple MRT" = **0 hits
  everywhere** — SFCC-237 is genuinely greenfield analysis; nothing in the repo pre-empts or
  contradicts any of the three options.
- Only **2 proxy origins** configured in *every* tier's config (`config/default.js`
  `ssrParameters.proxyConfigs`, spread + host-overridden per tier): SCAPI + OCAPI. No
  mulesoft/google/booxi proxy entries exist anywhere in `config/` yet — consistent with most of
  the ~18 `.docs/integration/NN-*.md` systems (confirmed still exactly 18 numbered files + index.md,
  unchanged since 07-30 except two content-only edits to `02-contentful.md`) not having code built
  yet (sprintScope.md).
- `.docs/prd/regional.md` and `.docs/releaseBranchesRules.md` — read in full, both silent on MRT
  app topology (only environment-*tier* language). Nothing to reconcile.
- CODEOWNERS Tier-1-protects `config/`, `overrides/app/ssr.js`, `overrides/app/ssr/`,
  `worker/main.js`, `mobify.config.js` (stale, see below), `.github/workflows/` — all
  `@ZimmermannAU/tier-1-approvers`.

## Discrepancy #1 (mobify.config.js) — CONFIRMED absent + root-caused 2026-08-10

Still doesn't exist as a file, and `package.json` has no `"mobify"` key either. Traced the actual
mechanism in the installed `@salesforce/pwa-kit-dev@3.18.0` / `@salesforce/pwa-kit-runtime@3.18.0`
(both pulled transitively via `retail-react-app@10.0.0` — root `package.json` doesn't pin them
directly): `bin/pwa-kit-dev.js:395` calls `getConfig()` (from `pwa-kit-runtime/utils/
ssr-config.server.js:59-75`), which uses `cosmiconfig` searching, in order,
`config/{DEPLOY_TARGET}.js` → `config/local.js` → `config/default.js` → `package.json`'s `mobify`
key. **A root `mobify.config.js` file is never in this version's search path at all** — this isn't
a missing file, it's a stale reference to a mechanism this PWA Kit version doesn't use. Project
slug (`zimmermann`) actually comes from `package.json`'s `"name"` via `getProjectName()`.

Now cited as real in **seven** places (was 3 at the 07-30 pass): `.docs/architecture.md:108`,
`.docs/memory/projectState.md:24`, `.claude/rules/frozenFiles.md:55` (**Tier 1**),
`CODEOWNERS:50` (**Tier 1**), `.github/copilot-instructions.md:388`,
`.docs/prompts/omsIntClaudeCodePrompt.md` (×2), **and now confirmed on Confluence too** — "05.6 -
Environment Details" (285540356): "MRT push credentials... scoped to the project slug in
`mobify.config.js`." Fixing this touches Tier-1 *Governance* files (frozenFiles.md, CODEOWNERS),
which AGENTS.md's own footer requires both squad leads + Integration lead to approve — flagged to
the user, not spawned as an autonomous background fix. See
[[project-env-topology-doc-conflicts]] conflicts #6/#9 for the Confluence-side sibling finding.

## ⚠️ VERIFIED EMPIRICALLY 2026-08-12: `tsd-architecture.md` §12.1's pool rationale is WRONG

Two bounded experiments against **Node v24.18.0** (matches `config/default.js`'s
`ssrFunctionNodeVersion: '24.x'`), using **only global `fetch` and `node:http`** so they measure the
actual SSR runtime, not the `node_modules/undici` copy (a transitive dep with its own separate global
dispatcher — importing it would inspect the wrong object). Scripts in session scratchpad:
`undici-isolation-check.mjs`, `undici-timeout-check.mjs`.

**Result 1 — cross-origin isolation ALREADY EXISTS by default.** With **100 concurrent requests
stalled** on a deliberately slow origin, a request to an unrelated origin completed in **4ms**
(no-load baseline 12ms). Zero starvation. Node's undici `Agent` keeps a per-origin `Map` and creates a
separate `Pool` per origin (`agent.js` `kClients`/`defaultFactory`), so origins are isolated by
construction.

**⇒ §12.1's stated rationale — "prevents a slow or flooded integration from exhausting connections
for unrelated origins" — describes a problem that does not occur.** That sentence is inherited by
this TSD and by `architecture.md`'s Blast-Radius section; it needs correcting in all three.

**Result 2 — per-origin connections are UNBOUNDED.** Slow origin peaked at **101 concurrent
sockets**; a same-origin request was served concurrently (1506ms = the server's own delay), not
queued. `Pool`'s default is `connections || null` = unlimited.

**Result 3 — the default response timeout exceeds MRT's execution ceiling.** Against a server that
accepts the TCP connection and never responds, `fetch` was **still waiting at 20,003ms**, past MRT's
20s production ceiling (16s non-prod). MRT kills the request first; undici never fails cleanly.

**CORRECTED justification for wiring the pools (use this, not §12.1's):**
1. **Bounding** per-origin connections. Unlimited sockets means one flooded integration can exhaust
   process file descriptors/memory (a genuine cross-integration blast radius, but via fd/memory
   exhaustion, *not* connection starvation) and can hammer or rate-limit the upstream.
2. **Per-origin timeouts** — the decisive benefit. Without them a hung upstream holds the request past
   MRT's ceiling. **Synthesis worth keeping: this produces the exact same shopper experience as the
   Test 1b finding — no response, then a generic 502 after ~20s — via a completely different root
   cause.** Missing error boundaries and missing timeouts converge on one symptom.

**Knock-on: §1.2's "no failure isolation of any kind" and §4.2's "no isolation at any level" are
OVERCLAIMS.** Accurate current-state breakdown:

| Layer | State |
|---|---|
| Cross-origin connection isolation | **EXISTS** by default (verified) |
| Per-origin connection bounding | MISSING (unbounded, verified) |
| Per-origin timeouts | MISSING (default >20s, verified) |
| Error boundaries in modules | MISSING (`marketingCloud.ts` has no try/catch) |
| Route-level promise observation | MISSING (`ssr.js` floating promises) |
| Event-loop isolation | IMPOSSIBLE under any single-app design (accepted) |

More credible than a sweeping "nothing works", and it re-orders the problem: the severe gaps are the
**error boundary** and **floating promise** ones (Tests 1 and 1b) plus missing timeouts. The unwired
pools matter, but less than the TSD currently implies.

## Discrepancy #2 (undici pools inert) — CONFIRMED still fully inert 2026-08-10

`overrides/app/ssr/connectionPools.ts` still defines the same 7 pools (`sfcc-scapi`,
`sfcc-payments`, `mulesoft`, `marketing-cloud-auth`, `marketing-cloud-rest`, `google-places`,
`booxi`). Zero imports/usages anywhere else in `overrides/` (grep-confirmed across the whole
tree). All 4 real SSR `fetch()` calls (`slasTokens.ts:78`, `paymentMetadata.ts:42-44`,
`marketingCloud.ts:38-46,61-75`) use the bare global dispatcher, no `dispatcher` option passed.
Git history proves this was never wired, not just "not yet caught up": the file has exactly **one
commit ever** (`610020e`, the original `ssr.js`→`ssr/` split), zero follow-ups, and — per
`git log --since=2026-07-30` — zero commits to `worker/main.js`, `overrides/app/ssr.js`,
`overrides/app/ssr/`, or `CODEOWNERS` at all in the last 11 days. `overrides/app/
request-processor.js` is confirmed still the unmodified Salesforce example stub (still contains
the template's own "this is an EXAMPLE file" comment). `worker/main.js` is a 7-line
license-header-only stub with no logic.

**Correction to the ticket's own Background text:** it states today's isolation is "at the network
level via per-origin `undici` connection pools" — that overstates reality. The pools are *designed*
but not wired, so today's real isolation is **zero**: all integrations share one global `fetch`
dispatcher in one process. Worth correcting in the TSD's as-is baseline rather than repeating the
ticket's own premise verbatim.

## Governance implication for whatever this TSD recommends

Implementing any topology change will eventually touch `config/default.js`, `config/sites.js`,
`overrides/app/ssr.js`, and/or `worker/main.js` — all four are **absolute** Tier-1 files under
AGENTS.md Hard Rule #4 (no verified-session/tier-1-approver exception applies to these specific
four, unlike ordinary Tier 1 files). Not blocking for *writing* the TSD (docs-only), but worth a
flag in the TSD's §5 Technical Implementation so the eventual build-out isn't surprised by it.

## Open items — MOSTLY RESOLVED 2026-08-10 via official MRT platform docs

User supplied `/Users/marcel.a.n.navarro/Dev/mrt-overview.md` + `mrt-administration.md` (official
Salesforce Managed Runtime docs). These resolve almost everything that previously required a
Gideon/platform conversation:

**Multi-app support — CONFIRMED YES.** "An organization can contain multiple projects for
multiple storefronts and each project can contain multiple environments" (mrt-overview.md
"Projects and Organizations"). Platform-architecturally, Option B is fully supported — this was
the single biggest open unknown and it's now closed.

**Numeric platform limits — CONFIRMED, and this is a real constraint on Option B's *shape*.**
Org-wide cap: **max 100 total environments, max 10 production environments** (raisable only by
contacting Salesforce Support). Zimmermann today uses 6 environments (dev/test/sit/uat/staging/
prod) in one project. A literal "one MRT app per integration" reading of Option B (~18 systems ×
6 tiers = 108 environments) **exceeds the 100-environment org cap on its own** and would need a
Support-ticket limit increase for production count too. A **domain-grouped** version (e.g. 3-5
apps clustering related integrations — payments, CMS-proxy, CRM/order-data, etc.) stays
comfortably under both caps (~24-36 total environments). This is the first hard, quantified
argument for why Option B, if chosen, should group by domain rather than by individual
integration — feed directly into §2.1 Constraints and §3 Options Analysis.

**Cost model — PARTIALLY resolved, nuance matters.** "Because environments run on highly
efficient microservices that automatically scale up and down, you can create as many
environments as you need **at no additional cost**" (up to the caps above). This answers the
*platform-mechanics* half (environments aren't individually metered) but is generic Salesforce
product documentation, not a Zimmermann-specific commercial statement — it does **not** confirm
whether Zimmermann's actual contract caps or charges for an *additional project* (as opposed to
additional environments within an existing project). **Narrowed remaining open item:** confirm
with account team/Gideon whether provisioning a wholly new MRT *project* (not just an
environment) has any commercial implication under Zimmermann's specific agreement.

**MRT execution/concurrency model — CONFIRMED.** App Server = Node.js + Express, "serverless,"
auto-scaling ("massive scaling capacity"). Critically: **"Unhandled promise rejections break app
rendering"** (mrt-overview.md, Rendering constraints) — this is the concrete platform-level
mechanism behind the failure-isolation argument: under Option A, one integration's unhandled
rejection can break rendering for a request that also needed a *different*, otherwise-healthy
integration, because they share the same Node process/request lifecycle. Hard execution-time
ceiling: **20s production / 16s non-production**, then HTTP 502 — a real ceiling regardless of
topology, and a concrete reason the still-inert undici per-pool timeouts (`connectionPools.ts`,
see Discrepancy #2) matter independent of which option wins.

**Deploy/rollback granularity — CONFIRMED, directly answers the ticket's named dimension.**
"Each project can have multiple bundles, but each environment can have only one bundle designated
as deployed" — a bundle is the *entire* built app, immutable. **Under Option A, any change to any
one integration requires deploying (and, if bad, rolling back) the single shared bundle
containing all integrations' code** — a bad change to Integration X forces a rollback that also
reverts unrelated Integration Y's code if it shipped in the same bundle. Option B gives each
domain-app its own independent bundle lineage — true deploy/rollback isolation. This is the
clearest, most concrete win for Option B of everything found so far.

**Architectural catch for Option B (original framing, now superseded below).** MRT environments
are hostname-bound HTTP-serving units ("A hostname can be set as the External Hostname for only
one environment at a time"). Zimmermann's architecture.md §"Cross-Storefront Session & Basket
Scope" depends on **all 8 storefronts sharing one first-party domain** for session-cookie sharing.
This part still holds. What does NOT hold — see the correction immediately below — is the
mechanism originally proposed here (hosting per-integration backends as *sibling MRT projects*
called server-to-server).

## CORRECTION (later 2026-08-10): Option B as literally stated is not platform-supported

User supplied a direct quote from **Mani (former Integration Lead)** plus two more docs
(`b2c-commerce-integration.md` — Salesforce's official B2C Commerce Headless Integration FAQ for
ISV partners — and `development-workflows-difference-with-pwa-kit.md`, which turned out
irrelevant to this ticket, pure dev-tooling comparison against a separate/newer "Storefront Next"
offering, no topology content). This meaningfully corrects the architectural mechanism proposed
above (not the multi-project *fact* itself, which stands — see below).

**Mani's statement (verbatim, as relayed by the user):** "you cannot run multiple separate or
independent Node.js application processes (like auxiliary microservices or distinct integration
apps) inside a single Salesforce Managed Runtime (MRT) environment. MRT is strictly designed to
host one unified application bundle generated from an official PWA Kit template."

**Independently corroborated by a primary source already in hand** — mrt-overview.md's own
opening `:::important` callout, read in full earlier the same day: "Managed Runtime only supports
applications created from a PWA Kit template." I had this fact already but under-weighted its
implication. It means MRT is not general-purpose Node/container hosting (unlike AWS/Heroku/GCP) —
every MRT project must be a full PWA-Kit-template-shaped bundle (React + Express + PWA Kit's
rendering/routing system), never a lightweight generic API service.

**Now further confirmed by `b2c-commerce-integration.md` (Salesforce's own ISV integration FAQ,
primary source, not a search summary):**
- "**Every Composable Storefront must have a project created in Runtime Admin** for managing
  deployments" — one project per storefront is the documented model, full stop.
- Its integration-pattern table shows backend logic for a Composable Storefront is always
  delivered as *one of*: (a) a B2C Commerce Cartridge running inside **SFCC itself**, not MRT; (b)
  a **Node module / NPM package that extends the same PWA Kit Express server** — "PWA Kit ships
  with a slim server that forwards requests to the React rendering pipeline but **can be extended
  to take arbitrary action on incoming HTTP requests**"; or (c) a **Connected App** — an
  ISV-hosted API living entirely outside MRT, called from the storefront or SFCC. **There is no
  fourth pattern of "a second MRT project as an integration's own backend."** The "combo"
  (front-end + back-end) integration type explicitly ships its back-end piece as "Node Module (If
  needed)" *into the existing app*, not as a separate deployment.

**The user's own "quick search" answers (secondary/AI-generated, mixed sourcing quality — one
citation is a personal blog, one is a malformed Google-Images URL, so treated as corroboration of
already-verified facts, not a new source of truth on its own) point the same way and add one
useful, plausible-and-consistent detail not contradicted by anything already read: MRT's genuine
multi-project support exists for **multi-brand/multi-domain separation** (e.g. `brand-us.com` vs
`brand-uk.com`), not for splitting one storefront's backend integration code by domain/system.**

**Corrected conclusion — replaces the server-to-server-sibling-MRT-app mechanism above:** Option B
("a dedicated MRT application per integration/domain"), read literally as *hosting a specific
integration's backend on its own Managed-Runtime-hosted project*, is **not a supported pattern**
for this platform — not a matter of Zimmermann's config or org limits, but of what MRT is built to
run at all. The two real, platform-sound alternatives to Option A are: (1) the ticket's own
"middle option" — **single modular app**, i.e. one MRT project/bundle with integration code
organised into clearly separated modules, each with its own undici pool / timeout / error
boundary (the currently-inert `connectionPools.ts` pattern, still the right mechanism — just for
calling *external* services, not sibling MRT apps); or (2) for a specific integration that
genuinely needs process-level isolation, **host that integration's proxy/middleware layer outside
MRT entirely** (general-purpose cloud compute — AWS/GCP/Heroku, or an ISV's own hosted API per the
"Connected App" pattern above), with the one MRT app's Express server calling out to it over HTTP
via the same undici-pool mechanism. That second path is a materially bigger, separate
infrastructure decision (new hosting target, new CI/CD, new on-call) — likely a candidate for
"discarded" or a forward-looking note in §7 Risks rather than a real contender in *this* TSD,
consistent with "one TSD = one problem." **Recommend restructuring §3 Options Analysis so the
ticket's literal Option B becomes the template's "discarded option" slot (with this correction as
the one-sentence discard reason), and the real comparison becomes Option A vs. the modular-app
middle option** — flag this restructure to the user before drafting, since it changes what the
ticket's own Option A/B framing means.

**Certificates — a non-issue either way.** TLS certs are **org-scoped**, usable by any environment
in the same org (not per-project) — Option B's extra projects would share the same wildcard cert
with no additional certificate-provisioning overhead.

**Project-level role granularity — a concrete secrets/ownership-blast-radius argument for Option
B.** Each MRT project has its own Admin/Developer/Marketer/Viewer role assignments (env-var
visibility, deploy access, log access are all project-scoped, one role per user per project).
Under Option A everyone who needs deploy/env-var access to *any* integration necessarily has it
for *all* integrations (one shared project). Option B lets access be scoped per domain-app —
directly answers the ticket's "secrets & security blast radius" and "ownership" dimensions with a
platform-verified mechanism, not a hypothetical.

**Collateral finding (out of SFCC-237's scope — one-TSD-one-problem — but worth flagging
separately):** "Server-Side Cookie Access is enabled by default for new projects. **Existing
projects continue to have server-side cookies turned off by default**" (mrt-administration.md).
Zimmermann's `httpOnly` SLAS refresh-token cookie architecture (architecture.md §"Cross-Storefront
Session") is load-bearing on server-side cookie access being *on*. Worth an independent Runtime
Admin check (project settings) that this is actually enabled on the existing `zimmermann` project
— not something derivable from the codebase, and not something to fold into this TSD.

## Local Salesforce/MRT reference docs the user has supplied (in `/Users/marcel.a.n.navarro/Dev/`)

Triage so a future session doesn't re-investigate hoping for more than each contains:
- **`mrt-overview.md`** — HIGH value. Source of the org caps (100 env / 10 production), the
  execution model, "unhandled promise rejections break app rendering", the 20s/16s execution
  ceiling, the "PWA Kit template only" constraint, roles/abilities table, and the
  environments-are-free-at-no-additional-cost statement. Load-bearing for §2 and §3.
- **`mrt-administration.md`** — HIGH value. Regions + backup-region table, project/environment
  admin, certificates being org-scoped, the (nonexistent-in-this-tenant) Server Architecture
  instruction, access-control-header rationale, server-side-cookie default caveat.
- **`b2c-commerce-integration.md`** — MEDIUM-HIGH. Salesforce's own ISV integration FAQ; the primary
  source proving backend integrations ship as SFCC cartridge / Node module into the same app /
  externally-hosted Connected App, and that "every Composable Storefront must have a project
  created in Runtime Admin". Key evidence for invalidating Option B.
- **`development-workflows-difference-with-pwa-kit.md`** — NO value for this ticket. Webpack-vs-Vite
  dev-tooling comparison against the separate "Storefront Next" offering. No topology content.
- **`composable-storefront-api-specs.md`** (added 2026-08-12) — LOW evidentiary value; it's a
  navigation stub, not substantive content. Useful only as **citable canonical spec URLs for the
  TSD's References section** (SFCC-249 sets the precedent of having one): SCAPI
  (`/docs/commerce/commerce-api/references/`), OCAPI (`/docs/commerce/b2c-commerce/references/`),
  Script API (`salesforcecommercecloud.github.io/b2c-dev-doc/`), Einstein API
  (`/docs/commerce/einstein-api/references/`). Mild corroboration only: the SCAPI+OCAPI pairing it
  names is exactly the two proxy configs wired in every MRT environment, and it places **Script API
  on the SFCC/cartridge side**, consistent with the boundary that backend logic lives in SFCC or in
  the single MRT Express app — never in a sibling MRT app.

## Runtime Admin live verification 2026-08-12 (user-performed, screenshots reviewed)

Org **Zimmermann** → project **Zimmermann** (`runtime.commercecloud.com/zimmermann/zimmermann/...`).

**Check 1 — "New Project" form confirms Option B is unofferable. FIRSTHAND VERIFIED.** The
Create-a-New-Project modal asks for exactly: Name, Project ID (immutable, max 20 chars), and two
Environment Defaults (Server-Side Cookie Access toggle, Proxy User Agent radio). **No
application-type field of any kind** — no "service", "API-only", or "microservice" option. The
platform silently assumes every project is a full PWA Kit storefront bundle, corroborating Mani +
the Salesforce ISV FAQ with direct UI evidence. (Form was cancelled, not submitted — nothing
created.)

**Check 2 — project users: 4 users, ALL FOUR are Admin. Zero Developer/Marketer/Viewer.**
`victor.t.crisostomo@`, `gideon.r.linsangan@`, `marcel.a.n.navarro@`, `timothy.lavelle@` (all
@accenture.com). So 100% of project members hold Deploy + Access Logs + **View and Manage
Environment Variables** + Manage Team. MRT offers exactly the granularity that would scope this
(Developer drops Manage Team; Marketer drops env-vars/deploy; Viewer is read-only) and **none of
it is in use**. Nuance to state honestly in the TSD rather than overstate: the *mechanism* is
coarse (project-scoped roles ⇒ one project = all-or-nothing per person), but *current* exposure is
small in absolute terms (4 senior people, incl. the SA and the SFCC lead). The argument is about
scaling — team growth × ~18 integrations' credentials — not present-day risk. **This partly
WEAKENS the secrets-blast-radius case for Option B**: splitting projects today wouldn't reduce
real exposure (all 4 would need access to most domains anyway) and would multiply per-project team
admin. Say so plainly.

**Access-boundary asymmetry worth flagging (new observation, not necessarily a problem):** GitHub
`@ZimmermannAU/tier-1-approvers` = **2** people (Tim + Marcel, per
[[project_release_branch_status]]); MRT project Admin = **4** (adds Victor + Gideon). So Victor and
Gideon cannot approve a Tier-1 change to `config/default.js` in the repo, but *can* directly edit
production environment variables and deploy to prod in MRT. Two different systems with different
trust boundaries; plausibly appropriate (SFCC-side staff legitimately need MRT access), but worth
recording since "secrets & security blast radius" is an explicit TSD scoring dimension.

**Project ID = `zimmermann`** — confirms firsthand the slug derived earlier from `package.json`'s
`"name"` field (see Discrepancy #1); no separate MRT-side slug config exists.

**COLLATERAL ITEM RESOLVED — Server-Side Cookie Access = "Enabled" on the existing project.** The
earlier concern (mrt-administration.md warns existing projects were *not* auto-enabled) does not
apply here — it's on. Zimmermann's `httpOnly` SLAS refresh-token cookie architecture
(architecture.md §Cross-Storefront Session) is safe. Close this out; no action needed.

**Also recorded: Proxy User Agent = "Infrastructure"** (not "Browser") — proxied requests replace
the shopper's UA with the Amazon CloudFront UA. Config fact only; any relevance to REG-009 bot
detection would be speculative (that gating is on page requests, not `/mobify/proxy/` calls) —
do not assert a connection without checking.

**DOC DISCREPANCY FOUND: project-level Server Architecture (ARM/x86) is NOT in this UI.**
mrt-administration.md instructs "Project Settings → under **Environment Defaults** and **Server
Architecture**, select either ARM or x86" — but this project's Environment Defaults shows *only*
Server-Side Cookie Access and Proxy User Agent. No Server Architecture field exists. Either the
doc describes a newer/different UI revision or the setting is per-environment only here. ARM/x86
must therefore be checked **per environment** (Environments → an environment → Environment
Settings → Advanced), not at project level.

**Access scope note:** left nav shows only Environments / Project Users / Project Settings — no
org-level *Certificates* or *Organization Users* entries, so the user appears to hold **Project**
Admin, not **Organization** Admin. Consequence: the org-wide caps (100 total / 10 production
environments *across all projects*) can't be fully audited from this view unless the PROJECT
dropdown reveals every project in the org.

**NEW FINDING 2026-08-12 — there are SEVEN MRT environments, not six. An undocumented `DEV1`
exists.** Live Environments list for project `zimmermann`: **DEV** (last deployed Aug 11 12:31 PM),
**DEV1** (Aug 11 9:42 AM), **Production** (Jun 30 2:31 PM), **SIT** (Aug 11 12:16 PM), **STG**
(Aug 11 9:42 AM), **TEST** (Aug 11 11:44 AM), **UAT** (Aug 11 11:44 AM).

`DEV1` appears in **none** of: `config/` (no `dev1.js`), `package.json` push scripts,
`.github/workflows/deploy-*.yml`, Confluence 05.6's environment table, or the GitHub Environments
list. **Repo-wide grep for "dev1" returns zero hits.** Git-verified history: `config/dev1.js` was
*added* in `3cfc0d9` (2026-06-12, "fix(config): hardcode dev1 proxy hosts, enable SLAS private
client, add dev1 env config" — also touched `deploy-dev.yml`, `config/default.js`, `ssr.js`,
`package.json`) and *removed* in `2c9e49f` ("docs: Measmerize, MRT envs, etc"). So the repo-side
config was deliberately retired; **the MRT environment itself was never deleted, and something
deployed to it yesterday (Aug 11, 9:42 AM).**

**Why this matters mechanically (ties directly to Discrepancy #1's cosmiconfig tracing):** because
`getConfig()` falls back `config/{DEPLOY_TARGET}.js` → `config/local.js` → `config/default.js`, a
`pwa-kit-dev push -t dev1` **silently succeeds with no `dev1.js`**, inheriting `default.js`'s
config — i.e. pointing at the *dev* SCAPI/OCAPI hosts. So DEV1 is a deployable environment with no
per-tier config, no CI/CD trail, no documentation, and no owner recorded anywhere. Relevant to the
ticket's named **deploy/rollback** and **ownership** scoring dimensions: the current one-project
model already shows real environment drift in practice, and under Option B that surface multiplies
per additional project.

**ORIGIN CONFIRMED BY USER 2026-08-12: DEV1 is a test environment created by Mani** (Manikandan
Ramachandran, epic SFCC-1 owner and — per the user's own framing earlier in this work — the
**former** Integration Lead). So it was deliberate, not an accident; MRT's docs also encourage
creating environments freely ("create as many as you need at no additional cost... when you no
longer need an environment, we encourage you to delete them"), and [[project_usintl_status]]
records that the shared MRT dev target gets clobbered by others' branches, so an isolated test
target was a reasonable thing to make.

**But the confirmation reframes rather than closes the finding, and DEV1's own config turns out to
be internally inconsistent.** Full DEV1 inspection 2026-08-12:

- **Only 7 environment variables** (vs DEV's 17): `COMMERCE_API_{CLIENT_ID,OCAPI_HOST,
  ORGANIZATION_ID,SHORT_CODE,SITE_ID}`, `EINSTEIN_API_SITE_ID`, `PWA_KIT_SLAS_CLIENT_SECRET`.
  **All five `CONTENTFUL_*` vars are absent**, as are `GTM_CONTAINER_ID`, `MEASMERIZE_BRAND_CODE`,
  `OPTIMIZELY_PROJECT_ID`, `PUBLIC__app__features__shopperContext__enabled`,
  `STOREFRONT_PREVIEW_DEBUG`. So the CMS integration cannot function at all on DEV1 (it would
  permanently exercise the §12 "render page without editorial content" degradation path), and
  `MARKETING_CLOUD_*` is missing here too — same guaranteed-throw situation as DEV.
- **Points at a DIFFERENT and UNDOCUMENTED SFCC instance: `bkzk_001`.** B2C Commerce Instance =
  `bkzk_001`; OCAPI proxy destination = `https://bkzk-001.dx.commercecloud.salesforce.com/*`.
  **`bkzk_001` appears nowhere in Confluence 05.6's environment table** (which lists dev=`bkzk_002`,
  test=`bkzk_005`, sit=`bkzk_003`, uat=`bkzk_dev`, staging=`bkzk_stg`, prod=`bkzk_prd`). This also
  explains commit `3cfc0d9`'s title — "hardcode **dev1 proxy hosts**" — the dev1 proxy pointed
  somewhere different from dev's all along.
- **INTERNAL INCONSISTENCY — SHARPENED 2026-08-12 via a text dump side-by-side with DEV.** The
  original observation was "DEV1's `COMMERCE_API_ORGANIZATION_ID` ends `_002` while its B2C instance
  and OCAPI proxy point at `bkzk_001`." Comparing DEV1's and DEV's masked values directly reveals
  the likely cause: **5 of DEV1's 7 variables have masked suffixes byte-identical to DEV's** —
  `COMMERCE_API_CLIENT_ID` (`****eb1c`), `COMMERCE_API_ORGANIZATION_ID` (`****_002`),
  `COMMERCE_API_SHORT_CODE` (`****7hks`), `COMMERCE_API_SITE_ID` (`****nnAU`), and
  `PWA_KIT_SLAS_CLIENT_SECRET` (`****lcSA`) — plus `COMMERCE_API_OCAPI_HOST` shares DEV's
  uninformative `.com` suffix. **DEV1's SCAPI/SLAS credential set therefore appears to be a copy of
  DEV's, while the environment's own platform bindings (B2C Commerce Instance, OCAPI proxy
  destination) were pointed at a different sandbox, `bkzk_001`.** That's a coherent explanation of
  how the mismatch arose, and it raises confidence well above the original 4-character inference.
  **Contrast — this is decisive:** SIT, TEST and UAT each carry *distinct* `COMMERCE_API_CLIENT_ID`
  values (`****9d46`, `****d762`, `****108e`) and *distinct* SLAS secrets (`****ZvDs`, `****s2Yc`,
  `****H5g8`), i.e. proper per-tier credentials. DEV1 alone duplicates another tier's.
  **One honest exception to the copy theory:** `EINSTEIN_API_SITE_ID` on DEV1 is *fully* masked
  (`****************`, no visible suffix) whereas DEV's shows `****nnAU` — so that one value is
  **not** the same as DEV's, and is probably short or empty. Don't claim a wholesale clone.
  **Caveat that still stands:** every value remains masked, so this is inference from suffixes, not
  a read of the actual strings. Have someone reveal the values before citing it as fact in the TSD.
  **Third possible inconsistency worth checking while doing so:** DEV1's `COMMERCE_API_OCAPI_HOST`
  *environment variable* vs its MRT *proxy* destination (`bkzk-001.dx...`). If the env var was
  copied from DEV it would read `bkzk-002...` while the proxy says `bkzk-001...`. Both masked
  suffixes are `.com`, so the mask cannot discriminate — this needs the value revealed.
  (For contrast, DEV is internally consistent throughout: org `_002` / instance `bkzk_002` / OCAPI
  `bkzk-002`.)
- Everything else matches DEV exactly: Environment ID `dev1`, Production Environment **Disabled**,
  all 8 Site IDs incl. `ZimmermannUSIntl`, no Access Control header, no IP allowlist, CDN "MRT CDN",
  default hostname `zimmermann-dev1.sfdc-8tgtt5-ecom1.exp-delivery.com`, Region **Asia Pacific
  (Sydney)**, Log Filtering `Info`, Server-Side Cookie Access **Enabled**, Source Maps **Enabled**,
  Proxy User Agent **Infrastructure**, SCAPI proxy → `qmyt7hks` (same as DEV).
- **Third confirmation: no Server Architecture (ARM/x86) field on this environment either.**

**Net TSD framing (fair reading, states both directions):** DEV1 is a legitimate environment that
has become **orphaned** — undocumented in Confluence, un-wired to any repo config/CI, pointing at an
undocumented SFCC instance with an apparently mixed-instance config, and owned by someone who has
since moved off the Integration Lead role. That's a concrete, live instance of the
environment-lifecycle-and-ownership gap the ticket names as a scoring dimension. Note the direction
carefully: this sprawl already happens with **one** project and 7 environments, and Option B would
**multiply** it (more projects × more environments, plus per-project team membership to keep
current) — so it reads as mild evidence **for** consolidation-plus-hygiene and **against** Option B,
not the reverse. Belongs in §7 Risks as "environment lifecycle/ownership is currently ungoverned"
with DEV1 as the worked example.

**Production last deployed Jun 30 2026** — ~6 weeks stale while all six others deployed Aug 11.
Consistent with [[project_release_branch_status]]'s finding that the `prod` GitHub Environment is
empty (no vars/secrets); the Jun 30 bundle is presumably initial provisioning, not a real
storefront release.

**Headroom against the org caps: 7 of 100 total environments used.** Confirms the earlier maths —
a literal per-integration Option B (~18 × 6 tiers = 108) still breaches the 100 cap on its own,
while a domain-grouped 3–5 apps (18–30 new + 7 existing = 25–37) fits comfortably.

**CAUTION — do not misread the Account Settings page as an architecture answer.** `/account/settings`
shows three *notification preferences*, all Enabled: "Node.js End of Life", "Certificate Status",
"x86 Server Architecture End of Life". These are **email-alert toggles, not status indicators** —
"x86 EOL notifications enabled" does **not** mean any environment is on x86. Useful only as
evidence that an early-warning mechanism exists. ARM/x86 remains unanswered. (Related, from
`config/default.js`: `ssrFunctionNodeVersion: '24.x'` — Node 24 is current, so the Node-EOL
notification is unlikely to fire soon.)

## DEV environment deep-dive 2026-08-12 (Environment Variables + Environment Settings, full scroll)

**Proxy Configs — FIRSTHAND CONFIRMATION of the codebase finding.** DEV's MRT-side proxy list is
**exactly two entries**, matching `config/default.js`'s `ssrParameters.proxyConfigs` precisely:
`/mobify/proxy/api/*` → `https://qmyt7hks.api.commercecloud.salesforce.com/*` (SCAPI) and
`/mobify/proxy/ocapi/*` → `https://bkzk-002.dx.commercecloud.salesforce.com/*` (OCAPI). No
MuleSoft, Google, or Booxi proxy exists on the live platform either — the code and the platform
agree.

**NEW OPERATIONAL GOTCHA (from the UI's own help text):** *"Proxy settings on the Managed Runtime
are separate from proxy settings in the bundle."* So proxies have **two independent sources of
truth** — the MRT environment settings *and* the deployed bundle's `config/*.js`. They currently
agree, but nothing enforces that; they can silently drift. Relevant to the TSD's deploy/ownership
dimensions, and it multiplies under Option B (N projects × M environments × 2 places to keep in
sync). Worth an explicit note in §5/§7.

**Environment Variables: 17 on DEV, one flat namespace, zero per-integration scoping.**
`COMMERCE_API_{CLIENT_ID,OCAPI_HOST,ORGANIZATION_ID,SHORT_CODE,SITE_ID}`, `CONTENTFUL_{DELIVERY_TOKEN,
ENVIRONMENT_ID,HOST,PREVIEW_TOKEN,SPACE_ID}`, `EINSTEIN_API_SITE_ID`, `GTM_CONTAINER_ID`,
`MEASMERIZE_BRAND_CODE`, `OPTIMIZELY_PROJECT_ID`, `PUBLIC__app__features__shopperContext__enabled`,
`PWA_KIT_SLAS_CLIENT_SECRET`, `STOREFRONT_PREVIEW_DEBUG`. All values masked in the UI. **Concrete
§4.3 Trade-offs evidence:** the platform offers no sub-scoping *within* a project — every
integration's credentials share one flat per-environment list, readable/editable by all 4 project
Admins. With ~18 integrations built this becomes ~40-50 vars in one list × 7 environments. Option B
*would* have scoped this per project — but since Option B isn't platform-viable, the honest framing
is "accepted trade-off, mitigated by access discipline and rotation, not by architecture."
(Note: `PWA_KIT_SLAS_CLIENT_SECRET` living here as an MRT env var is *correct* — the earlier
security smell in [[project_release_branch_status]] was about it being a plaintext **GitHub**
Environment *Variable*, a different store. No issue on the MRT side.)

**SIGNIFICANT — `MARKETING_CLOUD_*` is NOT set on DEV.** No `MARKETING_CLOUD_CLIENT_ID`,
`_CLIENT_SECRET`, or `_SUBDOMAIN` in the list, and MRT has no project-level env-var store to inherit
from (Project Settings has only Name/ID, Environment Defaults, Delete). So at runtime on DEV,
`marketingCloud.ts`'s `sendMarketingCloudEmail` hits its own guard —
`if (!clientId || !clientSecret || !subdomain) throw new Error('Marketing Cloud credentials are
missing...')` — and throws. **This means Test 1b's failure mode is not a hypothetical outage
scenario on DEV; it is the guaranteed, 100%-of-the-time behaviour of the passwordless-login and
reset-password callback routes on that tier today**: throw → orphaned promise at the `ssr.js` call
site → framework logs it → shopper gets no response → 20s/16s ceiling → generic 502. A *different*
trigger than the 503 the test simulates, but the identical uncaught path from the same function.
Strongest available evidence for the TSD's §1.3 Impact section. Caveat to state honestly: whether
those routes are actually exercised on DEV yet is unverified (auth flows are later-sprint work) —
the route registration exists unconditionally in `ssr.js`, so the behaviour is certain *if* hit.

**Also confirmed on DEV:** Environment ID `dev`; **Production Environment = Disabled**; B2C Commerce
Instance `bkzk_002` (matches Confluence 05.6's `f_ecom_bkzk_002`); **Site IDs = all 8 storefronts
including `ZimmermannUSIntl`** (firsthand corroboration of [[project_usintl_status]]'s "live on
dev"); **Region = Asia Pacific (Sydney)** — deliberately chosen, not MRT's `us-east-1` default
(backup region per docs = Singapore); Log Filtering `Info`; Server-Side Cookie Access **Enabled** at
the environment level too (not just the project default); CDN = **"MRT CDN"** (a third data point
against the Akamai-vs-Cloudflare open item tracked in [[project_env_topology_doc_conflicts]] — note
MRT's own CDN sits in front of the app, likely distinct from SFCC's eCDN; don't conflate); Hostname
= default `zimmermann-dev.sfdc-8tgtt5-ecom1.exp-delivery.com`, no custom domain.

**ARM/x86 — NOW DOUBLY UNRESOLVED, and unresolvable via this UI.** The Advanced section on the
*environment* exposes CDN, Hostname, Region, Log Filtering, Server-Side Cookie Access, Source Maps,
Allowed IP Addresses, Proxy Configs, Proxy User Agent — and **no Server Architecture field**, just
as Project Settings had none. So mrt-administration.md's instructions describe a control that
doesn't exist in this tenant's UI at either level. Plausible reasons (all unverified): docs ahead of
the deployed UI, the field is hidden when nothing is on x86, or it's API-only
(`projects_target_partial_update`). **Reasonable inference, explicitly NOT a verified fact:** ARM is
"the default for all new projects", the project's repo history starts 2026-06-12, and no x86 toggle
is surfaced — so it's *probably* ARM. Do not assert this in the TSD as confirmed; either mark it an
open item or have someone check via the MRT API. The account-level "x86 EOL" notification toggle
being Enabled is a default-on *notification preference*, not evidence of x86 usage.

**COLLATERAL (environment hardening — separate concern, do NOT fold into this TSD):** DEV has **no
Access Control Header configured** ("You haven't configured access control"), **no IP allowlist**
("No Allowed IP Addresses" = all IPs permitted), a **default public hostname**, and **Source Maps
Enabled**. Net effect: DEV is publicly reachable by anyone with the URL, serving readable source
maps, against a real SFCC sandbox (`bkzk_002`). Defensible for a dev tier, but worth a deliberate
decision rather than a default — and per the MRT docs, access control headers exist precisely to
stop bots bypassing CDN perimeter security and search crawlers indexing the wrong environment.
Also worth confirming Source Maps is **Disabled** on Production (not checked). This is orthogonal to
app topology — splitting into more apps wouldn't fix it, it would multiply the hardening surface —
so it belongs in its own ticket, not §5 of this TSD.

## PRODUCTION + SIT inspected 2026-08-12 — two high-consequence findings

### ⚠️ FINDING A (highest consequence of the whole pass): PROD runs in a DIFFERENT AWS REGION to every other environment

**Production Region = `US East (Ohio)`. DEV, DEV1, SIT (and by inference the rest) = `Asia Pacific
(Sydney)`.** Meanwhile Production's own OCAPI proxy destination is
`https://production-ap01-zimmermann.demandware.net/*` — **`ap01` = an Asia-Pacific SFCC realm.** So
as currently configured, production would run its Node/SSR layer in Ohio while its SFCC backend sits
in Asia-Pacific, and its primary audience (AU — the `/` root storefront and x-default hreflang
target) is also in Asia-Pacific. Every SSR render on a cache miss would cross the Pacific to reach
SFCC, then serve back to AU shoppers from Ohio.

**Why this is material, tied to signed commitments:**
- `architecture.md` §9 / TSD §9: **LCP ≤ 2s at p75 mobile is client-mandated and contractual.**
  Origin region is one of the largest single determinants of that number for uncached/SSR traffic.
- `architecture.md` §9.3 / TSD §9.3 claims **Stage "mirrors production infrastructure (same MRT
  bundle size class, same CDN/edge configuration, same SFCC realm tier)"** and is therefore the
  environment where the contractual LCP figure is validated. **STG is Sydney; PROD is Ohio** — so
  Stage demonstrably does *not* mirror production on the biggest latency variable, and any LCP
  sign-off measured on Stage would not be representative of production. This invalidates a stated
  premise of the performance-measurement approach, not just a config nit.
- **Honest nuance to include, don't overstate:** MRT's CDN caches at global edge locations, so
  *cache-hit* traffic is largely insulated from origin region. The exposure is on SSR/cache-miss
  renders (PWA Kit server-renders every page), personalised routes, and the MRT→SFCC OCAPI hop.
  Real and worth fixing; not "every request is slow".
- **Fixable now, cheaply:** Region is editable in Environment Settings → Advanced, and prod is not
  live yet (see Finding B) — no traffic, no data, nothing to migrate. This is a catch-it-before-
  go-live finding, not an incident. MRT's docs note `ap-southeast-2` (Sydney) fails over to
  `ap-southeast-1` (Singapore); `us-east-2` (Ohio) fails over to `us-east-1` (N. Virginia).

### ⚠️ FINDING B: the `Production Environment` flag is **Disabled** on Production

Per mrt-overview.md, marking an environment production is what buys **prioritised monitoring by
Salesforce Support** and **Log Center debugging access** (and is what counts against the org's
10-production cap). Production currently has it **Disabled**, so it has neither. Also unconfigured
on Production: **B2C Commerce Instance = `None`**, **Site IDs = empty**, and (user-confirmed) **no
environment variables at all**. Consistent with [[project_release_branch_status]]'s finding that the
`prod` GitHub Environment is empty — prod is genuinely not stood up, and the Jun 30 bundle is
provisioning-only. All of the above belong on a go-live checklist.

**Correcting my own earlier framing on access control:** I flagged "no Access Control Header" as a
general gap. On **Production** that is arguably *correct* — prod must be publicly reachable; the
relevant prod use is requiring the header so traffic can't bypass the customer CDN (Akamai) and hit
the MRT origin directly, which matters only once a custom domain + CDN are in front (neither exists
yet). The genuine gap is on the **non-production** tiers (dev/dev1/sit — and presumably test/uat/stg),
which are publicly reachable with no header and no IP allowlist. Likewise **Source Maps**: correctly
**Disabled** on Production, Enabled on dev/dev1/sit — so someone *did* think about prod hardening
there. My earlier collateral note over-generalised; the accurate version is "source maps on the
non-prod tiers", which is defensible.

### SIT — internally consistent, and the Einstein policy is genuinely being honoured

13 env vars. **`EINSTEIN_API_SITE_ID` is ABSENT on SIT** while present on DEV — direct confirmation
that Confluence 05.6's "**Never** enable Einstein, Global-e, or Narvar on SIT" rule is actually being
followed in practice, and that it's enforced exactly as [[project_einstein_siteid_investigation]]
recorded: **by env-var omission, i.e. convention, not code**. Positive finding worth citing.
Also absent vs DEV: `PUBLIC__app__features__shopperContext__enabled`, `STOREFRONT_PREVIEW_DEBUG`.

**SIT is internally consistent** — org ID `****_003` / B2C instance `bkzk_003` / OCAPI proxy
`bkzk-003`, and `bkzk_003` matches Confluence 05.6's table exactly. This sharpens the DEV1 finding
by contrast: **DEV1's mixed `_002`-vs-`bkzk_001` config is the anomaly, not the house norm.**
Per-tier credential hygiene is otherwise good: SIT has its own distinct `COMMERCE_API_CLIENT_ID`
(`****9d46` vs DEV's `****eb1c`), its own `PWA_KIT_SLAS_CLIENT_SECRET` (`****ZvDs` vs `****lcSA`),
and its own Contentful delivery/preview tokens (`****8Gjk`/`****8QH8` vs `****tQec`/`****tZU4`) while
sharing the same `CONTENTFUL_SPACE_ID` (`****slxu`) — exactly the "one Space, one Environment per
tier" model SFCC-249 documents. Shared-across-tiers by design: `COMMERCE_API_SHORT_CODE`,
`GTM_CONTAINER_ID`, `MEASMERIZE_BRAND_CODE`, `OPTIMIZELY_PROJECT_ID` (the last matches
`architecture.md`'s "single Optimizely snippet across all environments").

### STG + TEST inspected — Finding A is CONFIRMED and is broader than "prod is the odd one out"

**STG = `Asia Pacific (Sydney)`. PROD = `US East (Ohio)`. So Stage and Production run in different
AWS regions — Finding A is now confirmed by direct observation of both, not inferred.**
`architecture.md` §9.3 / TSD §9.3's claim that Stage "mirrors production infrastructure (same MRT
bundle size class, same CDN/edge configuration, same SFCC realm tier)" is therefore **factually
wrong on region**, the single largest latency determinant — and Stage is the environment where the
contractual LCP ≤ 2s p75-mobile figure is supposed to be validated. Any Stage-measured LCP sign-off
would not represent production as currently configured.

**TEST is ALSO in `US East (Ohio)`** — so this is not a prod-specific slip. Region assignment across
the estate is **inconsistent and appears unmanaged**: Sydney = DEV, DEV1, SIT, STG; Ohio = TEST,
PROD; UAT unknown (not inspected). For a brand whose primary market and root storefront (`/`,
x-default) is AU. Note MRT's documented default for a new environment is `us-east-1` (N. Virginia),
**not** `us-east-2` (Ohio) — so Ohio was actively selected in both cases (or the UI's default differs
from the docs); either way it isn't simply "nobody touched the default". Reframe the TSD note
accordingly: the issue is inconsistent, undocumented region assignment, of which the Stage↔Prod
mismatch is the highest-consequence instance.

**STG has NO environment variables either** (user-confirmed) — so the tier designated as the
*contractual performance-test environment* is not stood up at all. Combined with Finding B (prod
empty, prod flag Disabled), both of the two tiers that matter most for go-live readiness are
unconfigured. Belongs on the same go-live checklist ticket, not this TSD.

**TEST is internally consistent** — org `****_005` / instance `bkzk_005` / OCAPI `bkzk-005`, matching
Confluence 05.6 exactly. 13 env vars, same shape as SIT, each with its own distinct
`COMMERCE_API_CLIENT_ID` (`****d762`), `PWA_KIT_SLAS_CLIENT_SECRET` (`****s2Yc`), and Contentful
delivery/preview tokens (`****uwRE` / `****f-wo`), sharing the same `CONTENTFUL_SPACE_ID`
(`****slxu`). STG's OCAPI → `staging-ap01-zimmermann.demandware.net` also matches Confluence. So
**per-tier credential hygiene and instance mapping are good everywhere except DEV1** — reinforcing
that DEV1's mixed `_002`/`bkzk_001` config is the lone anomaly.

**Another positive: the Contentful CPA-token boundary is being respected.** Per SFCC-249's design the
preview token should exist "only on dev/test/sit/uat, never on staging/production" — observed:
present on DEV, SIT, TEST; absent on PROD; STG has no vars at all. Compliant so far (UAT unchecked).

**Einstein nuance to state precisely:** `EINSTEIN_API_SITE_ID` is present on DEV but absent on **both**
SIT and TEST. Only SIT's absence is explained by documented policy (Confluence 05.6: "Never enable
Einstein, Global-e, or Narvar on SIT"). TEST's absence isn't covered by any rule I've found — it may
simply not be needed there. Don't claim TEST is policy-driven.

### Cross-environment summary table (as observed 2026-08-12)

| Env | Region | B2C instance | OCAPI proxy | Prod flag | Source Maps | Env vars |
|---|---|---|---|---|---|---|
| DEV | Sydney | `bkzk_002` | `bkzk-002` | Disabled | Enabled | 17 |
| DEV1 | Sydney | `bkzk_001` | `bkzk-001` | Disabled | Enabled | 7 (org ID says `_002` ⚠️) |
| SIT | Sydney | `bkzk_003` | `bkzk-003` | Disabled | Enabled | 13 (no Einstein — per policy ✓) |
| TEST | **Ohio ⚠️** | `bkzk_005` | `bkzk-005` | Disabled | Enabled | 13 |
| STG | Sydney | `bkzk_stg` | `staging-ap01-zimmermann` | Disabled | Enabled | **0 ⚠️** |
| Production | **Ohio ⚠️** | **None ⚠️** | `production-ap01-zimmermann` | **Disabled ⚠️** | Disabled ✓ | **0 ⚠️** |
| UAT | Sydney | `bkzk_dev` | `development-ap01-zimmermann` | Disabled | Enabled | 13 |

Common to **all seven** (pass now complete): MRT CDN, default `*.exp-delivery.com` hostname (**no
custom domain anywhere**), Log Filtering `Info`, Server-Side Cookie Access **Enabled**, no IP
allowlist, no access-control header, Proxy User Agent `Infrastructure`, SCAPI proxy → `qmyt7hks`,
all 8 Site IDs (except Production: none), Production Environment flag **Disabled** on every single
environment including Production itself.

**UAT** is internally consistent and matches Confluence 05.6 exactly (org `****_dev` / instance
`bkzk_dev` / OCAPI `development-ap01-zimmermann.demandware.net`). 13 vars, same shape as SIT/TEST,
own distinct `COMMERCE_API_CLIENT_ID` (`****108e`), `PWA_KIT_SLAS_CLIENT_SECRET` (`****H5g8`), and
Contentful tokens (`****FvBg` / `****84Fc`), shared `CONTENTFUL_SPACE_ID` (`****slxu`). Nice
corroborating detail: UAT's `COMMERCE_API_OCAPI_HOST` masked value ends `.net` (a
`*-ap01-zimmermann.demandware.net` realm host) while DEV/TEST/SIT end `.com`
(`bkzk-00N.dx.commercecloud.salesforce.com` sandbox hosts) — exactly the split Confluence's table
implies. CPA preview token present on UAT ✓, so the "dev/test/sit/uat only, never staging/production"
boundary holds across all seven.

### Text-form re-verification of all 7 environments (2026-08-12) — zero discrepancies

User re-sent every environment as plain text rather than screenshots. Cross-checked all seven
line by line against the screenshot-derived records above: **every variable name, every masked
suffix, and every setting matches exactly. No corrections needed.** This also removes any doubt
about the ARM/x86 finding — the complete text field listing for the Advanced section is CDN,
Hostname, Region, Log Filtering, Server-Side Cookie Access, Source Maps, Allowed IP Addresses,
Proxy Configs, Proxy User Agent, Delete Environment. **No Server Architecture field exists**, so
that's now confirmed from a full text enumeration, not screenshot inference.

**Text verification now COMPLETE across the whole pass** — all 7 environments plus Project Users
and Project Settings, all re-checked line by line, **zero discrepancies against the
screenshot-derived records**. Project Settings in text form confirms **Environment Defaults contains
exactly two fields** (Server-Side Cookie Access, Proxy User Agent) — so the ARM/x86 control is
definitively absent at *project* level too, not just per-environment. That's the doc discrepancy
triple-confirmed (project page, environment page, all 7 environments). Project Users confirms 4
users, all Admin. PROD confirms zero env vars, B2C instance `None`, empty Site IDs, Production flag
Disabled, Region Ohio, Source Maps correctly Disabled.

**One detail the text side-by-side surfaced, investigated, and CLOSED as a non-issue —
`CONTENTFUL_HOST` exists only on DEV, not on SIT/TEST/UAT.** My first instinct was that this might
break Contentful preview on the three tiers that carry a `CONTENTFUL_PREVIEW_TOKEN` but no host
var. **Checked the code — it does not.** `CONTENTFUL_HOST` appears in exactly two places repo-wide
(`.env.sample:150` as an empty declaration, and `tsd-architecture.md:153` as a doc reference) and
is **read by no code at all**. `overrides/app/config/contentful.ts` hardcodes both hosts as
constants (`CONTENTFUL_PREVIEW_HOST = 'preview.contentful.com'`,
`CONTENTFUL_DELIVERY_HOST = 'cdn.contentful.com'`) and its `ContentfulConfig` type has only four
fields (`spaceId`, `accessToken`, `environment`, `previewAccessToken`) — no host field. So
`CONTENTFUL_HOST` is a **vestigial env var**: declared in `.env.sample`, documented in the TSD, set
on DEV, consumed by nothing. DEV having it is harmless dead config; the others lacking it is
functionally irrelevant. Only worth a line in `.env.sample`/TSD cleanup — and it's one more small
instance of the recurring "documented config has drifted from actual config" theme alongside
`mobify.config.js` and the MRT-vs-bundle proxy duplication.

### FINAL region tally — Finding A in its sharpest form

**Sydney (5): DEV, DEV1, SIT, UAT, STG. Ohio (2): TEST, PROD.**

Stated cleanly: the promotion path is DEV → TEST → SIT → UAT → STG → PROD, and **every
business-and-performance validation tier (SIT, UAT, STG) sits in Sydney while Production sits in
Ohio.** So the entire validation chain is region-unrepresentative of the environment it validates
*for* — including STG, which `architecture.md` §9.3 designates as the tier where the contractual
LCP ≤ 2s p75-mobile number is signed off, and UAT, where the business accepts the experience.
TEST (Ohio) is additionally unrepresentative of the SIT/UAT/STG tiers it feeds. Production's own
SFCC backend is `production-ap01-zimmermann` (Asia-Pacific), so prod as configured would also
cross the Pacific for every SSR-side OCAPI call. Nothing is live yet (prod + stg both have zero env
vars), so this is entirely fixable pre-go-live — Region is an editable field.

**Scope discipline:** Findings A and B are **not** MRT-app-topology questions — they're environment
configuration/go-live-readiness issues that exist identically under Option A or B. They should be
raised as their own ticket(s), not folded into this TSD (one TSD = one problem). Finding A *is* worth
one sentence in the TSD's §2 Constraints or §7 Risks, because the LCP ≤ 2s constraint is one of the
ticket's named recommendation criteria and the region mismatch materially affects it either way.

**Still open after this pass:** (a) **how many projects exist in the Zimmermann org** — the PROJECT
dropdown, still unchecked, directly relevant to Option B headroom; (b) **ARM vs x86** — not
answerable through the UI (see above); needs the MRT API or Support, or gets recorded as an open
item; (c) the commercial cost of an additional project (account team, not Runtime Admin); (d) **STG's
region** — see Finding A.

**Superseded pre-Runtime-Admin list:**

**Superseded — the pre-Runtime-Admin version of these opens:** (1) Zimmermann's actual commercial cost for an *additional project* specifically;
(2) current environment/production-count usage against the 100/10 org caps, to know real headroom;
(3) whether the existing `zimmermann` project runs ARM or x86 (x86 retires 2027-01-31; ARM is
default for anything created after its introduction); (4) the server-side-cookie collateral check
above. None of these require Claude — they're one-glance-at-Runtime-Admin facts for whoever has
access (the user has Managed Runtime access per role, presumably).

## Related people/tickets confirmed live 2026-08-10

Gideon Linsangan (SFCC-241, MuleSoft sync spike, In Progress — his MuleSoft work is directly
relevant since `mulesoft` is the highest-connection-pool-cap pool in §12.1 and a key input to any
per-integration boundary discussion). Manikandan Ramachandran owns epic SFCC-1. SFCC-254
("Environment Setup DEV/TEST/SIT/UAT") is now assigned to **me** per live JIRA (a prior memory had
it on Victor Crisostomo — that's stale, trust this live check) and structurally sequences after
this ticket's topology decision. SFCC-249 (Contentful TSD redo, Code Review, Jhoan) cross-
references "SFCC-237 — TSD in progress" in its own Confluence page (346783750) as a dependency
note, not a shared deliverable.

## Exhaustive re-verification 2026-08-11 — zero contradicting evidence found

Ran a full unbiased V&V of the connection-pool/blast-radius finding across codebase, docs,
Confluence, and JIRA (an Explore agent independently re-checked all 11 angles: file content,
repo-wide grep, every fetch call, git log, package.json deps, existing test coverage, doc text,
resilience-library sweep). **Every prior finding confirmed, nothing changed.** New precision
added: the 7 pools split into two groups — 4 (`sfcc-scapi`, `sfcc-payments`, `marketing-cloud-auth`,
`marketing-cloud-rest`) correspond to integrations with real, currently-shipping `fetch()` calls
that bypass their pool today; the other 3 (`mulesoft`, `google-places`, `booxi`) correspond to
features with **no implementation at all yet** — those pools were built speculatively, ahead of
the feature code. Both groups are "100% unused," just for different reasons. Also confirmed:
`overrides/app/ssr/` (where all 4 relevant files live) is Tier 1 in three separate rule docs
(`frozenFiles.md`, `.cursor/rules/tier1FrozenFiles.mdc`, `copilot-instructions.md`) — a plausible
institutional reason the gap has persisted, not just oversight.

**Cross-checked the Confluence-published counterpart of `.docs/temp/tsd-architecture.md`** —
"Technical Solution Design – PWA" (Confluence 256835585, v11, the actual page other TSDs cite as
"PWA TSD"). Its §12.1 Blast-Radius Containment section, including the full pool table, is **word-
for-word identical** to the local file — no drift on the finding itself. It does have its own,
unrelated drift: §14.1's tier ordering reads Local→Dev→SIT→**Stage→UAT**→Prod, the reverse of
both local files' (`architecture.md` and `tsd-architecture.md`) Local→Dev→SIT→**UAT→Stage**→Prod
— i.e. even within the *same* document family, the Confluence-published copy disagrees with its
own local-repo source on this point, not just with the separate Environment Topology page already
tracked in [[project-env-topology-doc-conflicts]]. Logged there, not central to this ticket.

**Found via SFCC-249 (a mature, v43, heavily-reviewed sibling TSD for Contentful, Confluence
346783750) — a legitimate, currently-unaddressed correction to the exact section this TSD will
build on.** Its §5.4/§7 flag: "PWA TSD 12.1 states Contentful connection isolation is 'not
achievable'; the SDK does expose `httpsAgent`/`httpAgent`/`adapter`." This is technically sound —
the `contentful` v11 SDK is axios-based, and axios does support connection-agent configuration,
just not undici's specific `dispatcher` option the other 7 pools use. Doesn't change the core
finding (Contentful isn't one of the 7 pools; it's browser-direct today per SFCC-249's own note,
so this is moot until/unless SSR-first Contentful fetching is adopted) — but worth citing
accurately rather than repeating the PWA TSD's over-broad "not achievable" framing verbatim.
Correction is logged in SFCC-249's own Risks table, owner "PWA TSD owner," still open — not this
ticket's job to fix, but good to know it's already flagged elsewhere.

**SFCC-249 is also a directly useful precedent for how this team actually writes a TSD from the
352419841 template in practice** — worth matching its conventions: lists multiple authors/
reviewers when more than one person contributed (here: Gideon should likely appear alongside
Tim, matching how SFCC-249 lists both a BA Lead and a Solution Architect as reviewers, since the
ticket names both Gideon and Angelo as required collaborators); adds a `References` section at
the end (not in the raw template but clearly accepted practice); uses Appendices for
ticket-required content that doesn't fit the 8-section shape, explicitly labelling it as an
intentional addition. Its own Decision Record confirms Tim (the Solution Architect / sign-off
authority) is on record expecting SFCC-237's TSD as a separate deliverable: *"MRT-app architecture
is out of scope here; covered by a separate TSD (SFCC-237). — Keep this TSD scoped to one
problem."* — direct corroboration that Tim is tracking this and expects it to land.

## Skeptical re-verification 2026-08-12 — tried hard to find existing coverage, found none, found something worse instead

User was unconvinced Tests 1-3's findings were genuinely uncovered and asked for an intensive,
skeptical re-dive across codebase/docs/configs/Confluence/JIRA specifically hunting for existing
mitigation. Actively tried to overturn the finding rather than confirm it. **Found zero existing
coverage anywhere** — no error-handling wrapper/middleware (`asyncHandler`, `express-async-errors`,
4-arg Express error middleware — none exist, repo-wide grep confirms), no `process.on(
'unhandledRejection', ...)` anywhere (repo-wide, not just `worker/main.js`), no worker-thread/
CPU-offload mechanism, no per-region isolation mechanism, no JIRA ticket or Confluence page on any
of the three specific failure categories (broad OR-term JIRA searches returned only unrelated
noise; Confluence searches returned empty).

**Found something more severe instead, while reading `overrides/app/ssr.js` in full for the first
time (route-registration code, not just the imports already known):** the real production call
sites for `sendMagicLinkEmail` (`ssr.js` lines ~150-178, both the passwordless and reset-password
routes) call it **inside a `.then()` callback whose returned promise is never itself `return`ed or
chained** — e.g. `validateSlasCallbackToken(token).then(() => { sendMagicLinkEmail(...); })` with
no `return` before `sendMagicLinkEmail(...)`. This is worse than "missing try/catch": it's a fully
orphaned floating promise. Test 1 (correctly, as a unit test) calls the function directly and
awaits it — a valid way to test the function's own behavior. But the **actual deployed code never
awaits or catches it at all**, so a rejection there isn't just "could break a `Promise.all` a
caller wrote" — it becomes a genuine Node-level unhandled-promise-rejection event with nothing
downstream watching for it, at the real call site, today. Confirmed no global
`unhandledRejection`/`uncaughtException` handler exists anywhere to soften this.

**Test 1b built 2026-08-12, all green.** Before building it, checked whether an unhandled rejection
here would crash the whole MRT process — read `@salesforce/pwa-kit-runtime`'s actual installed
source (not speculation): `build-remote-server.js:1794` registers `process.on('unhandledRejection',
catchAndLog)`, and `catchAndLog` (`utils/ssr-server/utils.js:64-74`) only logs — no `process.exit`,
no re-throw. Since a listener exists, Node's "unhandled rejection kills the process" default
(v15+) does not apply — **the server does not crash.** This ruled out the higher-risk/higher-effort
child-process crash-verification approach entirely; no need to build it.

The real, precise consequence instead: nothing ever calls `res.send`/`json`/`status` on that
shopper's response, so the request is left to run out MRT's own 20s/16s execution ceiling
(`mrt-overview.md`) and return a generic 502 with the actual cause logged but never surfaced.
Test 1b reproduces the exact ssr.js call shape (`void Promise.resolve().then(() => { void
sendMagicLinkEmail(...); })`, matching lines ~150-178) and asserts both that it becomes a genuine
process-level `unhandledRejection` (via a `process.once` listener with `try/finally` cleanup,
mirroring — not replacing — pwa-kit-runtime's own real safety net) and that the mock `res` is
never called. First run surfaced a real gotcha: Vitest separately flags a truly-unhandled
rejection as a stray run-failing error even when the test's own assertions pass (exit code 1
despite "1 passed") — capturing it via the listener fixed this and let the test assert on the
exact rejection reason too. Two lint fixes needed: `void` on both floating-promise call sites
(explicit-intent marker, zero runtime effect, keeps the orphaned shape genuine) and a justified
`eslint-disable` on 3 `not.toHaveBeenCalled()` assertions (known false-positive on plain `vi.fn()`
mocks under `@typescript-eslint/unbound-method`). `npm run test` / `eslint` / `tsc --noEmit` all
clean, 4/4 tests passing. Not committed yet.

**Why:** re-verified everything from the 07-30 pass plus went deeper (node_modules tracing,
Confluence Test-tier cross-check, full JIRA ticket text + changelog, fresh grep sweep, exhaustive
unbiased re-check 08-11 including the sibling SFCC-249 TSD and the Confluence-published PWA TSD).
Every prior finding held up and several got sharper root causes; nothing has changed in the
underlying files (git log confirms zero commits to the flagged files since 07-30).
**How to apply:** the as-is baseline section of the TSD can be written now, fully sourced from this
memory, and can cite SFCC-249 (346783750) as a template-usage precedent. The options analysis /
recommendation (§3-4) genuinely cannot be finalised without the Gideon/platform conversation
above — surface that to the user before drafting those sections rather than guessing at platform
capability or cost. **Track this work against SFCC-681 going forward, not SFCC-237.**
