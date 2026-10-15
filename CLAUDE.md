# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Fleet Sarthi (formerly Taxcy): fleet audit and cab operations for small fleet owners and owner-drivers in India. Code identifiers keep the old name (`@taxcy/*` packages, Dart package `taxcy_driver`, app id `in.taxcy.taxcy_driver`, DB and env names); only user-facing text says Fleet Sarthi.

## Commands

Bun workspaces + Nx; Node 24 runs the API. Run from the repo root unless noted.

```bash
bun install
bun run infra:up                          # Postgres+PostGIS :5433, Redis :6380, RustFS (S3) :9000 via docker compose
bun run db:migrate && bun run db:seed     # schema + demo fleet (seed is idempotent; db:reset wipes and re-seeds)
bun run dev                               # API :3000 + workers
bun run dev:driver-web                    # the Flutter app in Chrome on :5174 (debug; reload with r/R in the terminal, not the browser)

bun run verify                            # what CI's TypeScript job runs: format:check + lint typecheck test build
bunx nx run @taxcy/api:test               # one project's unit tests (also :lint, :typecheck, :build)
bun run test:integration                  # API integration tests (Testcontainers; Docker must be running)
```

Single tests:

```bash
cd apps/api && bunx vitest run src/modules/identity/default-org.test.ts                     # unit (src/**/*.test.ts)
cd apps/api && bunx vitest run -c vitest.int.config.ts test/trips.int.test.ts -t "replay"   # integration (test/*.int.test.ts)
cd apps/driver-app && flutter test test/desktop_test.dart --plain-name "trips are a table"
```

Flutter app (`apps/driver-app`): `flutter analyze --fatal-infos`, `dart format lib test`, `flutter test`. CI also runs `flutter build web`. Generated Dart (`lib/l10n/app_localizations*.dart`, `database.g.dart`) is committed; `flutter pub get` regenerates l10n from the ARB files.

Database changes: edit `libs/db/prisma/schema.prisma`, run `bun run db:migration <name>` (writes SQL without applying), **read the SQL and delete any drops of objects Prisma doesn't model** (partitions, exclusion constraints, CHECKs, RLS policies, functions), then `bun run db:migrate && bun run db:drift`. After changing `libs/contracts`, run `bun run api:client` (CI fails if the generated client is stale) and update the hand-written Dart models in `apps/driver-app/lib/core/api/` to match.

APK: `API_URL=https://taxcy-api.onrender.com bun run build:apk:arm64` → `dist/driver-app/fleet-sarthi-<version>-arm64-v8a.apk`, the one to send to phones (`build:apk` builds the universal APK instead; add `-- --split` for all three CPU variants too). Release builds require `https://`; for a laptop's LAN IP use `flutter build apk --debug --dart-define=API_URL=http://<ip>:3000` (see docs/deployment.md Part 1). Every push to `main` that changes `apps/driver-app` also builds the arm64 APK in CI and posts it to Slack #releases (`.github/workflows/android-release.yml`; setup in docs/deployment.md, "Automatic APK in Slack").

## Architecture

- **`apps/api`**: NestJS modular monolith (`src/modules/<area>`, cross-cutting code in `src/platform`). ESM-only with decorator metadata, so it compiles with `tsc` (dev = `tsc --watch` + `node --watch`) and the Vitest configs use SWC. Don't run it with tsx or `bun file.ts`.
- **`apps/workers`**: same codebase, runs the job runner (outbox relay, BullMQ workers, schedules). With `JOBS_MODE=in-process` the API runs jobs itself instead (free hosting); the two refuse to both run jobs.
- **`libs/contracts`**: Zod route contracts (`defineRoute`), the single source of truth. Controllers bind with `@Route(r.x)` and get validated input via `@Input()`; OpenAPI and `libs/api-client` are generated from them.
- **`libs/db`**: Prisma schema, migrations, client. **`libs/domain`**: pure business rules (fuel audit, trip state machine, settlement math) with table-driven tests. The trip transition table is exported as a JSON fixture that the Dart port is tested against.
- **`apps/driver-app`**: the only client. One Flutter app for Android and the web, with **owner mode** (online-first owner/manager screens) and **driver mode** (offline-first: drift/SQLite local DB + outbox replayed in order by `SyncEngine`, idempotency keys reused on retry). Riverpod for state; tests run against fakes in `test/support/` via `Harness`.

