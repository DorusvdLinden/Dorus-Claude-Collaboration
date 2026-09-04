# NAS Claude Code Devbox

A persistent, browser-accessible dev environment hosted on your NAS:
**code-server** (VS Code in the browser) + **Claude Code** (CLI agent),
reachable securely over **Tailscale**, with a bridge to the **Claude mobile
app** via Remote Control.

```
Phone/laptop ──(tailnet)──> code-server :8080 ──> container terminal ──> claude
                                                          │
Claude mobile app ──(Remote Control relay)────────────────┘
```

---

## 1. Prerequisites

- A NAS with Docker / Container Manager / Container Station support
  (Synology, QNAP, TrueNAS Scale, UGREEN, Unraid, etc.)
- Docker Compose available on the NAS (bundled with most of the above)
- A [Tailscale](https://tailscale.com) account (free tier is fine)
- A Claude subscription (Pro/Max) or an Anthropic Console API key, for
  Claude Code authentication

---

## 2. File layout

```
nas-claude-devbox/
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── .env.example
└── README.md   (this file)
```

Copy this folder onto the NAS (e.g. `/volume1/docker/nas-claude-devbox`).

---

## 3. Configure

```bash
cd nas-claude-devbox
cp .env.example .env
```

Edit `.env`:

- `CODE_SERVER_PASSWORD` — pick a strong password for the browser IDE login.
- `TS_AUTHKEY` — generate one at
  https://login.tailscale.com/admin/settings/keys (an ephemeral/reusable key
  is fine for a home box).
- `PROJECTS_PATH` — absolute NAS path to bind-mount as your workspace, e.g.
  `/volume1/projects`.
- `ANTHROPIC_API_KEY` — optional; leave blank if you'd rather log in
  interactively with your Pro/Max account instead.
- `CODER_UID` / `CODER_GID` — set these to match the NAS user that owns
  `PROJECTS_PATH` (`id <nas-username>` over SSH), or the container's
  `coder` user (UID/GID 1000 by default) won't be able to write to your
  mounted project folder.
- For `TS_AUTHKEY`, use a **reusable** key, not ephemeral — an ephemeral
  key drops the node from your tailnet on every container restart.

---

## 4. Build and start

```bash
docker compose up -d --build
```

This starts two containers:

- `tailscale` — joins your tailnet as `nas-devbox`
- `devbox` — code-server + Claude Code, networked *through* the tailscale
  container, so it is **not** exposed to your LAN or the internet directly

Check it joined the tailnet:

```bash
docker compose logs tailscale | grep -i "generated\|success"
```

