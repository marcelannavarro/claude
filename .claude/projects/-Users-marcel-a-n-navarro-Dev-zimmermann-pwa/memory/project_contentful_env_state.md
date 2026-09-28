---
name: project-contentful-env-state
description: Contentful promotion architecture and verified per-tier state — schema and entries are separate mechanisms, and only dev has ever been populated
metadata:
  type: project
---

Verified 2026-08-25 against the live Contentful API (read-only CDA + CMA). **Re-checked
2026-08-27: dev has grown to 19 content types, code now defines 6 — see the updated gap
below.**

**Tier state (updated 2026-08-27):** content HAS now been promoted out of dev — `dev` has 19
content types / 47 published entries (49 via preview, so 2 drafts), and `test`, `sit`, `uat`
each have **38 entries**. `staging` is still **0 entries** and `prod` still has no
`CONTENTFUL_ENVIRONMENT_ID` or delivery token. The 25 Aug reading below (all non-dev tiers at
zero) is superseded — do not quote it as current.

Consequence for staging/prod: every `useUiCopy` key silently renders its hardcoded English
fallback there, with no error surfaced anywhere. Verified by pointing the uiCopy check at
`staging` — all 5 call-site keys reported missing.

**Two separate mechanisms.** Content *types* promote via an org-scoped Environment Template
(`sync:contentful` builds it, `install:contentful --target` installs it). Entries **cannot**
travel that way — it's structural: `EnvironmentTemplateProps.entities` has exactly
`contentTypeTemplates` and `editorInterfaceTemplates`, no entry slot. The only entry-writing
code in the repo is `seedRegions.mjs:71-72` (11 `region` entries, that's all).

**As of 2026-08-27 the gap is 6-in-code vs 19-live.** Code on `develop` defines
`footerConfig`, `footerNavGroup`, `image`, `link`, `region`, `uiCopy`. Dev gained six types
since the 25 Aug sweep (`gallery`, `galleryItem`, `headerNavItem`, `headerNavigation`,
`imageAndText`, `navGroup` — header/gallery work in flight), and **`footerNavGroup` is
defined in code but no longer live in dev** (apparently superseded by `navGroup`), so drift
now runs in both directions. 14 live types have no code definition at all. Historical
snapshot from 25 Aug follows.

**The template covers 5 of dev's then-14 types** — `footerConfig`, `footerNavGroup`, `link`,
`region`, `uiCopy`. The other 9 (`collectionPageExp`, `contentCard`, `homepageContentRow`,
`homepageHeroBanner`, `image`, `pdpAccordionContent`, `plpInlineGridInsert`, `product`,
`promotionalAnnouncementBanner`) exist only inside the dev environment, UI-authored, with no
code representation.

**There is no forward content promotion at all.** The repo's actual release model is the
alias flip in `promoteAlias.mjs`: clone master → install template → author/verify → repoint
`production`/`master`. Content moves backwards (master → clone), never forwards.

**Why:** this took a full multi-agent investigation to establish and none of it is visible
from the repo alone — the tier state is live external state, and the 5-vs-14 gap only shows
up by diffing `content-types/*.js` against the live CDA.

**How to apply:** before promising any content-related fix on a non-dev tier, check whether
that tier has the content model at all. Don't assume `install:contentful` moves content — it
moves schema, and only the 5 types in `content-types/`. See [[project-contentful-known-bugs]].


---

**CORRECTED 2026-09-22 (live CDA check).** Entry counts above were wrong — "~38 across
test/sit/uat" is true of **uat only**:

| env | entries | types |
| --- | --- | --- |
| dev | 148 | 14 |
| test | 100 | 10 |
| sit | 97 | 9 |
| uat | 38 | 6 |
| staging | 0 | 6 |
| prod | uncheckable — `.env.prod` has no `CONTENTFUL_DELIVERY_TOKEN` | — |

Code defines **10** content types (`scripts/contentful/content-types/`, 457 lines total,
23–76 lines each). dev carries 4 extras not in code: `collectionPageExp`, `richtext`,
`sizeGuide`, `sizeGuideTable`; sit has a stray `zimmermann`.

**Promotion debt:** staging and uat still carry the pre-unification `footerNavGroup` — they
never received the `navGroup` unification (`d934ad96`, 2026-08-26) and are ~1 month behind
the template. Installing any new content type there is not a clean run today.


---

**RE-VERIFIED 2026-09-25 (live CDA, read-only).** Supersedes the 2026-09-22 table.

| env | types | entries | iconAndText | placement=benefits | uiCopy |
| --- | --- | --- | --- | --- | --- |
| dev | 14 | 163 | 1 | 1 | 37 |
| test | 14 | 167 | 2 | **2 (duplicate)** | 37 |
| sit | 13 | 163 | 1 | 1 | 37 |
| uat | 6 | 38 | 400 (type absent) | 400 | 5 |
| staging | 6 | 0 | 400 (type absent) | 400 | 0 |
| prod | — | — | — | — | — (no CONTENTFUL_DELIVERY_TOKEN and no CONTENTFUL_ENVIRONMENT_ID in .env.prod) |

Code now defines **12** content types, not 10 — `iconAndText` and `iconAndTextItem` were added
for the cart/PDP Zimmermann Benefits block (ZimmBenefits, SFCC-316/317).

**Cart-build consequence:** `ZimmBenefits` renders in the cart drawer footer (itemCount > 0) and
returns `null` when its entry is missing — so on uat/staging the benefits block silently vanishes
with no error, and `useUiCopy` falls back to hardcoded English. uat/staging are still on the old
6-type model and have not moved since 2026-09-22.

**test carries two published `placement=benefits` entries** and the component takes `entries[0]`,
so which one renders is not deterministic there.
