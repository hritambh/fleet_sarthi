import type { Session } from '@taxcy/contracts';
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { RedisService } from '../src/platform/redis.service.js';
import {
  bearer,
  lastOtp,
  login,
  ownerSession,
  randomPhone,
  startHarness,
  TEST_PASSWORD,
  type Harness,
} from './harness.js';

let h: Harness;

beforeAll(async () => {
  h = await startHarness();
});

afterAll(async () => {
  await h.close();
});

const device = () => ({ deviceId: randomUUID(), platform: 'web' });

/** Sends a fresh reset code (skipping the 30-second resend wait) and returns it. */
async function resetCode(phone: string): Promise<string> {
  await h.app.get(RedisService).client.del(`rl:otp:resend:${phone}`);
  await request(h.http).post('/v1/auth/otp/request').send({ phone }).expect(202);
  return lastOtp(h, phone);
}

async function signup(phone: string, password = 'correct horse 42') {
  return request(h.http)
    .post('/v1/auth/signup')
    .send({ phone, password, name: 'Anil Sharma', ...device() });
}

function passwordLogin(phone: string, password: string) {
  return request(h.http)
    .post('/v1/auth/password/login')
    .send({ phone, password, ...device() });
}

describe('phone and password', () => {
  it('signs up with phone and password, then logs in', async () => {
    const phone = randomPhone();
    const created = (await signup(phone)).body as Session;
    expect(created).toMatchObject({ user: { phone, name: 'Anil Sharma' }, activeOrgId: null });

    const session = (await passwordLogin(phone, 'correct horse 42').expect(200)).body as Session;
    expect(session.user.id).toBe(created.user.id);
    const me = await request(h.http)
      .get('/v1/me')
      .set(...bearer(session))
      .expect(200);
    expect(me.body).toMatchObject({ user: { hasPassword: true } });
    expect(me.body).not.toHaveProperty('user.googleLinked');
  });

  it('needs a long enough password to sign up', async () => {
    const short = await request(h.http)
      .post('/v1/auth/signup')
      .send({ phone: randomPhone(), password: 'short', ...device() })
      .expect(400);
    expect(short.body).toMatchObject({ error: { code: 'VALIDATION_FAILED' } });
  });

  it('does not let a second sign-up take over an account', async () => {
    const phone = randomPhone();
    await signup(phone);
    const again = await signup(phone, 'someone else 99');
    expect(again.status).toBe(409);
    expect(again.body).toMatchObject({ error: { code: 'ACCOUNT_EXISTS' } });
    await passwordLogin(phone, 'someone else 99').expect(401);
  });

  it('gives the same answer for a wrong password and an unknown number', async () => {
    const phone = randomPhone();
    await signup(phone);
    const wrong = await passwordLogin(phone, 'not the password').expect(401);
    const unknown = await passwordLogin(randomPhone(), 'not the password').expect(401);
    expect(wrong.body).toMatchObject({ error: { code: 'INVALID_CREDENTIALS' } });
    expect((unknown.body as { error: { message: string } }).error.message).toBe(
      (wrong.body as { error: { message: string } }).error.message,
    );
  });

  it('locks out repeated guessing for a number', async () => {
    const phone = randomPhone();
    await signup(phone);
    for (let i = 0; i < 10; i++) await passwordLogin(phone, `guess ${String(i)}xxxx`).expect(401);
    const blocked = await passwordLogin(phone, 'correct horse 42').expect(429);
    expect(blocked.body).toMatchObject({ error: { code: 'RATE_LIMITED' } });
  });

  it('an invited driver who signs up gets their fleet', async () => {
    const owner = await ownerSession(h, 'fleet', 'Sharma Travels');
    const phone = randomPhone();
    await request(h.http)
      .post('/v1/drivers')
      .set(...bearer(owner))
      .send({ name: 'Ramesh Kumar', phone })
      .expect(201);
    const session = (await signup(phone)).body as Session;
    expect(session.activeOrgId).toBe(owner.activeOrgId);
    expect(session.memberships[0]?.roles).toEqual(['driver']);
  });

  it('resets a forgotten password with a code and signs out other sessions', async () => {
    const phone = randomPhone();
    const old = (await signup(phone)).body as Session;
    const reset = await request(h.http)
      .post('/v1/auth/password/reset')
      .send({ phone, code: await resetCode(phone), password: 'brand new pass 7', ...device() })
      .expect(200);
    expect((reset.body as Session).user.id).toBe(old.user.id);
    await passwordLogin(phone, 'correct horse 42').expect(401);
    await passwordLogin(phone, 'brand new pass 7').expect(200);
    await request(h.http)
      .post('/v1/auth/refresh')
      .send({ refreshToken: old.refreshToken })
      .expect(401);
  });

  it('a wrong reset code is refused, and a code works only once', async () => {
    const phone = randomPhone();
    await signup(phone);
    const code = await resetCode(phone);
    const wrong = code === '000000' ? '111111' : '000000';
    const bad = await request(h.http)
      .post('/v1/auth/password/reset')
      .send({ phone, code: wrong, password: 'brand new pass 7', ...device() })
      .expect(401);
    expect(bad.body).toMatchObject({
      error: { code: 'OTP_INVALID', details: { attemptsLeft: 4 } },
    });
    const body = { phone, code, password: 'brand new pass 7', ...device() };
    await request(h.http).post('/v1/auth/password/reset').send(body).expect(200);
    const again = await request(h.http).post('/v1/auth/password/reset').send(body).expect(401);
    expect(again.body).toMatchObject({ error: { code: 'OTP_EXPIRED' } });
  });

  it("a reset doesn't create an account for an unknown number", async () => {
    const phone = randomPhone();
    const res = await request(h.http)
      .post('/v1/auth/password/reset')
      .send({ phone, code: await resetCode(phone), password: 'brand new pass 7', ...device() })
      .expect(404);
    expect(res.body).toMatchObject({ error: { code: 'NOT_FOUND' } });
    await passwordLogin(phone, 'brand new pass 7').expect(401);
  });

  it('changing a password needs the current one', async () => {
    const session = await login(h);
    const wrong = await request(h.http)
      .post('/v1/me/password')
      .set(...bearer(session))
      .send({ currentPassword: 'nope nope nope', newPassword: 'second password 2' })
      .expect(401);
    expect(wrong.body).toMatchObject({ error: { code: 'INVALID_CREDENTIALS' } });
    await request(h.http)
      .post('/v1/me/password')
      .set(...bearer(session))
      .send({ currentPassword: TEST_PASSWORD, newPassword: 'second password 2' })
      .expect(204);
    await passwordLogin(session.user.phone, 'second password 2').expect(200);
  });

  it('the old SMS-code login and Google sign-in are gone', async () => {
    const phone = randomPhone();
    await request(h.http)
      .post('/v1/auth/otp/verify')
      .send({ phone, code: '123456', ...device() })
      .expect(404);
    await request(h.http)
      .post('/v1/auth/google')
      .send({ idToken: 'x'.repeat(20) })
      .expect(404);
    await request(h.http).get('/v1/auth/config').expect(404);
  });
});
