import type { Session } from '@taxcy/contracts';
import request from 'supertest';
import { createServer, type Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { randomUUID } from 'node:crypto';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { TEST_PASSWORD, login, randomPhone, startHarness, type Harness } from './harness.js';

// Each integration test file runs in its own process; these settings only apply here.
const device = () => ({ deviceId: randomUUID(), platform: 'android' });
const error = (res: request.Response) => (res.body as { error: { code: string } }).error.code;

describe('phone OTP with the stub provider', () => {
  let h: Harness;

  beforeAll(async () => {
    process.env['PHONE_OTP_PROVIDER'] = 'stub';
    process.env['SIGNUP_REQUIRES_VERIFIED_PHONE'] = 'false';
    h = await startHarness();
  });

  afterAll(async () => {
    await h.close();
  });

  it('tells the app which methods are on', async () => {
    const res = await request(h.http).get('/v1/auth/methods').expect(200);
    expect(res.body).toEqual({
      phoneOtp: { provider: 'stub', clientId: null },
      signupRequiresVerifiedPhone: false,
    });
  });

  it('signs in an existing user by OTP, and each verification works once', async () => {
    const user = await login(h);
    const token = `stub:${user.user.phone}`;
    const res = await request(h.http)
      .post('/v1/auth/phone-otp/login')
      .send({ verificationToken: token, ...device() })
      .expect(200);
    expect((res.body as Session).user.id).toBe(user.user.id);

    const again = await request(h.http)
      .post('/v1/auth/phone-otp/login')
      .send({ verificationToken: token, ...device() })
      .expect(401);
    expect(error(again)).toBe('PHONE_NOT_VERIFIED');
  });

  it("doesn't create accounts on OTP sign-in", async () => {
    const res = await request(h.http)
      .post('/v1/auth/phone-otp/login')
      .send({ verificationToken: `stub:${randomPhone()}`, ...device() })
      .expect(404);
    expect(error(res)).toBe('NOT_FOUND');
  });

  it('signs up a verified number, and refuses a number other than the verified one', async () => {
    const phone = randomPhone();
    await request(h.http)
      .post('/v1/auth/signup')
      .send({ phone, password: TEST_PASSWORD, verificationToken: `stub:${phone}`, ...device() })
      .expect(201);

    const other = randomPhone();
    const res = await request(h.http)
      .post('/v1/auth/signup')
      .send({
        phone: randomPhone(),
        password: TEST_PASSWORD,
        verificationToken: `stub:${other}`,
        ...device(),
      })
      .expect(422);
    expect(res.body).toMatchObject({
      error: { code: 'PHONE_MISMATCH', details: { verifiedPhone: other } },
    });
  });

  it('resets a forgotten password with an OTP instead of a code', async () => {
    const user = await login(h);
    await request(h.http)
      .post('/v1/auth/password/reset-verified')
      .send({
        verificationToken: `stub:${user.user.phone}`,
        password: 'otp-new-password',
        ...device(),
      })
      .expect(200);
    await request(h.http)
      .post('/v1/auth/password/login')
      .send({ phone: user.user.phone, password: 'otp-new-password', ...device() })
      .expect(200);
  });
});

describe('phone OTP with phone.email, verified sign-up required', () => {
  let h: Harness;
  let fake: Server;
  const verified = randomPhone();
  const seen: Record<string, string>[] = [];

  beforeAll(async () => {
    // A stand-in for https://eapi.phone.email/getuser.
    fake = createServer((req, res) => {
      let raw = '';
      req.on('data', (chunk: Buffer) => (raw += chunk.toString()));
      req.on('end', () => {
        const form = Object.fromEntries(new URLSearchParams(raw));
        seen.push(form);
        const ok = form['access_token'] === 'good-token' && form['client_id'] === 'test-client';
        res.setHeader('Content-Type', 'application/json');
        res.end(
          JSON.stringify(
            ok
              ? { status: 200, country_code: '+91', phone_no: verified.slice(3), first_name: 'A' }
              : { status: 0 }, // what phone.email answers for a bad token
          ),
        );
      });
    });
    await new Promise<void>((resolve) => fake.listen(0, '127.0.0.1', resolve));
    const { port } = fake.address() as AddressInfo;
    process.env['PHONE_OTP_PROVIDER'] = 'phone_email';
    process.env['PHONE_EMAIL_CLIENT_ID'] = 'test-client';
    process.env['PHONE_EMAIL_USER_URL'] = `http://127.0.0.1:${port}/getuser`;
    process.env['SIGNUP_REQUIRES_VERIFIED_PHONE'] = 'true';
    h = await startHarness();
  });

  afterAll(async () => {
    await h.close();
    await new Promise((resolve) => fake.close(resolve));
  });

  it('reports phone.email with its client id', async () => {
    const res = await request(h.http).get('/v1/auth/methods').expect(200);
    expect(res.body).toEqual({
      phoneOtp: { provider: 'phone_email', clientId: 'test-client' },
      signupRequiresVerifiedPhone: true,
    });
  });

  it('requires a verified number to sign up', async () => {
    const without = await request(h.http)
      .post('/v1/auth/signup')
      .send({ phone: verified, password: TEST_PASSWORD, ...device() })
      .expect(422);
    expect(error(without)).toBe('PHONE_VERIFICATION_REQUIRED');

    const res = await request(h.http)
      .post('/v1/auth/signup')
      .send({
        phone: verified,
        password: TEST_PASSWORD,
        verificationToken: 'good-token',
        ...device(),
      })
      .expect(201);
    expect((res.body as Session).user.phone).toBe(verified);
    // The API asked phone.email itself, with the token and our client id.
    expect(seen.at(-1)).toEqual({ access_token: 'good-token', client_id: 'test-client' });
  });

  it('rejects tokens phone.email doesn’t confirm', async () => {
    const res = await request(h.http)
      .post('/v1/auth/phone-otp/login')
      .send({ verificationToken: 'forged-token', ...device() })
      .expect(401);
    expect(error(res)).toBe('PHONE_NOT_VERIFIED');
  });
});
