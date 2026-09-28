# Plan: Reorganize ~/Downloads

## Context

`~/Downloads` has drifted. ~50 loose files sit at the root alongside 7 subfolders — and the
subfolders show a filing system *was* established once and then stopped being followed.
`Zimmermann-PWA/` and `Pre-Zimm/` are cleanly organized by category; everything created
since late July landed at the root. Three separate "learnings" folders exist (one empty).

So this isn't a dump-into-folders job. The goals:
1. **Finish the structure that already exists** rather than invent a competing one
2. Collapse the three learnings folders, splitting personal notes from team-facing playbooks
3. Resolve duplicates — delete only what's provably redundant, quarantine anything ambiguous
4. Leave behind a written filing convention so the next drift self-corrects

**Decisions confirmed:** organize in place · delete-safe/quarantine-risky · split notes from
playbooks · replace the orphaned `art-life-sdk` config with a filing `CLAUDE.md`.

---

## Target structure

```
~/Downloads/
├── _Inbox/                    ← NEW: all new downloads land here, triaged weekly
├── _Review/                   ← NEW: ambiguous items awaiting your decision
│   ├── manifest.md
│   └── diverged/
├── .claude/
│   ├── CLAUDE.md              ← REPLACED: filing rules for this folder
│   └── _archived-art-life-sdk/  ← old SDK config, preserved intact
├── Accenture-Admin/           ← unchanged + 1 identified PDF
├── Learnings/                 ← merged, personal notes only
├── Playbooks/                 ← NEW: team-facing polished docs
├── Media/Images/              ← NEW: loose images with no project home
├── Personal/                  ← unchanged
├── Pre-Zimm/                  ← closed archive, minor cleanup only
└── Zimmermann-PWA/            ← extended with Assets/, Reference/, TSDs/
```

---

## Step 1 — Safe deletions (provably redundant only)

| File | Why safe |
|---|---|
| `Project Name_Peer Review Checklist.xlsx` (root) | Byte-identical to `Zimmermann-PWA/Delivery/` copy |
| `Zimmermann-PWA/Onboarding/Zimmermann_Frontend_Lead_Playbook.md` | Byte-identical to the `Pre-Zimm/` copy; **both superseded** by the 50 KB root version. Archive keeps one historical copy. |
| `refinement071626.md` | 0 bytes |
| `Pre-Zimm/Misc/Unconfirmed 311314.crdownload` | Aborted browser download |
| `.DS_Store` files | Finder metadata, regenerates harmlessly |
| `My Learnings/` (dir) | Empty |
| `FED Lead Learnings/` (dir) | Emptied by Step 3 |

Everything else is **moved, never deleted**.

## Step 2 — `Playbooks/` (new — team-facing docs)

| File | From |
|---|---|
| `Zimmermann_Frontend_Lead_Playbook.md` | root — **50 KB Jul 9 17:24 version is canonical** (newest + largest; the two 36 KB copies are the older draft) |
| `fedLead-playbook.md` | root (Aug 21) |
| `fedBuild-manual.md` | root (Aug 21) |

Verified distinct documents — not versions of each other. `fedLead-playbook.md` is derived
from the Contentful/PWA-Kit alignment sessions; `fedBuild-manual.md` is a manual UI build
guide; the Playbook is the IC-and-lead role guide.

## Step 3 — `Learnings/` (merged, personal notes)

Merge `FED Lead Learnings/2026-08-07-atlassian-mcp-setup.md` in, delete `My Learnings/`.
Filenames stay as-is — the mixed naming is preserved deliberately, no mass rename.

Remaining in `Learnings/`: `README.md` (index — **update it** to reflect the new split),
`2026-08-07-pr-review-lessons.md`, `2026-08-07-motion-design-review.md`,
`2026-08-07-atlassian-mcp-setup.md`, `copilot-sweep-{1,2,3}.md`,
`release-branch-strategy-eli5.md`, `user-story-breakdown-eli5.md`,
`sfcc-122-mrt-api-capabilities-eli5.md`, `us-intl-storefront-walkthrough.md`

## Step 4 — Extend `Zimmermann-PWA/`

New subfolders, following the existing category pattern:

```
Zimmermann-PWA/
├── Assets/        ← HomeMasthead.mov (99 MB), zimmermann-futura-round-woff2.zip
├── Reference/     ← SFCC_ManagedRuntimeOverview.md, SFCC_ManagedRuntimeAdministration.md
└── TSDs/
    ├── Templates/ ← renamed from TSD-Templates/
    ├── SFCC-122/  ← TSD-SFCC-122-v0.4-DRAFT.md
    └── SFCC-249/  ← the 4 SFCC-249 files (LOCAL, STAGING, REFORMAT-DRAFT, tim-feedback-tracker)
```

