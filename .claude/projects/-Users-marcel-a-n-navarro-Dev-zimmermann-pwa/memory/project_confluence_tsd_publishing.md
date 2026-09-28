---
name: project-confluence-tsd-publishing
description: "Where TSDs live in Confluence, the title pattern, and the markdown-to-storage conversion gotchas when publishing via MCP"
metadata: 
  node_type: memory
  type: project
  originSessionId: 80906d04-5b4f-487b-bbdb-5df3a398b61a
  modified: 2026-08-13T09:07:58.415Z
---

Publishing a TSD to the Zimmermann SFCC Confluence space (verified 13 Aug 2026 while publishing TSD-SFCC-681).

**Location.** Parent page is **"Technical Solution Designs", page id `392888324`**, space `SFCC`.
Path: `Adobe SFCC > SFCC Migration > 05 Technical Documentation > 05.1 Architecture & Solution Design > Technical Solution Designs`.
Two TSD-family exceptions that live elsewhere: MuleSoft domain TSDs (Product/Price/Inventory/Orders/Catalogue Sync) sit under `MuleSoft Integration - Functional Solution Designs` (`292847624`, itself a child of 392888324), and `TSD: AI-Assisted Defect Triage Agent` sits under `05.5 Agent Registry` (`278921217`).

**Title pattern.** The TSD template (`352419841`) prescribes no page-title rule; its only identifier
is `Document ID | TSD-[JIRA-KEY]`. Tim Lavelle's playbook has no naming section either. The space is
genuinely split: most pages use `TSD: <Name>`, but the template-faithful form leads with the Document
ID. Marcel's call on 13 Aug 2026 was **"use Tim's template prescribed pattern"** = lead with the
Document ID: `TSD-SFCC-681: MRT Application Topology (...)`. Use a **colon**, not the en dash the
`TSD-SFCC-268` page uses, since the playbook's pre-submission checklist bans em/en dashes.

**Conventions from live precedent.** No labels on any TSD page. Page emoji is clipboard (stored as
`1f4cb`), inherited from the template. Guidance callouts must be deleted. **No H1 in the body** - the
page title carries it, body opens on `## Document Information`.

**Markdown to storage conversion gotchas (mcp-atlassian `content_format: markdown`):**
- `<br />` (self-closing) **does** survive into table cells and renders as real line breaks. Bare
  `<br>` is riskier. Note the markdown *export* flattens these back to spaces, so a read-back with
  `convert_to_markdown: true` cannot tell you whether they worked - fetch with
  `convert_to_markdown: false` to see the actual `<br/>` tags.
- Inline code immediately followed by bold (`` `file.js` **(Tier 1)** ``) **loses the space** -
  renders as `file.js(Tier 1)`. Put plain text between them (`` `file.js` is **Tier 1** ``); spaces
  around plain text after `</code>` survive fine.
- Confluence's code macro has **no `ts`/typescript language** - a ```ts fence silently falls back to
  `none` (no highlighting). Use ```javascript. Indentation and blank lines inside the fence are
  preserved correctly in the CDATA either way.
- `confluence_update_page` **requires `title`** even when only changing content or emoji.
- Pass the actual emoji character (clipboard glyph) to the `emoji` param, not the string `"1f4cb"` -
  the latter gets hex-encoded per character into a garbage value.
- Use `confluence_get_page_diff` to verify an edit instead of re-reading the whole page; far cheaper
  and it proves what actually changed.

Local `.env` `JIRA_API_TOKEN` / `CONFLUENCE_API_TOKEN` were **expired** as of 13 Aug 2026 (401 on
`/rest/api/3/myself`). The MCP path is authenticated separately and works; only local scripts using
`.env` are affected. See [[project-sfcc237-mrt-topology-spike]] and [[project-tsd-templates]].
