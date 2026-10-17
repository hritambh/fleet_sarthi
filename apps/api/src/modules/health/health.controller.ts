import { Controller } from '@nestjs/common';
import { healthRoutes, type RouteOutput } from '@taxcy/contracts';
import { Db } from '../../platform/prisma.service.js';
import { RedisService } from '../../platform/redis.service.js';
import { S3Service } from '../../platform/s3.service.js';
import { Route } from '../../platform/http/route.js';

type Outcome = { status: 'ok' } | { status: 'error'; reason: string };

/** A short, secret-free reason: the error's name or code, and the HTTP status if any. */
export function failureReason(error: unknown): string {
  if (!(error instanceof Error)) return 'unknown';
  const { code, $metadata } = error as Error & {
    code?: unknown;
    $metadata?: { httpStatusCode?: number };
  };
  const name = typeof code === 'string' ? code : error.name;
  const status = $metadata?.httpStatusCode;
  return status ? `${name} (${status})` : name;
}

async function check(probe: () => Promise<unknown>): Promise<Outcome> {
  try {
    await probe();
    return { status: 'ok' };
  } catch (error) {
    return { status: 'error', reason: failureReason(error) };
  }
}

@Controller()
export class HealthController {
  constructor(
    private readonly db: Db,
    private readonly redis: RedisService,
    private readonly s3: S3Service,
  ) {}

  @Route(healthRoutes.live)
  live(): RouteOutput<typeof healthRoutes.live> {
    return { status: 'ok' };
  }

  @Route(healthRoutes.ready)
  async ready(): Promise<RouteOutput<typeof healthRoutes.ready>> {
    const [postgres, redis, s3] = await Promise.all([
      check(() => this.db.client.$queryRaw`SELECT 1`),
      check(() => this.redis.client.ping()),
      check(() => this.s3.ping()),
    ]);
    const outcomes = { postgres, redis, s3 };
    const failed = Object.entries(outcomes).flatMap(([name, o]) =>
      o.status === 'error' ? [[name, o.reason] as const] : [],
    );
    return {
      status: failed.length ? 'error' : 'ok',
      checks: { postgres: postgres.status, redis: redis.status, s3: s3.status },
      ...(failed.length ? { reasons: Object.fromEntries(failed) } : {}),
    };
  }
}
