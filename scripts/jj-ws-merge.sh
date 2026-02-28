#!/bin/bash
# jj-ws-merge.sh — Merge current workspace changes into the default workspace
# Usage: jj-ws-merge.sh ["commit message"]
#
# Flow:
#   1. Optionally describe the current working-copy commit
#   2. Squash it into default@
#   3. jj new default@  — creates a fresh working copy at the tip (no dangling empty commit)

set -e

# Detect workspace name from the current directory name
# (JJ names workspaces after their directory by default)
WS_NAME=$(basename "$(pwd)")

# Verify this is actually a known workspace
if ! jj workspace list --no-pager 2>/dev/null | grep -q "^${WS_NAME}:"; then
  echo "Error: '${WS_NAME}' is not a workspace in this repo."
  echo "Known workspaces:"
  jj workspace list --no-pager
  exit 1
fi

echo "Workspace: ${WS_NAME}"

# Optional: describe the commit before squashing
if [ -n "$1" ]; then
  echo "Describing: $1"
  jj describe -m "$1"
fi

# Squash workspace content into default@
# This puts the code into the 'default' working copy
echo "Squashing ${WS_NAME}@ → default@..."
jj squash --from "${WS_NAME}@" --into "default@" --use-description-from "${WS_NAME}@"

# Handle colocation sync - ensure Git index in main repo is current
echo "Exporting to Git..."
jj git export

# Create a fresh, empty working copy for this workspace at the new tip of default.
# This prevents dangling commits and keeps the feature workspace clean for next use.
echo "Repointing workspace to default@..."
jj new "default@"

echo "-------------------------------------------------------"
echo "Merge complete! To finish in the main workspace:"
echo "1. cd ../yoloaday"
echo "2. jj workspace update-stale"
echo "3. jj new           # <--- This 'seals' the work into the history"
echo "4. jj tug           # <--- Now tug works perfectly"
echo "-------------------------------------------------------"

echo ""
echo "Done. Log:"
jj log --limit 6 --no-pager
