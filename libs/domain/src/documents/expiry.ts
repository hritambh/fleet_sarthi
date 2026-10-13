import type { AlertText } from '../messages.js';

export type DocType =
  | 'rc'
  | 'insurance'
  | 'permit'
  | 'puc'
  | 'driving_licence'
  | 'aadhaar'
  | 'pan'
  | 'police_verification'
  | 'badge'
  | 'photo';

/** Documents that belong to a vehicle; every other type belongs to a driver. */
export const VEHICLE_DOC_TYPES = ['rc', 'insurance', 'permit', 'puc'] as const satisfies DocType[];
export const DRIVER_DOC_TYPES = [
  'driving_licence',
  'aadhaar',
  'pan',
  'police_verification',
  'badge',
  'photo',
] as const satisfies DocType[];
/** Types with no expiry date (an expiry is optional for them). */
export const NON_EXPIRING_DOC_TYPES = ['aadhaar', 'pan', 'photo'] as const satisfies DocType[];

export function isVehicleDocType(t: DocType): boolean {
  return (VEHICLE_DOC_TYPES as readonly DocType[]).includes(t);
}

export function expiryRequired(t: DocType): boolean {
  return !(NON_EXPIRING_DOC_TYPES as readonly DocType[]).includes(t);
}
export type ExpiryBucket = 'expired' | number;

const DAY_MS = 86_400_000;

/** Whole days from `today` to `expiresOn` (both IST calendar dates, YYYY-MM-DD). */
export function daysUntil(expiresOn: string, today: string): number {
  return Math.round(
    (Date.parse(`${expiresOn}T00:00:00Z`) - Date.parse(`${today}T00:00:00Z`)) / DAY_MS,
  );
}

/**
 * Which alert a document is due for today: the tightest threshold it's within
 * (e.g. 7 when 3–7 days remain with thresholds 30/7/1), 'expired' once past the
 * expiry date, or null when no threshold applies yet. A document is still valid on
 * its expiry date (0 days left counts as the last-day bucket).
 */
export function expiryBucket(
  expiresOn: string,
  today: string,
  thresholds: readonly number[],
): ExpiryBucket | null {
  const daysLeft = daysUntil(expiresOn, today);
  if (daysLeft < 0) return 'expired';
  const within = [...thresholds].sort((a, b) => a - b).find((t) => daysLeft <= t);
  return within ?? null;
}

export function expirySeverity(bucket: ExpiryBucket): 'info' | 'warning' | 'critical' {
  if (bucket === 'expired' || bucket <= 1) return 'critical';
  return bucket <= 7 ? 'warning' : 'info';
}

const DOC_NAMES: Record<DocType, string> = {
  rc: 'Registration certificate (RC)',
  insurance: 'Insurance',
  permit: 'Permit',
  puc: 'Pollution certificate (PUC)',
  driving_licence: 'Driving licence',
  aadhaar: 'Aadhaar card',
  pan: 'PAN card',
  police_verification: 'Police verification',
  badge: 'Badge / PSV licence',
  photo: 'Photo',
};

/** The owner's alert when a driver adds or renews one of their documents. */
export function explainSubmission(input: {
  docType: DocType;
  driverName: string;
  renewal: boolean;
}): AlertText {
  const name = DOC_NAMES[input.docType];
  const verb = input.renewal ? 'renewed' : 'added';
  return {
    title: `${input.driverName} ${verb} their ${name}`,
    explanation: `${input.driverName} uploaded a ${input.renewal ? 'renewed ' : ''}${name}. Check it and approve or reject it on their Documents tab.`,
    message: {
      key: 'document_submitted',
      params: { docType: input.docType, driverName: input.driverName, renewal: input.renewal },
    },
  };
}

export function explainExpiry(input: {
  docType: DocType;
  /** e.g. "MH12 AB 1234" or "Ramesh Kumar". */
  subject: string;
  subjectKind: 'vehicle' | 'driver';
  expiresOn: string;
  today: string;
}): AlertText {
  const name = DOC_NAMES[input.docType];
  const days = daysUntil(input.expiresOn, input.today);
  const params = {
    docType: input.docType,
    subjectKind: input.subjectKind,
    subject: input.subject,
    expiresOn: input.expiresOn,
    daysLeft: days,
  };
  const date = new Date(`${input.expiresOn}T00:00:00Z`).toLocaleDateString('en-IN', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
    timeZone: 'UTC',
  });
  if (days < 0) {
    return {
      title: `${name} for ${input.subject} has expired`,
      explanation: `${name} for ${input.subject} expired on ${date}. Operating without it risks fines and insurance claims being rejected. Renew it and upload the new copy.`,
      message: { key: 'document_expired', params },
    };
  }
  const when = days === 0 ? 'today' : days === 1 ? 'tomorrow' : `in ${days} days`;
  return {
    title: `${name} for ${input.subject} expires ${when}`,
    explanation: `${name} for ${input.subject} expires on ${date}. Renew it and upload the new copy before then.`,
    message: { key: 'document_expiring', params },
  };
}
