# Owner guide (owner mode in the app)

Owners and managers run their fleet from **owner mode** in the Fleet Sarthi app: the same app drivers use, on an Android phone or in a browser. Drivers use **driver mode** ([driver guide](driver-guide.md)). One account can do both: you can run your own fleet and drive for someone else's, and switch between them without signing out ([Switch mode or fleet](#switch-mode-or-fleet)).

Owner mode has four tabs: **Dashboard**, **Trips**, **Alerts** and **More** (everything else). They're a bar at the bottom on a phone, and a rail on the left on a tablet or a desktop browser.

## 1. Sign in

Your **mobile number** is your identity in Fleet Sarthi: invites and fleets go by it. Sign in with your **mobile number + password**: enter your 10-digit number and your password. A wrong number and a wrong password give the same message, on purpose. After several wrong tries you have to wait a few minutes.

You start in a fleet you own or manage, in owner mode. If you only drive for other fleets, you start in driver mode.

### Sign up

New to Fleet Sarthi? Choose **Sign up**, enter your mobile number, your name (optional) and a password (at least 8 characters, typed twice). No code is needed, and you're signed in straight away. If you were invited as a manager or driver, use the invited number: the invite is picked up automatically.

If you're not part of a fleet yet, you get a **Welcome** screen with two choices:

- **Drive for a vehicle owner:** give the owner your number so they can add you as a driver, then tap **Check again**.
- **Own vehicles?** Tap **I own vehicles: set up my fleet**, enter your fleet or business name, and tick **I also drive my own vehicles** if you do (an owner-driver). You land in owner mode in your new fleet.

If the number already has a password, sign-up says so: sign in, or reset the password instead.

> The phone number isn't verified at sign-up, so whoever signs up first with an invited number gets that account. That's fine for demos and pilots; SMS verification is needed before real use.

### Forgot your password

On the sign-in screen choose **Forgot password?**, enter your mobile number and tap **Send code**, then enter the 6-digit reset code we text you and a new password. You're signed in, and **signed out on every other device**. The code lasts 5 minutes; **Resend code** becomes available after a short wait. In local development and on the demo server no SMS is sent: the code is printed in the API log (`otp.issued phone=… code=…`).

### Account security

**More → Account security** (also in **Settings**) shows your number and whether a password is set.

- **Change password**: enter your current password and the new one twice. If you've forgotten the current one, sign out and use **Forgot password?**.

### Language

The app is available in **English** and **Hindi (हिन्दी)**. Pick one from the language button on the sign-in screen, or **More → Language** (also in **Settings**); the choice is remembered on that phone or browser.

Everything is shown in the chosen language, including alerts, settlement lines and error messages, with amounts in rupees with Indian grouping (₹1,23,456) and times in IST. Names, places, notes and reasons that people typed are shown exactly as entered. A few older alerts raised before this feature stay in English.

### Switch mode or fleet

Roles belong to a fleet, not to your account. If you own one fleet and drive in another, or own and drive in the same one, **More → Switch mode or fleet** lists everything you can do: **Manage _fleet_** (owner mode) and **Drive for _fleet_** (driver mode). In driver mode it's in the **⋮** menu. Switching to another fleet needs a connection, and waits until trips recorded on this device have synced.

## 2. Set up your fleet

### Vehicles

**More → Vehicles → Add vehicle**

- Registration number, make/model, year, and **fuel type** (petrol, diesel, CNG, or petrol + CNG). Fuel type is required and decides whether fuel is measured in litres or kg.
- Current odometer reading (optional, used to catch odometer rollbacks).
- **Drivers** (optional): who may drive it. A trip can only pair a vehicle with a driver linked to it. Change the list any time with **Edit drivers** on the vehicle's page. In an owner-driver business you're linked to every vehicle you add.

### Drivers

**More → Drivers → Invite driver**

