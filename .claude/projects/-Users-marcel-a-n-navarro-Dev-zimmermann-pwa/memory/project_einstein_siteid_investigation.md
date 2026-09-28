---
name: project-einstein-siteid-investigation
description: "EINSTEIN_API_SITE_ID / aaij-MobileFirst is unmodified Salesforce SDK demo boilerplate, not a real Zimmermann value — real setup is JIRA SFCC-112, still In Refinement. Never enable Einstein on SIT."
metadata: 
  node_type: memory
  type: project
  originSessionId: 8a3c90dc-1e73-41af-8c87-71e6db7e2556
  modified: 2026-09-17T07:02:34.888Z
---

**`aaij-MobileFirst` (+ einsteinId `1ea06c6e-c936-4324-bcf0-fada93f83bb1`) is NOT a Zimmermann value — it's unmodified Salesforce retail-react-app SDK demo boilerplate.** Verified byte-identical to `node_modules/@salesforce/retail-react-app/config/default.js:82,84` (Salesforce's own reference-architecture demo storefront credentials). `git log -S` confirms both values entered `config/default.js` in the very first commit (`cd60b7a` "Initial commit during Detailed Design phase", Hardi, 12 Jun) and have never been touched since — nobody at Zimmermann ever configured this.

**Live-tested and confirmed working** (curl replicating the exact SDK request): `aaij-MobileFirst` → `200 OK` with real `{uuid, requestId}`. Any other siteId (e.g. `ZimmermannAU`, `undefined`) → `400 {"error":{"code":"InvalidClientId","message":"The Client ID in the request does not have access to the site ID in the request"}}`. So it "works" only because it's Salesforce's own demo tenant that the shared einsteinId happens to be authorized for — not because Zimmermann has a real Einstein site.

**Real setup is tracked and NOT done:** JIRA **SFCC-112** "Recommendations – Einstein Configuration & Zone Setup" (labels SPR-59/SPR-63, Squad-B) — status **In Refinement**, description: "Einstein Recommendations provisioned and recommendation zones configured in Business Manager... before any PWA carousel work begins." Related: SFCC-7 (Search & Recommendations epic), SFCC-647 (updated 2026-08-10), SFCC-642 (Einstein AI Sort BM config), SFCC-118 (carousel UI), SFCC-106 (consent-gating for tracking). Confluence "8.1 Technical Files (Zimm Provided)" (253362177-adjacent, id 264765445) has an EMPTY row for "Salesforce Einstein" — no credentials ever handed over by the client. A "Search & Recommendations Workshop part 2" was scheduled 2026-08-10–14 (active as of this finding).

**⚠️ CRITICAL — Never enable Einstein on SIT.** Confluence "05.6 - Environment Details" (id 285540356) explicitly: *"Never enable Einstein, Global-e, or Narvar on SIT — see config/sit.js."* SIT is a dedicated isolated env for NewStore order-management integration testing. BUT `config/sit.js` has NO actual code enforcing this (only overrides SCAPI/OCAPI proxy hosts) — enforcement today is purely "leave the env var blank," not a code gate. I had filled `EINSTEIN_API_SITE_ID` into local `.env.sit` during a fix-verification pass (2026-08-10) — reverted to blank same session per user instruction ("revert and hold-off") once this policy was found. `.env.dev`/`.env.test`/`.env.uat` still have the value locally (not policy-restricted) but were NEVER pushed to GitHub Environments (confirmed 404 on the var across all environments) — holding off on any push pending SFCC-112 resolution, per user decision.

**Recommendation given (accepted):** don't push this demo credential to any GitHub Environment — it's a throwaway fix for a story (SFCC-112) already in progress; real Einstein provisioning should replace it. Raise with whoever owns SFCC-112 (Squad B) rather than quietly wiring the demo value into shared config.

