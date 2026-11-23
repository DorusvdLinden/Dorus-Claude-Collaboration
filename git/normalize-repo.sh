#!/usr/bin/env bash
# Normalize one repo to LF, once, without touching its checkout.
#
#   git/normalize-repo.sh <path-to-repo> [--push]
#
# In a temporary worktree based on origin/<default branch>, on a new branch
# chore/normalize-line-endings: adds or upgrades .gitattributes (git/attributes
# policy), runs `git add --renormalize .`, commits. --push pushes the branch.
# Merging stays a separate, explicit step.
#
# Then, if the user's own checkout is clean, rewrites files that are stored
# as LF but sit on disk as CRLF (silences "CRLF will be replaced by LF"
# warnings). Contents are identical apart from line endings.
set -euo pipefail
repo=$(cd "$1" && pwd); push=${2:-}
policy="$(cd "$(dirname "$0")" && pwd)/attributes"
branch=chore/normalize-line-endings
name=$(basename "$repo")
wt="${WT_ROOT:-${TMPDIR:-/tmp}}/eol-wt/${name// /_}"

cd "$repo"
default=$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's#^origin/##')
git fetch -q origin "$default"
if git rev-parse -q --verify "refs/heads/$branch" >/dev/null; then
  echo "$name: branch $branch already exists - skipped"; exit 0
fi

rm -rf "$wt"
git worktree add -q -b "$branch" "$wt" "origin/$default"
trap 'git -C "$repo" worktree remove --force "$wt" 2>/dev/null || true' EXIT
cd "$wt"

if [ -f .gitattributes ]; then
  # Upgrade a bare "* text=auto" (GitHub's default) to pin LF.
  sed -i 's/^\* text=auto[[:space:]]*$/* text=auto eol=lf/' .gitattributes
  # No catch-all text rule at all: prepend ours (first, so specific rules win).
  if ! grep -q '^\*[[:space:]]\+text' .gitattributes; then
    { printf '# Line endings: LF everywhere (Dorus-Claude-Collaboration/git/attributes)\n* text=auto eol=lf\n\n'; cat .gitattributes; } > .gitattributes.new
    mv .gitattributes.new .gitattributes
  fi
  for ext in bat cmd; do
    grep -q "^\*\.$ext[[:space:]]" .gitattributes ||
      printf '*.%s text eol=crlf\n' "$ext" >> .gitattributes
  done
else
  cp "$policy" .gitattributes
fi

git add --renormalize .
git add .gitattributes
changed=$(git diff --cached --name-only | wc -l)
if [ "$changed" -eq 0 ]; then
  echo "$name: already normalized - nothing to commit"
  cd "$repo"; git worktree remove --force "$wt"; git branch -q -D "$branch"
else
  git commit -q -F - <<'MSG'
Normalize line endings to LF via .gitattributes

Mixed CRLF/LF in the repo caused phantom whole-file diffs and
"CRLF will be replaced by LF" warnings on every commit from Windows.
.gitattributes now pins LF for text (CRLF only for .bat/.cmd), so every
clone - Windows, Pi, NAS - behaves the same. Content is unchanged apart
from line endings (`git diff --ignore-cr-at-eol` / `-w` shows nothing).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
MSG
  echo "$name: committed $changed file(s) on $branch"
  [ "$push" = "--push" ] && git push -q -u origin "$branch" && echo "$name: pushed"
fi

# Refresh the user's own checkout (only when clean).
cd "$repo"
if [ -z "$(git status --porcelain)" ]; then
  list=$(git -c core.quotePath=false ls-files --eol |
         awk -F'\t' '$1 ~ /^i\/lf +w\/crlf +attr\/.*eol=lf/ {print $2}')
  n=0
  if [ -n "$list" ]; then
    # checkout-index skips files git considers up to date (same content modulo
    # EOL), even with -f, so remove them first; the clean status check above
    # guarantees the index holds the same content.
    printf '%s\n' "$list" | while IFS= read -r f; do rm -f -- "$f"; done
    printf '%s\n' "$list" | git checkout-index -u --stdin
    n=$(printf '%s\n' "$list" | wc -l)
  fi
  echo "$name: rewrote $n CRLF working file(s) as LF"
else
  echo "$name: checkout has local changes - working files left as they are"
fi
