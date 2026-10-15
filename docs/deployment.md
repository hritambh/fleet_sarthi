# Deployment: Android APK and a free hosted demo

This page covers two things:

1. **Building the Android app** (`fleet-sarthi-<version>.apk`) pointed at any API, and installing it on a phone.
2. **Hosting the backend and the web app for free** on [Render](https://render.com), with Neon (Postgres + PostGIS), Render Key Value (Redis) and Backblaze B2 (photos).

The free stack is meant for demos, pilots and testing, not for real fleets: it sleeps when idle, has small quotas, and logs password-reset codes instead of sending SMS. [Moving beyond free](#moving-beyond-the-free-tier) lists what to change for real users.

- [Part 1: Build the APK](#part-1-build-the-apk)
- [Part 2: Recommended free infrastructure](#part-2-recommended-free-infrastructure)
- [Part 3: Deploy to Render step by step](#part-3-deploy-to-render-step-by-step)
- [Part 4: Sign-in on a free deployment (passwords, reset codes)](#part-4-sign-in-on-a-free-deployment)
- [Troubleshooting](#troubleshooting)

---

## Part 1: Build the APK

### Prerequisites

| Tool        | Version                          | Check                      |
| ----------- | -------------------------------- | -------------------------- |
| Flutter     | 3.38.x (Dart 3.10)               | `flutter --version`        |
| JDK         | 17+ (Android Studio bundles one) | `java -version`            |
| Android SDK | API 36 platform + build-tools    | `flutter doctor`           |
| adb         | Android platform-tools           | `adb version` (to install) |

`flutter doctor` should show a green tick for "Android toolchain". If it complains about licences, run `flutter doctor --android-licenses`.

### Build

The app's API address is compiled in (`--dart-define=API_URL`, read in `apps/driver-app/lib/app/providers.dart`). Give the server root, **without** `/v1`:

```bash
# From the repo root: just the APK to send to phones (arm64-v8a, ~25 MB). Use this one.
API_URL=https://taxcy-api.onrender.com bun run build:apk:arm64

# The universal APK (~66 MB, runs on any Android phone)
API_URL=https://taxcy-api.onrender.com bun run build:apk

# Everything: universal + one APK per CPU + an App Bundle for Google Play
apps/driver-app/scripts/build-apk.sh --api-url https://taxcy-api.onrender.com --split --aab
```

**Which APK?** `arm64-v8a` runs on nearly every Android phone from about 2017 on, so it's
the one to send to owners and drivers. `build:apk:arm64` builds only that file, in one pass,
so it's also the quickest. Build the universal APK (or `--split`) only for an old 32-bit
phone (`armeabi-v7a`) or an emulator on a PC (`x86_64`).

| Option             | Env var         | Default          | What it does                                                                                                      |
| ------------------ | --------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------- |
| `--api-url URL`    | `API_URL`       | (required)       | API server root. Release builds need `https://` (the app blocks plain HTTP except the emulator)                   |
| `--build-number N` | `BUILD_NUMBER`  | git commit count | Android `versionCode`. Must grow for an update to install over an older build                                     |
| `--split`          | `SPLIT_PER_ABI` | off              | Also builds one smaller APK per CPU (`arm64-v8a` fits nearly every phone from 2017 on)                            |
| `--arm64`          | `ARM64_ONLY`    | off              | Builds **only** the `arm64-v8a` APK, skipping the universal one (what `build:apk:arm64` runs). Not with `--split` |
| `--aab`            | `BUILD_AAB`     | off              | Also builds an Android App Bundle for Google Play                                                                 |

The version name is `YY.M.N` from `apps/driver-app/scripts/app-version.sh` (year and month of the latest commit, then that month's commit count), so it rises by itself; the app shows it as `v…` in small print. The script runs `flutter pub get` and `flutter build apk --release`, then copies the results to **`dist/driver-app/`** (gitignored) and prints their paths:

```
dist/driver-app/fleet-sarthi-0.1.0+76.apk              universal, ~66 MB
dist/driver-app/fleet-sarthi-0.1.0+76-arm64-v8a.apk    with --split or --arm64, ~24 MB
dist/driver-app/fleet-sarthi-0.1.0+76.aab              with --aab
```

A first build takes about 5 minutes (Gradle downloads); later builds about 1 minute.

### Rebuilding after a code change

1. **Commit first.** The build number defaults to the git commit count, and Android won't install a lower build number over a higher one. Committing keeps each build's number at least as high as the one on the phone.
2. Build from the repo root: `API_URL=https://taxcy-api.onrender.com bun run build:apk:arm64`.
3. Install `dist/driver-app/fleet-sarthi-<version>-arm64-v8a.apk` (send it to the phone, or `adb install -r …`). It's signed with the same upload key, so it updates the installed app and keeps its data.

Only changes under `apps/driver-app` need a new APK. API changes reach existing installs once Render redeploys after a push, and Render rebuilds the web app (`taxcy-web`) by itself when `apps/driver-app` changes.

### Automatic APK in Slack

Every push to `main` that changes the app (`apps/driver-app/**`, except tests and docs) runs
`.github/workflows/android-release.yml`. It checks the app (format, analyze, tests), builds the
**arm64-v8a APK** with your upload key, and posts it to Slack **#releases** with the version,
commit message and a link. The APK is also kept as a build artifact on the GitHub run for 30
days. You can start it by hand from **Actions → Android APK to Slack → Run workflow**. A newer
push cancels a build that's still running.

One-time setup:

1. **Slack app.** At <https://api.slack.com/apps>, **Create New App → From scratch** (e.g.
   "Fleet Sarthi Releases") in your workspace. Under **OAuth & Permissions → Bot Token
   Scopes** add `files:write` and `chat:write`, then **Install to Workspace** and copy the
   **Bot User OAuth Token** (`xoxb-…`).
2. **Channel.** In Slack, open #releases and run `/invite @Fleet Sarthi Releases` (the bot
   must be a member to post there). Open the channel's name → **About**; the **Channel ID**
   (`C…`) is at the bottom.
3. **GitHub secrets.** In the repo: **Settings → Secrets and variables → Actions → New
   repository secret**:

   | Secret                      | Value                                                                                         |
   | --------------------------- | --------------------------------------------------------------------------------------------- |
   | `SLACK_BOT_TOKEN`           | The `xoxb-…` token                                                                            |
   | `SLACK_RELEASES_CHANNEL_ID` | The `C…` channel ID                                                                           |
   | `ANDROID_KEYSTORE_BASE64`   | The upload keystore, base64: `base64 -i ~/.taxcy/taxcy-upload-keystore.jks \| pbcopy` (macOS) |
   | `ANDROID_KEYSTORE_PASSWORD` | The keystore password (`storePassword` in `apps/driver-app/android/key.properties`)           |

   Optionally add a **variable** (Variables tab) `API_URL` if the API isn't
   `https://taxcy-api.onrender.com`.

The keystore must be the same one your local builds use, or phones refuse the update. Anyone
with admin access to the repo can use these secrets in workflows, so keep that list short.

### Testing against your laptop

Release builds only accept `https://`, so to point a phone at the API on your laptop (`http://<LAN-IP>:3000`, same Wi-Fi), build a debug APK, which allows plain HTTP:

```bash
cd apps/driver-app
flutter build apk --debug --dart-define=API_URL=http://<LAN-IP>:3000
# output: build/app/outputs/flutter-apk/app-debug.apk (large, ~160 MB)
```

Or run it straight on a USB-connected phone with `flutter run --dart-define=API_URL=http://<LAN-IP>:3000`. Either way, set `S3_PUBLIC_ENDPOINT=http://<LAN-IP>:9000` in the root `.env` and restart `bun run dev` so photo links work from the phone, as in [getting started](getting-started.md#step-10-sign-in-as-a-driver). On macOS, `ipconfig getifaddr en0` prints the LAN IP; if the phone can't connect, allow incoming connections for `node` and Docker in the macOS firewall.

A debug build is signed with your machine's debug key, not the upload key, so uninstall the release app before installing it (and the other way round).

### Signing

Android only installs signed APKs, and only lets an update replace an installed app if both are signed with the **same key**.

- **No setup:** without `apps/driver-app/android/key.properties` the release build is signed with your machine's **debug key** and the script prints a warning. Fine for handing a test build to a few phones. Builds from another machine (another debug key) won't install over it until the old app is uninstalled, and Google Play rejects it.
- **Upload key (recommended once you share builds):** create it once:

  ```bash
  bun run driver:keystore            # = apps/driver-app/scripts/create-keystore.sh
  ```

  It asks for a password, then creates `~/.taxcy/taxcy-upload-keystore.jks` (outside the repo) and `apps/driver-app/android/key.properties`, and prints the key's SHA-1. From then on `build:apk` signs with it automatically; `android/app/build.gradle.kts` reads `key.properties` the standard Flutter way.

  The equivalent by hand:

  ```bash
  keytool -genkeypair -v -keystore ~/.taxcy/taxcy-upload-keystore.jks -storetype PKCS12 \
    -alias upload -keyalg RSA -keysize 2048 -validity 10000
  ```

  ```properties
  # apps/driver-app/android/key.properties (PKCS12: the same password twice)
  storePassword=<password>
  keyPassword=<password>
  keyAlias=upload
  storeFile=/Users/<you>/.taxcy/taxcy-upload-keystore.jks
  ```

**Back up the keystore file and its password** (a password manager). Lose them and existing installs can't be updated; Play can reset an upload key, but only through support.

`key.properties`, `*.jks` and `*.keystore` are gitignored at the root and in `apps/driver-app`. Never commit them, and never put them in CI logs. To check which key signed an APK: `$ANDROID_HOME/build-tools/<version>/apksigner verify --print-certs <apk>`.

### Install on a phone

**Over USB with adb:**

1. On the phone: Settings → About phone → tap **Build number** 7 times, then Settings → Developer options → turn on **USB debugging**.
2. Connect the cable, accept the "Allow USB debugging?" prompt, and check `adb devices` lists the phone.
3. Install (`-r` replaces an existing install and keeps its data):

   ```bash
   adb install -r dist/driver-app/fleet-sarthi-0.1.0+76.apk
   ```

   `INSTALL_FAILED_UPDATE_INCOMPATIBLE` means the installed app was signed with another key: `adb uninstall in.taxcy.taxcy_driver` first (this deletes un-synced offline data on the phone).

**Sideloading without a cable:** send the `.apk` to the phone (Google Drive, a messaging app, a download link), open it, and allow **Install unknown apps** for the app you opened it from when Android asks. Play Protect may warn about an unknown developer; choose **Install anyway**.

On first launch the app asks for camera, location ("Allow all the time" for route recording during a trip) and notification permissions.

### Plugins and release builds

The release build was verified on this repo (Flutter 3.38.5, AGP 8.11, `minSdk 24`, `compileSdk 36`) with every plugin in `pubspec.yaml`: drift + `sqlite3_flutter_libs`, `camera`, `geolocator` (foreground service), `flutter_secure_storage`, `connectivity_plus`, `shared_preferences`, `path_provider`. Flutter's release build shrinks Java code with R8; each plugin ships its own keep rules, so no extra ProGuard configuration is needed. Test a release build on a real phone before handing it out.

---

## Part 2: Recommended free infrastructure

Researched in October 2026. Free tiers change often, so check each provider's pricing page before relying on a number.

| Piece                                    | Recommended                                                 | Free limits that matter                                                                                                                                                                                                                                        |
| ---------------------------------------- | ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| API (NestJS)                             | **Render free web service** (`taxcy-api`)                   | 512 MB RAM, 0.1 CPU. **Sleeps after 15 min without requests; waking takes about a minute.** 750 instance-hours per workspace per month. No pre-deploy command, no shell, no background workers, single instance.                                               |
| Background jobs                          | **Inside the API** (`JOBS_MODE=in-process`)                 | Render has no free background worker. Jobs only run while the API is awake (see [gotchas](#gotchas-of-the-free-stack)).                                                                                                                                        |
| Web app (Flutter)                        | **Render free static site** (`taxcy-web`)                   | The Flutter app built for the browser (owner and driver modes). Global CDN, custom domains. Each build fetches the Flutter SDK (~5 min). Counts against the workspace's outbound bandwidth (reported cut to **5 GB/month** on the Hobby plan from 1 Aug 2026). |
| Postgres + PostGIS                       | **Neon free**                                               | 0.5 GB storage per project, **100 CU-hours/month** (0.25 CU minimum, so about 400 awake hours), scales to zero after 5 min idle. PostGIS and `btree_gist` supported. Region: Singapore (`aws-ap-southeast-1`).                                                 |
| Redis (reset codes, rate limits, BullMQ) | **Render Key Value free** (`taxcy-redis`)                   | 25 MB RAM, 50 connections (the API uses about 17), **in memory only: data is lost when it restarts**. Same region as the API, private network only.                                                                                                            |
| Photos (S3 API)                          | **Backblaze B2 free**                                       | First **10 GB stored free**, downloads free up to 3× the average data stored, Class A/B/C API calls free on pay-as-you-go. **No Asia region**: the region (US or EU) is chosen once per account at sign-up.                                                    |
| SMS                                      | **None (demo mode)**: reset codes are read from the API log | See [Part 4](#part-4-sign-in-on-a-free-deployment). India requires DLT registration for SMS, and no SMS gateway is free.                                                                                                                                       |
| Errors (optional)                        | Sentry free (Developer plan)                                | Set `SENTRY_DSN`; empty disables it.                                                                                                                                                                                                                           |

Why these choices:

- **Neon over Render Postgres:** Render's free Postgres (1 GB) **expires 30 days after creation** and is deleted 14 days later. Neon's free plan doesn't expire, supports PostGIS, and lets the owner role `CREATE ROLE` from SQL, which the app role needs (below). Render Postgres is fine for a demo of under a month; **Supabase** free (500 MB, pauses after 7 days without activity) also works but its direct connection is IPv6-only, so you'd use its session pooler. Neither alternative is tested.
- **Render Key Value over Upstash:** Upstash's free tier counts commands (about 500 K per month). BullMQ workers poll Redis constantly even when idle (blocking pops, stalled-job checks for each of the 5 queues), which can use up a command quota within days. Render Key Value has no command quota and sits on the same private network as the API. Its downside, losing data on restart, only affects OTP codes in flight, rate-limit counters and queued jobs; the outbox in Postgres is the source of truth for events, and schedules are re-created on start.
- **Backblaze B2 for photos:** 10 GB free with an S3-compatible API. Photos are small and viewed rarely, so the 3× egress allowance is plenty. Pick the **EU Central** region at sign-up: it's the closest to India (there is no Asian region), and uploads go straight from phones to B2, so only photo uploads and views feel the distance. Cloudflare R2 (10 GB, no egress fees, Asia-Pacific location) works the same way if you prefer it: only the endpoint, region and keys change.

### Gotchas of the free stack

- **Cold starts.** After 15 idle minutes the API sleeps. The next request waits for a wake-up (about a minute, plus a few seconds for the start script's role and migration check). The web app and APK show a network error or spin meanwhile; retry. Open `https://<api>/v1/health/live` a minute before a demo.
- **Jobs pause while the API sleeps.** Outbox events (photo OCR, fuel audit, trip close) are picked up when it wakes. The daily document-expiry scan (06:00 IST) runs late, when the API next wakes.
- **Neon compute hours vs keeping the API awake.** While awake, the API's outbox relay queries Postgres every second, so Neon never scales to zero. With the API sleeping when idle that's fine; but an uptime pinger that keeps the API awake 24/7 would burn Neon's 100 CU-hours in about 16 days. Don't use one on the free plan.
- **Render bandwidth.** Photos go straight between phones and B2 (signed URLs), not through Render. API JSON and the web app's assets count against Render's monthly bandwidth; if it runs out with no card on file, Render suspends free services until the month ends.
- **One API instance only.** In-process jobs assume a single instance (Render free never scales out). Before moving to several instances, switch to `JOBS_MODE=external` and run `apps/workers` as a worker service.
- **Client IPs.** Render's proxy is in front of the API and the API doesn't trust `X-Forwarded-For`, so every client looks like the same few proxy IPs. The per-IP limits (reset codes `OTP_IP_LIMIT_PER_HOUR`, 20 sign-ups per hour, 100 logins per hour) are therefore shared by everyone; the Blueprint raises it to 120. Per-phone limits (1 per 30 s, 3 per 10 min, 10 per day) still apply.
- **Logs are short-lived** on the free plan, and in demo mode they contain password-reset codes. Treat log access as admin access.

---

## Part 3: Deploy to Render step by step

What gets created:

| Piece         | Where                             | Talks to                                                 |
| ------------- | --------------------------------- | -------------------------------------------------------- |
| `taxcy-api`   | Render web service, Singapore     | Neon (TLS), `taxcy-redis` (private network), B2 (S3 API) |
| `taxcy-web`   | Render static site (global CDN)   | `taxcy-api` from the browser; B2 through signed URLs     |
| `taxcy-redis` | Render Key Value, Singapore       | only `taxcy-api`                                         |
| Postgres      | Neon, Singapore                   | only `taxcy-api`                                         |
| Photos        | Backblaze B2 bucket `taxcy-media` | phones and browsers upload/download with signed URLs     |
| The app       | APK on phones                     | `taxcy-api`, B2                                          |

`render.yaml` at the repo root is the [Blueprint](https://render.com/docs/infrastructure-as-code). It defines `taxcy-api`, `taxcy-web` and `taxcy-redis`; Neon and B2 are created by hand first.

### Step 1: Create the Neon database

1. Sign up at <https://neon.com> and create a project: Postgres **16** or newer, region **AWS Asia Pacific (Singapore)**.
2. On the project dashboard, **Connect**, turn **Connection pooling off** (the direct, non-`-pooler` host), and copy the URL. It looks like:

   ```
   postgresql://neondb_owner:AbC123...@ep-cool-name-123456.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
   ```

   This is the **owner** URL → `DATABASE_MIGRATION_URL`.

3. Make the **app** URL → `DATABASE_URL`: the same host and database, but user `taxcy_api` and a new random password (letters and digits only, so it needs no URL-escaping):

   ```bash
   openssl rand -hex 24            # e.g. 3f9c...; Neon requires at least 60 bits of entropy
   # postgresql://taxcy_api:<that password>@ep-cool-name-123456.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
   ```

   You don't create this role yourself: on every start, `libs/db/scripts/ensure-app-role.mjs` connects as the owner and creates (or updates) `taxcy_api` with that password, plus the `taxcy_app` group role that the migrations grant table access to. It refuses an app URL that uses the owner role, and checks the role is neither superuser nor `BYPASSRLS`, because [row-level security](architecture.md#multi-tenancy) must apply to the API's connection. (Locally, `infra/postgres/init-roles.sql` does the same job.)

PostGIS and `btree_gist` are created by the first migration; Neon allows that for the owner.

### Step 2: Create the Backblaze B2 bucket

1. **Account and bucket.** Sign up at <https://www.backblaze.com/sign-up/cloud-storage> and choose the region **EU Central** (closest to India; the region is fixed for the account, so pick it at sign-up). Then **Buckets → Create a Bucket**:
   - Bucket name `taxcy-media`. B2 bucket names are global; if it's taken, use another name and set `S3_BUCKET` on `taxcy-api` to match.
   - Files in bucket: **Private** (the API hands out short-lived signed URLs).
   - Default encryption: optional. Object Lock: **Disable**.

   The bucket page shows its **Endpoint**, e.g. `s3.eu-central-003.backblazeb2.com`. `S3_ENDPOINT` is that with `https://` in front, and `S3_REGION` is its middle part (`eu-central-003`).

   Optional: bucket → **Lifecycle Settings → Keep only the last version of the file**, so overwritten or deleted photos don't keep using storage.

2. **Application key.** **Application Keys → Add a New Application Key**:
   - Name `taxcy-api`, **Allow access to Bucket(s): `taxcy-media`**, Type of Access **Read and Write**, no file-name prefix, no expiry.
   - Copy **keyID** → `S3_ACCESS_KEY_ID` and **applicationKey** → `S3_SECRET_ACCESS_KEY`. The applicationKey is shown only once.

   Don't use the account's master application key: B2's S3 API rejects it.

3. **CORS rules** (required for the web app). The Flutter web app downloads photos with JavaScript requests and, in driver mode, uploads them to signed URLs, so the browser needs the bucket to allow the web app's origin. The APK doesn't need CORS.

   B2 supports S3's `PutBucketCors`, so the rules use the same format as `infra/s3/cors.json` (local RustFS). Save as `b2-cors.json`, with your web app's URL (and any custom domain):

   ```json
   {
     "CORSRules": [
       {
         "AllowedOrigins": ["https://taxcy-web.onrender.com"],
         "AllowedMethods": ["GET", "PUT", "HEAD"],
         "AllowedHeaders": ["*"],
         "ExposeHeaders": ["ETag"],
         "MaxAgeSeconds": 3600
       }
     ]
   }
   ```

   Apply it with the AWS CLI (`brew install awscli`), using a B2 key:

   ```bash
   AWS_ACCESS_KEY_ID=<keyID> AWS_SECRET_ACCESS_KEY=<applicationKey> \
   aws s3api put-bucket-cors --bucket taxcy-media \
     --endpoint-url https://s3.eu-central-003.backblazeb2.com --region eu-central-003 \
     --cors-configuration file://b2-cors.json

   # check
   AWS_ACCESS_KEY_ID=<keyID> AWS_SECRET_ACCESS_KEY=<applicationKey> \
   aws s3api get-bucket-cors --bucket taxcy-media \
     --endpoint-url https://s3.eu-central-003.backblazeb2.com --region eu-central-003
   ```

   Changing bucket settings needs the `writeBuckets` capability. If the bucket-scoped `taxcy-api` key gets `AccessDenied`, create a temporary key with access to **All** buckets (Read and Write), run the command with it, then delete that key. In the web UI, the bucket's **CORS Rules** dialog shows the result: rules applied to the **S3 Compatible API**. Rules set there with the simple "share with one origin" option cover downloads, not uploads, so prefer the CLI.

The API's S3 client sends checksums only when an operation requires them (`requestChecksumCalculation` / `responseChecksumValidation` set to `WHEN_REQUIRED` in `apps/api/src/platform/s3.service.ts`). The AWS SDK's newer defaults add CRC32 parameters to signed upload URLs and an `x-amz-checksum-mode` header to downloads, which B2 rejects.

### Step 3: Push the code and create the Blueprint

1. Push this repo (with `render.yaml`) to GitHub or GitLab.
2. In Render: **New → Blueprint**, connect your Git provider, pick the repo and branch (`main`). Render reads `render.yaml` and lists `taxcy-api`, `taxcy-web` and `taxcy-redis`.
3. Render asks for every variable marked `sync: false`: only secrets and your own accounts' values (database URLs, B2 endpoint and keys, optional extras). Fill them in as below (you can leave the optional ones empty), then **Apply**.
4. **Turn on Auto Sync:** Render → **Blueprints** → this Blueprint → **Settings** → **Auto Sync: Yes**. Then every push to `main` also applies changes to `render.yaml`, such as a new variable or a changed URL, so you don't add them by hand.

Render then creates the Key Value instance, builds both services (about 5 minutes each; the web app's build downloads the Flutter SDK every time) and starts the API.

**What Render sets by itself:** everything in `render.yaml` with a `value`, `generateValue` or `fromService`: the services' URLs (`API_URL` on `taxcy-web`, `CORS_ORIGINS` on `taxcy-api`), the Redis URL, the JWT secret, and the modes and limits. These are applied on every Blueprint sync. Variables marked `sync: false` are asked for only when the Blueprint is created; Render never changes them afterwards, so a **new** `sync: false` variable added later must be set in the service's **Environment** tab.

The service URLs are `https://<name>.onrender.com`, and `render.yaml` assumes `taxcy-api` and `taxcy-web`. If a name was taken, Render adds a suffix: check the real URLs on each service's page and change `API_URL` and `CORS_ORIGINS` in `render.yaml` to match (then push; with Auto Sync, Render applies them). A missing `https://` or a trailing `/` is forgiven by both.

### Step 4: Environment variables

**`taxcy-api`**

| Variable                                                                          | Where the value comes from                                                                                                                                                                                                                                                                                                                                                                      |
| --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `DATABASE_MIGRATION_URL`                                                          | Neon owner URL (Step 1.2)                                                                                                                                                                                                                                                                                                                                                                       |
| `DATABASE_URL`                                                                    | Neon app URL with `taxcy_api` and your generated password (Step 1.3)                                                                                                                                                                                                                                                                                                                            |
| `S3_ENDPOINT`                                                                     | The bucket's **Endpoint** with `https://`, e.g. `https://s3.eu-central-003.backblazeb2.com` (Step 2.1)                                                                                                                                                                                                                                                                                          |
| `S3_REGION`                                                                       | The middle part of that endpoint, e.g. `eu-central-003` (Step 2.1). It must match: B2 rejects signatures made for another region.                                                                                                                                                                                                                                                               |
| `S3_ACCESS_KEY_ID` / `S3_SECRET_ACCESS_KEY`                                       | B2 application key: `keyID` / `applicationKey` (Step 2.2)                                                                                                                                                                                                                                                                                                                                       |
| `SENTRY_DSN`                                                                      | Optional; Sentry project DSN. Empty: Sentry off.                                                                                                                                                                                                                                                                                                                                                |
| `MASTER_PASSWORD`                                                                 | Optional, testing only: a password of 8+ characters that signs in as any user ([below](#master-password-testing-only)). Empty: off.                                                                                                                                                                                                                                                             |
| `PHONE_OTP_PROVIDER` / `PHONE_EMAIL_CLIENT_ID` / `SIGNUP_REQUIRES_VERIFIED_PHONE` | Optional phone OTP via phone.email: `phone_email`, your client id, `true`/`false`. Set here in the dashboard; Blueprint syncs leave them alone. Empty: off. See [phone OTP](phone-otp.md).                                                                                                                                                                                                      |
| Set by the Blueprint                                                              | `CORS_ORIGINS=https://taxcy-web.onrender.com` (add custom domains comma-separated in `render.yaml`), `REDIS_URL` (from `taxcy-redis`), `JWT_ACCESS_SECRET` (generated by Render), `NODE_ENV=production`, `JOBS_MODE=in-process`, `SMS_PROVIDER=console`, `DEMO_MODE=true`, `S3_BUCKET=taxcy-media`, `OTP_IP_LIMIT_PER_HOUR=120`, `SEED_DEMO_DATA=false`, `NODE_VERSION=24`, `BUN_VERSION=1.4.2` |

`PORT` is set by Render and read by the API. `S3_PUBLIC_ENDPOINT` isn't needed (B2's endpoint is public).

**`taxcy-web`**

| Variable          | Value                                                                                                                                                                                 |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `API_URL`         | Set by the Blueprint: `https://taxcy-api.onrender.com` (no `/v1`). Compiled in **at build time** (`--dart-define`); a change applies on the site's next deploy.                       |
| `FLUTTER_VERSION` | Set by the Blueprint (`3.38.5`): the Flutter SDK tag `infra/render/build-web.sh` clones. Keep it in step with the version the app is developed and tested with (`flutter --version`). |

If a Blueprint was created before these URLs were in `render.yaml`, sync it once (Blueprint → **Manual Sync**, or turn on Auto Sync and push) to apply them. Values typed into the **Environment** tab by hand are overwritten by the Blueprint's on the next sync.

### Step 5: Check the deployment

```bash
curl https://taxcy-api.onrender.com/v1/health/ready
# {"status":"ok","checks":{"postgres":"ok","redis":"ok","s3":"ok"}}
```

Render's health check uses `/v1/health/live` (process up). `/v1/health/ready` also checks Postgres, Redis and B2, so it's the one to try when something is misconfigured. API docs are at `https://taxcy-api.onrender.com/docs`.

In the API's **Logs** you should see, in order: `db:roles: …`, Prisma applying migrations (or `No pending migrations to apply.`), `reference data: … cab models added` (or `already up to date`), the `DEMO_MODE: SMS is not sent…` warning, `jobs: started (in-process); queues [media, fleet, fuel, telemetry, trip]…`, and about half a minute later `vehicle catalogue built: … brands, … models`.

### Reference data and the vehicle catalogue

Two things fill the add-vehicle form's brand and model dropdowns, and both look after themselves on every deploy:

- **The cab shortlist** (the cars Indian fleets run as cabs, with a fuel baseline each) is reference data, not demo data. `start-api.sh` loads it on every start through `dist/seed/reference-cli.js`, regardless of `SEED_DEMO_DATA`. It is idempotent — one query, then inserts only what is missing — so a model added to `apps/api/src/seed/cab-models.ts` reaches production with the next deploy, and a baseline someone has tuned is left alone. Locally: `bun run db:reference`.
- **The wider India list** is built from Wikipedia and Wikidata and cached in Redis for a week. A cold build takes about half a minute, so the API warms it in the background once it is listening (never blocking the health check), and the `fleet.vehicle_catalog_refresh` schedule rebuilds it weekly, inside that week, so the cache never expires while someone is waiting. If both fail, the form falls back to typing the make and model in.

### Step 6 (optional): Load the demo fleet

The seed creates an owner, a manager, three drivers and vehicles, and six weeks of trips, fills and photos ([getting started](getting-started.md#step-7-create-the-database-and-load-sample-data) describes it). Render's free plan has no shell, so the start script can run it:

1. `taxcy-api` → **Environment** → set `SEED_DEMO_DATA=true` → save. The API restarts, seeds (a minute or two; photos go to B2), then starts.
2. Once the logs show the seeded users, set it back to `false`, so cold starts don't spend time on the (skipped) seed check.

The seed is safe to re-run: it does nothing if the demo org exists. Alternatively run it from your laptop against Neon and B2: put the Neon and B2 values in `.env` (keeping `REDIS_URL` pointed at your local Redis) and run `bun run db:seed`.

Seeded phone numbers: owner `9000000001`, manager `9000000002`, drivers `9000000011`–`9000000013`, all with the password `12345678`.

### Step 7: Build the APK for this API

```bash
API_URL=https://taxcy-api.onrender.com bun run build:apk:arm64
```

Then install it as in [Part 1](#install-on-a-phone).

### Custom domains (optional)

Both services can use your own domain on the free plan (**Settings → Custom Domains**, then a CNAME at your DNS provider; Render issues the certificate). Afterwards update: `CORS_ORIGINS` (API), `API_URL` (web app, then redeploy), the B2 CORS rules, and rebuild the APK if the API's domain changed.

### Updating

Every push to `main` redeploys (`autoDeployTrigger: commit`); build filters skip the API for app-only changes and the web app for anything outside `apps/driver-app`. New migrations are applied by the start script on the next start. Locally, `bun run db:deploy` does the same (role check + `prisma migrate deploy`) against whatever `.env` points at.

### The web app

`taxcy-web` is the Flutter app (`apps/driver-app`) built for the browser: the same screens as the APK, with owner mode and driver mode. Render's build image has no Flutter, so `infra/render/build-web.sh` clones the SDK at `FLUTTER_VERSION`, then runs `flutter build web --release --dart-define=API_URL=…`. The SQLite WebAssembly files the app's local database needs (`web/sqlite3.wasm`, `web/drift_worker.js`) are committed.

To build or try it locally:

```bash
cd apps/driver-app
flutter build web --release --dart-define=API_URL=https://taxcy-api.onrender.com
# output: apps/driver-app/build/web; serve it with any static server, e.g.
npx serve build/web
```

In a browser, driver mode works while the tab is open: GPS is recorded only while the page is visible, and photos come from the browser's camera or file picker. Drivers on the road should use the APK, which records in the background.

---

## Part 4: Sign-in on a free deployment

Everyone signs in with **mobile number + password**. New users tap **Sign up** (number, password, optional name; no code). An invited driver or manager who has no password yet signs up with the invited number, which sets their password and joins them to the fleet.

To add **log in with OTP**, verified sign-up and forgot password by OTP, set up [phone OTP](phone-otp.md) (phone.email; Android, iOS and the web app): `PHONE_OTP_PROVIDER=phone_email` and `PHONE_EMAIL_CLIENT_ID` on `taxcy-api`. No app rebuild is needed.

### Password-reset codes (demo mode)

Only **Forgot password?** needs a code sent to the phone. There's no SMS provider in the code yet (`SMS_PROVIDER` only has `console`), and Indian SMS gateways (MSG91, Twilio, Gupshup, Fast2SMS, …) all need paid credit and DLT registration of the sender and templates.

So the free deployment runs in **demo mode**:

- `SMS_PROVIDER=console` writes each reset code to the API log instead of sending it. In production (`NODE_ENV=production`) the API **refuses to start** with `console` unless `DEMO_MODE=true` is set explicitly, and then logs a `DEMO_MODE: SMS is not sent…` warning at every start.
- To reset a password: tap **Forgot password?** in the app (web or APK) and request a code, then open Render → `taxcy-api` → **Logs**, search for `otp.issued`, and read the line `otp.issued phone=+91… code=123456`. Enter it with the new password; other sessions are signed out.
- Signed in, change the password under **More → Account security** (owner mode) or the menu's **Account security** (driver mode).

### Master password (testing only)

Set `MASTER_PASSWORD` (8+ characters) on the API to test as anyone without knowing their password:

- **Sign in as anyone:** enter any existing user's number and the master password. It doesn't create accounts, and the usual sign-in rate limits apply.
- **Reset anyone's password:** sign in as them with the master password, then **Account security → Change password** with the master password as the current password. (The **Forgot password?** form still needs the 6-digit code.)
- Every use is logged as a warning, `auth.master_password_used action=login phone=+91…`, and the API warns at startup while it's set. In production it starts only with `DEMO_MODE=true`.

Whoever knows it can be anyone, so keep it out of chats and screenshots, change it if it leaks, and leave it empty before real users arrive.

Anyone who can read the API's logs can reset anyone's password, so demo mode is only for demos with test data. Sign-up doesn't verify the phone either: whoever signs up first with an invited number claims it. For real users, implement an `SmsProvider` (`apps/api/src/modules/identity/sms.provider.ts`) for your gateway, add it to the `SMS_PROVIDER` enum in `config.ts`, remove `DEMO_MODE`, and add SMS verification to sign-up.

---

## Troubleshooting

| Symptom                                                                                                         | Cause and fix                                                                                                                                                                                                                                                                                 |
| --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `build-apk: release builds need an https:// API_URL`                                                            | Release builds block plain HTTP. Use the HTTPS API URL, or a debug `flutter run` for a LAN laptop.                                                                                                                                                                                            |
| Gradle: `SDK location not found` / licences not accepted                                                        | Run `flutter doctor` and `flutter doctor --android-licenses`; set `ANDROID_HOME` if the SDK isn't in the default place.                                                                                                                                                                       |
| Gradle: `Keystore file … not found` or `wrong password`                                                         | `storeFile` in `android/key.properties` must be an absolute path (or relative to `android/app/`), and both passwords must match the keystore's.                                                                                                                                               |
| `adb: INSTALL_FAILED_UPDATE_INCOMPATIBLE`                                                                       | The installed app has a different signing key. `adb uninstall in.taxcy.taxcy_driver`, then install again.                                                                                                                                                                                     |
| `INSTALL_FAILED_VERSION_DOWNGRADE`                                                                              | The installed build has a higher `versionCode`. Pass a larger `--build-number`, or uninstall first.                                                                                                                                                                                           |
| App: network error on the first try                                                                             | The free API was asleep; wait a minute and retry. Check `https://<api>/v1/health/live` in a browser.                                                                                                                                                                                          |
| App: photos stay "waiting to upload"                                                                            | `/v1/health/ready` shows `s3: error` → check `S3_ENDPOINT`, `S3_REGION` (must match the endpoint), the keys (not the master key), the bucket name and that the key covers the bucket.                                                                                                         |
| Render deploy fails: `Invalid environment configuration: SMS_PROVIDER: console only logs password-reset codes…` | `DEMO_MODE` isn't `true`. Set it (demo) or configure a real SMS provider.                                                                                                                                                                                                                     |
| Render deploy fails at `db:roles: …`                                                                            | `DATABASE_MIGRATION_URL` isn't the Neon owner URL, or `DATABASE_URL` uses the owner's user. `permission denied to create role` means the owner lacks `CREATEROLE`: create `taxcy_app` (NOLOGIN) and `taxcy_api` (LOGIN, member of `taxcy_app`) by hand as in `infra/postgres/init-roles.sql`. |
| Neon: `password authentication failed for user "taxcy_api"`                                                     | The password in `DATABASE_URL` has characters that need URL-escaping; use `openssl rand -hex 24`. The start script resets the role's password to whatever `DATABASE_URL` holds on every start.                                                                                                |
| Neon: SSL / `channel_binding` errors                                                                            | Keep `sslmode=require`; if a client complains about `channel_binding=require`, drop that parameter from the URL.                                                                                                                                                                              |
| Prisma: `P3009 migrate found failed migrations`                                                                 | A migration failed half-way. Read the API log, fix the cause, then mark it with `prisma migrate resolve` from your laptop (`cd libs/db`, `DATABASE_MIGRATION_URL=… node_modules/.bin/prisma migrate resolve --rolled-back <name>`).                                                           |
| Web app: `Failed to fetch` / CORS error in the browser console                                                  | `CORS_ORIGINS` on the API must contain the web app's URL exactly (scheme, host, no trailing slash); `API_URL` on `taxcy-web` must be the API URL, and the site must be redeployed after changing it.                                                                                          |
| Web app: 404 on refresh of a deep link                                                                          | The `/* → /index.html` rewrite is missing; it's in `render.yaml` (`routes`). Re-sync the Blueprint.                                                                                                                                                                                           |
| Web app: photos don't load (CORS error on `*.backblazeb2.com`)                                                  | The web app downloads photos with JavaScript, so the bucket's CORS rules must allow its origin (Step 2.3).                                                                                                                                                                                    |
| `taxcy-web` build fails at `git clone … flutter` or `API_URL`                                                   | `FLUTTER_VERSION` must be a Flutter release tag (e.g. `3.38.5`), and `API_URL` must be set on the service.                                                                                                                                                                                    |
| Browser upload fails with a CORS error on `*.backblazeb2.com`                                                   | Add the page's origin to the bucket's CORS rules (Step 2.3), applied to the **S3 Compatible API**.                                                                                                                                                                                            |
| B2: `SignatureDoesNotMatch` / `InvalidAccessKeyId` / `AuthorizationHeaderMalformed`                             | `S3_REGION` doesn't match the endpoint's region, or the key is the account's master key (B2's S3 API doesn't accept it). Create a bucket-scoped application key.                                                                                                                              |
| B2: `Unsupported header 'x-amz-checksum-…'` / uploads fail with 400                                             | An S3 client is using the AWS SDK's default checksums. `apps/api/src/platform/s3.service.ts` sets `requestChecksumCalculation` and `responseChecksumValidation` to `WHEN_REQUIRED`; keep that if you add another S3 client.                                                                   |
| `/v1/health/ready` shows `redis: error`                                                                         | The Key Value instance must be in the same region as the API (both `singapore` in `render.yaml`).                                                                                                                                                                                             |
| Jobs (OCR, fuel audit) never finish                                                                             | Check the log for `jobs: started (in-process)`. If missing, `JOBS_MODE` isn't `in-process`. The workers app refuses to start when `JOBS_MODE=in-process`, so the two can't both run jobs.                                                                                                     |

## Moving beyond the free tier

- **SMS:** implement a real `SmsProvider`, set `SMS_PROVIDER` to it, remove `DEMO_MODE`, and verify the phone at sign-up.
- **Master password:** empty `MASTER_PASSWORD` (production refuses it without `DEMO_MODE` anyway).
- **Always-on API:** a paid Render instance (no sleep; enables `preDeployCommand`, where `bun run db:deploy` could move from the start script).
- **Jobs:** `JOBS_MODE=external` plus a Render background worker running `apps/workers` (`node apps/workers/dist/main.js`), so the API can scale to more instances. Bull Board is then on the worker's `WORKERS_DASHBOARD_PORT`; don't expose it publicly without auth.
- **Redis:** a persistent Key Value plan (BullMQ needs `maxmemory-policy noeviction`, already set).
- **Postgres:** a paid Neon plan (no compute-hour cap, backups/point-in-time restore) or another managed Postgres with PostGIS.
- **Client IPs:** trust Render's proxy hops in Express so per-IP limits (reset codes, sign-up, login) are per client.
- **App releases:** an upload keystore, Play App Signing, and the Play Console instead of sideloading.

## Sources (checked October 2026)

- Render free tier: <https://render.com/docs/free>; Blueprint spec: <https://render.com/docs/blueprint-spec>; Bun on native runtimes (`BUN_VERSION`): <https://render.com/changelog/added-native-support-for-bun>; Hobby plan bandwidth change of 1 Aug 2026 (third-party summary): <https://jwatte.com/blog/render-com-platform-review.md>
- Neon pricing and limits: <https://neon.com/pricing>; roles created with SQL: <https://neon.com/docs/manage/roles>; regions: <https://neon.com/docs/introduction/regions>
- Upstash Redis pricing: <https://upstash.com/pricing/redis>; BullMQ on Upstash: <https://upstash.com/docs/redis/integrations/bullmq>
- Backblaze B2 pricing: <https://www.backblaze.com/cloud-storage/pricing>; S3-compatible API and endpoints: <https://www.backblaze.com/docs/cloud-storage-s3-compatible-api>; CORS rules (S3 `PutBucketCors` supported): <https://www.backblaze.com/docs/cloud-storage-cross-origin-resource-sharing-rules>; AWS SDK checksum defaults: <https://docs.aws.amazon.com/sdkref/latest/guide/feature-dataintegrity.html>
- Cloudflare R2 pricing (alternative): <https://developers.cloudflare.com/r2/pricing/>
- Supabase pricing: <https://supabase.com/pricing>
