import { Controller } from '@nestjs/common';
import { analyticsRoutes as r, type RouteInput, type RouteOutput } from '@taxcy/contracts';
import type { TenantAuth } from '../../platform/auth/auth-context.js';
import { Input, Route, Tenant } from '../../platform/http/route.js';
import { AnalyticsService } from './analytics.service.js';

@Controller()
export class AnalyticsController {
  constructor(private readonly analytics: AnalyticsService) {}

  @Route(r.daily)
  daily(
    @Tenant() a: TenantAuth,
    @Input() { query }: RouteInput<typeof r.daily>,
  ): Promise<RouteOutput<typeof r.daily>> {
    return this.analytics.daily(a, query.month);
  }

  @Route(r.dashboard)
  dashboard(
    @Tenant() a: TenantAuth,
    @Input() { query }: RouteInput<typeof r.dashboard>,
  ): Promise<RouteOutput<typeof r.dashboard>> {
    return this.analytics.dashboard(a, query.date);
  }
}
