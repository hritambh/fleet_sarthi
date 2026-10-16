// Fills an existing org with a few months of trips and fuel, so the Analytics page has
// something to draw. Unlike the Sharma Travels demo seed this targets whatever org you
// already signed up with, and it deliberately produces the two shapes that seed cannot:
// trips the customer under-paid (billed above collected) and days a vehicle ran twice
// (trips per vehicle above one). Run with `bun run db:seed:analytics <phone>`.
import { PutObjectCommand } from '@aws-sdk/client-s3';
import type { INestApplicationContext } from '@nestjs/common';
import { istBusinessDate } from '@taxcy/domain';
import { createHash } from 'node:crypto';
import type { TenantAuth } from '../platform/auth/auth-context.js';
import { newId } from '../platform/ids.js';
import { JobDispatcher } from '../platform/jobs/job-dispatcher.js';
import type { JobEvent } from '../platform/jobs/on-job.js';
import { OutboxRelay } from '../platform/jobs/outbox-relay.js';
import { Db } from '../platform/prisma.service.js';
import { S3Service } from '../platform/s3.service.js';
import { FleetService } from '../modules/fleet/fleet.service.js';
import { FuelService } from '../modules/fuel/fuel.service.js';
import { MediaService } from '../modules/media/media.service.js';
import { TripsService } from '../modules/trips/trips.service.js';
import { hashPassword } from '../modules/identity/passwords.js';
// The same password as every other demo person (12345678).
import { DEMO_PASSWORD } from './seed.js';
import { textPng } from './png.js';

/** Long enough to fill the current month and the two before it. */
const HISTORY_DAYS = 75;

/**
 * One of these is a bifuel car: it is filled with both petrol and CNG, which the fuel
 * chart has to split across its litres and kilograms panels.
 */
const PAIRS = [
  {
    driver: { name: 'Mahesh Jadhav', phone: '+919100000011' },
    vehicle: {
      reg: 'MH14PT0001',
      make: 'Toyota',
      model: 'Innova Crysta',
      fuel: 'diesel',
      odo: 72_000,
      kmpl: 11.5,
    },
  },
  {
    driver: { name: 'Sunita Pawar', phone: '+919100000012' },
    vehicle: {
      reg: 'MH14PT0002',
      make: 'Maruti Suzuki',
      model: 'Dzire',
      fuel: 'cng',
      odo: 44_000,
      kmpl: 24,
    },
  },
  {
    driver: { name: 'Farhan Qureshi', phone: '+919100000013' },
    vehicle: {
      reg: 'MH14PT0003',
      make: 'Maruti Suzuki',
      model: 'Ertiga',
      fuel: 'petrol_cng',
      odo: 29_000,
      kmpl: 17,
    },
  },
] as const;

type Pair = (typeof PAIRS)[number];

/** Paise per litre or kilogram. */
const PRICES = { diesel: 9_000, cng: 9_000, petrol: 10_500 } as const;

const ROUTES = [
  ['Pune Station', 'Mumbai Airport T2'],
  ['Hinjewadi Phase 1', 'Lonavala'],
  ['Kothrud', 'Mahabaleshwar'],
  ['Pune Airport', 'Nashik Road'],
  ['Viman Nagar', 'Shirdi'],
  ['Baner', 'Satara'],
] as const;
const CUSTOMERS = ['Rohit Desai', 'Meera Joshi', 'Sanjay Kale', 'Divya Menon', 'Arun Bhosale'];
const PUNE = { lat: 18.5286, lng: 73.8743 };

/** Deterministic, so re-seeding a fresh org gives the same charts. */
let rng = 2026;
const random = () => (rng = (rng * 1_103_515_245 + 12_345) % 2_147_483_648) / 2_147_483_648;
const between = (min: number, max: number) => Math.round(min + random() * (max - min));

const todayIst = istBusinessDate(new Date());

