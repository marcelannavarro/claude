---
name: reference-jira-ac-field
description: Zimmermann Jira acceptance criteria live in customfield_10231, not the issue description
metadata:
  type: reference
---

On `zimmermannworkboard.atlassian.net`, a story's **acceptance criteria are in
`customfield_10231`** ("Acceptance Criteria", project-scoped textarea) — **not** in the
description. Fetching only `description` misses them entirely and makes a card look
underspecified when it isn't.

Some issues return it as plain text with `#` list markers; others return **ADF**
(`{type: "doc", version: 1, content: [...]}`) which needs flattening to read. In one
batch, SFCC-315/270/795 came back as ADF and SFCC-250/271/272/275 as plain text.

`jira_search` with `fields=key,summary,customfield_10231` pulls several cards' ACs in one
call, which is much cheaper than per-issue fetches.

Sprint is `customfield_10020` on this instance (see [[project-real-sprint-cadence]]).
Cards are PO-approved and **not edited** — record deviations as a comment instead
(see [[project-cart-bundle-decisions]]).
