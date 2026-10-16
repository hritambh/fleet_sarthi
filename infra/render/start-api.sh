#!/usr/bin/env bash
# Start command for the API on Render's free plan (render.yaml). Free web services
# have no pre-deploy command, so the database is prepared here, before the API
# listens. Every step is idempotent, and a free service runs a single instance.
#
#   1. create/update the app login role (libs/db/scripts/ensure-app-role.mjs)
#   2. prisma migrate deploy (takes an advisory lock; a no-op when up to date)
#   3. load the reference data (cab models and their fuel baselines) — idempotent,
#      and the one part of the seed every deployment needs, demo or not
#   4. with SEED_DEMO_DATA=true, load the demo fleet (skips if it already exists)
#   5. with DEMO_REFRESH_DAILY=true, rebuild the demo fleets if they were seeded on an
#      earlier IST day (a free service sleeps, so the 03:30 IST job may not run on
#      time; this makes the first start of the day bring the demo up to date). With
#      DEMO_REFRESH_FORCE=true, rebuild them on this start even if they're from today
#      (a one-off: set it, restart, set it back to false)
#   6. exec the API, so it receives Render's SIGTERM directly
set -euo pipefail
cd "$(dirname "$0")/../.."

(cd libs/db && node scripts/ensure-app-role.mjs && node_modules/.bin/prisma migrate deploy)

(cd apps/api && node --enable-source-maps dist/seed/reference-cli.js)

if [[ "${SEED_DEMO_DATA:-false}" == "true" ]]; then
  (cd apps/api && node --enable-source-maps dist/seed/seed-cli.js)
fi

if [[ "${DEMO_REFRESH_FORCE:-false}" == "true" ]]; then
  (cd apps/api && node --enable-source-maps dist/seed/demo-refresh-cli.js)
elif [[ "${DEMO_REFRESH_DAILY:-false}" == "true" ]]; then
  (cd apps/api && node --enable-source-maps dist/seed/demo-refresh-cli.js --if-stale)
fi

cd apps/api
exec node --enable-source-maps dist/main.js