Layering in the API: controller (no logic) → service (opens transactions) → repository/Prisma on the given transaction → `libs/domain` for rules. Errors are `AppError(code, message, details?)`; anything else becomes a 500. To record something _and_ fail the request, commit it in its own transaction, then throw. Side effects after commit go through the transactional outbox: `publish(tx, topic, payload)`, handled by idempotent `@OnJob(topic)` handlers.

**Multi-tenancy is enforced in three layers:** the guard loads the membership for the JWT's `org_id`; org work runs inside `db.tenant(orgId, tx => …)` (typed `TenantTx`), which sets `app.org_id`; Postgres RLS policies check it. The API connects as `taxcy_api`, which must not be the table owner or `BYPASSRLS`; `libs/db/scripts/ensure-app-role.mjs` creates and checks that role, and `DATABASE_MIGRATION_URL` is the owner connection. Cross-org/system work uses `db.system(…)`.

**Accounts and roles:** one user, many memberships, each with a set of roles (`owner`, `manager`, `driver`), so a person can run one fleet and drive in another. Tokens are scoped to one org; `POST /auth/switch-org` issues a new pair. Login opens a fleet the user owns or manages first (`defaultOrgId`). In the app, `lib/app/workspaces.dart` turns memberships into "Manage X" / "Drive for Y" workspaces. Switching fleets clears the device's local driver data, so it's refused while anything is unsynced. Sign-in is phone + password, plus optional phone OTP via phone.email (`PHONE_OTP_PROVIDER`; the API verifies each token itself in `phone-verification.ts`, once; the app reads `GET /auth/methods`; see docs/phone-otp.md). Reset codes go through `SmsProvider` (`console` logs them). `MASTER_PASSWORD` (testing only) signs in as anyone.

**App layout:** owner mode has three layouts by width: bottom nav (phones), rail (tablets), and from 1100 px (`desktopMinWidth`) `DesktopOwnerShell` with a sidebar, one nested `Navigator` per section, and desktop variants built from shared `DesktopTable` / `CardGrid` / `PageAction` in `owner_widgets.dart`. Gate desktop-only UI with `isDesktop(context)`. All UI text goes through `context.l10n` (English template `lib/l10n/app_en.arb`, Hindi `app_hi.arb`); add every new key to both.

## Conventions

- Strict TypeScript (`strictTypeChecked`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`), no `any`. Partial updates use `Patch<T>` + `definedOnly()`.
- Money is integer paise (`bigint` in the DB, `number` in code). Times are UTC; IST only for display and business dates (`istBusinessDate`).
- Bun installs workspaces in isolated mode: a package can only import what its own `package.json` lists.
- Conventional Commits. Prettier formats TS/JSON/Markdown/YAML; `dart format` formats Dart.
- Demo data (`apps/api/src/seed/seed.ts`): the Sharma Travels fleet plus Patil Cabs (Anil and Suresh each own one fleet and drive in the other); every demo person's password is `12345678`. `docs/usage/demo-data.md` and `seed.int.test.ts` depend on what the seed creates.
- Deployment (Render Blueprint `render.yaml` + Neon + Backblaze B2) is documented in `docs/deployment.md`; design decisions in `docs/decisions.md`.
- Project skills live in `.claude/skills/` and are named with an `fs-` prefix (folder and `name:` frontmatter, e.g. `fs-plan-feature`), so they're easy to tell apart from global and plugin skills.
