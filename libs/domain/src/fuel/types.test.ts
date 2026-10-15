import { describe, expect, it } from 'vitest';
import { allowedFuels, hasFuelAudit, trackFor } from './types.js';

describe('electric vehicles', () => {
  it('take no fuel fills and have no fuel audit', () => {
    expect(allowedFuels('ev')).toEqual([]);
    expect(hasFuelAudit('ev')).toBe(false);
  });

  it('leave every other vehicle audited as before', () => {
    for (const fuel of ['petrol', 'diesel', 'cng', 'petrol_cng'] as const) {
      expect(hasFuelAudit(fuel)).toBe(true);
    }
    expect(trackFor('petrol_cng')).toBe('bifuel_cost');
    expect(allowedFuels('petrol_cng')).toEqual(['petrol', 'cng']);
    expect(allowedFuels('cng')).toEqual(['cng']);
  });
});
