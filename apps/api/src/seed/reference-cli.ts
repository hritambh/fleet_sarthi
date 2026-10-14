// Loads the reference data (the cab models and their fuel baselines) and nothing
// else — no demo fleet. Run on every API start by infra/render/start-api.sh, and
// locally with `bun run db:reference`. Idempotent.
import { Db } from '../platform/prisma.service.js';
import { createWorkerContext } from '../worker.js';
import { loadReferenceData } from './reference-data.js';

const ctx = await createWorkerContext();
try {
  const added = await loadReferenceData(ctx.get(Db));
  process.stdout.write(
    added === 0
      ? 'reference data: cab models already up to date\n'
      : `reference data: ${added} cab models added\n`,
  );
} finally {
  await ctx.close();
}
