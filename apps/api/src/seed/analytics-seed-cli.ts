import { createWorkerContext } from '../worker.js';
import { runAnalyticsSeed } from './analytics-seed.js';

const phone = process.argv[2];
if (!phone) {
  process.stderr.write(
    'Usage: bun run db:seed:analytics +91XXXXXXXXXX\n' +
      'Pass the phone number you signed up with; its org gets the demo fleet and history.\n',
  );
  process.exit(1);
}

const ctx = await createWorkerContext();
try {
  await runAnalyticsSeed(ctx, phone);
} finally {
  await ctx.close();
}
