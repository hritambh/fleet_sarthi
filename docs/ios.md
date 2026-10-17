# Install the app on an iPhone (Xcode)

The same Flutter app (`apps/driver-app`) runs on iPhone. This page covers installing it on your own phone from a Mac with Xcode, pointed at any API (usually the hosted demo, `https://taxcy-api.onrender.com`). It isn't the App Store or TestFlight; those need a paid Apple Developer account (see [the end](#beyond-your-own-phone)).

## What you need

|                                    |                                                                     |
| ---------------------------------- | ------------------------------------------------------------------- |
| A Mac with **Xcode** (16 or later) | From the App Store. Open it once and let it install its components. |
| **CocoaPods**                      | `brew install cocoapods` (Flutter uses it for the iOS plugins)      |
| An **Apple ID**                    | A free one is enough for your own phone; installs then last 7 days  |
| The **iPhone** and its cable       | iOS 14 or later                                                     |

## One-time Mac setup

Point the command-line tools at Xcode (they default to the separate Command Line Tools), finish Xcode's first launch, and accept its licence:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
xcodebuild -downloadPlatform iOS     # the iOS device platform, several GB (also Xcode → Settings → Components)
```

**Xcode version:** the app builds with Xcode 16 because `connectivity_plus` is pinned to 7.0.0 in `pubspec.yaml`; its 7.1+ releases need Xcode 26 (and Xcode 26 needs macOS 15.6 or later). Once the Mac has Xcode 26, move it back to `^7.3` for the later fixes.

Then check: `flutter doctor` should show a green tick for **Xcode** (the iOS simulator line can stay yellow).

In Xcode, add your Apple ID: **Xcode → Settings → Accounts → +**.

## Signing (once per Mac)

1. Open `apps/driver-app/ios/Runner.xcworkspace` in Xcode (the **workspace**, not `Runner.xcodeproj`).
2. Select **Runner** in the left sidebar → the **Runner** target → **Signing & Capabilities**.
3. Tick **Automatically manage signing** and pick your **Team** (your Apple ID, "Personal Team").
4. If Xcode says the bundle identifier `in.taxcy.taxcyDriver` isn't available to your team, change it to something unique to you, e.g. `in.taxcy.taxcyDriver.yourname`. Don't commit that change.

## Install on a new iPhone

Do this for each iPhone the app goes on. The Mac needs the [one-time setup](#one-time-mac-setup) and [signing](#signing-once-per-mac) above.

1. **Connect** the iPhone with its cable, unlock it, and tap **Trust** on the phone (enter the phone's passcode if asked).
2. **Developer Mode:** on the phone, **Settings → Privacy & Security → Developer Mode** → on. The phone restarts; after it does, tap **Turn On** and enter the passcode. (If the option isn't there, open Xcode with the phone connected once; it appears after that.)
3. **Find the phone's id:** from `apps/driver-app`, run `flutter devices`. The iPhone is listed with a long id, e.g. `00008120-000669821487A01E`.
4. **Install:**
   ```bash
   flutter run -d <iphone-id> --release --dart-define=API_URL=https://taxcy-api.onrender.com
   ```
   The first build takes a few minutes. If the Mac asks for the **"login" keychain password**, it's your Mac login password; click **Always Allow**. Xcode registers the new phone with your Apple ID on its own (automatic signing).
5. **Trust the developer** (once per phone): the first time, iOS says "Untrusted Developer". On the phone, go to **Settings → General → VPN & Device Management**, tap your Apple ID under **Developer App**, then **Trust**. The phone needs internet for this.
6. Open **Fleet Sarthi** from the home screen. You can unplug the phone now: `--release` installs an app that runs on its own. Press `q` in the terminal to end `flutter run`.

`--release` with `API_URL` is what makes it a standalone app pointed at the hosted API (it must be `https://`, as on Android). Leave `--release` out for a debug build with hot reload while plugged in. For a local API on your laptop, use `--dart-define=API_URL=http://<laptop-ip>:3000` with a debug build.

**Free Apple ID limits:** an install works for **7 days**, then the app stops opening until you update it (below); and one phone can hold at most 3 apps from the same free Apple ID at a time. A paid Apple Developer account lifts both (installs last a year).

