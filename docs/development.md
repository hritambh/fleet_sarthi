# Development guide

For a first run, follow [getting-started.md](getting-started.md); to build the APK or host a free demo, see [deployment.md](deployment.md). This page is the reference: tools, services, environment variables, scripts, tests and conventions.

## Toolchain

| Tool                   | Version                  | Used for                                                                            |
| ---------------------- | ------------------------ | ----------------------------------------------------------------------------------- |
| Node.js                | 24.x (`.nvmrc`)          | Runtime for the API, workers, seed and tooling                                      |
| Bun                    | 1.4.x (`packageManager`) | **Package manager only**: installs, workspaces, running scripts. Code runs on Node. |
| Nx                     | 23.x                     | Task runner and cache (`nx run-many`, libs build before their dependents)           |
| TypeScript             | 6.0.x                    | Pinned below 7 because typescript-eslint doesn't support TypeScript 7 yet           |
| Prisma                 | 7.10 (`libs/db`)         | Schema, migrations, client (driver adapter `@prisma/adapter-pg`)                    |
| Docker                 | 24+                      | Postgres, Redis and RustFS locally; Testcontainers in integration tests             |
| Flutter                | 3.38.x (Dart 3.10)       | Driver app                                                                          |
| Android Studio / Xcode | latest                   | Driver app emulator/simulator builds                                                |

### Why the Node apps build with `tsc`

NestJS 12 is ESM-only and relies on `emitDecoratorMetadata` for dependency injection. esbuild-based runners (tsx, `bun run file.ts`) don't emit that metadata. So `apps/api` and `apps/workers` compile with `tsc`, `dev` runs `tsc --watch` next to `node --watch`, and the API's Vitest configs use SWC (`unplugin-swc`).

### How workspace libs are consumed

| Condition | Target            | Used by                           |
| --------- | ----------------- | --------------------------------- |
| `source`  | `src/index.ts`    | Type-checking inside the monorepo |
| `types`   | `dist/index.d.ts` | `tsc` in the Node apps            |
| `default` | `dist/index.js`   | Node at runtime                   |

Nx builds a project's libs first, so `dist/` is fresh whenever a Node app needs it. Bun installs workspaces in **isolated** mode: a package can only import what its own `package.json` lists, including `@types/node`.

## Local services

`bun run infra:up` starts them; `docker-compose.yml` defines them.

| Service                     | Address                                            | Credentials (dev only)                                                    |
| --------------------------- | -------------------------------------------------- | ------------------------------------------------------------------------- |
| PostgreSQL 16 + PostGIS 3.5 | `localhost:5433`                                   | owner `taxcy`/`taxcy`; app role `taxcy_api`/`taxcy_api`; database `taxcy` |
| Redis 8                     | `localhost:6380`                                   | —                                                                         |
| RustFS (S3 API)             | <http://localhost:9000>                            | `taxcy` / `taxcy-dev-secret`, bucket `taxcy-media`                        |
| RustFS console              | <http://localhost:9001/rustfs/console/>            | same                                                                      |
| API                         | <http://localhost:3000/v1>                         | —                                                                         |
| API docs                    | <http://localhost:3000/docs> (`/` redirects here)  | —                                                                         |
| Bull Board (job queues)     | <http://localhost:3001/queues>                     | —                                                                         |
| The app in Chrome           | <http://localhost:5174> (`bun run dev:driver-web`) | —                                                                         |

