import { Inject, Injectable, Logger, type OnModuleInit } from '@nestjs/common';
import { APP_CONFIG, type AppConfig } from '../../platform/config.js';

export interface SmsProvider {
  sendOtp(phone: string, code: string): Promise<void>;
}

export const SMS_PROVIDER = Symbol('SMS_PROVIDER');

/**
 * Development/test provider: logs the code instead of sending an SMS. It also keeps
 * the last code per phone in memory so integration tests can log in. In production
 * config only allows it with DEMO_MODE=true.
 */
@Injectable()
export class ConsoleSmsProvider implements SmsProvider, OnModuleInit {
  private readonly logger = new Logger('ConsoleSmsProvider');
  private readonly lastCodes = new Map<string, string>();

  constructor(@Inject(APP_CONFIG) private readonly config: AppConfig) {}

  onModuleInit(): void {
    if (this.config.NODE_ENV === 'production') {
      this.logger.warn(
        'DEMO_MODE: SMS is not sent. Login codes are written to this log, so anyone who can read it can sign in as any user. Do not use with real users.',
      );
    }
  }

  sendOtp(phone: string, code: string): Promise<void> {
    this.lastCodes.set(phone, code);
    this.logger.log(`otp.issued phone=${phone} code=${code} (dev only, not sent)`);
    return Promise.resolve();
  }

  lastCodeFor(phone: string): string | undefined {
    return this.lastCodes.get(phone);
  }
}
