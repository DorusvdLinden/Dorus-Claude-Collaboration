# NAS Claude Code Devbox

Project-specific detail for this subproject. See the repo root
[CLAUDE.md](../CLAUDE.md) for the portable process this follows.

## Specifics

- Deploy target: fill in the NAS model and path once actually deployed
  (e.g. `/volume1/docker/nas-claude-devbox` on Synology).
- Deploy command: `docker compose up -d --build` from this folder on the
  NAS.
- Auth: Remote Control (the mobile app's Code tab) requires an
  interactive Pro/Max login via `claude login` — API keys are not
  supported by Remote Control. See `.env.example`.
- First boot requires one manual `tmux attach -t claude` inside the
  container to log in and accept the workspace-trust prompt; after that,
  the entrypoint's restart loop keeps a Remote Control session live
  automatically across container restarts.
- Once actually running on the NAS, add it to `nas-dashboard`
  (http://192.168.1.2:8093/) per the root `CLAUDE.md`'s standing rule.
