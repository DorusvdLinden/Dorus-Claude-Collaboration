// PostToolUse hook: remind to re-sync ~/.claude/CLAUDE.md after this repo's
// root CLAUDE.md changes, per "This repo's own maintenance" in CLAUDE.md.
let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  let filePath = "";
  try {
    const data = JSON.parse(input);
    filePath = (data.tool_input && data.tool_input.file_path) ||
      (data.tool_response && data.tool_response.filePath) || "";
  } catch {
    return;
  }
  const normalized = filePath.replace(/\\/g, "/");
  if (normalized.endsWith("Dorus-Claude-Collaboration/CLAUDE.md")) {
    console.log(JSON.stringify({
      systemMessage: "CLAUDE.md changed here — copy it to ~/.claude/CLAUDE.md to keep the global default in sync?",
    }));
  }
});