/** A UTC instant for an IST wall-clock time `daysAgo` days before today. */
function ist(daysAgo: number, hour: number, minute = 0): Date {
  const [y, m, d] = todayIst.split('-').map(Number) as [number, number, number];
  return new Date(Date.UTC(y, m - 1, d - daysAgo, hour - 5, minute - 30));
}

interface Truck {
  pair: Pair;
  vehicle: { id: string };
  driver: { id: string };
  auth: TenantAuth;
  odo: number;
  sinceFull: number;
  fillIndex: number;
}

class AnalyticsSeeder {
  private readonly db: Db;
  private readonly s3: S3Service;
  private readonly media: MediaService;
  private readonly fleet: FleetService;
  private readonly trips: TripsService;
  private readonly fuel: FuelService;
  private photos = 0;
  private shortPaid = 0;
  private doubleDays = 0;

  constructor(private readonly ctx: INestApplicationContext) {
    this.db = ctx.get(Db);
    this.s3 = ctx.get(S3Service);
    this.media = ctx.get(MediaService);
    this.fleet = ctx.get(FleetService);
    this.trips = ctx.get(TripsService);
    this.fuel = ctx.get(FuelService);
  }

  async run(phone: string): Promise<void> {
    const owner = await this.findOwner(phone);
    const existing = await this.db.tenant(owner.orgId, (tx) =>
      tx.vehicle.count({ where: { orgId: tx.orgId } }),
    );
    if (existing > 0) {
      log(`That org already has ${String(existing)} vehicle(s); nothing to do.`);
      log('This seed only fills an empty org, so it cannot double-count your history.');
      return;
    }

    const fleet = await this.createFleet(owner.orgId);
    log(`${String(fleet.length)} vehicles and drivers`);

    for (let daysAgo = HISTORY_DAYS; daysAgo >= 1; daysAgo--) {
      for (const [index, truck] of fleet.entries()) {
        const restDay = (daysAgo + index) % 8 === 0;
        if (!restDay) {
          await this.trip(owner, truck, daysAgo, between(90, 240), { second: false });
          // Every so often a car goes out again the same evening, which is the only way
          // trips-per-vehicle rises above one.
          if ((daysAgo + index) % 11 === 0) {
            await this.trip(owner, truck, daysAgo, between(40, 110), { second: true });
            this.doubleDays += 1;
          }
        }
        if (truck.sinceFull >= truck.pair.vehicle.kmpl * 30) await this.fill(truck, daysAgo);
      }
      if (daysAgo % 15 === 0)
        log(`history: ${String(HISTORY_DAYS - daysAgo + 1)}/${String(HISTORY_DAYS)} days`);
    }

    log('running jobs (OCR, fuel audits)…');
    await this.drainJobs();
    await this.setPasswords();

    log('');
    log(`Filled "${owner.orgName}" with ${String(HISTORY_DAYS)} days of history.`);
    log(
      `  ${String(this.photos)} photos, ${String(this.shortPaid)} part-paid trips, ${String(this.doubleDays)} double-trip days`,
    );
    for (const p of PAIRS)
      log(
        `  driver   ${p.driver.name.padEnd(16)} ${p.driver.phone}   (${p.vehicle.model}, ${p.vehicle.fuel})`,
      );
    log(`Drivers sign in with the password ${DEMO_PASSWORD}; your own login is unchanged.`);
  }

  /** The org this person owns. Anything else would be someone else's fleet. */
  private async findOwner(phone: string): Promise<TenantAuth & { orgName: string }> {
    const user = await this.db.system((tx) =>
      tx.user.findUnique({
        where: { phoneE164: phone },
        include: { memberships: { include: { org: true } } },
      }),
    );
    if (!user) throw new Error(`No user with phone ${phone}. Sign up in the app first.`);
    const membership = user.memberships.find((m) => m.roles.includes('owner'));
    if (!membership) throw new Error(`${phone} does not own an organization.`);
    return {
      userId: user.id,
      orgId: membership.orgId,
      roles: ['owner'],
      orgName: membership.org.name,
    };
  }

