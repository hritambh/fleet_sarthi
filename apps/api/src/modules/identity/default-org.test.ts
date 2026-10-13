import type { Membership } from '@taxcy/contracts';
import { describe, expect, it } from 'vitest';
import { defaultOrgId } from './session.service.js';

const member = (orgId: string, roles: Membership['roles']): Membership => ({
  orgId,
  orgName: orgId,
  orgKind: 'fleet',
  roles,
});

describe('defaultOrgId', () => {
  it('opens a fleet the user owns before an older one they drive for', () => {
    expect(defaultOrgId([member('b', ['driver']), member('a', ['owner'])])).toBe('a');
  });

  it('counts managing a fleet like owning it', () => {
    expect(defaultOrgId([member('b', ['driver']), member('a', ['manager'])])).toBe('a');
  });

  it('falls back to the oldest membership for drivers only', () => {
    expect(defaultOrgId([member('b', ['driver']), member('c', ['driver'])])).toBe('b');
  });

  it('is null without memberships', () => {
    expect(defaultOrgId([])).toBeNull();
  });
});
