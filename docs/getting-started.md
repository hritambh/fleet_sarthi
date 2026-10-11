# Getting started: run Fleet Sarthi locally, step by step

> Everything in this guide works as of M1.8. The one exception is the Maestro end-to-end flow (M1.9), marked below. The app has been built and unit-tested, and compiles for Chrome, but hasn't yet been run on a real phone; see [roadmap.md](roadmap.md).

Fleet Sarthi has one app (`apps/driver-app`, Flutter) for owners, managers and drivers, in Chrome or on a phone. Owners and managers get **owner mode**; drivers get **driver mode**.

This takes about 20 minutes the first time, mostly downloads.

---

## Step 1: Install the tools

### macOS

```bash
# Homebrew (skip if installed): https://brew.sh
brew install fnm                          # Node version manager
fnm install 24 && fnm use 24
curl -fsSL https://bun.sh/install | bash  # Bun, used as the package manager
brew install --cask docker                # Docker Desktop. Open it once and let it finish starting.
```

For the app, also install Flutter (<https://docs.flutter.dev/get-started/install/macos>) and Google Chrome. To run it on a phone or emulator you also need Android Studio, Xcode, or both.

### Linux

Install Node 24 (via `fnm` or `nvm`), Bun (`curl -fsSL https://bun.sh/install | bash`), and Docker Engine with the Compose plugin. Add yourself to the `docker` group. Install Flutter and Chrome for the app, and Android Studio to run it on Android.

### Windows

Use **WSL 2** (Ubuntu) and follow the Linux steps inside it, with Docker Desktop's WSL integration turned on. To run the app in Chrome or on an Android emulator, install Flutter on Windows itself.

### Check

```bash
node -v          # v24.x
bun -v           # 1.4.x
docker info      # must not print "Cannot connect to the Docker daemon"
flutter --version   # 3.38.x (the app)
```

## Step 2: Get the code and install dependencies

```bash
git clone https://github.com/hritambh/taxcy.git
cd taxcy
bun install
```

Bun installs every workspace (apps and libs) and writes nothing outside the repo.

## Step 3: Create your environment file

```bash
cp .env.example .env
```

The defaults work for local development. If one of the default host ports (5433, 6380, 9000, 9001, 3000, 5174) is taken on your machine, change it in `.env`.

## Step 4: Start Postgres, Redis and RustFS

```bash
bun run infra:up
```

This runs `docker compose up -d --wait` and returns once everything is healthy:

| Service                 | Address                                 | Login                        |
| ----------------------- | --------------------------------------- | ---------------------------- |
| PostgreSQL 16 + PostGIS | `localhost:5433`                        | `taxcy` / `taxcy`            |
| Redis                   | `localhost:6380`                        | —                            |
| RustFS (S3)             | <http://localhost:9000>                 | `taxcy` / `taxcy-dev-secret` |
| RustFS console          | <http://localhost:9001/rustfs/console/> | same                         |

The `taxcy-media` bucket is created automatically. To check:

```bash
docker compose ps                                     # postgres, redis, s3: healthy
docker compose exec postgres psql -U taxcy -c 'select postgis_version()'
```

## Step 5: Start the API and workers

```bash
bun run dev
```

Nx builds the shared libs, then runs two processes with prefixed logs:

| Process          | What you should see                                                 |
| ---------------- | ------------------------------------------------------------------- |
| `@taxcy/api`     | `Nest application successfully started`, at <http://localhost:3000> |
| `@taxcy/workers` | `workers: started, no queues registered yet`                        |

Leave this running and use a second terminal for the next steps.

## Step 6: Check that it works

```bash
curl localhost:3000/v1/health/ready
# {"status":"ok","checks":{"postgres":"ok","redis":"ok","s3":"ok"}}
```

The API docs are at <http://localhost:3000/docs>. Edit any file under `apps/api/src` and the API restarts by itself.

---

## Step 7: Create the database and load sample data

```bash
bun run db:migrate
bun run db:seed
```

The seed prints the logins it created. Every demo person has the password `demo1234`:

```
Seeded org "Sharma Travels"
  owner    Anil Sharma     +919000000001
  manager  Priya Nair      +919000000002
  driver   Ramesh Kumar    +919000000011   (Innova Crysta, diesel)
  driver   Suresh Patil    +919000000012   (Dzire, cng)
  driver   Imran Shaikh    +919000000013   (Etios, petrol)
Sign in with any of these numbers and the password demo1234.
```

Re-running the seed is safe. `bun run db:reset` wipes the database and seeds it again. [Demo data](usage/demo-data.md) lists what the seed contains and walks through trying each feature with it.

## Step 8: Open the app in Chrome and sign in as the owner

```bash
bun run dev:driver-web   # opens Chrome at http://localhost:5174, talking to the API on :3000
```

The first build takes a minute. Enter the owner's number (`9000000001`) and the password `demo1234`, and sign in. The owner gets **owner mode**: Dashboard, Trips, Alerts and More (a side rail when the window is wide, a bottom bar when it's narrow).

