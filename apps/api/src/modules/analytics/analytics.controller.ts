import { Controller } from '@nestjs/common';
import { analyticsRoutes as r, type RouteInput, type RouteOutput } from '@taxcy/contracts';
import type { TenantAuth } from '../../platform/auth/auth-context.js';
import { Input, Route, Tenant } from '../../platform/http/route.js';
import { AnalyticsService } from './analytics.service.js';

@Controller()
export class AnalyticsController {
  constructor(private readonly analytics: AnalyticsService) {}

  @Route(r.monthly)
  monthly(
    @Tenant() a: TenantAuth,
    @Input() { query }: RouteInput<typeof r.monthly>,
  ): Promise<RouteOutput<typeof r.monthly>> {
    return this.analytics.monthly(a, query);
  }
}
