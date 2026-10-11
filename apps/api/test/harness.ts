import { JobDispatcher } from '../src/platform/jobs/job-dispatcher.js';
import type { JobEvent } from '../src/platform/jobs/on-job.js';
import { OutboxRelay } from '../src/platform/jobs/outbox-relay.js';
import type { Session } from '@taxcy/contracts';
import request from 'supertest';
import { randomInt, randomUUID } from 'node:crypto';
import { SMS_PROVIDER, type ConsoleSmsProvider } from '../src/modules/identity/sms.provider.js';
import type { INestApplication } from '@nestjs/common';
import { createPrismaClient, type PrismaClient } from '@taxcy/db';
import type { Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { createApp } from '../src/app.js';

export interface Harness {
  app: INestApplication;
  /** Base URL of the running app, for supertest. */
  http: string;
  /** Owner connection: bypasses RLS. For arranging fixtures and asserting raw state only. */
  owner: PrismaClient;
  close(): Promise<void>;
}

export async function startHarness(): Promise<Harness> {
  const app = await createApp({ logs: false });
  // Listen once on a real port. Handing supertest an unstarted server makes it start
  // and stop the server per request, which races when requests overlap.
  await app.listen(0, '127.0.0.1');
  const address = (app.getHttpServer() as Server).address() as AddressInfo;
  const owner = createPrismaClient(requireEnv('DATABASE_MIGRATION_URL'));
  return {
    app,
    http: `http://127.0.0.1:${address.port}`,
    owner,
    async close() {
      await owner.$disconnect();
      await app.close();
    },
  };
}

export function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is not set; is the integration global setup running?`);
  return value;
}

/** A random valid Indian mobile number, so per-phone rate limits never collide across tests. */
export function randomPhone(): string {
  return `+919${randomInt(0, 1_000_000_000).toString().padStart(9, '0')}`;
}

export function lastOtp(h: Harness, phone: string): string {
  const code = h.app.get<ConsoleSmsProvider>(SMS_PROVIDER).lastCodeFor(phone);
  if (!code) throw new Error(`No OTP was sent to ${phone}`);
  return code;
}

/** The password every test user gets. */
export const TEST_PASSWORD = 'test-password-1';

/**
 * Signs in with phone + password: signs the number up the first time (which also
 * activates any pending invite), and logs in after that.
 */
export async function login(h: Harness, phone = randomPhone()): Promise<Session> {
  const device = { deviceId: randomUUID(), platform: 'web' };
  const signup = await request(h.http)
    .post('/v1/auth/signup')
    .send({ phone, password: TEST_PASSWORD, ...device });
  if (signup.status === 201) return signup.body as Session;
  const res = await request(h.http)
    .post('/v1/auth/password/login')
    .send({ phone, password: TEST_PASSWORD, ...device })
    .expect(200);
  return res.body as Session;
}

/** Signs up a new user and creates an org they own; returns a session scoped to it. */
export async function ownerSession(
  h: Harness,
  kind: 'fleet' | 'dco' = 'fleet',
  name = 'Test Travels',
): Promise<Session> {
  const session = await login(h);
  const res = await request(h.http)
    .post('/v1/orgs')
    .set('Authorization', `Bearer ${session.accessToken}`)
    .send({ name, kind, refreshToken: session.refreshToken })
    .expect(201);
  return res.body as Session;
}

export const bearer = (session: Session): [string, string] => [
  'Authorization',
  `Bearer ${session.accessToken}`,
];

/**
 * Drains the outbox and runs each job's handler in-process, repeating until no new
 * events appear (handlers may publish follow-up events). Mirrors what the workers
 * app does through BullMQ, minus the queue, so tests are deterministic.
 */
export async function runJobs(h: Harness): Promise<number> {
  const relay = h.app.get(OutboxRelay);
  const dispatcher = h.app.get(JobDispatcher);
  let total = 0;
  for (let round = 0; round < 20; round++) {
    const events: JobEvent[] = [];
    await relay.drainOnce((event) => {
      events.push(event);
      return Promise.resolve();
    });
    if (!events.length) return total;
    for (const event of events) await dispatcher.dispatch(event);
    total += events.length;
  }
  throw new Error('runJobs: jobs keep producing events after 20 rounds');
}

async function ids(h: Harness, session: Session, path: string): Promise<string[]> {
  const res = await request(h.http)
    .get(path)
    .set(...bearer(session))
    .expect(200);
  return (res.body as { id: string }[]).map((row) => row.id);
}

/**
 * Owner invites a driver; the driver signs in through OTP and gets a session for the org.
 * Unless `linkAll` is false, the driver is linked to every vehicle in the org (and
 * createVehicle links every driver), so tests can pair anyone with anything.
 */
export async function driverSession(
  h: Harness,
  owner: Session,
  name = 'Ramesh Kumar',
  { linkAll = true }: { linkAll?: boolean } = {},
): Promise<{ session: Session; driverId: string }> {
  const phone = randomPhone();
  const vehicleIds = linkAll ? await ids(h, owner, '/v1/vehicles') : [];
  const invite = await request(h.http)
    .post('/v1/drivers')
    .set(...bearer(owner))
    .send({ name, phone, vehicleIds })
    .expect(201);
  const session = await login(h, phone);
  return { session, driverId: (invite.body as { id: string }).id };
}

/**
 * Test isolation for files that share one driver: a driver can have only one trip on
 * the road, so trips a test left running are marked ended (straight in the database,
 * skipping the end command and its jobs) before the next test.
 */
export async function parkRunningTrips(h: Harness): Promise<void> {
  await h.owner.trip.updateMany({
    where: { status: 'started' },
    data: { status: 'ended', endedAt: new Date() },
  });
}

/** Runs a scheduled job's handler directly. */
export async function runSchedule(h: Harness, topic: string): Promise<void> {
  await h.app.get(JobDispatcher).dispatch({ topic, orgId: null, payload: {} });
}

/** Registers a photo (no upload needed for the API to accept it as evidence). */
export async function registerPhoto(
  h: Harness,
  session: Session,
  kind: 'odometer' | 'fuel_receipt' = 'odometer',
): Promise<string> {
  const id = randomUUID();
  await request(h.http)
    .post('/v1/media')
    .set(...bearer(session))
    .send({
      id,
      kind,
      contentType: 'image/jpeg',
      sha256: 'a'.repeat(64),
      byteSize: 1000,
      capturedAt: new Date().toISOString(),
    })
    .expect(201);
  return id;
}

export async function odometer(h: Harness, session: Session, typedKm: number) {
  return {
    id: randomUUID(),
    typedKm,
    mediaId: await registerPhoto(h, session),
    capturedAt: new Date().toISOString(),
  };
}

export async function createVehicle(
  h: Harness,
  owner: Session,
  registrationNo: string,
  fuelType = 'diesel',
  lastOdometerKm = 48_000,
  { linkAll = true }: { linkAll?: boolean } = {},
) {
  const driverIds = linkAll ? await ids(h, owner, '/v1/drivers') : [];
  const res = await request(h.http)
    .post('/v1/vehicles')
    .set(...bearer(owner))
    .send({
      registrationNo,
      make: 'Toyota',
      model: 'Innova Crysta',
      fuelType,
      lastOdometerKm,
      driverIds,
    })
    .expect(201);
  return res.body as { id: string; registrationNo: string };
}

let tripSlot = 0;
/** A non-overlapping schedule window per call, so exclusion constraints never collide by accident. */
export function schedule(hours = 4): { scheduledStartAt: string; scheduledEndAt: string } {
  tripSlot += 1;
  const start = Date.now() + tripSlot * 7 * 86_400_000;
  return {
    scheduledStartAt: new Date(start).toISOString(),
    scheduledEndAt: new Date(start + hours * 3_600_000).toISOString(),
  };
}

export const key = (): [string, string] => ['Idempotency-Key', randomUUID()];