- **Ports:** the host ports avoid 5432 and 6379, so a natively installed Postgres or another project's Redis can't silently answer on `localhost`.
- **Database roles:** the Postgres init script (`infra/postgres/init-roles.sql`) creates `taxcy_api`, the role the API and workers connect as. It is neither a superuser nor the table owner, so [row-level security](architecture.md#multi-tenancy) applies to it. Migrations and the seed's reference data run as the owner.
- **Object storage:** local S3 is **RustFS**, because MinIO no longer publishes container images. The API speaks plain S3 (AWS SDK).

## Environment variables

The API and workers validate their environment at startup with Zod (`apps/api/src/platform/config.ts`) and exit with a readable list of problems. `.env.example` has working local values; never commit real secrets.

| Variable                                                                            | Default                  | Purpose                                                                                                                                                                     |
| ----------------------------------------------------------------------------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `NODE_ENV`                                                                          | `development`            | `development` \| `test` \| `production`                                                                                                                                     |
| `PORT`                                                                              | `3000`                   | API port                                                                                                                                                                    |
| `LOG_LEVEL`                                                                         | `info`                   | pino level; pretty-printed in development                                                                                                                                   |
| `CORS_ORIGINS`                                                                      | `http://localhost:5174`  | Comma-separated allowed origins                                                                                                                                             |
| `DATABASE_URL`                                                                      | —                        | App role connection (`taxcy_api`, RLS applies)                                                                                                                              |
| `DATABASE_MIGRATION_URL`                                                            | —                        | Owner connection for migrations and the seed                                                                                                                                |
| `SHADOW_DATABASE_URL`                                                               | —                        | Empty database used by `db:drift`                                                                                                                                           |
| `POSTGRES_*`, `REDIS_PORT`, `S3_PORT`, `S3_CONSOLE_PORT`                            | see `.env.example`       | docker-compose settings                                                                                                                                                     |
| `REDIS_URL`                                                                         | —                        | Reset codes, rate limits, BullMQ                                                                                                                                            |
| `S3_ENDPOINT`, `S3_REGION`, `S3_BUCKET`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY` | —                        | Object storage                                                                                                                                                              |
| `S3_PUBLIC_ENDPOINT`                                                                | `S3_ENDPOINT`            | Host used in signed URLs; set to your LAN IP for a physical phone                                                                                                           |
| `S3_UPLOAD_URL_TTL_SECONDS`                                                         | `600`                    | Signed upload URL lifetime                                                                                                                                                  |
| `JWT_ACCESS_SECRET`                                                                 | —                        | ≥ 32 characters                                                                                                                                                             |
| `JWT_ACCESS_TTL_SECONDS` / `JWT_REFRESH_TTL_DAYS`                                   | `900` / `30`             | Token lifetimes                                                                                                                                                             |
| `OTP_TTL_SECONDS` / `OTP_MAX_ATTEMPTS` / `OTP_IP_LIMIT_PER_HOUR`                    | `300` / `5` / `30`       | Password-reset codes                                                                                                                                                        |
| `SMS_PROVIDER` / `OCR_PROVIDER`                                                     | `console` / `stub`       | Provider selection (only stubs exist so far)                                                                                                                                |
| `JOBS_MODE`                                                                         | `external`               | `external`: the workers app runs jobs; `in-process`: the API does                                                                                                           |
| `DEMO_MODE`                                                                         | `false`                  | Allows `SMS_PROVIDER=console` in production (reset codes in the log)                                                                                                        |
| `MASTER_PASSWORD`                                                                   | empty (off)              | Testing only: signs in as any user and resets any password (see [deployment](deployment.md#master-password-testing-only)); 8+ characters; production needs `DEMO_MODE=true` |
| `PHONE_OTP_PROVIDER` / `PHONE_EMAIL_CLIENT_ID` / `SIGNUP_REQUIRES_VERIFIED_PHONE`   | `none` / empty / `false` | Phone OTP via phone.email, or `stub` locally; see [phone OTP](phone-otp.md)                                                                                                 |
| `SENTRY_DSN`                                                                        | empty                    | Sentry is enabled when set                                                                                                                                                  |
| `WORKERS_DASHBOARD_PORT`                                                            | `3001`                   | Bull Board                                                                                                                                                                  |

## Scripts

Run from the repo root with `bun run <script>`.

| Script                                    | What it does                                                                                         |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `dev`                                     | API and workers in watch mode (builds libs first)                                                    |
| `dev:api` / `dev:workers`                 | One app only                                                                                         |
| `dev:driver-web`                          | The Flutter app in Chrome on port 5174, owner and driver modes (needs the API running)               |
| `build:apk`                               | Release APK of the app for `API_URL` into `dist/driver-app/` ([deployment](deployment.md))           |
| `driver:keystore`                         | Create the app's upload keystore and `android/key.properties` (once)                                 |
| `infra:up` / `infra:down` / `infra:reset` | Start, stop, or wipe and restart Postgres, Redis and RustFS                                          |
| `db:migrate`                              | Apply migrations (`prisma migrate deploy`)                                                           |
| `db:deploy`                               | Create/update the app role from `DATABASE_URL`, then apply migrations (hosted databases)             |
| `db:seed`                                 | Load the demo fleet (safe to re-run; skips if it already exists)                                     |
| `db:reset`                                | Drop everything, migrate, and seed                                                                   |
| `db:migration <name>`                     | Create a migration for review (`prisma migrate dev --create-only`)                                   |
| `db:drift`                                | Fail if `schema.prisma` and the migrations disagree (needs the shadow database)                      |
| `db:generate` / `db:studio`               | Prisma client generation / Prisma Studio                                                             |
| `api:client`                              | Rebuild `libs/api-client/openapi.json` and the typed client from the contracts                       |
| `lint` / `typecheck` / `test` / `build`   | Across all projects, including `dart format` + `flutter analyze` + `flutter test` for the driver app |
| `test:integration`                        | API integration tests against throwaway containers (about 5 minutes)                                 |
| `format` / `format:check`                 | Prettier                                                                                             |
| `verify`                                  | `format:check`, then lint, typecheck, test and build: what CI runs                                   |

Run one project's target with `bunx nx run @taxcy/domain:test`. Nx caches results; add `--skip-nx-cache` to force a run.

### Creating a migration

1. Edit `libs/db/prisma/schema.prisma`.
2. `bun run db:migration add_something` writes `libs/db/prisma/migrations/<timestamp>_add_something/migration.sql` without applying it.
3. **Read the SQL.** Prisma will drop objects it doesn't model, such as partitions, exclusion constraints, CHECKs, RLS policies and functions. If you see such drops, delete them.
4. `bun run db:migrate`, then `bun run db:drift`.

## Projects

| Project             | Path              | What's inside                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| ------------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `@taxcy/api`        | `apps/api`        | NestJS modular monolith: `platform/` (config, logging, auth guard, contract binding, idempotency, outbox, jobs) and `modules/` (identity, media, fleet, trips, fuel, telemetry, money, alerts)                                                                                                                                                                                                                                                                                                                                  |
| `@taxcy/workers`    | `apps/workers`    | Outbox relay → BullMQ, a worker per queue, cron schedules, Bull Board. Boots the API's modules without HTTP (`@taxcy/api/worker`).                                                                                                                                                                                                                                                                                                                                                                                              |
| `@taxcy/driver-app` | `apps/driver-app` | Flutter app "Fleet Sarthi" (Dart package `taxcy_driver`): offline-first driver screens and online owner/manager mode, in English and Hindi. `bun run --cwd apps/driver-app codegen` regenerates the drift database code; `bun run dev:driver-web` runs it in Chrome on port 5174, and `bun run --cwd apps/driver-app web-assets` refreshes `web/sqlite3.wasm` and `web/drift_worker.js` after upgrading `sqlite3` or `drift`; `bunx nx run @taxcy/domain:fixtures` re-exports the trip transition fixture it is tested against. |
| `@taxcy/contracts`  | `libs/contracts`  | Zod route contracts, error codes, OpenAPI builder                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `@taxcy/domain`     | `libs/domain`     | Pure logic: fuel audit, GPS checks, trip state machine, settlement, document expiry                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `@taxcy/db`         | `libs/db`         | Prisma schema, migrations, client, tenant/system transactions                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| `@taxcy/api-client` | `libs/api-client` | Generated TypeScript client (openapi-fetch)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |

## Translations

The app ships in English (default) and Hindi, with Flutter's `gen-l10n` (`apps/driver-app/l10n.yaml`).

- **Resources:** one ARB file per language in `apps/driver-app/lib/l10n/`. `app_en.arb` is the template, with an `@key` entry for each string that declares its placeholders; every other `app_<code>.arb` is a translation. The generated Dart (`lib/l10n/app_localizations*.dart`) is committed and regenerated by `flutter pub get` / `flutter gen-l10n`.
- **Using it:** `context.l10n.someKey` (an extension in `lib/features/common/format.dart`); placeholders are named parameters, e.g. `l.workspaceDrive(fleet: name)`.
- **Numbers, money and dates:** `Fmt` in `lib/features/common/format.dart` formats for the current language's locale (`en_IN` / `hi_IN`: ₹ with Indian grouping). Format values first and pass the strings into the message.
- **Server text:** the API sends codes and values, not translated text. Alerts, settlement lines and review reasons are rendered in `lib/features/owner/owner_text.dart`, and errors from `error.code` in `lib/features/common/errors.dart`. Each falls back to the server's English when the code is unknown.
- **Choosing a language:** the language button on the sign-in screen, **More → Language** in owner mode, or the menu in driver mode. The choice is saved on the device (`locale_v1` in shared preferences).
- **Checks:** `test/l10n_test.dart` checks that every ARB file is a complete translation, that Hindi is in Devanagari, money and date formats, and that every contract error code has a translation.

### Adding a language

1. Copy `lib/l10n/app_hi.arb` to `app_<code>.arb` (e.g. `app_mr.arb`), set `@@locale`, and translate every string. Keep each `{placeholder}`, and the ICU `plural` forms the language needs.
2. Add the language's own name to `languageNames` in `lib/app/preferences.dart`.
3. Run `flutter pub get` (regenerates the Dart) and `flutter test test/l10n_test.dart`.

## Testing

| Suite                 | Where                            | What it covers                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| --------------------- | -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Domain unit tests     | `libs/domain` (Vitest)           | Every rule, table-driven, including the worked examples in [`docs/domain`](domain/)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Contract tests        | `libs/contracts`                 | Shared schemas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| API integration tests | `apps/api/test/*.int.test.ts`    | Each file boots the real Nest app on a port against Testcontainers (PostGIS, Redis, RustFS) with migrations applied, and drives it over HTTP. Background jobs run in-process via `runJobs()`.                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Seed test             | `apps/api/test/seed.int.test.ts` | Runs the full demo seed and checks it produces the alerts, review items, trip states and settlements the guides promise                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Driver app            | `apps/driver-app/test`           | `flutter test`: sync engine against a fake API (ordering, idempotency keys reused on retry, backoff, conflicts), drift outbox, model parsing, widgets, and state-machine conformance with the TypeScript fixture. Owner mode against `FakeOwnerApi`: parsing of every model, alert/settlement/review wording in both languages, role routing, manager restrictions and the main flows. Sign-in (password, sign-up, forgot password, account security) against `FakeAuthApi`. Every screen is rendered at 360 px in English and Hindi to catch overflow. `l10n_test.dart` fails if a translation is missing a key or a placeholder |

The integration suite covers password sign-in, sign-up, password reset and token rotation, row-level security, signed uploads and OCR reconciliation, fleet and document expiry, the trip lifecycle (idempotent replays, double-booking, offline conflicts, cancellation approval), fuel audits (late fills, voids, bi-fuel), GPS distance checks and partitions, and settlements (carry-forward of late items).

## The app: languages, owner mode and sign-in

### Translations

The app uses Flutter's `gen-l10n`. Every user-facing string lives in `apps/driver-app/lib/l10n/app_en.arb` (the template) and its translation `app_hi.arb`. `flutter pub get` (and `flutter gen-l10n`) regenerates `lib/l10n/app_localizations*.dart` from them; the generated files are committed, like the drift code, and excluded from lint by their own `ignore_for_file`. In code, `context.l10n.someKey` gives a message and `context.fmt` formats ₹ amounts, numbers and dates for the current language (`en_IN` or `hi_IN`, Indian digit grouping, device local time).

- **New string:** add it to `app_en.arb` (with an `@key` entry describing placeholders) and to `app_hi.arb`, then run `flutter gen-l10n`. Use ICU plurals for counts. Pass formatted values (amounts, km, dates) as String placeholders.
- **Server text:** the API sends codes and values. Word them in `lib/features/owner/owner_text.dart` (alerts from `message`, settlement lines from `item`, review reasons from `context.reasonCode`) and `lib/features/common/errors.dart` (errors by `error.code`). Always fall back to the server's English for codes the app doesn't know.
- **New language:** copy `app_hi.arb` to `app_<code>.arb`, set `@@locale`, translate every value (keep placeholders), and run `flutter gen-l10n`. It appears in the language picker automatically (add its own-script name in `languageNames` in `lib/app/preferences.dart`). `test/l10n_test.dart` fails until every key is translated. For a script the web build can't render, bundle a font as with `assets/fonts/NotoSansDevanagari-*`.
- Hindi should be everyday Hindi in Devanagari, keeping loan words people use (ट्रिप, ड्राइवर, किमी, टोल, UPI, ओडोमीटर).

The language is stored with `shared_preferences` (`locale_v1`); unset means "follow the phone".

### Owner mode

`lib/app/app.dart` routes by role (`screensFor`): owners and managers get `OwnerShell`, drivers the driver screens, and a DCO switches (`appModeProvider`, saved as `app_mode_v1`). Owner mode is online-first ([D12](decisions.md)):

| Layer   | Where                                              | What                                                                                                                    |
| ------- | -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| API     | `lib/core/api/owner_api.dart`, `owner_models.dart` | `OwnerApi` (staff endpoints) over the driver's `HttpTaxcyApi` transport; hand-written models parsed through `json.dart` |
| Data    | `lib/features/owner/owner_providers.dart`          | Riverpod `FutureProvider`s per list/record; `refreshAfter` invalidates what a change touches                            |
| Wording | `lib/features/owner/owner_text.dart`               | Pure functions from codes to text, unit-tested in both languages                                                        |
| Screens | `lib/features/owner/**`                            | `OwnerShell` (bottom bar on phones, rail from 840 px), one file per area; shared widgets in `owner_widgets.dart`        |

Tests replace `ownerApiProvider` with `FakeOwnerApi` (`test/support/owner_fakes.dart`) and turn off map tiles (`mapTilesProvider`).

### Sign-in

The login screen (`lib/features/login/`) offers mobile number + password, **Sign up** and **Forgot password?** (a reset code, then a new password). All sign-in calls go through `AuthApi` (`lib/core/api/auth_api.dart`, models in `auth_models.dart`); `AuthController` in `lib/app/providers.dart` saves the session and the root widget routes by role as before. The account screen (`lib/features/account/`) uses `GET /me` and `POST /me/password` to set or change the password. Passwords are never stored by the app. Tests replace `authApiProvider` with `FakeAuthApi` (`test/support/auth_fakes.dart`).

## Conventions

- **Layering:** controller (bound to a contract with `@Route`; `@Input()` gives validated params/query/body) → service (transactions via `Db.tenant()`/`Db.system()`) → repository or Prisma calls on the transaction → `libs/domain` for rules. Controllers hold no logic.
- **Tenancy:** org-scoped work happens inside `db.tenant(orgId, tx => …)`. `TenantTx` is the only way to reach org data, and RLS backs it up.
- **Writes and jobs:** side effects that should happen after commit are published with `publish(tx, topic, payload)` into the outbox. Handlers are marked `@OnJob(topic)` and must be idempotent.
- **Errors:** throw `AppError(code, message, details?)`. Anything else becomes a logged `500 INTERNAL`.
- **Errors that must persist:** if something must be recorded _and_ the request must fail (e.g. a rejected upload), commit the record in its own transaction, then throw. A throw inside the transaction rolls the record back.
- **Types:** strict TypeScript (`strictTypeChecked`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`), no `any`. Use `Patch<T>` + `definedOnly()` for partial updates.
- **Money and time:** paise as `bigint` in the DB and `number` in code. UTC everywhere; IST only for display and business dates (`istBusinessDate`).
- **Commits:** [Conventional Commits](https://www.conventionalcommits.org/).

## CI

`.github/workflows/ci.yml` runs on pushes to `main` and on pull requests:

| Job                      | Steps                                                                                                           |
| ------------------------ | --------------------------------------------------------------------------------------------------------------- |
| TypeScript               | install, `format:check`, lint, typecheck, test, build (excluding the driver app)                                |
| Migrations + integration | Postgres service → roles → `db:drift`; generated client must be up to date; `test:integration` (Testcontainers) |
| Flutter driver app       | `dart format` check, `flutter analyze --fatal-infos`, `flutter test`, `flutter build web`                       |
