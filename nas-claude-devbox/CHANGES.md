# Changes

Numbered log of key decisions for the NAS Claude Code devbox, with status.

## 1. Initial plan: code-server + Claude Code + Tailscale sidecar (active)

Drafted in a prior Claude.ai chat, reviewed and brought into this repo.
Architecture: a Docker container running code-server and the Claude Code
CLI, networked through a Tailscale sidecar (`network_mode:
service:tailscale`) so nothing is exposed to the LAN or internet directly.
Validated against web research as the standard, documented pattern for
this kind of setup.

## 2. Fixed UID/GID and Tailscale key gaps (active)

- Wired `CODER_UID`/`CODER_GID` through `docker-compose.yml` build args so
  the container's `coder` user can match the NAS user that owns
  `PROJECTS_PATH` — otherwise write access to the bind-mounted project
  folder can silently fail depending on the NAS's UID scheme.
- Documented that the Tailscale auth key must be reusable, not ephemeral —
  an ephemeral key drops the node from the tailnet on every container
  restart.

## 3. Fixed API-key/Remote-Control conflict, switched to server mode (active)

Web research turned up that Claude Code's Remote Control feature (what the
mobile app's Code tab connects to) does not support API-key auth at all —
only an interactive Pro/Max login. The original `.env.example` presented
`ANTHROPIC_API_KEY` as an equally valid alternative, which would have
silently broken the actual goal (using the mobile app to start projects
remotely) if set.

- `.env.example` and `README.md` now call this out explicitly.
- `entrypoint.sh` now auto-starts `claude remote-control` (server mode,
  `--spawn worktree` when the project folder is a git repo) inside the
  supervised `tmux` session, instead of a bare interactive `claude`. A
  session is now always reachable from the mobile app without a manual
  re-attach after every container restart, and each new project started
  from the phone gets its own isolated git worktree.
- Superseded: the earlier "attach to tmux and run `claude` manually, then
  `/config` to enable Remote Control" flow from decision 1.

A fresh-context subagent review of this diff caught that the first draft
of the login instructions told you to Ctrl-C inside the restart-loop tmux
pane — which actually kills the whole loop (Ctrl-C hits the pane's entire
process group, including the enclosing `while` shell), not just one
attempt. Fixed: login now happens in a separate code-server terminal
while the loop harmlessly retries in the background. Same review flagged
that switching `--spawn` mode (by running `git init` in `PROJECTS_PATH`)
needs a container restart to take effect, since the mode is detected once
at container start — documented in README section 7.
