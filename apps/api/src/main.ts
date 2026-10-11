import './instrument.js';
import 'reflect-metadata';
import { createApp } from './app.js';
import { APP_CONFIG, type AppConfig } from './platform/config.js';
import { JobRunner } from './platform/jobs/job-runner.js';

const app = await createApp();
const config = app.get<AppConfig>(APP_CONFIG);
// Free hosting without a background worker: the API runs the jobs itself.
if (config.JOBS_MODE === 'in-process') await app.get(JobRunner).start();
await app.listen(config.PORT);
