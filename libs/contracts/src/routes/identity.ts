import { z } from 'zod';
import { DateTime, Id, PhoneE164 } from '../common.js';
import { access, defineRoute, MembershipRole } from '../http.js';

export const OrgKind = z.enum(['fleet', 'dco']);
export type OrgKind = z.infer<typeof OrgKind>;

/** A fleet's display name, as typed when it was created or renamed. */
export const OrgName = z.string().trim().min(2).max(100);

/** The active organization as its staff see it in Settings → General. */
export const OrgProfile = z.object({ id: Id, name: OrgName, kind: OrgKind });
export type OrgProfile = z.infer<typeof OrgProfile>;

export const DevicePlatform = z.enum(['android', 'ios', 'web']);

export const Membership = z.object({
  orgId: Id,
  orgName: z.string(),
  orgKind: OrgKind,
  roles: z.array(MembershipRole),
});
export type Membership = z.infer<typeof Membership>;

export const Session = z.object({
  accessToken: z.string(),
  accessTokenExpiresAt: DateTime,
  refreshToken: z.string(),
  refreshTokenExpiresAt: DateTime,
  user: z.object({ id: Id, phone: PhoneE164, name: z.string().nullable() }),
  /** The org this access token is scoped to; null until the user creates or joins one. */
  activeOrgId: Id.nullable(),
  memberships: z.array(Membership),
});
export type Session = z.infer<typeof Session>;

const RefreshTokenBody = z.object({ refreshToken: z.string().min(20).max(200) });

const OtpCode = z.string().regex(/^\d{6}$/, 'Expected a 6-digit code');
export const Password = z
  .string()
  .min(8, 'Use at least 8 characters')
  .max(128, 'Use at most 128 characters');

/**
 * Proof of a phone number from the OTP provider (phone.email: the access token its
 * sign-in screen returns; the API checks it with phone.email and uses it once).
 */
const VerificationToken = z.string().trim().min(1).max(4096);

/** Which sign-in methods this server offers (set by its environment). */
export const AuthMethods = z.object({
  /** Phone OTP, or null when off. `stub` is a local stand-in for development and tests. */
  phoneOtp: z
    .object({
      provider: z.enum(['phone_email', 'stub']),
      /** phone.email's public client id (null for the stub). */
      clientId: z.string().nullable(),
    })
    .nullable(),
  /** Sign-up must carry a verificationToken for the number being signed up. */
  signupRequiresVerifiedPhone: z.boolean(),
});
export type AuthMethods = z.infer<typeof AuthMethods>;

/** The device a session is for. */
const DeviceFields = {
  deviceId: Id,
  platform: DevicePlatform,
  appVersion: z.string().max(40).optional(),
};