In the `flutter run` terminal, press `r` to hot-reload after editing anything under `apps/driver-app/lib`. If sign-in fails with a network error, check that `CORS_ORIGINS` in `.env` includes `http://localhost:5174` and restart `bun run dev`.

Forgot a password you changed? Choose **Forgot password?** and request a code. No SMS is sent locally; the code is printed in the `bun run dev` terminal, then enter it with a new password:

```
@taxcy/api: otp.issued phone=+919000000001 code=482913 (dev only, not sent)
```

## Step 9: Explore the seeded data

1. **Alerts:** a critical fuel alert on the Dzire, an odometer-vs-GPS alert on an Innova trip, and an insurance-expiry warning.
2. **More → Fuel → Dzire:** one red cycle well below the vehicle's usual figure, with the fills and the explanation.
3. **Trips → (any ended trip):** the timeline, odometer photos, and the route on the map.
4. **More → Review:** an OCR mismatch. Choose "Keep typed value".
5. **More → Settlements → yesterday:** open a driver's row, check the numbers, then **Mark settled**.
6. **Trips → New trip:** one way, Pune → Mumbai, starting in 10 minutes, fare ₹3,500, assigned to Ramesh and the Innova. You'll drive it in step 11.

## Step 10: Sign in as a driver

Drivers use the same app in **driver mode**. Chrome keeps one signed-in person per browser profile, so keep the owner where they are and pick one:

- **Chrome again:** open <http://localhost:5174> in an incognito window (or another Chrome profile) and use it for the driver. The browser build keeps its data in the browser (SQLite in WebAssembly) and uses the laptop's webcam and location. It records the route only while the tab is open, so use a phone or emulator to test background GPS.
- **A phone, emulator or simulator,** as below.

```bash
cd apps/driver-app
flutter pub get
flutter devices          # list emulators, simulators and phones
flutter run              # pick one
```

Tell the app where the API is:

| Target                      | Command                                                       |
| --------------------------- | ------------------------------------------------------------- |
| Android emulator            | `flutter run --dart-define=API_URL=http://10.0.2.2:3000`      |
| iOS simulator               | `flutter run --dart-define=API_URL=http://localhost:3000`     |
| Physical phone (same Wi-Fi) | `flutter run --dart-define=API_URL=http://<your-LAN-IP>:3000` |

On a physical phone, photo uploads also need `S3_PUBLIC_ENDPOINT=http://<your-LAN-IP>:9000` in the root `.env`. Restart `bun run dev` after changing it. On macOS, `ipconfig getifaddr en0` prints your LAN IP.

## Step 11: Drive a trip

1. Log in as **Ramesh** (`9000000011`, password `demo1234`), and allow camera and location access.
2. Open the Pune → Mumbai trip and tap **Start trip**. Photograph the odometer (an emulator camera shows a test scene and Chrome uses your webcam; either is fine because OCR is stubbed), type `48210`, and tap **Start**.
3. **Simulate driving.** On the Android emulator, open **Extended controls → Location → Routes**, pick or import any route, and press play. On the iOS simulator, use **Features → Location → Freeway Drive**. In Chrome, open DevTools → **More tools → Sensors** and change **Location** a few times while the trip runs (points closer than 50 m apart are skipped).
4. Add a ₹250 toll, marked **I paid this**.
5. **End trip:** photograph the odometer, type `48365`, and enter ₹3,500 cash.
6. In the owner's window, **Trips** shows the trip _Ended_, with the GPS route, the toll, and an odometer-vs-GPS result within a few seconds (pull down to refresh).

