# Settings hub

Status: done · Date: 2026-10-16 · Owner: Hritambh Hritvij

## Problem and outcome

Settings today is a single page holding five things: language, account
security, fuel/odometer audit thresholds, the default driver pay rule and the
managers list (`apps/driver-app/lib/features/owner/settings_screen.dart`).
Nothing explains what a threshold changes, there is no way to rename the
fleet, and the few real operating rules a fleet owner would want to choose are
hardcoded.

**Outcome:** a Settings hub with one page per category. Every setting says what
it does, which part of the app it affects, and whether it changes existing
records or only what happens next. Every control is saved per fleet and
enforced by the API, not just the screen.

## Scope: what is in, and why the rest is not

The brief proposed eleven categories. This plan keeps only the ones that map to
something Fleet Sarthi actually does, so no control is decorative.

| Category                                    | In  | Settings                                                                                                                                                                                           |
| ------------------------------------------- | --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| General                                     | yes | Fleet name (**new**)                                                                                                                                                                               |
| Trips & drivers                             | yes | Drivers can create their own trips (**new**); drivers can add charges (**new**); odometer-vs-GPS tolerance (moved)                                                                                 |
| Fuel audit                                  | yes | Fuel receipt photo required (**new**); kσ, minimum cycles, percent drop, smoothing (moved), with reset to defaults                                                                                 |
| Documents & reminders                       | yes | Reminder days before expiry (moved), with reset to defaults                                                                                                                                        |
| Driver pay                                  | yes | Default pay rule (moved)                                                                                                                                                                           |
| Team & roles                                | yes | Managers (moved), plus a table of what each role can do                                                                                                                                            |
| You                                         | yes | Language, account security (moved)                                                                                                                                                                 |
| Maintenance                                 | no  | There is no maintenance module (no service records, intervals or reminders).                                                                                                                       |
| Expense / income categories                 | no  | Charge kinds and collection methods are fixed enums used by settlement math (`libs/domain/src/settlement`); making them custom needs a settlement redesign.                                        |
| Currency, units, date format, time zone     | no  | Money is INR paise and business dates are IST throughout (CLAUDE.md conventions); a switch would be decorative.                                                                                    |
| Email / push notifications                  | no  | No email or push channel exists; reminders are in-app alerts (D-roadmap "Later").                                                                                                                  |
| Custom fields                               | no  | Needs a typed field store, contracts and every form, list, detail and report to render them; a feature of its own.                                                                                 |
| Data export, fleet deletion                 | no  | No export or deletion exists; deletion must handle settled money and RLS-scoped history safely. Its own plan.                                                                                      |
| Required documents, odometer photo optional | no  | Odometer photos anchor the audit (evidence, OCR, GPS check); making them optional weakens the product's core promise. Required-document rules need an assignment-time document check; a follow-up. |

## Design

### Settings, effects and scope

| Setting                            | Default                | Who changes | Enforced in                                                                               | Applies to                                                       |
| ---------------------------------- | ---------------------- | ----------- | ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| Fleet name                         | (set at creation)      | owner       | `PATCH /orgs/current`                                                                     | Everywhere the name shows, immediately; history unchanged        |
| Drivers can create their own trips | on                     | owner       | `TripsService.create` → `DRIVER_TRIPS_DISABLED`; driver app hides **New trip**            | New trips only; existing trips untouched                         |
| Drivers can add charges            | on                     | owner       | `TripsService.addCharge` → `DRIVER_CHARGES_DISABLED`; driver app hides **Add charge**     | New charges only; existing charges and settlements untouched     |
| Fuel receipt photo required        | on                     | owner       | `FuelService.create` → `RECEIPT_REQUIRED`; driver app makes the receipt optional when off | New fills only                                                   |
| Odometer-vs-GPS tolerance          | 10%                    | owner       | Distance check (`telemetry.service.ts`)                                                   | Checks run after saving; past verdicts stay                      |
| Fuel audit thresholds              | 2σ, 3 cycles, 20%, 0.3 | owner       | Fuel audit (`fuel-audit.service.ts`)                                                      | Next recompute of each vehicle (its next fill); past alerts stay |
| Reminder days                      | 30, 7, 1               | owner       | Daily expiry job (`document-expiry.job.ts`)                                               | Next daily run                                                   |
| Default driver pay                 | none                   | owner       | Settlements (`settlements.service.ts`)                                                    | Days not yet settled; settled days are frozen                    |

Managers see every page read-only (the API already returns `FORBIDDEN_ROLE`);
drivers see none of it, but read the three driver rules.

### Data model

Three columns on `org_settings` (already RLS-scoped by `tenant_isolation`), so
no new table or policy:

