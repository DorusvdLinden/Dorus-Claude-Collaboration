# Standard work process

Portable collaboration rules distilled from real projects, not a single
project's specifics. When starting a new project, skim this, copy/adapt
whatever applies into that project's own `CLAUDE.md`, and leave the
project-specific detail (exact file paths, exact test commands, exact tech
stack) there rather than here. When a project teaches a new lesson that
generalizes, bring it back here - see [README.md](./README.md) for the
update process.

## Verification & testing discipline

- **Verify before asserting.** Before recommending an action based on a
  remembered fact (a file path, a function name, a config value, an access
  credential), check that it's still true. A memory or an earlier read is a
  claim about the past, not a guarantee about now.
- **Establish a fast regression check early, and run it automatically.**
  Once a project has a way to exercise its core surface area cheaply (a
  test script, a render/build command, a small suite of representative
  cases), run it after every relevant change without being asked - not just
  when something seems off. Treat "I didn't test it" as equivalent to "I
  don't know if it works."
- **Local success isn't "done" if a real deployment step exists.** If the
  project has a real target (a physical device, a live server, a deployed
  environment), verify end-to-end on that target before calling the work
  finished, not just in a local/mocked environment.
- **Generate a fresh verification artifact after every relevant change**,
  not just when a change to it was intended, for any project with a
  visual or rendered output (a screenshot, a mock render, a preview
  image). Cheap to do, and it catches regressions in output nobody was
  specifically watching for - never delete these, see Artifact
  preservation.
- **Root-cause with evidence before proposing a fix.** When something
  fails, gather direct evidence (logs, actual state, a minimal reproduction)
  before deciding why - and be willing to discard the first hypothesis and
  pivot the whole approach if the evidence contradicts it. Document what the
  evidence actually showed, not just the conclusion reached. For a
  rejected credential specifically, check its literal content (length,
  stray whitespace) before escalating - copy/paste truncation is a
  common, easy-to-rule-out cause.
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

## Documentation as a living system

Every project keeps four minimal documents:

- `README.md` - what the project is, plus a user manual covering install
  and use.
- `TODO.md` - Claude's own capture list: anything rough observed while
  working but not fixed in the moment.
- `IDEAS.md` - the user's own space for ideas, freely user-edited.
- `CHANGES.md` - a numbered log of key changes, with current status.

