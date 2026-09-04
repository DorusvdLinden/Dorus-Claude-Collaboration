# Dorus-Claude-Collaboration

A personal, evolving playbook for how Claude should work across projects -
not project-specific instructions, but the workflow patterns that turned
out to matter regardless of what's being built.

## What's here

[CLAUDE.md](./CLAUDE.md) - the actual rules. Written in the same format
Claude Code reads automatically from a project root, so a section can be
copied verbatim into a new project's own `CLAUDE.md` as a starting point.

Nine sections:

- **Verification & testing discipline** - verify facts before acting on
  them, auto-run regression/visual checks, root-cause with evidence (check
  a stale process's own output, not a fresh debug session), use crafted
  fixtures when live data can't reliably cover a case, and a two-session
  Writer/Reviewer split for high-stakes changes.
- **Documentation as a living system** - four minimal docs per project
  (`README.md`, `TODO.md`, `IDEAS.md`, `CHANGES.md`), each with a
  distinct owner; update docs in the same change that invalidates them.
- **Artifact preservation** - never delete a generated render/screenshot/
  mockup once shown; organize by task in subfolders, not a flat pile.
- **Git & deployment workflow** - branch before editing in every mode;
  commit/push standing-authorized once tested; merging to `main` always
  stays gated; watch for persistent processes needing an explicit
  restart after deploy; container entrypoints that drop root privileges
  have recurring gotchas (PATH loss on `su`, first-mount volume
  ownership, GID collisions, state hiding outside the mounted volume).
- **Decision-making & communication** - ask on a genuine fork, don't ask
  when there's a reasonable default, and prefer trying a cheap reversible
  experiment (then `/rewind` if wrong) over asking upfront.
- **Working modes** - three explicit modes (Plan / Build / Away)
  controlling how much autonomy to use before checking in, each with its
  own branching, spec-interview, and review rules.
- **Memory & continuity** - persist durable cross-session facts only;
  treat session/decision logs as ephemeral unless they reveal a standing
  preference.
- **Session & instruction hygiene** - keep `CLAUDE.md` itself pruned,
  push zero-exception rules into hooks rather than advisory text, and
  manage context deliberately (`/clear`, subagents for open-ended
  exploration).
- **This repo's own maintenance** - after any change here, ask whether to
  re-sync the global `~/.claude/CLAUDE.md` copy.

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
project, underneath whatever project-specific `CLAUDE.md` is present.
After any change here, re-copy the file to that location to keep the two
in sync.

## Origin

Started while working on
[InkyPiZero](https://github.com/DorusvdLinden/InkyPiZero), a Raspberry Pi
e-paper weather display - the first `CLAUDE.md` this pattern came from.
