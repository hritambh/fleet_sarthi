# Playing with the demo data

`bun run db:seed` loads **Sharma Travels**, a small Pune fleet with six weeks of history and a handful of planted problems for Fleet Sarthi to catch. This page lists who's in it, what's planted, and walkthroughs that exercise each part of the product from the admin web, the owner app and the driver app.

All dates are relative to the day you seed: "yesterday" below means the day before you ran the seed.

## Start it

```bash
bun run infra:up      # Postgres, Redis, RustFS (if not already running)
bun run dev           # API :3000, workers, admin web :5173
bun run dev:driver-web   # the app in Chrome on :5174 (or run it on a phone, see getting-started.md)
```

### Reset to a fresh copy

```bash
bun run db:reset      # drops every table in the local database, re-migrates, seeds
```

`db:reset` destroys all data in the database named in `.env`. It is for your local Docker database only; never point it at a hosted one. `bun run db:seed` on its own does nothing if Sharma Travels already exists.

The reset doesn't touch uploaded photos (RustFS) or the job queue (Redis). For a completely clean start, clear those first:

```bash
docker compose run --rm --no-deps --entrypoint sh s3-init -c 'aws --endpoint-url http://s3:9000 s3 rm "s3://$BUCKET" --recursive'
docker exec taxcy-redis-1 redis-cli FLUSHALL
```

After a reset, the app in Chrome still holds the old trips and any unsent actions in its local database. Sign out (or clear the site data for `localhost:5174`) so it starts fresh; otherwise its queued actions fail with "not found".

## Who's who

| Person       | Phone        | Role    | Drives                                   | Notes                                                                  |
| ------------ | ------------ | ------- | ---------------------------------------- | ---------------------------------------------------------------------- |
| Anil Sharma  | `9000000001` | Owner   | —                                        | Sees and changes everything                                            |
| Priya Nair   | `9000000002` | Manager | —                                        | Runs trips, alerts and settlements; can't change settings or pay rules |
| Ramesh Kumar | `9000000011` | Driver  | MH12AB1234 Toyota Innova Crysta (diesel) |                                                                        |
| Suresh Patil | `9000000012` | Driver  | MH12CD5678 Maruti Dzire (CNG)            | On a trip right now                                                    |
| Imran Shaikh | `9000000013` | Driver  | MH12EF9012 Toyota Etios (petrol)         | Has a trip this evening                                                |

- Each driver is linked to their own car only. Linking more pairs is one of the walkthroughs below.
- Driver pay: the org default, **20% of the quoted fare**, with driver allowances paid to the driver.

### Signing in

The demo people have **no passwords**. On the sign-in screen choose **Use an SMS code instead**, enter the number and tap **Send code**. Nothing is sent locally: the code is printed in the API log:

```
otp.issued phone=+919000000001 code=482913 (dev only, not sent)
```

To skip codes from then on, set a password under **Account security** (app: driver menu or More; web: account menu). **Continue with Google** works too while no Google client id is set: the stand-in asks for an email, then you verify one of the numbers above with a code.

## What's in it

- **42 days of history:** about 85 ended trips across the three cars, with odometer photos (221 photos in all), fuel fills whenever a tank ran low, tolls on some trips, and GPS routes for the last 4 days.
- **Settlements:** every day up to 3 days ago is settled; the last two days are open drafts.
- **Documents:** RC, insurance, permit and PUC for each car, and each driver's licence.
- **Today's board:**

  | Trip                         | Status      | Who                                                                      |
  | ---------------------------- | ----------- | ------------------------------------------------------------------------ |
  | Hinjewadi Phase 1 → Lonavala | Ended       | Ramesh, MH12AB1234 (an early run)                                        |
  | Aundh → Lavasa (round trip)  | On the road | Suresh, MH12CD5678, started 75 minutes before the seed, with a GPS route |
  | Koregaon Park (local rental) | Assigned    | Imran, MH12EF9012, this evening                                          |
  | Pune Station → Goa (Panaji)  | Created     | Not assigned yet, tomorrow                                               |
  | Wakad → Mumbai Central       | Cancelled   | "Customer booked a flight instead"                                       |

### Planted problems