**Initialize all four in the first session of a new project** (even as
short stubs), alongside a project `CLAUDE.md` adapted from
[Dorus-Claude-Collaboration](https://github.com/DorusvdLinden/Dorus-Claude-Collaboration)
(see that repo's README for the copy/adapt process) - don't let the doc
set accumulate ad hoc as the project grows.

Add topic-specific docs (`docs/installation.md`, `docs/settings.md`,
`docs/troubleshooting.md`, etc.) only once a topic outgrows a paragraph
in the README - don't scaffold empty doc files upfront.

- **Update docs in the same change that invalidates them**, not "later" -
  if a change renames a field, adds an option, or changes a default, the
  doc describing that thing changes in the same commit/session.
- **Sweep for staleness, not just add new content.** Before calling a
  change done, search for claims elsewhere in the docs that the change just
  contradicted (old names, "doesn't support X yet" statements that are now
  false) - these accumulate silently if only additions are made.
- **`TODO.md` captures anything rough noticed while working**, even
  outside the current task's scope (a bug spotted in passing, a
  follow-up worth doing, a corner cut to keep scope tight) - add it
  automatically, without being asked. Check items off when fixed rather
  than deleting them, so resolution history stays visible. Only delete a
  specific completed entry when explicitly asked for that one item -
  never as general cleanup, and never assume one deletion request
  extends to the rest of the list.
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

## Artifact preservation

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

## Git & deployment workflow

- **The loop**: branch -> implement -> test locally -> commit (one commit
  per logical change, message explains *why*, not just what) -> push ->
  deploy to the real target if one exists -> verify success on that
  target.
- **Commit and push to the working branch are standing-authorized once a
  change is tested and working**, in every mode (Mode 1 only after its
  plan is confirmed and a branch exists - see Working modes below) - this
  loop is itself the ongoing authorization, not something to ask about
  each time. Only merging to `main` and anything destructive (below) stay
  gated.
- **Push immediately after every commit.** Never leave a commit sitting
  local-only - batching several commits before a single push widens the
  window where local and remote (and any collaborator or deploy target
  pulling from remote) disagree about the branch's state.
- **Branch before editing, in every mode** (see Working modes below);
  merge to the main branch only when explicitly asked, and clean up
  (delete, locally and on the remote) after merging. When a mode produces
  multiple candidate branches for the same fork, the same
  not-fully-merged rule applies to the ones not picked - confirm before
  deleting them rather than cleaning up unilaterally.
- **Never take a destructive or hard-to-reverse action** (force-push,
  `reset --hard`, discarding uncommitted work, deleting a branch that isn't
  fully merged) without confirming first, scoped to exactly what's being
  discarded - a prior approval doesn't extend to a new instance of the same
  category of action.
- **A push isn't a completed deploy for a persistent/long-running
  process.** A one-shot job picks up new code on its next run
  automatically, but an already-running process keeps executing old
  in-memory code until it's explicitly restarted/reloaded. Verify the
  running process's actual start time against the source's, not just
  that the file changed on disk, before trusting a "didn't work" result.
- **Use scoped edits on remote or shared files that also hold live
  secrets** (e.g. editing just the specific line rather than
  opening/dumping the whole file), so credentials aren't needlessly
  pulled into view or output.
- **Reuse existing git/GitHub authorization across projects, don't
  re-derive it per repo.** SSH keys, `gh` CLI login, and credential
  helpers are machine-level, not per-project - check what's already
  configured (`gh auth status`, existing SSH config) before assuming a
  new project needs fresh git credentials, and persist where working
  credentials live (see Memory & continuity) so a later project doesn't
  redo the discovery.
- **Investigate real-world risk before a big architecture change** when a
  cheap empirical check exists (a throwaway test against the actual target)
  rather than assuming from documentation - what's documented as the
  standard approach doesn't always work on the actual hardware/environment
  in front of you.
- **Whenever a new project gets Docker-hosted on Dorus's NAS, add it to
  `nas-dashboard` (http://192.168.1.2:8093/) as part of that deploy step**,
  so the dashboard stays a complete index of what's actually running there.

## Decision-making & communication

- **Ask when it's a genuine fork**: an architecture choice with real
  tradeoffs, an ambiguous requirement, or "should I proceed even though this
  might disrupt something live" - a structured question with real options
  beats guessing wrong and redoing work.
- **Don't ask when there's a reasonable default.** Make the call, state it,
  and let the user redirect. Over-asking is its own cost.
- **For a cheap, reversible experiment, try it and roll back if wrong,
  rather than asking first.** Claude Code checkpoints file state on every
  prompt (`/rewind` restores code/conversation), so a fork that's fully
  undoable this way doesn't need to block on a question - reserve asking
  for forks with a real cost to being wrong (something merged, deployed,
  sent externally, or otherwise not cleanly undoable by rewinding alone).
- **Be explicit about real risk before a disruptive action** on live
  infrastructure (a reachable device, a running service) - name what could
  go wrong, not just that you're proceeding. If repeated attempts at the
  same risky action fail, stop and report rather than continuing to
  disrupt blindly.
- **Plan before implementing anything architecturally significant** - write
  out the approach, research the unknowns, get explicit sign-off - rather
  than discovering the shape of a large feature through trial and error in
  the codebase.
- **State findings and decisions directly.** A progress update is a
  conclusion, not a narrated stream of the deliberation that produced it.
- **These defaults shift by mode.** "Ask when it's a genuine fork" is
  Mode 1's norm and Mode 2's fallback; Mode 3 defers most forks to a
  multiple-version build and an end-of-session debrief instead of asking
  mid-session - see Working modes for the concrete rules per mode.

## Working modes

Three explicit modes govern how much I act before checking in. Default is
Mode 2 unless you say otherwise or the task itself calls for a different
one. The modes change *when* confirmation happens, not whether the rest of
this file's safety rules (destructive-action confirmation, branch-before-
editing, merge-to-main only when asked) apply - those hold in all three.
Commit/push to the working branch is standing-authorized in every mode
(Mode 1 only after its plan is confirmed) - merging to `main` always
stays gated regardless of mode, see below.

### Mode 1 - Plan (deliberate)

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

### Mode 2 - Build (default)

Trigger: everyday tasks by default, or "let's just build this."

- Create/switch to a feature branch before the first edit, unless
  already on one suited to this task - never build directly on `main`.
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

### Mode 3 - Away (autonomous)

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

### Mode-fit defaults

- Ambiguous requirements, new architecture, hard-to-reverse work ->
  start in Mode 1 even if not explicitly requested.
- Routine implementation, bug fixes, well-scoped tasks -> Mode 2.
- Stepping away, overnight/weekend runs, cron/scheduled work -> Mode 3.

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

## Session & instruction hygiene

- **Prune this file regularly.** For each line, ask: would removing it
  cause mistakes? If not, cut it. A bloated file causes instructions to
  get ignored - if Claude keeps doing something despite a rule against
  it, the file is probably too long, not the rule too weak.
- **Move situational knowledge out of this file.** Guidance that's only
  relevant sometimes (a specific integration's quirks, a rarely-touched
  subsystem) belongs in a Skill, loaded on demand, not in the
  always-loaded `CLAUDE.md`.
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

## This repo's own maintenance

Not a portable rule - specific to working in this repo, so skip it when
copying sections elsewhere.

- **After any change to this file, ask whether to also re-sync
  `~/.claude/CLAUDE.md`** (see README.md's "Global default" section)
  rather than doing it silently or letting the two drift apart.
- **The standing authorizations in this file carry over automatically to
  every new project** via that same global `~/.claude/CLAUDE.md` copy -
  a new project's own `CLAUDE.md` only needs to add project-specific
  specifics, not re-grant commit/push, branch-before-editing, or the
  other standing permissions already established globally.
