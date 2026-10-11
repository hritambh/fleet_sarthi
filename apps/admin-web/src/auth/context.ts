import { createContext, useContext } from 'react';
import type { Membership, Session } from '../lib/api-types.js';

export type AuthStatus = 'restoring' | 'signed_out' | 'signed_in';

export interface AuthState {
  status: AuthStatus;
  session: Session | null;
  /** The membership for the session's active org, if any. */
  activeMembership: Membership | null;
  isStaff: boolean;
  isOwner: boolean;
  passwordLogin(phone: string, password: string): Promise<void>;
  signup(input: { phone: string; password: string; name?: string }): Promise<void>;
  /** Sends a password-reset code (locally / in demo mode it is printed in the API log). */
  requestOtp(phone: string): Promise<{ expiresInSeconds: number; resendAfterSeconds: number }>;
  resetPassword(input: { phone: string; code: string; password: string }): Promise<void>;
  createOrg(name: string, kind: 'fleet' | 'dco'): Promise<void>;
  switchOrg(orgId: string): Promise<void>;
  logout(): Promise<void>;
}

export const AuthContext = createContext<AuthState | null>(null);

export function useAuth(): AuthState {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used inside <AuthProvider>');
  return context;
}
