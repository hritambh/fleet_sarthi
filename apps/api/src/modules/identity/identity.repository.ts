import { Injectable } from '@nestjs/common';
import type { Membership } from '@taxcy/contracts';
import type { SystemTx } from '@taxcy/db';
import { newId } from '../../platform/ids.js';

export interface UserRow {
  id: string;
  phoneE164: string;
  name: string | null;
}

/** A user with their password hash. */
export interface AccountRow extends UserRow {
  passwordHash: string | null;
}

const accountSelect = {
  id: true,
  phoneE164: true,
  name: true,
  passwordHash: true,
} as const;

/**
 * User-centric data. These lookups happen before (or across) org selection, so they
 * run in system transactions; every query is still filtered by the user's own id.
 */
@Injectable()
export class IdentityRepository {
  async upsertUserByPhone(tx: SystemTx, phone: string): Promise<UserRow> {
    return tx.user.upsert({
      where: { phoneE164: phone },
      update: {},
      create: { id: newId(), phoneE164: phone },
      select: { id: true, phoneE164: true, name: true },
    });
  }

  async findUser(tx: SystemTx, userId: string): Promise<UserRow | null> {
    return tx.user.findUnique({
      where: { id: userId },
      select: { id: true, phoneE164: true, name: true },
    });
  }

  async findAccount(
    tx: SystemTx,
    where: { id: string } | { phoneE164: string },
  ): Promise<AccountRow | null> {
    return tx.user.findUnique({ where, select: accountSelect });
  }

  async setPassword(tx: SystemTx, userId: string, passwordHash: string): Promise<void> {
    await tx.user.update({ where: { id: userId }, data: { passwordHash } });
  }

  /** Signs the user out everywhere (after a password reset). */
  async revokeAllForUser(tx: SystemTx, userId: string): Promise<void> {
    await tx.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }

  async updateUserName(tx: SystemTx, userId: string, name: string): Promise<UserRow> {
    return tx.user.update({
      where: { id: userId },
      data: { name },
      select: { id: true, phoneE164: true, name: true },
    });
  }

  async upsertDevice(
    tx: SystemTx,
    device: { id: string; userId: string; platform: string; appVersion: string | undefined },
  ): Promise<void> {
    const data = {
      userId: device.userId,
      platform: device.platform,
      appVersion: device.appVersion ?? null,
      lastSeenAt: new Date(),
    };
    await tx.device.upsert({
      where: { id: device.id },
      update: data,
      create: { id: device.id, ...data },
    });
  }

  /** Invited memberships become active the first time the user signs in. */
  async activateInvitedMemberships(tx: SystemTx, userId: string): Promise<void> {
    await tx.membership.updateMany({
      where: { userId, status: 'invited' },
      data: { status: 'active' },
    });
  }

  async activeMemberships(tx: SystemTx, userId: string): Promise<Membership[]> {
    const rows = await tx.membership.findMany({
      where: { userId, status: 'active' },
      orderBy: { createdAt: 'asc' },
      select: { orgId: true, roles: true, org: { select: { name: true, kind: true } } },
    });
    return rows.map((r) => ({
      orgId: r.orgId,
      orgName: r.org.name,
      orgKind: r.org.kind,
      roles: r.roles,
    }));
  }

  async insertRefreshToken(
    tx: SystemTx,
    token: {
      id: string;
      userId: string;
      orgId: string | null;
      familyId: string;
      tokenHash: string;
      deviceId: string | null;
      expiresAt: Date;
    },
  ): Promise<void> {
    await tx.refreshToken.create({ data: token });
  }

  async findRefreshToken(tx: SystemTx, tokenHash: string) {
    return tx.refreshToken.findUnique({ where: { tokenHash } });
  }

  async markRotated(tx: SystemTx, id: string, replacedBy: string): Promise<void> {
    await tx.refreshToken.update({ where: { id }, data: { revokedAt: new Date(), replacedBy } });
  }

  async revokeFamily(tx: SystemTx, familyId: string): Promise<void> {
    await tx.refreshToken.updateMany({
      where: { familyId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }
}
