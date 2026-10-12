import { Inject, Injectable, Logger } from '@nestjs/common';
import { PhoneE164 } from '@taxcy/contracts';
import { createHash } from 'node:crypto';
import { APP_CONFIG, type AppConfig } from '../../platform/config.js';
import { AppError } from '../../platform/errors.js';
import { RedisService } from '../../platform/redis.service.js';

/** How long a used verification token is remembered, so it can't be replayed. */
const USED_TOKEN_TTL_SECONDS = 24 * 3_600;
const PHONE_EMAIL_TIMEOUT_MS = 10_000;

/**
 * Turns a phone verification token from the OTP provider (PHONE_OTP_PROVIDER) into
 * the verified number, server side, so a client can't just claim a number.
 *
 * - `phone_email`: the token is the access token phone.email's sign-in screen gives
 *   the app after the OTP; the API posts it with our client id to phone.email's
 *   user lookup, which answers with the verified number.
 * - `stub`: `stub:+919876543210` verifies that number. Development and tests only
 *   (config refuses it in production).
 *
 * Every token is accepted once: its hash is kept in Redis for a day.
 */
@Injectable()
export class PhoneVerification {
  private readonly logger = new Logger('PhoneVerification');

  constructor(
    @Inject(APP_CONFIG) private readonly config: AppConfig,
    private readonly redis: RedisService,
  ) {}

  get enabled(): boolean {
    return this.config.PHONE_OTP_PROVIDER !== 'none';
  }

  /** The verified number for [token], consuming the token. */
  async verify(token: string): Promise<string> {
    if (!this.enabled) {
      throw new AppError('PHONE_OTP_DISABLED', 'Phone OTP is switched off on this server');
    }
    const phone =
      this.config.PHONE_OTP_PROVIDER === 'stub'
        ? this.fromStub(token)
        : await this.fromPhoneEmail(token);
    const fresh = await this.redis.client.set(
      `phone-otp:used:${createHash('sha256').update(token).digest('hex')}`,
      '1',
      'EX',
      USED_TOKEN_TTL_SECONDS,
      'NX',
    );
    if (fresh !== 'OK') {
      throw new AppError('PHONE_NOT_VERIFIED', 'This verification was already used; verify again');
    }
    return phone;
  }

  private fromStub(token: string): string {
    const phone = token.startsWith('stub:') ? token.slice('stub:'.length) : '';
    return this.indianMobile(phone);
  }

  private async fromPhoneEmail(token: string): Promise<string> {
    let body: unknown;
    try {
      const res = await fetch(this.config.PHONE_EMAIL_USER_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          access_token: token,
          client_id: this.config.PHONE_EMAIL_CLIENT_ID ?? '',
        }),
        signal: AbortSignal.timeout(PHONE_EMAIL_TIMEOUT_MS),
      });
      body = res.ok ? await res.json() : null;
      if (!res.ok) this.logger.warn(`phone.email getuser returned HTTP ${res.status}`);
    } catch (error) {
      this.logger.warn(`phone.email getuser failed: ${String(error)}`);
      throw new AppError('PHONE_NOT_VERIFIED', "Couldn't reach the phone verification service");
    }
    // Failure is HTTP 200 with {"status":0}. Success carries the number; its
    // status value isn't documented (the SDK models it as an int), so only the
    // failure values are rejected.
    const user = (body ?? {}) as { status?: unknown; country_code?: unknown; phone_no?: unknown };
    const failed = user.status === 0 || user.status === '0' || user.status === false;
    if (failed || !user.phone_no) {
      throw new AppError('PHONE_NOT_VERIFIED', 'Phone verification failed or expired; try again');
    }
    const digits = (v: unknown) =>
      typeof v === 'string' || typeof v === 'number' ? String(v).replace(/\D/g, '') : '';
    return this.indianMobile(`+${digits(user.country_code)}${digits(user.phone_no)}`);
  }

  private indianMobile(phone: string): string {
    const parsed = PhoneE164.safeParse(phone);
    if (!parsed.success) {
      throw new AppError('PHONE_NOT_VERIFIED', 'Verify an Indian mobile number (+91)');
    }
    return parsed.data;
  }
}
