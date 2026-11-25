#!/bin/sh
# Sets a secret, read from the standard input, in every app repository's "release" environment:
#   scripts/set-secret.sh HOMEBREW_TAP_TOKEN < token.txt
# or in this repository (the suite's own workflows) with --suite:
#   scripts/set-secret.sh --suite SUITE_DISPATCH_TOKEN < token.txt
set -eu
. "$(dirname "$0")/apps.sh"
if [ "${1:-}" = --suite ]; then
    gh secret set "${2:?a secret name}" --repo "$OWNER/suite"
    exit 0
fi
NAME="${1:?a secret name}"
VALUE="$(cat)"
for REPO in $(apps); do
    gh api --silent -X PUT "repos/$OWNER/$REPO/environments/release"
    printf %s "$VALUE" | gh secret set "$NAME" --env release --repo "$OWNER/$REPO"
    echo "$OWNER/$REPO: $NAME set"
done
