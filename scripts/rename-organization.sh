#!/bin/sh
# After the GitHub organization was renamed (or the repositories moved to another one) on GitHub:
#   scripts/rename-organization.sh <new organization>
# points every local repository (~/GitHub/paul-amour/suite/<repo>) at it: its origin, the constant
# `organization` of its Package.swift, the locations in its Package.resolved, and the addresses written out
# in its casks, catalog and documentation. Commits nothing: check the changes, then commit them.
# The rest follows by itself: workflows take the organization from GitHub, make-app.sh and publish.sh
# from origin. GitHub redirects the old addresses as long as nobody takes the old name.
set -eu
. "$(dirname "$0")/apps.sh"
NEW="${1:?the new organization}"
OLD="$OWNER"
[ "$OLD" != "$NEW" ] || { echo "Already $NEW."; exit 0; }
for DIR in "$ROOT"/*/; do
    REPO="$(basename "$DIR")"
    URL="$(git -C "$DIR" config --get remote.origin.url 2>/dev/null || true)"
    case "$URL" in
        "https://github.com/$OLD/"*) git -C "$DIR" remote set-url origin "https://github.com/$NEW/${URL#https://github.com/$OLD/}" ;;
        "git@github.com:$OLD/"*) git -C "$DIR" remote set-url origin "git@github.com:$NEW/${URL#git@github.com:$OLD/}" ;;
        *) continue ;;
    esac
    [ ! -f "$DIR/Package.swift" ] || sed -i '' "s|^let organization = \"$OLD\"|let organization = \"$NEW\"|" "$DIR/Package.swift"
    git -C "$DIR" ls-files -z -- '*.md' '*.rb' '*.json' '*.resolved' \
        | (cd "$DIR" && xargs -0 sed -i '' -E "s#github\.com/$OLD/#github.com/$NEW/#g; s#(^|[^/A-Za-z-])$OLD/(homebrew-tap|tap|suite)#\1$NEW/\2#g")
    echo "$REPO: $NEW"
done
