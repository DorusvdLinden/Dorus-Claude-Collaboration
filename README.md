# Dorus-Claude-Collaboration

A personal, evolving playbook for how Claude should work across projects -
not project-specific instructions, but the workflow patterns that turned
out to matter regardless of what's being built.

## What's here

[CLAUDE.md](./CLAUDE.md) - the rules most tasks need, kept short (~75
lines) because it is loaded into every session: verify, project docs,
artifacts, git, decisions, working modes (summary), memory and context.
Each section points to a guide for the detail.

[guides/](./guides/) - the situational detail, read on demand when its
trigger applies (not loaded automatically):

- [working-modes.md](./guides/working-modes.md) - full Plan / Build /
  Away rules, mode-fit defaults; read when entering Mode 1 or 3.
- [deployment.md](./guides/deployment.md) - "a push isn't a deploy" for
  long-running processes, scoped edits on files holding secrets, NAS
  dashboard, container privilege-drop gotchas (PATH loss on `su`,
  first-mount volume ownership, GID collisions, state outside the volume).
- [verification.md](./guides/verification.md) - evidence-based
  root-causing (credentials, stale processes), crafted fixtures,
  Writer/Reviewer split, full artifact-preservation rules.
- [session-hygiene.md](./guides/session-hygiene.md) - pruning
  `CLAUDE.md`, hooks for zero-exception rules, `/clear`, image batching,
  memory scope, full project-doc rules.

The split (2026-11-11) moved text verbatim; the pre-split single file is in
git history. Don't put the guides in `~/.claude/rules/` - Claude Code loads
that folder automatically, which would undo the saving.

## How to use this

**Starting a new project**: skim `CLAUDE.md` here, copy the sections that
apply into the new project's own `CLAUDE.md`, and adapt the generic
guidance into project-specific specifics there (the exact test command, the
exact deploy target, the exact doc files to keep current). Don't just point
a new project at this repo instead of writing its own rules - project
context (paths, commands, architecture) belongs with the project.

**Updating this repo**: when a project surfaces a lesson that's clearly
bigger than that one project - a correction given more than once, or a
workflow that visibly paid off - bring it back here in generalized form.
Strip anything project-specific (file paths, tech stack, exact commands)
before adding it; if it can't be stated without naming a specific project's
details, it probably belongs in that project's `CLAUDE.md` instead, not
here.

**Global default**: `CLAUDE.md` here is also copied to `~/.claude/CLAUDE.md`,
where Claude Code applies it as the default for every session across every
project, underneath whatever project-specific `CLAUDE.md` is present, and
`guides/` is copied to `~/.claude/guides/` (the global file links there).
After any change here, re-copy both to keep them in sync - when Claude
changes either side, it asks whether to re-sync the other rather than
doing it silently. The standing authorizations in `CLAUDE.md` (commit/push,
branch-before-editing) carry over to every project through that global
copy, so a project's own `CLAUDE.md` only adds project specifics.

**Global hooks**: [hooks/](./hooks/) holds reference copies of the hooks
deployed to `~/.claude/hooks/` and wired up in `~/.claude/settings.json`,
enforcing CLAUDE.md rules that can't be trusted to advisory text alone
(see [guides/session-hygiene.md](./guides/session-hygiene.md) -
zero-exception rules belong in hooks, not prose):

- `block-main-mutations.js` - blocks `Edit`/`Write`/`NotebookEdit` and
  `git commit` while the current branch is `main`/`master`, enforcing
  "branch before editing" in every mode. Exempts Mode 1 planning
  artifacts (`SPEC.md`, `plans/<task-name>.md`), which Mode 1
  ([guides/working-modes.md](./guides/working-modes.md)) explicitly
  allows to be written before a branch exists.
- `stage-ideas-md.js` - before every `git commit`, auto-stages `IDEAS.md`
  if it has pending changes, so manual edits made outside a Claude
  session (`IDEAS.md` is the user's own space) always make it into the
  next commit without being asked.

`~/.claude` isn't a git repo, so these can't be symlinked in and tracked
live - this is a manually-synced reference copy, the same pattern as the
`CLAUDE.md` copy above. After changing a hook, copy the file to (or from)
`~/.claude/hooks/` to keep the two in sync.

## Origin

Started while working on
[InkyPiZero](https://github.com/DorusvdLinden/InkyPiZero), a Raspberry Pi
e-paper weather display - the first `CLAUDE.md` this pattern came from.
