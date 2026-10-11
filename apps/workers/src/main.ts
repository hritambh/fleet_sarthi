import { createBullBoard } from '@bull-board/api';
import { BullMQAdapter } from '@bull-board/api/bullMQAdapter';
import { ExpressAdapter } from '@bull-board/express';
import { APP_CONFIG, createWorkerContext, JobRunner, type AppConfig } from '@taxcy/api/worker';
import express, { type RequestHandler } from 'express';
import { Logger } from 'nestjs-pino';

const DASHBOARD_PORT = Number(process.env['WORKERS_DASHBOARD_PORT'] ?? 3001);

const context = await createWorkerContext();
const logger = context.get(Logger);

if (context.get<AppConfig>(APP_CONFIG).JOBS_MODE === 'in-process') {
  logger.error('workers: JOBS_MODE=in-process means the API runs the jobs; not starting');
  await context.close();
  process.exit(1);
}

// The outbox relay, a worker per queue and the schedules (stopped by the context's
// shutdown hooks on SIGINT/SIGTERM).
const queues = await context.get(JobRunner).start();

const board = new ExpressAdapter();
board.setBasePath('/queues');
createBullBoard({
  queues: queues.map((q) => new BullMQAdapter(q)),
  serverAdapter: board,
});
const dashboard = express()
  .use('/queues', board.getRouter() as RequestHandler)
  .listen(DASHBOARD_PORT);

logger.log(`workers: dashboard http://localhost:${DASHBOARD_PORT}/queues`);

for (const signal of ['SIGINT', 'SIGTERM'] as const) {
  process.once(signal, () => {
    logger.log(`workers: ${signal}, shutting down`);
    dashboard.close();
  });
}
