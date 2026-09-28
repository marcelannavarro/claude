---
name: project-contentful-cma-token-trap
description: The repo points at the correct Contentful space; CMA access is blocked by an org-level access grant, proven by 401-vs-404 error discrimination
metadata:
  type: project
---

Verified 2026-08-27 against the live Contentful API.

**The repo is pointed at the RIGHT space.** `CONTENTFUL_SPACE_ID` = `u9kb6gp6slxu` =
**"Zimmermann Global"**, created 2026-07-11 by user `033cM8RoepjPObIPPU7Akb`, sitting in the
dedicated **Zimmermann org** `0wUl0fj7AXD9rS1jgBDyta`. It holds all real content (19 content
types; 47 entries in `dev`, 38 each in `test`/`sit`/`uat`). Delivery + preview tokens read it
fine on every tier. This supersedes projectState.md's "Contentful | Mock | Demo space" line —
that's stale.

**`qxem2w4qko22` "Zimm" is NOT the intended space.** It appeared in Hardi Sempuno's `/spaces`
list, but returns **404** for this user's token — i.e. a different org's space, effectively
Hardi's own. Do not propose migrating to it.

**The blocker is an org-level access grant, not missing space membership.** Marcel's own PAT
authenticates (`/users/me` → 200) and belongs to two orgs (`Accenture` + `Zimmermann`), and
`GET /organizations/{zimmermann}/spaces` → **200** listing Zimmermann Global. But every
space-scoped call 401s. The error discriminates:

| target | result |
|---|---|
| own training space `kb5e56rj0ibk` | `200 OK` |
| **Zimmermann Global `u9kb6gp6slxu`** | **`401 OrganizationAccessGrantRequired`** |
| `qxem2w4qko22` (other org) | `404 NotFound` |
| deliberately invalid id | `404 NotFound` |

A space you have no relationship to returns **404** (Contentful hides existence). Zimmermann
Global returns **401 + a distinct error id**, so Contentful recognises the org relationship and
is withholding the grant.

**Root cause: the Zimmermann org's token-authorization control applies to PATs but NOT to the
CLI's OAuth token.** Proven 2026-08-27 by running both credentials for the *same user* against
the same endpoints:

| credential | shape | `/spaces` | `GET /spaces/u9kb6gp6slxu` |
|---|---|---|---|
| PAT from Account Settings | `CFPAT-…` 49 ch | total=1 (Accenture only) | **401 OrganizationAccessGrantRequired** |
| OAuth token from `contentful login` | `AN9X3…` 43 ch | total=2 (incl. Zimmermann Global) | **200** |

So the account has full access — the `contentful` CLI works completely (all 6 envs listed,
content-type list works). Only the **PAT** is gated, by Contentful's token-authorization
control (shipped Nov 2025: org admins can require users to manually authorize their PATs
against the org, and can de-authorize existing ones). Ruled out along the way: SSO
(`accessPolicy.sso:false`), role (Developer held; a role failure is `403`, not `401`), space
membership (that is `404`), token validity (`/users/me` → 200).

**An earlier revision of this memory concluded "regenerating cannot fix this — an admin must
grant access." That was wrong** — it was built across snapshots while the token in
`.env.shared` was being swapped three times mid-session (`4fc7699f`→`39412d0a`→`0a48c804`),
without re-verifying identity each time.

**`npm run env -- validate --live` cannot see any of this** — its live section covers only the
Delivery API and SFCC SLAS, never the management token. It reports all-OK while the whole write
path 401s. Matches [[feedback-prove-dont-assert]].

**How to apply:** to test CMA reach, call `GET /users/me` **and** `GET /spaces` and assert the
configured space id is in the list — and when a space 401s, compare against a known-invalid id:
404 means no relationship, 401 means org-recognised-but-ungranted, and those need completely
different fixes. Diagnostic covering all six surfaces lives in the session scratchpad as
`checkContentful.mjs` (not yet in the repo). See [[project-contentful-env-state]] and
[[project-contentful-known-bugs]].