| What you'll see                                                                                                       | Where             | Why it's there                                                                                                      |
| --------------------------------------------------------------------------------------------------------------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Critical:** MH12CD5678 (Dzire, CNG) used more fuel than usual                                                       | Alerts            | Fills in the last 3 days were inflated (simulated fuel theft); the fuel audit compares the car with its own history |
| **Critical:** yesterday's Kothrud → Mahabaleshwar trip in MH12AB1234 shows more km on the odometer than the GPS route | Alerts            | The end reading was padded by about 21%                                                                             |
| **Warning:** insurance for MH12CD5678 expires in 5 days                                                               | Alerts, Documents |                                                                                                                     |
| **Info:** PUC for MH12EF9012 expires in 24 days; Imran's driving licence in 25                                        | Alerts, Documents |                                                                                                                     |
| **Review:** an odometer photo that doesn't match the typed reading (60 km apart)                                      | Review            | Imran's trip 2 days ago: the photo shows 60 km more than he typed                                                   |

## Walkthroughs

### 1. The owner's morning check (admin web or owner app)

1. Sign in as **Anil** (`9000000001`). The dashboard shows today's trips, open alerts and money owed.
2. Open **Alerts**. Open the Dzire fuel alert: it shows the fills and the expected range. Resolve it with a note.
3. Open the odometer-vs-GPS alert: compare the trip's route on the map with the odometer km.
4. Open **Review**, look at the photo next to the typed reading, and accept the photo's value or keep the typed one. Your decision corrects the record.

### 2. A driver's live trip (driver app)

1. Sign in as **Suresh** (`9000000012`). **Aundh → Lavasa** is on the road.
2. Add a **toll** or **parking** charge, and a **fuel fill** (the car is filled in from the trip). They show on the trip right away, before it ends.
3. Try to start another trip: **Start trip** is greyed out with "End your trip Aundh → Lavasa before starting another".
4. **End trip:** take an odometer photo and enter a reading above the start reading (about 61,000 km plus the km driven). As the owner, the trip now shows in today's settlement draft for Suresh.

### 3. Drivers and vehicles (owner)

1. Open the **Goa** booking and assign it. Pick **MH12AB1234**: only Ramesh is offered, because only he is linked to it.
2. Open **Vehicles → MH12CD5678 → Edit drivers** and add Ramesh. Now both Suresh and Ramesh can be put on the Dzire, and Ramesh's vehicle list (in his app) shows both cars.
3. Open **MH12EF9012 → Edit drivers** and try to remove Imran. It's refused: he has this evening's trip in that car. Unassign or reassign that trip first, then the unlink works.
4. Through the API, assigning an unlinked pair fails with `DRIVER_NOT_LINKED`; the forms simply don't offer it.

### 4. A driver books their own trip (driver app)

1. Sign in as **Ramesh** (`9000000011`) and tap **New trip**.
2. The vehicle list shows only the cars Ramesh is linked to. Enter the customer, route, fare and optionally the km included in the fare, then save. It's assigned to Ramesh straight away, and the owner sees it on the trip board.

### 5. Extra fare and settlement

1. On a running or ended trip, add a **night charge** or **extra km** charge. These are added to what the customer pays (extra fare) and are never treated as the driver's expense.
2. As the owner, open **Settlements** for yesterday: a draft per driver with fares, the driver's 20% share, allowances, tolls and fuel the driver paid, and the cash to collect or pay. Settle a day to freeze it.

### 6. Cancelling a trip that has started

1. As **Suresh**, ask to cancel the running trip with a reason.
2. As **Anil** or **Priya**, approve (optionally with a cancellation fare) or reject the request from the trip.

### 7. Manager limits

Sign in as **Priya** (`9000000002`). She can create and assign trips, handle alerts and review, and settle days. Settings and driver pay rules are read-only for her.

### 8. Offline driver (app in Chrome)

1. As a driver, open Chrome DevTools → **Network → Offline**.
2. Add a charge or a fuel fill, or end a trip. The app saves it and shows pending actions.
3. Go back online: the actions sync in order, and the pending count drops to zero.

### 9. Hindi

Switch the language (sign-in screen, the web sidebar footer, or the app menu) to **हिन्दी**. Alerts, settlement lines, errors and dates follow the language; the server sends codes and the apps word them.

## On a hosted demo

The free Render deployment can load the same data: set `SEED_DEMO_DATA=true` once, then set it back to `false`. Login codes are in the Render logs. See [deployment.md](../deployment.md#step-6-optional-load-the-demo-fleet).
