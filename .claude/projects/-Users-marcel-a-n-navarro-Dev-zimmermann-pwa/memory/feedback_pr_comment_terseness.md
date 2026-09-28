---
name: feedback-pr-comment-terseness
description: "PR review comments to other authors should state the ask directly, no justification/reasoning padding"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f4400464-2081-4e6b-a2cf-b7c0c8f6b68e
  modified: 2026-09-15T11:33:08.106Z
---

State the ask directly in PR review comments to other authors ("add a test for X", "run eslint --fix on Y"). Don't add the reasoning, consequence, or mechanism behind the ask unless the ask itself is genuinely unclear without it.

**Why:** Marcel called this out directly during [[project_sfcc266_pr111_review]] after I drafted comments with explanatory padding ("that's the part most likely to break silently if someone tweaks it later", "testing the whole page is awkward here since..."). His reaction: "isn't that simpler and more straightforward? why are we trying to overexplain/justify when we don't have to." The author can read the code themselves to see why; the comment's job is to say what needs doing.

**How to apply:** This is the opposite of [[feedback_eli5bitfedlotp_register]], which is specifically for messages *to Marcel* (consequence, then mechanism, then fix) — that register is for a FED lead who wants the full picture. PR comments go to a *different* audience (the PR author, a peer developer), so default to terse there: the ask, maybe the file/line, nothing else. This matches zimmerMANNReview's own stated comment-drafting rules (no opening praise, no jargon-stacking) — the gap was that I wasn't fully applying that rule myself before he flagged it. Applies to inline PR comments and general/review-body comments alike, not just one or the other.
