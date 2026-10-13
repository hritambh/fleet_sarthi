import type { Session } from '@taxcy/contracts';
import { istBusinessDate } from '@taxcy/domain';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  bearer,
  driverSession,
  lastOtp,
  ownerSession,
  randomPhone,
  startHarness,
  type Harness,
} from './harness.js';

let h: Harness;
let owner: Session;
let driver: { session: Session; driverId: string };
let other: { session: Session; driverId: string };

const addDays = (days: number) =>
  new Date(Date.parse(`${istBusinessDate(new Date())}T00:00:00Z`) + days * 86_400_000)
    .toISOString()
    .slice(0, 10);

interface Doc {
  id: string;
  reviewStatus: string;
  reviewNote: string | null;
  submittedByDriver: boolean;
  replacesId: string | null;
  supersededBy: string | null;
  status: string;
  daysLeft: number | null;
}

async function submittedAlerts(docId: string) {
  return h.owner.alert.findMany({ where: { kind: 'document_submitted', subjectId: docId } });
}

beforeAll(async () => {
  h = await startHarness();
  owner = await ownerSession(h, 'fleet', 'Driver Self Travels');
  driver = await driverSession(h, owner, 'Ramesh Kumar');
  other = await driverSession(h, owner, 'Suresh Patil');
});

afterAll(async () => {
  await h.close();
});

describe('driver profile', () => {
  it('returns the signed-in driver', async () => {
    const res = await request(h.http)
      .get('/v1/me/driver')
      .set(...bearer(driver.session))
      .expect(200);
    expect(res.body).toMatchObject({ id: driver.driverId, name: 'Ramesh Kumar' });
  });
});

describe('driver documents', () => {
  it('a driver upload waits for approval, then counts', async () => {
    const res = await request(h.http)
      .post('/v1/me/documents')
      .set(...bearer(driver.session))
      .send({ docType: 'driving_licence', number: 'MH12 2020', expiresOn: addDays(400) })
      .expect(201);
    const doc = res.body as Doc;
    expect(doc).toMatchObject({ reviewStatus: 'pending', submittedByDriver: true });
    expect(await submittedAlerts(doc.id)).toMatchObject([{ status: 'open', severity: 'info' }]);

    // The owner sees it on the driver's documents.
    const list = await request(h.http)
      .get(`/v1/documents?driverId=${driver.driverId}`)
      .set(...bearer(owner))
      .expect(200);
    expect((list.body as Doc[]).map((d) => d.id)).toContain(doc.id);

    const approved = await request(h.http)
      .post(`/v1/documents/${doc.id}/approve`)
      .set(...bearer(owner))
      .expect(200);
    expect(approved.body).toMatchObject({ reviewStatus: 'approved' });
    expect(await submittedAlerts(doc.id)).toMatchObject([{ status: 'resolved' }]);

    // A renewal replaces the old copy only once approved.
    const renewal = await request(h.http)
      .post(`/v1/me/documents/${doc.id}/renew`)
      .set(...bearer(driver.session))
      .send({ expiresOn: addDays(800) })
      .expect(201);
    expect(renewal.body).toMatchObject({ reviewStatus: 'pending', replacesId: doc.id });
    const before = await request(h.http)
      .get('/v1/me/documents')
      .set(...bearer(driver.session))
      .expect(200);
    expect((before.body as Doc[]).map((d) => d.id).sort()).toEqual(
      [doc.id, (renewal.body as Doc).id].sort(),
    );
    await request(h.http)
      .post(`/v1/documents/${(renewal.body as Doc).id}/approve`)
      .set(...bearer(owner))
      .expect(200);
    const after = await request(h.http)
      .get('/v1/me/documents')
      .set(...bearer(driver.session))
      .expect(200);
    expect((after.body as Doc[]).map((d) => d.id)).toEqual([(renewal.body as Doc).id]);
  });

  it('a rejected upload keeps the reason', async () => {
    const res = await request(h.http)
      .post('/v1/me/documents')
      .set(...bearer(driver.session))
      .send({ docType: 'aadhaar', number: '1234 5678 9012' })
      .expect(201);
    expect(res.body).toMatchObject({ daysLeft: null, status: 'valid' });
    const rejected = await request(h.http)
      .post(`/v1/documents/${(res.body as Doc).id}/reject`)
      .set(...bearer(owner))
      .send({ note: 'Photo is blurry' })
      .expect(200);
    expect(rejected.body).toMatchObject({
      reviewStatus: 'rejected',
      reviewNote: 'Photo is blurry',
    });
    // Only a pending document can be reviewed.
    await request(h.http)
      .post(`/v1/documents/${(res.body as Doc).id}/approve`)
      .set(...bearer(owner))
      .expect(409);
  });

  it('licences need an expiry date; vehicle papers are not a driver’s', async () => {
    await request(h.http)
      .post('/v1/me/documents')
      .set(...bearer(driver.session))
      .send({ docType: 'driving_licence' })
      .expect(400);
    await request(h.http)
      .post('/v1/me/documents')
      .set(...bearer(driver.session))
      .send({ docType: 'insurance', expiresOn: addDays(100) })
      .expect(400);
  });

  it("a driver can't see or renew another driver's documents", async () => {
    const theirs = await request(h.http)
      .post('/v1/documents')
      .set(...bearer(owner))
      .send({ docType: 'pan', driverId: other.driverId })
      .expect(201);
    const mine = await request(h.http)
      .get('/v1/me/documents')
      .set(...bearer(driver.session))
      .expect(200);
    expect((mine.body as Doc[]).map((d) => d.id)).not.toContain((theirs.body as Doc).id);
    await request(h.http)
      .post(`/v1/me/documents/${(theirs.body as Doc).id}/renew`)
      .set(...bearer(driver.session))
      .send({})
      .expect(404);
    // Staff-only review.
    await request(h.http)
      .post(`/v1/documents/${(theirs.body as Doc).id}/approve`)
      .set(...bearer(driver.session))
      .expect(403);
  });
});

