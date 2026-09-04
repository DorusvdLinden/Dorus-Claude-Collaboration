#!/usr/bin/env bash
set -euo pipefail

# code-server reads its password from this env var if set (see docker-compose.yml).
export PASSWORD="${CODE_SERVER_PASSWORD:-}"

# If an API key was supplied via the environment, Claude Code will pick it up
# automatically — no need to run `claude login` interactively in that case.
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
    echo "ANTHROPIC_API_KEY detected: Claude Code will authenticate automatically."
fi

# Pre-create a detached tmux session named "claude" so that:
#   1. Starting `claude` inside it lets you attach/detach without killing the process.
#   2. It survives the code-server browser tab or SSH connection dropping.
# It does NOT survive a container restart — see README for making this durable.
if ! tmux has-session -t claude 2>/dev/null; then
    tmux new-session -d -s claude -c "/home/coder/project" || true
fi

echo "Starting code-server on :8080 ..."
exec code-server \
    --bind-addr 0.0.0.0:8080 \
    --user-data-dir /home/coder/.local/share/code-server \
    --extensions-dir /home/coder/.local/share/code-server/extensions \
    /home/coder/project