**Confirmed by full codebase/git-history sweep (2026-08-10, Explore agent, 126 tool uses):**
- Byte-for-byte match to `node_modules/@salesforce/retail-react-app/config/default.js:80-86` (pinned SDK v10.0.0) — Salesforce's own "RefArchGlobal" demo config (org `f_ecom_zzrf_001`, shortCode `8o7m175y`). The SDK's own comment (`// This differs from the siteId in commerceAPIConfig for testing purposes`) was DROPPED when copied into config/default.js — only the unrelated isProduction comment survived.
- `.env.sample` scope:tier comparison: of 13 tier-scoped SFCC-adjacent credentials, EINSTEIN_API_SITE_ID is the ONLY one with a real-looking non-blank/non-TODO default — every sibling (COMMERCE_API_*, CONTENTFUL_*, GLOBALE_*, ADYEN_*) is blank or `TODO`.
- Only live runtime use anywhere in overrides/: `einstein.sendViewPage(pathname)` in home/index.tsx:152 (page-view beacon only). `RecommendedProducts` component (actual recs rendering) has ZERO consumers per the registry — Einstein isn't even rendering anything yet, just firing tracking pings.
- **SIT-disable was documented as "done" but was NEVER implemented.** A deleted doc (`docs/environments/sit.md`, removed in migrate-to-Confluence commit) + `.docs/prompts/omsIntClaudeCodePrompt.md:326-333` (marked "Status — done... already implemented") both describe an aspirational `config/sit.js` snippet: `einsteinAPI: { enabled: false }` with comment "avoid polluting recommendation data." Checked config/sit.js's full history (3 commits total) — this was NEVER added; sit.js only ever overrode SCAPI/OCAPI proxy hosts. ALSO: even if it had been added, the base `useEinstein()` hook has no `enabled` flag check at all (only destructures host/einsteinId/siteId/isProduction) — the killswitch wouldn't have worked anyway. So the team knew/worried about this and documented a fix that was never real.
- No `.docs/integration/` doc exists for Einstein specifically — folded into 01-sfcc.md as 3 minor bullets (recs are consent-gated, Didomi purpose TBC, falls back to static merchandising group on no-consent or 5xx). No "credentials" section anywhere, unlike every other integration doc.
- PRD sign-off (`.docs/prd/search.md`): SPR-63 "confirmed and signed off 2026-05-08" is about the PLATFORM CHOICE (Einstein vs Athos Commerce) only — never about this specific credential. CAI-005 cross-sheet contradiction (RJ: "99% likely we will move away from Athos") still open in cart.md.
- Residual honest caveat from the agent: cannot see actual GitHub Environment/MRT secret values from a static repo scan — can't 100% rule out a different real value was set out-of-band without ever being reflected in .env.sample. Worth closing out directly with the Integration Lead / whoever owns CQuotient BM for the bkzk realm.

