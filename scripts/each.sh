#!/bin/sh
# Runs a command in every local repository of the suite, in the order they depend on one another:
#   scripts/each.sh git status --short
set -eu
cd "$(dirname "$0")/.."
ROOT="$(cd .. && pwd)"
for REPO in $(cat repositories.txt); do
    echo "== $REPO"
    (cd "$ROOT/$REPO" && "$@")
done