- Name and mobile number. The driver signs up in the app with that number and chooses a password; they join your fleet straight away.
- **Vehicles** (optional): the vehicles they may drive. A driver can be linked to several vehicles, and a vehicle to several drivers. Change it later with **Edit vehicles** on the driver's page. A driver can't be unlinked from a vehicle while they have an assigned or running trip in it: reassign or finish that trip first.

### Documents

**More → Documents**, or the Documents tab on a vehicle's page.

- Add RC, insurance, permit and PUC for each vehicle, and a driving licence for each driver, with expiry dates and an optional photo or scan.
- When you renew a document, use **Renew** on the old one. That keeps the history and stops alerts for the old copy.
- You'll get alerts **30, 7 and 1 days** before expiry, and again on the day it expires.

## 3. Trips

### Create a trip

**Trips → New trip**

- Type: **One way**, **Round trip** or **Local rental**.
- Pickup and drop, as text (local rentals have no drop point). Optionally tap **Add map pin** under either one, tap the map where the place is (tap again to move the pin), then **Use this pin**. The pins show on the trip's map; the text is still what the driver reads.
- Scheduled start and end, customer name and phone, and the **quoted fare** in ₹.
- **Included km** (optional): the km the fare covers, e.g. 300 for a 300 km package. The trip page shows how far the trip went past it, and the driver is prompted to add an extra km charge.

Drivers can also create trips themselves in the app (for example a walk-in customer). Those are assigned to the driver, in the vehicle they picked (drivers only see the vehicles they're linked to), and the usual double-booking checks apply.

**Charges.** Night charges, extra km and driver allowance are extra fare: added to what the customer pays and never reimbursed to the driver. Tolls, parking, state tax and other charges are expenses, reimbursed to the driver when they paid.

### Assign

Pick a vehicle and driver. Only drivers linked to the chosen vehicle are offered (and, if you pick the driver first, only their vehicles); a vehicle with no linked drivers says so, with **Edit drivers** to link some without leaving the form. If either is already booked for an overlapping time, you'll see which trip conflicts. A driver, and a vehicle, can only have one trip on the road at a time: a trip can't start until the earlier one has ended.

### Track

The **Trips** tab lists trips, filtered by status, day, driver and vehicle, with each trip's status: Created → Assigned → Started → Ended → Settled (or Cancelled). A trip's page shows:

- a timeline of every status change: who did it and when (device time and server time)
- start and end odometer photos, with the typed value and the OCR value
- the GPS route on a map, plus the **odometer vs GPS** result (OK / Flagged / Inconclusive)
- collections and charges (tolls, parking, etc.)

### Add or correct charges

On the trip detail page, **Charges → Add** lets you add tolls, parking, state tax, driver allowance, night charge or extra km, and mark whether the driver paid it out of pocket. Charges the driver added in the app also appear here, labelled with who entered them. You can void a wrong charge any time before the day is settled.

### Cancel

- **Not yet started:** **Cancel trip** asks for a reason and takes effect immediately. If the driver was offline, they'll see it as soon as their app syncs.
- **Already started:** the trip can only be cancelled with a reason and an approval. When a driver requests a cancellation, you'll get an alert, and the trip shows **Cancellation requested** with the reason and end-odometer photo. Choose:
  - **Approve**: optionally enter a cancellation fare (for example, to charge for the distance already driven). The trip becomes Cancelled.
  - **Reject**, with a note: the trip continues.

  You can also start a cancellation yourself on a running trip. You'll be asked for the reason, and the driver will be prompted for the end odometer.

## 4. Fuel

**More → Fuel → (pick a vehicle)**, or the Fuel tab on a vehicle's page

- A list of fills: date, driver, quantity, cost, odometer, full-tank flag and receipt photo.
- A **cycles chart**: efficiency (km/L or km/kg) for each full-tank-to-full-tank cycle, coloured by verdict. Flagged cycles are shown in red.
- **Petrol + CNG cars** are charted as **cost per km (₹/km)** instead, because there's no way to tell how far they drove on each fuel. Here a _higher_ value is worse, and running on petrol when CNG is available shows up as a spike.
- Below the chart, each cycle with its dates, distance, efficiency, the vehicle's usual figure and the rule that flagged it (or didn't).
- A wrong fill can be voided with a reason.

