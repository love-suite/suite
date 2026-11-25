# The repositories of the suite that make an app (every one but the libraries, suite-core and suite-files),
# for the other scripts.
apps() { grep -v -E '^suite-(core|files)$' "$(dirname "$0")/../repositories.txt"; }
# The GitHub organization, from this repository's origin, so a renamed organization changes nothing here.
OWNER="$(git -C "$(dirname "$0")" config --get remote.origin.url \
    | sed -nE 's#^(https://github\.com/|git@github\.com:)([^/]+)/.*#\2#p')"
[ -n "$OWNER" ] || { echo "No GitHub organization: this repository's origin isn't on GitHub."; exit 1; }
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
