# Working modes

Read when entering Mode 1 (Plan), Mode 1b (Design) or Mode 3 (Away).
Moved verbatim from `~/.claude/CLAUDE.md` on 2026-11-11; Mode 1b added
2026-11-20.

Four explicit modes govern how much I act before checking in. Default is
Mode 2 unless you say otherwise or the task itself calls for a different
one. The modes change *when* confirmation happens, not whether the rest of
this file's safety rules (destructive-action confirmation, branch-before-
editing, merge-to-main only when asked) apply - those hold in all of them.
Commit/push to the working branch is standing-authorized in every mode
(Mode 1 only after its plan is confirmed; Mode 1b for its design artifacts)
- merging to `main` always stays gated regardless of mode, see below.

## Mode 1 - Plan (deliberate)

Trigger: "let's plan this," "plan mode," or automatically for
architecturally significant / ambiguous / hard-to-reverse work.

- Break the problem into steps out loud before touching anything.
- Surface real options with tradeoffs (2-3, not 10) instead of silently
  picking one.
- No implementation edits, no side-effecting commands, until the plan is
  explicitly confirmed - writing planning artifacts themselves (an
  interview's findings, `SPEC.md`, the plan file below) doesn't count
  against this.
- Ask clarifying questions freely - this is the mode where asking is
  cheap. For a bigger or ambiguous feature, consider a structured
  interview (technical approach, UX, edge cases, tradeoffs - dig into
  what wasn't considered, not just the obvious questions) and write the
  result to `SPEC.md` before drafting the plan. For a long interview,
  start a fresh session to implement from the spec (or at minimum clear
  context - see Session & instruction hygiene) so the build phase isn't
  cluttered by the back-and-forth that produced it.
- Once the plan is confirmed, create a new feature branch before making
  any changes (name reflects the task, e.g. `feature/dark-mode-toggle`).
- Commit and push to that branch as work proceeds, tested increment by
  increment - same standing authorization as Mode 2, just gated on the
  plan being confirmed first. Merging to `main` stays gated regardless.
- Exit by presenting the final plan for confirmation - save it to
  `plans/<task-name>.md` in the repo as the durable record, not just
  Claude Code's internal plan-mode state - then move into Mode 2 to
  execute it.

## Mode 1b - Design (structure, no logic)

Trigger: "design mode". Sits between Plan and Build: the plan becomes a
skeleton in the repo, but nothing works yet. Usually follows a Mode 1 plan;
can be combined with Mode 3 (away) like Plan can.

Allowed (and expected):
- Own branch (e.g. `design/<task>`); commit and push the design artifacts
  as they are made.
- Folder structure, with a short README per module: what it is for, what
  it may depend on, what it must not touch.
- Types and interfaces with full signatures; functions as stubs whose body
  only throws `not implemented` (or the language's equivalent).
- Data formats: database tables, file/backup formats, settings with their
  defaults, state machines (states + transitions as typed tables), IPC /
  API contracts, error cases.
- Test files with the test names written and marked todo/skip, plus
  fixtures from real data (sampled, read-only).
- Diagrams (Mermaid) and decisions (CHANGES.md); the plan updated to match
  the design, open questions listed.
- Proof the skeleton holds: it type-checks / compiles, and the test runner
  runs (all tests todo/skipped, none failing). The project's existing
  regression check must stay green.

Not allowed:
- Working logic (beyond trivial constants, defaults and type guards needed
  to type-check).
- Network calls other than read-only research; changing settings of other
  programs; installing software; building or packaging releases.
- Adding dependencies for real - list them in the design (name, version,
  why) and install in Build.

Exit: an explicit "execute" / "build" moves to Mode 2, which fills in the
stubs and turns the todo tests into real ones. Answering design questions
or approving parts of the design is not that.

## Mode 2 - Build (default)

Trigger: everyday tasks by default, or "let's just build this."

- Create/switch to a feature branch before the first edit, unless
  already on one suited to this task (a hook blocks edits on `main`
  regardless, so this is about avoiding the interruption, not the rule
  itself).
- Before diving into a moderately-sized task, a quick round of scoping
  questions (not a full Mode 1 interview) can be worth it if
  requirements are fuzzy - cheaper than guessing wrong and redoing work
  mid-build.
- Make reasonable, reversible changes without asking step-by-step
  permission.
- Still ask on a genuine fork (architecture choice, ambiguous
  requirement).
- Still confirm before anything destructive/hard-to-reverse (force-push,
  `reset --hard`, deleting unmerged branches, etc.).
- Narrate briefly at key moments - findings, direction changes,
  blockers - not a play-by-play.
- For non-trivial changes (multi-file, or touching logic rather than a
  one-line fix), have a fresh-context subagent review the diff before
  calling it done - report only correctness gaps against the task, not
  style preferences. Skip this for small, trivial changes.
- Commit and push once a change is tested and working, per the Git &
  deployment workflow loop above - that section is itself the standing
  authorization, not something to ask about each time. Merging to
  `main` stays gated.

## Mode 3 - Away (autonomous)

Trigger: "I'll be away," "go do X while I'm out," scheduled/overnight
runs.

- In the first few minutes before the user leaves, ask any clarifying
  questions needed to scope the session (technical approach, priorities
  among tasks, anything genuinely ambiguous) - but don't block on it: if
  there's no response within 20 minutes, proceed using judgment and
  reasonable defaults, per the norm below.
- Start by creating a dedicated branch - everything for the session
  happens there; `main` stays untouched until reviewed.
- Push as far as possible without stopping. Use judgment + memory +
  reasonable defaults for anything that would normally be a quick
  check-in.
- Commit and push to the session branch(es) as work proceeds, tested
  increment by increment - same standing authorization as Mode 2.
  Merging to `main` stays gated for the end-of-session review, same as
  every other irreversible action below.
- When a genuine fork has multiple good options - not one
  obviously-best path - don't silently pick one. Build each viable
  option as its own branch, each in its own git worktree (not just a
  branch switch in one working copy, so versions don't collide on the
  filesystem) - e.g. `away/dark-mode-css-vars` vs
  `away/dark-mode-context-api` - so the choice on return is a
  comparison, not a guess. Keep the number of parallel versions small
  (2-3, matching the option-count guidance from Mode 1) and only do
  this for forks actually worth the extra build time - not every minor
  naming choice.
- Verify each task the same way Mode 2 does (above) before treating it
  as finished within the session; for longer unattended stretches,
  prefer a deterministic gate - a Stop hook or a `/goal` condition -
  over trusting "looks done," since nothing catches a false completion
  if no one's watching.
- Truly irreversible actions (force-push, merge to main, deleting
  anything, sending external messages) are never taken unilaterally -
  stay on the branch(es) and queue the go/no-go for the end.
- Keep a running decision log while working: what was chosen, why, and
  what the alternative was - this becomes the debrief. For forks
  resolved by building multiple versions, log what differs between them
  and any tradeoff worth knowing before picking.
- If genuinely blocked (missing credential, contradictory instructions,
  a fork with no safe default and no reasonable way to build both
  sides), stop and flag it - but treat this as the exception, not the
  norm.
- On return: one consolidated summary - what got done, what judgment
  calls were made, which forks produced multiple versions (with a
  recommendation, not just a dump), and a short list of key decisions
  needing a yes/no before anything ships further (including the merge
  itself).

## Mode-fit defaults

- Ambiguous requirements, new architecture, hard-to-reverse work ->
  start in Mode 1 even if not explicitly requested.
- A confirmed plan for a new app/module with many parts, where seeing the
  structure first is cheaper than reworking code -> offer Mode 1b (only
  enter it when asked).
- Routine implementation, bug fixes, well-scoped tasks -> Mode 2.
- Stepping away, overnight/weekend runs, cron/scheduled work -> Mode 3.

## Decision defaults per mode

- "Ask when it's a genuine fork" is Mode 1's and Mode 1b's norm (in 1b,
  record the fork in the design as an open question with a recommended
  default rather than stubbing both) and Mode 2's fallback;
  Mode 3 defers most forks to a multiple-version build and an
  end-of-session debrief instead of asking mid-session.
