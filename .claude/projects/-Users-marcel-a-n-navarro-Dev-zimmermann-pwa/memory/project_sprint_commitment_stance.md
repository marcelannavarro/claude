---
name: project-sprint-commitment-stance
description: "User's position against committing to a high volume of user stories per sprint while foundational stories are still in progress"
metadata: 
  node_type: memory
  type: project
  originSessionId: 29bd7f90-4bc3-4e11-acaf-08e029fc058f
  modified: 2026-08-25T09:46:29.341Z
---

In a 2026-08-25 leads meeting, the user pushed back on committing to a high volume of user
stories in a single sprint at this stage of the project. Many of the stories currently ahead
of the team are foundational, with other stories depending on them being completed first, so
a raw story-count commitment does not reflect that dependency load.

**Why:** committing to a large batch of stories without accounting for foundational
dependencies risks overcommitting the sprint, since downstream stories can't really start
until the foundational ones land. The user does separately support grouping/bundling related
stories together for tracking purposes, and treats that as a different question from the
volume-commitment concern, not a resolution to it.

**How to apply:** when helping with sprint planning, backlog grooming, or drafting new Jira
stories, flag when a proposed batch of stories depends on an unfinished foundational story,
and treat grouping-for-tracking as orthogonal to whether the total volume is appropriate to
commit to. See [[project_story_decomposition_pattern]] for the related epic-grouping
convention, and [[project_real_sprint_cadence]] for actual sprint dates.
