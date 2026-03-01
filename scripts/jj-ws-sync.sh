#!/bin/bash
# jj-ws-sync.sh — Rebase the current feature workspace onto the tip of default@
# Usage: jj ws-sync
#
# Run this from your feature workspace when default@ has moved ahead
# (e.g., after a teammate pushed, or you shipped other work via jj tug).
# This keeps your feature workspace from falling behind.

set -e

# Detect workspace name from the current directory name
WS_NAME=$(basename "$(pwd)")

# Verify this is actually a known workspace
if ! jj workspace list --no-pager 2>/dev/null | grep -q "^${WS_NAME}:"; then
  echo "Error: '${WS_NAME}' is not a workspace in this repo."
  echo "Known workspaces:"
  jj workspace list --no-pager
  exit 1
fi

echo "Workspace: ${WS_NAME}"
echo "Rebasing ${WS_NAME}@ onto default@..."

jj rebase -s "${WS_NAME}@" -d "default@"

echo "-------------------------------------------------------"
echo "Sync complete. ${WS_NAME} is now based on the tip of default."
jj log --limit 5 --no-pager
