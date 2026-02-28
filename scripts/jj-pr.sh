#!/bin/bash
# jj-pr.sh — Helper for bookmark-based PR workflows
# Usage: 
#   jj pr push [bookmark_name]  — Pushes current bookmark or creates one
#   jj pr sync                  — Fetches and rebases onto trunk()

set -e

COMMAND=$1
shift

case "$COMMAND" in
  "push")
    BOOKMARK=$1
    if [ -z "$BOOKMARK" ]; then
      # Try to find a bookmark pointing to the current commit (@)
      # We exclude 'main' as that should be handled by jj tug
      BOOKMARK=$(jj bookmark list -r @ --no-pager | grep -v "main" | awk '{print $1}' | head -n 1 | sed 's/:$//')
      
      if [ -z "$BOOKMARK" ]; then
        echo "Error: No feature bookmark found at @."
        echo "Usage: jj pr push <bookmark_name>"
        exit 1
      fi
    fi
    
    echo "Updating bookmark: $BOOKMARK"
    # Move if exists, create if not
    jj bookmark move "$BOOKMARK" --to @ 2>/dev/null || jj bookmark create "$BOOKMARK"
    
    echo "Exporting to Git and pushing..."
    jj git export
    jj git push --bookmark "$BOOKMARK"
    
    echo "-------------------------------------------------------"
    echo "Bookmark '$BOOKMARK' pushed to origin."
    ;;

  "sync")
    echo "Fetching from remotes..."
    jj git fetch
    
    echo "Rebasing current work onto trunk()..."
    jj rebase -d "trunk()"
    
    echo "-------------------------------------------------------"
    echo "Sync complete. Current log:"
    jj log --limit 5 --no-pager
    ;;

  *)
    echo "Usage: jj pr <push|sync> [bookmark_name]"
    exit 1
    ;;
esac
