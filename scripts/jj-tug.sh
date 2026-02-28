#!/bin/bash
jj git fetch --all-remotes
jj rebase -d main
jj bookmark move main --to @-
jj git push --bookmark main