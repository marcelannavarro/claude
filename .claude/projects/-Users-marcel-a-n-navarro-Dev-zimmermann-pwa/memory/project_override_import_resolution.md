---
name: project-override-import-resolution
description: "Base-path imports from inside overrides/ resolve to the BASE module, not your override — overrideStyling.md claims otherwise"
metadata:
  node_type: memory
  type: project
  originSessionId: bad4ca0d-db64-47ee-b18c-8601052cd7b0
  modified: 2026-09-24T06:55:54.904Z
---

Verified live on 2026-09-24 (SFCC-11, dev server + Playwright marker test), in the **real app
build**, not just Storybook/Vitest:

- From a file under `overrides/`, importing `@salesforce/retail-react-app/app/hooks/use-auth-modal`
  resolves to the **base `.js`** — the override is NOT used (0 debug markers).
- Importing `app/hooks/use-auth-modal` (the `app/` alias) resolves to the **override `.tsx`**
  (12 markers).
- The ccExtensibility resolver does rewrite base-path imports made from **inside the base
  package** — that's how `withRegistration` (in `node_modules`) picked up our override.

**Why:** `.claude/rules/overrideStyling.md` ("Importing an already-overridden component from a new
component") states a base-path import "will build and run correctly in the shipped app" and that the
problem is confined to Storybook/Vitest. That is wrong about the app build — it runs, but it runs the
*base* version. A fix written into an override silently does nothing for our own components.

**How to apply:** In any file under `overrides/`, import an already-overridden module via the `app/`
alias or a relative path, never the SFCC base path. A base-path import also fails to *parse* under
Vitest when the base file is JSX-in-`.js` (e.g. `use-auth-modal.js`), which is the usual first
symptom. Known consumers still on the base path and therefore silently using the base hook:
`_app/index.tsx`, `pages/cart/cartDrawerContainer.tsx`,
`ui-kits/organisms/zimmWishlistAuthDrawer/index.tsx`, `hooks/useWishlistAuthDrawer.ts`.
The rule doc itself needs correcting. Related: [[project-styling-layer-boundary]],
[[project-shared-ui-barrel-trap]].
