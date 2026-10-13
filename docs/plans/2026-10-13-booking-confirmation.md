# Share a booking confirmation

Status: proposed · Date: 2026-10-13 · Owner: Hritambh Hritvij

## Problem and outcome

Owners confirm bookings by typing details into WhatsApp by hand, and today's
"Copy / WhatsApp" buttons send only a bare summary with no fleet name, contact or
terms. **Outcome:** an owner or manager taps _Share booking_ on a trip and the
customer gets a WhatsApp message (or a PDF) with the booking, cab, driver,
fare and terms. The message includes a link to a live booking page that
always shows the current cab and driver, even after a reassignment.

## Who and where

- **Who shares:** owner and manager (staff). Drivers don't share in v1.
- **Who receives:** the customer. They need no app or account; they get a
  WhatsApp message, a web page, or a PDF.
- **Where:** owner mode on phone, tablet and desktop (≥1100 px). Owner mode is
  online-first (D12), so sharing needs a connection. The public page runs in
  any mobile browser.
- **Settings:** owners edit the booking terms; managers see them read-only,
  like the other settings (D11).

## Acceptance checks

1. On an assigned trip, _Share on WhatsApp_ opens WhatsApp to the customer's
   number with a message that has: the "Booking confirmed" heading and
   reference, the fleet name and contact, pickup and drop, date and time, cab
   (model, number, fuel), driver (name, phone), fare with included km, the key
   terms, and the live link.
2. Opening the link on a phone shows the same booking, with the driver's and
   cab's documents as "verified" badges (status only, no images or numbers),
   the full terms, and "This is not a tax invoice". After the owner reassigns
   the driver, a refresh shows the new driver.
3. Sharing is offered only for _created_ ("Booking received"), _assigned_
   ("Booking confirmed") and _started_ ("Trip in progress") trips. Ended,
   settled and cancelled trips can't be shared. Their link shows "completed"
   or "cancelled" for 7 or 2 days, then stops working.
4. _Share as PDF_ produces a one-page A4 PDF of the same confirmation, correct
   in English and Hindi, that can be sent through the system share sheet
   (Android) or downloaded (web).
5. An owner can set extra-km, extra-hour, allowance, night, waiting, tolls,
   GST, contact number and cancellation terms once in Settings. A trip can
   override the extra-km rate.

## Options considered

| Option                                    | Sketch                                                                                                                                                          | Touches                                                                                        | Effort      | Main risk                                                                                                    |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------ |
| A. Better message only                    | Rewrite `tripShareText` into a formatted WhatsApp message with fleet contact and terms; add a booking-terms setting.                                            | App, contracts and API (settings)                                                              | S–M         | The message goes stale when the cab or driver changes, and there's no "verified documents" view.             |
| **B. Message + live link (+ PDF option)** | The message as in A, plus a revocable public link to a lightweight booking page that reads a minimal, public-safe view. The PDF is rendered from the same view. | Domain, DB (new table, settings column, one trip column), contracts, API, app, static web page | L (~6 days) | A public endpoint: the data it shows, enumeration, the cost of the free-tier cold start.                     |
| C. Automatic WhatsApp updates             | Send the confirmation automatically from a WhatsApp Business number on assign or reassign and 2 h before pickup (the industry norm), through the outbox.        | API, jobs, provider integration                                                                | L+          | A paid provider, template approval, and opt-in. The roadmap parks this under "Later" (`docs/roadmap.md:59`). |

## Chosen approach and why

**B**, which you chose on 2026-10-13: a WhatsApp message with a live link,
showing documents as **status only**, plus **PDF** as a secondary option. The
link fixes A's staleness at its root, and the plan's models and routes leave
room for C later (an outbox handler could send the same view).

## Research findings

### Codebase

- **Existing share:**
  - `apps/driver-app/lib/features/owner/trips/trip_share.dart:22-44` builds plain text (heading, customer, pickup, drop, time, cab, driver and phone, fare and km).
  - `:48-51` builds a `wa.me` link; `:54-103` has the Copy and WhatsApp buttons.
  - It is used only at `owner_trip_detail_screen.dart:143` and shown **for every status**.
  - It has no fleet name, contact, terms or link. The driver's phone comes from `driversProvider`.
- **Trip states:**
  - `created | assigned | started | ended | settled | cancelled` (`libs/domain/src/trips/state-machine.ts:1`).
  - A pending cancellation is a flag, not a state (`state-machine.ts:66-69`).
- **Trip data:**
  - Pickup and drop text and points, schedule, `quotedFarePaise`, `includedKm` ("beyond it, extra km is chargeable", `libs/db/prisma/schema.prisma:430`), vehicle, driver.
  - The `Trip` contract (`libs/contracts/src/routes/trips.ts:126-157`) has the vehicle as `{id, registrationNo, model}` and the driver as `{id, name}`. It has no make, fuel type or driver phone.
- **No customer rate card:**
  - Charge kinds `toll, parking, state_tax, driver_allowance, night_charge, extra_km, other` are only ad-hoc amounts entered on a trip (`trips.ts:30-38`).
  - The only rates are driver _pay_ rules (`schema.prisma:156`, `fleet.ts:54-67`).
  - A "rate-card fare engine" is parked under "Later" (`docs/roadmap.md:62`).
- **Organization:**
  - It has only `name, kind, timezone` (`schema.prisma:134-146`).
  - `OrgSettings` holds only audit thresholds and the pay rule (`schema.prisma:148-160`).
  - There's no phone, address, GSTIN or terms, and no route to edit the org profile.
- **Documents:**
  - `rc, insurance, permit, puc, driving_licence` with `expiresOn` and supersession (`schema.prisma:89-97, 346-364`).
  - Multiple files per document since `5ffe019` (`document_files`, `schema.prisma:366-378`).
  - Media URLs are presigned for 5 minutes (`apps/api/src/modules/media/media.service.ts:156`). Not needed here: we show status only.
- **Public routes:**
  - `AuthGuard` lets a contract with `access.kind === 'public'` through without a token (`apps/api/src/platform/http/auth.guard.ts:23`).
  - Today only `/auth/*` and health are public.
  - Responses are always JSON, encoded through the contract (`response.interceptor.ts`). There's no HTML route.
  - A public route has no org, so it must look the org up (`db.system`, `apps/api/src/platform/prisma.service.ts:29`) before `db.tenant`.
