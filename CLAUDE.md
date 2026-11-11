# Standard work process

Portable rules for every project; project specifics go in the project's own
CLAUDE.md. Situational detail lives in ~/.claude/guides/ - read the named
file when its trigger applies.

## Verify
- Verify before asserting: re-check remembered paths, names, config and
  credentials before relying on them.
- Set up a fast regression check early; run it after every relevant change,
  unasked. Untested = unknown.
- Visual/rendered output: make a fresh render after every relevant change
  and keep it.
- If a real target exists (device, server), verify there before "done".
- Root-cause with evidence (logs, actual state, minimal repro) before
  fixing; drop the first hypothesis if the evidence contradicts it.
- Prefer a cheap empirical check over reasoning from docs.
- Credentials, long-running processes, fixtures, high-stakes reviews,
  full artifact rules: ~/.claude/guides/verification.md

## Project docs
Every project has README.md (what it is + user manual), TODO.md (my
capture list), IDEAS.md (the user's - don't groom it) and CHANGES.md
(numbered decisions, status active / superseded / rejected). Create all
four plus a project CLAUDE.md (adapted from Dorus-Claude-Collaboration)
in the first session.
- Update docs in the same change that invalidates them; sweep for claims
  the change made false.
- TODO.md: add rough edges unasked; check items off, never delete unless
  that one item is asked for.

## Artifacts
- Durable things (renders, specs, plans/<task>.md) live in the repo, not
  in ~/.claude.
- Never delete a generated artifact once shown or referenced; a new
  version gets a new name, in a per-task subfolder.

## Git
- Loop: branch -> implement -> test -> commit (say why) -> push
  immediately -> deploy and verify if a target exists.
- Commit + push to the working branch are standing-authorized once tested
  (Mode 1: after the plan is confirmed).
- Branch before editing (a hook enforces this). Merge to main only when
  asked, then delete the branch locally and remotely.
- Confirm before anything destructive (force-push, reset --hard,
  discarding work, deleting unmerged branches); one approval doesn't
  cover the next.
- Reuse machine-level git/gh auth (check `gh auth status` first).
- Docker/NAS deploys, long-running processes, remote files holding
  secrets: ~/.claude/guides/deployment.md

## Decisions
- Ask on genuine forks (architecture, ambiguous requirement, risk to
  something live); otherwise pick a reasonable default, state it, go on.
- Cheap, reversible experiment: try it and roll back if wrong.
- Name the real risk before disrupting live infrastructure; stop after
  repeated failures.
- State findings and decisions directly, not the deliberation.

## Working modes
- Mode 1 Plan ("plan", or ambiguous / architectural / hard-to-reverse):
  no implementation until the plan is confirmed; save it to
  plans/<task>.md.
- Mode 2 Build (default): feature branch, reversible changes without
  asking, fresh-context subagent review of non-trivial diffs.
- Mode 3 Away ("I'll be away", scheduled runs): own branch, real forks
  built side by side in worktrees, decision log, nothing irreversible,
  one debrief at the end.
- Read ~/.claude/guides/working-modes.md when entering Mode 1 or Mode 3.

## Memory and context
- Persist durable cross-session facts (access details, decisions,
  repeated preferences), not task state or anything re-derivable.
- Clear context between unrelated tasks; read images about 5 at a time
  and compact between batches; send open-ended exploration to a subagent;
  after two failed corrections, restart with a better prompt.
  Details: ~/.claude/guides/session-hygiene.md
