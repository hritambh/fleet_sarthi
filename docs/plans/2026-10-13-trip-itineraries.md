# Trip itineraries for tour planners

Status: proposed · Date: 2026-10-13 · Owner: Hritambh Hritvij

Depends on: [Share a booking confirmation](2026-10-13-booking-confirmation.md)
(its booking links, `BookingView`, public page, share card and PDF option).
Build that plan's steps 1–9 first, or interleave as noted below.

## Problem and outcome

Fleets that also plan tours send customers a day-by-day plan ("Kerala 4N/5D")
as a PDF on WhatsApp, separately from the cab details, and re-send the same
file for every booking. **Outcome:** a tour planner uploads an itinerary once
to an **Itineraries library**, attaches it to any trip (or uploads a one-off
for a single trip), and the customer gets it with the booking confirmation
through every share option: the WhatsApp message, the live booking page (view
and download), and the PDF share (as a second file or one combined PDF). The
assigned driver can open or download it from the trip.

## Who and where

- **Owner:** turns on **"We plan tours"** in Settings. Only fleets with it on
  see itineraries.
- **Owner and manager:** manage the library, attach itineraries to trips, and
  share them. This is owner mode on phone, tablet and desktop, online-first
  (D12).
- **Driver:** sees the trip's itinerary in driver mode, with **View**
  (online) and **Download** (saves to the phone). Nothing is cached inside
  the app (your choice, 2026-10-13).
- **Customer:** gets it through the booking link and message, or as a PDF.
  No app is needed.

## Acceptance checks

1. With "We plan tours" off, no itinerary UI appears anywhere. With it on, an
   **Itineraries** section appears (desktop sidebar; More on phone and
   tablet), plus an **Itinerary** card on trips.
2. An owner uploads "Kerala 4N/5D" as a PDF (or as up to 10 photos), and within
   a few seconds it shows "12 pages · 2.4 MB · Ready". A password-protected or
   corrupt file shows a clear reason and isn't attachable.
3. Attaching it to an assigned trip and sharing produces a WhatsApp message
   with an "Itinerary: Kerala 4N/5D (12 pages)" line. The booking page shows
   an Itinerary card with **View** and **Download**. _Share as PDF_ offers
   _Confirmation only_, _Confirmation + itinerary (2 files)_ and _One combined
   PDF_.
