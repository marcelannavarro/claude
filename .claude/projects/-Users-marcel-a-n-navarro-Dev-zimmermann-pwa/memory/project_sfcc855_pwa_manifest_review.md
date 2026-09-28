---
name: sfcc855-pwa-manifest-review
description: "PR #77 (SFCC-855 manifest/maskable-icon fix) shipped 3-of-4 required Lighthouse PWA audits; service-worker gap traced to a CSP script-src issue already tracked separately in SFCC-856; Marcel decided to leave both as-is."
metadata: 
  node_type: memory
  type: project
  originSessionId: 595954f6-8885-46a0-80fe-533015c6ebf6
  modified: 2026-09-01T05:49:31.358Z
---

SFCC-855's AC (single conjunctive bullet, `customfield_10231`) requires ALL FOUR Lighthouse
PWA-installability audits to pass: `installable-manifest`, `service-worker`, `maskable-icon`,
`splash-screen`. PR #77 (merged 2026-09-01, commit `a4f6921`) fixed only 3 — `service-worker`
still fails. Root cause (confirmed by reading `overrides/app/ssr/contentSecurityPolicy.ts:18-34`):
`script-src` has no `'self'` entry, and helmet's `useDefaults: true` replaces rather than merges
an explicitly-set directive, so same-origin script loads (including `/worker.js`) may be blocked
under CSP in a real deployed environment. This file is Tier 1 (frozenFiles.md) and correctly
untouched by PR #77.

A sibling ticket, **SFCC-856** (CSP hardening: nonce/hash-based script-src and style-src),
independently reached the identical root-cause conclusion and formally logged it same-day
(2026-09-01) as "a known, accepted SIT Gate failure for now... given the ssr.js constraint and the
risk of breaking styling/payments without dedicated testing." No formal Jira link exists between
SFCC-855 and SFCC-856 despite the real dependency — SFCC-855's 4th AC clause cannot pass until
SFCC-856 ships.

**Decision (2026-09-01, Marcel, via /zimmerMANNReview of PR #77):** leave SFCC-855's ticket as-is
(no AC split, no formal link to SFCC-856) — made after seeing that the PR body itself already
documents the root cause and the Tier-1 blocker reasonably. Also decided: don't chase right now
whether the missing `script-src: 'self'` blocks more than just the service worker (e.g. the app's
own main bundle) on a live deploy — trusting SFCC-856's existing accepted-gap framing rather than
independently verifying blast radius.

Separately noticed during the same review, not ticketed by Marcel's choice: the base `_app`
component's `<meta name="theme-color">` still resolves to Salesforce's demo blue (`#0176D3`, from
unoverridden `THEME_COLOR` in `@salesforce/retail-react-app/app/constants.js` —
`overrides/app/constants/index.ts` re-exports everything else but not this one) — independent of
`manifest.json`'s `theme_color`, now correctly `#191919`. Visible brand mismatch, cheap fix
whenever it's worth doing, explicitly deprioritized for now.

**Why:** SFCC-855 was created and cycled through its entire refinement workflow the same day the
PR merged (ticket created 11:32+10, PR already merged by ~14:55+10, ticket status finalized
14:59+10) — same-day SIT-gate-unblocking work, not a normal pre-planned story. That context
matters if SFCC-855 is later checked for "is this actually done" — the AC as written is not fully
met, and that's now a known, consciously accepted state, not an oversight.

**How to apply:** If service-worker/CSP/PWA-installability comes up again (a later Lighthouse
re-run, a "why didn't the site's JS load" incident, or someone asking whether SFCC-855 is done),
this is the context — don't re-diagnose from scratch. If SFCC-856 ships, SFCC-855's 4th AC clause
should be re-tested. If the theme-color mismatch or the script-src blast-radius question resurface
with more urgency, both were seen and consciously set aside on 2026-09-01, not missed.

**Retrospective verdict:** Marcel reviewed PR #77 after the fact (it had already merged on
CodeRabbit's bot approval alone — no human review approval before merge) and closed it out as
approved, remaining items nitpicks only. Nothing was posted to GitHub or Jira — kept internal per
his explicit instruction.
