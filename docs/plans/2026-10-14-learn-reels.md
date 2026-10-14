# Learn: how-to reels

Status: proposed · Date: 2026-10-14 · Owner: Hritambh Hritvij

## Problem and outcome

New owners and drivers don't know how to log a fuel fill, start a trip with an
odometer photo, or settle a driver's day. The app has no help at all: only
intro and hint strings on a few screens (`fuelIntro`, `settlementsIntro`,
`noTripsHint` in `apps/driver-app/lib/l10n/app_en.arb`). Today someone has to
show them in person or explain on WhatsApp.

**Outcome:** a signed-in owner, manager or driver opens **Learn** and watches
short vertical "reels" (under a minute, voiced in English or Hindi). They swipe
from one to the next, as in Rapido Captain's or Uber Driver's training videos.
They can also **jump straight to the exact reel** they need: from a **"Watch
how"** button on the screen they're stuck on, from search, or from a link an
owner sends a driver on WhatsApp.

## Who and where

- **Owner and manager:** in owner mode, Learn is a section in the desktop
  sidebar (≥1100 px) and an item under More on phones and tablets. Owner mode
  is online-first (D12).
- **Driver:** in driver mode, Learn is a tile on the Profile tab, and a "New to
  Fleet Sarthi?" card on the home screen until they've watched a few reels.
  Driver mode is offline-first, but **video needs internet**. Offline, a reel
  shows its written steps and a "connect to watch" notice. Downloading reels for
  offline viewing is out of scope.
- **DCO (owner-driver):** sees both the owner and the driver reels, with the
  current mode's reels first.
- **Signed out:** no Learn. This was your choice (2026-10-14). The welcome page
  keeps its own mock showcase.
- **Form factors:** Android phones and the web build. The player is full-screen
  9:16 on phones. On wide screens it's a centred 9:16 frame over a dark
  backdrop.

## Acceptance checks

1. A driver on the Log fuel screen taps **Watch how**. The "Log a fuel fill"
   reel plays at once, in Hindi if the app is in Hindi. Swiping up plays the
   next fuel reel, and closing the player returns them to the form they were
   filling in, unchanged.
2. An owner opens Learn, types "settle" in search, and taps the single result.
   It plays. Reels they've watched show a tick in the list.
3. An owner shares a reel to a driver on WhatsApp. On the web, tapping the link
   (`…/learn/driver.log-fuel`) opens the app on that reel once the driver is
   signed in, or straight after they sign in.
4. Offline, a driver opening a reel sees its written steps and "You're offline",
   with no spinner that never ends. The Learn list still shows the last catalog
   it loaded.
5. A new reel, or a re-recorded video, goes live by uploading to the bucket and
   updating the catalog. **No app release is needed**, unless an in-app "Watch
   how" button should point at it.

## Options considered

| Option                                               | Sketch                                                                                                                                                                                                                                        | Touches                                    | Effort                                 | Main risk                                                                                                                                                                                                           |
| ---------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A. Smallest: reel list in Dart, videos in the bucket | The reel list (ids, titles in ARB, video paths) is a Dart `const`. MP4s live in a public B2 bucket. Learn screen, player and "Watch how" buttons.                                                                                             | App only                                   | M (2–3 days of code)                   | Every new reel or title fix needs an app release and a Play Store update. Titles in ARB mean 2 strings × 2 languages per reel.                                                                                      |
| **B. Proper: remote catalog + per-language videos**  | A reviewed `content/learn/catalog.json` in git (ids, topics, audience, en and hi titles, steps, video paths) is uploaded to the public bucket next to the MP4s. The app fetches and caches it, and stable reel ids are the deep-link handles. | App, content pipeline, docs (no API or DB) | M–L (3–4 days of code, plus recording) | A public bucket means "signed-in only" is a UX gate, not a secret. Catalog and app can drift if an id changes.                                                                                                      |
| C. Lateral: guided walkthroughs instead of video     | A "Show me" button runs a coach-mark tour over the live screen (highlight a field, then the next…), with text from ARB.                                                                                                                       | App only                                   | M                                      | Always matches the current UI, works offline and costs no recording. But it isn't the reel experience you asked for, it's fragile across layouts, and drivers who read little get less from it than a voiced video. |

## Chosen approach and why

**B.** You chose per-language voiceover and a public B2 bucket. Videos will be
re-recorded as the UI changes, so the list of reels has to change without an app
release, and only a remote catalog allows that. Stable reel ids give us one
deep-link handle for the in-app buttons, search and shared links. C is a good
complement later (see Out of scope).

## Research findings

### Codebase

- **No routing or deep links.** The app has a single `home: const _Root()`
  (`apps/driver-app/lib/app/app.dart:30`), and screens are pushed imperatively
  with `openScreen` (`apps/driver-app/lib/features/owner/owner_widgets.dart:626`).
  The only other `onGenerateRoute` is per desktop section
  (`lib/features/owner/desktop_shell.dart:106`). The Android manifest has only
  the launcher intent filter, and nothing reads `Uri.base`.
- **Owner navigation:**
  - Desktop sections come from `enum OwnerSection`
    (`lib/features/owner/desktop_shell.dart:21-29`). Each section gets its own
    nested Navigator. `navGroupSetup` holds only Settings
    (`desktop_shell.dart:208`).
  - On phones and tablets, `MoreScreen` (`lib/features/owner/owner_shell.dart:104`)
    lists items with keys such as `more-settings` (`:168`) and
    `more-account-security` (`:174`).
