import { z } from 'zod';

export const ErrorCode = z.enum([
  'VALIDATION_FAILED',
  'UNAUTHENTICATED',
  'TOKEN_EXPIRED',
  'FORBIDDEN_ROLE',
  'NO_ACTIVE_ORG',
  'NOT_FOUND',
  'ILLEGAL_TRANSITION',
  'TRIP_CANCELLED',
  'TRIP_REASSIGNED',
  'VEHICLE_BUSY',
  'DRIVER_BUSY',
  /** Starting a trip while the driver already has one on the road (details.tripId, route). */
  'DRIVER_ON_TRIP',
  /** Starting a trip in a vehicle that's already on the road (details.tripId, route). */
  'VEHICLE_ON_TRIP',
  /** Pairing a driver with a vehicle they aren't linked to (details.vehicleId, driverId). */
  'DRIVER_NOT_LINKED',
  /** Unlinking a driver from a vehicle they have assigned or running trips in (details.tripIds). */
  'LINK_IN_USE',
  'CANCELLATION_PENDING',
  'ALREADY_SETTLED',
  'IDEMPOTENCY_CONFLICT',
  'IDEMPOTENCY_KEY_REQUIRED',
  'VERSION_CONFLICT',
  'CONFLICT',
  'FUEL_TYPE_MISMATCH',
  'ODOMETER_BEFORE_START',
  'OTP_INVALID',
  'OTP_EXPIRED',
  /** Wrong phone or password (deliberately doesn't say which). */
  'INVALID_CREDENTIALS',
  /** Signing up a phone that already has a password: log in or reset it instead. */
  'ACCOUNT_EXISTS',
  /** Phone OTP (PHONE_OTP_PROVIDER) is switched off on this server. */
  'PHONE_OTP_DISABLED',
  /** The phone verification token was rejected, expired or already used. */
  'PHONE_NOT_VERIFIED',
  /** The verified number isn't the one entered (details.verifiedPhone). */
  'PHONE_MISMATCH',
  /** Sign-up needs a verified number on this server (SIGNUP_REQUIRES_VERIFIED_PHONE). */
  'PHONE_VERIFICATION_REQUIRED',
  'RATE_LIMITED',
  'UPLOAD_NOT_FOUND',
  'UPLOAD_MISMATCH',
  'INTERNAL',
]);
export type ErrorCode = z.infer<typeof ErrorCode>;

export const ErrorBody = z.object({
  error: z.object({
    code: ErrorCode,
    message: z.string(),
    details: z.unknown().optional(),
    requestId: z.string().optional(),
  }),
});
export type ErrorBody = z.infer<typeof ErrorBody>;
