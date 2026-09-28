---
name: file-organization-preferences
description: How Marcel wants file-organization work done — safe deletes only, quarantine anything ambiguous, no rename churn
metadata:
  type: feedback
---

When reorganizing Marcel's files: delete only what is **provably** redundant (byte-identical
verified by `md5`, or 0 bytes). Everything ambiguous goes to a `_Review/` folder with a
`manifest.md` explaining each conflict, sizes, dates, and which copy is newer. Preserve
existing filenames — he chose the option that kept mixed naming over a tidy mass rename.

Splits should be by **audience**, not topic: personal notes (`Learnings/`) vs. team-facing
deliverables (`Playbooks/`).

**Why:** he wants reorganization to be reversible and auditable. Losing a file is far worse
than leaving a duplicate, and rename churn breaks his own recall of where things are.

**How to apply:** snapshot the tree (`find … | sort > pre-reorg-tree.txt`) before touching
anything, make every change a `mv`, and reconcile file counts afterward. Never delete on a
hunch. See [[downloads-filing-convention]].
