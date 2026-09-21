#!/bin/bash
# jj-pr.sh — Helper for bookmark-based PR workflows
# Usage: 
#   jj pr push [bookmark_name]  — Pushes current bookmark or creates one
#   jj pr sync                  — Fetches and rebases onto trunk()

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/hooks.sh
. "$SCRIPT_DIR/lib/hooks.sh"

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
    # `bookmark set` creates or moves in one step. `bookmark move` is not a
    # substitute: on a name that does not exist yet it warns and still exits 0,
    # so a `|| bookmark create` fallback never fires and the push silently
    # becomes a no-op while reporting success.
    jj bookmark set "$BOOKMARK" -r @
    
    # Repo-local gate, run against exactly what is about to be pushed
    run_pre_push_hook

    echo "Exporting to Git and pushing..."
    jj git export
    # The first push of a PR bookmark necessarily creates it on the remote, which
    # jj refuses without --allow-new. 0.37 prints a deprecation warning for the
    # flag and points at remotes.<name>.auto-track-bookmarks, but that setting
    # governs fetch-side tracking and does not permit a push to create the remote
    # bookmark — verified, it still errors. The warning is expected.
    jj git push --bookmark "$BOOKMARK" --allow-new
    
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
