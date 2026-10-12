#!/usr/bin/env bash
# Build command for the web app on Render (render.yaml: taxcy-web): the Flutter
# app (apps/driver-app) built for the browser, owner and driver modes in one.
# Render's build image has no Flutter SDK, so this fetches the pinned version
# (reused when the build cache still has it), then builds with the API's URL
# compiled in. Output: apps/driver-app/build/web.
set -euo pipefail
: "${API_URL:?set API_URL to the API server root, e.g. https://taxcy-api.onrender.com}"
# Forgive a bare host ("taxcy-api.onrender.com"): without a scheme the browser
# would treat it as a path on the web app itself. Drop a trailing / or /v1 too.
[[ "$API_URL" == http://* || "$API_URL" == https://* ]] || API_URL="https://$API_URL"
API_URL="${API_URL%/}"
API_URL="${API_URL%/v1}"
echo "API_URL=$API_URL"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.38.5}"
cd "$(dirname "$0")/../.."

sdk="${XDG_CACHE_HOME:-$HOME/.cache}/flutter-$FLUTTER_VERSION"
if [[ ! -x "$sdk/bin/flutter" ]]; then
  rm -rf "$sdk"
  git clone --quiet --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$sdk"
fi
export PATH="$sdk/bin:$PATH"
flutter config --no-analytics --no-cli-animations >/dev/null
flutter --version

cd apps/driver-app
flutter pub get
flutter build web --release --dart-define=API_URL="$API_URL"
