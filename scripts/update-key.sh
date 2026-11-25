#!/bin/sh
# Makes, once, the Ed25519 key that signs every app's update.json:
#   scripts/update-key.sh [--replace]
# Its private half goes straight into the "release" environment's secrets of every app repository
# (UPDATE_PRIVATE_KEY) and is never kept on this Mac; its public half goes in each local repository's
# Support/update-public-key.txt, to commit there: make-app.sh puts it in the app, which then accepts
# only updates signed with the private half.
set -eu
. "$(dirname "$0")/apps.sh"
FIRST="$ROOT/$(apps | head -1)/Support/update-public-key.txt"
if [ -s "$FIRST" ] && [ "${1:-}" != --replace ]; then
    echo "$FIRST exists already. Pass --replace to make a new key (installed apps would refuse updates)."; exit 1
fi
# Made before any repository is touched: a failing swift (a missing toolchain prints its error, not a key)
# stops here instead of storing that text as the key.
KEYS="$(swift "$(dirname "$0")/sign-update.swift" --create-key)" || {
    echo "Could not make the key. If swift complains about a missing toolchain: swiftly use 6.4.2"; exit 1
}
set -- $KEYS
# Two Ed25519 keys of 32 bytes, in base64: 44 characters each.
[ $# -eq 2 ] || { echo "sign-update.swift printed no valid key pair."; exit 1; }
for KEY in "$@"; do
    printf %s "$KEY" | grep -qE '^[A-Za-z0-9+/]{43}=$' || { echo "sign-update.swift printed no valid key pair."; exit 1; }
done
for REPO in $(apps); do
    gh api --silent -X PUT "repos/$OWNER/$REPO/environments/release"
    printf %s "$1" | gh secret set UPDATE_PRIVATE_KEY --env release --repo "$OWNER/$REPO"
    echo "$2" > "$ROOT/$REPO/Support/update-public-key.txt"
    echo "$OWNER/$REPO: update key in its release environment, public half in Support/update-public-key.txt"
done
echo "Commit Support/update-public-key.txt in each repository."
