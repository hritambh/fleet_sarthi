import type { DocType } from './expiry.js';

/** Whether a form field applies to a document type, and whether it must be filled. */
export type FieldRule = 'required' | 'optional' | 'hidden';

export interface DocFields {
  number: FieldRule;
  validFrom: Exclude<FieldRule, 'required'>;
  expiresOn: FieldRule;
}

/**
 * Which details each document type has. Aadhaar, PAN and the photo never
 * expire; a police verification may or may not carry a date.
 */
export const DOC_FIELDS: Record<DocType, DocFields> = {
  rc: { number: 'required', validFrom: 'optional', expiresOn: 'required' },
  insurance: { number: 'optional', validFrom: 'optional', expiresOn: 'required' },
  permit: { number: 'optional', validFrom: 'optional', expiresOn: 'required' },
  puc: { number: 'optional', validFrom: 'optional', expiresOn: 'required' },
  driving_licence: { number: 'required', validFrom: 'optional', expiresOn: 'required' },
  aadhaar: { number: 'required', validFrom: 'hidden', expiresOn: 'hidden' },
  pan: { number: 'required', validFrom: 'hidden', expiresOn: 'hidden' },
  police_verification: { number: 'optional', validFrom: 'optional', expiresOn: 'optional' },
  badge: { number: 'optional', validFrom: 'optional', expiresOn: 'required' },
  photo: { number: 'hidden', validFrom: 'hidden', expiresOn: 'hidden' },
};

/** The shape each type's number must have once normalised, and what to tell the user. */
const NUMBER_FORMATS: Record<DocType, { pattern: RegExp; message: string } | null> = {
  rc: {
    pattern: /^[A-Z0-9]{6,11}$/,
    message: 'Expected a registration number like MH12AB1234',
  },
  insurance: {
    pattern: /^[A-Z0-9/-]{5,30}$/,
    message: 'Use 5–30 letters, digits, / or -',
  },
  permit: { pattern: /^[A-Z0-9/-]{4,30}$/, message: 'Use 4–30 letters, digits, / or -' },
  puc: { pattern: /^[A-Z0-9/-]{4,30}$/, message: 'Use 4–30 letters, digits, / or -' },
  driving_licence: {
    pattern: /^[A-Z]{2}\d{13}$/,
    message: 'Expected a licence number like MH12 20110012345 (2 letters, 13 digits)',
  },
  aadhaar: {
    pattern: /^[2-9]\d{11}$/,
    message: 'Expected a 12-digit Aadhaar number',
  },
  pan: {
    pattern: /^[A-Z]{5}\d{4}[A-Z]$/,
    message: 'Expected a PAN like ABCDE1234F',
  },
  police_verification: {
    pattern: /^[A-Z0-9/-]{3,30}$/,
    message: 'Use 3–30 letters, digits, / or -',
  },
  badge: { pattern: /^[A-Z0-9]{3,20}$/, message: 'Use 3–20 letters and digits' },
  photo: null,
};

/**
 * The number as stored: uppercase, without spaces. Identity and licence numbers
 * also lose their dashes ("MH-12 2011 0012345" → "MH1220110012345"); policy and
 * permit numbers keep them, as they are part of the number.
 */
export function normaliseDocNumber(docType: DocType, raw: string): string {
  const upper = raw.toUpperCase().replace(/\s+/g, '');
  return ['rc', 'driving_licence', 'aadhaar', 'pan', 'badge'].includes(docType)
    ? upper.replace(/-/g, '')
    : upper;
}

// Verhoeff tables (UIDAI uses this check digit for Aadhaar).
const D = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
  [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
  [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
  [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
  [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
  [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
  [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
  [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
  [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
];
const P = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
  [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
  [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
  [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
  [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
  [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
  [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
];

/** A table cell; -1 (never a match) outside the table. */
const cell = (table: number[][], row: number, col: number): number => table[row]?.[col] ?? -1;

/** Whether a string of digits ends in a valid Verhoeff check digit. */
export function verhoeffValid(digits: string): boolean {
  let c = 0;
  const n = digits.length;
  for (let i = 0; i < n; i++) {
    const digit = digits.charCodeAt(n - 1 - i) - 48;
    c = cell(D, c, cell(P, i % 8, digit));
  }
  return c === 0;
}

/**
 * What is wrong with a normalised number for this type, or null when it is fine.
 * An empty number is fine unless the type requires one.
 */
export function checkDocNumber(docType: DocType, number: string): string | null {
  const rule = DOC_FIELDS[docType].number;
  if (number === '') return rule === 'required' ? 'This document needs its number' : null;
  if (rule === 'hidden') return 'This document has no number';
  const format = NUMBER_FORMATS[docType];
  if (format && !format.pattern.test(number)) return format.message;
  if (docType === 'aadhaar' && !verhoeffValid(number)) {
    return 'This is not a valid Aadhaar number; check the digits';
  }
  return null;
}
