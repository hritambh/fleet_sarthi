import { Module } from '@nestjs/common';
import { SettingsModule } from '../fleet/settings.module.js';
import { MediaModule } from '../media/media.module.js';
import { TripsController } from './trips.controller.js';
import { TripsRepository } from './trips.repository.js';
import { TripsService } from './trips.service.js';
import { UnassignedTripAlerts } from './unassigned-trip-alerts.js';

@Module({
  imports: [MediaModule, SettingsModule],
  controllers: [TripsController],
  providers: [TripsRepository, TripsService, UnassignedTripAlerts],
  exports: [TripsRepository, TripsService],
})
export class TripsModule {}
