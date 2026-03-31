#!/bin/bash
# jj-git-main.sh — Move a jj bookmark to match git HEAD (colocated repos).
#
# Unlike jj-tug.sh (fetch, rebase onto main, move main to sealed work, push to
# origin/main), this only does: jj bookmark <name> = git HEAD.
#
# Use when you made commits with `git` and jj's bookmark (usually `main`) still
# points at an older revision — `jj log main` then disagrees with `git log`.
# `jj tug` tracks origin/main; it does not fix a detached or ahead git HEAD
# that has not been pushed or that jj never advanced to.
set -euo pipefail

BOOKMARK="${1:-main}"

if ! jj root >/dev/null 2>&1; then
  echo "jj-git-main: not inside a jj repository (run from a colocated clone)" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "jj-git-main: not inside a git working tree" >&2
  exit 1
fi

HEAD="$(git rev-parse HEAD)"
echo "jj-git-main: moving bookmark '${BOOKMARK}' to git HEAD ${HEAD}"
jj bookmark set "${BOOKMARK}" -r "${HEAD}"
