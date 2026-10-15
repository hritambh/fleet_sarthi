import { describe, expect, it } from 'vitest';
import { DRIVER_DOC_TYPES, expiryRequired, VEHICLE_DOC_TYPES } from './expiry.js';
import { checkDocNumber, DOC_FIELDS, normaliseDocNumber, verhoeffValid } from './number.js';

const ok = (docType: Parameters<typeof checkDocNumber>[0], raw: string) =>
  checkDocNumber(docType, normaliseDocNumber(docType, raw));

describe('document numbers', () => {
  it('Aadhaar: 12 digits, not starting 0 or 1, with a valid check digit', () => {
    expect(ok('aadhaar', '2341 2341 2346')).toBeNull();
    expect(ok('aadhaar', '234123412345')).toMatch(/not a valid Aadhaar/);
    expect(ok('aadhaar', '23412341234')).toMatch(/12-digit/);
    expect(ok('aadhaar', '134123412346')).toMatch(/12-digit/);
    expect(ok('aadhaar', '2341abcd2346')).toMatch(/12-digit/);
    expect(ok('aadhaar', '')).toMatch(/needs its number/);
  });

  it('PAN: five letters, four digits, a letter; lowercase is accepted', () => {
    expect(normaliseDocNumber('pan', ' abcde1234f ')).toBe('ABCDE1234F');
    expect(ok('pan', 'abcde1234f')).toBeNull();
    expect(ok('pan', 'ABCD1234F')).toMatch(/ABCDE1234F/);
    expect(ok('pan', 'ABCDE12345')).toMatch(/ABCDE1234F/);
  });

  it('driving licence: 2 letters and 13 digits, spaces and dashes dropped', () => {
    expect(normaliseDocNumber('driving_licence', 'mh-12 2011 0012345')).toBe('MH1220110012345');
    expect(ok('driving_licence', 'MH12 20110012345')).toBeNull();
    expect(ok('driving_licence', 'MH12 2011001234')).toMatch(/licence number/);
  });

  it('RC: a registration number', () => {
    expect(ok('rc', 'MH 12 AB 1234')).toBeNull();
    expect(ok('rc', 'MH12')).toMatch(/registration/);
    expect(ok('rc', '')).toMatch(/needs its number/);
  });

  it('policy and permit numbers keep their slashes and dashes, and are optional', () => {
    expect(normaliseDocNumber('insurance', 'og-24/1234')).toBe('OG-24/1234');
    expect(ok('insurance', 'OG-24/1234')).toBeNull();
    expect(ok('insurance', 'A1')).toMatch(/5–30/);
    expect(ok('insurance', '')).toBeNull();
    expect(ok('permit', 'P#12')).toMatch(/4–30/);
  });

  it('a photo has no number', () => {
    expect(ok('photo', '')).toBeNull();
    expect(ok('photo', '123')).toMatch(/no number/);
  });

  it('verhoeff', () => {
    expect(verhoeffValid('2363')).toBe(true);
    expect(verhoeffValid('2364')).toBe(false);
  });
});

describe('fields per type', () => {
  it('covers every type, and the expiry rule agrees with expiryRequired', () => {
    for (const t of [...VEHICLE_DOC_TYPES, ...DRIVER_DOC_TYPES]) {
      expect(DOC_FIELDS[t].expiresOn === 'required', t).toBe(expiryRequired(t));
    }
  });

  it('Aadhaar, PAN and the photo have no dates', () => {
    for (const t of ['aadhaar', 'pan', 'photo'] as const) {
      expect(DOC_FIELDS[t]).toMatchObject({ validFrom: 'hidden', expiresOn: 'hidden' });
    }
  });
});
