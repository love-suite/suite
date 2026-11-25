#!/bin/sh
# Makes, once, the certificate GitHub signs every app's releases with ("Suite Release Signing"), apart from
# the one this Mac signs its own builds with, which never leaves it:
#   scripts/release-certificate.sh [--replace]
# Its private key goes straight into the "release" environment's secrets of every app repository, and
# nowhere else: it is never kept on this Mac. Its public half goes in each local repository's
# Support/release-certificate.cer, to commit there: the release workflows check the app against it.
set -eu
. "$(dirname "$0")/apps.sh"
NAME="Suite Release Signing"
FIRST="$ROOT/$(apps | head -1)/Support/release-certificate.cer"
if [ -s "$FIRST" ] && [ "${1:-}" != --replace ]; then
    echo "$FIRST exists already. Pass --replace to make a new certificate."; exit 1
fi
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
PASSWORD="$(uuidgen)"
/usr/bin/openssl req -x509 -newkey rsa:3072 -sha256 -days 3650 -nodes -subj "/CN=$NAME" \
    -addext "basicConstraints=critical,CA:false" \
    -addext "keyUsage=critical,digitalSignature" \
    -addext "extendedKeyUsage=critical,codeSigning" \
    -keyout "$WORK/key.pem" -out "$WORK/cert.pem" 2>/dev/null
# macOS's own openssl (LibreSSL) writes a .p12 that `security import` reads.
/usr/bin/openssl pkcs12 -export -name "$NAME" -inkey "$WORK/key.pem" -in "$WORK/cert.pem" \
    -out "$WORK/release.p12" -passout "pass:$PASSWORD"
for REPO in $(apps); do
    gh api --silent -X PUT "repos/$OWNER/$REPO/environments/release"
    base64 -i "$WORK/release.p12" | gh secret set RELEASE_CERTIFICATE --env release --repo "$OWNER/$REPO"
    printf %s "$PASSWORD" | gh secret set RELEASE_CERTIFICATE_PASSWORD --env release --repo "$OWNER/$REPO"
    /usr/bin/openssl x509 -in "$WORK/cert.pem" -outform der -out "$ROOT/$REPO/Support/release-certificate.cer"
    echo "$OWNER/$REPO: certificate in its release environment, public half in Support/release-certificate.cer"
done
echo "Commit Support/release-certificate.cer in each repository."
