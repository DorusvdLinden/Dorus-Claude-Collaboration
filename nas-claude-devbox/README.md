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

**Optional — HTTPS instead of a raw IP:port:** run `tailscale serve https / http://localhost:8080`
inside the `tailscale` container for a proper HTTPS URL on your tailnet.

---

## 6. First-time Claude Code login

Open a terminal inside code-server (`` Terminal > New Terminal ``) and run:

```bash
claude
```

- If `ANTHROPIC_API_KEY` was set in `.env`, it authenticates automatically.
- Otherwise, follow the printed login URL to authenticate with your Pro/Max
  account. Credentials are written to `~/.claude`, which is a persistent
  Docker volume — you won't need to log in again after a container restart.

---

## 7. Connect the Claude mobile app (Remote Control)

This is what lets you pick up the same running Claude Code session from
your phone, not just from the browser IDE.

1. In the terminal session where `claude` is running, enable it for this
   session or for all future ones:

   ```
   /config
   ```

   Toggle **"Enable Remote Control for all sessions"** to `true` (or use
   the one-off convert-this-session command if you'd rather opt in per
   session).

2. Claude Code prints a session URL and can show a QR code (press
   spacebar).

3. On your phone: open the **Claude app → Code tab**, find the session
   (it shows a computer icon with a green dot when online), or scan the QR
   code the first time.

4. Chat with it from your phone. Execution still happens entirely on the
   NAS container — your mounted project files, `~/.claude` config, and any
   MCP servers stay right where they are. The phone is just a window into
   that session.

**Keeping the session alive:** the entrypoint script pre-creates a detached
`tmux` session named `claude`. Run `claude` inside it so a dropped browser
tab or SSH connection doesn't kill the process:

```bash
tmux attach -t claude
claude
# ... work, then detach without stopping it:
# Ctrl-b, then d
```

Note this survives *disconnects*, not a container restart — if the
`devbox` container restarts, you'll need to re-attach and run `claude`
again (conversation history is preserved as long as you're in the same
project directory, since `~/.claude` is a persistent volume).

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
