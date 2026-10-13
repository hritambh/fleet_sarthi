---
name: plan-feature
description: Brainstorm, research, and produce a design and step-by-step implementation plan for a Fleet Sarthi feature or change, before any code is written. Use when the user says "plan", "design", "brainstorm", "how should we build", "research how to", "spec out", or describes a feature idea and wants options. Ends with a plan document and a stop for approval — it does not implement.
argument-hint: <feature idea or problem, in a sentence or two>
---

# Plan a feature: brainstorm → research → design → implementation plan

You are acting as the tech lead for Fleet Sarthi (code name taxcy). Your output
is a decision-ready plan the user can approve, change, or reject — not code.
Do not edit source files during this skill. The only file you write is the plan.

Work through the five phases in order. Keep the user informed with one short
line per phase ("Researching the trips module and settlement rules…").

---

## Phase 0 — Frame the problem (2 minutes, not 20)

1. Restate the request in one sentence as an outcome for a person:
   _"An owner can see which cab is burning extra fuel this week without opening each vehicle."_
2. Name who it's for — **owner**, **manager**, **driver**, or a DCO (drives in
   one fleet, owns another) — and where: phone, tablet, desktop (≥1100 px),
   online or offline (driver mode must work offline).
3. Write down what "done" looks like as 3–5 acceptance checks.
4. Ask questions **only** if the answer changes the design and can't be found
   in the repo or docs. At most 3, via AskUserQuestion, each with a
   recommended option first. Otherwise state your assumption and move on.

## Phase 1 — Brainstorm options

Produce **3 distinct approaches**, always including:

- **The smallest thing that works** (often: reuse an existing screen, table, or job).
- **The "proper" version** (new model/flow, built to last).
- **One lateral idea** (a different product angle: an alert instead of a
  screen, a scheduled job instead of a button, a WhatsApp/SMS nudge, a
  default instead of a setting).

For each: one-paragraph sketch, what it touches (API / domain / DB / app /
jobs), effort (S ≤1 day, M ≤3 days, L >3 days), and the main risk.

Then pick one and say why in two sentences. The user can override.

## Phase 2 — Research

Run codebase and external research **in parallel**.

### Codebase (always)

Spawn Explore agents in a single message (medium thoroughness), each with
one question, for example:

- "Which API module, services, and contracts already handle <area>? List
  files, key functions, and the Prisma models they use."
- "What does the Flutter app have for <area>? Screens, providers,
  repositories, desktop variants, l10n keys."
- "What domain rules in libs/domain relate to <area>, and their tests?"

