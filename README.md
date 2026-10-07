# AI usage disclosure

Per the exercise's "Our stance on AI" section, AI usage on this project is disclosed here.

**Policy for this project:** all application code is written by hand, to demonstrate my own
skills. AI (Claude Code, Anthropic) is used only in these ways:

- **Code review, on request** — asking AI to review hand-written code specifically for
  potential bugs or performance issues.
- **Architecture consultant** — discussing architecture/design decisions and interpretations
  of the exercise brief with AI, as a sounding board, without it writing the implementation.
- **Audit log maintenance** — AI writes and maintains the AI usage log in this README from
  its own record of each session. This is documentation only, and the README is the only
  file in the repo AI edits. I review the entries.

**Enforcement:** if I ask the AI something that falls outside those two categories (e.g. ask
it to write or edit application code), it is instructed to question it and decline by
default. It will only proceed if I explicitly insist, and any such exception is then recorded
in the log below rather than left undisclosed.

The initial project setup and first commits (`85501dc` through `fc91306` — project scaffold,
networking guard checks, rendering the cake list) were written by hand, without any AI
involvement. Usage from this point onward is logged below as it happens, rather than
disclosed only as a single blanket statement at submission time. Logging granularity: one row
per distinct topic/question — follow-ups on the same topic update that row rather than adding
a new one each time.

**AI usage log:**

| Date | What AI assisted with |
|------|------------------------|
| 2026-09-24 | Drafted this AI usage disclosure document itself (not application code), using Claude Code, per my request and revised on my feedback. |
| 2026-09-24 | Architecture/interpretation consulting: asked AI to identify which error conditions are required ("Must have") vs. nice-to-have in the exercise brief. No code written. |
| 2026-09-25 | Architecture consulting: asked AI when to prefer `.popover` vs `.sheet` in SwiftUI, for the cake description popup requirement. No code written. |
| 2026-09-25 | Architecture consulting: discussed downsides of adding a stored `UUID` to `Cake` for `Identifiable` conformance (for `sheet(item:)`) vs. a computed `id` derived from `title`. No code written. |
| 2026-09-29, 2026-10-05 | Code review, on request: a full audit of the submission against the exercise brief. On 09-29 AI read all the sources and the git history, built and ran the unit tests, and checked the live API. Findings included image distortion, the `200..<299` status range, cancellation shown as an error, the sort comparator, test coverage gaps and missing TODOs. On 10-05 AI re-read the sources after those fixes (no build or test run; the brief PDF could not be rendered) and reported remaining points: silent refresh failures, untested network layer, dead commented code in `Network.swift`, sheet description not scrollable, and a retroactive `Equatable` in tests. No code written by AI. |
| 2026-10-06 | Architecture consulting: handling concurrent `load()` calls and silent failed refreshes. Discussed coalescing in-flight work by keeping the `Task` and awaiting it versus a boolean guard or cancel-and-restart, the interaction with cancellation handling, and how to test it. AI reviewed the resulting TODOs in `CakeViewModel.swift` by reading the code, building and running the tests. No application code written by AI. |
