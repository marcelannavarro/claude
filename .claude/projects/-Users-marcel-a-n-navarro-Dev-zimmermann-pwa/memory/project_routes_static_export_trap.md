---
name: project-routes-static-export-trap
description: "overrides/app/routes.tsx imports base's STATIC routes array, so any route base appends conditionally in its default export (social-callback) is silently never registered"
metadata:
  node_type: memory
  type: project
  originSessionId: 75bd095e-159e-4981-9ce1-13fc8b267fc5
  modified: 2026-09-24T08:08:59.141Z
---

Found 2026-09-24 auditing SFCC-135. Static read, not yet exercised on a running target.

`node_modules/@salesforce/retail-react-app/app/routes.jsx` has **two** exports:

- `export const routes = [...]` (line 56) — the static array
- `export default () => {...}` (line 131) — a function that reads `getConfig()` and
  **conditionally appends** extra routes before calling `configureRoutes`. At lines 153-157 it
  appends `{path: socialRedirectURI, component: SocialLoginRedirect}` when
  `loginConfig.social.enabled` is true.

`overrides/app/routes.tsx:15` imports **only the static named export** (`{routes as _routes}`),
spreads it at `:90`, and at `:114` runs its own
`configureRoutes(routes, config, {ignoredRoutes: ['/callback', '*']})`. **The base default export
is never invoked**, so anything it appends conditionally does not exist in this app.

**Live consequence:** `social.enabled: true` in `config/dev|test|sit|uat|staging|production.js`
and `redirectURI` defaults to `/social-callback`. `overrides/app/ssr.js:115` already allowlists
`^/social-callback`, so the path was expected to resolve — but no route is registered, so an
Apple/Google return falls through to the `/:segments+` catch-all, resolves `social-callback` as a
category, and renders not-found. `loginIDPUser` never runs. The social buttons in
`zimmAuthDrawerContent/socialButtons.tsx` are already built and shipped.

**Why:** this fails silently and only at runtime on a redirect back from a third party — no build
error, no failing test, and the ssr.js allowlist makes it look wired.

**How to apply:** when a base feature is enabled purely by config and its route isn't in the
static `routes` array, check base's default export before assuming the route exists. Same shape
could affect the passwordless callback routes — verify rather than assume. Related:
[[project-override-import-resolution]] (the sibling trap: base-path imports resolving to the base
module), [[project-test-harness-gaps]].
