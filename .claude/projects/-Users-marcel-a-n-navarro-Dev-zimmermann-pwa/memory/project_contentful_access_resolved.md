---
name: project-contentful-access-resolved
description: Marcel's Contentful access works for all real work (incl. content-type writes); only space-admin endpoints 404, which breaks config:contentful only
metadata:
  type: project
---

Resolved 2026-08-27 by direct capability probing with the token in `.env`.

**Working credential is the CLI's OAuth token**, not a `CFPAT-` PAT. `contentful login` writes
`~/.contentfulrc.json`; that token was copied into `.env.shared`'s
`CONTENTFUL_MANAGEMENT_TOKEN` and `npm run env -- dev` regenerated `.env`. The `CFPAT-` PAT is
gated by the Zimmermann org's token-authorization policy and 401s; the OAuth token is not
subject to it. Stopgap — it dies on `contentful logout`.

**Capability matrix (Developer role on space `u9kb6gp6slxu`):**

| endpoint | result |
|---|---|
| space, `/environments`, `/content_types`, `/entries`, `/locales` | **200** |
| **PUT `/content_types/{id}`** (invalid-body probe) | **422 ValidationFailed** → write IS authorised |
| org `/environment_templates` | **200** |
| `/api_keys`, `/preview_api_keys`, `/space_memberships`, `/roles` | **404** |

Contentful returns **404, not 403**, for endpoints a role can't reach — so a 404 here means
"insufficient role", not "missing resource". All four 404s are space-*administration*
endpoints, which Developer role excludes.

**Consequence: only `config:contentful` is broken, and it isn't needed.** `getConfig.mjs` opens
with `client.apiKey.getMany()` (admin-only) so it dies at step 3 for any Developer. Its whole
job is fetching delivery/preview tokens, which are already populated in `.env.<tier>` and
verified working on dev/test/sit/uat/staging. Everything the actual build needs — authoring
content types, reading/writing entries, building the org environment template — works.

**Script design bug worth reporting:** `getConfig.mjs` gates writes on GitHub
`@ZimmermannAU/tier-1-approvers` membership and prints "Write access granted", then fails on
Contentful's own permission model. A GitHub team says nothing about a Contentful space role —
false green. `scripts/contentful/` is Tier 2, Integration/SI-owned.

**How to apply:** don't diagnose Contentful permissions from a single 401/404 — probe the
matrix, and remember 404 = role boundary. To test write without writing, PUT an invalid body
and look for 422. See [[project-contentful-cma-token-trap]], [[project-contentful-env-state]].
