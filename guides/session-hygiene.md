# Session, memory and instruction hygiene

Read when processing many images, when a session is getting long or
off-track, when deciding what to save to memory, or when editing
`~/.claude/CLAUDE.md` itself. Moved verbatim from `~/.claude/CLAUDE.md`
on 2026-11-11.

## Session & instruction hygiene

- **Prune `~/.claude/CLAUDE.md` regularly.** For each line, ask: would
  removing it cause mistakes? If not, cut it. A bloated file causes
  instructions to get ignored - if Claude keeps doing something despite a
  rule against it, the file is probably too long, not the rule too weak.
- **Move situational knowledge out of that file.** Guidance that's only
  relevant sometimes (a specific integration's quirks, a rarely-touched
  subsystem) belongs in a Skill or one of these guides, loaded on demand,
  not in the always-loaded `CLAUDE.md`.
- **Use hooks for anything that must happen with zero exceptions.**
  `CLAUDE.md` is advisory - Claude can misread or deprioritize it under
  context pressure. A hook (lint after edit, block writes to a sensitive
  path, a Stop-hook gate on a verification check) is deterministic and
  can't be skipped the way a text instruction can.
- **Clear context between unrelated tasks (`/clear`).** Don't let one
  session accumulate a second, unrelated task's files and commands on
  top of the first - it degrades performance on both.
- **Process bulk photos/images in small batches, compacting or clearing
  between batches.** Any task that reads many images in a row (cropping,
  verifying, comparing screenshots, reviewing mockups) should work
  through them ~5 at a time, then `/compact` (or `/clear` if that's not
  enough) before starting the next batch, rather than letting images
  from every batch pile up in one growing context. This applies
  regardless of what the images are for - reading a full-resolution
  image into an already-large context costs far more than reading the
  same image into a small one, because prompt caching has to rewrite the
  entire accumulated context on the next turn, not just add the new
  image. A single overnight session that skipped this (processing ~90
  photos with no batching or compaction) burned the bulk of its token
  cost in just two multi-minute bursts near the end, once the
  accumulated context had grown large.
- **After correcting the same mistake twice without success, stop
  patching.** Clear and restart with a better initial prompt that
  incorporates what was learned, rather than continuing to layer
  corrections onto an already-polluted context.
- **Scope open-ended investigation to a subagent.** Exploring an
  unfamiliar area in the main conversation fills its context with
  everything read along the way; a subagent explores in its own context
  and reports back only the summary.

## Memory & continuity

- **Persist durable, cross-session facts**: infrastructure access details,
  key decisions and their rationale, standing preferences the user has
  stated more than once. Don't persist ephemeral task state or anything
  easily re-derived by reading the current code.
- **Keep memory scoped to what's actually reusable.** A fact specific to
  one project's tech stack belongs in that project, not here.
- **A Mode 3 decision log is session output, not memory.** Only persist
  an entry from it if it reveals a standing preference or fact that will
  matter next time - the rest is ephemeral task state, already served by
  the end-of-session debrief itself.

## Project documentation (full rules)

- Add topic-specific docs (`docs/installation.md`, `docs/settings.md`,
  `docs/troubleshooting.md`, etc.) only once a topic outgrows a paragraph
  in the README - don't scaffold empty doc files upfront.
- **`IDEAS.md` is the user's own space**, not Claude's to groom. Read it
  for context when relevant; add or restructure entries in it only when
  asked to - don't apply `TODO.md`'s add/check-off/never-delete
  discipline here unprompted.
- **`CHANGES.md` is a numbered log of major decisions with current
  status** (active / superseded-by-\<entry\> / rejected). This is what
  makes it possible to reconstruct *why* something looks the way it does
  later, including documenting approaches that were tried and rejected
  and why - without this, rejected ideas tend to get silently
  re-proposed and re-litigated.

## Origin of `~/.claude/CLAUDE.md`

The global file and these guides are copies of `CLAUDE.md` and `guides/`
in the Dorus-Claude-Collaboration repo
(https://github.com/DorusvdLinden/Dorus-Claude-Collaboration); after a
change there, re-copy both, and vice versa. The full pre-shortening
version (2026-11-11) is in that repo's git history and at
`~/.claude/backups/CLAUDE.md.2026-11-11-before-shortening`.
