import { Injectable } from '@nestjs/common';
import { PayRule, type Driver, type FuelType, type Vehicle } from '@taxcy/contracts';
import type { Prisma, TenantTx } from '@taxcy/db';

const vehicleSelect = {
  id: true,
  registrationNo: true,
  make: true,
  model: true,
  year: true,
  fuelType: true,
  vehicleModelId: true,
  lastOdometerKm: true,
  status: true,
  createdAt: true,
  drivers: {
    select: { driver: { select: { id: true, name: true } } },
    orderBy: { driver: { name: 'asc' } },
  },
} as const;

const driverInclude = {
  membership: { select: { status: true, user: { select: { phoneE164: true } } } },
  vehicles: {
    select: { vehicle: { select: { id: true, registrationNo: true } } },
    orderBy: { vehicle: { registrationNo: 'asc' } },
  },
} as const;

type DriverRow = Prisma.DriverGetPayload<{ include: typeof driverInclude }>;

function toVehicle({
  drivers,
  ...row
}: Prisma.VehicleGetPayload<{ select: typeof vehicleSelect }>): Vehicle {
  return {
    ...row,
    status: row.status === 'inactive' ? 'inactive' : 'active',
    drivers: drivers.map((link) => link.driver),
  };
}

function toDriver(row: DriverRow): Driver {
  const membershipStatus = row.membership.status;
  return {
    id: row.id,
    userId: row.userId,
    name: row.name,
    phone: row.membership.user.phoneE164,
    status: row.status === 'inactive' ? 'inactive' : 'active',
    membershipStatus:
      membershipStatus === 'invited' || membershipStatus === 'suspended'
        ? membershipStatus
        : 'active',
    payRule: row.payRule === null ? null : PayRule.parse(row.payRule),
    vehicles: row.vehicles.map((link) => link.vehicle),
    photoMediaId: row.photoMediaId,
    dateOfBirth: row.dateOfBirth,
    email: row.email,
    address: row.address,
    emergencyContactName: row.emergencyContactName,
    emergencyContactPhone: row.emergencyContactPhone,
    createdAt: row.createdAt,
  };
}

@Injectable()
export class FleetRepository {
  /** With `driverId`, only the vehicles that driver is linked to. */
  async listVehicles(
    tx: TenantTx,
    filter: { status?: 'active' | 'inactive' | undefined; driverId?: string | undefined } = {},
  ): Promise<Vehicle[]> {
    const rows = await tx.vehicle.findMany({
      where: {
        orgId: tx.orgId,
        ...(filter.status ? { status: filter.status } : {}),
        ...(filter.driverId ? { drivers: { some: { driverId: filter.driverId } } } : {}),
      },
      select: vehicleSelect,
      orderBy: { registrationNo: 'asc' },
    });
    return rows.map(toVehicle);
  }

  async findVehicle(tx: TenantTx, id: string): Promise<Vehicle | null> {
    const row = await tx.vehicle.findFirst({
      where: { id, orgId: tx.orgId },
      select: vehicleSelect,
    });
    return row ? toVehicle(row) : null;
  }

  async createVehicle(
    tx: TenantTx,
    data: {
      id: string;
      registrationNo: string;
      make: string;
      model: string;
      year: number | null;
      fuelType: FuelType;
      vehicleModelId: string | null;
      lastOdometerKm: number | null;
    },
  ): Promise<Vehicle> {
    return toVehicle(
      await tx.vehicle.create({ data: { ...data, orgId: tx.orgId }, select: vehicleSelect }),
    );
  }

  async updateVehicle(
    tx: TenantTx,
    id: string,
    data: Prisma.VehicleUpdateManyMutationInput,
  ): Promise<void> {
    await tx.vehicle.updateMany({ where: { id, orgId: tx.orgId }, data });
  }

  async listDrivers(tx: TenantTx, status?: 'active' | 'inactive'): Promise<Driver[]> {
    const rows = await tx.driver.findMany({
      where: { orgId: tx.orgId, ...(status ? { status } : {}) },
      include: driverInclude,
      orderBy: { name: 'asc' },
    });
    return rows.map(toDriver);
  }

  async findDriver(tx: TenantTx, id: string): Promise<Driver | null> {
    const row = await tx.driver.findFirst({
      where: { id, orgId: tx.orgId },
      include: driverInclude,
    });
    return row ? toDriver(row) : null;
  }

  async findDriverByUser(tx: TenantTx, userId: string): Promise<Driver | null> {
    const row = await tx.driver.findFirst({
      where: { userId, orgId: tx.orgId },
      include: driverInclude,
    });
    return row ? toDriver(row) : null;
  }

  async linkedPairs(
    tx: TenantTx,
    where: { vehicleId: string } | { driverId: string },
  ): Promise<{ vehicleId: string; driverId: string }[]> {
    return tx.vehicleDriver.findMany({
      where: { orgId: tx.orgId, ...where },
      select: { vehicleId: true, driverId: true },
    });
  }

  async link(tx: TenantTx, pairs: { vehicleId: string; driverId: string }[]): Promise<void> {
    if (!pairs.length) return;
    await tx.vehicleDriver.createMany({
      data: pairs.map((p) => ({ ...p, orgId: tx.orgId })),
      skipDuplicates: true,
    });
  }

  async unlink(tx: TenantTx, pairs: { vehicleId: string; driverId: string }[]): Promise<void> {
    if (!pairs.length) return;
    await tx.vehicleDriver.deleteMany({ where: { orgId: tx.orgId, OR: pairs } });
  }

  async updateDriver(
    tx: TenantTx,
    id: string,
    data: Prisma.DriverUpdateManyMutationInput,
  ): Promise<void> {
    await tx.driver.updateMany({ where: { id, orgId: tx.orgId }, data });
  }
}
