# Getting Started

A walkthrough for the very first setup, start to finish: from nothing
running, to chatting with Claude Code from your phone's Code tab. For
reference detail on any step, see `README.md` in this same folder.

## What you'll need before you start

- SSH (or your NAS's terminal app) access to the NAS
- Docker / Container Manager / Container Station installed and running
- A free [Tailscale](https://tailscale.com) account
- A Claude Pro or Max subscription (Remote Control needs an interactive
  login — an API key will not work for the phone app, see step 4)

## 1. Get the files onto the NAS

From this repo, copy the whole `nas-claude-devbox/` folder onto the NAS,
e.g. to `/volume1/docker/nas-claude-devbox`. Any way you'd normally move
files there works (`scp`, File Station, a git clone if the NAS has git).

## 2. Configure

SSH into the NAS and run:

```bash
cd /volume1/docker/nas-claude-devbox
cp .env.example .env
nano .env      # or vi, or edit it from File Station
```

Fill in:

- `CODE_SERVER_PASSWORD` — pick a real password.
- `TS_AUTHKEY` — from https://login.tailscale.com/admin/settings/keys.
  **Use a reusable key**, not ephemeral, or the container drops off your
  tailnet every restart.
- `PROJECTS_PATH` — where your project files live on the NAS, e.g.
  `/volume1/projects`.
- `CODER_UID` / `CODER_GID` — run `id <your-nas-username>` and use those
  numbers, so the container can actually write to `PROJECTS_PATH`.
- Leave `ANTHROPIC_API_KEY` **blank** — see step 4 for why.

## 3. Build and start it

```bash
docker compose up -d --build
```

Give it a minute. Check it joined your tailnet:

```bash
docker compose logs tailscale | grep -i "generated\|success"
```

You'll see `nas-devbox` show up at
https://login.tailscale.com/admin/machines with a tailnet IP.

## 4. Log in (one-time, do this once ever)

This is the only step that needs a keyboard rather than your phone.

Open `http://<nas-devbox-tailscale-ip>:8080` in a browser on any device on
your tailnet, enter your `CODE_SERVER_PASSWORD`, then open a terminal
inside it (`Terminal > New Terminal`) and run:

```bash
cd /home/coder/project
claude
```

Follow the printed link to log in with your Pro/Max account, accept the
workspace-trust prompt, then exit (`Ctrl-D`). That's it — credentials are
saved permanently. Within a few seconds, a background process picks up
the login automatically and starts serving Remote Control.

## 5. Open the Claude app on your phone

1. Tap **Code** in the app's navigation.
2. Look for a session called **"NAS Devbox"** with a green dot — it may
   take a minute after step 4 to appear online.
3. Tap it. You're now chatting directly with Claude Code running on your
   NAS, with full access to your project files.

Try it: *"create a new folder called hello-world with a simple Python
script that prints today's date, then run it."* Watch it work, entirely
on your NAS, entirely from your phone.

## 6. Day to day

- **From your phone:** Claude app → Code tab → tap the session. Good for
  starting a small project, checking progress, or nudging a long task.
- **From a laptop:** open `http://<tailscale-ip>:8080` in a browser for
  the full VS Code experience over the same files.
- Starting a *new* project from your phone gets its own isolated copy of
  the code automatically (as long as `PROJECTS_PATH` is a git repo — run
  `git init` there once if it isn't yet, then restart the container).

## If something's not working

See `README.md` section 9 (Maintenance) for how to check the background
process's logs directly on the NAS, and `TODO.md` for known rough edges.
