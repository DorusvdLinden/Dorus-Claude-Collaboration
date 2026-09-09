// PreToolUse hook: auto-stage IDEAS.md before every git commit, per CLAUDE.md's
// "IDEAS.md is the user's own space" rule - manual edits made outside a Claude
// session should still make it into the next commit without being asked.
// No-op in repos without an IDEAS.md, or where it has no pending changes.
let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  let data;
  try {
    data = JSON.parse(input);
  } catch {
    return;
  }

  const command = (data.tool_input && data.tool_input.command) || "";
  const isGitCommit = /(^|[;&|]\s*)git\s+commit(\s|$)/.test(command.trim());
  if (!isGitCommit) return;

  const { execSync } = require("child_process");
  let root;
  try {
    root = execSync("git rev-parse --show-toplevel", {
      stdio: ["ignore", "pipe", "ignore"],
    })
      .toString()
      .trim();
  } catch {
    return; // not a git repo
  }

  const path = require("path");
  const fs = require("fs");
  const ideasPath = path.join(root, "IDEAS.md");
  if (!fs.existsSync(ideasPath)) return;

  let status;
  try {
    status = execSync(`git status --porcelain -- "${ideasPath}"`, {
      cwd: root,
      stdio: ["ignore", "pipe", "ignore"],
    })
      .toString()
      .trim();
  } catch {
    return;
  }

  if (status) {
    try {
      execSync(`git add "${ideasPath}"`, { cwd: root, stdio: "ignore" });
    } catch {
      // best-effort; never block the commit over this
    }
  }
});
