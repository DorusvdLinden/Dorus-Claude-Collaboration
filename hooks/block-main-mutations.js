// PreToolUse hook: enforce "branch before editing" from CLAUDE.md.
// Denies Edit/Write/NotebookEdit outright, and denies Bash only when the
// command is actually a git commit — checked here (not just via the
// settings.json "if" filter) so an unrelated Bash call is never caught by
// this hook regardless of how loosely "if" prefix-matches.
//
// Which repo's branch is checked: for Edit/Write/NotebookEdit, the repo that
// contains the target file, not the session's working directory. So a file
// outside any git repo (e.g. Claude Code's own memory folder under
// ~/.claude/projects/) is never blocked just because the session's repo
// happens to be on main, and a file in a second repo is judged by that
// repo's branch. For git commit, it's still the session's working directory.
//
// Exception: Mode 1 planning artifacts (SPEC.md, plans/<task-name>.md) are
// explicitly allowed to be written before a branch exists — CLAUDE.md says
// "writing planning artifacts themselves ... doesn't count against" the
// no-edits-until-confirmed rule, and the branch itself is only created once
// the plan is confirmed. So those specific paths are exempt from this guard.
const path = require("path");
const fs = require("fs");

let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  let data;
  try {
    data = JSON.parse(input);
  } catch {
    return;
  }

  const toolName = data.tool_name || "";
  const command = (data.tool_input && data.tool_input.command) || "";
  const filePath = (data.tool_input && (data.tool_input.file_path || data.tool_input.notebook_path)) || "";

  const isEditLike = toolName === "Edit" || toolName === "Write" || toolName === "NotebookEdit";
  const isGitCommit = toolName === "Bash" && /(^|[;&|]\s*)git\s+commit(\s|$)/.test(command.trim());

  if (!isEditLike && !isGitCommit) return;

  const normalizedPath = filePath.split(String.fromCharCode(92)).join("/");
  const isPlanningArtifact =
    isEditLike &&
    (/\/SPEC\.md$/.test(normalizedPath) ||
      normalizedPath === "SPEC.md" ||
      /\/plans\/[^/]+\.md$/.test(normalizedPath));

  if (isPlanningArtifact) return;

  const sessionDir = data.cwd || process.cwd();
  let gitDir = sessionDir;
  if (isEditLike && filePath) {
    gitDir = path.dirname(path.resolve(sessionDir, filePath));
    // Write can create new folders - start from the nearest one that exists.
    while (!fs.existsSync(gitDir) && path.dirname(gitDir) !== gitDir) {
      gitDir = path.dirname(gitDir);
    }
  }

  const { execSync } = require("child_process");
  let repoRoot, branch;
  try {
    [repoRoot, branch] = execSync("git rev-parse --show-toplevel --abbrev-ref HEAD", {
      cwd: gitDir,
      stdio: ["ignore", "pipe", "ignore"],
    })
      .toString()
      .trim()
      .split(/\r?\n/);
  } catch {
    return; // not in a git repo
  }

  if (branch === "main" || branch === "master") {
    const action = isGitCommit ? "committing" : "editing";
    console.log(
      JSON.stringify({
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: `Blocked: ${repoRoot} is on branch ${branch}. Create a feature branch first (git checkout -b feature/<task-name>) before ${action}, per CLAUDE.md standing workflow rule.`,
        },
      })
    );
  }
});
