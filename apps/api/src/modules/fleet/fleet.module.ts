import { Module } from '@nestjs/common';
import { DocumentExpiryJob } from './document-expiry.job.js';
import { DocumentsService } from './documents.service.js';
import { FleetController } from './fleet.controller.js';
import { FleetRepository } from './fleet.repository.js';
import { FleetService } from './fleet.service.js';
import { SettingsService } from './settings.service.js';
import { VehicleCatalogJob } from './vehicle-catalog.job.js';
import { VehicleCatalogService } from './vehicle-catalog.service.js';

@Module({
  controllers: [FleetController],
  providers: [
    FleetRepository,
    FleetService,
    DocumentsService,
    SettingsService,
    VehicleCatalogService,
    VehicleCatalogJob,
    DocumentExpiryJob,
  ],
  exports: [FleetRepository, FleetService, SettingsService],
})
export class FleetModule {}
