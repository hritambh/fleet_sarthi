import type { ErrorCode } from '@taxcy/contracts';

const DEFAULT_STATUS: Record<ErrorCode, number> = {
  VALIDATION_FAILED: 400,
  UNAUTHENTICATED: 401,
  TOKEN_EXPIRED: 401,
  OTP_INVALID: 401,
  OTP_EXPIRED: 401,
  INVALID_CREDENTIALS: 401,
  ACCOUNT_EXISTS: 409,
  PHONE_OTP_DISABLED: 403,
  PHONE_NOT_VERIFIED: 401,
  PHONE_MISMATCH: 422,
  PHONE_VERIFICATION_REQUIRED: 422,
  FORBIDDEN_ROLE: 403,
  NO_ACTIVE_ORG: 403,
  NOT_FOUND: 404,
  ILLEGAL_TRANSITION: 409,
  TRIP_CANCELLED: 409,
  TRIP_REASSIGNED: 409,
  VEHICLE_BUSY: 409,
  DRIVER_BUSY: 409,
  DRIVER_INACTIVE: 403,
  DRIVER_HAS_TRIPS: 409,
  DRIVER_ON_TRIP: 409,
  VEHICLE_ON_TRIP: 409,
  DRIVER_NOT_LINKED: 409,
  LINK_IN_USE: 409,
  CANCELLATION_PENDING: 409,
  DRIVER_TRIPS_DISABLED: 403,
  DRIVER_CHARGES_DISABLED: 403,
  RECEIPT_REQUIRED: 422,
  ALREADY_SETTLED: 409,
  IDEMPOTENCY_CONFLICT: 409,
  VERSION_CONFLICT: 409,
  CONFLICT: 409,
  IDEMPOTENCY_KEY_REQUIRED: 400,
  FUEL_TYPE_MISMATCH: 422,
  ODOMETER_BEFORE_START: 422,
  UPLOAD_NOT_FOUND: 422,
  UPLOAD_MISMATCH: 422,
  STORAGE_UNAVAILABLE: 503,
  CATALOG_UNAVAILABLE: 503,
  RATE_LIMITED: 429,
  INTERNAL: 500,
};

/** An expected, client-facing failure. Rendered as the standard error envelope. */
export class AppError extends Error {
  readonly status: number;

  constructor(
    readonly code: ErrorCode,
    message: string,
    readonly details?: unknown,
    status?: number,
  ) {
    super(message);
    this.name = 'AppError';
    this.status = status ?? DEFAULT_STATUS[code];
  }
}

export const notFound = (what: string): AppError => new AppError('NOT_FOUND', `${what} not found`);
