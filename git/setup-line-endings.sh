#!/usr/bin/env bash
# One-time machine setup: make git use LF for every repo on this machine.
# Safe to re-run. Run from Git Bash (Windows) or any POSIX shell.
#
#   core.autocrlf=false   git never guesses from the OS
#   core.eol=lf           text files are checked out as LF
#   core.attributesFile   global fallback rules (`* text=auto eol=lf`, CRLF for
#                         .bat/.cmd) for repos that have no .gitattributes yet
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

mkdir -p ~/.config/git
cp "$here/attributes" ~/.config/git/attributes
git config --global core.attributesFile "~/.config/git/attributes"
git config --global core.autocrlf false
git config --global core.eol lf

echo "Global git line-ending config:"
git config --global --get-regexp '^core\.(autocrlf|eol|attributesfile)$'
echo
echo "Editors: set VS Code \"files.eol\": \"\\n\" in user settings."