You'll see the tailnet IP for `nas-devbox` in your
[Tailscale admin console](https://login.tailscale.com/admin/machines).

---

## 5. Open the IDE

From any device on your tailnet:

```
http://<nas-devbox-tailscale-ip>:8080
```

Enter the `CODE_SERVER_PASSWORD` you set. You now have full VS Code in the
browser, rooted at `/home/coder/project` (your NAS `PROJECTS_PATH`).

> **This deployment:** `http://100.93.245.82:8080` — password is in `.env`
> on the NAS (`/volume1/docker/nas-claude-devbox/.env`), not written here
> since this file is version-controlled. The tailnet IP is stable but can
> be re-checked with `tailscale ip -4` inside the `tailscale` container if
> it ever changes.

**Optional — HTTPS instead of a raw IP:port:** run `tailscale serve https / http://localhost:8080`
inside the `tailscale` container for a proper HTTPS URL on your tailnet.

---

## 6. First-time Claude Code login (one-time manual step)

The entrypoint auto-starts a Remote Control server in a detached `tmux`
session, but the very first run still needs one manual, interactive step:
logging in and accepting the workspace-trust prompt. Both are interactive
by design and can't be scripted around.

**Important:** Remote Control (the mobile app's Code tab, section 7) does
**not** support `ANTHROPIC_API_KEY` auth — only an interactive Pro/Max
login works with it. If you want to use the mobile app, leave
`ANTHROPIC_API_KEY` blank in `.env` and log in interactively as below.

**Don't attach to the `claude` tmux session for this** — it's running a
restart loop (`while true; do claude remote-control ...; sleep 5; done`),
and Ctrl-C there kills the whole loop's shell, not just one attempt (tmux
delivers Ctrl-C to the entire pane's process group). Since you're not
logged in yet, `claude remote-control` just exits immediately with an
error and the loop harmlessly retries every 5 seconds in the background —
leave it alone.

Instead, open a **separate** terminal inside code-server (`` Terminal >
New Terminal ``, not the tmux pane) and log in there:

```bash
cd /home/coder/project
claude          # follow the printed URL to log in with your Pro/Max account
```

Accept the workspace-trust prompt when it appears, confirm you're logged
in, then exit (Ctrl-D or `/exit`). Credentials are written to `~/.claude`,
a persistent Docker volume. Within a few seconds the restart loop's next
retry picks up the new login automatically and starts serving Remote
Control for real — you won't need to log in again after a container
restart.

---

## 7. Connect the Claude mobile app (Remote Control)

This is what lets you pick up the same running Claude Code session from
your phone, not just from the browser IDE — and, per the goal this is
built for, start new small projects from your phone with no browser IDE
open at all.

1. On your phone: open the **Claude app → Code tab**. The session appears
   as **"NAS Devbox"** with a computer icon and a green dot once it's
   online (a minute or so after the container starts, once you've
   completed the one-time login in section 6).
2. Tap it to open a chat window into that session. Ask it to scaffold a
   new project, write code, run commands — it executes entirely on the
   NAS container, with full access to your mounted project files,
   `~/.claude` config, and any MCP servers.
3. If `/home/coder/project` (your `PROJECTS_PATH`) is a git repository,
   the entrypoint runs Remote Control in `--spawn worktree` mode: **every
   new session you start from the phone gets its own isolated git
   worktree**, so starting a second small project doesn't collide with
   whatever the first one is doing. If it isn't a git repo yet, it falls
   back to sharing one directory across sessions. Worktree-mode detection
   only runs once at container start, so if you `git init` in
   `PROJECTS_PATH` to switch modes, restart the container afterwards
   (`docker compose restart devbox`) for it to take effect.

**Keeping the session alive:** the entrypoint's `tmux` session named
`claude` runs `claude remote-control` in a restart loop, so it survives a
dropped browser tab, a disconnected phone, or the container itself
restarting — no manual re-attach needed after the one-time login in
section 6. To check on it directly, `tmux attach -t claude` any time (this
does not interrupt the running Remote Control server; just detach again
with `Ctrl-b` then `d`).

---

## 8. Day-to-day use

- **From a laptop/browser:** open code-server, edit files, use its
  integrated terminal for `claude` as normal.
- **From your phone, no laptop open:** use the Claude app's Code tab to
  check on or nudge a long-running task via Remote Control.
- **Both at once:** they're views into the same session — messages sent
  from your phone and the terminal interleave in the same conversation.

---

## 9. Maintenance

- **Troubleshooting Remote Control connectivity:** the restart loop's
  output (login errors, crash-loop failures) only appears inside the
  `claude` tmux pane, not in `docker compose logs`. From the NAS host:
  `docker exec -it nas-claude-devbox tmux attach -t claude` (detach with
  `Ctrl-b` then `d` — don't Ctrl-C, see section 6).
- **Updating Claude Code:** `claude update` inside the container (or it
  updates itself in the background, depending on install channel).
- **Updating code-server:** rebuild the image —
  `docker compose up -d --build`.
- **Backups:** the only state that matters is the `claude-config` and
  `code-server-config` named volumes, plus your `PROJECTS_PATH` on the
  NAS. Back up NAS volumes as you normally would; Docker named volumes
  live under the NAS's Docker data directory.
- **Resource limits:** `mem_limit` / `cpus` in `docker-compose.yml` keep
  this from starving other NAS services (Plex, backups, etc.) — tune to
  your NAS's actual specs.

---

## 10. Security notes

- The devbox is only reachable over your tailnet — nothing is published
  to the LAN or internet in this compose file.
- `CODE_SERVER_PASSWORD` and `TS_AUTHKEY` live in `.env`, which is
  intentionally excluded from anything you'd commit to git — add it to
  `.gitignore` if this folder ever becomes a repo.
- Claude Code has full filesystem access *within the container*, scoped
  to `/home/coder` and whatever you mount under `/home/coder/project` —
  it cannot see the rest of the NAS unless you explicitly mount more.