**Getting accurate numbers:** ask drivers to fill **to full tank** regularly and to turn on "Full tank" in the app when they do. Efficiency can only be measured between two full-tank fills.

New vehicles use a typical figure for their model for the first 3 cycles. After that, Fleet Sarthi compares each vehicle against its own history.

## 5. Alerts

The **Alerts** tab is your inbox for anything that needs attention (filter by status and kind):

| Alert                                              | What it means                                                                  |
| -------------------------------------------------- | ------------------------------------------------------------------------------ |
| Fuel use higher than usual                         | A fuel cycle was much worse than the vehicle's normal efficiency               |
| Odometer higher than GPS                           | A trip's odometer distance is well above the GPS-recorded route                |
| Document expiring / expired                        | RC, insurance, permit, PUC or DL is due                                        |
| Running cost higher than usual (petrol + CNG cars) | Cost per km in a cycle was much higher than the car's normal                   |
| Cancellation requested                             | A driver asked to cancel a running trip; approve or reject it on the trip page |

Each alert explains in plain language what happened and what to check. Mark it **Acknowledged**, **Resolved** or **Dismissed**. Dismissing a fuel alert as a false alarm lets that cycle count toward the vehicle's normal range.

## 6. Review queue

**More → Review** lists items where Fleet Sarthi isn't sure and needs a decision. Most often the photo and the typed number don't match. Each item shows the photo, the typed value and the value read from the photo. Choose:

- **Keep typed value**
- **Use value from photo**
- **Enter correct value**
- **Dismiss**

Fuel and distance checks are recalculated automatically after your decision.

## 7. Daily settlement

**More → Settlements** shows one row per driver for a day (yesterday by default; pick another date at the top):

| Column          | Meaning                                                               |
| --------------- | --------------------------------------------------------------------- |
| Expected fare   | Quoted fares plus charges for trips that ended that day               |
| Cash            | Cash the driver collected                                             |
| Online          | UPI/card payments (already in your account)                           |
| Driver expenses | Fuel and tolls the driver paid from their pocket                      |
| Driver earnings | Per the driver's pay rule (see below)                                 |
| **Net payable** | What the driver hands over (or, if negative, what you owe the driver) |
| Shortfall       | Expected fare minus everything collected. It should be ₹0.            |

Open a row to see every item in it. Once you've received the cash, tap **Mark settled**. A settled day is locked: anything the driver's phone syncs later appears in their next settlement as an adjustment.

## 8. Settings

**More → Settings → Audit**: fuel alert sensitivity (k standard deviations, minimum cycles, percentage threshold), odometer-vs-GPS tolerance, and document alert days. The defaults suit most fleets.

**More → Settings → Driver pay**: the default way drivers are paid in settlements:

| Option          | Example                                           |
| --------------- | ------------------------------------------------- |
| None            | Salaried drivers paid outside Fleet Sarthi        |
| Percent of fare | 20% of quoted fare (or of fare including charges) |
| Per trip        | ₹300 per trip                                     |
| Per km          | ₹2 per km driven                                  |
| Fixed daily     | ₹800 for any day with at least one trip           |

Turn **Driver allowance goes to driver** on if the bata customers pay belongs to the driver. To give one driver a different arrangement, open **More → Drivers → (driver) → Pay**. Changing a rule only affects days that haven't been settled yet.

## 9. Good to know

- **Dashboard:** today's trips by status, open alerts by severity, items to review, documents due in the next 30 days, and the most urgent open alerts.
- **Members:** **More → Members** lists people with access; only the owner can invite or remove managers.
- **Managers** can do everything above except change settings and pay: the audit thresholds, the default pay rule and a driver's own pay rule are shown read-only.
- **Needs a connection.** Unlike driver mode, owner mode works online only: each screen loads fresh from the server, shows **Retry** if it can't, and refreshes when you pull down.
- **Sign out:** **More → Sign out**.
