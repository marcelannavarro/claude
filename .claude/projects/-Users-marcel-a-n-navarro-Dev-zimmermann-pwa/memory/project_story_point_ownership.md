---
name: project-story-point-ownership
description: Only Hazel Cacalda has ever written a story point on the SFCC board; Marcel has never set one, so there is no personal estimation history to pattern-match against
metadata:
  type: project
---

Verified 2026-09-22 via `jira_batch_get_changelogs` across 23 tickets spanning
multiple squads and assignees: **Hazel Marie Cacalda is the only person who has
ever written a value into `customfield_10016` (Story point estimate)** on the SFCC
board. Marcel has never set one — on his own 19 pointed tickets his changelog
entries are only `duedate`, `status`, `Rank`, `summary`, `description`.

So when someone asks "how do I usually assign points", the honest answer is that
his input has only ever been verbal, in the Tech Design ceremony, and recorded by
Hazel. Per Confluence *Story Workflow* (page 247922696), the **In Tech Design**
status is where "Story is sized and estimated here. Developers and QA are involved
at this stage."

**Why:** any request to "match my existing estimation pattern" rests on a false
premise. The only defensible basis is the board's own calibration ladder (see
[[project-story-point-calibration]]), not his personal history.

**How to apply:** say this plainly rather than inventing a pattern from numbers he
didn't set. Check the changelog author before treating any existing estimate as his.

Related: [[project-real-sprint-cadence]], [[feedback-prove-dont-assert]]
