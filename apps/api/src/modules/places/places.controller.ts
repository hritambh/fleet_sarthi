import { Controller } from '@nestjs/common';
import { placeRoutes as r, type RouteInput, type RouteOutput } from '@taxcy/contracts';
import type { TenantAuth } from '../../platform/auth/auth-context.js';
import { Input, Route, Tenant } from '../../platform/http/route.js';
import { PlacesService } from './places.service.js';

@Controller()
export class PlacesController {
  constructor(private readonly places: PlacesService) {}

  @Route(r.searchPlaces)
  searchPlaces(
    @Tenant() a: TenantAuth,
    @Input() { query }: RouteInput<typeof r.searchPlaces>,
  ): Promise<RouteOutput<typeof r.searchPlaces>> {
    return this.places.search(a.userId, query.q);
  }
}
