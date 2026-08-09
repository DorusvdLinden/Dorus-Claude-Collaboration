# Dorus-Claude-Collaboration

A personal, evolving playbook for how Claude should work across projects -
not project-specific instructions, but the workflow patterns that turned
out to matter regardless of what's being built.

## What's here

[CLAUDE.md](./CLAUDE.md) - the actual rules, organized by theme (testing,
documentation, git/deployment, decision-making, memory). Written in the
same format Claude Code reads automatically from a project root, so a
section can be copied verbatim into a new project's own `CLAUDE.md` as a
starting point.

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

## Origin

Started while working on
[InkyPiZero](https://github.com/DorusvdLinden/InkyPiZero), a Raspberry Pi
e-paper weather display - the first `CLAUDE.md` this pattern came from.
