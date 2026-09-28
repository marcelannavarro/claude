---
name: feedback-local-only-docs
description: The three FED playbooks live in ~/Dev only — never cite them in PR threads, commits, or code comments
metadata:
  node_type: memory
  type: feedback
  originSessionId: f5f727b4-7546-4aa6-9d86-ef229e247d3f
  modified: 2026-08-22T02:20:00.000Z
---

`/Users/marcel.a.n.navarro/Dev/fedLead-playbook.md` and
`/Users/marcel.a.n.navarro/Dev/fedBuild-manual.md` are **local-only files on Marcel's
machine**. They are a legitimate input to the work, but must never be referenced in anything
another person can read: PR review replies, commit messages, or code comments.

Caught in the SFCC-55 session (652997c6) when a CodeRabbit reply cited the playbook as
justification. Marcel: *"it's wrong to mention the fed lead playbook here, because that file is
only local to me, what should we do about this?"* The reply was rewritten to rest on
`AGENTS.md` Hard Rule #4 instead, which reaches the same conclusion from a source the reviewer
can actually open.

Also standing from the same session: **no `Co-Authored-By` line on any commit** — stated as
*"no authored by claude in the commit messages"*. This overrides the default commit trailer.

**Why:** a citation nobody else can verify reads as an appeal to a private authority; it can't be
checked, and for CodeRabbit specifically it teaches the bot nothing (see the in-thread reply rule
in AGENTS.md).

**How to apply:** when a local doc is the real reason for a decision, find the public equivalent
in `AGENTS.md`, `.claude/rules/`, or `.docs/` and cite that. If no public equivalent exists,
argue the merits directly rather than naming the local file. Related: [[feedback-pr-body-standard]].