- **Driver navigation:**
  - Profile tiles include `profile-language` and `profile-security`
    (`lib/features/driver/driver_profile_screen.dart:227`, `:234`).
  - `DriverQuickActions` (`lib/features/trips/driver_home.dart:467`) already
    has three buttons in a row (`driver-action-new-trip`, `-fuel`, `-sync`,
    ending at `:522`). A fourth would crowd a 360 px phone.
- **Screens that get a "Watch how" button:**
  - Driver: `FuelFillScreen` (`lib/features/fuel/fuel_fill_screen.dart:19`,
    app bar at `:88`); `StartTripScreen` and `EndTripScreen`
    (`lib/features/trips/trip_forms.dart:35`, `:143`).
  - Owner: `CreateTripScreen` (`lib/features/owner/trips/create_trip_screen.dart:115`);
    `VehicleFormScreen` (`lib/features/owner/vehicles_screen.dart:240`);
    `DocumentFormScreen` (`lib/features/owner/documents_screen.dart:571`);
    `SettlementsScreen` (`lib/features/owner/settlements_screen.dart:15`).
- **Sharing:** `urlOpenerProvider` (`lib/features/owner/trips/trip_share.dart:14`)
  and `whatsAppUri` (`trip_share.dart:48`) already build wa.me links and are
  faked in tests. The share-a-reel feature reuses them.
- **Media and storage:**
  - There are no video or image-cache packages in `apps/driver-app/pubspec.yaml`.
    Remote photos use plain `Image.network` with signed URLs.
  - The B2 media bucket is **private**, with signed URLs from the API
    (`docs/deployment.md:212`; `S3_BUCKET` in `render.yaml:95`; `viewUrl()` in
    `apps/api/src/modules/media/media.service.ts:152`, which signs for 300 s).
    So reels need their own **public** bucket, and nothing in the API changes.
- **Hosting limits:** the web app is a Render static site with a reported
  **5 GB/month** bandwidth cap (`docs/deployment.md:146`), so videos must not be
  served from it. APKs are about 24 MB (arm64 split) and about 66 MB universal
  (`docs/deployment.md:53-54`), so bundling videos is out.
- **Build-time config:** the web build already passes `--dart-define=API_URL`
  (`infra/render/build-web.sh:30`). A `LEARN_MEDIA_URL` define fits next to it.
- **Language:** the app follows D13, with UI text in ARB. Reel titles and steps
  are content that changes without a release, so this plan proposes keeping them
  in the catalog instead (D25 below).

### External