Also into existing folders:
- `Delivery/` ← `CodeReview_Checklist_Overhaul_Plan.md` (its title names Zimmermann PWA),
  `Replatform - Weekly Status Update - 06 August 2026 - v0.1.pdf`
- `Screenshots/` ← the 14 root PNGs. **Inspect each before moving** — they span Jul 28–Aug 11
  (the Zimmermann window) so this is the default destination, but any that clearly belong to
  Accenture admin or personal go to those folders instead.

## Step 5 — `Media/Images/` and identification

- `rocky-amaze-amaze-amaze.gif`, `735877446_…n.jpeg` (Meta CDN filename),
  `att.KTVvlvJ6C-…jpeg` (email attachment) → `Media/Images/`
- `5d79e3c5-11e6-46e6-98fc-bd5d2c1b81fc.pdf` — sourced from `pesh.accenture.com`. Open it,
  rename descriptively, file into `Accenture-Admin/`.

## Step 6 — `_Review/` quarantine (nothing deleted)

Five diverged pairs that need your judgement, plus a `manifest.md` stating each conflict,
both file sizes, both dates, and which is newer:

| Pair | Conflict |
|---|---|
| `tagging.md` ↔ `tagging copy.md` | Same title, **136 lines differ** |
| `zimmermann-outstanding-items.md` | `Learnings/` ↔ `Zimmermann-PWA/Handover/`, content differs |
| `SFCC-122-MRT-API-Capabilities.md` (root) | vs `Learnings/sfcc-122-mrt-api-capabilities-detailed.md` |
| `tag-based-promotion-LEARNING.md` (root) | vs `Learnings/tag-based-code-promotion.md` |
| `mulesoft-order-management-questions.md` (root) | vs `Learnings/mulesoft-order-management-plain.md` |

Note the `-eli5` variants are **intentional** plain-language companions, not duplicates — those
stay in `Learnings/`. Only the detailed/source pairs are quarantined.

## Step 7 — Replace the orphaned Claude config

`~/Downloads/.claude/` configures **`art-life-sdk`** — a repo that doesn't exist here or in any
sibling location. It carries 6 rule files, 5 skills, and 4 hooks, including a `SessionStart`
hook that reads `.claude/build-log.md` and a `PreToolUse` hook on every Bash call. Every Claude
session opened in `~/Downloads` currently inherits SDK build rules, design-token rules, and
component-porting rules that have nothing to do with these files. (This session loaded them.)

- Move the whole current config to `.claude/_archived-art-life-sdk/` — **preserved intact**, in
  case the repo resurfaces
- Write a fresh `.claude/CLAUDE.md` documenting the filing rules agreed here: new files land in
  `_Inbox/`, screenshots go to `<Project>/Screenshots/`, notes vs. playbooks split, nothing
  stays loose at the root
- Write a minimal `.claude/settings.json` with no hooks (the current one wires all four to
  `art-life-sdk` scripts)

---

## Security — needs you, not me

`github-recovery-codes.txt` (206 B) sits unencrypted at the root of `~/Downloads`.

**I have not opened this file and will not move or copy it.** GitHub recovery codes belong in a
password manager. Move it into 1Password/Keychain yourself, then delete the plaintext copy.
I'll leave it exactly where it is and skip it in every step above.

---

## Verification

After execution, all of these should hold:

```bash
# 1. No loose files at root except the intentional ones
ls -p ~/Downloads | grep -v /
#    expect ONLY: github-recovery-codes.txt, .localized

# 2. Nothing was lost — file count before vs after (excluding deletions)
find ~/Downloads -type f -not -path '*/.claude/*' -not -name '.DS_Store' | wc -l
#    expect: 128 (135 before − 5 deletions − 2 .DS_Store)

# 3. No remaining byte-identical duplicates
find ~/Downloads -type f -size +1k -not -path '*/.claude/*' -exec md5 -r {} \; \
  | awk '{print $1}' | sort | uniq -d
#    expect: empty output

# 4. Every quarantined conflict is documented
cat ~/Downloads/_Review/manifest.md
#    expect: 5 pairs, each with sizes + dates + which is newer

# 5. Claude no longer loads SDK rules here
grep -rl "art-life-sdk" ~/Downloads/.claude/ --exclude-dir=_archived-art-life-sdk
#    expect: empty output
```

Then open a fresh Claude Code session in `~/Downloads` and confirm the context shows the new
filing `CLAUDE.md` instead of the art-life-sdk brief index.

## Rollback

No `git` here, so before touching anything: snapshot the current layout to
`_Review/pre-reorg-tree.txt` via `find ~/Downloads -not -path '*/.claude/*' | sort`. Every
step is a `mv` except the 5 named deletions in Step 1, so the tree file is enough to
reconstruct the original arrangement.
