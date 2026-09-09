// PreToolUse hook: enforce "branch before editing" from CLAUDE.md.
// Denies Edit/Write/NotebookEdit outright, and denies Bash only when the
// command is actually a git commit — checked here (not just via the
// settings.json "if" filter) so an unrelated Bash call is never caught by
// this hook regardless of how loosely "if" prefix-matches.
//
// Exception: Mode 1 planning artifacts (SPEC.md, plans/<task-name>.md) are
// explicitly allowed to be written before a branch exists — CLAUDE.md says
// "writing planning artifacts themselves ... doesn't count against" the
// no-edits-until-confirmed rule, and the branch itself is only created once
// the plan is confirmed. So those specific paths are exempt from this guard.
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

  const normalizedPath = filePath.replace(/\\/g, "/");
  const isPlanningArtifact =
    isEditLike &&
    (/\/SPEC\.md$/.test(normalizedPath) ||
      normalizedPath === "SPEC.md" ||
      /\/plans\/[^/]+\.md$/.test(normalizedPath));

  if (isPlanningArtifact) return;

  const { execSync } = require("child_process");
  let branch;
  try {
    branch = execSync("git rev-parse --abbrev-ref HEAD", {
      stdio: ["ignore", "pipe", "ignore"],
    })
      .toString()
      .trim();
  } catch {
    return; // not a git repo
  }

  if (branch === "main" || branch === "master") {
    const action = isGitCommit ? "committing" : "editing";
    console.log(
      JSON.stringify({
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: `Blocked: current branch is ${branch}. Create a feature branch first (git checkout -b feature/<task-name>) before ${action}, per CLAUDE.md standing workflow rule.`,
        },
      })
    );
  }
});
