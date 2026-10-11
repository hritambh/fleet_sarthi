import { describe, expect, it } from 'vitest';
import { loadConfig } from './config.js';

const base = {
  DATABASE_URL: 'postgres://taxcy_api:pw@localhost:5433/taxcy',
  REDIS_URL: 'redis://localhost:6380',
  S3_ENDPOINT: 'http://localhost:9000',
  S3_REGION: 'ap-south-1',
  S3_BUCKET: 'taxcy-media',
  S3_ACCESS_KEY_ID: 'taxcy',
  S3_SECRET_ACCESS_KEY: 'secret',
  JWT_ACCESS_SECRET: 'x'.repeat(32),
};

describe('loadConfig', () => {
  it('runs jobs in the workers app and keeps demo mode off by default', () => {
    const config = loadConfig({ ...base, DEMO_MODE: '' });
    expect(config.JOBS_MODE).toBe('external');
    expect(config.DEMO_MODE).toBe(false);
  });

  it('accepts in-process jobs', () => {
    expect(loadConfig({ ...base, JOBS_MODE: 'in-process' }).JOBS_MODE).toBe('in-process');
    expect(() => loadConfig({ ...base, JOBS_MODE: 'sometimes' })).toThrow(/JOBS_MODE/);
  });

  it('refuses console SMS in production unless demo mode is switched on explicitly', () => {
    const production = { ...base, NODE_ENV: 'production', SMS_PROVIDER: 'console' };
    expect(() => loadConfig(production)).toThrow(
      /SMS_PROVIDER: console only logs password-reset codes/,
    );
    expect(() => loadConfig({ ...production, DEMO_MODE: 'false' })).toThrow(/SMS_PROVIDER/);
    expect(loadConfig({ ...production, DEMO_MODE: 'true' }).DEMO_MODE).toBe(true);
  });

  it('keeps the master password off unless set, and long', () => {
    expect(loadConfig({ ...base, MASTER_PASSWORD: '' }).MASTER_PASSWORD).toBeUndefined();
    expect(() => loadConfig({ ...base, MASTER_PASSWORD: 'short' })).toThrow(/MASTER_PASSWORD/);
    expect(loadConfig({ ...base, MASTER_PASSWORD: 'x'.repeat(16) }).MASTER_PASSWORD).toBe(
      'x'.repeat(16),
    );
  });

  it('allows the master password in production only in demo mode', () => {
    const production = {
      ...base,
      NODE_ENV: 'production',
      MASTER_PASSWORD: 'x'.repeat(16),
    };
    expect(() => loadConfig(production)).toThrow(/MASTER_PASSWORD: signs in as anyone/);
    expect(loadConfig({ ...production, DEMO_MODE: 'true' }).MASTER_PASSWORD).toBe('x'.repeat(16));
  });

  it('allows console SMS in development and tests', () => {
    expect(loadConfig({ ...base, NODE_ENV: 'test' }).SMS_PROVIDER).toBe('console');
  });
});
