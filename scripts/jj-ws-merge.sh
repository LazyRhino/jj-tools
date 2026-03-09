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

# Always ensure the workspace commit has the intended message before squashing.
# If no message was provided as an argument, we keep whatever is already there.
if [ -n "$1" ]; then
  echo "Describing current working copy: $1"
  jj describe -m "$1"
fi

# Squash all work in the workspace since it diverged from main into default@
# This handles cases where work has been 'sealed' (moved to @- or further)
echo "Squashing ${WS_NAME} (all work since main) → default@..."
jj squash --from "main..@" --into "default@"

# Handle colocation sync - ensure Git index in main repo is current
echo "Exporting to Git..."
jj git export

# Create a fresh, empty working copy for this workspace at the new tip of default.
# This prevents dangling commits and keeps the feature workspace clean for next use.
echo "Repointing workspace to default@..."
jj new "default@"

echo "Merge complete! To finish in the main workspace:"
echo "1. cd ../yoloaday"
echo "2. jj sync        # <--- Updates state and exports to Git"
echo "3. jj tug         # <--- Robustly handles rebase, sealing, and pushing"
echo "-------------------------------------------------------"

echo ""
echo "Done. Log:"
jj log --limit 6 --no-pager
