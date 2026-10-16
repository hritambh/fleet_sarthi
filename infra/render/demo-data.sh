#!/usr/bin/env bash
# The demo-data step of start-api.sh, kept apart so it can be tested
# (apps/api/src/seed/demo-data-script.test.ts). Run from the repo root.
#
#   SEED_DEMO_DATA=true      load the demo fleet (skips if it already exists)
#   DEMO_REFRESH_DAILY=true  rebuild the demo fleets if they're from an earlier IST
#                            day or a seed stopped partway
#   DEMO_REFRESH_FORCE=true  rebuild them now, even if they're from today
#
# Demo data never stops the API from starting: a failure (for example the B2 key
# can't write photos: AccessDenied) is logged and this exits 0, so the API starts
# with whatever data there is. The next start tries again.
set -uo pipefail
cd "$(dirname "$0")/../.."

run() {
  local what="$1"
  shift
  if ! (cd apps/api && node --enable-source-maps "$@"); then
    echo "start-api: the demo $what failed (see above); starting the API anyway" >&2
  fi
}

if [[ "${SEED_DEMO_DATA:-false}" == "true" ]]; then
  run seed dist/seed/seed-cli.js
fi

if [[ "${DEMO_REFRESH_FORCE:-false}" == "true" ]]; then
  run refresh dist/seed/demo-refresh-cli.js
elif [[ "${DEMO_REFRESH_DAILY:-false}" == "true" ]]; then
  run refresh dist/seed/demo-refresh-cli.js --if-stale
fi
exit 0
