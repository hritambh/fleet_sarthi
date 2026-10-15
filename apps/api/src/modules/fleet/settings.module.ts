import { Module } from '@nestjs/common';
import { SettingsService } from './settings.service.js';

/**
 * The org's settings on their own, so modules that FleetModule itself depends
 * on (trips) can read them without an import cycle.
 */
@Module({
  providers: [SettingsService],
  exports: [SettingsService],
})
export class SettingsModule {}