- **[video_player](https://pub.dev/packages/video_player/versions/2.12.0)**
  (Flutter team; Android uses ExoPlayer, the web uses an HTML `<video>`). It
  plays progressive MP4 on both. Version 2.12.0 is listed on pub.dev, but Flutter
  Gems shows 2.11.1 (May 2026), so pin whatever `flutter pub add` resolves.
  _Unverified: the exact latest version._ HLS or adaptive bitrate isn't needed
  for sub-minute 720p clips. [Mux's guide](https://www.mux.com/articles/flutter-video-player-hls-streaming-guide)
  and [Better Player](https://pub.dev/documentation/better_player/1.18.0/) cover
  heavier needs we don't have.
- **[Chrome's autoplay policy](https://developer.chrome.com/blog/autoplay):**
  muted autoplay is always allowed, and sound needs a prior user interaction on
  the site. Opening Learn or a reel is a tap, so playing with sound should work.
  If `play()` is still rejected, the player starts muted with "Tap for sound".
  (Article first published 2017 and still current; how `video_player_web`
  surfaces the rejection is unverified.)
- **Backblaze B2 egress:** free up to **3× the data stored**, then $0.01/GB
  ([Backblaze developers](https://www.backblaze.com/cloud-storage/solutions/developers);
  a [2023 announcement quoted on a forum](https://forum.duplicacy.com/t/how-to-download-without-fees-from-from-backblaze-b2/7725)).
  Routing through Cloudflare makes B2 egress free under the
  [Bandwidth Alliance](https://www.backblaze.com/blog/backblaze-and-cloudflare-partner-to-provide-free-data-transfer/),
  but serving video on Cloudflare's _free_ plan may break its terms
  (forum reports, unverified). Example: 30 reels × 2 languages × about 5 MB is
  about 300 MB stored, so about 0.9 GB/month of free egress, roughly 180 full
  views. **Plan for Cloudflare (paid) or R2 once reels are watched beyond
  pilots.**
- **Rapido Captain:** third-party guides describe a mandatory "training course"
  of short videos during captain onboarding
  ([registration guide](https://m.indiacustomercare.com/procedure-registered-rapido-captain),
  undated, unverified). That supports short, task-sized videos. Making them
  mandatory is out of scope.

## Design

### User flows

**Learn home** (owner section or More item; driver Profile tile; the driver
home card):

1. A header, "Learn", with a search field.
2. **Start here:** the first three reels for this role not yet watched. The row
   is hidden once all are watched.
3. Rows by topic: Getting started, Trips, Fuel, Money, Documents, Drivers &
   vehicles, Offline & sync. Each row holds horizontal 9:16 cards with the
   poster, title, duration and a tick if watched.
4. A DCO gets two tabs, **For owners** and **For drivers**, with the current
   mode's tab first. Single-role users see only theirs.
5. **Search** filters titles and steps in the current language, as you type.
   With no matches it shows "No videos match "…"".

**Player** (opened from a card, a "Watch how" button, search or a link):

1. Full-screen vertical pager. Each page is one reel. The video fills 9:16, and
   the overlay shows the title, a progress bar, mute, a **Steps** sheet, share
   (owners and managers) and close.
2. The pager holds the reels of the opened reel's topic (and audience), in
   catalog order. Swipe up for next and down for previous. At the end of a reel
   it shows "Next: …" and moves on after 3 s, unless the user has paused.
3. Tapping pauses and resumes.
4. The video plays in the app's language, and falls back to English with an
   "Available in English only" chip.
5. A reel is marked watched (on this device) after 80% of its length.
6. On desktop, the up and down arrow keys change reels, and Esc closes.

**States:**

- **Loading catalog:** skeleton cards.
- **Catalog fetch failed with no cache:** an error with Retry.
- **Fetch failed with a cache:** the cached catalog, silently.
- **Video buffering:** the poster with a spinner.
- **Video failed:** try the fallback language, then show "Couldn't play this
  video" with the steps and Retry.
- **Offline:** the poster greyed out, "You're offline. Connect to the internet
  to watch this video.", and the steps listed.
- **Unknown reel id** (stale link or button): open Learn home with a snackbar,
  "This video isn't available any more."

**Watch how buttons:**

- An icon button with a play-in-circle icon and the tooltip "Watch how" in the
  app bar of the mapped screens.
- It's shown only when the catalog has that reel for the user's audience, so a
  missing reel never leaves a dead button.

**Shared links:**

- Owners tap share in the player to open WhatsApp with
  "<title>: Fleet Sarthi video: https://<web host>/learn/<id>".
- On the web, the app reads `Uri.base.path` at startup. If it's `/learn/<id>`,
  that becomes a **pending reel**, which opens once a session exists (now, or
  after sign-in).
- On Android the link opens the browser (the web app) until App Links are added
  (Out of scope).

```mermaid
flowchart LR
  A[Watch how button] --> P[Player at reel id]
  B[Learn search / card] --> P
  C[/learn/:id link] -->|signed in| P
  C -->|signed out| L[Welcome → Sign in] --> P
  P -->|swipe| P2[Next reel in topic]
  P -->|offline| S[Steps + offline notice]
```

### Domain rules

There's no `libs/domain` change: this is client content, not business logic.
The pure Dart rules live in `lib/features/learn/learn_rules.dart` and get
table-driven tests:

```dart
/// Reels a person can see: their audiences (driver, owner; manager → owner),
/// the current mode first, and none that need a newer app build.
List<Reel> reelsFor(LearnCatalog c, {required Set<Audience> audiences,
    required Audience current, required int appBuild});

/// The pager for an opened reel: same topic and audience, catalog order.
({List<Reel> reels, int index}) pagerFor(LearnCatalog c, String reelId,
    {required Set<Audience> audiences, required int appBuild});

/// Video to play: the language's file, else English, else null.
({String path, bool fallback})? videoFor(Reel r, String languageCode);

/// Case- and diacritic-insensitive match on title and steps in [lang].
List<Reel> search(List<Reel> reels, String query, String lang);

/// "/learn/driver.log-fuel" → "driver.log-fuel"; anything else → null.
String? reelIdFromPath(String path);
```

| Rule           | Input                                    | Output                              |
| -------------- | ---------------------------------------- | ----------------------------------- |
| reelsFor       | driver-only user, reel audiences [owner] | excluded                            |
| reelsFor       | DCO in driver mode                       | driver reels, then owner reels      |
| reelsFor       | manager                                  | same as owner                       |
| reelsFor       | reel `minAppBuild` 90, app build 76      | excluded                            |
| pagerFor       | id `driver.end-trip` in topic trips      | trips reels, index of end-trip      |
| pagerFor       | unknown id                               | null (caller shows "not available") |
| videoFor       | hi present, lang hi                      | hi path, fallback false             |
| videoFor       | hi missing, lang hi                      | en path, fallback true              |
| videoFor       | neither present                          | null                                |
| search         | "SETTLE" in en                           | matches "Settle a driver's day"     |
| search         | "ईंधन" in hi                             | matches the fuel reels              |
| reelIdFromPath | `/learn/owner.create-trip`               | `owner.create-trip`                 |
| reelIdFromPath | `/learn/../x`, `/learn/`, `/trips/1`     | null                                |

Reel ids match `^(owner|driver)\.[a-z0-9-]{2,40}$`. Anything else in the
catalog or a link is ignored.

### Data model and migration

**No change.** There are no tables, no RLS and no migration. Watched state is
per device in `SharedPreferences` (`learn_watched_v1`, a list of ids) and isn't
synced. That's acceptable for a nudge; cross-device progress is out of scope.

**New content files (in git, uploaded to the bucket):**

```
content/learn/catalog.json        # source of truth, reviewed in PRs
content/learn/README.md           # recording spec + upload steps
```

`catalog.json` (schema version 1):

```json
{
  "schema": 1,
  "updatedAt": "2026-10-20T00:00:00Z",
  "topics": [{ "id": "fuel", "title": { "en": "Fuel", "hi": "ईंधन" } }],
  "reels": [
    {
      "id": "driver.log-fuel",
      "topic": "fuel",
      "audiences": ["driver"],
      "title": { "en": "Log a fuel fill", "hi": "ईंधन फ़िल दर्ज करें" },
      "steps": {
        "en": [
          "Tap Log fuel",
          "Photograph the receipt",
          "Type litres and amount",
          "Turn on Full tank if you filled it up",
          "Save"
        ],
        "hi": [
          "ईंधन दर्ज करें पर टैप करें",
          "रसीद की फ़ोटो लें",
          "लीटर और रक़म लिखें",
          "टैंक फ़ुल कराया हो तो फ़ुल टैंक चालू करें",
          "सेव करें"
        ]
      },
      "durationSec": 38,
      "video": { "en": "v1/en/driver.log-fuel.mp4", "hi": "v1/hi/driver.log-fuel.mp4" },
      "poster": "v1/posters/driver.log-fuel.jpg",
      "minAppBuild": 76
    }
  ]
}
```

Paths are relative to `LEARN_MEDIA_URL`. A changed video gets a new path
(`v2/...`) rather than an overwrite, so caches never show a stale file.

**First reels** (ids are stable; titles shown in English):

| Audience      | Id                        | Title                                |
| ------------- | ------------------------- | ------------------------------------ |
| driver        | `driver.start-trip`       | Start a trip with the odometer photo |
| driver        | `driver.end-trip`         | End a trip and record cash or UPI    |
| driver        | `driver.log-fuel`         | Log a fuel fill                      |
| driver        | `driver.add-charge`       | Add a toll, parking or other charge  |
| driver        | `driver.cancel-request`   | Ask to cancel a running trip         |
| driver        | `driver.new-trip`         | Create your own trip                 |
| driver        | `driver.offline-sync`     | Working without network, and syncing |
| driver        | `driver.my-documents`     | Add your licence and documents       |
| owner         | `owner.add-vehicle`       | Add a vehicle                        |
| owner         | `owner.add-driver`        | Add a driver and link them to cars   |
| owner         | `owner.create-trip`       | Create and assign a trip             |
| owner         | `owner.fuel-alerts`       | Read a fuel alert                    |
| owner         | `owner.review-queue`      | Check flagged trips and fills        |
| owner         | `owner.settle-day`        | Settle a driver's day                |
| owner         | `owner.pay-rules`         | Set driver pay rules                 |
| owner         | `owner.documents`         | Track documents and expiry reminders |
| owner, driver | `common.switch-workspace` | Switch between your fleets           |

`common.*` ids are allowed: the id rule becomes `^(owner|driver|common)\.…`.

### Contracts

**No change.** There are no API routes, so no `bun run api:client` and no Dart
API model updates.

### API

**No change.** Videos and the catalog are static files in a public bucket, so
the API isn't involved.

### App

**New package:** `video_player` (version as resolved by `flutter pub add`).
Android's `INTERNET` permission is already declared
(`android/app/src/main/AndroidManifest.xml:2`), so no manifest change.

**New files in `lib/features/learn/`:**

- `learn_models.dart`: `LearnCatalog`, `Topic`, `Reel`, `Audience`, and a
  tolerant `fromJson`. Invalid reels are skipped and an unknown `schema`
  version is rejected as a whole.
- `learn_rules.dart`: the pure functions above.
- `learn_providers.dart`:
  - `learnMediaUrlProvider`: from `--dart-define=LEARN_MEDIA_URL`; empty means
    Learn is hidden.
  - `learnCatalogProvider`: fetches `<base>/catalog.json` with `http` and a 10 s
    timeout, caches the last good copy in `SharedPreferences` (`learn_catalog_v1`),
    and serves the cache when offline or on failure. It refreshes when Learn
    opens if older than 6 h.
  - `learnWatchedProvider`: a set of ids in prefs.
  - `pendingReelProvider`: the reel id from a link.
  - `reelPlayerProvider`: a factory that wraps `VideoPlayerController.networkUrl`
    behind a small `ReelPlayer` interface, so widget tests get a fake.
- `learn_screen.dart`: home with search, Start here and topic rows (owner tabs
  for DCOs), and a desktop variant using `CardGrid` from `owner_widgets.dart`.
- `reel_player_screen.dart`:
  - A vertical `PageView` that keeps only the current page's controller plus
    the next one preloaded, and disposes the rest.
  - Overlay controls, a Steps bottom sheet, the language fallback chip, and the
    offline and error states.
  - On web, if `play()` with sound is rejected it starts muted with "Tap for
    sound".
- `watch_how_button.dart`: `WatchHowButton(reelId)`, which hides itself when
  the reel isn't in `reelsFor(...)`, and `openReel(context, ref, id)`.

**Edits:**

- `lib/features/owner/desktop_shell.dart`: add `OwnerSection.learn` under
  `navGroupSetup` (key `side-learn`), with its root `LearnScreen()`.
- `lib/features/owner/owner_shell.dart`: add a `more-learn` item after
  `more-settings`.
- `lib/features/driver/driver_profile_screen.dart`: add a `profile-learn` tile
  before `profile-language`.
- `lib/features/trips/driver_home.dart`: add a dismissible `driver-learn-card`
  ("New to Fleet Sarthi?"), shown until 3 reels are watched or it's dismissed.
- `WatchHowButton` in the app bars of the screens below. Ids are constants in
  `learn_ids.dart`, checked against the catalog in a test.

  | Screen                | Reel id                                                       |
  | --------------------- | ------------------------------------------------------------- |
  | `FuelFillScreen`      | `driver.log-fuel`                                             |
  | `StartTripScreen`     | `driver.start-trip`                                           |
  | `EndTripScreen`       | `driver.end-trip`                                             |
  | `CancelRequestScreen` | `driver.cancel-request`                                       |
  | `NewTripScreen`       | `driver.new-trip`                                             |
  | `CreateTripScreen`    | `owner.create-trip`                                           |
  | `VehicleFormScreen`   | `owner.add-vehicle`                                           |
  | `DocumentFormScreen`  | `owner.documents`, or `driver.my-documents` when `mine: true` |
  | `SettlementsScreen`   | `owner.settle-day`                                            |
  | `ReviewScreen`        | `owner.review-queue`                                          |

- `lib/app/app.dart`: on startup, read `Uri.base.path` (web only) and set
  `pendingReelProvider`. When `_Root` reaches a signed-in shell, open the
  pending reel once and clear it.
- `infra/render/build-web.sh`, the root `package.json` `build:apk` script, and
  `bun run dev:driver-web`: pass `--dart-define=LEARN_MEDIA_URL`, defaulting to
  empty locally so Learn stays hidden unless set.
- `test/support/harness.dart`: overrides for `learnCatalogProvider` (a fixture
  catalog) and `reelPlayerProvider` (a fake that "plays" immediately).

**Driver mode offline:** there are no drift tables and no outbox. Learn only
reads, so syncing is unaffected. Offline, it shows the cached catalog (posters
may not load and show a placeholder) and the steps.

**New l10n keys** (UI chrome only; reel titles and steps come from the catalog,
see D25):

| Key                 | English                                                      | Hindi                                                        |
| ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `learnTitle`        | Learn                                                        | सीखें                                                        |
| `learnSubtitle`     | Short videos on how to use Fleet Sarthi                      | फ़्लीट सारथी चलाना सीखें, छोटे वीडियो में                    |
| `learnSearchHint`   | Search videos                                                | वीडियो खोजें                                                 |
| `learnForOwners`    | For owners                                                   | मालिकों के लिए                                               |
| `learnForDrivers`   | For drivers                                                  | ड्राइवरों के लिए                                             |
| `learnStartHere`    | Start here                                                   | यहाँ से शुरू करें                                            |
| `learnWatched`      | Watched                                                      | देखा गया                                                     |
| `learnWatchHow`     | Watch how                                                    | देखें कैसे                                                   |
| `learnSteps`        | Steps                                                        | स्टेप                                                        |
| `learnNext`         | Next: {title}                                                | अगला: {title}                                                |
| `learnDurationSec`  | {seconds} sec                                                | {seconds} सेकंड                                              |
| `learnEnglishOnly`  | Available in English only                                    | सिर्फ़ English में उपलब्ध                                    |
| `learnTapForSound`  | Tap for sound                                                | आवाज़ के लिए टैप करें                                        |
| `learnOffline`      | You're offline. Connect to the internet to watch this video. | आप ऑफ़लाइन हैं। यह वीडियो देखने के लिए इंटरनेट से जुड़ें।    |
| `learnPlayFailed`   | Couldn't play this video.                                    | यह वीडियो चल नहीं सका।                                       |
| `learnLoadFailed`   | Couldn't load the videos. Check your internet and try again. | वीडियो लोड नहीं हो सके। इंटरनेट जाँचकर फिर कोशिश करें।       |
| `learnNoResults`    | No videos match "{query}".                                   | "{query}" से मेल खाता कोई वीडियो नहीं।                       |
| `learnUnavailable`  | This video isn't available any more.                         | यह वीडियो अब उपलब्ध नहीं है।                                 |
| `learnShare`        | Share                                                        | शेयर करें                                                    |
| `learnShareText`    | {title}: Fleet Sarthi video: {link}                          | {title}: फ़्लीट सारथी वीडियो: {link}                         |
| `learnNewHereTitle` | New to Fleet Sarthi?                                         | फ़्लीट सारथी पर नए हैं?                                      |
| `learnNewHereBody`  | Watch 1-minute videos on starting trips and logging fuel.    | ट्रिप शुरू करने और ईंधन दर्ज करने के 1 मिनट के वीडियो देखें। |
| `learnDismiss`      | Not now                                                      | अभी नहीं                                                     |

### Security and tenancy

- **No org data is involved.** There's no tenancy, RLS or guard change.
- **The bucket is public-read**, so "signed-in only" decides who _sees Learn_.
  It doesn't keep the videos secret: anyone with a URL can download a video.
  Videos must therefore show **only the seed demo fleet** (Sharma Travels /
  Patil Cabs), with no real phone numbers, faces or registration numbers.
  `content/learn/README.md` makes this a recording checklist item.
- **No listing:** B2 public buckets serve files by name; listing needs an
  authorised key. _Verify when creating the bucket._
- **Writes:** only a dedicated B2 application key, limited to that bucket and
  held by whoever publishes reels, can upload. It's never in the app or on
  Render.
- **Links:** `reelIdFromPath` accepts only the id pattern, so a crafted
  `/learn/…` path can't inject anything. The URL is never put into a widget or
  a request except as a catalog lookup.
- **Abuse:** hot-linking or scraping the bucket costs egress. Mitigate with
  Cloudflare in front and a B2 cap and alert (B2 "caps & alerts") set to a
  small daily download limit.

### Failure modes

| Failure                                | What the user sees                                                                                          |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| Catalog fetch fails, cache present     | Cached list; no error                                                                                       |
| Catalog fetch fails, no cache          | "Couldn't load the videos…" + Retry                                                                         |
| Catalog malformed or unknown `schema`  | Keep the previous cache; log to Sentry once                                                                 |
| Video 404 or decode error              | Try English, then "Couldn't play this video" + steps + Retry                                                |
| Slow network                           | Poster + buffering spinner; pager still swipeable                                                           |
| Offline                                | Steps + "You're offline…"; never an endless spinner (checked via `connectivity_plus`, already a dependency) |
| Web autoplay with sound blocked        | Plays muted with "Tap for sound"                                                                            |
| Stale id (link or button)              | Button hidden; link opens Learn home + "This video isn't available any more."                               |
| Many quick swipes                      | Only current + next controllers exist; old ones disposed (no memory growth)                                 |
| Egress over the free 3×                | B2 bills $0.01/GB; caps and alerts warn; move to Cloudflare or R2                                           |
| Reel needs a newer app (`minAppBuild`) | Hidden on old apps, so nobody watches a UI they don't have                                                  |

### Seed and docs

- **Seed:** no change. Recordings _use_ the seed fleet, so if `seed.ts` changes
  names or numbers, the affected reels go on a re-record list (noted in
  `content/learn/README.md`).
- **Docs:**
  - `docs/deployment.md`: the learn bucket (public), CORS (not needed for
    `<video>` playback; needed only if the catalog is fetched cross-origin on
    the web, which it is, so add GET from the web origin), the
    `LEARN_MEDIA_URL` define, and caps and alerts.
  - `docs/usage/owner-guide.md` and `driver-guide.md`: a short Learn section.
  - `docs/decisions.md`: D24 and D25.
  - `docs/roadmap.md`: an entry under Phase 1 or a new "Adoption" milestone.
  - `content/learn/README.md`:
    - Recording spec: 720×1280, H.264 High, AAC 128 kbps, ≤60 s, `-movflags +faststart`,
      ≤8 MB, poster 360×640 JPEG.
    - The `ffmpeg` command and the `b2`/`aws s3 cp` upload commands.
    - The script for each reel in English and Hindi.

### Proposed decisions

| #   | Question                                        | Decision                                                                                                                                                                                                                                                                                                                                              | Consequences                                                                                                                                                                                                                                             |
| --- | ----------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| D24 | How are how-to videos built and served?         | _Proposed:_ **Learn reels: per-language voiceover MP4s in a public B2 bucket, listed by a catalog in git.** `content/learn/catalog.json` is reviewed in PRs and uploaded next to the videos. The app fetches and caches it from `LEARN_MEDIA_URL`, and reel ids are stable deep-link handles (`/learn/<id>`). Learn is shown to signed-in users only. | New reels and re-recordings need no app release. The bucket is public, so videos show only demo data. Egress is free up to 3× storage, with Cloudflare or R2 when usage grows. No API, DB or RLS changes. Every reel is recorded twice (English, Hindi). |
| D25 | Where do reel titles and steps live, given D13? | _Proposed:_ **In the catalog (`title`/`steps` per language), not ARB.** UI chrome (buttons, states) stays in ARB.                                                                                                                                                                                                                                     | Content changes ship without a release. A catalog test enforces that every reel has `en` and `hi` titles and steps, mirroring the ARB parity test in `test/l10n_test.dart`.                                                                              |

## Implementation plan

### Step 1: The catalog has a format, rules and a test

Files:

- New: `content/learn/catalog.json`, with the 17 reels above (video paths
  filled in; files uploaded later).
- New: `apps/driver-app/lib/features/learn/learn_models.dart`.
- New: `apps/driver-app/lib/features/learn/learn_rules.dart`.
- New: `apps/driver-app/lib/features/learn/learn_ids.dart`.
- New: `apps/driver-app/test/learn_rules_test.dart`.
- New: `apps/driver-app/test/learn_catalog_test.dart`.

Change:

- Typed models with tolerant parsing, and the five pure functions.
- Constants for the in-app reel ids.

Tests:

- The table above (reelsFor, pagerFor, videoFor, search, reelIdFromPath).
- Parsing skips invalid reels and rejects `schema: 2`.
- The catalog test reads `../../content/learn/catalog.json` and checks:
  - ids are unique and match the pattern;
  - every reel has `en` and `hi` titles and steps;
  - every topic exists;
  - every id in `learn_ids.dart` is in the catalog.

Verify:

```
cd apps/driver-app && flutter analyze --fatal-infos && flutter test test/learn_rules_test.dart test/learn_catalog_test.dart
bunx prettier --check content/learn/catalog.json
```

Commit: `feat(learn): reel catalog format, rules and content`

Size: S

### Step 2: The app loads and caches the catalog

Files:

- New: `lib/features/learn/learn_providers.dart`.
- Edit: `infra/render/build-web.sh` (add `--dart-define=LEARN_MEDIA_URL="${LEARN_MEDIA_URL:-}"`).
- Edit: root `package.json` (`build:apk`, `dev:driver-web` pass `LEARN_MEDIA_URL`).
- Edit: `render.yaml` (`LEARN_MEDIA_URL` env on `taxcy-web`).
- Edit: `test/support/harness.dart` (catalog override).

Change:

- The media URL, catalog (fetch, prefs cache, 6 h refresh), watched set and
  pending-reel providers.
- An empty URL hides Learn.

Tests (`test/learn_providers_test.dart`):

- A fake HTTP client serves the catalog, then fails, and the cache is used.
- A malformed response keeps the cache.
- Watched ids persist.

Verify:

```
cd apps/driver-app && flutter test test/learn_providers_test.dart
```

Commit: `feat(learn): fetch and cache the reel catalog`

Size: S

### Step 3: Owners and drivers can open Learn and find a reel

Files:

- New: `lib/features/learn/learn_screen.dart`.
- Edit: `desktop_shell.dart`, `owner_shell.dart`, `driver_profile_screen.dart`,
  `driver_home.dart` (the entry points and the new-here card).
- Edit: `app_en.arb` and `app_hi.arb` (the keys above).

Change:

- Learn home (Start here, topic rows, search, DCO tabs, ticks), with a desktop
  `CardGrid` variant.
- Opening a card pushes the player (a stub until Step 4).

Tests (`test/learn_screen_test.dart`):

- A driver sees only driver reels, and a DCO sees both tabs.
- Searching "settle" leaves one result.
- Watched shows a tick, and Start here hides when all are watched.
- No overflow at 360 px in en and hi, or on desktop.
- The entry keys `side-learn`, `more-learn`, `profile-learn` and
  `driver-learn-card` open Learn.

Verify:

```
cd apps/driver-app && flutter analyze --fatal-infos && flutter test test/learn_screen_test.dart test/l10n_test.dart test/desktop_test.dart
```

Commit: `feat(learn): learn section for owners and drivers`

Size: M

### Step 4: Reels play like reels

Files:

- Edit: `pubspec.yaml` (add `video_player`).
- New: `lib/features/learn/reel_player.dart` (the `ReelPlayer` interface and
  its `video_player` implementation).
- New: `lib/features/learn/reel_player_screen.dart`.
- Edit: the harness (fake player).

Change:

- A vertical pager over `pagerFor`, overlay controls, the Steps sheet, the
  language fallback, offline and error states, and the web muted fallback.
- Marked watched at 80%, with auto-next after 3 s.
- Controllers limited to current and next.

Tests (`test/reel_player_test.dart`):

- Opens at the right index and swiping plays the next reel.
- Hindi falls back to English and shows the chip.
- Offline shows the steps and no player.
- A play error leads to the fallback, then the error with Retry.
- Watched is set at 80%.
- Closing returns to the previous screen.
- No overflow at 360 px or desktop.

Verify:

```
cd apps/driver-app && flutter test test/reel_player_test.dart
cd apps/driver-app && flutter build web
```

Then a manual check: play a real MP4 in Chrome and on an Android phone or
emulator.

Commit: `feat(learn): vertical reel player`

Size: M

### Step 5: "Watch how" opens the exact reel from where you're stuck

Files:

- New: `lib/features/learn/watch_how_button.dart`.
- Edit: the 10 screens in the table above (an app bar action).

Change:

- `WatchHowButton(reelId)` hides itself when the reel isn't available, and
  opens the player directly at that id.

Tests (in `test/learn_screen_test.dart`, or `test/watch_how_test.dart`):

- On FuelFillScreen the button opens `driver.log-fuel`, and closing keeps the
  typed litres.
- The button is hidden when the catalog lacks the id.
- The existing screen smoke tests (`test/screens_smoke_test.dart`) still have
  no overflow.

Verify:

```
cd apps/driver-app && flutter test test/watch_how_test.dart test/screens_smoke_test.dart
```

Commit: `feat(learn): watch-how buttons on key screens`

Size: S

### Step 6: A shared link opens the reel (web)

Files:

- Edit: `lib/app/app.dart` (read `Uri.base` on web; open the pending reel after
  sign-in).
- Edit: `reel_player_screen.dart` (the share action, using `urlOpenerProvider`
  and `whatsAppUri`).

Change:

- Owners and managers share a `https://<web host>/learn/<id>` link.
- Opening it signed out goes welcome → sign in → reel; signed in, it goes
  straight to the reel.
- An unknown id shows the "not available" snackbar.

Tests (`test/learn_links_test.dart`):

- The share opens a wa.me URI with the localized text.
- A pending id opens the player after a fake sign-in, only once.
- A bad path is ignored.

Verify:

```
cd apps/driver-app && flutter test test/learn_links_test.dart
```

Then a manual check: open `http://localhost:5174/learn/driver.log-fuel`.

Commit: `feat(learn): share and open reels by link`

Size: S

### Step 7: The first reels are recorded and live

Files:

- New: `content/learn/README.md`.
- New: `scripts/learn/encode.sh`.
- New: `scripts/learn/publish.sh` (uploads MP4s, posters and `catalog.json`
  with `aws s3 cp --endpoint-url` to B2, with `Cache-Control: public,
max-age=31536000, immutable` for media and `no-cache` for the catalog).
- Edit: `docs/deployment.md` (the learn bucket, CORS for the catalog, caps and
  alerts, `LEARN_MEDIA_URL`).

Change:

- Create the `fleet-sarthi-learn` public bucket.
- Record and voice the 8 driver reels first (both languages), then the 9 owner
  and common reels.
- Upload, then set `LEARN_MEDIA_URL` on Render and in the APK build.

Tests: `publish.sh --dry-run` lists files. The catalog test (Step 1) is green.

Verify:

```
curl -I $LEARN_MEDIA_URL/catalog.json
curl -I $LEARN_MEDIA_URL/v1/hi/driver.log-fuel.mp4   # 200, video/mp4
```

Then play one reel in each language on the deployed web app and an APK.

Commit: `docs(learn): recording spec and publish scripts`

Size: M (mostly recording time, about ½ day per 4 reels per language)

### Step 8: Docs and decisions are updated

Files: `docs/decisions.md` (D24, D25), `docs/roadmap.md`,
`docs/usage/owner-guide.md`, `docs/usage/driver-guide.md`.

Change: describe Learn, the content workflow and the limits (no offline
download, no Android App Links yet).

Tests: Prettier.

Verify:

```
bun run format:check
```

Commit: `docs: learn reels decisions and guides`

Size: S

### Step 9: The landing page mentions Learn

Do this only once the driver reels are live (Step 7). The landing page only
claims what has shipped.

Files:

- Edit: `apps/driver-app/lib/features/welcome/welcome_screen.dart` (a feature
  card in the features grid, and a line in the "For drivers" list).
- Edit: `app_en.arb` and `app_hi.arb`.

Change:

- Feature card `welcomeFeatureLearnTitle`, "How-to videos" / "कैसे करें वीडियो".
  Body `welcomeFeatureLearnBody`: "Short videos in Hindi and English show
  owners and drivers how to do each task, from the screen they're on." /
  "हिन्दी और English के छोटे वीडियो मालिकों और ड्राइवरों को हर काम करना
  सिखाते हैं, उसी स्क्रीन से जहाँ वे हैं।"
- The features grid goes from 6 to 7 cards, or 8 if something else ships
  alongside. Check the 3-column desktop layout still looks balanced.
- An FAQ entry is optional: "How do my drivers learn the app?", answered with
  the above.

Tests: in `test/welcome_test.dart`, the new card's text is found, and there's
no overflow at 360 px, tablet or laptop sizes, in English or Hindi.

Verify:

```
cd apps/driver-app && flutter test test/welcome_test.dart test/l10n_test.dart
```

Commit: `feat(app): mention how-to videos on the welcome page`

Size: S

## Risks and mitigations

1. **Videos go stale as the UI changes.**
   - Mitigation: `minAppBuild` hides reels for UI that old apps don't have.
   - Versioned paths (`v2/…`) let a re-record ship without breaking caches.
   - The README keeps a "screens shown" list per reel, so a UI PR can see which
     reels to re-record.
2. **Egress cost if reels are popular.**
   - B2 caps and alerts from day one.
   - Put Cloudflare (a paid plan, given the free-plan terms) or R2 in front
     before scaling past pilots.
3. **Drivers on weak 4G** get buffering.
   - 720p at about 1.5–2 Mbps, ≤60 s, `faststart`, and the next reel preloaded.
   - Offline steps as the fallback.
   - A lower-bitrate 480p variant if field feedback asks for it.
4. **Web autoplay and video quirks** (`video_player_web` uses `<video>`).
   - The muted fallback.
   - A manual check in Chrome and in Android Chrome is part of Step 4.
5. **Recording effort doubles** with per-language voiceover.
   - Ship driver reels first (8 × 2).
   - The English fallback lets Hindi lag behind without broken reels.

## Out of scope

- Downloading reels for offline viewing in driver mode.
- **Android App Links** (`/learn/<id>` opening the installed app). This needs an
  intent filter with `autoVerify` plus `/.well-known/assetlinks.json` on the web
  host with the release key's SHA-256. Until then, links open the web app.
- Learn for signed-out visitors (on the welcome page).
- Watched progress synced across devices, usage analytics, or "mandatory
  training" gates like Rapido's onboarding.
- An in-app admin for uploading reels (it's a script plus a PR for now).
- Guided coach-mark tours (option C), as a later complement.
- Burned-in subtitles or accessibility captions (the Steps sheet covers the
  text for now).

## Open questions

1. **Who records and voices the reels, and on what device?** Recommended: one
   person records the screen on an Android phone (or the web build at 412×915
   in Chrome DevTools) with the seed fleet. Voiceovers are recorded separately
   and laid over in a simple editor (CapCut or DaVinci Resolve), following the
   scripts in `content/learn/README.md`.
2. **Bucket name and domain?** Recommended: `fleet-sarthi-learn`, served at
   first through B2's `f00x.backblazeb2.com/file/…` URL. Later, use a
   `learn.<your domain>` hostname through Cloudflare, so moving to R2 doesn't
   change `LEARN_MEDIA_URL`'s shape.
3. **Should managers see the owner reels on pay rules and settlements,** which
   they can only view (D11)? Recommended: yes. Watching is harmless, and the
   reels show what the owner does.
4. **Auto-advance to the next reel?** Recommended: yes, after 3 s with a
   visible countdown, like Reels. Turn it off if drivers find it confusing in
   the pilot.

## Done when

- [ ] Acceptance checks 1–5 pass by hand on:
  - a 360 px Android phone (the APK),
  - Chrome at phone width,
  - desktop at ≥1100 px.
- [ ] `flutter analyze --fatal-infos` and `flutter test` are green. The new
      tests cover the rules, catalog parity, providers, screens, player, buttons
      and links.
- [ ] `bun run verify` is green (Prettier for `content/learn/catalog.json` and
      the docs).
- [ ] The driver reels are live in English and Hindi. `LEARN_MEDIA_URL` is set
      for the Render web build and the APK build.
- [ ] D24 and D25 are added to `docs/decisions.md`, and the deployment and
      usage docs are updated.