Read these yourself (they're short and decisive):

- `CLAUDE.md` — layering, tenancy, conventions.
- `docs/decisions.md` — prior decisions (D1, D2, …). Never contradict one
  silently; if the plan needs to change one, say so and propose a new D-row.
- `docs/roadmap.md` — whether this is already planned, and where it fits.
- The relevant `docs/domain/*.md` (fuel-audit, settlement, telemetry, evidence).
- `libs/db/prisma/schema.prisma` for the models involved.

Every claim about existing code must cite `path:line`. If you didn't read
it, don't claim it.

### External (when the feature touches the outside world or a known problem)

Use WebSearch (standard first, extended for niche or recent topics) for:

- Libraries that already solve it **within the stack** (NestJS, Prisma, Zod,
  BullMQ, Flutter, Riverpod, drift). Prefer maintained, popular, licence-compatible.
- Indian context where relevant: SMS/OTP providers and DLT rules, UPI and
  payment rails, fuel types (CNG, petrol-CNG), RTO/permit documents, GST on
  trips, Maps/geocoding costs.
- How comparable fleet/cab apps handle it (patterns, not copying).

Cite each finding with a link and its date. Flag anything older than 2 years
or unverified.

## Phase 3 — Design

Cover each layer. Write "No change" where nothing changes, so the reader knows
it was considered.

1. **User flows** — step by step per role and form factor. Note the empty,
   loading, error, offline, and permission-denied states.
2. **Domain rules** (`libs/domain`) — the pure rules as functions with
   signatures, plus a table of example inputs → outputs that will become the
   table-driven tests. Money in **integer paise**; time in **UTC**, IST only
   for display and business dates (`istBusinessDate`).
3. **Data model** (`libs/db/prisma/schema.prisma`) — new and changed models,
   columns, indexes. List what Prisma can't express and must go in the
   hand-written migration: **RLS policy for every org-scoped table**,
   CHECKs, partial or exclusion indexes, partitions.
4. **Contracts** (`libs/contracts`) — each route: method, path, Zod input and
   output, error codes (`AppError` codes), the roles allowed, and whether it
   needs an `Idempotency-Key`.
5. **API** (`apps/api/src/modules/<area>`) — controller (no logic) → service
   (opens the transaction inside `db.tenant`) → Prisma on `TenantTx` →
   domain. Side effects after commit go through `publish(tx, topic, …)` and an
   idempotent `@OnJob(topic)` handler. Name the topics.
6. **App** (`apps/driver-app`) — screens and widgets per layout (phone /
   rail / `DesktopOwnerShell`), providers, the `OwnerApi` or `TaxcyApi`
   methods, hand-written Dart models to update. For driver mode: drift
   tables, the outbox command, sync and conflict behaviour. New l10n keys,
   listed in both English and Hindi.
7. **Security and tenancy** — who can read and write what; how RLS and the
   membership guard enforce it; abuse cases (rate limits, enumeration, leaking
   another org's data).
8. **Failure modes** — retries, duplicate taps, partial failures, clock skew,
   offline replays, provider outages, and what the user sees for each.
9. **Data, seed, and docs** — seed changes (`apps/api/src/seed/seed.ts`; keep
   `docs/usage/demo-data.md` and `seed.int.test.ts` in step), backfills, and
   which docs change.
10. **Decisions** — new rows for `docs/decisions.md` in its format
    (`| D<n> | Question | Decision | Consequences |`), marked _proposed_.

Use a small mermaid diagram only where a flow or state machine is clearer as a
picture.

## Phase 4 — Implementation plan

Break the work into **vertical slices**, each shippable and testable on its
own, in dependency order. Typical order: domain → schema/migration → contracts
(+ `bun run api:client`) → API service and tests → app models and providers →
UI → seed and docs.

For each step:

```
### Step N — <outcome, not activity>
Files: path/a.ts (new), path/b.dart (edit: <what>)
Change: 2–4 bullets, concrete.
Tests: which test files, and the cases (table rows, widget checks, int tests for RLS/outbox).
Verify: exact commands, e.g.
  cd apps/api && bunx vitest run src/modules/<area>/<file>.test.ts
  bun run test:integration   # if RLS, transactions, or the outbox changed
  cd apps/driver-app && flutter analyze --fatal-infos && flutter test test/<file>.dart
Commit: feat(<scope>): <message>   (Conventional Commits)
Size: S / M / L
```

Finish the plan with:

- **Risks and mitigations** — the top 3–5.
- **Out of scope** — explicitly deferred items.
- **Open questions** — each with your recommended answer.
- **Done when** — Phase 0's acceptance checks, plus `bun run verify` and
  `flutter test` green, and a manual check on the screen sizes involved.

## Phase 5 — Deliver and stop

1. Write the plan to `docs/plans/YYYY-MM-DD-<kebab-slug>.md` (today's date),
   using the outline below. Create `docs/plans/` if it doesn't exist.
2. Reply in chat with: the chosen approach in two sentences, the step list
   (titles and sizes only), the open questions, and the plan's path.
3. **Stop.** Don't implement until the user approves. If they approve, work
   step by step, committing per step only when they ask.

### Plan document outline

```markdown
# <Feature name>

Status: proposed · Date: YYYY-MM-DD · Owner: <user>

## Problem and outcome

## Who and where

## Acceptance checks

## Options considered

| Option | Sketch | Touches | Effort | Main risk |

## Chosen approach and why

## Research findings

(codebase findings with path:line; external findings with links and dates)

## Design

### User flows

### Domain rules

### Data model and migration

### Contracts

### API

### App

### Security and tenancy

### Failure modes

### Seed and docs

### Proposed decisions

## Implementation plan

### Step 1 — …

## Risks and mitigations

## Out of scope

## Open questions

## Done when
```

---

## Quality bar (check before delivering)

- [ ] Every existing-code claim has a `path:line` and was actually read.
- [ ] No invented APIs, tables, or env vars; new ones are clearly marked new.
- [ ] Money in paise, times in UTC, IST only for display and business dates.
- [ ] Every org-scoped table has an RLS policy in the plan; cross-org work uses `db.system` and says why.
- [ ] Driver-mode changes work offline or say plainly that they don't.
- [ ] Every new UI string is listed in English **and** Hindi.
- [ ] Contract changes include `bun run api:client` and the Dart model updates.
- [ ] Each step has tests and an exact verify command.
- [ ] No conflict with `docs/decisions.md`, or a proposed D-row explains the change.
- [ ] The plan is something a teammate could pick up without this conversation.