describe('driver trips in a range', () => {
  it("returns only the driver's own trips overlapping the window", async () => {
    const from = new Date(Date.now() - 6 * 86_400_000).toISOString();
    const to = new Date(Date.now() + 86_400_000).toISOString();
    const res = await request(h.http)
      .get('/v1/me/trips/range')
      .query({ from, to })
      .set(...bearer(driver.session))
      .expect(200);
    expect(Array.isArray(res.body)).toBe(true);
    for (const t of res.body as { driver: { id: string } | null }[]) {
      expect(t.driver?.id).toBe(driver.driverId);
    }
    await request(h.http)
      .get('/v1/me/trips/range')
      .query({ from, to: new Date(Date.now() + 90 * 86_400_000).toISOString() })
      .set(...bearer(driver.session))
      .expect(400);
  });
});

describe('driver profile details', () => {
  it('the driver edits their own details and the owner sees them', async () => {
    const res = await request(h.http)
      .patch('/v1/me/driver')
      .set(...bearer(driver.session))
      .send({
        dateOfBirth: '1990-05-20',
        email: 'ramesh@example.com',
        address: '12 MG Road, Pune',
        emergencyContactName: 'Sita Kumar',
        emergencyContactPhone: '+919876543210',
      })
      .expect(200);
    expect(res.body).toMatchObject({ email: 'ramesh@example.com', dateOfBirth: '1990-05-20' });
    const seen = await request(h.http)
      .get(`/v1/drivers/${driver.driverId}`)
      .set(...bearer(owner))
      .expect(200);
    expect(seen.body).toMatchObject({
      address: '12 MG Road, Pune',
      emergencyContactName: 'Sita Kumar',
    });
  });

  it('the owner edits them too, and a bad email is refused', async () => {
    const res = await request(h.http)
      .patch(`/v1/drivers/${driver.driverId}`)
      .set(...bearer(owner))
      .send({ address: null, email: 'r.kumar@example.com' })
      .expect(200);
    expect(res.body).toMatchObject({ address: null, email: 'r.kumar@example.com' });
    await request(h.http)
      .patch('/v1/me/driver')
      .set(...bearer(driver.session))
      .send({ email: 'not-an-email' })
      .expect(400);
  });

  it('renaming yourself renames you on the owner’s list', async () => {
    await request(h.http)
      .patch('/v1/me/driver')
      .set(...bearer(driver.session))
      .send({ name: 'Ramesh K. Yadav' })
      .expect(200);
    const seen = await request(h.http)
      .get(`/v1/drivers/${driver.driverId}`)
      .set(...bearer(owner))
      .expect(200);
    expect(seen.body).toMatchObject({ name: 'Ramesh K. Yadav' });
  });
});

describe('changing your mobile number', () => {
  it('needs the code sent to the new number, and a free number', async () => {
    const next = randomPhone();
    await request(h.http)
      .post('/v1/me/phone/otp')
      .set(...bearer(other.session))
      .send({ phone: next })
      .expect(202);
    await request(h.http)
      .post('/v1/me/phone')
      .set(...bearer(other.session))
      .send({ phone: next, code: lastOtp(h, next) === '000000' ? '111111' : '000000' })
      .expect(401); // OTP_INVALID, like a wrong password-reset code
    const res = await request(h.http)
      .post('/v1/me/phone')
      .set(...bearer(other.session))
      .send({ phone: next, code: lastOtp(h, next) })
      .expect(200);
    expect(res.body).toEqual({ phone: next });

    // Someone else's number is refused even with a valid code.
    const taken = (
      await request(h.http)
        .get(`/v1/drivers/${driver.driverId}`)
        .set(...bearer(owner))
        .expect(200)
    ).body as { phone: string };
    await request(h.http)
      .post('/v1/me/phone/otp')
      .set(...bearer(other.session))
      .send({ phone: taken.phone })
      .expect(202);
    await request(h.http)
      .post('/v1/me/phone')
      .set(...bearer(other.session))
      .send({ phone: taken.phone, code: lastOtp(h, taken.phone) })
      .expect(409);
  });
});
