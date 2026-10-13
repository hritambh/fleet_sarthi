---
name: fs-review
description: Review a Fleet Sarthi pull request, branch, commit range, or uncommitted changes against this repo's own standards (CLAUDE.md, docs/decisions.md, the plan in docs/plans/ if any) — layering, multi-tenancy/RLS, migrations, contracts and generated code, money/time, offline driver mode, English + Hindi strings, tests, and CI checks. Use when the user says "review", "review this PR/branch", "check my changes", "is this ready to merge", or gives a PR number or branch name. Reports findings; does not change code unless asked.
argument-hint: '[PR number | branch | <base>..<head> | empty for uncommitted changes] [--quick]'
---

# Review a change against Fleet Sarthi standards

You are the reviewing tech lead. Find the problems that matter in this repo
— a cross-tenant leak, a migration that drops an RLS policy, a Hindi string
missing — not generic style nits. Every finding must point to a line and
to the standard it breaks. Don't edit code; report, then offer to fix.

## Step 1 — Work out what to review

Resolve the argument to a base and head. `gh` is **not installed** here, so use git:

| Argument      | How                                                                                                                                            |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| empty         | Uncommitted work: `git diff HEAD` plus untracked files (`git status --short`). Base = `HEAD`.                                                  |
| PR number `N` | `git fetch origin pull/N/head:review/pr-N` (GitHub exposes PR heads). Base = `git merge-base origin/main review/pr-N`, head = `review/pr-N`.   |
| branch name   | `git fetch origin <branch>`; base = `git merge-base origin/main origin/<branch>`, head = `origin/<branch>` (or the local branch if it exists). |
| `A..B`        | Use as given.                                                                                                                                  |

Then collect:

- `git log --oneline <base>..<head>` — commit messages (Conventional Commits?).
- `git diff --stat <base>..<head>` and the full diff.
- The list of changed files grouped by area: `apps/api`, `apps/workers`,
  `libs/contracts`, `libs/db` (schema / migrations), `libs/domain`,
  `libs/api-client`, `apps/driver-app` (lib / test / l10n / web),
  `docs`, `infra` / `render.yaml` / CI.

If the diff is empty, say so and stop. If it's huge (>3,000 changed lines),
say which areas you'll focus on and why.

## Step 2 — Load the standards

Read, don't recall:

- `CLAUDE.md` — commands, architecture, layering, tenancy, conventions.
- `docs/decisions.md` — numbered decisions (D1…). A change that contradicts
  one without a new D-row is a finding.
- The plan, if the change implements one: look in `docs/plans/` for a file
  whose name or content matches the branch/PR/commits. Its acceptance checks
  and steps are the spec.
- For domain areas touched: `docs/domain/*.md` (fuel-audit, settlement,
  telemetry, evidence), `docs/database.md`, `docs/architecture.md`.

## Step 3 — Run the mechanical checks (what CI runs)

Run only what the changed areas need; run independent ones in parallel.
Skip all of this with `--quick`.

| Changed                                        | Run                                                                                                                               |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| any TS/JSON/MD/YAML                            | `bun run format:check`                                                                                                            |
| `apps/api`, `apps/workers`, `libs/*`           | `bunx nx run-many -t lint typecheck test --exclude @taxcy/driver-app` (or the affected projects only)                             |
| `libs/contracts`                               | `bun run api:client && git diff --exit-code libs/api-client` (stale generated client fails CI)                                    |
| `libs/db/prisma/**`                            | `bun run db:drift` (needs `bun run infra:up`)                                                                                     |
| API behaviour, RLS, transactions, outbox, seed | `bun run test:integration` — needs Docker; if Docker isn't running, say so and list it as not run                                 |
| `apps/driver-app`                              | `cd apps/driver-app && dart format --output=none --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test` |
| `apps/driver-app/web/**` or build config       | `cd apps/driver-app && flutter build web`                                                                                         |

Report each as pass / fail (with the first relevant error lines) / not run
(and why). A failing check is always a finding.

## Step 4 — Review by dimension, in parallel

Spawn one Agent per dimension that the diff touches, **in a single
message**, each with the diff range, the changed files for its area, and
its checklist below. Each returns findings as
`{severity, file, line, title, standard, why, fix}`. For a small diff
(< ~300 lines, one area) review yourself instead of spawning.

### A. API, domain and data (apps/api, apps/workers, libs/domain, libs/db, libs/contracts)

- **Layering:** controller has no logic (binds `@Route(r.x)`, `@Input()`,
  calls one service method); the service opens the transaction; repositories
  use the given `TenantTx`; business rules live in `libs/domain` as pure
  functions, not in services.
- **Tenancy:** org data only inside `db.tenant(orgId, …)`; `db.system(…)`
  only for genuinely cross-org work, with a comment saying why; no queries
  that rely on app-side `where orgId` instead of RLS.
- **Migrations:** every new org-scoped table has `ENABLE ROW LEVEL SECURITY`
  and the `tenant_isolation` policy (pattern:
  `libs/db/prisma/migrations/20261013000000_document_files/migration.sql`),
  plus grants. Generated SQL must not drop objects Prisma doesn't model
  (partitions, exclusion constraints, CHECKs, RLS policies, functions).
  Enum `ADD VALUE` in its own migration. Destructive changes (drop column,
  type change) have a backfill/compat story.
- **Errors:** `AppError(code, message, details?)`; anything else is a 500.
  "Record and fail" commits in its own transaction, then throws. New error
  codes are in the contract.
