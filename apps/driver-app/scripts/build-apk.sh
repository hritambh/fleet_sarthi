#!/usr/bin/env bash
# Builds a release APK of the Taxcy app pointed at a given API server.
#
#   API_URL=https://taxcy-api.onrender.com bun run build:apk
#   apps/driver-app/scripts/build-apk.sh --api-url https://taxcy-api.onrender.com --split --aab
#
# Options (each also settable through the environment variable in brackets):
#   --api-url URL        API server root, without /v1 [API_URL] (required)
#   --build-number N     Android versionCode [BUILD_NUMBER] (default: git commit count,
#                        so every newer build installs over the previous one)
#   --split              also build one smaller APK per CPU architecture [SPLIT_PER_ABI=1]
#   --aab                also build an Android App Bundle for Google Play [BUILD_AAB=1]
#
# Signing: android/key.properties (see scripts/create-keystore.sh) signs with your
# upload key; without it the build is signed with the debug key and a warning is shown.
# Copies of the outputs land in dist/driver-app/ at the repo root.
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$APP_DIR/../.." && pwd)"

API_URL="${API_URL:-}"
BUILD_NUMBER="${BUILD_NUMBER:-}"
SPLIT_PER_ABI="${SPLIT_PER_ABI:-0}"
BUILD_AAB="${BUILD_AAB:-0}"

usage() { sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; }
fail() {
  echo "build-apk: $*" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --api-url) API_URL="${2:-}"; shift 2 ;;
    --api-url=*) API_URL="${1#*=}"; shift ;;
    --build-number) BUILD_NUMBER="${2:-}"; shift 2 ;;
    --build-number=*) BUILD_NUMBER="${1#*=}"; shift ;;
    --split) SPLIT_PER_ABI=1; shift ;;
    --aab) BUILD_AAB=1; shift ;;
    -h | --help) usage; exit 0 ;;
    *) usage >&2; fail "unknown option: $1" ;;
  esac
done

# ── checks ──────────────────────────────────────────────────────────────────
command -v flutter >/dev/null || fail "flutter is not on PATH (https://docs.flutter.dev/get-started/install)"
command -v java >/dev/null || fail "java (JDK 17+) is not on PATH; Android Studio bundles one"

[[ -n "$API_URL" ]] || fail "set the API server, e.g. API_URL=https://taxcy-api.onrender.com bun run build:apk"
API_URL="${API_URL%/}"
API_URL="${API_URL%/v1}"
[[ "$API_URL" =~ ^https?://[^/]+ ]] || fail "API_URL must look like https://host[:port], got: $API_URL"

# Release builds only allow plain HTTP to the emulator's host alias and localhost
# (android/app/src/main/res/xml/network_security_config.xml).
if [[ "$API_URL" == http://* ]]; then
  host="${API_URL#http://}"
  host="${host%%[:/]*}"
  case "$host" in
    10.0.2.2 | localhost | 127.0.0.1) ;;
    *) fail "release builds need an https:// API_URL (got $API_URL). For a laptop on your LAN, use a debug build: flutter run --dart-define=API_URL=$API_URL" ;;
  esac
fi

[[ -z "$BUILD_NUMBER" || "$BUILD_NUMBER" =~ ^[0-9]+$ ]] || fail "--build-number must be a whole number"
if [[ -z "$BUILD_NUMBER" ]]; then
  BUILD_NUMBER="$(git -C "$REPO_ROOT" rev-list --count HEAD 2>/dev/null || echo 1)"
fi
VERSION="$(awk '/^version:/ { print $2; exit }' "$APP_DIR/pubspec.yaml")"
VERSION="${VERSION%%+*}"

KEY_PROPERTIES="$APP_DIR/android/key.properties"
if [[ -f "$KEY_PROPERTIES" ]]; then
  signing="upload key (android/key.properties)"
else
  signing="DEBUG key"
  cat >&2 <<'WARN'

  WARNING: android/key.properties not found, so this build is signed with the DEBUG key.
  That is fine for sideloading a test build, but phones holding a build signed with
  another key must uninstall it first, and Google Play rejects debug-signed uploads.
  Create an upload key once with: apps/driver-app/scripts/create-keystore.sh

WARN
fi

echo "build-apk: Taxcy $VERSION (build $BUILD_NUMBER), API $API_URL, signed with the $signing"

# ── build ───────────────────────────────────────────────────────────────────
cd "$APP_DIR"
flutter pub get
common=(--release "--dart-define=API_URL=$API_URL" "--build-name=$VERSION" "--build-number=$BUILD_NUMBER")

flutter build apk "${common[@]}"
if [[ "$SPLIT_PER_ABI" == 1 ]]; then
  flutter build apk "${common[@]}" --split-per-abi
fi
if [[ "$BUILD_AAB" == 1 ]]; then
  flutter build appbundle "${common[@]}"
fi

# ── collect ─────────────────────────────────────────────────────────────────
OUT_DIR="$REPO_ROOT/dist/driver-app"
mkdir -p "$OUT_DIR"
APK_DIR="$APP_DIR/build/app/outputs/flutter-apk"
name="taxcy-$VERSION+$BUILD_NUMBER"
outputs=()

cp "$APK_DIR/app-release.apk" "$OUT_DIR/$name.apk"
outputs+=("$OUT_DIR/$name.apk")
if [[ "$SPLIT_PER_ABI" == 1 ]]; then
  for abi in arm64-v8a armeabi-v7a x86_64; do
    if [[ -f "$APK_DIR/app-$abi-release.apk" ]]; then
      cp "$APK_DIR/app-$abi-release.apk" "$OUT_DIR/$name-$abi.apk"
      outputs+=("$OUT_DIR/$name-$abi.apk")
    fi
  done
fi
if [[ "$BUILD_AAB" == 1 ]]; then
  cp "$APP_DIR/build/app/outputs/bundle/release/app-release.aab" "$OUT_DIR/$name.aab"
  outputs+=("$OUT_DIR/$name.aab")
fi

echo
echo "build-apk: done (signed with the $signing). Outputs:"
for f in "${outputs[@]}"; do
  size="$(du -h "$f" | awk '{ print $1 }')"
  echo "  $f  ($size)"
done
echo
echo "Install on a phone connected over USB (USB debugging on):"
echo "  adb install -r \"$OUT_DIR/$name.apk\""
echo "Or copy the .apk to the phone and open it (allow installing from that app when asked)."
