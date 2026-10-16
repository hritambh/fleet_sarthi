#!/usr/bin/env bash
# Everything that must pass before a commit: `bun run preflight` from the repo root.
#
#   1. TypeScript: format, lint, typecheck, unit tests, build   (bun run verify)
#   2. Flutter app: format, analyze, tests                      (apps/driver-app)
#   3. API integration tests (Testcontainers; Docker must run)  [--skip-integration]
#   4. The server starts: migrate the local database, boot the built API and wait
#      for GET /v1/health/ready (local infra from `bun run infra:up`)
#   5. The web app builds                                      (flutter build web)
#   6. The Android app builds: a debug arm64 APK                [--skip-apk]
#   7. The iOS app builds: unsigned debug build (Mac + Xcode)   [--skip-ios]
#
# Stops at the first failure. Options skip slow steps when the change can't
# affect them (say so in the commit): --skip-integration (no API, contracts,
# domain or database change), --skip-apk / --skip-ios (no Android / iOS, plugin
# or pubspec change). Off a Mac the iOS step can't run and says so.
set -euo pipefail
cd "$(dirname "$0")/.."

SKIP_INTEGRATION=0
SKIP_APK=0
SKIP_IOS=0
for arg in "$@"; do
  case "$arg" in
    --skip-integration) SKIP_INTEGRATION=1 ;;
    --skip-apk) SKIP_APK=1 ;;
    --skip-ios) SKIP_IOS=1 ;;
    *) echo "preflight: unknown option $arg" >&2; exit 2 ;;
  esac
done

step() { printf '\n\033[1m── preflight: %s\033[0m\n' "$*"; }

step "1/7 TypeScript (format, lint, typecheck, unit tests, build)"
bun run verify

step "2/7 Flutter app (format, analyze, tests)"
(
  cd apps/driver-app
  flutter pub get >/dev/null
  dart format --output=none --set-exit-if-changed lib test
  flutter analyze --fatal-infos
  flutter test
)

if [[ "$SKIP_INTEGRATION" == 1 ]]; then
  step "3/7 API integration tests: skipped (--skip-integration)"
else
  step "3/7 API integration tests"
  # A local .env's S3_PUBLIC_ENDPOINT (a LAN address for phones) would point the
  # test containers' signed upload URLs at the wrong host.
  (cd apps/api && env -u S3_PUBLIC_ENDPOINT bunx vitest run -c vitest.int.config.ts)
fi

step "4/7 Server starts (local database migrated, API answers /v1/health/ready)"
docker compose up -d --wait >/dev/null
bun run db:migrate >/dev/null
PORT_UNDER_TEST="${PREFLIGHT_PORT:-3999}"
log="$(mktemp)"
(
  cd apps/api
  PORT="$PORT_UNDER_TEST" JOBS_MODE=external \
    exec node --env-file-if-exists=../../.env --enable-source-maps dist/main.js
) >"$log" 2>&1 &
api_pid=$!
trap 'kill "$api_pid" 2>/dev/null || true; rm -f "$log"' EXIT
ready=0
for _ in $(seq 1 60); do
  if ! kill -0 "$api_pid" 2>/dev/null; then break; fi
  if curl -fsS "http://localhost:$PORT_UNDER_TEST/v1/health/ready" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done
if [[ "$ready" != 1 ]]; then
  echo "preflight: the API did not become ready on port $PORT_UNDER_TEST. Its log:" >&2
  tail -40 "$log" >&2
  exit 1
fi
echo "API is up and ready on port $PORT_UNDER_TEST"
kill "$api_pid" 2>/dev/null || true
wait "$api_pid" 2>/dev/null || true

step "5/7 Web app builds"
(cd apps/driver-app && flutter build web --release)

if [[ "$SKIP_APK" == 1 ]]; then
  step "6/7 Android app: skipped (--skip-apk)"
else
  step "6/7 Android app builds (debug, arm64)"
  (cd apps/driver-app && flutter build apk --debug --target-platform android-arm64)
fi

if [[ "$SKIP_IOS" == 1 ]]; then
  step "7/7 iOS app: skipped (--skip-ios)"
elif [[ "$(uname)" != Darwin || ! -d /Applications/Xcode.app ]]; then
  step "7/7 iOS app: not checked (needs a Mac with Xcode; see docs/ios.md)"
else
  step "7/7 iOS app builds (debug, unsigned)"
  xcode_dir="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
  ios_path="$PATH"
  if [[ "$(xcode-select -p 2>/dev/null)" != "$xcode_dir" ]]; then
    # xcode-select still points at the Command Line Tools (fix for good with
    # `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`).
    # DEVELOPER_DIR alone isn't enough: Dart native-asset hooks (objective_c)
    # run `xcrun` without it, so put an xcrun on the PATH that sets it.
    echo "note: xcode-select points at $(xcode-select -p 2>/dev/null); using $xcode_dir for this build"
    shim="$(mktemp -d)"
    printf '#!/bin/sh\nDEVELOPER_DIR=%q exec /usr/bin/xcrun "$@"\n' "$xcode_dir" >"$shim/xcrun"
    chmod +x "$shim/xcrun"
    ios_path="$shim:$PATH"
  fi
  (cd apps/driver-app &&
    PATH="$ios_path" DEVELOPER_DIR="$xcode_dir" flutter build ios --debug --no-codesign)
fi

printf '\n\033[1;32mpreflight: everything passed\033[0m\n'