```prisma
driversCanCreateTrips Boolean @default(true) @map("drivers_can_create_trips")
driversCanAddCharges  Boolean @default(true) @map("drivers_can_add_charges")
fuelReceiptRequired   Boolean @default(true) @map("fuel_receipt_required")
```

Migration `20261016100000_workflow_settings`. Existing fleets get the
defaults, which match today's behaviour (the app already required a receipt).

### Contracts (`libs/contracts/src/routes/fleet.ts`, `identity.ts`)

| Route                      | Access     | Body / result                                                    |
| -------------------------- | ---------- | ---------------------------------------------------------------- |
| `GET /settings/workflow`   | any member | `WorkflowSettings`                                               |
| `PATCH /settings/workflow` | owner      | `WorkflowSettings.partial()` → `WorkflowSettings`                |
| `GET /orgs/current`        | staff      | `OrgProfile { id, name, kind }`                                  |
| `PATCH /orgs/current`      | owner      | `{ name }` (2–100 chars, trimmed, as at creation) → `OrgProfile` |

New error codes: `DRIVER_TRIPS_DISABLED`, `DRIVER_CHARGES_DISABLED`,
`RECEIPT_REQUIRED` (403, 403, 422).

### App

- `SettingsScreen` becomes the hub: category cards (icon, title, one-line
  description), grouped **Fleet** and **You**. Phones push a page; the desktop
  pushes inside the Settings section's navigator.
- Each page uses one `SettingTile` pattern: name, plain explanation, an
  "Affects" line and an "Applies to" line, then the control.
- Pages with edits have Save and Cancel, an unsaved-changes guard
  (`PopScope`, the pattern from `DocumentFormScreen`) and, where defaults
  exist, Reset to defaults (which only fills the form; Save still applies it).
- Driver mode reads the rules through `TaxcyApi.workflowSettings()`, keeps the
  last copy in `SharedPreferences` for offline use, and falls back to the
  defaults before the first fetch. The API is the authority: a queued action
  refused after a rule change lands in the outbox's **needs attention** state
  with the reason.

## Failure modes

| Failure                                   | What happens                                                                    |
| ----------------------------------------- | ------------------------------------------------------------------------------- |
| Manager opens a page                      | Read-only controls, a banner saying only the owner can change it                |
| Save fails (offline, 5xx)                 | Snackbar error, form keeps the edits                                            |
| Invalid value                             | Error under the field; Save does nothing                                        |
| Leaving with unsaved edits                | "Discard changes?" dialog                                                       |
| Rule turned off while a driver is offline | Their queued trip/charge is refused on sync and shown as needing attention      |
| Driver app never fetched the rules        | Defaults (all allowed, receipt required); the API still enforces the real value |

## Tests

- API integration (`apps/api/test/settings.int.test.ts`): defaults, owner
  updates, manager 403, driver reads, each rule enforced (create trip, add
  charge, fuel fill), fleet rename and validation.
- App: hub navigation, each page's save/reset/discard, manager read-only,
  driver New trip / Add charge hidden, receipt optional, models round-trip,
  no overflow at 360 px in English and Hindi, desktop layout.

## Docs

`docs/usage/owner-guide.md` (Settings section), `docs/usage/api.md`
(routes), `docs/database.md` (columns), `docs/decisions.md` (D26: which
settings exist and why the rest are out).

## Implementation notes

- `SettingsService` moved into its own `SettingsModule` (`apps/api/src/modules/fleet/settings.module.ts`): `FleetModule` imports `TripsModule`, so trips couldn't import fleet without a cycle. `FleetModule` re-exports it, so fuel, telemetry and money are unchanged.
- The driver-charges check sits in `TripsService.insertCharges`, so it covers both `POST /trips/{id}/charges` and charges sent with **end trip**.
- The receipt check runs after the idempotent replay and the vehicle/fuel-type checks, so a replay of a fill that already reached the server still succeeds and a wrong fuel still reports `FUEL_TYPE_MISMATCH`.
- A create replay (same trip id, same user) returns the existing trip even after drivers' trips are turned off.
- Three existing integration tests recorded fills without a receipt; they now attach one, as the app and the seed always did.
- App: `lib/features/owner/settings_screen.dart` (hub), `settings/settings_pages.dart` (pages), `settings/settings_widgets.dart` (`SettingsScaffold`, `SettingTile`, `SettingSwitch`, `NumberSetting`), `lib/app/workflow_settings.dart` (rules for driver mode, cached per fleet in `SharedPreferences`).
- Tests: `apps/api/test/settings.int.test.ts` (8), `apps/driver-app/test/settings_test.dart` (15), model tests in `owner_models_test.dart`; six existing tests moved to the new pages.
