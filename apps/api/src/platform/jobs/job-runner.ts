import { Inject, Injectable, type BeforeApplicationShutdown } from '@nestjs/common';
import { Queue, Worker, type ConnectionOptions } from 'bullmq';
import { Logger } from 'nestjs-pino';
import { APP_CONFIG, type AppConfig } from '../config.js';
import { JobDispatcher } from './job-dispatcher.js';
import { queueFor, SCHEDULES, type JobEvent } from './on-job.js';
import { OutboxRelay } from './outbox-relay.js';

const RELAY_INTERVAL_MS = 1_000;

/** BullMQ connection options for a redis:// or rediss:// (TLS) URL. */
export function redisConnection(url: string): ConnectionOptions {
  const parsed = new URL(url);
  const db = Number(parsed.pathname.slice(1) || 0);
  return {
    host: parsed.hostname,
    port: Number(parsed.port || 6379),
    ...(parsed.username ? { username: decodeURIComponent(parsed.username) } : {}),
    ...(parsed.password ? { password: decodeURIComponent(parsed.password) } : {}),
    ...(db ? { db } : {}),
    ...(parsed.protocol === 'rediss:' ? { tls: {} } : {}),
    // BullMQ workers block on Redis; they must retry forever rather than give up.
    maxRetriesPerRequest: null,
  };
}

/**
 * Runs background jobs: relays committed outbox rows to BullMQ, a worker per queue,
 * and the recurring schedules. Started by the workers app, or by the API itself with
 * JOBS_MODE=in-process. Call start() after the app is initialised (handlers are
 * discovered on bootstrap); it stops before the app's connections close.
 */
@Injectable()
export class JobRunner implements BeforeApplicationShutdown {
  private queues = new Map<string, Queue>();
  private workers: Worker[] = [];
  private relayTimer: NodeJS.Timeout | undefined;

  constructor(
    @Inject(APP_CONFIG) private readonly config: AppConfig,
    private readonly dispatcher: JobDispatcher,
    private readonly relay: OutboxRelay,
    private readonly logger: Logger,
  ) {}

  /** Starts everything; returns the queues (for a dashboard). */
  async start(): Promise<Queue[]> {
    if (this.relayTimer) throw new Error('JobRunner already started');
    const connection = redisConnection(this.config.REDIS_URL);

    // One queue per topic prefix (media, fuel, trips, …).
    const queueNames = new Set(
      [...this.dispatcher.topics(), ...SCHEDULES.map((s) => s.topic)].map(queueFor),
    );
    this.queues = new Map([...queueNames].map((name) => [name, new Queue(name, { connection })]));
    this.workers = [...queueNames].map((name) => {
      const worker = new Worker(
        name,
        async (job) => {
          await this.dispatcher.dispatch(job.data as JobEvent);
        },
        { connection, concurrency: 5 },
      );
      worker.on('failed', (job, error) => {
        this.logger.error(
          { queue: name, job: job?.name, attempts: job?.attemptsMade, err: error },
          'job failed',
        );
      });
      return worker;
    });

    for (const schedule of SCHEDULES) {
      await this.queues.get(queueFor(schedule.topic))?.upsertJobScheduler(
        schedule.topic,
        { pattern: schedule.pattern, tz: 'UTC' },
        {
          name: schedule.topic,
          data: { topic: schedule.topic, orgId: null, payload: {} } satisfies JobEvent,
        },
      );
    }

    // Outbox → BullMQ. jobId = outbox id, so a relay that crashes after enqueueing but
    // before marking the row dispatched can't create a duplicate job.
    let relaying = false;
    this.relayTimer = setInterval(() => {
      if (relaying) return;
      relaying = true;
      this.relay
        .drainOnce((event, id) => this.enqueue(event, id))
        .catch((error: unknown) => {
          this.logger.error({ err: error }, 'outbox relay failed');
        })
        .finally(() => {
          relaying = false;
        });
    }, RELAY_INTERVAL_MS);

    this.logger.log(
      `jobs: started (${this.config.JOBS_MODE}); queues [${[...queueNames].join(', ')}]; handlers [${this.dispatcher.topics().join(', ')}]`,
    );
    return [...this.queues.values()];
  }

  async beforeApplicationShutdown(): Promise<void> {
    if (!this.relayTimer) return;
    clearInterval(this.relayTimer);
    this.relayTimer = undefined;
    await Promise.all(this.workers.map((w) => w.close()));
    await Promise.all([...this.queues.values()].map((q) => q.close()));
  }

  private async enqueue(event: JobEvent, id: string): Promise<void> {
    const queue = this.queues.get(queueFor(event.topic));
    if (!queue) {
      this.logger.warn({ topic: event.topic }, 'no queue for outbox topic; dropping');
      return;
    }
    await queue.add(event.topic, event, {
      jobId: `outbox-${id}`,
      attempts: 5,
      backoff: { type: 'exponential', delay: 2_000 },
      removeOnComplete: 1_000,
      removeOnFail: 5_000,
    });
  }
}