4. Editing the library itinerary later doesn't change what an
   already-confirmed trip shows (it's pinned to a version). The trip shows
   "A newer version exists" with **Use latest**.
5. The assigned driver can open the itinerary when online and download it to
   the phone. Offline, the buttons say "Needs internet".

## Options considered

| Option                                         | Sketch                                                                                                                                                                             | Touches                                                                                | Effort      | Main risk                                                                                                                            |
| ---------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| A. Per-trip upload only                        | An "Attach itinerary PDF" on each trip, reusing the documents upload, with a signed link on the booking page.                                                                      | API, DB (1 table), app, public page                                                    | M           | The same file is uploaded again for every booking. Raw, unsanitised PDFs go to customers.                                            |
| **B. Library + versions + attach (+ one-off)** | A fleet-level library of itineraries with immutable, server-sanitised versions. Trips pin a version. A one-off upload is a hidden library entry. Sharing extends the booking plan. | Domain, DB (3 tables, 2 columns, 1 enum value), contracts, API + job, app, public page | L (~8 days) | PDF sanitising edge cases (encrypted, malformed), and server memory for large files.                                                 |
| C. Structured day-by-day builder               | Planners type days, places, hotels and meals in the app, and we render a branded itinerary on the page and in the PDF. No uploads.                                                 | Domain, DB, app, page                                                                  | L+          | Planners already have polished PDFs and won't retype them. Hindi PDF rendering again. Good later as an _addition_ (open question 4). |

## Chosen approach and why

**B**, as you chose (library + attach, gated by a fleet setting). Pinned,
sanitised versions mean a customer never receives an active-content PDF, and
a confirmed booking never changes under them. The one-off upload keeps
"just this trip" as fast as option A.

## Research findings

### Codebase

- **Media pipeline:**
  - `POST /media` takes a client id, `kind`, `contentType ∈ {jpeg, png, webp, pdf}`, sha256 and `byteSize ≤ 15 MiB` (`libs/contracts/src/routes/media.ts:43-52`).
  - `POST /media/{id}/complete` re-hashes the object in S3, rejects mismatches, marks it `uploaded` and publishes `media.uploaded` (`apps/api/src/modules/media/media.service.ts:106-151`, publish at `:148`), which only OCR consumes (`ocr.job.ts:23`).
  - Views are presigned GETs with a 300 s TTL (`media.service.ts:153-163`).
  - Keys are `${orgId}/${kind}/${YYYY/MM}/${id}.${ext}`, with `pdf` supported (`:73, :82`).
  - The server's actual content type isn't checked; only the declared one is.
  - No orphan-cleanup job exists.
- **`MediaKind`:** `odometer | fuel_receipt | document | other` (`libs/db/prisma/schema.prisma:99-106`).
- **Pattern to reuse:**
  - Documents attach many files via `document_files` with `position` (`schema.prisma:366-378`; `apps/api/src/modules/fleet/documents.service.ts:228-238`).
  - **Gap:** `assertMedia` doesn't require `status === 'uploaded'` (`documents.service.ts:214-226`), so a pending or rejected upload can be attached. The itinerary code must check the status. Fixing documents is listed separately (out of scope).
- **App uploads:**
  - `pickDocumentFiles` allows pdf, jpg, jpeg, png and webp up to 15 MiB (`apps/driver-app/lib/core/media/file_pick.dart:8-16, 39-73`).
  - `uploadPhotoNow` runs register → PUT → complete, online (`lib/core/media/upload_now.dart:9-41`).
  - Viewing a document opens a fresh signed URL externally (`lib/features/owner/documents_screen.dart:225-240`, via `urlOpenerProvider`).
  - There's no in-app PDF viewer.
  - The phone photo store hard-codes `.jpg` (`lib/core/media/photo_store_io.dart:29`). It isn't used here, since the driver downloads through the browser.
- **Org type:**
  - `OrgKind` is `fleet | dco` (`schema.prisma:23-28`), chosen at creation (`apps/api/src/modules/identity/orgs.service.ts:21-50`).
  - There's no business-type flag, and the app doesn't parse `orgKind` (`lib/core/api/models.dart:8-27`).
  - `OrgSettings` holds audit and pay settings only (`schema.prisma:148-160`).
- **Driver mode:**
  - Caches only trip and vehicle JSON (`lib/core/db/database.dart:9-30`).
  - Trips come from `GET /me/trips` and `GET /trips/{id}` (anyMember; drivers see their own) (`libs/contracts/src/routes/trips.ts:252, :410`).
- **Phone layout:** the phone and tablet layouts keep some sections behind **More**; desktop shows every section in the sidebar (`apps/driver-app/test/desktop_test.dart:27-52`).

### External (checked 2026-10-13)

- **Itinerary content and size:**
  - Indian packages list the day plan, hotels with meal plan, the cab (often including toll, parking and driver), and exclusions. Sources (undated listings): https://www.tourtravelworld.com/packages/4-night5-days-kerala-tour-package-244479.html , https://traveltriangle.com/packages/5days-4nights-kerala-tour-package-starting-from-inr31600?id=61797
  - Typical PDFs are 0.2–5 MB; photo-heavy ones run 10–30 MB. _Unverified._
- **WhatsApp:**
  - Documents up to 2 GB in the app: https://blog.whatsapp.com/reactions-2gb-file-sharing-512-groups (2022, _over 2 years old_, still the cited figure).
  - 100 MB through the Cloud API: https://developers.facebook.com/docs/whatsapp/cloud-api/reference/media (fetched 2026-10-13).
  - PDF first-page thumbnails are unreliable (https://community.adobe.com/questions-15/pdf-thumbnails-not-showing-in-whatsapp-2321, 2026-09-30), so the link's Open Graph card matters more.
- **Gmail:** 25 MB per message, beyond which it becomes a Drive link (https://support.google.com/mail/answer/6584). That favours links over attachments.
- **OWASP File Upload Cheat Sheet** (https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html):
  - Allow-list types and check magic bytes, not the declared type.
  - Use size limits and random names.
  - Serve through an ID handler from separate storage.
  - Use content disarm and reconstruction for PDFs.
- **Sanitising and merging in Node:**
  - `pdf-lib` 1.17.1 is unmaintained (last release 2021) and throws on encrypted files.
  - The maintained fork **`@cantoo/pdf-lib` 2.11.1** (2026-09-15, MIT) loads encrypted files and keeps the same API: https://unpkg.com/@cantoo/pdf-lib@2.11.1/README.md
  - Copying pages into a new document drops document-level JavaScript, OpenAction and embedded files. Annotation actions survive and must be stripped per page. _Unverified; confirmed by a test fixture in Step 4._
  - Ghostscript is AGPL (https://ghostscript.com/licensing), so we avoid it.
  - `qpdf` (Apache-2.0) is the robust repair tool if needed later.
  - ClamAV via `clamscan` needs a clamd daemon, too heavy for Render free: https://transloadit.com/devtips/implementing-server-side-malware-scanning-with-clamav-in-node-js/ (2025-02-05).
- **Flutter:**
  - `pdf` can't import existing pages.
  - **`pdf_combiner` 6.2.2** (2026-09-07, MIT, all platforms; PDFLib JS on web) can merge: https://pub.dev/documentation/pdf_combiner/latest/
  - `pdfrx` 2.6.5 (MIT) is the best in-app viewer if one is ever needed.
  - `syncfusion_*` is commercial.
- **Viewing:**
  - Desktop browsers view PDFs natively.
  - Chrome on Android gained an inline viewer around v135 (https://www.droid-life.com/2025/04/25/chrome-on-android-lets-you-open-pdfs-after-all-these-years/, 2025-04-25). Older versions, or `Content-Disposition: attachment`, download instead.
  - So the page shows the itinerary's title, length and highlights as text, with View and Download.
- **Standards:**
  - PDF/A isn't needed for a shared itinerary, and you can't force uploads to comply.
  - Converting would need Ghostscript (AGPL) or Gotenberg (heavy).
  - DOCX conversion needs LibreOffice (Gotenberg), so it's out of v1; planners can "Save as PDF".
  - JPG and PNG are accepted and wrapped into a PDF on the server.

## Design

### User flows

**Owner, turning it on:** in Settings, a new **Business** section has a
**"We plan tours"** switch with the hint "Show an itinerary library and attach
day plans to bookings". Only owners can edit it; managers see it read-only.

**Owner or manager, library**: desktop sidebar FLEET → **Itineraries**;
phone and tablet: More → Itineraries.

1. **List:** cards (CardGrid on desktop) with the title, "4N/5D", pages and
   size, "Updated 2 days ago" and "On 3 upcoming trips".
   - Empty state: "No itineraries yet · Upload a tour plan once and attach it
     to any booking."
   - Archived itineraries sit behind a filter.
2. **Add itinerary:**
   - Title (required), nights and days (optional), and highlights (optional,
     ≤ 1,000 chars, shown as text on the booking page).
   - **Upload PDF or photos** (1 PDF, or up to 10 JPG/PNG/WebP photos, each ≤ 15 MB).
3. **After saving:** the version shows **Preparing…**, and the app polls
   (1 s, 2 s, 4 s … up to 30 s, then on pull-to-refresh). It becomes **Ready**
   (pages, size) or **Failed** with the reason:
   - password-protected
   - unreadable
   - over 60 pages
   - over 20 MB after processing
4. **Detail:**
   - View and Download the latest version.
   - **Replace file**, which creates version N+1 (old versions stay for the
     trips pinned to them).
   - Edit the title, nights, days and highlights. These are shared by all
     versions and show on every trip immediately; only the _file_ is pinned.
   - **Archive**: hidden from pickers, while attached trips keep working.

**Owner or manager, on a trip:** when the feature is on, the trip detail has an
**Itinerary** card.

1. **Empty:** **Choose from library** (a searchable picker of ready
   itineraries) or **Upload for this trip only**, which creates a hidden
   one-off entry.
2. **Attached:**
   - The title, "4N/5D · 12 pages", and View, Download and Remove.
   - If the library has a newer ready version: "A newer version of this
     itinerary exists" with **Use latest**.
   - If the pinned version is still processing: "Preparing…" (sharing goes
     ahead without it, with a warning).
3. **Create and edit trip:** an optional **Itinerary** picker in the form.

**Sharing** (extends the booking plan's share card):

- **Message:** the WhatsApp message gains
  `*Itinerary:* Kerala 4N/5D (12 pages) · view or download at the link below`.
- **Booking page:** an **Itinerary** card with the title, nights and days,
  highlights as text, "12 pages · 2.4 MB", and two buttons:
  - **View**: opens inline in a new tab.
  - **Download**: saves as `Kerala-4N5D-FS-7K2Q9M.pdf`.
- **Share as PDF:** a sheet with three choices:
  - **Confirmation only** (the default when there's no itinerary).
  - **Confirmation + itinerary (2 files)** (the default when there is one):
    `share_plus` shares both files at once (WhatsApp and Gmail accept several
    documents; on web the Web Share API does too, else both download).
  - **One combined PDF**: the app downloads the itinerary and merges it after
    the confirmation page with `pdf_combiner`. If the merge fails, it falls
    back to two files with a snackbar.
- **Warnings:**
  - "Itinerary is still being prepared; it won't be included."
  - "Combined PDF is over 25 MB; email may not accept it."

**Driver:** the trip screen (`trip_detail_screen.dart`) shows an **Itinerary**
row when the trip has one, with **View** and **Download**.

- **View** opens a fresh signed URL, inline, in the browser or PDF app.
- **Download** opens it with `attachment` disposition, so Android's download
  manager saves it to Downloads, and the browser does the same on web.
- **Offline:** both buttons are disabled with "Needs internet". The hint "Use
  Download before you lose signal" shows once.
- The cached trip JSON carries the itinerary's _metadata_ (title, pages), so
  the row still shows offline.

### Domain rules (`libs/domain/src/itineraries/`, new)

```ts
type UploadKind = 'pdf' | 'jpeg' | 'png' | 'webp';
function sniffUpload(head: Uint8Array): UploadKind | null; // magic bytes: %PDF-, FF D8 FF, 89 50 4E 47 0D 0A 1A 0A, RIFF....WEBP

type SourceCheck =
  | { ok: true; kind: 'pdf' | 'images' }
  | {
      ok: false;
      reason: 'MIXED_TYPES' | 'TOO_MANY_FILES' | 'MULTIPLE_PDFS' | 'TYPE_MISMATCH' | 'UNSUPPORTED';
    };
function checkSources(files: { declared: string; sniffed: UploadKind | null }[]): SourceCheck;

type ActionVerdict = 'keep' | 'drop';
function pdfActionPolicy(action: { type: string; uri?: string }): ActionVerdict;
// keep: URI with http/https/mailto/tel, GoTo (internal), Named (NextPage…)
// drop: JavaScript, Launch, GoToR, GoToE, SubmitForm, ImportData, ResetForm,
//       Rendition, Sound, Movie, Hide, RichMediaExecute, and any URI with another scheme

const ITINERARY_LIMITS = {
  maxFiles: 10,
  maxPages: 60,
  maxOutputBytes: 20 * 1024 * 1024,
  maxTitle: 80,
  maxHighlights: 1000,
};
function checkOutput(o: { pages: number; bytes: number }): null | 'TOO_MANY_PAGES' | 'TOO_LARGE';

function pinnedStatus(
  pinnedVersion: number,
  latestReadyVersion: number | null,
): 'current' | 'outdated';
function itineraryFileName(title: string, reference: string): string; // ASCII-safe slug, ≤ 60 chars, "<slug>-<ref>.pdf"
function nightsDaysLabel(nights: number | null, days: number | null): string | null; // "4N/5D", "5D", null
```

| Rule              | Input                                                                 | Output                                           |
| ----------------- | --------------------------------------------------------------------- | ------------------------------------------------ |
| sniffUpload       | `25 50 44 46 2D …`                                                    | pdf                                              |
| sniffUpload       | `FF D8 FF E0`                                                         | jpeg                                             |
| sniffUpload       | `3C 68 74 6D 6C` (HTML named .pdf)                                    | null                                             |
| checkSources      | 1 pdf (declared pdf)                                                  | ok, pdf                                          |
| checkSources      | 3 jpeg + 1 png                                                        | ok, images                                       |
| checkSources      | 1 pdf + 1 jpeg                                                        | MIXED_TYPES                                      |
| checkSources      | 2 pdf                                                                 | MULTIPLE_PDFS                                    |
| checkSources      | declared pdf, sniffed jpeg                                            | TYPE_MISMATCH                                    |
| checkSources      | 11 jpeg                                                               | TOO_MANY_FILES                                   |
| pdfActionPolicy   | URI `https://maps.google.com/…`                                       | keep                                             |
| pdfActionPolicy   | URI `javascript:alert(1)` / `file:///…` / `intent://…`                | drop                                             |
| pdfActionPolicy   | JavaScript / Launch / SubmitForm                                      | drop                                             |
| pdfActionPolicy   | Named NextPage / GoTo                                                 | keep                                             |
| checkOutput       | 61 pages / 21 MB                                                      | TOO_MANY_PAGES / TOO_LARGE                       |
| pinnedStatus      | pinned 2, latest ready 3 / pinned 3, latest 3 / pinned 2, latest null | outdated / current / current                     |
| itineraryFileName | "Kerala 4N/5D – Munnar & Alleppey", "FS-7K2Q9M"                       | `Kerala-4N5D-Munnar-Alleppey-FS-7K2Q9M.pdf`      |
| itineraryFileName | "केरल यात्रा", "FS-7K2Q9M"                                            | `itinerary-FS-7K2Q9M.pdf` (non-ASCII falls back) |
| nightsDaysLabel   | 4, 5 / null, 5 / null, null                                           | "4N/5D" / "5D" / null                            |

### Data model and migration

Prisma changes (`libs/db/prisma/schema.prisma`):

- **`MediaKind`** gains `itinerary`. This is a Postgres enum
  `ALTER TYPE … ADD VALUE`, so it's added in its own migration file.
  `ADD VALUE` can't be used in the same transaction as its first use.
- **`OrgSettings.offersTours`**: `Boolean @default(false)` (`offers_tours`).
- **`Itinerary` (new), table `itineraries`:**
  - `id` uuid (client-supplied, so creation is idempotent)
  - `org_id`
  - `title` (≤ 80)
  - `nights` smallint?, `days` smallint?
  - `highlights` text? (≤ 1,000)
  - `one_off` bool (default false)
  - `archived_at`?
  - `created_by`, `created_at`, `updated_at`
- **`ItineraryVersion` (new), table `itinerary_versions`:**
  - `id` uuid (client-supplied), `org_id`, `itinerary_id`
  - `version` int
  - `status` (`processing | ready | failed`)
  - `failure_reason`?
  - `source_media_ids` uuid[]
  - `media_id`? (the sanitised PDF; the server-created `MediaObject`, kind `itinerary`)
  - `page_count`?, `byte_size`?
  - `created_by`, `created_at`, `ready_at`?
  - `UNIQUE (itinerary_id, version)`
- **`TripItinerary` (new), table `trip_itineraries`:**
  - `trip_id` (PK), `org_id`, `itinerary_version_id`
  - `attached_by`, `attached_at`
  - One itinerary per trip.

Hand-written additions to the migration SQL:

- RLS `ENABLE` and the `tenant_isolation` policy on all three tables, the
  same as `document_files` (`libs/db/prisma/migrations/20261013000000_document_files/migration.sql:22-24`),
  plus grants to `taxcy_api`.
- CHECKs:
  - `nights BETWEEN 0 AND 60`
  - `days BETWEEN 1 AND 61`
  - `nights IS NULL OR days IS NULL OR days >= nights`
  - `status IN ('processing','ready','failed')`
  - `status <> 'ready' OR (media_id IS NOT NULL AND page_count > 0)`
  - `char_length(title) BETWEEN 1 AND 80`
- Partial index `itineraries (org_id, updated_at DESC) WHERE archived_at IS NULL AND NOT one_off`, for the library list.
- Index `trip_itineraries (itinerary_version_id)`, for "used by N trips".
- Cross-table rule (enforced in the service, not SQL): the version a trip
  pins must belong to the same org. RLS already makes another org's rows
  invisible.

### Contracts (`libs/contracts`)

New `routes/itineraries.ts`, plus edits to `media.ts`, `trips.ts` and
`fleet.ts` (settings).

| Route                                    | Method | Access                        | Input → Output                                                                           | Errors                                                                                      | Idempotency          |
| ---------------------------------------- | ------ | ----------------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- | -------------------- |
| `/settings/business`                     | GET    | staff                         | → `{ offersTours }`                                                                      | —                                                                                           | —                    |
| `/settings/business`                     | PATCH  | owner                         | `{ offersTours }` → same                                                                 | `FORBIDDEN_ROLE`                                                                            | —                    |
| `/itineraries`                           | GET    | staff                         | `?archived=bool&q=` → `ItinerarySummary[]` (incl. latest ready version, `upcomingTrips`) | `FEATURE_DISABLED`                                                                          | —                    |
| `/itineraries`                           | POST   | staff                         | `{ id, title, nights?, days?, highlights? }` → `Itinerary`                               | `FEATURE_DISABLED`, `VALIDATION_FAILED`                                                     | by client `id`       |
| `/itineraries/{id}`                      | GET    | staff                         | → `Itinerary` (with `versions[]`)                                                        | `NOT_FOUND`                                                                                 | —                    |
| `/itineraries/{id}`                      | PATCH  | staff                         | `Patch<{ title, nights, days, highlights }>` → `Itinerary`                               | `NOT_FOUND`, `VALIDATION_FAILED`                                                            | —                    |
| `/itineraries/{id}/archive`              | POST   | staff                         | → `Itinerary`                                                                            | `NOT_FOUND`                                                                                 | naturally idempotent |
| `/itineraries/{id}/versions`             | POST   | staff                         | `{ id, mediaIds: uuid[1..10] }` → `ItineraryVersion` (`processing`)                      | `MEDIA_NOT_UPLOADED`, `VALIDATION_FAILED` (`checkSources` reason in `details`), `NOT_FOUND` | by client `id`       |
| `/itinerary-versions/{id}`               | GET    | staff                         | → `ItineraryVersion`                                                                     | `NOT_FOUND`                                                                                 | —                    |
| `/trips/{id}/itinerary`                  | PUT    | staff                         | `{ itineraryVersionId }` → `Trip`                                                        | `NOT_FOUND`, `ITINERARY_NOT_READY` (failed), `FEATURE_DISABLED`                             | naturally idempotent |
| `/trips/{id}/itinerary`                  | DELETE | staff                         | → 204                                                                                    | `NOT_FOUND`                                                                                 | naturally idempotent |
| `/trips/{id}/itinerary/one-off`          | POST   | staff                         | `{ itineraryId, versionId, title?, mediaIds }` → `Trip`                                  | as versions + attach                                                                        | by client ids        |
| `/trips/{id}/itinerary/url`              | GET    | anyMember (drivers: own trip) | `?download=bool` → `{ url, expiresAt, fileName }`                                        | `NOT_FOUND`, `ITINERARY_NOT_READY`                                                          | —                    |
| `/public/bookings/{token}/itinerary-url` | GET    | **public**                    | `?download=bool` → `{ url, expiresAt, fileName }`                                        | `BOOKING_LINK_NOT_FOUND`, `RATE_LIMITED`                                                    | —                    |

Model changes:

- **`MediaKind`** gains `'itinerary'`.
- **`Trip`** gains:
  ```
  itinerary: {
    itineraryId, versionId, version, title, nights, days, pageCount, byteSize,
    status, pinned: 'current'|'outdated'
  } | null
  ```
- **`BookingView`** (from the booking plan) gains:
  ```
  itinerary: { title, nightsDays, highlights, pageCount, byteSize } | null
  ```
  It's only present when the pinned version is `ready`.

Afterwards, run `bun run api:client`.

### API

**New module `apps/api/src/modules/itineraries/`:**

- **Controllers and services:** `itineraries.controller.ts` + `itineraries.service.ts`
  for library CRUD and versions, inside `db.tenant`.
  - Every write first checks `offersTours`, or throws `FEATURE_DISABLED`.
  - Creating a version:
    1. Load each `mediaId`: same org, `kind = itinerary`, and
       **`status = uploaded`** (else `MEDIA_NOT_UPLOADED`).
    2. Run `checkSources` with the sniffed bytes. The service reads the first
       16 bytes with a ranged S3 GET.
    3. Insert `processing` with `version = max + 1`.
    4. `publish(tx, 'itinerary.version.created', { versionId })`.
- **`itinerary.processor.ts`:** `@OnJob('itinerary.version.created')`. It's
  idempotent: it returns if the version isn't `processing`.
  1. Download the sources from the internal S3 client.
  2. **PDF:** load with `@cantoo/pdf-lib` (`{ password: '' }`). A
     password-protected file gives `ENCRYPTED`, a parse error `UNREADABLE`.
     Create a fresh `PDFDocument` and `copyPages` every page. For each page,
     walk `/Annots` and remove `/A` and `/AA` entries where
     `pdfActionPolicy` says `drop`, and remove `FileAttachment`, `Movie`,
     `Sound`, `Screen` and `RichMedia` annotations. Don't copy the catalog's
     `/Names` (JavaScript, EmbeddedFiles), `/OpenAction`, `/AA` or `/AcroForm`.
  3. **Images:** decode and validate with `embedJpg` / `embedPng` (WebP:
     convert with `sharp` if it's already a dependency, otherwise reject WebP
     in v1). One A4 page per image, fit with margins.
  4. Run `checkOutput`, then save (`useObjectStreams: true`).
  5. Store through the **new** `MediaService.storeGenerated(tx, { kind: 'itinerary', contentType: 'application/pdf', bytes, fileName })`:
     - Put the object with `ContentType: application/pdf` and
       `ContentDisposition: inline; filename="…"`.
     - Insert the `MediaObject` with status `uploaded`, sha256 and size.
  6. Mark the version `ready` (page count, size), or `failed` with the
     reason.
  7. Memory: one file at a time, capped at 15 MB in and 20 MB out, which
     fits a 512 MB instance.
- **Trip side:** `trip-itinerary.service.ts`.
  - Attach, detach and one-off (creates a `one_off` itinerary + version +
    attach in one transaction; the processing job runs after commit).
  - Writes trip events `itinerary_attached` and `itinerary_removed` on the
    trip timeline.
  - The trip repository includes `trip_itineraries → version → itinerary` for
    the `Trip.itinerary` field (`apps/api/src/modules/trips/trips.repository.ts:6-8`).
- **Signed URLs:** `MediaService.viewUrl` gains
  `{ disposition: 'inline' | 'attachment', fileName }` and passes
  `ResponseContentDisposition` and `ResponseContentType` to the presigned
  GET (the TTL stays 300 s). This needs verifying on B2 (open question 1).
  - The fallback is the object's stored `Content-Disposition: inline`, plus
    an `<a download>` attribute on the page.
- **Public:** in `public-bookings.controller.ts` (booking plan), add
  `itinerary-url`. It is rate-limited like the view, resolves the token with
  `db.system`, then loads the pinned version in `db.tenant`. It returns a
  404 unless the link state is live or completed and the version is ready.
  - Only the **sanitised** output is ever served. Source uploads never get a
    public URL.
- **Outbox topic:** `itinerary.version.created`. No other side effects.
- **New dependency:** `@cantoo/pdf-lib` in `apps/api/package.json`, as the
  API runs jobs in-process on the free tier (`JOBS_MODE=in-process`).

### App (`apps/driver-app`)

- **Models and API:**
  - `owner_models.dart`: `Itinerary`, `ItineraryVersion`, `ItinerarySummary`,
    `TripItinerary`.
  - `Trip.itinerary` (`models.dart`); `BusinessSettings`.
  - `OwnerApi` methods for each route above.
  - `TaxcyApi.itineraryUrl(tripId, download)` for drivers.
  - `MediaKind` `itinerary` in `pickDocumentFiles` callers (`file_pick.dart`).
- **Gating:** `businessSettingsProvider` (`GET /settings/business`, loaded
  with the owner shell). All itinerary UI checks `offersTours`.
- **Library:** `lib/features/owner/itineraries/`
  - `itineraries_screen.dart`: list, CardGrid on desktop.
  - `itinerary_detail_screen.dart`: versions, replace, edit, archive.
  - `itinerary_form.dart`: create and edit, with the picker and upload via
    `uploadPhotoNow`.
  - `itinerary_picker.dart`: a searchable sheet on phones, a dialog on
    desktop.
  - Polling uses a `FutureProvider.family` with backoff.
- **Navigation:**
  - The desktop sidebar adds `OwnerSection.itineraries` under FLEET, only
    when `offersTours` (`lib/features/owner/desktop_shell.dart`).
  - Phone and tablet add an entry in More.
- **Trip:**
  - `owner_trip_detail_screen.dart` gets an `_ItineraryCard`.
  - The create and edit trip forms get the picker.
  - The driver's `trip_detail_screen.dart` gets an `_ItineraryRow`
    (View/Download, offline-disabled using the connectivity provider the sync
    engine already uses).
- **Share** (the booking plan's `booking_share.dart` and `booking_pdf.dart`):
  - The message line.
  - The PDF sheet with three options.
  - New dependency: `pdf_combiner ^6.2.2` for the combined option.
  - Multi-file share via `share_plus` (added by the booking plan).
- **Settings:** a `_BusinessSection` with the switch.
- **Public page** (`web/booking.js`): an itinerary card with View and
  Download, which call `itinerary-url` and then open or download. The en/hi
  strings live in the page dictionary.

**New l10n keys:**

| Key                         | English                                                                  | Hindi                                                                           |
| --------------------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| businessSettings            | Business                                                                 | व्यवसाय                                                                         |
| offersTours                 | We plan tours                                                            | हम टूर प्लान करते हैं                                                           |
| offersToursHint             | Show an itinerary library and attach day plans to bookings.              | यात्रा-योजना लाइब्रेरी दिखाएँ और बुकिंग के साथ दिन-वार योजना जोड़ें।            |
| itineraries                 | Itineraries                                                              | यात्रा-योजनाएँ                                                                  |
| itinerary                   | Itinerary                                                                | यात्रा-योजना                                                                    |
| noItineraries               | No itineraries yet                                                       | अभी कोई यात्रा-योजना नहीं                                                       |
| noItinerariesHint           | Upload a tour plan once and attach it to any booking.                    | टूर प्लान एक बार अपलोड करें और किसी भी बुकिंग से जोड़ें।                        |
| addItinerary                | Add itinerary                                                            | यात्रा-योजना जोड़ें                                                             |
| itineraryTitle              | Title                                                                    | शीर्षक                                                                          |
| itineraryNights             | Nights                                                                   | रातें                                                                           |
| itineraryDays               | Days                                                                     | दिन                                                                             |
| itineraryHighlights         | Highlights (optional)                                                    | मुख्य बातें (वैकल्पिक)                                                          |
| uploadItineraryFiles        | Upload PDF or photos                                                     | PDF या फ़ोटो अपलोड करें                                                         |
| itineraryUploadHint         | One PDF, or up to 10 photos, each under 15 MB.                           | एक PDF, या 10 तक फ़ोटो, हर एक 15 MB से कम।                                      |
| itineraryPreparing          | Preparing…                                                               | तैयार हो रही है…                                                                |
| itineraryReady              | Ready                                                                    | तैयार                                                                           |
| itineraryPages              | {count, plural, =1{1 page} other{{count} pages}}                         | {count, plural, =1{1 पेज} other{{count} पेज}}                                   |
| itineraryFailedEncrypted    | This PDF is password-protected. Remove the password and upload again.    | यह PDF पासवर्ड से सुरक्षित है। पासवर्ड हटाकर फिर से अपलोड करें।                 |
| itineraryFailedUnreadable   | We couldn't read this file. Try another PDF.                             | यह फ़ाइल पढ़ी नहीं जा सकी। कोई दूसरी PDF आज़माएँ।                               |
| itineraryFailedTooManyPages | Itineraries can have up to 60 pages.                                     | यात्रा-योजना में अधिकतम 60 पेज हो सकते हैं।                                     |
| itineraryFailedTooLarge     | The itinerary is over 20 MB. Use a smaller file.                         | यात्रा-योजना 20 MB से बड़ी है। छोटी फ़ाइल इस्तेमाल करें।                        |
| itineraryMixedFiles         | Upload either one PDF or photos, not both.                               | या तो एक PDF या फ़ोटो अपलोड करें, दोनों नहीं।                                   |
| replaceItineraryFile        | Replace file                                                             | फ़ाइल बदलें                                                                     |
| archiveItinerary            | Archive                                                                  | संग्रह में डालें                                                                |
| showArchived                | Show archived                                                            | संग्रहीत दिखाएँ                                                                 |
| usedOnUpcomingTrips         | {count, plural, =1{On 1 upcoming trip} other{On {count} upcoming trips}} | {count, plural, =1{1 आने वाली यात्रा में} other{{count} आने वाली यात्राओं में}} |
| chooseFromLibrary           | Choose from library                                                      | लाइब्रेरी से चुनें                                                              |
| uploadForThisTrip           | Upload for this trip only                                                | सिर्फ़ इस यात्रा के लिए अपलोड करें                                              |
| viewItinerary               | View                                                                     | देखें                                                                           |
| downloadItinerary           | Download                                                                 | डाउनलोड                                                                         |
| removeItinerary             | Remove itinerary                                                         | यात्रा-योजना हटाएँ                                                              |
| itineraryOutdated           | A newer version of this itinerary exists.                                | इस यात्रा-योजना का नया संस्करण मौजूद है।                                        |
| useLatestVersion            | Use latest                                                               | नया इस्तेमाल करें                                                               |
| needsInternet               | Needs internet                                                           | इंटरनेट चाहिए                                                                   |
| downloadBeforeSignalHint    | Use Download before you lose signal.                                     | नेटवर्क जाने से पहले डाउनलोड कर लें।                                            |
| itineraryMessageLine        | Itinerary: {title} ({pages}) · view or download at the link below        | यात्रा-योजना: {title} ({pages}) · नीचे दिए लिंक पर देखें या डाउनलोड करें        |
| warnItineraryNotReady       | The itinerary is still being prepared; it won't be included.             | यात्रा-योजना अभी तैयार हो रही है; यह शामिल नहीं होगी।                           |
| pdfConfirmationOnly         | Confirmation only                                                        | सिर्फ़ पुष्टि                                                                   |
| pdfWithItineraryTwoFiles    | Confirmation + itinerary (2 files)                                       | पुष्टि + यात्रा-योजना (2 फ़ाइलें)                                               |
| pdfCombined                 | One combined PDF                                                         | एक संयुक्त PDF                                                                  |
| pdfCombineFailed            | Couldn't combine; sharing as two files.                                  | जोड़ नहीं सके; दो फ़ाइलों के रूप में भेज रहे हैं।                               |
| warnPdfOver25Mb             | Over 25 MB: email may not accept it.                                     | 25 MB से बड़ी: ईमेल शायद स्वीकार न करे।                                         |

### Security and tenancy

- **Who can do what:**
  - Staff manage the library and attachments (role check + RLS on the three
    new tables).
  - Owners toggle the feature.
  - Drivers only get a URL for a trip assigned to them: `/trips/{id}/itinerary/url`
    uses the same visibility rule as `GET /trips/{id}`.
- **Uploads:**
  - Magic-byte sniffing, not the declared type.
  - Size caps in (15 MB per file, already enforced) and out (20 MB).
  - A page cap.
  - Random storage keys (existing).
  - The server re-builds every PDF and drops active content. This is content
    disarm and reconstruction in the OWASP sense.
  - Images are re-embedded into a new PDF, never served as uploaded.
- **Serving:**
  - Only sanitised outputs, through presigned GETs valid for 5 minutes,
    issued per request (staff, driver or valid booking token).
  - The public route has the same 404 rules, rate limits and `db.system`
    token lookup as the booking plan.
  - Source media keep `kind = itinerary` and are never exposed on public
    routes.
- **Enumeration:** version and media ids are UUIDs, and public access only goes
  through the booking token.
- **Malware:** sanitising removes active PDF content. Full antivirus
  scanning (ClamAV) is out of scope on Render free; see risks.
- **Feature off:** writes return `FEATURE_DISABLED`. Already attached
  itineraries keep showing to customers and drivers, since data isn't
  deleted, until the owner removes them.

### Failure modes

| Failure                                              | Behaviour                                                                                                                                                     |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Password-protected or corrupt PDF                    | The version becomes `failed` (`ENCRYPTED` / `UNREADABLE`), with the reason shown and **Replace file** offered. The trip can't pin it (`ITINERARY_NOT_READY`). |
| Job runner down or slow                              | The version stays `processing`. The UI shows "Preparing…" and sharing proceeds without the itinerary, with a warning. The job retries per the outbox policy.  |
| Duplicate tap on save or upload                      | Client ids make `POST /itineraries` and `/versions` idempotent. Media upload is already idempotent by id.                                                     |
| Library edited after a booking is confirmed          | The trip stays pinned and the customer keeps seeing the same file. The owner sees "newer version" and chooses **Use latest**.                                 |
| Itinerary archived                                   | Hidden from pickers; attached trips keep working.                                                                                                             |
| Feature turned off with attachments                  | Existing attachments remain visible; the UI to change them is hidden.                                                                                         |
| Signed URL expires on a slow phone                   | View and Download fetch a fresh URL on each tap.                                                                                                              |
| B2 ignores the response-content-disposition override | Inline still works (stored header). The page's Download uses a `fetch` → `Blob` → `<a download>` fallback for files ≤ 20 MB.                                  |
| Combined PDF merge fails (malformed or huge)         | Fall back to two files with the `pdfCombineFailed` snackbar.                                                                                                  |
| Driver offline                                       | The metadata shows from cache, and View/Download are disabled ("Needs internet"). Previously downloaded copies are in the phone's Downloads.                  |
| Upload interrupted                                   | The media stays `pending`. Creating a version rejects it with `MEDIA_NOT_UPLOADED`, and the app re-runs the upload.                                           |

### Seed and docs

- **Seed** (`apps/api/src/seed/seed.ts`):
  - Sharma Travels: `offersTours = true`, library entries "Kerala 4N/5D" and
    "Mahabaleshwar 1N/2D", each with a small generated 2-page PDF made with
    `@cantoo/pdf-lib` at seed time (no binary files in the repo).
  - Attach "Mahabaleshwar 1N/2D" to Imran's evening trip.
  - Patil Cabs stays off.
  - Update `docs/usage/demo-data.md` and `seed.int.test.ts`.
- **Docs:**
  - `docs/usage/itineraries.md` (new).
  - `docs/architecture.md`: the processing job and sanitising.
  - `docs/deployment.md`: no new env vars; note the new API dependency and
    the B2 check.
  - `docs/decisions.md`: D21–D23.

### Proposed decisions

| #   | Question                                       | Decision                                                                                                                                                           | Consequences                                                                                                                                                                                                              |
| --- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| D21 | Itineraries _(proposed)_                       | **An opt-in fleet feature ("We plan tours"): a library of itineraries with immutable versions; trips pin one version; one-off uploads are hidden library entries** | `org_settings.offers_tours`, plus the `itineraries`, `itinerary_versions` and `trip_itineraries` tables (RLS). Confirmed bookings never change under the customer, and library edits surface as "newer version" on trips. |
| D22 | Uploaded files shown to customers _(proposed)_ | **Never serve uploads as-is: the server rebuilds PDFs (`@cantoo/pdf-lib`), drops active content, wraps images into PDF; only the output is served**                | Adds a `media.storeGenerated` path and a `MediaKind.itinerary`. PDF, JPG and PNG are accepted; DOCX isn't (planners save as PDF). No ClamAV on the free tier. Caps: 10 files, 15 MB each, 60 pages, 20 MB out.            |
| D23 | Driver access to itineraries _(proposed)_      | **Online view + download to the phone; no in-app offline cache**                                                                                                   | Simple and storage-free. Drivers are told to download before losing signal. The cached trip JSON keeps the metadata, so the row still shows offline.                                                                      |

## Implementation plan

Steps 6 and 9 need the booking plan's public page and share card. Steps 1–5,
7 and 8 don't.

### Step 1 — Itinerary rules exist and are tested

Files: `libs/domain/src/itineraries/{sniff,sources,actions,output,pinned,names}.ts` + `*.test.ts` (new), `libs/domain/src/index.ts`
Change:

- Implement `sniffUpload`, `checkSources`, `pdfActionPolicy`, `checkOutput`,
  `pinnedStatus`, `itineraryFileName`, `nightsDaysLabel` and
  `ITINERARY_LIMITS`.

Tests: every row of the table above, plus WebP RIFF detection, empty input,
and a 60-char cap on the file name.
Verify: `bunx nx run @taxcy/domain:test`
Commit: `feat(domain): itinerary upload checks, PDF action policy and naming`
Size: S

### Step 2 — The schema holds libraries, versions and trip pins

Files: `libs/db/prisma/schema.prisma`, `libs/db/prisma/migrations/…_media_kind_itinerary/migration.sql` (enum value only), `libs/db/prisma/migrations/…_itineraries/migration.sql`
Change:

- Add the `MediaKind` value, `OrgSettings.offersTours` and the three models.
- Hand-add the RLS policies, grants, CHECKs and partial index.
- Delete any drops of unmodelled objects from the generated SQL.

Tests: `apps/api/test/itineraries.int.test.ts` (new):

- Another org can't read the rows (RLS).
- The CHECK rejects `ready` without `media_id`.
- `(itinerary_id, version)` is unique.

Verify: `bun run db:migrate && bun run db:drift && bun run test:integration`
Commit: `feat(db): itinerary library, versions and trip itineraries`
Size: S

### Step 3 — Contracts and client

Files: `libs/contracts/src/routes/{itineraries,media,trips,fleet}.ts`, `libs/contracts/src/index.ts`, `libs/api-client` (regenerated)
Change:

- The routes in the table, `Trip.itinerary`, the business settings, and
  `MediaKind.itinerary`.
- Errors `FEATURE_DISABLED`, `MEDIA_NOT_UPLOADED` and `ITINERARY_NOT_READY`.

Tests: schema limits (title 80, highlights 1,000, `mediaIds` 1–10).
Verify: `bunx nx run @taxcy/contracts:test && bun run api:client && bunx nx run @taxcy/api:typecheck`
Commit: `feat(contracts): itineraries, trip itinerary and business settings`
Size: S

### Step 4 — Owners build a library; uploads become sanitised PDFs

Files: `apps/api/src/modules/itineraries/{itineraries.module,itineraries.controller,itineraries.service,itinerary.processor,pdf-sanitiser}.ts` (new), `apps/api/src/modules/media/media.service.ts` (`storeGenerated`, `viewUrl` disposition), `apps/api/src/modules/fleet/` (business settings get/patch), `apps/api/package.json` (`@cantoo/pdf-lib`), `apps/api/test/fixtures/pdfs/` (generated in the test setup, not committed binaries)
Change:

- Library CRUD with feature gating, and the `MEDIA_NOT_UPLOADED` check.
- Versions plus the outbox event.
- The processor (PDF rebuild, annotation-action stripping, images → PDF,
  limits), and `storeGenerated`.

Tests:

- **Unit** (`pdf-sanitiser.test.ts`), with fixtures built in the test:
  - A PDF with a document-level JavaScript OpenAction, an embedded file, a
    Launch link and an https link. The output has none of the first three,
    keeps the https link, and keeps the page count.
  - An encrypted PDF gives `ENCRYPTED`.
  - Garbage bytes give `UNREADABLE`.
  - 61 pages give `TOO_MANY_PAGES`.
  - 3 JPGs give a 3-page A4 PDF.
- **Integration:**
  - Version create → job → `ready`, with the media `uploaded` and the
    content type PDF.
  - A pending media gets `MEDIA_NOT_UPLOADED`.
  - With the feature off, writes get `FEATURE_DISABLED`.
  - Re-running the job is a no-op.

Verify: `cd apps/api && bunx vitest run src/modules/itineraries && bun run test:integration`
Commit: `feat(api): itinerary library with sanitised PDF versions`
Size: M–L

### Step 5 — Trips pin itineraries; staff and drivers open them

Files: `apps/api/src/modules/itineraries/trip-itinerary.{controller,service}.ts` (new), `apps/api/src/modules/trips/trips.repository.ts` (include), the trips mapper (the `Trip.itinerary` field)
Change:

- Attach, detach and one-off (one transaction), with trip events.
- `GET /trips/{id}/itinerary/url` with disposition and file name.
- `pinned: current | outdated`.

Tests (integration):

- Attaching a failed version gets `ITINERARY_NOT_READY`.
- A one-off creates a hidden entry missing from `GET /itineraries`.
- After a new library version, the trip reports `outdated`.
- The assigned driver gets a URL; another driver gets `NOT_FOUND`.
- Another org's version id gets `NOT_FOUND`.

Verify: `bun run test:integration`
Commit: `feat(api): attach itineraries to trips and serve signed links`
Size: M

### Step 6 — Customers get the itinerary from the booking link

_Needs booking plan Step 5._

Files: `apps/api/src/modules/bookings/{public-bookings.controller,booking-view.service}.ts` (edit)
Change:

- Add `BookingView.itinerary` (ready only).
- Add `GET /public/bookings/{token}/itinerary-url`, rate-limited.
- Verify B2 honours `response-content-disposition` (a manual check against
  the real bucket, recorded in the PR).

Tests (integration):

- The view includes the itinerary only when it's ready.
- The URL is served for live and completed links, and gives a 404 for
  expired or revoked ones.
- The response never contains source media ids.

Verify: `bun run test:integration`
Commit: `feat(api): itinerary in the public booking view`
Size: S

### Step 7 — Owners turn it on and manage the library in the app

Files: `lib/core/api/{owner_models,models,owner_api}.dart`, `lib/features/owner/settings_screen.dart` (`_BusinessSection`), `lib/features/owner/itineraries/*` (new), `lib/features/owner/desktop_shell.dart` and the phone More menu (nav entry), `lib/l10n/app_en.arb` + `app_hi.arb`, `test/support/owner_fakes.dart`
Change:

- Models, the provider gating, and the list, detail, form and picker
  screens with polling.
- Upload through `uploadPhotoNow` with kind `itinerary`.

Tests:

- `test/itineraries_test.dart`:
  - Hidden when off.
  - Create → Preparing → Ready.
  - A failed reason shows.
  - Archive hides the entry from the picker.
  - Desktop CardGrid and sidebar entry.
- `test/owner_models_test.dart`: parsing.
- `test/l10n_test.dart`: the library in Hindi.

Verify: `cd apps/driver-app && flutter analyze --fatal-infos && flutter test`
Commit: `feat(app): itinerary library and the "We plan tours" setting`
Size: M

### Step 8 — Trips show itineraries to staff and drivers

Files: `lib/features/owner/trips/owner_trip_detail_screen.dart` (`_ItineraryCard`), the create and edit trip forms (picker), `lib/features/trips/trip_detail_screen.dart` (`_ItineraryRow`), `lib/core/api/http_api.dart` (driver `itineraryUrl`)
Change:

- Attach from the library, one-off upload, View/Download/Remove, and
  "Use latest".
- The driver row, disabled offline.

Tests:

- `test/owner_flows_test.dart`: attach, outdated → use latest, remove.
- `test/widgets_test.dart`: the driver row opens a URL with
  `download=true`, and is disabled when offline.

Verify: `cd apps/driver-app && flutter analyze --fatal-infos && flutter test`
Commit: `feat(app): itineraries on trips for owners and drivers`
Size: M

### Step 9 — Itineraries go out with every share option

_Needs booking plan Steps 7–9._

Files: `lib/features/owner/trips/{booking_share,booking_pdf}.dart` (edit), `pubspec.yaml` (`pdf_combiner`), `apps/driver-app/web/booking.js` + `booking.html` (itinerary card)
Change:

- The message line.
- The PDF sheet (only, 2 files, combined), with the fallback and the size
  warning.
- The page card with View/Download and the `<a download>` fallback.

Tests:

- `test/booking_share_test.dart`: the message has the itinerary line only
  when it's ready, and the not-ready warning shows.
- `test/booking_pdf_test.dart`:
  - The 2-files option passes two `application/pdf` files.
  - The combined option calls the combiner (faked) and falls back on error.
- Manual: Android share to WhatsApp (both modes), web download, and the page
  at 360 px in English and Hindi.

Verify: `cd apps/driver-app && flutter analyze --fatal-infos && flutter test && flutter build web`
Commit: `feat(app): share itineraries with booking confirmations`
Size: M

### Step 10 — Seed, docs and decisions

Files: `apps/api/src/seed/seed.ts`, `apps/api/test/seed.int.test.ts`, `docs/usage/demo-data.md`, `docs/usage/itineraries.md` (new), `docs/architecture.md`, `docs/deployment.md`, `docs/decisions.md` (D21–D23 accepted)
Change:

- The demo library and attachment, as described above.
- The docs as listed.

Tests: the seed integration test asserts two ready versions and the attachment
on Imran's trip.
Verify: `bun run db:reset && bun run test:integration && bun run verify`
Commit: `docs: itineraries; seed a demo library`
Size: S

**Total:** about 8 working days, on top of the booking plan.

## Risks and mitigations

1. **Sanitising misses an active-content path** (exotic annotations, XFA
   forms, malformed files that parse differently in viewers).
   - Mitigations: rebuild into a new document, never copy the catalog-level
     objects, strip all non-allow-listed actions, and keep a fixture suite of
     hostile PDFs.
   - Add qpdf repair, or ClamAV on a paid worker, if real uploads show
     problems.
2. **Memory and CPU on Render free (the API runs jobs in-process).** One job
   at a time for this topic, capped input and output, and pages copied
   without rasterising. Move it to the workers service when on a paid plan.
3. **B2 and presigned response overrides.** This is verified in Step 6, and
   the fallbacks (stored `Content-Disposition: inline` and the page's blob
   download) keep View and Download working either way.
4. **`pdf_combiner` native or web quirks.** It's only used for the optional
   combined PDF, behind a provider, with a two-file fallback.
5. **Storage growth.** Every version and one-off keeps its source and output.
   Storage is cheap at this scale; an orphan and old-version cleanup job is
   out of scope and noted in the roadmap.

## Out of scope

- A structured day-by-day itinerary builder (option C).
- DOCX/ODT conversion.
- ClamAV scanning.
- An in-app PDF viewer and an offline in-app cache for drivers.
- Sending an itinerary to a prospect without a booking.
- Pricing or packages (hotels, meals) as structured data.
- Fixing `documents.service.ts` `assertMedia` to require `uploaded` (a
  separate small fix; recommended next).
- Media orphan cleanup.

## Open questions

1. **Does B2 honour `response-content-disposition` on presigned GETs?**
   _Recommended:_ verify in Step 6. If not, the fallbacks are already in the
   design.
2. **Accept WebP itineraries?**
   _Recommended:_ only if `sharp` is already in the API. Otherwise accept
   JPG and PNG in v1; the app's picker already offers WebP, so filter it for
   kind `itinerary`.
3. **Should sharing to a prospect (before a booking exists) be possible from
   the library?**
   _Recommended:_ a follow-up, "Share itinerary" in the library, reusing a
   token like the booking link.
4. **Add a structured "day plan" text later?**
   _Recommended:_ yes, as an optional addition (option C-lite: a few lines
   per day shown on the booking page) once planners ask for it.

## Done when

- [ ] The five acceptance checks above pass.
- [ ] The hostile-PDF fixture suite passes (no JavaScript, Launch, embedded files or OpenAction in the outputs).
- [ ] `bun run verify`, `bun run test:integration` and `flutter test` are green; `flutter analyze --fatal-infos` is clean; `flutter build web` succeeds.
- [ ] Manual checks pass:
  - Library and trip card on phone (360 px), tablet and desktop (1440 px).
  - The driver's View and Download on Android, and offline-disabled.
  - The booking page itinerary card in English and Hindi.
  - Share as PDF (2 files and combined) to WhatsApp on Android, and download on web.
- [ ] D21–D23 are accepted in `docs/decisions.md`.