## Step 12: Try offline mode

1. Turn on airplane mode (in Chrome: DevTools → **Network** → **Offline**); the status bar shows 🔴 **Offline**.
2. Log a fuel fill: receipt photo, odometer, 40 L, ₹3,800, **Full tank** on. The bar shows 🟡 **1 pending**.
3. Turn airplane mode (or DevTools' Offline) off. The bar goes back to 🟢 **Synced**, and the fill appears in the owner's **More → Fuel**.

To see a sync conflict: put the phone offline, start an assigned trip in the app, cancel that trip from the owner's window, then go back online. The app shows _"This trip was cancelled by the owner"_.

---

## Step 13: Run the checks

```bash
bun run verify     # format check, lint, typecheck, unit tests, build: what CI runs
```

`bun run test:integration` runs the API integration tests against throwaway containers (about 5 minutes; needs Docker). The Maestro end-to-end flow (`bun run test:e2e:driver`) is planned for M1.9.

## Stopping and resetting

```bash
# stop the dev servers: Ctrl+C in the `bun run dev` terminal (and `q` in the `flutter run` one)
bun run infra:down       # stop containers; data is kept
bun run infra:reset      # DELETE all local data (database, Redis, uploaded files) and start fresh
```

## Troubleshooting

| Symptom                                                                         | Fix                                                                                                                                                                                                                                                                                                                        |
| ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Bind for 0.0.0.0:5433 failed: port is already allocated` (or 6380, 9000, 9001) | Something else uses that port. Pick another in `.env` (`POSTGRES_PORT`, `REDIS_PORT`, `S3_PORT`, `S3_CONSOLE_PORT`) and update `DATABASE_URL` / `REDIS_URL` / `S3_ENDPOINT` to match.                                                                                                                                      |
| Chrome opens but `flutter run` says port 5174 is in use                         | Another `dev:driver-web` (or another app) is running. Stop it; the port is fixed so it stays in `CORS_ORIGINS` and the RustFS CORS rules.                                                                                                                                                                                  |
| API logs `EADDRINUSE :::3000`                                                   | Set `PORT=3001` (or another free port) in `.env`, and run the app with `--dart-define=API_URL=http://localhost:3001`.                                                                                                                                                                                                      |
| The app shows a network error on sign-in                                        | The API isn't running or crashed; check the `@taxcy/api` lines in the `bun run dev` output.                                                                                                                                                                                                                                |
| `Cannot find module '@taxcy/…'` when running an app directly                    | Libs haven't been built. Use `bun run dev` / `bun run build` (Nx builds libs first), or `bunx nx run @taxcy/<lib>:build`.                                                                                                                                                                                                  |
| TypeScript can't find `process` or `setInterval` in a new Node package          | Add `@types/node` to that package's `devDependencies` and `"types": ["node"]` to its `tsconfig.json`. TypeScript 6 doesn't auto-load `@types`, and Bun's isolated installs don't share them across packages.                                                                                                               |
| `flutter: command not found` during `bun run lint`                              | The app's lint/test need Flutter. Install it, or run `bunx nx run-many -t lint --exclude @taxcy/driver-app`.                                                                                                                                                                                                               |
| The app in Chrome stays at 🟡 _N pending_                                       | Photo uploads go from the browser straight to RustFS, which must allow the page's origin. `bun run infra:up` applies `infra/s3/cors.json` to the bucket; on an older setup run `docker compose run --rm s3-init` once. Failed uploads retry with backoff (at most 5 minutes apart), so the queue catches up shortly after. |
| RustFS console shows 403                                                        | Use the full console path: <http://localhost:9001/rustfs/console/>.                                                                                                                                                                                                                                                        |
