import { Injectable, Logger } from '@nestjs/common';
import { OnJob } from '../../platform/jobs/on-job.js';
import { VehicleCatalogService } from './vehicle-catalog.service.js';

/**
 * Weekly: rebuilds the public vehicle catalogue and replaces the cached copy.
 *
 * The cache keeps it for a week, so refreshing inside that week means the entry
 * never expires while someone is waiting on it — without this, the first owner
 * to open the add-vehicle form after the TTL lapsed would pay for the rebuild.
 * The brand and model lists change about once a year, so weekly is plenty.
 */
@Injectable()
export class VehicleCatalogJob {
  private readonly logger = new Logger('VehicleCatalogJob');

  constructor(private readonly catalog: VehicleCatalogService) {}

  @OnJob('fleet.vehicle_catalog_refresh')
  async run(): Promise<void> {
    const { brands, models } = await this.catalog.refresh();
    const count = Object.values(models).reduce((n, list) => n + list.length, 0);
    this.logger.log(`vehicle catalogue refreshed: ${brands.length} brands, ${count} models`);
  }
}
