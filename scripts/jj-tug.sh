#!/bin/bash
# jj-tug.sh — Fetch, rebase, seal (if needed), export, and push main.
set -e

echo "Fetching remote changes..."
jj git fetch --all-remotes

# Universal rebase: all work since main up to the current working copy
echo "Rebasing work onto main..."
# We use roots(main..@) to pick up everything between main and the current tip.
jj rebase -s "roots(main..@)" -d main

# Conditional Sealing: Run jj new only if there's actual work in the current working copy (@)
# This handles both trunk-only (jj commit) and workspace (jj ws-merge/sync).
IS_EMPTY=$(jj log -r @ -T 'empty' --no-pager --no-graph)

if [ "$IS_EMPTY" = "false" ]; then
  echo "Sealing uncommitted changes..."
  jj new
  echo "New empty working copy created at tip."
else
  echo "Working copy is already empty (pre-sealed)."
fi

# Move the bookmark to the 'sealed' work (@-)
# Whether we just ran 'jj new' or it was already empty, @- is the target.
echo "Moving 'main' bookmark to tip..."
jj bookmark move main --to @-

# Export to Git so local git log/tools are immediately accurate
echo "Exporting to Git..."
jj git export

# Push to origin
echo "Pushing 'main' to origin..."
jj git push --bookmark main