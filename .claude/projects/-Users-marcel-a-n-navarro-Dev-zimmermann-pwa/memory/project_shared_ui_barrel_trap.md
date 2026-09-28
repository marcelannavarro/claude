---
name: project-shared-ui-barrel-trap
description: Overriding shared/ui/<Name> intercepts nothing — the SFCC barrel re-exports relatively, and 208 base files import the barrel while 0 import the individual path
metadata:
  node_type: memory
  type: project
  originSessionId: f5f727b4-7546-4aa6-9d86-ef229e247d3f
  modified: 2026-08-22T02:35:00.000Z
---

The tempting high-leverage play in a slim-overrides project: override
`@salesforce/retail-react-app/app/components/shared/ui/<Name>` so branded styling propagates
into every base SFCC component for free — base cart, checkout and account all inherit
Zimmermann buttons, no import churn, no forked components.

**It does not work.** `shared/ui/index.jsx:29` does `export {Button} from './Button'` — a
**relative** export, which the ccExtensibility resolver does not rewrite. And the consumption
pattern is the wrong way round: **212 base files import the barrel (195 excluding tests); 0 import
`shared/ui/Button`.** (Re-counted 2026-08-25; an earlier note said 208.) So the override intercepts nothing.

This was asserted confidently once and was wrong; Tim's framing (raw components for Contentful)
turned out to be the correct one. An exception note was added to both Desktop docs.

**Why:** it's an architecturally attractive idea that reads as obviously correct, and the
failure is invisible — the override compiles, resolves, and simply never gets imported.

**How to apply:** before scoping a story around "override X and it propagates", grep the base
package for who actually imports the path you're overriding
(`grep -r "from '@salesforce/retail-react-app/app/components/<name>'" node_modules/@salesforce/retail-react-app/app/`).
Distinct from, but same family as, the resolver trap already documented in
`.claude/rules/overrideStyling.md` — Storybook and Vitest don't load the resolver at all, so a
base-path import silently renders the unstyled base component there.
