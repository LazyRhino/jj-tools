#!/bin/bash
# jj-sync.sh — Run this whenever you jump into your main workspace
# Usage: jj-sync.sh

set -e

echo "Updating workspace state..."
jj workspace update-stale

# Check if the current commit is empty. If not, create a new empty commit on top.
# This 'seals' any squashed work from other workspaces into the history.
IS_EMPTY=$(jj log -r @ -T 'empty' --no-pager --no-graph)

if [ "$IS_EMPTY" = "false" ]; then
  echo "Sealing squashed changes into history..."
  jj new
  echo "New empty working copy created at tip."
else
  echo "Working copy is already empty."
fi

echo "-------------------------------------------------------"
echo "Workspace is synced and clean."
jj log --limit 5 --no-pager