**From Xcode instead:** run `flutter build ios --release --dart-define=API_URL=https://taxcy-api.onrender.com` once (it writes the API address into the Xcode build settings), then in Xcode pick the iPhone at the top and press **Run** (⌘R).

## Update the app on an iPhone that has it

To put a newer version of the app on a phone (after pulling new code), or to renew a free Apple ID's 7-day install:

1. Get the code you want: `git pull` in the repo, then `bun install` if dependencies changed.
2. Connect the iPhone and unlock it.
3. From `apps/driver-app`, run the same command as for the install:
   ```bash
   flutter devices
   flutter run -d <iphone-id> --release --dart-define=API_URL=https://taxcy-api.onrender.com
   ```

The new version replaces the old one in place: the sign-in, settings and a driver's saved trips stay on the phone, and you don't trust the developer again. That holds as long as it's signed by the **same Apple ID (Team)**, from any Mac, and keeps the same bundle id.

**Signing with a different Apple ID** (another Team, or a changed bundle id) can't update the app: iOS shows it as a second app or refuses to install. Delete the old app from the phone first (long-press the icon → **Remove App**), then install as for a new phone. Deleting the app **deletes its data**, so a driver should open the app online first and let it finish syncing (nothing waiting to upload) before you delete it.

## What iOS asks the user

The app's permission texts are in `ios/Runner/Info.plist`:

| Permission                          | When it's asked                                               |
| ----------------------------------- | ------------------------------------------------------------- |
| Camera                              | Photographing the odometer, fuel receipts and documents       |
| Location (while using, then always) | Recording the route while a trip runs, also in the background |
| Photo library                       | Uploading a document photo from the library                   |

Uploading a document on an iPhone offers **Photo library** or **Files (PDF or image)**: the iPhone's Files app doesn't show the Photos library, unlike Android's file chooser. Photos are converted to JPEG on the way in, since iPhone photos are often HEIC.

## Troubleshooting

| Problem                                                                                                                                                | Fix                                                                                                                       |
| ------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| `xcodebuild requires Xcode, but active developer directory … is a command line tools instance`                                                         | Run the `xcode-select` command from the Mac setup above                                                                   |
| Flutter says to pick a Development Team, but the Xcode log shows `Building assets for package:objective_c failed` / `SDK "iphoneos" cannot be located` | `xcode-select` still points at the Command Line Tools: run the `xcode-select` command from the Mac setup above            |
| `CocoaPods not installed`                                                                                                                              | `brew install cocoapods`, then run again                                                                                  |
| "iOS 18.5 is not installed. To use with Xcode, first download and install the platform" (Flutter only says to pick a Development Team)                 | `xcodebuild -downloadPlatform iOS`, or **Xcode → Settings → Components → iOS**                                            |
| `Value of type 'NWPath' has no member 'isUltraConstrained'`                                                                                            | A plugin needs Xcode 26: keep `connectivity_plus` at 7.0.0, or update Xcode                                               |
| "requires a higher minimum iOS deployment version"                                                                                                     | The app targets iOS 14 (`ios/Podfile`, the Xcode project, `AppFrameworkInfo.plist`); raise all three together             |
| "Untrusted Developer" when opening the app                                                                                                             | Trust your Apple ID under **Settings → General → VPN & Device Management**                                                |
| The app stops opening after a week                                                                                                                     | Free Apple ID installs expire after 7 days: [update the app](#update-the-app-on-an-iphone-that-has-it) (its data is kept) |
| "No profiles for 'in.taxcy.taxcyDriver' were found"                                                                                                    | Pick your Team under Signing & Capabilities; change the bundle id if it's taken                                           |
| The phone isn't listed by `flutter devices`                                                                                                            | Unlock it, tap Trust, and turn on Developer Mode                                                                          |

## Beyond your own phone

Installing on other people's iPhones, TestFlight and the App Store need a paid **Apple Developer Program** membership ($99/year), an App Store Connect app record, and an archive built in Xcode (**Product → Archive**). That isn't set up yet.
