import { Injectable } from '@nestjs/common';
import type { Driver, FuelType, PayRule, Vehicle } from '@taxcy/contracts';
import { Prisma, type TenantTx } from '@taxcy/db';
import { AppError, notFound } from '../../platform/errors.js';
import { definedOnly, type Patch } from '../../platform/patch.js';
import { newId } from '../../platform/ids.js';
import { FleetRepository } from './fleet.repository.js';

interface Pair {
  vehicleId: string;
  driverId: string;
}

@Injectable()
export class FleetService {
  constructor(private readonly repo: FleetRepository) {}

  async requireVehicle(tx: TenantTx, id: string): Promise<Vehicle> {
    const vehicle = await this.repo.findVehicle(tx, id);
    if (!vehicle) throw notFound('Vehicle');
    return vehicle;
  }

  async createVehicle(
    tx: TenantTx,
    input: {
      registrationNo: string;
      make: string;
      model: string;
      year?: number | undefined;
      fuelType: FuelType;
      vehicleModelId?: string | undefined;
      lastOdometerKm?: number | undefined;
      driverIds?: string[] | undefined;
    },
  ): Promise<Vehicle> {
    const duplicate = await tx.vehicle.count({
      where: { orgId: tx.orgId, registrationNo: input.registrationNo },
    });
    if (duplicate)
      throw new AppError('CONFLICT', `${input.registrationNo} is already in your fleet`);
    const driverIds = new Set(input.driverIds ?? []);
    await this.assertAllExist(tx, 'driver', [...driverIds]);
    // An owner-driver drives every vehicle they add.
    const org = await tx.organization.findUniqueOrThrow({
      where: { id: tx.orgId },
      select: { kind: true },
    });
    if (org.kind === 'dco') {
      const owners = await tx.driver.findMany({
        where: { orgId: tx.orgId, membership: { roles: { has: 'owner' } } },
        select: { id: true },
      });
      for (const owner of owners) driverIds.add(owner.id);
    }
    const id = newId();
    await this.repo.createVehicle(tx, {
      id,
      registrationNo: input.registrationNo,
      make: input.make,
      model: input.model,
      year: input.year ?? null,
      fuelType: input.fuelType,
      vehicleModelId: input.vehicleModelId ?? null,
      lastOdometerKm: input.lastOdometerKm ?? null,
    });
    await this.repo.link(
      tx,
      [...driverIds].map((driverId) => ({ vehicleId: id, driverId })),
    );
    return this.requireVehicle(tx, id);
  }

  /** Replaces the drivers who may drive a vehicle. */
  async setVehicleDrivers(tx: TenantTx, vehicleId: string, driverIds: string[]): Promise<Vehicle> {
    await this.requireVehicle(tx, vehicleId);
    await this.assertAllExist(tx, 'driver', driverIds);
    await this.relink(
      tx,
      await this.repo.linkedPairs(tx, { vehicleId }),
      driverIds.map((driverId) => ({ vehicleId, driverId })),
    );
    return this.requireVehicle(tx, vehicleId);
  }

  /** Replaces the vehicles a driver may drive. */
  async setDriverVehicles(tx: TenantTx, driverId: string, vehicleIds: string[]): Promise<Driver> {
    await this.requireDriver(tx, driverId);
    await this.assertAllExist(tx, 'vehicle', vehicleIds);
    await this.relink(
      tx,
      await this.repo.linkedPairs(tx, { driverId }),
      vehicleIds.map((vehicleId) => ({ vehicleId, driverId })),
    );
    return this.requireDriver(tx, driverId);
  }

