# Phone OTP (phone.email)

Fleet Sarthi can verify mobile numbers with a one-time password (OTP) sent by [phone.email](https://www.phone.email). It's switched off unless you turn it on, and the server's environment controls it entirely. When on, it adds:

- **Log in with OTP:** an alternative to the password; no password needed.
- **Verified sign-up:** the number is proved by OTP before the account is created; optionally required for everyone.
- **Forgot password by OTP:** instead of the reset code from the API log.

Passwords stay the main way in, and the password-reset code (`SMS_PROVIDER=console`, see [deployment](deployment.md#part-4-sign-in-on-a-free-deployment)) keeps working wherever OTP isn't available.

## How it works

phone.email runs the whole OTP step (number entry, SMS, code check) on its own sign-in page. The app opens that page, and when the user has entered the right code, the page hands the app an **access token**. The app (Android, iOS or web) sends the token to our API, and **the API asks phone.email which number the token belongs to.** The app never tells the API which number was verified, so a modified app can't claim someone else's number.

```mermaid
sequenceDiagram
  participant U as User
  participant A as App (Android/iOS/web)
  participant P as phone.email
  participant API as Fleet Sarthi API
  A->>API: GET /v1/auth/methods
  API-->>A: {phoneOtp: {provider: phone_email, clientId}, signupRequiresVerifiedPhone}
  A->>P: WebView (apps) or popup (web): phone.email sign-in page
  U->>P: number + OTP
  P-->>A: access token (JS handler in apps; redirect to phone-otp.html on the web)
  A->>API: POST /v1/auth/phone-otp/login {verificationToken: access_token}
  API->>P: POST eapi.phone.email/getuser (access_token, client_id)
  P-->>API: {country_code, phone_no, ...}
  API->>API: +91 number? token unused? account exists?
  API-->>A: session (access + refresh tokens)
```

Sign-up and forgot password work the same way, with the token in their request instead.

## Setup

1. **Create a phone.email account** at <https://admin.phone.email> and add your app. Check their pricing (on [phone.email](https://www.phone.email)) for the number of verifications you need.
2. **Copy the client id:** Admin Dashboard → **Profile Details**. It's public: the app receives it from `GET /auth/methods` and puts it in the sign-in page's address. There's no secret to store.
3. **Configure the API** (`.env` locally, the `taxcy-api` service's Environment on Render):

   ```bash
   PHONE_OTP_PROVIDER=phone_email
   PHONE_EMAIL_CLIENT_ID=<client id from step 2>
   SIGNUP_REQUIRES_VERIFIED_PHONE=false   # true: every sign-up must verify its number
   ```

4. Restart the API. `GET /v1/auth/methods` should now show `phoneOtp`. The app asks for this on its sign-in screen, so **no app rebuild is needed** to switch OTP on or off. The APK built from this version includes the OTP screen.

## Configuration

| Variable                         | Default                            | Effect                                                                                                                                                                                |
| -------------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `PHONE_OTP_PROVIDER`             | `none`                             | `none`: OTP off (the app shows no OTP options). `phone_email`: phone.email. `stub`: a stand-in for development and tests, [below](#testing-without-phoneemail); refused in production |
| `PHONE_EMAIL_CLIENT_ID`          | empty                              | phone.email client id; required with `phone_email` (the API won't start without it)                                                                                                   |
| `SIGNUP_REQUIRES_VERIFIED_PHONE` | `false`                            | `true`: `POST /auth/signup` without a verification token fails with `PHONE_VERIFICATION_REQUIRED`. Needs a provider                                                                   |
| `PHONE_EMAIL_USER_URL`           | `https://eapi.phone.email/getuser` | Where the API checks tokens. Only change it for tests                                                                                                                                 |

The API validates these at startup, like the rest of its configuration (`apps/api/src/platform/config.ts`).

## What users see

The sign-in card adapts to `GET /auth/methods`:

| Screen          | OTP off (default)                             | OTP on                                                                                                              |
| --------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Log in          | Number + password                             | Also **Log in with OTP**. A number with no account gets "No account with this number yet" and a **Sign up** button  |
| Sign up         | Number, name, password → **Create account**   | **Verify number & create account**: the OTP screen opens first; the account is created only for the verified number |
| Forgot password | Number → code from the API log → new password | **Verify with OTP** → new password → signed in                                                                      |

- OTP sign-in **doesn't create accounts**: a new number signs up (with its name and password) first.
- An **invited driver or manager** who hasn't signed up can log in with OTP straight away (their invitation activates), or sign up to set a password.
- Signing up an invited number with verification also fixes the [demo-mode caveat](deployment.md#password-reset-codes-demo-mode) that whoever signs up first claims the number.

### Platforms

- **Android and iOS apps:** phone.email's sign-in page opens in a native WebView (`PhoneEmailScreen`), which hands the token back through a JavaScript handler.
- **Web app:** phone.email's website sign-in opens in a popup (`phone_email_popup_web.dart`), as in phone.email's website snippet: `https://www.phone.email/auth/log-in?client_id=…&redirect_url=<web app>/phone-otp.html`. After the OTP, phone.email sends the popup to `phone-otp.html?access_token=…` (`apps/driver-app/web/phone-otp.html`), which posts the token to the app window (same origin only) and closes. If the browser blocks the popup, the app says to allow pop-ups for the site.

Both end with the same access token, which the API checks with phone.email in the same way. If phone.email asks you to register the sites that use your client id, add the web app's address (e.g. `https://taxcy-web.onrender.com`, and `http://localhost:5174` for local development).

## API

| Endpoint                                | Body                                                               | Result                                                                                              |
| --------------------------------------- | ------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| `GET /v1/auth/methods`                  | —                                                                  | `{phoneOtp: {provider, clientId} \| null, signupRequiresVerifiedPhone}`                             |
| `POST /v1/auth/phone-otp/login`         | `{verificationToken, deviceId, platform}`                          | A session for the verified number; `NOT_FOUND` if it has no account                                 |
| `POST /v1/auth/signup`                  | `{phone, password, name?, verificationToken?, deviceId, platform}` | As before; with a token, the verified number must equal `phone` (`PHONE_MISMATCH` otherwise)        |
| `POST /v1/auth/password/reset-verified` | `{verificationToken, password, deviceId, platform}`                | Sets the password of the verified number's account, signs out its other sessions, returns a session |

| Error                         | Status | When                                                                                                     |
| ----------------------------- | ------ | -------------------------------------------------------------------------------------------------------- |
| `PHONE_OTP_DISABLED`          | 403    | `PHONE_OTP_PROVIDER=none`                                                                                |
| `PHONE_NOT_VERIFIED`          | 401    | phone.email rejected the token, couldn't be reached, the number isn't +91, or the token was already used |
| `PHONE_MISMATCH`              | 422    | Sign-up: the verified number (`details.verifiedPhone`) isn't the `phone` sent                            |
| `PHONE_VERIFICATION_REQUIRED` | 422    | Sign-up without a token while `SIGNUP_REQUIRES_VERIFIED_PHONE=true`                                      |

OTP log-in is rate-limited to 100 per IP per hour; sign-up keeps its own limit.

## Security

- **The API verifies every token itself** with phone.email (`apps/api/src/modules/identity/phone-verification.ts`). phone.email answers failures with HTTP 200 and `{"status":0}`; the API accepts a token only when phone.email returns a number and no failure status.
- **Each token works once:** the API keeps a SHA-256 hash of every used token in Redis for 24 hours and rejects repeats, so a token copied from a device or a log can't be replayed.
- **Only Indian mobile numbers** (`+91`, as everywhere in the app) are accepted.
- **Tokens aren't logged** by the app or the API. (phone.email's own Flutter package prints them to the device log, which is one reason the app opens phone.email's page itself, in `apps/driver-app/lib/features/login/phone_verification.dart`, instead of using that package.)
- The client id is public by design; there's no shared secret with phone.email in this flow.
- OTP is an extra way in, not a replacement: `MASTER_PASSWORD` and the reset code are separate and unaffected.

## Testing without phone.email

`PHONE_OTP_PROVIDER=stub` (refused when `NODE_ENV=production`) accepts tokens of the form `stub:+91XXXXXXXXXX` and treats that number as verified, without sending anything. Use it for local development and automated tests:

- **API:** `apps/api/test/phone-otp.int.test.ts` runs the flows against the stub, and the phone.email path against a local stand-in for `getuser` (checking the token and client id are sent).
- **App:** with the stub, the OTP buttons open a small "Test mode" dialog where you type the number to treat as verified, on any platform including the web. Widget tests replace the verifier with `FakePhoneVerifier` (`test/support/auth_fakes.dart`); see `test/phone_otp_test.dart`.

Locally, add `PHONE_OTP_PROVIDER=stub` to `.env`, restart `bun run dev`, and run the app (`bun run dev:driver-web` or a debug APK).

## Troubleshooting

| Symptom                                                    | Cause and fix                                                                                                                                                                                            |
| ---------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| No OTP buttons in the app                                  | `GET /v1/auth/methods` shows `phoneOtp: null` (check `PHONE_OTP_PROVIDER` and restart the API), or you're on the web app, which doesn't offer phone.email                                                |
| API won't start: `PHONE_EMAIL_CLIENT_ID: required…`        | Set the client id, or use `PHONE_OTP_PROVIDER=none`                                                                                                                                                      |
| API won't start: `PHONE_OTP_PROVIDER: stub…`               | The stub is refused in production; use `phone_email` or `none`                                                                                                                                           |
| "Couldn't verify your number" after entering the right OTP | The API couldn't confirm the token: check its log for `phone.email getuser` warnings, that `PHONE_EMAIL_CLIENT_ID` is the same client the app's page used, and that the API can reach `eapi.phone.email` |
| The OTP screen shows a network error                       | The phone can't reach `auth.phone.email`; check its connection                                                                                                                                           |
| Sign-up says the verified number isn't the one entered     | The user verified a different number on phone.email's page than the one typed in the form; type the number they verified                                                                                 |

## Limitations

- phone.email's documentation doesn't describe its `getuser` response beyond the fields its SDK reads (`status`, `country_code`, `phone_no`, `first_name`, `last_name`), so the success check is deliberately tolerant (see [Security](#security)). Before relying on OTP with real users, verify one real sign-in end to end.
- The sign-in page's address and its `sendTokenToApp` callback come from phone.email's Flutter package (version 0.0.6). If phone.email changes them, update `PhoneEmailScreen` in `phone_verification.dart`.
