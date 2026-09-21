#!/bin/bash
# hooks.sh — repo-local hook support for jj-tools.
#
# jj deliberately does not run git hooks, so git-hook managers (husky,
# pre-commit, lefthook) never fire on a jj workflow — their hooks sit installed
# and silent. This gives repos an opt-in equivalent for the only jj operations
# that reach a remote: `jj tug` and `jj pr push`.
#
# A repo opts in by adding an executable .jj-hooks/pre-push at its root.

# Runs <repo root>/.jj-hooks/pre-push, if present and executable, with the repo
# root as cwd. A non-zero exit aborts before anything is pushed.
# Set JJ_SKIP_HOOKS=1 to bypass.
run_pre_push_hook() {
  local root hook
  root="$(jj root 2>/dev/null)" || return 0
  hook="$root/.jj-hooks/pre-push"

  [ -x "$hook" ] || return 0

  if [ -n "$JJ_SKIP_HOOKS" ]; then
    echo "Skipping .jj-hooks/pre-push (JJ_SKIP_HOOKS is set)."
    return 0
  fi

  echo "Running .jj-hooks/pre-push..."
  if ! (cd "$root" && "$hook"); then
    echo ""
    echo "-------------------------------------------------------"
    echo "pre-push hook failed — nothing was pushed to origin."
    echo "Local rebase/bookmark changes already applied; fix, then re-run."
    echo "To bypass: JJ_SKIP_HOOKS=1 jj <command>"
    exit 1
  fi
  echo "pre-push hook passed."
}
