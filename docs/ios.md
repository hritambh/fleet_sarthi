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

## One-time iPhone setup

1. Connect the iPhone to the Mac and tap **Trust** on the phone.
2. Turn on **Developer Mode**: **Settings → Privacy & Security → Developer Mode** (it appears after the phone has been connected to Xcode once; the phone restarts).

## Signing (once per Mac)

1. Open `apps/driver-app/ios/Runner.xcworkspace` in Xcode (the **workspace**, not `Runner.xcodeproj`).
2. Select **Runner** in the left sidebar → the **Runner** target → **Signing & Capabilities**.
3. Tick **Automatically manage signing** and pick your **Team** (your Apple ID, "Personal Team").
4. If Xcode says the bundle identifier `in.taxcy.taxcyDriver` isn't available to your team, change it to something unique to you, e.g. `in.taxcy.taxcyDriver.yourname`. Don't commit that change.

## Install and run

From `apps/driver-app`, with the phone connected and unlocked:

```bash
flutter devices                                   # the iPhone should be listed
flutter run -d <iphone-id> --release --dart-define=API_URL=https://taxcy-api.onrender.com
```

`--release` installs an app that keeps working after you unplug the phone; leave it out for a debug build with hot reload while plugged in. Like Android release builds, the API must be `https://`.

The first time, iOS blocks the app from an unknown developer: **Settings → General → VPN & Device Management → (your Apple ID) → Trust**, then open **Fleet Sarthi** again.

**From Xcode instead:** run `flutter build ios --release --dart-define=API_URL=https://taxcy-api.onrender.com` once (it writes the API address into the Xcode build settings), then in Xcode pick the iPhone at the top and press **Run** (⌘R).

## What iOS asks the user

The app's permission texts are in `ios/Runner/Info.plist`:

| Permission                          | When it's asked                                               |
| ----------------------------------- | ------------------------------------------------------------- |
| Camera                              | Photographing the odometer, fuel receipts and documents       |
| Location (while using, then always) | Recording the route while a trip runs, also in the background |
| Photo library                       | Uploading a document photo from the library                   |

Uploading a document on an iPhone offers **Photo library** or **Files (PDF or image)**: the iPhone's Files app doesn't show the Photos library, unlike Android's file chooser. Photos are converted to JPEG on the way in, since iPhone photos are often HEIC.

## Troubleshooting

| Problem                                                                                                                                                | Fix                                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| `xcodebuild requires Xcode, but active developer directory … is a command line tools instance`                                                         | Run the `xcode-select` command from the Mac setup above                                                        |
| Flutter says to pick a Development Team, but the Xcode log shows `Building assets for package:objective_c failed` / `SDK "iphoneos" cannot be located` | `xcode-select` still points at the Command Line Tools: run the `xcode-select` command from the Mac setup above |
| `CocoaPods not installed`                                                                                                                              | `brew install cocoapods`, then run again                                                                       |
| "iOS 18.5 is not installed. To use with Xcode, first download and install the platform" (Flutter only says to pick a Development Team)                 | `xcodebuild -downloadPlatform iOS`, or **Xcode → Settings → Components → iOS**                                 |
| `Value of type 'NWPath' has no member 'isUltraConstrained'`                                                                                            | A plugin needs Xcode 26: keep `connectivity_plus` at 7.0.0, or update Xcode                                    |
| "requires a higher minimum iOS deployment version"                                                                                                     | The app targets iOS 14 (`ios/Podfile`, the Xcode project, `AppFrameworkInfo.plist`); raise all three together  |
| "Untrusted Developer" when opening the app                                                                                                             | Trust your Apple ID under **Settings → General → VPN & Device Management**                                     |
| The app stops opening after a week                                                                                                                     | Free Apple ID installs expire after 7 days: run `flutter run --release …` again                                |
| "No profiles for 'in.taxcy.taxcyDriver' were found"                                                                                                    | Pick your Team under Signing & Capabilities; change the bundle id if it's taken                                |
| The phone isn't listed by `flutter devices`                                                                                                            | Unlock it, tap Trust, and turn on Developer Mode                                                               |

## Beyond your own phone

Installing on other people's iPhones, TestFlight and the App Store need a paid **Apple Developer Program** membership ($99/year), an App Store Connect app record, and an archive built in Xcode (**Product → Archive**). That isn't set up yet.