- **RLS pattern:** `CREATE POLICY tenant_isolation … USING (org_id = NULLIF(current_setting('app.org_id', true), '')::uuid OR current_setting('app.bypass_rls', true) = 'on')` (`libs/db/prisma/migrations/20261013000000_document_files/migration.sql:22-24`).
- **Rate limiting:** `RateLimiter` (`apps/api/src/platform/rate-limit.ts:14`) is provided only in `IdentityModule` (`identity.module.ts:18`).
- **Static web pages:**
  - `apps/driver-app/web/phone-otp.html` is a standalone page published with the Flutter build.
  - Render serves real files before its `/* → /index.html` rewrite (`render.yaml:126-130`), and the web build runs `infra/render/build-web.sh` (`render.yaml:119`).
- **App dependencies:** `url_launcher` is present; `share_plus` and `pdf` are absent (`apps/driver-app/pubspec.yaml`).
- **Existing l10n keys:** `shareTripHeading … whatsAppUnavailable` (`app_en.arb:2257-2290`).

### External (checked 2026-10-13)

- **What confirmations contain:** Indian operators list included km, extra km
  and hour rates, driver allowance (₹250–500/day), a night charge for 10 PM–6 AM,
  tolls, parking and state tax "at actuals", garage-to-garage counting, waiting
  slabs, AC off in hills, GST, and the cancellation window.
  - Savaari route pages (undated): https://www.savaari.com/hyderabad/hyderabad-to-hubli-cabs
  - Quick Ride (undated): https://quickride.in/outstation-taxi.php
  - MakeMyTrip city pages (undated boilerplate): https://www.makemytrip.com/car-rental/itarsi-city-cabs.html
  - eUttaranchal (2026): https://www.euttaranchal.com/tourism/gairsain-bus-car-taxi-hire.php
  - Official T&C pages didn't render or weren't found; these are route pages and secondary copies. _Unverified as legal wording._
- **Driver and cab details:** operators share the driver's name, phone and vehicle
  number, usually ~2 h before pickup. None share licence, RC, insurance or permit
  images. Sources (undated): https://www.intercitycab.in/faq/outstation_taxi.php, https://arohicabs.com/cab-booking-FAQ.aspx
- **MoRTH Motor Vehicle Aggregator Guidelines 2025 (July 2025):**
  - Passengers keep the driver's contact for **7 days after the trip**.
  - The licence and permit are displayed _in the vehicle_.
  - Passenger data falls under DPDP.
  - The rules target aggregators, so a small direct-booking fleet is likely
    outside them, but they're a sensible baseline.
  - Sources: https://morth.gov.in/sites/default/files/circulars_document/MV-Aggregators-Guidelines-2025%20-%20English%20and%20Hindi.pdf ; summary: https://www.medianama.com/2025/07/223-motor-vehicles-aggregator-guidelines-2025/
  - _The clause text wasn't read; points are from the summary._
- **DPDP Rules:** notified 13–14 Nov 2025, with notice and consent duties from about May 2027.
  - Sources: https://static.pib.gov.in/WriteReadData/specificdocs/documents/2025/nov/doc20251117695301.pdf (Nov 2025); https://www.azbpartners.com/bank/update-indias-digital-personal-data-protection-framework-comes-into-effect/ (Nov 2025)
  - Supports showing document **status only** and an option to show the office
    number instead of the driver's.
- **GST on rent-a-cab:** from 22 Sep 2025 it's 5% (limited ITC) or 18% (full ITC); the 12% option is gone. Many small owners aren't registered.
  - Sources: https://studycafe.in/gst-overhaul-2025-full-list-of-service-rate-changes-392308.html (4 Sep 2025, secondary; the CBIC notification wasn't fetched).
  - So: a per-fleet GST setting (none / 5 / 18, included or extra), an optional GSTIN, and "not a tax invoice".
- **WhatsApp:**
  - Formatting is `*bold*`, `_italic_`, lists and quotes (lists and quotes since Feb 2024): https://alternativeto.net/news/2024/2/whatsapp-introduces-four-new-advanced-text-formatting-features
  - Link previews read Open Graph tags (og:image under ~300 KB): https://andrewbaker.ninja/2026/03/05/fix-thumbnail-previews-on-whatsapp-linkedin-x-guide/ (Mar 2026)
  - Keep messages under ~1,000 characters.
- **Flutter packages (pub.dev, Oct 2026):**
  - `pdf` 3.13.1 works on every platform, but **doesn't shape Devanagari** (conjuncts and matras break). Issues https://github.com/DavBfr/dart_pdf/issues/1100 and #198 (the latter over 2 years old).
  - `share_plus` 13.3.1 (`SharePlus.instance.share(ShareParams(...))`) uses the Web Share API on web and falls back to a download.

## Design

### Which states can be shared

| Trip status                            | Stage shown to the customer                                         | Share in app?      | Public link                                                                                                       |
| -------------------------------------- | ------------------------------------------------------------------- | ------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `created`                              | **Booking received**: "Cab and driver will be shared before pickup" | Yes                | Live; fills in when assigned                                                                                      |
| `assigned`                             | **Booking confirmed**                                               | Yes (main case)    | Live                                                                                                              |
| `started` (incl. cancellation pending) | **Trip in progress**                                                | Yes                | Live                                                                                                              |
| `ended`, `settled`                     | —                                                                   | No (button hidden) | "Trip completed on …", driver contact kept **7 days after the end** (MoRTH baseline), then the link stops working |
| `cancelled`                            | —                                                                   | No                 | "This booking was cancelled", for 2 days, then the link stops working                                             |

A trip summary or receipt after the trip is out of scope (see below).

### User flows

**Owner or manager, sharing (phone, tablet and desktop):**

1. Open a trip. Where the Copy / WhatsApp buttons used to be, a **Share
   booking** card shows the stage chip ("Booking confirmed") and a language
   toggle (_English_ / _हिंदी_, defaulting to English).
2. Warnings appear before sharing, without blocking it:
   - No customer phone: "WhatsApp will ask whom to send to."
   - Driver or cab documents not valid on the trip date: "Insurance isn't
     valid on the trip date; the customer won't see it as verified."
   - _created_ stage: "Cab and driver aren't assigned yet; the link will show
     them once you assign."
3. Buttons:
   - **Share on WhatsApp** (primary, green).
   - **Copy message**.
   - **Copy link**.
   - An overflow menu with **Share as PDF**, **Open booking page** and
     **Reset link** (the confirm dialog says "The old link stops working").
