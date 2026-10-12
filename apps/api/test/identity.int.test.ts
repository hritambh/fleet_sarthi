import type { Session } from '@taxcy/contracts';
import request from 'supertest';
import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { bearer, login, ownerSession, randomPhone, startHarness, type Harness } from './harness.js';

let h: Harness;

beforeAll(async () => {
  h = await startHarness();
});

afterAll(async () => {
  await h.close();
});

describe('sign-up and reset codes', () => {
  it('creates the user on sign-up, with no org yet', async () => {
    const phone = randomPhone();
    const session = await login(h, phone);
    expect(session.user.phone).toBe(phone);
    expect(session.activeOrgId).toBeNull();
    expect(session.memberships).toEqual([]);
  });

  it('rate-limits repeated requests for the same phone', async () => {
    const phone = randomPhone();
    await request(h.http).post('/v1/auth/otp/request').send({ phone }).expect(202);
    const res = await request(h.http).post('/v1/auth/otp/request').send({ phone }).expect(429);
    expect(res.body).toMatchObject({
      error: { code: 'RATE_LIMITED', details: { retryAfterSeconds: expect.any(Number) as number } },
    });
  });

  it('validates the phone format', async () => {
    const res = await request(h.http)
      .post('/v1/auth/otp/request')
      .send({ phone: '98123' })
      .expect(400);
    expect(res.body).toMatchObject({ error: { code: 'VALIDATION_FAILED' } });
  });
});

describe('phone OTP switched off (the default)', () => {
  it('reports no OTP and refuses OTP sign-in', async () => {
    const methods = await request(h.http).get('/v1/auth/methods').expect(200);
    expect(methods.body).toEqual({ phoneOtp: null, signupRequiresVerifiedPhone: false });
    const res = await request(h.http)
      .post('/v1/auth/phone-otp/login')
      .send({ verificationToken: 'stub:+919876543210', deviceId: randomUUID(), platform: 'web' })
      .expect(403);
    expect(res.body).toMatchObject({ error: { code: 'PHONE_OTP_DISABLED' } });
  });

  it('refuses the account check too', async () => {
    const res = await request(h.http)
      .post('/v1/auth/phone-otp/check')
      .send({ phone: '+919876543210' })
      .expect(403);
    expect(res.body).toMatchObject({ error: { code: 'PHONE_OTP_DISABLED' } });
  });
});

describe('orgs and memberships', () => {
  it('one account owns a fleet and drives in another, both ways (U1/U2)', async () => {
    const u1 = await ownerSession(h, 'fleet', 'U1 Cabs');
    const u2 = await ownerSession(h, 'fleet', 'U2 Cabs');
    const invite = (owner: Session, driver: Session) =>
      request(h.http)
        .post('/v1/drivers')
        .set(...bearer(owner))
        .send({ name: 'Driver', phone: driver.user.phone })
        .expect(201);
    await invite(u1, u2);
    await invite(u2, u1);

    // Already signed in: the invite shows up in /me without signing in again.
    const me = await request(h.http)
      .get('/v1/me')
      .set(...bearer(u1))
      .expect(200);
    expect((me.body as { memberships: unknown }).memberships).toEqual([
      { orgId: u1.activeOrgId, orgName: 'U1 Cabs', orgKind: 'fleet', roles: ['owner'] },
      { orgId: u2.activeOrgId, orgName: 'U2 Cabs', orgKind: 'fleet', roles: ['driver'] },
    ]);

    const driving = await request(h.http)
      .post('/v1/auth/switch-org')
      .set(...bearer(u1))
      .send({ orgId: u2.activeOrgId, refreshToken: u1.refreshToken })
      .expect(200);
    const asDriver = await request(h.http)
      .get('/v1/me')
      .set(...bearer(driving.body as Session))
      .expect(200);
    expect(asDriver.body).toMatchObject({ activeOrgId: u2.activeOrgId, roles: ['driver'] });
  });

  it('signs in to a fleet the user owns before an older one they drive for', async () => {
    const owner = await ownerSession(h, 'fleet', 'Older Fleet');
    const phone = randomPhone();
    const first = await login(h, phone);
    await request(h.http)
      .post('/v1/drivers')
      .set(...bearer(owner))
      .send({ name: 'Driver', phone })
      .expect(201);
    const own = await request(h.http)
      .post('/v1/orgs')
      .set(...bearer(first))
      .send({ name: 'My Fleet', kind: 'fleet', refreshToken: first.refreshToken })
      .expect(201);

    const again = await login(h, phone);
    expect(again.memberships.map((m) => m.orgName)).toEqual(['Older Fleet', 'My Fleet']);
    expect(again.activeOrgId).toBe((own.body as Session).activeOrgId);
  });

  it('makes the creator the owner of a fleet and scopes the session to it', async () => {
    const session = await ownerSession(h, 'fleet', 'Sharma Travels');
    expect(session.activeOrgId).not.toBeNull();
    expect(session.memberships).toEqual([
      { orgId: session.activeOrgId, orgName: 'Sharma Travels', orgKind: 'fleet', roles: ['owner'] },
    ]);
    const me = await request(h.http)
      .get('/v1/me')
      .set(...bearer(session))
      .expect(200);
    expect(me.body).toMatchObject({ activeOrgId: session.activeOrgId, roles: ['owner'] });
  });

  it('makes a DCO owner also its driver, with a driver profile', async () => {
    const session = await ownerSession(h, 'dco', 'Ravi Cabs');
    expect(session.memberships[0]?.roles).toEqual(['owner', 'driver']);
    const drivers = await h.owner.driver.findMany({ where: { orgId: session.activeOrgId ?? '' } });
    expect(drivers).toHaveLength(1);
  });

  it('switches only into orgs the user belongs to', async () => {
    const a = await ownerSession(h);
    const res = await request(h.http)
      .post('/v1/auth/switch-org')
      .set(...bearer(a))
      .send({ refreshToken: a.refreshToken, orgId: randomUUID() })
      .expect(404);
    expect(res.body).toMatchObject({ error: { code: 'NOT_FOUND' } });
  });

  it('requires a token for user routes', async () => {
    const res = await request(h.http).get('/v1/me').expect(401);
    expect(res.body).toMatchObject({ error: { code: 'UNAUTHENTICATED' } });
  });
});

describe('refresh token rotation', () => {
  it('rotates on every refresh', async () => {
    const session = await login(h);
    const res = await request(h.http)
      .post('/v1/auth/refresh')
      .send({ refreshToken: session.refreshToken })
      .expect(200);
    const next = res.body as Session;
    expect(next.refreshToken).not.toBe(session.refreshToken);
    expect(next.user.id).toBe(session.user.id);
  });

  it('treats reuse of a rotated token as theft and revokes the whole family', async () => {
    const session = await login(h);
    const rotated = (
      await request(h.http)
        .post('/v1/auth/refresh')
        .send({ refreshToken: session.refreshToken })
        .expect(200)
    ).body as Session;
    await request(h.http)
      .post('/v1/auth/refresh')
      .send({ refreshToken: session.refreshToken })
      .expect(401);
    // The legitimate holder's newer token is now dead too.
    await request(h.http)
      .post('/v1/auth/refresh')
      .send({ refreshToken: rotated.refreshToken })
      .expect(401);
  });

  it('logout revokes the session', async () => {
    const session = await login(h);
    await request(h.http)
      .post('/v1/auth/logout')
      .send({ refreshToken: session.refreshToken })
      .expect(204);
    await request(h.http)
      .post('/v1/auth/refresh')
      .send({ refreshToken: session.refreshToken })
      .expect(401);
  });
});