  private async relink(tx: TenantTx, current: Pair[], wanted: Pair[]): Promise<void> {
    const key = (p: Pair) => `${p.vehicleId}:${p.driverId}`;
    const wantedKeys = new Set(wanted.map(key));
    const currentKeys = new Set(current.map(key));
    const removed = current.filter((p) => !wantedKeys.has(key(p)));
    if (removed.length) {
      // Trips already booked with a pair keep it until they're reassigned or done.
      const open = await tx.trip.findMany({
        where: { orgId: tx.orgId, status: { in: ['assigned', 'started'] }, OR: removed },
        select: { id: true },
        orderBy: { scheduledStartAt: 'asc' },
      });
      if (open.length) {
        throw new AppError(
          'LINK_IN_USE',
          `Reassign or finish the ${open.length} assigned or running trip(s) with this driver and vehicle first`,
          { tripIds: open.map((t) => t.id) },
        );
      }
    }
    await this.repo.unlink(tx, removed);
    await this.repo.link(
      tx,
      wanted.filter((p) => !currentKeys.has(key(p))),
    );
  }

  private async assertAllExist(
    tx: TenantTx,
    kind: 'vehicle' | 'driver',
    ids: string[],
  ): Promise<void> {
    if (!ids.length) return;
    const where = { orgId: tx.orgId, id: { in: ids } };
    const found =
      kind === 'vehicle' ? await tx.vehicle.count({ where }) : await tx.driver.count({ where });
    if (found !== new Set(ids).size) throw notFound(kind === 'vehicle' ? 'Vehicle' : 'Driver');
  }

  async updateVehicle(
    tx: TenantTx,
    id: string,
    patch: Patch<Omit<Vehicle, 'id' | 'createdAt'>>,
  ): Promise<Vehicle> {
    await this.requireVehicle(tx, id);
    await this.repo.updateVehicle(tx, id, definedOnly(patch));
    return this.requireVehicle(tx, id);
  }

  async requireDriver(tx: TenantTx, id: string): Promise<Driver> {
    const driver = await this.repo.findDriver(tx, id);
    if (!driver) throw notFound('Driver');
    return driver;
  }

  /**
   * Invites a driver by phone. The user is created if new; an existing member (e.g.
   * a manager who also drives) gains the driver role. The membership stays
   * 'invited' until their first sign-in.
   */
  async inviteDriver(
    tx: TenantTx,
    input: { name: string; phone: string; vehicleIds?: string[] | undefined },
  ): Promise<Driver> {
    await this.assertAllExist(tx, 'vehicle', input.vehicleIds ?? []);
    const user = await tx.user.upsert({
      where: { phoneE164: input.phone },
      update: {},
      create: { id: newId(), phoneE164: input.phone, name: input.name },
    });
    if (!user.name) await tx.user.update({ where: { id: user.id }, data: { name: input.name } });

    let membership = await tx.membership.findUnique({
      where: { orgId_userId: { orgId: tx.orgId, userId: user.id } },
    });
    if (!membership) {
      membership = await tx.membership.create({
        data: {
          id: newId(),
          orgId: tx.orgId,
          userId: user.id,
          roles: ['driver'],
          status: 'invited',
        },
      });
    } else if (!membership.roles.includes('driver')) {
      membership = await tx.membership.update({
        where: { id: membership.id },
        data: { roles: [...membership.roles, 'driver'] },
      });
    }
    if (await tx.driver.count({ where: { membershipId: membership.id } })) {
      throw new AppError('CONFLICT', `${input.phone} is already a driver in this organization`);
    }
    const id = newId();
    await tx.driver.create({
      data: { id, orgId: tx.orgId, membershipId: membership.id, userId: user.id, name: input.name },
    });
    await this.repo.link(
      tx,
      (input.vehicleIds ?? []).map((vehicleId) => ({ vehicleId, driverId: id })),
    );
    return this.requireDriver(tx, id);
  }

  async updateDriver(
    tx: TenantTx,
    id: string,
    patch: Patch<{ name: string; status: 'active' | 'inactive' }>,
  ): Promise<Driver> {
    await this.requireDriver(tx, id);
    await this.repo.updateDriver(tx, id, definedOnly(patch));
    return this.requireDriver(tx, id);
  }

  async setDriverPayRule(tx: TenantTx, id: string, payRule: PayRule | null): Promise<Driver> {
    await this.requireDriver(tx, id);
    await tx.driver.updateMany({
      where: { id, orgId: tx.orgId },
      data: { payRule: payRule ?? Prisma.DbNull },
    });
    return this.requireDriver(tx, id);
  }
}
