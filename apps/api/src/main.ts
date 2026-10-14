import './instrument.js';
import 'reflect-metadata';
import { createApp } from './app.js';
import { APP_CONFIG, type AppConfig } from './platform/config.js';
import { JobRunner } from './platform/jobs/job-runner.js';
import { VehicleCatalogService } from './modules/fleet/vehicle-catalog.service.js';

const app = await createApp();
const config = app.get<AppConfig>(APP_CONFIG);
// Free hosting without a background worker: the API runs the jobs itself.
if (config.JOBS_MODE === 'in-process') await app.get(JobRunner).start();
await app.listen(config.PORT);
// Build the public vehicle catalogue in the background, so the add-vehicle form
// is ready for the first owner to open it after a deploy. Not awaited: the API is
// already serving, and the request path builds it if this fails.
void app.get(VehicleCatalogService).warm();
