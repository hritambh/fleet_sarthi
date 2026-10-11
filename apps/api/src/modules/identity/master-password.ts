import { Inject, Injectable, Logger, type OnModuleInit } from '@nestjs/common';
import { createHash, timingSafeEqual } from 'node:crypto';
import { APP_CONFIG, type AppConfig } from '../../platform/config.js';

const digest = (text: string): Buffer => createHash('sha256').update(text).digest();

/**
 * MASTER_PASSWORD, for testing: it signs in as any existing user and stands in for
 * anyone's current password when changing it (to reset a password without a code).
 * Off unless set; production allows it only with DEMO_MODE (see config.ts). Every use
 * is logged as a warning with the account's number.
 */
@Injectable()
export class MasterPassword implements OnModuleInit {
  private readonly logger = new Logger('MasterPassword');
  // Compared as SHA-256 digests: equal length, so timingSafeEqual never throws.
  private readonly expected: Buffer | null;

  constructor(@Inject(APP_CONFIG) config: AppConfig) {
    this.expected = config.MASTER_PASSWORD ? digest(config.MASTER_PASSWORD) : null;
  }

  onModuleInit(): void {
    if (this.expected) {
      this.logger.warn(
        'MASTER_PASSWORD is set: it signs in as any user and resets any password. Testing only; leave it empty for real users.',
      );
    }
  }

  /** Whether [password] is the master password (always false when it's off). */
  matches(password: string): boolean {
    return this.expected !== null && timingSafeEqual(this.expected, digest(password));
  }

  /** Logs a use; [action] is what it was used for. */
  used(action: 'login' | 'change-password', phone: string): void {
    this.logger.warn(`auth.master_password_used action=${action} phone=${phone}`);
  }
}
