#!/usr/bin/env bash
# Creates the app's upload keystore (once) and android/key.properties, which
# android/app/build.gradle.kts reads to sign release builds.
#
#   apps/driver-app/scripts/create-keystore.sh [keystore-path]
#
# The keystore goes OUTSIDE the repo by default (~/.taxcy/taxcy-upload-keystore.jks).
# Back it up together with its password: Google Play only accepts updates signed with
# the same upload key, and phones refuse to install an update signed with another key.
# key.properties, *.jks and *.keystore are gitignored. Never commit them.
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KEYSTORE="${1:-$HOME/.taxcy/taxcy-upload-keystore.jks}"
KEY_PROPERTIES="$APP_DIR/android/key.properties"
ALIAS="upload"

command -v keytool >/dev/null || {
  echo "create-keystore: keytool not found; install a JDK 17+ (Android Studio bundles one)" >&2
  exit 1
}
if [[ -e "$KEYSTORE" ]]; then
  echo "create-keystore: $KEYSTORE already exists; not overwriting it." >&2
  echo "To reuse it, write $KEY_PROPERTIES by hand (see docs/deployment.md)." >&2
  exit 1
fi
if [[ -e "$KEY_PROPERTIES" ]]; then
  echo "create-keystore: $KEY_PROPERTIES already exists; move it away first." >&2
  exit 1
fi

read -r -s -p "Keystore password (at least 8 characters): " TAXCY_KEYSTORE_PASSWORD
echo
read -r -s -p "Repeat the password: " repeat
echo
[[ "$TAXCY_KEYSTORE_PASSWORD" == "$repeat" ]] || { echo "create-keystore: passwords differ" >&2; exit 1; }
[[ ${#TAXCY_KEYSTORE_PASSWORD} -ge 8 ]] || { echo "create-keystore: password too short" >&2; exit 1; }
export TAXCY_KEYSTORE_PASSWORD

mkdir -p "$(dirname "$KEYSTORE")"
# PKCS12 keystores use one password for the store and the key. `:env` keeps the
# password off the command line (and out of `ps`).
keytool -genkeypair -v \
  -keystore "$KEYSTORE" -storetype PKCS12 \
  -alias "$ALIAS" -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Fleet Sarthi, O=Fleet Sarthi, C=IN" \
  -storepass:env TAXCY_KEYSTORE_PASSWORD -keypass:env TAXCY_KEYSTORE_PASSWORD
chmod 600 "$KEYSTORE"

umask 077
cat >"$KEY_PROPERTIES" <<EOF
storePassword=$TAXCY_KEYSTORE_PASSWORD
keyPassword=$TAXCY_KEYSTORE_PASSWORD
keyAlias=$ALIAS
storeFile=$KEYSTORE
EOF

echo
echo "create-keystore: wrote $KEYSTORE and $KEY_PROPERTIES"
echo "Back up the keystore and its password somewhere safe (a password manager)."
echo
echo "Key fingerprints (keep for your records, e.g. for Play Console):"
keytool -list -v -keystore "$KEYSTORE" -alias "$ALIAS" -storepass:env TAXCY_KEYSTORE_PASSWORD |
  grep -E 'SHA1:|SHA256:' | sed 's/^[[:space:]]*/  /'
