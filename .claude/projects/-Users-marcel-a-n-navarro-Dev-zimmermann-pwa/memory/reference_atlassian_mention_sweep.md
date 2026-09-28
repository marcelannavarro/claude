---
name: reference-atlassian-mention-sweep
description: How to find all Jira/Confluence mentions of a person via the mcp-atlassian tools — Jira has no mention field, use the account-ID text-search trick
metadata:
  type: reference
---

Marcel's Atlassian account ID: `712020:08a6f120-c836-4f71-92db-c97999401c49`
(extract anyone's from a mention link in a `confluence_get_comments` body: `.../wiki/people/<accountId>?ref=confluence`)

**Confluence** — CQL `mention = currentUser()` works and is global (no space filter needed).
Returns both `type=comment` and `type=page` (page-body mentions).

**Jira** — has *no* mention field, and `comment ~ "Marcel"` returns **zero**: mentions are
stored as ADF account-ID markup, not display text. The working query is
`comment ~ "712020:08a6f120-c836-4f71-92db-c97999401c49"` — the account ID *is* text-indexed.
Also check `description ~ "<accountId>"`. Jira Cloud returns `total: -1` (no count) — page via
`next_page_token`.

**Traps:**
- `jira_get_issue` drops comments unless `comment` is named explicitly in `fields`.
- `confluence_get_comments` silently truncates at ~25 comments/page — on a busy page it returns
  the *oldest* 25 and hides newer ones. Cross-check with CQL `type = comment AND container = "<pageId>"`,
  and `AND creator = currentUser()` to find your own replies.
- `confluence_search` returns comment IDs but builds the `url` as if they were page IDs — the link
  is wrong; resolve the parent page by title instead.
- Confluence inline-comment resolved/unresolved state is **not** exposed by these tools.
- To rule out a result cap, date-slice the query (`lastModified >= "YYYY-MM-DD"`) and check the
  slices sum to the unsliced total.

Sweep run 2026-08-19 → [[project-mention-sweep-2026-08-19]]
