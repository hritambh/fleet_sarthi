import { describe, expect, it } from 'vitest';
import { failureReason } from './health.controller.js';

describe('failureReason', () => {
  it('names an S3 error with its HTTP status', () => {
    const error = Object.assign(new Error('nope'), {
      name: 'InvalidAccessKeyId',
      $metadata: { httpStatusCode: 403 },
    });
    expect(failureReason(error)).toBe('InvalidAccessKeyId (403)');
  });

  it('uses a network error code', () => {
    const error = Object.assign(new Error('getaddrinfo ENOTFOUND s3.example'), {
      code: 'ENOTFOUND',
    });
    expect(failureReason(error)).toBe('ENOTFOUND');
  });

  it('never repeats the message', () => {
    expect(failureReason(new Error('secret=abc'))).toBe('Error');
    expect(failureReason('weird')).toBe('unknown');
  });
});
