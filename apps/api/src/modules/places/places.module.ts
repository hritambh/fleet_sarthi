import { Module } from '@nestjs/common';
import { RateLimiter } from '../../platform/rate-limit.js';
import { PlacesController } from './places.controller.js';
import { PlacesService } from './places.service.js';

@Module({
  controllers: [PlacesController],
  providers: [PlacesService, RateLimiter],
})
export class PlacesModule {}
