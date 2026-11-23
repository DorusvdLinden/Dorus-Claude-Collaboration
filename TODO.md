Personal playbook of how Claude works across projects: a short CLAUDE.md (copied to ~/.claude) plus on-demand guides, hooks and git line-ending setup.
Status: active; CLAUDE.md, four guides, two global hooks and git/ LF policy in place.
Latest: LF line endings machine-wide (git/); 24 repos renormalized and merged to main; CHANGES.md started.
Next: branches made before the sweep (e.g. RecipeManager todo/review-next) pick up LF when they merge main; README "What's here" refresh.
Updated: 2026-11-23

# TODO

- [x] Add CHANGES.md (numbered decisions) for this repo itself.
- [ ] README "What's here" does not list TODO.md / IDEAS.md yet.
- [x] Merge chore/normalize-line-endings in each repo (then pull, so CRLF working files get rewritten as LF).
- [ ] Third-party clones (TFT_eSPI, weather-icons, hakuneko - Copy) and the pi-weather-display clone were left out of the line-ending sweep.
