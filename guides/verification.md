# Verification details

Read when debugging a failure, a rejected credential or a long-running
process, when live data can't trigger a case, or before a high-stakes
change. Moved verbatim from `~/.claude/CLAUDE.md` on 2026-11-11.

- **Root-cause with evidence before proposing a fix.** When something
  fails, gather direct evidence (logs, actual state, a minimal reproduction)
  before deciding why - and be willing to discard the first hypothesis and
  pivot the whole approach if the evidence contradicts it. Document what the
  evidence actually showed, not just the conclusion reached. For a
  rejected credential specifically, check its literal content (length,
  stray whitespace) before escalating - copy/paste truncation is a
  common, easy-to-rule-out cause. For a supervised/long-running process,
  check its own original output, not a fresh debug shell/session attached
  to the same environment - a new session can pick up corrected state
  (env vars, working directory) that the stale original process never
  got, making a live bug look intermittent or already fixed when it
  isn't.
- **Prefer an empirical check over an assumption when the cost is low.** If
  a risk can be tested directly and cheaply (e.g., a throwaway change on the
  real target, reverted after), do that instead of reasoning it out from
  documentation alone.
- **Real/live checks aren't always sufficient for full coverage.** When a
  behavior depends on conditions live data can't reliably trigger on any
  given run (a rare event, a specific data combination), add deterministic
  crafted fixtures for that specific case, while keeping real-pipeline
  checks as the default for everything else.
- **For high-stakes changes, use a Writer/Reviewer split across two
  sessions.** One session implements; a second, fresh session reviews the
  diff with no memory of the reasoning that produced it, catching things a
  same-session self-review misses. Reserve this for changes where being
  wrong is costly (security, data migrations, anything hard to reverse) -
  it's overhead most changes don't need. This stacks with, rather than
  replaces, Mode 2/3's lighter subagent review for non-trivial changes
  (below) - a high-stakes change gets both.
- **Generate a fresh verification artifact after every relevant change**,
  not just when a change to it was intended, for any project with a
  visual or rendered output (a screenshot, a mock render, a preview
  image). Cheap to do, and it catches regressions in output nobody was
  specifically watching for - never delete these, see Artifact
  preservation.

## Artifact preservation (full rules)

- **Everything durable lives in the project repo, not `~/.claude`.**
  Generated artifacts (below), schema/spec documents, and confirmed
  plans (`plans/<task-name>.md`, see Working modes) all belong in the
  repo's own file tree - Claude Code's user-level directory is
  session/environment state, not a place for project record-keeping.
- **Never delete a generated artifact (render, screenshot, mockup, sample
  output) because it looks superseded.** Treat every version as a kept
  record of an iteration, not scratch space - if something needs
  regenerating with different settings, give the new version a distinctly
  named file and leave every prior version in place. The only safe deletion
  is a file created and discarded within the same tool-call chain, before
  it was ever shown or referenced.
- **Anything shown to the user during testing is kept, no exceptions.**
  Once an artifact has been surfaced - shown in a message, referenced, used
  to demonstrate a result - the "safe to delete" window above has closed;
  it's a permanent record from that point on.
- **Organize artifacts by task, not as a flat pile.** Create a new
  subfolder per larger task or branch (e.g.
  `mock_display_output/dark-mode-toggle/`) instead of writing directly
  into the top-level output folder, so a given iteration's artifacts can
  be found back easily later. Small checks within an already-scoped task
  share that task's existing subfolder rather than each getting their own.
