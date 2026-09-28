---
name: project-review-findings-never-posted
description: "Four defects Marcel's own PR reviews confirmed and never posted — verified still live 2026-09-11, parked pending action"
metadata: 
  node_type: memory
  type: project
  originSessionId: 936e8a1d-369c-4c54-9c6e-2c7295b8b654
  modified: 2026-09-11T01:35:19.652Z
---

Found by the 2026-09-11 improver catch-up. Across PRs #65, #67, #81, #83 and #84 (all merged),
roughly **44 verified review findings produced 8 posted comments**. These four were confirmed by
the reviews at the time, never posted, and **re-verified as still present on 2026-09-11**:

1. **`overrides/app/components/ui-kits/atoms/zimmModal/index.tsx:86-87`** — `ModalOverlay` and
   `ModalContent` still use `__css`; `ZimmDrawer` got the `sx` fix in the same PR (#67) and uses
   it at lines 149/152/160/210. PR #67's review confirmed by live render: no backdrop renders at
   all, panel is plain white / 448px / zero padding, *"shipping today on the real newsletter
   signup."* Line 56 of the file already carries a comment acknowledging the mechanism.
2. **`.../molecules/zimmTabs/index.tsx:57`** — `setCanScrollLeft(list.scrollLeft > 0)`; the real
   initial `scrollLeft` measures 2.5px, so it reads true on first render and Previous never
   disables. Untracked.
3. **`.../molecules/zimmTabs/index.tsx:102`** — `handleKeyDown` uses `tabs[0].id`,
   `tabs[tabs.length - 1].id` and a modulo lookup with no empty-array guard. Untracked.
4. **`overrides/app/components/pageContainer/index.tsx`** — reproduces only `paddingX`. Base
   `layerStyles.js:32-40` gave `layerStyle="page"` a `paddingTop: [4,4,6,6,8]` and
   `paddingBottom: 32`; both PDP call sites pass no vertical padding. PR #81's review
   browser-confirmed 0px header→hero and 0px content→footer at 1440px and **never presented it to
   Marcel** — the session was abandoned and re-invoked fresh. *Code-level confirmed only;
   `#app-main` also contributes padding, so whether it still renders as 0px needs a browser check.*

**The pattern that makes this matter:** four *other* PR #67 findings were independently
re-discovered by QA 25 hours later and filed as **SFCC-898 "PDP Drawer/Slideout Defects"** —
one of them word-for-word the same root cause the eventual fix commit names. Findings that are
correct but undelivered get re-found at full cost by someone else.

**Why:** Marcel parked these on 2026-09-11 with "hold until the improvers are done". The improvers
are done (commits `8b3935f`, `efc7896`). Nothing else tracks items 2-4.

**How to apply:** raise 2 and 3 together (one `ZimmTabs` fix), 1 on its own, and browser-verify 4
before ticketing it. The skill-side cause is fixed — see [[project-improver-ledger]] — but these
four predate the fix. Related: [[project-sfcc855-pwa-manifest-review]].