- **Side effects:** external calls (SMS, S3 writes for other purposes,
  HTTP) never inside a transaction; they go through
  `publish(tx, topic, …)` + an **idempotent** `@OnJob(topic)` handler.
- **Contracts:** Zod contracts in `libs/contracts` are the source of
  truth; responses go through the contract (no hand-built JSON that bypasses
  it); commands that need it declare `Idempotency-Key`; access level
  (`public`/`staff`/`anyMember`/roles) is right — a new `public` route gets
  extra scrutiny (data minimisation, rate limit, same 404 for unknown/expired).
- **Money/time:** integer paise (`bigint` in DB, `number` in code), never
  floats or rupees; UTC everywhere, IST only via `istBusinessDate` / display.
- **TypeScript:** strict, no `any`, no non-null `!` papering over
  `noUncheckedIndexedAccess`; `Patch<T>` + `definedOnly()` for partial
  updates; ESM imports with `.js`; a package imports only what its own
  `package.json` lists (Bun isolated installs).
- **Domain tests:** rule changes come with table-driven tests; a trip state
  machine change regenerates `libs/domain/fixtures/trip-transitions.json`
  (the Dart port is tested against it).
- **Security:** authz on every route (roles, own-trip checks for drivers),
  input limits, no secrets or PII in logs, rate limits on anything
  unauthenticated or OTP-like.

### B. Flutter app (apps/driver-app)

- **Strings:** every user-visible string via `context.l10n`; each new key in
  **both** `app_en.arb` and `app_hi.arb` with a real Hindi translation (not
  English copied); placeholders/plurals match; generated
  `app_localizations*.dart` regenerated and committed.
- **Modes:** owner mode is online-first (loading / error / retry states,
  pull-to-refresh); driver mode is offline-first — writes go through the
  drift outbox and `SyncEngine`, idempotency keys reused on retry, nothing
  that silently needs the network. Switching fleets must stay refused while
  anything is unsynced.
- **Layouts:** works on phone (bottom nav), tablet (rail) and desktop
  (≥1100 px, `DesktopOwnerShell`); desktop-only UI gated by
  `isDesktop(context)`; shared `DesktopTable` / `CardGrid` / `PageAction`
  reused; no overflow at 360 px.
- **State:** Riverpod providers, no API calls from widgets directly;
  providers disposed/invalidated correctly; no `setState` after dispose.
- **API models:** hand-written Dart models in `lib/core/api/` match the
  contract change (field names, nullability) with parsing tests.
- **Generated code:** `database.g.dart` / l10n regenerated, not hand-edited.
- **Web:** anything under `web/` escapes data (`textContent`, not
  `innerHTML`), pins script versions, works without the Flutter app.

### C. Tests, docs and delivery

- Each behaviour change has tests at the right level: domain → table tests;
  API → unit + integration (RLS, transactions, outbox, idempotency); app →
  widget tests via `Harness` and fakes in `test/support/`, English **and**
  Hindi for new screens (`test/l10n_test.dart`).
- Tests assert behaviour, not implementation; no `skip`/`only` left behind;
  no sleeps where a fake clock exists.
- Seed changes keep `docs/usage/demo-data.md` and `seed.int.test.ts` in step.
- New env vars are in `apps/api/src/platform/config.ts`, `render.yaml`
  (`sync: false` for secrets) and `docs/deployment.md`.
- Decisions that change behaviour have a `docs/decisions.md` row; plan
  acceptance checks are met (if a plan exists).
- Commits are Conventional Commits; user-facing text says **Fleet Sarthi**
  while identifiers keep `taxcy` (`@taxcy/*`, `taxcy_driver`) — renaming
  identifiers is a finding.

## Step 5 — Verify before reporting

For every candidate finding, open the file at the cited line and confirm:

- it's real in the head revision (not fixed later in the diff);
- the standard it cites actually says that (quote CLAUDE.md / decision /
  plan line when possible);
- the failure scenario is concrete ("a manager calling PUT … gets 200 and
  changes the pay rule").

Drop anything you can't confirm, or list it under "Questions" instead.

## Step 6 — Report

Reply in chat (no file unless asked), in this shape:

```markdown
## Review: <PR #N | branch | range> — <one-line verdict: Ready / Ready after fixes / Needs work>

**Scope:** <n> commits, <files> files (+a −d) · areas: api, contracts, app…
**Spec:** docs/plans/<file>.md (or "no plan found")

### Checks

| Check | Result |
| format:check | ✅ |
| lint/typecheck/test (TS) | ❌ `apps/api/src/…:42` … |
| api-client fresh | ✅ |
| db:drift | not run — Docker isn't running |
| flutter analyze / test | ✅ 306 passed |

### Blockers (must fix before merge)

1. **<title>** — `path/to/file.ts:123`
   Breaks: <standard, quoted or cited>.
   Why it matters: <concrete failure>.
   Fix: <specific change>.

### Should fix

…

### Nits (optional)

…

### Questions

…

### Good

- <1–3 things done well, briefly>
```

Severity guide:

- **Blocker:** security or tenancy leak, data loss, migration that drops
  RLS/constraints, broken offline sync, failing CI check, contract/client
  drift, missing Hindi for shipped UI, wrong money/time handling.
- **Should fix:** missing tests for new behaviour, layering violations,
  missing error states, decision not recorded, docs/seed out of step.
- **Nit:** naming, small readability; keep these few.

End with one line offering next steps: "Want me to fix the blockers?" Don't
fix anything until the user says so. If you created a `review/pr-N` branch,
mention it (and that it can be deleted with `git branch -D review/pr-N`).
