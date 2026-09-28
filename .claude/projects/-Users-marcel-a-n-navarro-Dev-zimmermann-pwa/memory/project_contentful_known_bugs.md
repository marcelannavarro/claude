---
name: project-contentful-known-bugs
description: Three verified defects in scripts/contentful/ — promoteAlias will throw at runtime; plus the CLI does not read our env var
metadata:
  type: project
---

Found and independently verified 2026-08-25. All still unfixed as of that date; reported to
the team, not patched (`scripts/contentful/` is Tier 2, Integration/SI-owned).

1. **`promoteAlias.mjs:70` calls `client.environmentAlias.createOrUpdate(...)`, which does not
   exist.** The string `createOrUpdate` appears in **0 files** in `contentful-management@12.3.2`.
   It throws at runtime on the non-dry-run path, so it has almost certainly never executed
   successfully — this is the production cutover script. `bootstrapSpace.mjs:238-240` already
   documents the correct pattern (get → `update()` with `sys.version`, else `createWithId()`).
2. **`installTemplate.mjs:89`** tells the operator to run `npm run build:contentful`; no such
   script exists. It's `sync:contentful`.
3. **`bootstrapSpace.mjs:166`** passes the clone source `'master'` positionally, landing it in
   the `headers` slot instead of `params.sourceEnvironmentId`. Benign today only because
   Contentful defaults the source to master anyway.

**The CLI footgun:** `contentful-cli` reads only `CONTENTFUL_CONFIG_FILE` and `NODE_ENV`;
`contentful-import`/`contentful-export` read **zero** env vars. None of them honour this repo's
`CONTENTFUL_MANAGEMENT_TOKEN`. Auth must be passed as `--management-token`. Worse,
`--environment-id` silently defaults to **`master`** — and on `contentful space import` that
default is undocumented (help shows none; `dist/lib/utils/middlewares.js` hard-codes it).
`node_modules/.bin/contentful-export` is also broken in this install (`yargs@18` is ESM-only);
use `npx contentful space export` instead.

**Why:** #1 means a documented release mechanism is untested and will fail the first time
someone relies on it. The CLI defaults are a live path to writing production by omission.

**How to apply:** always pass `--space-id`, `--environment-id`, and `--management-token`
explicitly to any contentful CLI command. See [[project-contentful-env-state]].
