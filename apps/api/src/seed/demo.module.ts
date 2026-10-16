import { Module } from '@nestjs/common';
import { DemoRefreshJob } from './demo-refresh.job.js';

/** The daily demo refresh (DEMO_REFRESH_DAILY); see demo-refresh.ts. */
@Module({ providers: [DemoRefreshJob] })
export class DemoModule {}