  private async createFleet(orgId: string): Promise<Truck[]> {
    const fleet: Truck[] = [];
    for (const pair of PAIRS) {
      const vehicle = await this.db.tenant(orgId, async (tx) =>
        this.fleet.createVehicle(tx, {
          registrationNo: pair.vehicle.reg,
          make: pair.vehicle.make,
          model: pair.vehicle.model,
          fuelType: pair.vehicle.fuel,
          year: 2023,
          lastOdometerKm: pair.vehicle.odo,
          vehicleModelId: await tx.vehicleModel
            .findFirst({ where: { orgId: null, model: pair.vehicle.model }, select: { id: true } })
            .then((m) => m?.id),
        }),
      );
      const driver = await this.db.tenant(orgId, (tx) =>
        this.fleet.inviteDriver(tx, { ...pair.driver, vehicleIds: [vehicle.id] }),
      );
      await this.db.tenant(orgId, (tx) =>
        tx.membership.updateMany({
          where: { orgId, userId: driver.userId },
          data: { status: 'active' },
        }),
      );
      fleet.push({
        pair,
        vehicle,
        driver,
        auth: { userId: driver.userId, orgId, roles: ['driver'] },
        odo: pair.vehicle.odo,
        sinceFull: 0,
        fillIndex: 0,
      });
    }
    return fleet;
  }

  private async trip(
    owner: TenantAuth,
    truck: Truck,
    daysAgo: number,
    km: number,
    options: { second: boolean },
  ): Promise<void> {
    const [from, to] = ROUTES[between(0, ROUTES.length - 1)] ?? ROUTES[0];
    const start = ist(daysAgo, options.second ? between(17, 19) : between(7, 10));
    const end = new Date(start.getTime() + Math.max(2, Math.round(km / 55)) * 3_600_000);
    const fare = Math.round((km * 16) / 50) * 50 * 100;
    const trip = await this.trips.create(owner, {
      tripType: 'one_way',
      customer: { name: CUSTOMERS[between(0, CUSTOMERS.length - 1)] ?? 'Walk-in customer' },
      from: { text: from, point: PUNE },
      to: { text: to, point: null },
      scheduledStartAt: start,
      scheduledEndAt: end,
      quotedFarePaise: fare,
      vehicleId: truck.vehicle.id,
      driverId: truck.driver.id,
    });
    await this.trips.start(truck.auth, trip.id, newId(), {
      odometer: await this.odometer(truck.auth, truck.odo, start),
      occurredAt: start,
    });

    const toll = random() < 0.4 ? between(1, 4) * 5_000 : 0;
    const billed = fare + toll;
    // One trip in five is settled short, so billed and collected pull apart on the chart.
    const shortfall = random() < 0.2 ? Math.round((billed * between(10, 35)) / 100 / 100) * 100 : 0;
    if (shortfall > 0) this.shortPaid += 1;
    const paid = billed - shortfall;
    const cash = Math.round((paid * (random() < 0.5 ? 1 : 0.6)) / 100) * 100;

    await this.trips.end(truck.auth, trip.id, newId(), {
      odometer: await this.odometer(truck.auth, truck.odo + km, end),
      occurredAt: end,
      charges: toll ? [{ id: newId(), kind: 'toll', amountPaise: toll, paidByDriver: true }] : [],
      collections: [
        { id: newId(), method: 'cash', amountPaise: cash, collectedAt: end },
        ...(paid - cash > 0
          ? [
              {
                id: newId(),
                method: 'upi' as const,
                amountPaise: paid - cash,
                reference: `UPI${String(between(100_000, 999_999))}`,
                collectedAt: end,
              },
            ]
          : []),
      ],
    });
    truck.odo += km;
    truck.sinceFull += km;
  }

