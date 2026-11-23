# CHANGES

Numbered decisions for this repo. Status: active / superseded / rejected.

## 1. LF line endings everywhere, enforced by git config + .gitattributes (active)

2026-11-23. Line endings kept costing time on commits in every repo: some
repos stored CRLF or mixed files, others had GitHub's bare `* text=auto`
(LF in git, CRLF on disk on Windows), and editors/Claude wrote a mix.

Decision: LF for all text, CRLF only for `.bat`/`.cmd`.
- Machine: `core.autocrlf=false`, `core.eol=lf`, global attributes file
  `~/.config/git/attributes` (copy of `git/attributes`) as fallback for
  repos without their own rules; VS Code `files.eol` = `\n`.
- Each repo: `.gitattributes` from `git/attributes`, so other clones (Pi,
  NAS, GitHub) behave the same without the machine config.
- Existing repos: one renormalize commit each via `git/normalize-repo.sh`,
  on branch `chore/normalize-line-endings`, merged when asked.

Rejected: `core.autocrlf=true` (OS-dependent, still leaves CRLF in repos
that already have it, breaks shell scripts deployed to Linux) and silencing
the warnings with `core.safecrlf=false` (hides the symptom only).