export const identityRoutes = {
  authMethods: defineRoute({
    method: 'GET',
    path: '/auth/methods',
    summary: 'Which sign-in methods this server offers (phone OTP, verified sign-up)',
    tag: 'auth',
    access: access.public,
    response: AuthMethods,
  }),
  phoneOtpCheck: defineRoute({
    method: 'POST',
    path: '/auth/phone-otp/check',
    summary:
      'Whether a number has an account (including invited people who have not signed up), before sending an OTP to log in',
    tag: 'auth',
    access: access.public,
    body: z.object({ phone: PhoneE164 }),
    response: z.object({ exists: z.boolean() }),
  }),
  phoneOtpLogin: defineRoute({
    method: 'POST',
    path: '/auth/phone-otp/login',
    summary:
      'Sign in with a phone verified by OTP (no password). NOT_FOUND when the number has no account; sign up instead',
    tag: 'auth',
    access: access.public,
    body: z.object({
      verificationToken: VerificationToken,
      /** The number the user entered; the verified one must match (PHONE_MISMATCH). */
      phone: PhoneE164.optional(),
      ...DeviceFields,
    }),
    response: Session,
  }),
  resetPasswordVerified: defineRoute({
    method: 'POST',
    path: '/auth/password/reset-verified',
    summary: 'Set a new password for the number verified by OTP; signs out every other session',
    tag: 'auth',
    access: access.public,
    body: z.object({ verificationToken: VerificationToken, password: Password, ...DeviceFields }),
    response: Session,
  }),
  requestOtp: defineRoute({
    method: 'POST',
    path: '/auth/otp/request',
    summary:
      'Send a password-reset code by SMS (in development and demo mode it is printed in the API log)',
    tag: 'auth',
    access: access.public,
    status: 202,
    body: z.object({ phone: PhoneE164 }),
    response: z.object({
      expiresInSeconds: z.number().int(),
      resendAfterSeconds: z.number().int(),
    }),
  }),
  signup: defineRoute({
    method: 'POST',
    path: '/auth/signup',
    summary:
      'Sign up with phone and password. An invited number without a password gets this password and joins its fleet',
    tag: 'auth',
    access: access.public,
    status: 201,
    body: z.object({
      phone: PhoneE164,
      password: Password,
      name: z.string().trim().min(1).max(100).optional(),
      /** OTP proof that the caller owns `phone`; required when the server says so. */
      verificationToken: VerificationToken.optional(),
      ...DeviceFields,
    }),
    response: Session,
  }),
  passwordLogin: defineRoute({
    method: 'POST',
    path: '/auth/password/login',
    summary: 'Sign in with phone and password',
    tag: 'auth',
    access: access.public,
    body: z.object({ phone: PhoneE164, password: z.string().min(1).max(128), ...DeviceFields }),
    response: Session,
  }),
  resetPassword: defineRoute({
    method: 'POST',
    path: '/auth/password/reset',
    summary:
      'Set a new password with a reset code (request one with /auth/otp/request); signs out every other session',
    tag: 'auth',
    access: access.public,
    body: z.object({ phone: PhoneE164, code: OtpCode, password: Password, ...DeviceFields }),
    response: Session,
  }),
  changePassword: defineRoute({
    method: 'POST',
    path: '/me/password',
    summary: 'Set or change your password (the current one is required if you have one)',
    tag: 'auth',
    access: access.user,
    status: 204,
    body: z.object({ currentPassword: z.string().max(128).optional(), newPassword: Password }),
    response: z.void(),
  }),
  refresh: defineRoute({
    method: 'POST',
    path: '/auth/refresh',
    summary: 'Rotate the refresh token and get a new access token',
    tag: 'auth',
    access: access.public,
    body: RefreshTokenBody,
    response: Session,
  }),
  logout: defineRoute({
    method: 'POST',
    path: '/auth/logout',
    summary: 'Revoke the refresh token (and every token rotated from it)',
    tag: 'auth',
    access: access.public,
    status: 204,
    body: RefreshTokenBody,
    response: z.void(),
  }),
  switchOrg: defineRoute({
    method: 'POST',
    path: '/auth/switch-org',
    summary: 'Get a session scoped to another org you belong to',
    tag: 'auth',
    access: access.user,
    body: RefreshTokenBody.extend({ orgId: Id }),
    response: Session,
  }),
  me: defineRoute({
    method: 'GET',
    path: '/me',
    summary: 'The signed-in user and their memberships',
    tag: 'auth',
    access: access.user,
    response: z.object({
      user: z.object({
        id: Id,
        phone: PhoneE164,
        name: z.string().nullable(),
        hasPassword: z.boolean(),
      }),
      activeOrgId: Id.nullable(),
      roles: z.array(MembershipRole),
      memberships: z.array(Membership),
    }),
  }),
  updateMe: defineRoute({
    method: 'PATCH',
    path: '/me',
    summary: 'Update your profile',
    tag: 'auth',
    access: access.user,
    body: z.object({ name: z.string().trim().min(1).max(100) }),
    response: z.object({ id: Id, phone: PhoneE164, name: z.string().nullable() }),
  }),
  requestPhoneChange: defineRoute({
    method: 'POST',
    path: '/me/phone/otp',
    summary:
      'Send a code to a new number before changing yours to it (printed in the API log in development)',
    tag: 'auth',
    access: access.user,
    status: 202,
    body: z.object({ phone: PhoneE164 }),
    response: z.object({
      expiresInSeconds: z.number().int(),
      resendAfterSeconds: z.number().int(),
    }),
  }),
  changePhone: defineRoute({
    method: 'POST',
    path: '/me/phone',
    summary: 'Change your number (your login) to one you proved with the code; CONFLICT if taken',
    tag: 'auth',
    access: access.user,
    body: z.object({ phone: PhoneE164, code: OtpCode }),
    response: z.object({ phone: PhoneE164 }),
  }),
  createOrg: defineRoute({
    method: 'POST',
    path: '/orgs',
    summary: 'Create an organization; you become its owner (and driver, for a DCO)',
    tag: 'auth',
    access: access.user,
    status: 201,
    body: RefreshTokenBody.extend({ name: OrgName, kind: OrgKind }),
    response: Session,
  }),
};

export const MemberStatus = z.enum(['invited', 'active', 'suspended']);

/** Someone with access to the org: owners, managers and drivers. */
export const Member = z.object({
  /** The membership id. */
  id: Id,
  userId: Id,
  name: z.string().nullable(),
  phone: PhoneE164,
  roles: z.array(MembershipRole),
  /**
   * 'invited' until their first sign-in. 'suspended' once their last role was taken
   * away; `roles` then still shows that role, for the record.
   */
  status: MemberStatus,
  createdAt: DateTime,
});
export type Member = z.infer<typeof Member>;

const IdParam = z.object({ id: Id });

export const memberRoutes = {
  listMembers: defineRoute({
    method: 'GET',
    path: '/members',
    summary: 'People with access to the org, with their roles',
    tag: 'members',
    access: access.staff,
    response: z.array(Member),
  }),
  inviteManager: defineRoute({
    method: 'POST',
    path: '/members/managers',
    summary:
      'Give someone manager access by phone (managers run trips, alerts and settlements, but cannot change settings or pay rules)',
    tag: 'members',
    access: access.roles('owner'),
    status: 201,
    body: z.object({ name: z.string().trim().min(1).max(100), phone: PhoneE164 }),
    response: Member,
  }),
  removeManager: defineRoute({
    method: 'DELETE',
    path: '/members/{id}/manager',
    summary:
      'Take away manager access. Other roles (e.g. driver) stay; with none left the member is suspended',
    tag: 'members',
    access: access.roles('owner'),
    params: IdParam,
    response: Member,
  }),
  getOrgProfile: defineRoute({
    method: 'GET',
    path: '/orgs/current',
    summary: 'The active organization: its name and kind',
    tag: 'settings',
    access: access.staff,
    response: OrgProfile,
  }),
  updateOrgProfile: defineRoute({
    method: 'PATCH',
    path: '/orgs/current',
    summary: 'Rename the active organization (owner)',
    tag: 'settings',
    access: access.roles('owner'),
    body: z.object({ name: OrgName }),
    response: OrgProfile,
  }),
};
