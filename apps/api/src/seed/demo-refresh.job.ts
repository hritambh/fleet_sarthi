import { Inject, Injectable, Logger } from '@nestjs/common';
import { ModuleRef } from '@nestjs/core';
import { APP_CONFIG, type AppConfig } from '../platform/config.js';
import { OnJob } from '../platform/jobs/on-job.js';
import { refreshDemoIfStale } from './demo-refresh.js';
import type { SeedContext } from './seed.js';

/**
 * Daily at 03:30 IST: rebuilds the demo fleets for the new day, so the demo
 * always shows six weeks of history, a trip on the road, one this evening, an
 * unassigned booking for tomorrow, documents about to expire and two open
 * settlement days. Does nothing unless DEMO_REFRESH_DAILY is on.
 */
@Injectable()
export class DemoRefreshJob {
  private readonly logger = new Logger('DemoRefreshJob');

  constructor(
    private readonly moduleRef: ModuleRef,
    @Inject(APP_CONFIG) private readonly config: AppConfig,
  ) {}

  @OnJob('demo.refresh')
  async run(): Promise<void> {
    if (!this.config.DEMO_REFRESH_DAILY) return;
    // The seed reaches services across modules, as a standalone context would.
    const ctx: SeedContext = {
      get: (type) => this.moduleRef.get(type, { strict: false }),
    };
    const rebuilt = await refreshDemoIfStale(ctx);
    this.logger.log(rebuilt ? 'demo fleets rebuilt for today' : 'demo already seeded today');
  }
}
