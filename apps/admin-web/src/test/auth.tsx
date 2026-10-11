import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { render } from '@testing-library/react';
import type { ReactElement } from 'react';
import { vi, type Mock } from 'vitest';
import { AuthContext, type AuthState } from '../auth/context.js';

/** AuthState with every call a mock, so tests can assert on them. */
export type FakeAuth = {
  [K in keyof AuthState]: AuthState[K] extends (...args: infer A) => infer R
    ? Mock<(...args: A) => R>
    : AuthState[K];
};

/** A signed-out AuthState whose calls are mocks (override the ones a test cares about). */
export function fakeAuth(overrides: Partial<AuthState> = {}): FakeAuth {
  // Every call below is a vi.fn(), and overrides are too.
  return {
    status: 'signed_out',
    session: null,
    activeMembership: null,
    isStaff: false,
    isOwner: false,
    passwordLogin: vi.fn().mockResolvedValue(undefined),
    signup: vi.fn().mockResolvedValue(undefined),
    requestOtp: vi.fn().mockResolvedValue({ expiresInSeconds: 300, resendAfterSeconds: 30 }),
    resetPassword: vi.fn().mockResolvedValue(undefined),
    createOrg: vi.fn(),
    switchOrg: vi.fn(),
    logout: vi.fn(),
    ...overrides,
  } as FakeAuth;
}

/** Renders inside a fresh query client and the given auth. */
export function renderWithAuth(ui: ReactElement, auth: FakeAuth = fakeAuth()): FakeAuth {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  render(
    <QueryClientProvider client={client}>
      <AuthContext.Provider value={auth}>{ui}</AuthContext.Provider>
    </QueryClientProvider>,
  );
  return auth;
}
