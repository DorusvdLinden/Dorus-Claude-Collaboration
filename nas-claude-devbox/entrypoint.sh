#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" != "--as-coder" ]; then
    # Starts as root (see Dockerfile). Docker creates named volumes
    # (code-server-config, claude-config) owned by root:root the first
    # time they're used, and code-server/Claude Code both need to write
    # into them -- fix that once here, then drop to the coder user that
    # everything below actually expects to run as.
    chown -R coder:coder /home/coder/.local/share/code-server /home/coder/.claude
    exec su coder -c "HOME=/home/coder exec $0 --as-coder"
fi

# --- Everything below runs as coder, with HOME correctly set. ---

# code-server reads its password from this env var if set (see docker-compose.yml).
export PASSWORD="${CODE_SERVER_PASSWORD:-}"

# Remote Control (the Claude mobile app's Code tab) does NOT support API-key
# auth -- only an interactive Pro/Max login (`claude login`) works with it.
# An API key still works for a plain `claude` session, just not Remote Control.
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    echo "ANTHROPIC_API_KEY detected: plain 'claude' sessions will authenticate"
    echo "automatically, but Remote Control (mobile app) will NOT work with an"
    echo "API key -- it requires an interactive Pro/Max login. See README."
fi

# --spawn worktree gives every session started from the mobile app its own
# git worktree, so starting a new small project from your phone doesn't
# collide with whatever else is open. Falls back to same-dir if the project
# folder isn't a git repo yet (worktree mode requires one).
if [ -d /home/coder/project/.git ]; then
    SPAWN_MODE=worktree
else
    SPAWN_MODE=same-dir
    echo "NOTE: /home/coder/project is not a git repo -- Remote Control will run"
    echo "in same-dir mode. Run 'git init' there to get isolated per-session"
    echo "worktrees for each project you start from your phone."
fi

# Keep a Remote Control server running in a detached tmux session so the
# mobile app's Code tab can always reach it. This loop restarts it
# automatically whenever the container restarts. Until you've logged in,
# each attempt fails fast and the loop just retries every 5s -- log in
# via a SEPARATE terminal (see README section 6), not by attaching here;
# Ctrl-C in this pane kills the whole loop's shell, not one attempt.
# Login and workspace trust persist on the ~/.claude and project volumes,
# so this is only needed once, ever.
if ! tmux has-session -t claude 2>/dev/null; then
    tmux new-session -d -s claude -c "/home/coder/project" \
        "while true; do claude remote-control --spawn ${SPAWN_MODE} --name 'NAS Devbox'; sleep 5; done"
fi

echo "Starting code-server on :8080 ..."
exec code-server \
    --bind-addr 0.0.0.0:8080 \
    --user-data-dir /home/coder/.local/share/code-server \
    --extensions-dir /home/coder/.local/share/code-server/extensions \
    /home/coder/project
