---
name: feedback-prove-dont-assert
description: Marcel's standard on this project — a verification must be made to fail on purpose before its pass counts; mutation testing is the bar
metadata:
  node_type: memory
  type: feedback
  originSessionId: f5f727b4-7546-4aa6-9d86-ef229e247d3f
  modified: 2026-08-22T02:20:00.000Z
---

Across the four-day SFCC-55 session (652997c6) the single recurring failure mode was
**verification theatre**: a check built from the same assumption as the thing it was checking,
which therefore passed vacuously. The session's own root-cause line was *"the verification
instrument was built from the same belief as the thing verified, and never made to fail on
purpose."*

Concrete instances, all self-caught after reporting a false all-clear:

- `safeHref` reported "well covered, 3 layers" — 13 test cases contained **zero backslashes**,
  the exact vector CodeRabbit had already named.
- A `fontFace` test had two tests iterating an empty array (`forEach` over `[]`) and missed the
  original bug entirely, because jsdom always provides `window` so every case took the browser branch.
- A mutation test "passed" because `perl -pi` works line-at-a-time and can't match `\n`.
- A recipe parity check false-alarmed three times on recipes whose `baseStyle` is a **function**
  (naive `Object.keys` reports every part missing).
- A literal-count sweep inflated 19→41 by matching `.rem` inside `removeEventListener`.

**Why:** Marcel repeatedly asked for "in-depth, intensive, exhaustive, recursive" V&V with
*"actual value and feasibility tests ran"* rather than face-value acceptance — and the pattern
above is precisely what defeats that. A green check that was never proven capable of going red
carries no information.

**How to apply:** before reporting any check as passing, mutate the thing under test so the check
*must* fail, and confirm it does. State plainly when something is asserted rather than proven —
e.g. a React ref clear is not DOM-observable, so say so instead of implying it was measured.
Related: [[project-test-harness-gaps]].
