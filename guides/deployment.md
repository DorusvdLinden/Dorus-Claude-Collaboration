# Deployment, Docker/NAS and live systems

Read when deploying to a real target (NAS, Docker, server, device), when a
long-running process is involved, or when editing remote files that hold
secrets. Moved verbatim from `~/.claude/CLAUDE.md` on 2026-11-11.

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
- **Container entrypoints that drop root privileges have sharp,
  repeatable edges** - worth checking for on every new Docker deploy, not
  just the one that first surfaced them:
  - `su`/privilege-drop resets `PATH` to a bare system default, silently
    breaking resolution of anything installed to a user-local path (e.g.
    `~/.local/bin`) - a supervised loop just sees "command not found" on
    every attempt, with no error at the call site. Set `PATH` (and `HOME`)
    explicitly in the `su` invocation rather than assuming it carries over.
  - Docker named volumes are created `root:root` on first mount even when
    the container's default user is non-root - start the entrypoint as
    root, `chown` the mount points once, then drop privileges, rather than
    running as the non-root user from the start and hitting an opaque
    `EACCES` the first time only.
  - A container user's GID can collide with a group the base image already
    reserves (e.g. `100`/`users`) - the OS silently reuses that existing
    group instead of creating one named after your user, so a
    `chown user:user` that assumes the names match fails with "invalid
    group." Scope `chown` to the owner alone when only user-level write
    access is actually needed.
  - Don't assume a volume/bind-mount covers "all persistent state" for a
    tool without checking where it actually writes - first-run/onboarding
    flags can land outside the directory you assumed was the persistence
    boundary. For an unattended/headless process this is worse than
    cosmetic: a missed one-time prompt hangs the process forever with
    nobody there to answer it.
- **Be explicit about real risk before a disruptive action** on live
  infrastructure (a reachable device, a running service) - name what could
  go wrong, not just that you're proceeding. If repeated attempts at the
  same risky action fail, stop and report rather than continuing to
  disrupt blindly.
