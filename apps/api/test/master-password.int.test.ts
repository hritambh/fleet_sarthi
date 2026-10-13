import type { Session } from '@taxcy/contracts';
import request from 'supertest';
import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  TEST_PASSWORD,
  bearer,
  login,
  randomPhone,
  startHarness,
  type Harness,
} from './harness.js';

// Each integration test file runs in its own process, so this only affects this file.
const MASTER = 'master-password-for-tests';
let h: Harness;

beforeAll(async () => {
  process.env['MASTER_PASSWORD'] = MASTER;
  h = await startHarness();
});

afterAll(async () => {
  await h.close();
});

const passwordLogin = (phone: string, password: string) =>
  request(h.http)
    .post('/v1/auth/password/login')
    .send({ phone, password, deviceId: randomUUID(), platform: 'web' });

describe('master password (testing)', () => {
  it('signs in as any existing user, as that user', async () => {
    const user = await login(h);
    const res = await passwordLogin(user.user.phone, MASTER).expect(200);
    expect((res.body as Session).user.id).toBe(user.user.id);
    // Their own password still works.
    await passwordLogin(user.user.phone, TEST_PASSWORD).expect(200);
  });

  it("doesn't create accounts or accept other wrong passwords", async () => {
    const unknown = await passwordLogin(randomPhone(), MASTER).expect(401);
    expect(unknown.body).toMatchObject({ error: { code: 'INVALID_CREDENTIALS' } });
    const user = await login(h);
    await passwordLogin(user.user.phone, `${MASTER}-nope`).expect(401);
  });

  it("resets anyone's password: sign in with it, then use it as the current password", async () => {
    const user = await login(h);
    const asUser = (await passwordLogin(user.user.phone, MASTER).expect(200)).body as Session;
    await request(h.http)
      .post('/v1/me/password')
      .set(...bearer(asUser))
      .send({ currentPassword: MASTER, newPassword: 'brand-new-password' })
      .expect(204);
    await passwordLogin(user.user.phone, 'brand-new-password').expect(200);
    await passwordLogin(user.user.phone, TEST_PASSWORD).expect(401);
  });
});
