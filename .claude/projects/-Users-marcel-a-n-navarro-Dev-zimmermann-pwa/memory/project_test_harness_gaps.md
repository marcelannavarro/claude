---
name: project-test-harness-gaps
description: What the test harness really enforces — a11y IS gated (contrary to the SFCC-55 session), while lint/prettier/tsc are gated nowhere and a skipped required check counts as passing
metadata:
  node_type: memory
  type: project
  originSessionId: f5f727b4-7546-4aa6-9d86-ef229e247d3f
  modified: 2026-08-22T14:15:00.000Z
---

All verified live against the installed toolchain on 2026-08-22, not taken from the transcript.

**a11y IS gated — corrects both the SFCC-55 session and an earlier version of this memory.**
The session concluded four separate times that "a11y is not gated, there's no
`.storybook/test-runner.js`". That was **Storybook 8 knowledge and is wrong for what's installed.**
`@storybook/test-runner@0.24.4`'s `dist/setup-page-script.js:390-402` reads
`parameters.a11y.test` and rejects when it `=== "error"`; `.storybook/preview.tsx` sets exactly
that; `addon-a11y@10.4.6` runs `axe.run` with `initialGlobals.manual: false`; `axe-core@4.11.4` is
present. **No `test-runner.js` is needed — do not remove that `preview.tsx` a11y block.**
Honest caveat: the gate has never been made to fail on purpose, so by the project's own standard
it is unproven, just not absent.

**A skipped required check counts as passing.** Live on PR #59: `gh pr checks 59` shows all four
suites `skipping` — including both *required* checks — while `mergeable: true`. Cause:
`detect-changes` uses `since_last_remote_commit: true`, and a final push touching only
`.claude/registry/components.md` + `scripts/generateRegistry.mjs` fell outside every allow-list.
A 64-commit, ~5,000-line PR became merge-eligible with **zero test evidence on its head SHA**.
Always read `gh pr checks` for `skipping`, not just for green.

**Gated nowhere at all** (grepped all 15 workflows): `eslint`, `prettier`, `tsc --noEmit`, any CSS
bundle budget. `npm run lint` currently fails repo-wide on 19 pre-existing prettier errors and CI
never notices. `bundlesize` never runs on a PR to `develop`.

**A named gate that cannot fail:** `digital-sit.yml`'s "MuleSoft contract tests" runs
`npm run test:contracts`, which is `echo 'TODO…' && exit 0` — and it's a hard `needs` of
`sit-gate`.

**A Tier 1 rule that breaks if followed verbatim:** `.claude/rules/testing.md:87` prescribes
`@storybook/test`, which is **not installed** — Storybook 10 moved it to `storybook/test`, which is
what the live footer story imports. Line 100's "never reach into `document`" also lacks the portal
carve-out that portalled dialogs need.

**Still-true harness traps:** `test-storybook` needs a **built** Storybook (dev-server runs made
four mutation results uninterpretable); **Vitest does not run `play`**; **`extendTheme` does not
populate `theme.__cssMap`** — only `ChakraProvider` does via `toCSSVar`, so a direct `css()(theme)`
assertion passes vacuously; **jsdom always provides `window`**, so an SSR branch needs
`// @vitest-environment node`; every jsdom rect is 0, so layout assertions there are meaningless.

**E2E reality:** the only spec in the repo is `SMOKE-homepage-load.spec.js`, so `@SFCC-55`-scoped
BrowserStack runs matched zero tests — a silent no-op, not a pass.

**Why:** each of these makes a green or absent signal look like evidence. The a11y one is the most
dangerous in reverse — believing it's ungated invites deleting the thing that gates it.

**How to apply:** verify a gate against the installed package version before claiming it does or
doesn't run. See [[feedback-prove-dont-assert]].
