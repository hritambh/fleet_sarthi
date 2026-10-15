import { Module } from '@nestjs/common';
import { TripsModule } from '../trips/trips.module.js';
import { DocumentExpiryJob } from './document-expiry.job.js';
import { DocumentsService } from './documents.service.js';
import { FleetController } from './fleet.controller.js';
import { FleetRepository } from './fleet.repository.js';
import { FleetService } from './fleet.service.js';
import { SettingsModule } from './settings.module.js';
import { VehicleCatalogJob } from './vehicle-catalog.job.js';
import { VehicleCatalogService } from './vehicle-catalog.service.js';

@Module({
  imports: [TripsModule, SettingsModule],
  controllers: [FleetController],
  providers: [
    FleetRepository,
    FleetService,
    DocumentsService,
    VehicleCatalogService,
    VehicleCatalogJob,
    DocumentExpiryJob,
  ],
  exports: [FleetRepository, FleetService, SettingsModule],
})
export class FleetModule {}
