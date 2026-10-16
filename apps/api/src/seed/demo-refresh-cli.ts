// `bun run db:seed:refresh`: rebuilds the demo fleets (Sharma Travels, Patil Cabs)
// as of now, deleting only those two fleets. With --if-stale (used when the API
// starts on a demo deployment), only when they were seeded on an earlier IST day.
import { createWorkerContext } from '../worker.js';
import { refreshDemo, refreshDemoIfStale } from './demo-refresh.js';

const ctx = await createWorkerContext();
try {
  if (process.argv.includes('--if-stale')) {
    const rebuilt = await refreshDemoIfStale(ctx);
    if (!rebuilt) process.stdout.write('Demo already seeded today.\n');
  } else {
    await refreshDemo(ctx);
  }
} finally {
  await ctx.close();
}
