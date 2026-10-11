import { describe, expect, it } from 'vitest';
import { redisConnection } from './job-runner.js';

describe('redisConnection', () => {
  it('reads host and port from a plain local URL', () => {
    expect(redisConnection('redis://localhost:6380')).toEqual({
      host: 'localhost',
      port: 6380,
      maxRetriesPerRequest: null,
    });
  });

  it('keeps credentials, the database number and TLS for hosted Redis', () => {
    expect(redisConnection('rediss://default:p%40ss@redis.example.com:6380/2')).toEqual({
      host: 'redis.example.com',
      port: 6380,
      username: 'default',
      password: 'p@ss',
      db: 2,
      tls: {},
      maxRetriesPerRequest: null,
    });
  });

  it('defaults the port to 6379', () => {
    expect(redisConnection('redis://red-abc123')).toMatchObject({ port: 6379 });
  });
});
