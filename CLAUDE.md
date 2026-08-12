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

## Documentation as a living system

Every project keeps four minimal documents:

- `README.md` - what the project is, plus a user manual covering install
  and use.
- `TODO.md` - Claude's own capture list: anything rough observed while
  working but not fixed in the moment.
- `IDEAS.md` - the user's own space for ideas, freely user-edited.
- `CHANGES.md` - a numbered log of key changes, with current status.

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
- **Investigate real-world risk before a big architecture change** when a
  cheap empirical check exists (a throwaway test against the actual target)
  rather than assuming from documentation - what's documented as the
  standard approach doesn't always work on the actual hardware/environment
  in front of you.

## Decision-making & communication

- **Ask when it's a genuine fork**: an architecture choice with real
  tradeoffs, an ambiguous requirement, or "should I proceed even though this
  might disrupt something live" - a structured question with real options
  beats guessing wrong and redoing work.
- **Don't ask when there's a reasonable default.** Make the call, state it,
  and let the user redirect. Over-asking is its own cost.
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
- No edits, no side-effecting commands, until the plan is explicitly
  confirmed.
- Ask clarifying questions freely - this is the mode where asking is
  cheap.
- Once the plan is confirmed, create a new feature branch before making
  any changes (name reflects the task, e.g. `feature/dark-mode-toggle`).
- Commit and push to that branch as work proceeds, tested increment by
  increment - same standing authorization as Mode 2, just gated on the
  plan being confirmed first. Merging to `main` stays gated regardless.
- Exit by presenting the final plan for confirmation, then move into
  Mode 2 to execute it.

### Mode 2 - Build (default)

Trigger: everyday tasks by default, or "let's just build this."

- Create/switch to a feature branch before the first edit, unless
  already on one suited to this task - never build directly on `main`.
- Make reasonable, reversible changes without asking step-by-step
  permission.
- Still ask on a genuine fork (architecture choice, ambiguous
  requirement).
- Still confirm before anything destructive/hard-to-reverse (force-push,
  `reset --hard`, deleting unmerged branches, etc.).
- Narrate briefly at key moments - findings, direction changes,
  blockers - not a play-by-play.
- Commit and push once a change is tested and working, per the Git &
  deployment workflow loop above - that section is itself the standing
  authorization, not something to ask about each time. Merging to
  `main` stays gated.

### Mode 3 - Away (autonomous)

Trigger: "I'll be away," "go do X while I'm out," scheduled/overnight
runs.

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
  option as its own branch (e.g. `away/dark-mode-css-vars` vs
  `away/dark-mode-context-api`), so the choice on return is a
  comparison, not a guess. Keep the number of parallel versions small
  (2-3, matching the option-count guidance from Mode 1) and only do
  this for forks actually worth the extra build time - not every minor
  naming choice.
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