  private async fill(truck: Truck, daysAgo: number): Promise<void> {
    const at = ist(daysAgo, 19, between(0, 50));
    // A bifuel car alternates between its two fuels, so it lands on both fuel charts.
    const fuel =
      truck.pair.vehicle.fuel === 'petrol_cng'
        ? truck.fillIndex % 2 === 0
          ? 'petrol'
          : 'cng'
        : truck.pair.vehicle.fuel;
    const efficiency = truck.pair.vehicle.kmpl * (1 + (random() - 0.5) * 0.08);
    const quantityMilli = Math.max(1_000, Math.round((truck.sinceFull / efficiency) * 1_000));
    const cost = Math.round((quantityMilli / 1_000) * PRICES[fuel]);
    const receipt = await this.photo(
      truck.auth,
      'fuel_receipt',
      `RS ${String(Math.round(cost / 100))}`,
      at,
      {
        'ocr-amount-paise': String(cost),
      },
    );
    await this.fuel.record(truck.auth, {
      id: newId(),
      vehicleId: truck.vehicle.id,
      fuel,
      quantityMilli,
      costPaise: cost,
      odometer: await this.odometer(truck.auth, truck.odo, at),
      isFullTank: true,
      receiptMediaId: receipt,
      paidBy: truck.fillIndex % 3 === 0 ? 'owner' : 'driver_cash',
      filledAt: at,
    });
    truck.sinceFull = 0;
    truck.fillIndex += 1;
  }

  private async odometer(auth: TenantAuth, km: number, at: Date) {
    return {
      id: newId(),
      typedKm: km,
      mediaId: await this.photo(auth, 'odometer', `${String(km)} KM`, at, {
        'ocr-km': String(km),
      }),
      capturedAt: at,
    };
  }

  private async photo(
    auth: TenantAuth,
    kind: 'odometer' | 'fuel_receipt',
    text: string,
    at: Date,
    ocr: Record<string, string>,
  ): Promise<string> {
    const bytes = textPng(
      text,
      kind === 'odometer'
        ? { bg: [20, 20, 20], fg: [250, 250, 250] }
        : { bg: [250, 248, 240], fg: [30, 30, 30] },
    );
    const id = newId();
    await this.media.create(auth, {
      id,
      kind,
      contentType: 'image/png',
      sha256: createHash('sha256').update(bytes).digest('hex'),
      byteSize: bytes.length,
      capturedAt: at,
      location: { lat: PUNE.lat, lng: PUNE.lng, accuracyM: 8 },
    });
    const { storageKey } = await this.db.tenant(auth.orgId, (tx) =>
      tx.mediaObject.findUniqueOrThrow({ where: { id } }),
    );
    await this.s3.client.send(
      new PutObjectCommand({
        Bucket: this.s3.bucket,
        Key: storageKey,
        Body: bytes,
        ContentType: 'image/png',
        Metadata: ocr,
      }),
    );
    await this.media.complete(auth, id);
    this.photos += 1;
    return id;
  }

  private async setPasswords(): Promise<void> {
    const passwordHash = await hashPassword(DEMO_PASSWORD);
    await this.db.system((tx) =>
      tx.user.updateMany({
        where: { phoneE164: { in: PAIRS.map((p) => p.driver.phone) } },
        data: { passwordHash },
      }),
    );
  }

  private async drainJobs(): Promise<void> {
    const relay = this.ctx.get(OutboxRelay);
    const dispatcher = this.ctx.get(JobDispatcher);
    for (;;) {
      const events: JobEvent[] = [];
      await relay.drainOnce((event) => {
        events.push(event);
        return Promise.resolve();
      }, 500);
      if (!events.length) return;
      for (const event of events) await dispatcher.dispatch(event);
    }
  }
}

function log(message: string): void {
  process.stdout.write(`${message}\n`);
}

export async function runAnalyticsSeed(ctx: INestApplicationContext, phone: string): Promise<void> {
  await new AnalyticsSeeder(ctx).run(phone);
}