**Unrelated bug SOLVED using the same methodology (2026-08-10) — Shopper Context 412 on test/sit/uat.** Root cause is NOT a code bug — it's an SFCC org-level feature toggle. Direct SCAPI probe (fresh random usids, multiple sites, reading full JSON error body via `scripts/sfcc/_shared.mjs`'s getSlasToken, hitting shopper-context v1 directly) returned the literal SFCC error on ALL of test(bkzk_005)/sit(bkzk_003)/uat(bkzk_dev), 7/7 requests each, zero variance across usid or site: `{"title":"Shopper Context Pre Condition Not Met","detail":"...Pre-condition: The feature toggle ShopperContextEnabled is not enabled."}`. Dev (bkzk_002) has this toggle ON (inferred from Jesse's original real-browser 404 = genuinely-not-found, not precondition-failed; my own direct test of dev returned a DIFFERENT error — `400 usid-token-mismatch` — because my test script's usid didn't match the SLAS token's internal usid, an artifact of not passing a matching usid to getSlasToken, NOT evidence about dev's toggle state). **Actionable ask for BM/Integration:** enable `ShopperContextEnabled` for the SFCC orgs backing test/sit/uat to match dev. Not fixable in code — pure BM/Account Manager config.

Cross-cutting lesson: same pattern as [[env-topology-doc-conflicts]] — docs (Confluence AND a since-deleted local doc) describe safeguards/rules the code never actually implements; always grep the referenced config file before trusting a "see config/X.js" citation, and check git history to see if an aspirational snippet in a prompt/doc actually landed.

---

## DNT gate — Einstein is OFF by default in this app (added 2026-09-07, code-verified)

**Every Einstein call in the storefront returns `{}` unless a `dw_dnt=0` cookie exists.** Verified chain,
each link read directly:

1. `node_modules/@salesforce/retail-react-app/app/constants.js:216` → `DEFAULT_DNT_STATE = true`
2. `overrides/app/components/_app-config/index.tsx:196` → `defaultDnt={DEFAULT_DNT_STATE}`
3. `node_modules/@salesforce/commerce-sdk-react/auth/index.js:337-339` → `getDnt({includeDefaults:true})`:
   no `dw_dnt` cookie → `effectiveDnt = defaultDnt` (= `true`)
4. `node_modules/@salesforce/commerce-sdk-react/hooks/useDNT.js:34` → `effectiveDnt` comes from that call
5. `use-einstein.js:458` → `dnt: effectiveDnt` into `EinsteinAPI`
6. `use-einstein.js:156` → `einsteinFetch`: `if (this.dnt !== false) return {}`

**`updateDnt` (useDNT.js:39) is the ONLY thing in the entire SDK that calls `setDnt`, and nothing in
`overrides/` calls `updateDnt`.** Zero hits for `dw_dnt`/`updateDnt`/`useDNT`/`Didomi` anywhere under
`overrides/app`. So no shopper ever gets the cookie.

This is *correct* fail-closed consent behaviour per AGENTS.md — but the consequence is that **SFCC-106
(consent gating, Blocked) is a hard dependency of SFCC-83, not the "relates to" link Jira records.**

**Status: code-verified, NOT browser-verified.** Decisive test is to set `document.cookie = 'dw_dnt=0;
path=/'` and reload — if the rail populates, confirmed. Marcel took this to verify live 2026-09-07.
Tension to resolve: he previously reported seeing an unbrowsed product in the rail, which implies data
was flowing at some point.

## Recently Viewed — vendor behaviour, now documented (2026-09-07)

- **Cross-device for logged-in shoppers is documented**, closing the residual left open 2026-09-04:
  Salesforce defines `userId` as *"Unique identifier of a logged-in shopper that enables Einstein to
  link the same logged-in user across multiple devices."* The SDK sends it on both write and read.
  SFCC-83 AC 7 is satisfiable by the mechanism already wired.
- **`Recently Viewed` is a single-strategy recommender — it CANNOT backfill.** Salesforce: *"The
  Recently Viewed and Complete the Set recommender types use only one strategy."* So the two-product
  prefix seen against the demo org is a *configuration* artefact (pinned/included products on that
  org's recommender), not intrinsic recommender behaviour. Turns the parked Bianca question into a
  one-line ask: don't pin/include any products on Zimmermann's Recently Viewed recommender.
- **The recommender NAME is an unverified string contract.** `viewed-recently-einstein` is hardcoded in
  base `constants.js:154-163` (both `PDP_RECENTLY_VIEWED` and `CART_RECENTLY_VIEWED` = same string).
  BM recommender names are user-defined, and **no Confluence page anywhere maps Einstein recommender
  names to UI surfaces** — "recommendation zone" appears nowhere in the space. Wrong name = silently
  empty rail.

## Jira/Confluence deltas re-verified 2026-09-07

- **SFCC-112 is now `Blocked`** (was In Refinement). Its zones cover Recommended-for-You and
  More-from-Category — still **no Recently Viewed zone**. RV is a *recommender*, not a zone, so it
  likely needs Einstein merely enabled, not SFCC-112's zone work.
- **SFCC-647 "Review Einstein Recommendation Capabilities" is CANCELLED** — this is why no Einstein
  capability findings are documented anywhere.
- **No TSD exists for Einstein or recommendations** (19 TSDs exist; none covers it). Three Search &
  Recommendations workshops are marked Complete with **zero artefacts** — Open Questions cells still
  read "TBD", page has no children.
- Einstein still has **no credentials row** on 7.1b and an **empty** documentation cell on 8.1 (page
  touched 2026-09-03, so current). No Didomi purpose ID assigned for Einstein or Recently Viewed.
- `EINSTEIN_API_SITE_ID` is **empty in `.env.staging` and `.env.prod`** (as well as `.env.sit`, which
  is deliberate). Staging/prod blanks are a go-live gap, not policy.
- `.docs/integration/01-sfcc.md:78` is wrong twice: says GET (it's POST), and promises a "static SFCC
  merchandising group" fallback that **does not exist in code** — `einsteinFetch` returns `{}` and the
  rail renders nothing.
- Doc conflict: SPR-61 says Recently Viewed on **PDP and Cart**; Confluence 04.7 Component Inventory
  says **PDP only**. The SFCC-83 build wires both.

See [[prove-dont-assert]] — the DNT chain was read link-by-link rather than inferred from the top constant.

## 🔴 Einstein is "Not Deployed" for every real Zimmermann site — the foundational layer (2026-09-07, Marcel/BM screenshots)

**The deepest of three independent, stacking blockers, now fully mapped.** Marcel checked the
Einstein Status Dashboard (BM: Administration > Operations > Einstein Status Dashboard) on three
separate sandboxes — BKZK_002, BKZK_003, BKZK_005 — and got an identical result on all three: **all
8 sites** (AU, EU, EUIntl, HK, ME, UK, US, USIntl) show **Einstein Status: Not Deployed**, **Data
Quality: Not Available**, and **Catalog Runs / Order Runs both `—` (never run, ever)**. He also
checked Global Preferences > Einstein Search Dictionaries Opt-In on the same three sandboxes: the
"I accept these terms and conditions" checkbox is unticked and Save is disabled on all three, with
the page's own note that *"the state of the agreement can only be changed on a Staging instance"* —
so this can't even be self-served from a sandbox.

**Why this is the root layer, not just a third data point:** "Not Deployed" + zero catalog/order
runs means there is no trained recommendation model behind any Zimmermann site at all — a gap that
sits *before* either of the other two documented issues:
- Even with [[project-einstein-siteid-investigation|`EINSTEIN_API_SITE_ID` corrected]] to a real
  Zimmermann site, there would be no deployed engine on the other end to answer it.
- Even with the DNT gate (above) fixed/bypassed, a request that actually reaches Einstein would hit
  an undeployed engine with no catalog/order history to recommend from.
- The only Einstein responses anyone has ever actually observed (the `200 OK` demo-siteId curl test,
  the "single-strategy recommender, two-product baseline" analysis, Marcel's live "stuck on one
  product" report) were **all against Salesforce's own `aaij-MobileFirst` demo tenant** — a
  pre-existing Salesforce demo instance unrelated to Zimmermann's own catalog — not against any real
  Zimmermann deployment, because no real Zimmermann deployment has ever existed to test against.

**Blast radius: not specific to Recently Viewed (SFCC-83/84).** Every Einstein-powered surface —
PDP Complete-the-Set, PDP/Cart Might-Also-Like, the add-to-cart-modal recs, PLP empty-search
top-sellers/most-viewed, and the new Recently Viewed rail — depends on the same undeployed
platform-level engine. None of them can return real, personalized data on any real Zimmermann site
in any environment today, independent of any frontend code.

**Consistent with, not contradicting, the existing SFCC-112 finding above:** SFCC-112
("Recommendations – Einstein Configuration & Zone Setup") being **Blocked** now reads as blocked on
exactly this — platform-level Einstein activation plus initial catalog/order feed export — which is
very plausibly Salesforce/Account-Rep-level provisioning work, not something self-serviceable from
BM by Zimmermann or the SI partner (consistent with the opt-in being locked to Staging-only).

**Not yet done, deliberately left to Marcel:** escalating this (owner is already tagged as Bianca on
the related finding-28/backfill question above) and any sprint/Definition-of-Done consequence for
the wider personalization epic — this is a cross-team platform-provisioning decision, not something
to action unilaterally from a build session.

## Full round-trip live-confirmed (2026-09-08) — plumbing works, data is foreign

Marcel asked "how do we use that key, what APIs are available" as a sidequest. Direct curl,
bypassing `useEinstein()`'s DNT gate entirely, confirms both endpoint families genuinely work
against the demo tenant:

- **`getRecommenders`** (`GET /v3/personalization/recommenders/aaij-MobileFirst`) → `200 OK`, 20
  recommenders configured, including `{"name":"viewed-recently-einstein",
  "recommenderType":"recently-viewed"}` — byte-identical to our own hardcoded
  `EINSTEIN_RECOMMENDERS.PDP_RECENTLY_VIEWED`/`CART_RECENTLY_VIEWED` string. Confirms *why* the SDK
  example uses that exact string: the base retail-react-app was built/tested against this same
  Salesforce demo tenant, which happens to ship a recommender with that name already configured.
- **`getRecommendations`** (`POST /v3/personalization/recs/aaij-MobileFirst/viewed-recently-einstein`,
  body `{"products":[],"realm":"aaij","instanceType":"sbx"}`) → `200 OK`, returned 2 real products
  (`11736753M` "Summer Bomber Jacket", `12416789M` "Straight Leg Trousers") with working image/product
  URLs on `zzcu-007.sandbox.us01.dx.commercecloud.salesforce.com` — Salesforce's own men's-apparel
  demo storefront. This is the concrete evidence behind the "two-product baseline" line above —
  previously inferred from docs, now directly observed with real response data.

**Confirms, doesn't change, the existing three-layer-blocker conclusion.** Auth (static
`x-cq-client-id` header, no OAuth) and both endpoint families work correctly end-to-end — but the
returned product IDs belong to Salesforce's demo catalog, not Zimmermann's, so a follow-up
`getProducts` against Zimmermann's real SFCC instance would find nothing. Independently, none of
this is reachable through the live storefront anyway (DNT gate above), and even a corrected siteId
would hit an undeployed engine (Einstein Status Dashboard section above). All three blockers are
separate and each independently sufficient — fixing only one doesn't unblock Recently Viewed via
Einstein.

## Real per-visitor personalization CONFIRMED live (2026-09-08) — mutation-tested, not asserted

Marcel asked directly: "does it return any products under recently viewed?" Rather than infer from
the static 2-product response above, ran an actual before/after mutation test against a
never-before-used `cookieId`:

1. Fresh `cookieId` (`sfcc83-verify-<timestamp>`, never used before) → `getRecommendations` on
   `viewed-recently-einstein`, empty `products` → same 2 fixed products as always
   (`11736753M`, `12416789M`).
2. `sendViewProduct` (`POST /v3/activities/aaij-MobileFirst/viewProduct`) for that **same
   cookieId**, product `25519318M` (a genuinely different, freshly-harvested real catalog ID,
   confirmed via a `products-in-all-categories` call first — not a guess) → `200 OK`.
2. Immediately re-queried `viewed-recently-einstein` with the **same cookieId** → now returned
   **3 products**: the same 2 fixed ones **plus `25519318M` appended** — no batching delay, no
   cache lag.
3. Also tried the *other* same-typed recommender found in the full 20-recommender list,
   `recently-viewed` ("Shopper, Recently-Viewed") → returned **only `25519318M`**, no pinned
   filler at all.

**This settles two things conclusively:**
- **Real per-visitor Einstein view tracking genuinely works, live, immediately** — this is not a
  static/fallback-only mechanism. If DNT + platform-deployment were both resolved and pointed at a
  real Zimmermann site, this exact mechanism would produce real personalized recently-viewed data.
- **The "two-product baseline" (memory above, "single-strategy recommender... configuration
  artefact") is now proven, not inferred** — `viewed-recently-einstein` specifically has 2
  products pinned/included in its BM config on this demo tenant, added on top of genuine per-visitor
  history. A same-type sibling recommender (`recently-viewed`) has zero pinning and reflects only
  real tracked views. This is a **per-recommender BM configuration choice**, not an inherent
  limitation of the `recently-viewed` recommender type — so Zimmermann's own recommender (once
  Einstein is actually deployed) should be built with no pinned/included products, matching
  `recently-viewed`'s behaviour here, not `viewed-recently-einstein`'s.

Net effect on the standing conclusion: unchanged — still blocked by DNT (not reachable from the
live app) and by platform non-deployment (Einstein Status Dashboard, "Not Deployed" on all 8 real
sites) — but this closes out any residual doubt that the *mechanism itself* is sound. The blockers
are entirely about reachability/deployment, not about whether Einstein's recently-viewed feature
actually does what it claims.

## Re-confirmed 2026-09-15 — still true, right before the Einstein-wiring PR opened

Re-checked `EINSTEIN_API_SITE_ID` presence across all 7 relevant GitHub Environments (`dev`,
`test`, `sit`, `uat`, `staging`, `prod`, `shared`) as both a variable and a secret — absent from
every single one, still. Nothing has changed since the 2026-08-10 finding. Raised directly with
Marcel during the SFCC-83+84-einstein Einstein-wiring build/PostBuild session — this is the third,
independently-confirmed-still-open blocker (alongside DNT-defaults-ON and platform non-deployment)
that stacks on top of whatever this new branch wires up. None of the three are fixable in that
branch's own code.

## Browser-verified live against PR #116's own MRT Preview (2026-09-17) — DNT gate confirmed live, closes the "not yet browser-verified" gap

Tim suggested testing PR #116 (the Einstein-wiring branch, now open as a PR) by watching for a
200/204 in the console on a sandbox. Rather than reason from the code-read chain above, tested
directly against PR #116's own live MRT Preview
(`https://zimmermann-pr-f83-acee696a.sfdc-8tgtt5-ecom1.exp-delivery.com`, no worktree/dev-server
needed — every PR gets one automatically via `deploy-preview.yml`, posted as a PR comment).

- Home page load, a search results page, and a full PDP load (`8637DS241`, Natura Mini Dress) —
  checked Network tab each time — **zero requests to any Einstein/personalization/activities/
  cquotient endpoint fired, at any point.** Not a 400, not a failed request — no attempt at all.
  This matches the DNT short-circuit (`einsteinFetch: if (this.dnt !== false) return {}`,
  memory above) actually holding in the real deployed build, not just in a static code read.
- Attempted the "decisive test" this file flagged as pending 2026-09-07
  (`document.cookie = 'dw_dnt=0'` + reload): **the cookie did not survive a full-page reload** —
  gone from `document.cookie` immediately after, tried once plain and once with an explicit
  `max-age=31536000` to rule out a session-cookie explanation. The site's own `usid_*`/`cc-nx-g_*`
  cookies persisted fine across the same reloads, so this isn't a general cookie-handling
  failure — something in this build's own bootstrap/hydration specifically drops a manually-set
  `dw_dnt` cookie. Root cause not diagnosed (would need reading the live SLAS/auth init path) —
  flagged, not resolved. Practical effect: even a developer who knows about the DNT gate and
  tries to manually bypass it for a quick console check cannot currently do so by just setting
  the cookie and reloading.
- **Corrects Tim's framing, not just this PR's testability:** "if we see 200/204 on a sandbox,
  Einstein is being called correctly" assumes the call reaches the network layer at all. On this
  build, it never does, regardless of sandbox/environment — the DNT default blocks it identically
  everywhere, independent of whether Einstein itself is deployed. So "watch the console on a
  sandbox" cannot currently produce a 200/204 either way; a silent console is the *expected*
  result today, not evidence the wiring is broken.
- **This closes the "Status: code-verified, NOT browser-verified" line from 2026-09-07** — now
  browser-verified, against the real PR build, and the result matches the code-read prediction
  exactly. Doesn't touch the separate open "tension" (Marcel previously reported seeing an
  unbrowsed product in the rail) — didn't get far enough to observe rail contents since no rail
  ever populates without a live Einstein response.
- **Reusable technique:** any PR on this repo can be live-tested via its own `deploy-preview.yml`
  MRT Preview URL (posted as a PR comment, format `pr-<slug>`) — no local worktree, no `npm start`
  (which Claude is not allowed to run per AGENTS.md anyway), and zero interference with whatever
  branch/worktree is currently checked out locally. Worth defaulting to this over a local worktree
  for any future "test PR #N live" ask.

## Wiring itself proven correct via direct hook-class calls (2026-09-17) — bypasses DNT/browser entirely, corrects the "no propagation delay" claim

Marcel asked to test via the actual PWA Kit hook rather than the browser, to get past the DNT
wall above. `EinsteinAPI` (the class `use-einstein.js`'s `useEinstein()` hook wraps) has zero
React/DOM dependency — only the outer hook function needs React context. It can't be `import`ed
directly with plain Node (the package has no `"type": "module"`, so Node's CJS loader chokes on
the file's `import`/`export` syntax), so copied the class verbatim (constructor,
`_buildBody`, `_constructEinsteinProduct`, `einsteinFetch`, `sendViewProduct`,
`getRecommendations`, `getRecommenders` — unmodified except one added `console.log` of the raw
HTTP status, since the real method swallows non-ok statuses into `{}`) into a standalone Node
script, instantiated with `dnt: false` — bypassing the browser DNT gate entirely, no cookie
fighting needed — and `siteId` read live from `.env.dev` (`aaij-MobileFirst`, still the only
populated value anywhere, re-confirmed).

- `getRecommenders()`, `getRecommendations('viewed-recently-einstein', ...)` (PR #116's own
  `EINSTEIN_RECOMMENDERS.PDP_RECENTLY_VIEWED`), and `sendViewProduct()` — the three calls the
  app's own code actually makes — **all returned 200 OK**, every time. Recommender confirmed
  still configured (`type: recently-viewed`) on the demo tenant.
- **Corrects the 2026-09-08 finding of "no batching delay, no cache lag":** an immediate
  re-fetch after `sendViewProduct` did NOT show the newly-viewed product this time; waiting 5s
  before re-fetching did. So there's now an observed propagation delay of at least a few
  seconds — infra-side (Salesforce's demo tenant), not something in our wiring, but worth
  knowing so a same-tick empty result isn't misread as evidence something's broken.
- **Strongest confirmation yet that PR #116's actual request construction is correct** — every
  endpoint the app's code calls, called via the exact code path the app uses (not hand-rolled
  curl), succeeds. The three-blocker conclusion (DNT default, missing prod `siteId`, Einstein
  undeployed for Zimmermann) is entirely about *reachability from a real shopper's browser on a
  real Zimmermann site* — separate from, and unaffected by, this result. The wiring itself
  checks out.
- **Reusable technique:** copying a hook's underlying vendor class verbatim into a scratch Node
  script (kept out of the repo) and constructing it directly is a fast way to test any
  DNT-gated or config-dependent SDK call path without a worktree, a dev server, or a browser —
  worth reaching for again for any future "does this hook's wiring actually work" question,
  independent of whatever's blocking it from firing live.
