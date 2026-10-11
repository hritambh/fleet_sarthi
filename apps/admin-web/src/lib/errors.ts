import { ErrorBody, ErrorCode } from '@taxcy/contracts';
import { z } from 'zod';
import { i18n } from '../i18n/index.js';
import { fmtRegistration } from './format.js';

/** An API failure carrying the server's error envelope (code + English message). */
export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
    readonly details?: unknown,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export function toApiError(status: number, body: unknown): ApiError {
  const parsed = ErrorBody.safeParse(body);
  if (parsed.success) {
    const { code, message, details } = parsed.data.error;
    return new ApiError(status, code, message, details);
  }
  return new ApiError(
    status,
    status >= 500 ? 'INTERNAL' : 'UNKNOWN',
    `Request failed (${String(status)})`,
  );
}

const DriverNotLinkedDetails = z.object({ driverName: z.string(), registrationNo: z.string() });
const LinkInUseDetails = z.object({ tripIds: z.array(z.string()) });

/** A more specific message for codes whose details name what went wrong, when present. */
function detailedMessage(code: ErrorCode, details: unknown): string | null {
  if (code === 'DRIVER_NOT_LINKED') {
    const parsed = DriverNotLinkedDetails.safeParse(details);
    if (parsed.success)
      return i18n.t('errors.detailed.driverNotLinked', {
        driver: parsed.data.driverName,
        vehicle: fmtRegistration(parsed.data.registrationNo),
      });
  }
  if (code === 'LINK_IN_USE') {
    const parsed = LinkInUseDetails.safeParse(details);
    if (parsed.success && parsed.data.tripIds.length > 0)
      return i18n.t('errors.detailed.linkInUse', { count: parsed.data.tripIds.length });
  }
  return null;
}

/**
 * What to tell the user about a failure, in their language: API errors by their stable
 * code (the server's English message is the fallback for a code we don't know).
 */
export function errorMessage(error: unknown): string {
  if (error instanceof ApiError) {
    const code = ErrorCode.safeParse(error.code);
    if (code.success)
      return detailedMessage(code.data, error.details) ?? i18n.t(`errors.${code.data}`);
    if (error.code === 'UNKNOWN') return i18n.t('errors.requestFailed', { status: error.status });
    return error.message;
  }
  // fetch rejects with a TypeError when the server can't be reached; browsers word it differently.
  if (error instanceof TypeError && /fetch|network|load failed/i.test(error.message))
    return i18n.t('errors.network');
  if (error instanceof Error && error.message) return error.message;
  return i18n.t('errors.generic');
}