4. The first tap creates the link (or reuses the trip's active one), then
   fetches the public view, so the message and PDF use exactly what the
   customer will see. The buttons show a spinner while this runs.
5. **States:**
   - **Loading:** a spinner inside the button; the other buttons are disabled.
   - **Offline or error:** a snackbar with the error text and a retry.
   - **Permission denied:** a driver never sees the card. The API returns
     `FORBIDDEN_ROLE` anyway.

**Owner, settings:** a new **Booking confirmation** section in Settings, with
these fields:

- Booking contact number
- Show the driver's number to customers (on by default)
- GST: none / 5% / 18%, included or extra, and an optional GSTIN
- Extra km rate and extra hour rate
- Driver allowance per day
- Night charge (10 PM–6 AM)
- Free waiting minutes and the waiting charge per 30 min
- Tolls, parking and state tax: included or extra at actuals
- Count km garage to garage
- Cancellation policy (free text)
- Other terms (up to 10 lines)

A live **preview** of the terms shows under the form. Managers see the
section read-only, with the existing `settingsOwnerOnly` note.

**Trip form:** an optional **Extra km rate** field, prefilled with the fleet
default, on create and edit.

**Customer, public page** (`/booking.html#t=<token>&l=en`):

1. A skeleton loads ("Loading your booking…"). The free-tier API can take up
   to about a minute to wake from sleep, so after 10 s the page explains this
   and keeps retrying.
2. Header: the fleet name, the stage chip, the reference (e.g. `FS-7K2Q9M`).
3. Cards:
   - **Trip:** pickup and drop, date and time (IST), type.
   - **Cab:** model, number, fuel type.
   - **Driver:** name, phone as a `tel:` link (or the fleet contact if that
     setting is off).
   - **Verified documents:** ✓ Driving licence, ✓ RC, ✓ Insurance, ✓ Permit,
     ✓ PUC, each with "valid till".
   - **Fare:** quoted fare, included km, GST line, paid so far.
   - **Terms:** the full list.
   - **Contact the fleet:** a `tel:` link and a WhatsApp link.
4. Footer: "This is a booking confirmation, not a tax invoice", "Updated
   <time>", and a **Print / Save as PDF** button (a print stylesheet).
5. **Unknown, expired or revoked link:** one message: "This booking link isn't
   available. Please contact your cab operator."

**Sample WhatsApp message (English, assigned):**

```
*Booking confirmed* · FS-7K2Q9M
*Sharma Travels* · +91 98220 11111

*Pickup:* Pune Station
*Drop:* Mumbai Airport T2
*When:* Tue, 14 Oct, 6:30 am
*Cab:* Toyota Innova Crysta · MH 12 AB 1234 (diesel)
*Driver:* Ramesh Kumar · +91 90000 00011
*Fare:* ₹3,500 incl. 150 km · 5% GST included

*Terms*
- Extra km ₹14/km, extra hour ₹150/hour
- Driver allowance ₹300/day; night charge ₹250 (10 pm–6 am)
- Tolls, parking and state tax extra, at actuals
- Free cancellation until 24 h before pickup

Latest details, documents and all terms:
https://taxcy-web.onrender.com/booking.html#t=…&l=en
```

### Domain rules (`libs/domain/src/bookings/`, new)

These are pure functions. Money is integer paise, and times are UTC Dates.
Business dates use `istBusinessDate`.

```ts
type BookingStage = 'received' | 'confirmed' | 'in_progress';
function bookingStage(status: TripStatus): BookingStage | null;

type BookingLinkState = 'live' | 'completed' | 'cancelled' | 'expired';
function bookingLinkState(
  t: { status: TripStatus; endedAt: Date | null; cancelledAt: Date | null },
  now: Date,
): BookingLinkState;

type TermLine =
  | { code: 'included_km'; km: number }
  | { code: 'extra_km'; paisePerKm: number }
  | { code: 'extra_hour'; paisePerHour: number }
  | { code: 'garage_to_garage' }
  | { code: 'driver_allowance'; paisePerDay: number }
  | { code: 'night_charge'; paise: number } // 10 PM–6 AM IST
  | { code: 'tolls'; mode: 'included' | 'extra' }
  | { code: 'waiting'; freeMinutes: number; paisePer30Min: number }
  | { code: 'gst'; percent: 5 | 18; included: boolean }
  | { code: 'cancellation'; text: string }
  | { code: 'custom'; text: string }
  | { code: 'not_tax_invoice' };
function bookingTerms(
  terms: BookingTerms,
  trip: { includedKm: number | null; extraKmRatePaise: number | null },
): TermLine[];

function gstBreakup(
  farePaise: number,
  percent: 0 | 5 | 18,
  included: boolean,
): { basePaise: number; gstPaise: number; totalPaise: number };

type DocBadge = { docType: DocType; validTill: string /* YYYY-MM-DD */ };
function verifiedDocuments(
  docs: { docType: DocType; expiresOn: string; superseded: boolean }[],
  tripDateIst: string,
): DocBadge[]; // only documents valid on the trip date; latest per type

function bookingReference(tripId: string): string; // 'FS-' + 6 Crockford base32 chars from the id's random tail
```

| Rule              | Input                                                      | Output                                                                                                                                           |
| ----------------- | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| bookingStage      | created / assigned / started / ended / settled / cancelled | received / confirmed / in_progress / null / null / null                                                                                          |
| bookingLinkState  | assigned, now                                              | live                                                                                                                                             |
| bookingLinkState  | ended 6 d 23 h ago                                         | completed                                                                                                                                        |
| bookingLinkState  | ended 7 d 1 min ago                                        | expired                                                                                                                                          |
| bookingLinkState  | cancelled 1 d ago / 2 d 1 min ago                          | cancelled / expired                                                                                                                              |
| bookingTerms      | trip `extraKmRatePaise` 1600, fleet 1400                   | `extra_km` 1600 (the trip overrides the fleet)                                                                                                   |
| bookingTerms      | `includedKm` null, no fleet rates set                      | only `tolls` (default extra) and `not_tax_invoice`                                                                                               |
| bookingTerms      | order                                                      | included_km, extra_km, extra_hour, garage_to_garage, driver_allowance, night_charge, tolls, waiting, gst, cancellation, custom…, not_tax_invoice |
| gstBreakup        | 350000, 5, included                                        | base 333333, gst 16667, total 350000 (GST rounded half-up; base = total − gst)                                                                   |
| gstBreakup        | 350000, 5, extra                                           | base 350000, gst 17500, total 367500                                                                                                             |
| gstBreakup        | 350000, 0, —                                               | gst 0                                                                                                                                            |
| verifiedDocuments | insurance expires the day before the trip                  | insurance omitted                                                                                                                                |
| verifiedDocuments | two RCs, one superseded                                    | only the current one                                                                                                                             |
| verifiedDocuments | expires on the trip date                                   | included (valid through `expiresOn`, IST)                                                                                                        |

`BookingTerms` (the Zod schema in contracts, also used by the domain), with
every field optional:

- `contactPhone` (E.164)
- `showDriverPhone` (default true)
- `gst`: `{ percent: 0|5|18, included: boolean }`
- `gstin`
- `extraKmPaise`, `extraHourPaise`, `driverAllowancePaisePerDay`, `nightChargePaise`
- `waiting`: `{ freeMinutes, paisePer30Min }`
- `tolls`: `'included' | 'extra'` (default extra)
- `garageToGarage` (default false)
- `cancellationText` (≤ 300 chars)
- `customTerms` (≤ 10 lines, each ≤ 200 chars)

Every amount in `BookingTerms` is non-negative.

### Data model and migration

Prisma changes (`libs/db/prisma/schema.prisma`):

- **`BookingLink` (new), table `booking_links`:**
  - Columns:
    - `id` uuid (v7)
    - `org_id` uuid → organizations
    - `trip_id` uuid → trips
    - `token` text (22-char base64url, 128 random bits), unique
    - `created_by` uuid → users
    - `created_at`
    - `revoked_at` nullable
  - Index on `trip_id`.
- **`OrgSettings.bookingTerms`:** new `Json @default("{}")` column
  (`booking_terms`), parsed with the Zod schema and its defaults.
- **`Trip.extraKmRatePaise`:** new `BigInt?` column (`extra_km_rate_paise`),
  the per-trip override.

Hand-written additions to the migration SQL:

- `ALTER TABLE booking_links ENABLE ROW LEVEL SECURITY` and the
  `tenant_isolation` policy (same as `document_files`), plus `GRANT` to
  `taxcy_api` as other tables do.
- A partial unique index: one active link per trip,
  `CREATE UNIQUE INDEX booking_links_active ON booking_links (trip_id) WHERE revoked_at IS NULL`.
- `CHECK (extra_km_rate_paise IS NULL OR extra_km_rate_paise >= 0)` on `trips`.
- `CHECK (length(token) = 22)`.

The token is stored in plain text, so the app can re-share the same link. It
grants only a read-only view of data already in the row's org, it is
revocable by rotation, and there's an open question on hashing.

### Contracts (`libs/contracts`)

| Route                                   | Method     | Access     | Input                                  | Output                                        | Errors                                                                                    | Idempotency                                                   |
| --------------------------------------- | ---------- | ---------- | -------------------------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `/settings/booking-terms`               | GET        | staff      | —                                      | `BookingTerms`                                | —                                                                                         | —                                                             |
| `/settings/booking-terms`               | PUT        | owner      | `BookingTerms`                         | `BookingTerms`                                | `VALIDATION`, `FORBIDDEN_ROLE`                                                            | not needed (PUT)                                              |
| `/trips/{id}/booking-link`              | POST       | staff      | —                                      | `{ url, token, reference, stage, createdAt }` | `NOT_FOUND`, `BOOKING_NOT_SHAREABLE` (status not created/assigned/started)                | Naturally idempotent: returns the active link if there is one |
| `/trips/{id}/booking-link/rotate`       | POST       | staff      | —                                      | same                                          | `NOT_FOUND`, `BOOKING_NOT_SHAREABLE`                                                      | `Idempotency-Key` required (a retry mustn't rotate twice)     |
| `/public/bookings/{token}`              | GET        | **public** | path `token` (22 chars, base64url)     | `BookingView`                                 | `BOOKING_LINK_NOT_FOUND` (404, the same for unknown, revoked and expired), `RATE_LIMITED` | —                                                             |
| `/trips`, `/trips/{id}` (create, patch) | POST/PATCH | as today   | `+ extraKmRatePaise?: int ≥ 0 \| null` | `Trip` gains `extraKmRatePaise`               | —                                                                                         | as today                                                      |

`BookingView` is a separate, minimal schema. It must **never** reuse `Trip`,
so collections, odometers, fuel and charges can't leak. Its fields:

- `reference`, `stage | 'completed' | 'cancelled'`, `tripType`
- `fleet`: `{ name, contactPhone|null, gstin|null }`
- `trip`: `{ from, to|null, scheduledStartAt, scheduledEndAt }`
- `customerFirstName|null`
- `cab|null`: `{ make, model, registrationNo, fuelType }`
- `driver|null`: `{ name, phone|null }`
- `documents: DocBadge[]`
- `fare`: `{ quotedPaise, includedKm|null, gst: {percent, included, gstPaise}|null, paidPaise }`
- `terms: TermLine[]`
- `updatedAt`

After the contract change, run `bun run api:client`.

### API

**Module:** new `apps/api/src/modules/bookings/`.

- **Files:**
  - `bookings.module.ts`
  - `booking-terms.controller.ts` + `booking-terms.service.ts`: get and put
    `org_settings.booking_terms` inside `db.tenant`.
  - `booking-links.controller.ts` + `booking-links.service.ts`
  - `public-bookings.controller.ts` + `booking-view.service.ts`
- **`createOrGet(tripId)`**, inside `db.tenant(orgId)`:
  1. Load the trip, and reject with `BOOKING_NOT_SHAREABLE` if
     `bookingStage(status) === null`.
  2. Return the active link, or insert one with
     `crypto.randomBytes(16).toString('base64url')`. The partial unique
     index guards against two links being created at once; on a unique
     violation, re-read.
  3. Write a `trip_events` row `booking_link_created` (or
     `booking_link_rotated`) so it shows on the trip timeline (`TripEvent`,
     `schema.prisma:454`).
- **`url`:** `${PUBLIC_WEB_URL}/booking.html#t=${token}`. `PUBLIC_WEB_URL` is a
  **new env var**, with the default `http://localhost:5174` and on Render the
  `taxcy-web` URL. The token sits in the fragment, so it never reaches server
  logs or `Referer` headers.
- **Public view:**
  1. Rate-limit per IP (60/min) and per token (300/hour).
  2. `db.system` looks up the link by token (cross-org by necessity: the
     caller has no org). Revoked or missing gives a 404.
  3. `db.tenant(link.orgId)` loads the trip, vehicle (with `vehicleModel`),
     driver (name + `User.phoneE164`), current documents for that vehicle and
     driver, org name, booking terms, and the sum of collections.
  4. `bookingLinkState`: if expired, a 404.
  5. Build the `BookingView` with the domain functions.
  6. Set `Cache-Control: no-store`.
- **Rate limiting:** move `RateLimiter` into `PlatformModule` exports, so
  Identity and Bookings share it (no behaviour change).
- **Outbox:** no events needed in v1 (nothing is sent by the server). Option C
  would add a `booking.shared` topic later.

### App (`apps/driver-app`)

- **Models:**
  - `lib/core/api/owner_models.dart`: `BookingTerms`, `BookingLink`,
    `BookingView`, `TermLine` (sealed class with a `fromJson` per code),
    `DocBadge`.
  - `Trip` gains `extraKmRatePaise` (`models.dart:360`).
  - Parsing tests in `test/owner_models_test.dart`.
- **API:** `OwnerApi`
  - `bookingTerms()`, `updateBookingTerms()`
  - `bookingLink(tripId)`, `rotateBookingLink(tripId, key)`
  - `publicBooking(token)`, which calls the public route without auth
- **Share card:**
  - New `lib/features/owner/trips/booking_share.dart`, replacing
    `trip_share.dart`, which is deleted along with its use at
    `owner_trip_detail_screen.dart:143`.
  - `BookingShareCard` builds the message with
    `bookingMessage(l10n, fmt, BookingView, url)` and keeps `urlOpenerProvider`
    for `wa.me`.
  - It is shown only when `bookingStage(trip.status)` isn't null. That's a
    Dart port of the one-line rule; the fixture test isn't needed for a
    6-row table, but a unit test covers it.
- **PDF (secondary):**
  - New `lib/features/owner/trips/booking_pdf.dart`.
  - Build a `BookingConfirmationSheet` widget (A4 aspect, the same layout as
    the page), render it off-screen through a `RepaintBoundary` at 2× scale to
    PNG, and wrap it in a one-page A4 PDF with `pdf`.
  - Rasterising means **Hindi renders correctly** (Flutter shapes the text);
    the trade-off is non-selectable text and ~300–600 KB.
  - Share it with `share_plus` (`XFile.fromData`, `application/pdf`,
    `FS-7K2Q9M.pdf`). On web it uses the Web Share API, otherwise a download.
  - The footer says "Generated <time>; for the latest details open <url>".
  - New dependencies: `pdf ^3.13.1` and `share_plus ^13.3.1`.
- **Settings:** a new `_BookingTermsForm` section in
  `lib/features/owner/settings_screen.dart`, owner-editable and read-only
  for managers, with a terms preview built from the same `TermLine`
  renderer.
- **Trip form:** an extra km rate field in the create and edit trip screens,
  in ₹ and converted to paise.
- **Desktop:** the share card sits in the trip header's action row. In
  Settings it's one more section in the existing layout. No new desktop
  shell work.

**Public page** (`apps/driver-app/web/booking.html` + `web/booking.js` +
`web/booking.css`, new; no framework, under 30 KB):

- **API base:** a `<meta name="api-url" content="__API_URL__">` that
  `infra/render/build-web.sh` (and `bun run dev:driver-web`) replaces with
  `API_URL`.
- **Strings:** an en/hi dictionary in `booking.js`; `l=hi|en` comes from the
  fragment, with a toggle on the page.
- **Formatting:** `Intl.NumberFormat('en-IN', {style:'currency', currency:'INR'})`
  for amounts, and IST via `timeZone: 'Asia/Kolkata'`.
- **Printing:** `@media print` styles for "Save as PDF".
- **Link preview:** static Open Graph tags ("Your cab booking · Fleet
  Sarthi", og:image = `icons/Icon-512.png`, under 300 KB).
- **CORS:** `CORS_ORIGINS` already includes the web origin.

**Driver mode:** no change (drivers don't share in v1, and nothing offline is
involved).

**New l10n keys:**

| Key                  | English                                                                      | Hindi                                                                           |
| -------------------- | ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| shareBooking         | Share booking                                                                | बुकिंग भेजें                                                                    |
| bookingReceived      | Booking received                                                             | बुकिंग मिल गई                                                                   |
| bookingConfirmed     | Booking confirmed                                                            | बुकिंग कन्फ़र्म                                                                 |
| bookingInProgress    | Trip in progress                                                             | यात्रा जारी है                                                                  |
| cabDriverPending     | Cab and driver will be shared before pickup.                                 | कैब और ड्राइवर की जानकारी पिकअप से पहले भेजी जाएगी।                             |
| copyMessage          | Copy message                                                                 | संदेश कॉपी करें                                                                 |
| copyBookingLink      | Copy link                                                                    | लिंक कॉपी करें                                                                  |
| bookingLinkCopied    | Link copied                                                                  | लिंक कॉपी हो गया                                                                |
| shareAsPdf           | Share as PDF                                                                 | PDF के रूप में भेजें                                                            |
| openBookingPage      | Open booking page                                                            | बुकिंग पेज खोलें                                                                |
| resetBookingLink     | Reset link                                                                   | लिंक बदलें                                                                      |
| resetBookingLinkHint | The old link will stop working.                                              | पुराना लिंक काम करना बंद कर देगा।                                               |
| sendIn               | Send in                                                                      | भेजने की भाषा                                                                   |
| warnNoCustomerPhone  | No customer phone: WhatsApp will ask whom to send to.                        | ग्राहक का फ़ोन नहीं है: व्हाट्सऐप पूछेगा कि किसे भेजना है।                      |
| warnDocsNotValid     | {docs} not valid on the trip date; the customer won't see them as verified.  | {docs} यात्रा की तारीख़ पर मान्य नहीं हैं; ग्राहक को ये जाँचे हुए नहीं दिखेंगे। |
| warnNotAssigned      | Cab and driver aren't assigned yet; the link will show them once you assign. | कैब और ड्राइवर अभी तय नहीं हैं; तय करते ही लिंक पर दिखेंगे।                     |
| bookingLatestAt      | Latest details, documents and all terms:                                     | ताज़ा जानकारी, दस्तावेज़ और सभी शर्तें:                                         |
| bookingTermsTitle    | Terms                                                                        | शर्तें                                                                          |
| termIncludedKm       | Fare includes {km} km                                                        | किराये में {km} किमी शामिल                                                      |
| termExtraKm          | Extra km {rate}/km                                                           | अतिरिक्त किमी {rate}/किमी                                                       |
| termExtraHour        | Extra hour {rate}/hour                                                       | अतिरिक्त घंटा {rate}/घंटा                                                       |
| termGarageToGarage   | Km and time counted from our garage and back                                 | किमी और समय गैराज से गैराज तक गिने जाएंगे                                       |
| termDriverAllowance  | Driver allowance {rate}/day                                                  | ड्राइवर भत्ता {rate}/दिन                                                        |
| termNightCharge      | Night charge {rate} (10 pm–6 am)                                             | रात्रि शुल्क {rate} (रात 10 से सुबह 6)                                          |
| termTollsIncluded    | Tolls, parking and state tax included                                        | टोल, पार्किंग और राज्य कर शामिल                                                 |
| termTollsExtra       | Tolls, parking and state tax extra, at actuals                               | टोल, पार्किंग और राज्य कर अतिरिक्त, जितना लगे                                   |
| termWaiting          | {min} min free waiting, then {rate} per 30 min                               | {min} मिनट प्रतीक्षा मुफ़्त, फिर हर 30 मिनट {rate}                              |
| termGstIncluded      | {pct}% GST included                                                          | {pct}% जीएसटी शामिल                                                             |
| termGstExtra         | {pct}% GST extra                                                             | {pct}% जीएसटी अतिरिक्त                                                          |
| termNotTaxInvoice    | This is a booking confirmation, not a tax invoice.                           | यह बुकिंग की पुष्टि है, टैक्स इनवॉइस नहीं।                                      |
| bookingSettings      | Booking confirmation                                                         | बुकिंग पुष्टि                                                                   |
| bookingContactPhone  | Booking contact number                                                       | बुकिंग संपर्क नंबर                                                              |
| showDriverPhone      | Show the driver's number to customers                                        | ग्राहकों को ड्राइवर का नंबर दिखाएँ                                              |
| extraKmRate          | Extra km rate (₹/km)                                                         | अतिरिक्त किमी दर (₹/किमी)                                                       |
| extraHourRate        | Extra hour rate (₹/hour)                                                     | अतिरिक्त घंटा दर (₹/घंटा)                                                       |
| driverAllowanceRate  | Driver allowance (₹/day)                                                     | ड्राइवर भत्ता (₹/दिन)                                                           |
| nightChargeAmount    | Night charge (₹)                                                             | रात्रि शुल्क (₹)                                                                |
| freeWaitingMinutes   | Free waiting (min)                                                           | मुफ़्त प्रतीक्षा (मिनट)                                                         |
| waitingChargeRate    | Waiting charge (₹ per 30 min)                                                | प्रतीक्षा शुल्क (₹ प्रति 30 मिनट)                                               |
| tollsIncludedSwitch  | Tolls, parking and state tax included in fare                                | टोल, पार्किंग और राज्य कर किराये में शामिल                                      |
| garageToGarageSwitch | Count km garage to garage                                                    | किमी गैराज से गैराज गिनें                                                       |
| gstRateLabel         | GST                                                                          | जीएसटी                                                                          |
| gstinLabel           | GSTIN                                                                        | जीएसटीआईएन                                                                      |
| cancellationPolicy   | Cancellation policy                                                          | रद्द करने की नीति                                                               |
| otherTerms           | Other terms (one per line)                                                   | अन्य शर्तें (हर लाइन में एक)                                                    |

The keys `shareTripHeading … shareFareWithKm` are retired, while `copyDetails`,
`shareOnWhatsApp` and `whatsAppUnavailable` are reused. The public page holds
its own copies of the customer-facing strings, the `term*` and stage ones.

### Security and tenancy

- **Who can do what:**
  - Staff create and rotate links for trips in their org. RLS on
    `booking_links` and `trips` enforces that, alongside the role check in
    the contract.
  - Drivers get `FORBIDDEN_ROLE`.
  - Only owners edit terms.
- **The public endpoint:**
  - Its only cross-org step is the token lookup (`db.system`, justified in a
    code comment). Everything after it runs inside `db.tenant(link.orgId)`.
  - The response is a hand-built, minimal schema. The contract encoder
    strips unknown fields (`response.interceptor.ts`).
  - No customer phone, no collections breakdown, no odometer, GPS, fuel or
    pay data.
- **Enumeration:**
  - The token has 128 random bits.
  - The same 404 for unknown, revoked and expired links.
  - Per-IP and per-token rate limits.
  - `no-store` caching.
  - The token sits in the URL fragment, so it isn't sent to servers or in
    `Referer` headers.
- **Driver privacy:**
  - Documents appear only as status badges.
  - The driver's phone can be swapped for the fleet contact.
  - The driver's contact disappears 7 days after the trip, when the link
    expires.
  - DPDP notice and consent (from ~May 2027): see the open questions.
- **Abuse:**
  - Link creation is staff-only and idempotent, so it can't be spammed into
    many tokens. Rotation needs an idempotency key.
  - The page escapes all text: `textContent` only, no `innerHTML` with data.

### Failure modes

| Failure                                   | Behaviour                                                                                                                                                               |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Double tap on Share                       | `POST …/booking-link` returns the existing active link; the partial unique index makes concurrent inserts safe (re-read on conflict).                                   |
| Retry of Reset link                       | The `Idempotency-Key` replays the first rotation's response.                                                                                                            |
| Cab or driver reassigned after sharing    | The message is stale, but it says "Latest details…" and the link shows the new pair. The owner can share again.                                                         |
| Render free API asleep (cold start ~50 s) | The page shows the skeleton, then "Waking up the server…", and retries with backoff for up to 90 s, then shows retry and contact buttons. (Paid instances don't sleep.) |
| Owner offline                             | The share buttons show the standard error snackbar with retry (online-first, D12).                                                                                      |
| WhatsApp not installed / `wa.me` fails    | The existing `whatsAppUnavailable` snackbar, with Copy message as the fallback.                                                                                         |
| Web Share API missing (desktop Firefox)   | The PDF downloads instead (share_plus fallback).                                                                                                                        |
| Trip ends or is cancelled                 | The share card is hidden. The link moves to completed or cancelled, then expires.                                                                                       |
| Terms not set                             | Only the default lines (tolls extra, not a tax invoice) appear, and Settings nudges "Add your booking terms" in the share card.                                         |
| Clock skew                                | The server decides expiry; the page only displays times.                                                                                                                |

### Seed and docs

- **Seed** (`apps/api/src/seed/seed.ts`):
  - Booking terms for Sharma Travels (contact, ₹14/km, ₹150/h, ₹300/day
    allowance, ₹250 night charge, tolls extra, 5% GST included, a
    cancellation line).
  - Simpler terms for Patil Cabs.
  - An active booking link on Imran's evening trip (assigned), so the demo
    page works.
  - Update `docs/usage/demo-data.md` and `seed.int.test.ts`.
- **Docs:**
  - `docs/usage/` gets a "Sharing a booking" page.
  - `docs/deployment.md` gets `PUBLIC_WEB_URL`, plus the `__API_URL__`
    replacement in `build-web.sh`.
  - `docs/architecture.md` gets the public endpoint.
  - `docs/roadmap.md` notes that booking terms are an interim stand-in for
    the rate card.

### Proposed decisions

| #   | Question                               | Decision                                                                                                                      | Consequences                                                                                                                                                                                                                                                                                                                                                           |
| --- | -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| D18 | Booking confirmations _(proposed)_     | **WhatsApp message + revocable public link, PDF optional; documents as status only**                                          | A first public, token-based read route (`/public/bookings/{token}`): the token lookup is the only `db.system` step; minimal `BookingView`; same 404 for unknown/revoked/expired; links expire 7 days after the trip ends (MoRTH 2025 baseline) or 2 days after cancellation. A static `booking.html` on the web host serves customers without loading the Flutter app. |
| D19 | Which trips can be shared _(proposed)_ | **created ("received"), assigned ("confirmed"), started ("in progress")**                                                     | No sharing for ended, settled or cancelled trips; a post-trip summary or receipt is separate, later work.                                                                                                                                                                                                                                                              |
| D20 | Customer-facing rates _(proposed)_     | **A fleet-level "booking terms" setting, with a per-trip extra-km override**, as an interim stand-in for the rate-card engine | `org_settings.booking_terms` (JSON, Zod-validated) and `trips.extra_km_rate_paise`. Terms are sent as codes and values, and each client words them in English or Hindi (D13). A future rate card replaces the defaults without changing `TermLine`.                                                                                                                    |

## Implementation plan

### Step 1 — Booking rules exist and are tested

Files: `libs/domain/src/bookings/{stage,link-state,terms,gst,documents,reference}.ts` (new), `libs/domain/src/bookings/*.test.ts` (new), `libs/domain/src/index.ts` (export)
Change:

- Implement `bookingStage`, `bookingLinkState`, `bookingTerms`, `gstBreakup`, `verifiedDocuments` and `bookingReference` as specified above.
- `BookingTerms` lives in contracts. The domain takes a plain structural type, so it doesn't import contracts.

Tests: every row of the table in _Domain rules_, plus 7-day and 2-day boundaries to the minute and GST rounding (odd amounts).
Verify: `bunx nx run @taxcy/domain:test`
Commit: `feat(domain): booking stage, link expiry, terms, GST and document badges`
Size: S

### Step 2 — Schema supports links, terms and per-trip extra km

Files: `libs/db/prisma/schema.prisma` (edit), `libs/db/prisma/migrations/2026101400…_booking_links/migration.sql` (new)
Change:

- Add `BookingLink`, `OrgSettings.bookingTerms` and `Trip.extraKmRatePaise`.
- Run `bun run db:migration booking_links`.
- Hand-add the RLS policy, grants, the partial unique index and the CHECKs.
- Read the generated SQL and delete any drops of unmodelled objects.

Tests: an integration test, `apps/api/test/booking-links.int.test.ts` (new):

- A second org can't see the first org's link under `db.tenant`.
- Two active links for one trip are rejected.

Verify: `bun run db:migrate && bun run db:drift && bun run test:integration`
Commit: `feat(db): booking links, booking terms and per-trip extra km rate`
Size: S

### Step 3 — Contracts and the generated client

Files: `libs/contracts/src/routes/bookings.ts` (new), `libs/contracts/src/routes/trips.ts` (`extraKmRatePaise`), `libs/contracts/src/index.ts`, `libs/api-client` (regenerated)
Change:

- Add `BookingTerms`, `BookingLink`, `BookingView`, `TermLine` and `DocBadge`.
- Add the five routes from the table, with error codes `BOOKING_NOT_SHAREABLE` and `BOOKING_LINK_NOT_FOUND`.
- Add the `extraKmRatePaise` field to trip create, patch and output.

Tests: contract schema tests for the `BookingTerms` limits (10 custom lines, 200 chars, non-negative amounts).
Verify: `bunx nx run @taxcy/contracts:test && bun run api:client && bunx nx run @taxcy/api:typecheck`
Commit: `feat(contracts): booking terms, booking links and public booking view`
Size: S

### Step 4 — Owners can save booking terms; trips carry an extra-km rate

Files: `apps/api/src/modules/bookings/{bookings.module,booking-terms.controller,booking-terms.service}.ts` (new), `apps/api/src/app.module.ts` (import), `apps/api/src/modules/trips/trips.service.ts` + `trips.repository.ts` (extraKmRatePaise)
Change:

- GET and PUT `/settings/booking-terms` in `db.tenant`. PUT is owner-only.
- Persist and return the trip's `extraKmRatePaise`.

Tests:

- Unit test: the service parses defaults from `{}`.
- Integration test: a manager's PUT gets `FORBIDDEN_ROLE`; the trip round-trips `extraKmRatePaise`.

Verify: `cd apps/api && bunx vitest run src/modules/bookings && bunx vitest run -c vitest.int.config.ts test/booking-links.int.test.ts`
Commit: `feat(api): booking terms setting and per-trip extra km rate`
Size: S

### Step 5 — Staff create links; anyone with the link reads the booking

Files: `apps/api/src/modules/bookings/{booking-links.controller,booking-links.service,public-bookings.controller,booking-view.service}.ts` (new), `apps/api/src/platform/platform.module.ts` (export `RateLimiter`), `apps/api/src/modules/identity/identity.module.ts` (drop the local provider), `apps/api/src/platform/config.ts` (`PUBLIC_WEB_URL`)
Change:

- `createOrGet` and `rotate`, with trip events.
- The public route: rate limit, `db.system` lookup, `db.tenant` load, domain assembly, `no-store`.
- The URL is built from `PUBLIC_WEB_URL`.

Tests: `apps/api/test/booking-links.int.test.ts`

- Create is idempotent, and concurrent creates give one link.
- Rotate revokes the old link (the old token gets a 404), and an `Idempotency-Key` replay doesn't rotate twice.
- `BOOKING_NOT_SHAREABLE` for ended trips.
- The public view has no customer phone, collections list or odometer (assert the exact key set).
- Reassigning shows the new driver.
- Expired after 7 days (use the fake clock); unknown and revoked give the same 404 body.
- The rate limit trips at 61 requests a minute.
- Another org's staff get `NOT_FOUND` when creating a link for this trip.

Verify: `cd apps/api && bunx vitest run src/modules/bookings && bun run test:integration`
Commit: `feat(api): revocable booking links and a public booking view`
Size: M

### Step 6 — App models, API and settings

Files: `apps/driver-app/lib/core/api/owner_models.dart`, `models.dart` (`Trip.extraKmRatePaise`), `owner_api.dart` + `http_owner_api.dart` (if separate), `lib/features/owner/settings_screen.dart` (`_BookingTermsForm`), the create and edit trip screens (extra km field), `lib/l10n/app_en.arb` + `app_hi.arb` (keys above), `test/support/owner_fakes.dart`
Change:

- Dart models with `fromJson`, and the `TermLine` renderer `termText(l10n, fmt, line)`.
- The settings section, read-only for managers, with a preview.
- The trip form field.

Tests:

- `test/owner_models_test.dart`: parsing, including unknown `TermLine` codes (skipped, not a crash).
- `test/owner_flows_test.dart`: an owner saves terms; a manager sees them read-only.
- `test/l10n_test.dart`: the settings section in Hindi.

Verify: `cd apps/driver-app && flutter analyze --fatal-infos && flutter test`
Commit: `feat(app): booking terms in settings and extra km rate on trips`
Size: M

### Step 7 — Owners share a booking by WhatsApp, copy or link

Files: `lib/features/owner/trips/booking_share.dart` (new), `owner_trip_detail_screen.dart` (replace `TripShareButtons`), `trip_share.dart` (deleted), and its tests moved
Change:

- `BookingShareCard`: the stage chip, language toggle, warnings, WhatsApp, copy message, copy link, open page and reset link.
- `bookingMessage()` builds the WhatsApp-formatted text from `BookingView`.
- The card is hidden for ended, settled and cancelled trips.

Tests (`test/booking_share_test.dart`):

- A card for created, assigned and started, and none for the other three.
- The WhatsApp URI targets the customer phone, and the message contains the reference, cab, driver, `termExtraKm` and the link.
- The no-phone and invalid-document warnings.
- Hindi message wording.
- Reset link asks for confirmation and sends an idempotency key.
- Desktop layout (`test/desktop_test.dart`).

Verify: `cd apps/driver-app && flutter analyze --fatal-infos && flutter test test/booking_share_test.dart test/desktop_test.dart`
Commit: `feat(app): share a booking confirmation with a live link`
Size: M

### Step 8 — Customers see the live booking page

Files: `apps/driver-app/web/{booking.html,booking.js,booking.css}` (new), `infra/render/build-web.sh` and the `dev:driver-web` script (replace `__API_URL__`), `render.yaml` (`PUBLIC_WEB_URL` on the API, `sync: false`)
Change:

- The vanilla page: fetch the view, render the cards, en/hi strings, wake-up retry, the 404 state, a print stylesheet, and Open Graph tags.
- All data is written with `textContent`.

Tests:

- The JS has a pure `render(view, lang)` function, unit-tested with Vitest in jsdom (`apps/driver-app/web/booking.test.js`, run from the root as a small Nx target), if adding it is cheap. Otherwise a manual check script.
- Manual: open the seeded link at 360 px and at desktop width, in English and Hindi; then reassign and refresh; then rotate (the old link shows 404); and print to PDF.

Verify: `bun run dev` + `bun run dev:driver-web`, then open `http://localhost:5174/booking.html#t=<seeded token>`
Commit: `feat(web): public booking confirmation page`
Size: M

### Step 9 — Share as PDF

Files: `lib/features/owner/trips/booking_pdf.dart` (new), `pubspec.yaml` (`pdf`, `share_plus`), `booking_share.dart` (menu item)
Change:

- `BookingConfirmationSheet` widget → off-screen `RepaintBoundary` → PNG at 2× → one-page A4 PDF.
- Share through `share_plus` with the file name `<reference>.pdf`.
- The footer has the generated time and the live link.

Tests:

- `test/booking_pdf_test.dart`: the sheet renders without overflow in English and Hindi at A4 aspect.
- The PDF bytes start with `%PDF` and are under 1 MB.
- The share call receives `application/pdf` (`share_plus` behind a provider, faked in tests).

Verify: `cd apps/driver-app && flutter test test/booking_pdf_test.dart && flutter build web`
Commit: `feat(app): share a booking confirmation as PDF`
Size: S–M

### Step 10 — Seed, docs and decisions

Files: `apps/api/src/seed/seed.ts`, `apps/api/test/seed.int.test.ts`, `docs/usage/demo-data.md`, `docs/usage/sharing-a-booking.md` (new), `docs/deployment.md`, `docs/architecture.md`, `docs/decisions.md` (D18–D20, accepted), `docs/roadmap.md`
Change:

- The demo terms and the demo link, as described above.
- The docs as listed.

Tests: the seed integration test asserts the terms and an active link on Imran's trip.
Verify: `bun run db:reset && bun run test:integration && bun run verify`
Commit: `docs: booking confirmations; seed demo terms and link`
Size: S

**Total:** about 6 working days.

## Risks and mitigations

1. **A public endpoint leaks more than intended.**
   - Mitigations: a separate minimal `BookingView`, the contract encoder
     stripping unknown fields, and an integration test that asserts the exact
     key set.
   - Code review checks any new field against D18.
2. **The free-tier cold start makes the link feel broken.** The page has a
   wake-up message and retries. Paid instances (or a keep-alive ping) remove
   the delay; this is noted in `deployment.md`.
3. **The terms are wrong or legally weak.** They're the owner's own words and
   numbers; we only format them. The page says "not a tax invoice". Nothing
   here is legal advice, and the GST rates are configurable.
4. **Rasterised PDF size or quality.** It renders at 2× on A4 and is capped
   under 1 MB by the test. If that falls short, a vector PDF in English only
   is the fallback.
5. **Stale messages after a reassignment.** The live link covers this, and
   the share card could later prompt "Share the update?" after a
   reassignment (out of scope).

## Out of scope

- A post-trip summary, receipt or tax invoice.
- Automatic sends (WhatsApp Business API or SMS, option C).
- Sharing by drivers.
- A rate-card fare engine, and rates per vehicle type.
- Driver photos.
- QR codes on the PDF.
- Per-booking Open Graph previews.
- Viewing document images.
- Customer records.

## Open questions

1. **Store the token in plain text or hashed?**
   - _Recommended:_ plain text in v1, so the same link can be shared again.
     It's read-only, revocable, and scoped to data already in the org.
   - Hashing would mean rotating the link on every share.
2. **PDF: rasterised (correct Hindi) or vector (selectable text, English only)?**
   _Recommended:_ rasterised, since Hindi must work and it's a secondary option.
3. **Driver consent for sharing their name and phone with customers (DPDP,
   from about May 2027)?**
   - _Recommended:_ add a notice line to the driver invite and acceptance
     screen in a follow-up.
   - Until then, the `showDriverPhone` switch lets owners show the office
     number instead.
4. **Should drivers be able to share?**
   _Recommended:_ not in v1; revisit with real use.
5. **Do extra-km rates need to be per vehicle type (Dzire vs Innova)?**
   _Recommended:_ the per-trip override now; per-model rates arrive with the
   rate card.

## Done when

- [ ] The five acceptance checks above pass.
- [ ] `bun run verify`, `bun run test:integration` and `flutter test` are green.
- [ ] `flutter analyze --fatal-infos` is clean and `flutter build web` succeeds.
- [ ] Manual checks pass: the share card on phone (360 px), tablet and desktop (1440 px); the public page in English and Hindi at 360 px and desktop; a PDF from Android and from web; and the old link returning 404 after a reset.
- [ ] D18–D20 are accepted in `docs/decisions.md`.
