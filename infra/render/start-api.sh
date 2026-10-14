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
#   5. exec the API, so it receives Render's SIGTERM directly
set -euo pipefail
cd "$(dirname "$0")/../.."

(cd libs/db && node scripts/ensure-app-role.mjs && node_modules/.bin/prisma migrate deploy)

(cd apps/api && node --enable-source-maps dist/seed/reference-cli.js)

if [[ "${SEED_DEMO_DATA:-false}" == "true" ]]; then
  (cd apps/api && node --enable-source-maps dist/seed/seed-cli.js)
fi

cd apps/api
exec node --enable-source-maps dist/main.js
