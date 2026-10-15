import { z } from 'zod';
import { CalendarDate, DateTime, Id, Paise, PhoneE164 } from '../common.js';
import { access, defineRoute } from '../http.js';

export const FuelType = z.enum(['petrol', 'diesel', 'cng', 'petrol_cng', 'ev']);
export type FuelType = z.infer<typeof FuelType>;

/** Indian registration numbers, stored without spaces or dashes: "MH 12 AB 1234" → "MH12AB1234". */
export const RegistrationNo = z
  .string()
  .transform((v) => v.toUpperCase().replace(/[\s-]/g, ''))
  .pipe(z.string().regex(/^[A-Z0-9]{6,11}$/, 'Expected a registration number like MH12AB1234'));

const ActiveStatus = z.enum(['active', 'inactive']);

export const Vehicle = z.object({
  id: Id,
  registrationNo: z.string(),
  make: z.string(),
  model: z.string(),
  year: z.number().int().nullable(),
  fuelType: FuelType,
  vehicleModelId: Id.nullable(),
  lastOdometerKm: z.number().int().nullable(),
  status: ActiveStatus,
  /** Drivers who may drive this vehicle; trips can only pair it with one of them. */
  drivers: z.array(z.object({ id: Id, name: z.string() })),
  createdAt: DateTime,
});
export type Vehicle = z.infer<typeof Vehicle>;

export const VehicleModel = z.object({
  id: Id,
  make: z.string(),
  model: z.string(),
  fuelType: FuelType,
});

/**
 * A brand in the public vehicle catalogue. The id is the upstream provider's own
 * identifier, opaque to the client, and is what `/vehicle-catalog/models` takes.
 */
export const CatalogBrand = z.object({ id: z.string(), name: z.string() });
export type CatalogBrand = z.infer<typeof CatalogBrand>;

export const CatalogModel = z.object({ name: z.string() });
export type CatalogModel = z.infer<typeof CatalogModel>;

const VehicleInput = z.object({
  registrationNo: RegistrationNo,
  make: z.string().trim().min(1).max(50),
  model: z.string().trim().min(1).max(50),
  year: z.number().int().min(1990).max(2100).optional(),
  fuelType: FuelType,
  vehicleModelId: Id.optional(),
  lastOdometerKm: z.number().int().nonnegative().optional(),
});

const IdList = z
  .array(Id)
  .max(200)
  .refine((ids) => new Set(ids).size === ids.length, 'Each id may appear only once');

export const PayRule = z.intersection(
  z.discriminatedUnion('kind', [
    z.object({ kind: z.literal('none') }),
    z.object({
      kind: z.literal('percent_of_fare'),
      percent: z.number().min(0).max(100),
      base: z.enum(['quoted', 'expected']),
    }),
    z.object({ kind: z.literal('per_trip'), amountPaise: Paise }),
    z.object({ kind: z.literal('per_km'), paisePerKm: z.number().int().nonnegative() }),
    z.object({ kind: z.literal('fixed_daily'), amountPaise: Paise }),
  ]),
  z.object({ allowanceToDriver: z.boolean() }),
);
export type PayRule = z.infer<typeof PayRule>;

export const Driver = z.object({
  id: Id,
  userId: Id,
  name: z.string(),
  phone: PhoneE164,
  status: ActiveStatus,
  /** 'invited' until the driver signs in for the first time. */
  membershipStatus: z.enum(['invited', 'active', 'suspended']),
  /** Overrides the org's default pay rule; null uses the default. */
  payRule: PayRule.nullable(),
  /** Vehicles this driver may drive. */
  vehicles: z.array(z.object({ id: Id, registrationNo: z.string() })),
  /** Profile, editable by the driver and the owner. The photo is an uploaded image. */
  photoMediaId: Id.nullable(),
  dateOfBirth: CalendarDate.nullable(),
  email: z.string().nullable(),
  address: z.string().nullable(),
  emergencyContactName: z.string().nullable(),
  emergencyContactPhone: z.string().nullable(),
  createdAt: DateTime,
});
export type Driver = z.infer<typeof Driver>;

/** A driver's profile changes; null clears a field. */
export const DriverProfile = z.object({
  name: z.string().trim().min(1).max(100).optional(),
  photoMediaId: Id.nullable().optional(),
  dateOfBirth: CalendarDate.nullable().optional(),
  email: z.email().max(200).nullable().optional(),
  address: z.string().trim().max(300).nullable().optional(),
  emergencyContactName: z.string().trim().max(100).nullable().optional(),
  emergencyContactPhone: PhoneE164.nullable().optional(),
});
export type DriverProfile = z.infer<typeof DriverProfile>;

export const VehicleDocType = z.enum(['rc', 'insurance', 'permit', 'puc']);
export const DriverDocType = z.enum([
  'driving_licence',
  'aadhaar',
  'pan',
  'police_verification',
  'badge',
  'photo',
]);
export const DocType = z.enum([...VehicleDocType.options, ...DriverDocType.options]);
export type DocType = z.infer<typeof DocType>;

/** Most files one document holds. */
export const MAX_DOCUMENT_FILES = 10;

export const DocumentFile = z.object({ mediaId: Id, contentType: z.string() });
export type DocumentFile = z.infer<typeof DocumentFile>;

export const Document = z.object({
  id: Id,
  docType: DocType,
  vehicleId: Id.nullable(),
  driverId: Id.nullable(),
  number: z.string().nullable(),
  validFrom: CalendarDate.nullable(),
  /** Null for documents that don't expire (Aadhaar, PAN, photo). */
  expiresOn: CalendarDate.nullable(),
  /** The first file (older clients); every file is in `files`. */
  mediaId: Id.nullable(),
  /** The first file's type ("image/jpeg", "application/pdf", …). */
  mediaContentType: z.string().nullable(),
  /** Every file (photos and PDFs), in the order they were added. */
  files: z.array(DocumentFile),
  supersededBy: Id.nullable(),
  /** Days until expiry in IST; negative once expired; null without an expiry. */
  daysLeft: z.number().int().nullable(),
  status: z.enum(['valid', 'expiring', 'expired', 'superseded']),
  /** A driver's upload is 'pending' until the owner approves or rejects it. */
  reviewStatus: z.enum(['pending', 'approved', 'rejected']),
  /** Why the owner rejected it. */
  reviewNote: z.string().nullable(),
  /** Uploaded by the driver from their app (rather than by the owner or a manager). */
  submittedByDriver: z.boolean(),
  /** A pending renewal: the document it replaces once approved. */
  replacesId: Id.nullable(),
  createdAt: DateTime,
});
export type Document = z.infer<typeof Document>;

const DocumentDetails = z.object({
  number: z.string().trim().max(50).optional(),
  validFrom: CalendarDate.optional(),
  /** Required except for types that don't expire (Aadhaar, PAN, photo). */
  expiresOn: CalendarDate.optional(),
  /** One file (older clients). Use mediaIds for several. */
  mediaId: Id.optional(),
  /** The document's files in order: uploaded photos or PDFs (kind "document"). */
  mediaIds: z.array(Id).max(MAX_DOCUMENT_FILES).optional(),
});

export const AuditSettings = z.object({
  fuelKSigma: z.number().min(0.5).max(5),
  fuelMinCycles: z.number().int().min(1).max(20),
  fuelPctThreshold: z.number().min(1).max(80),
  fuelEwmaAlpha: z.number().min(0.05).max(0.9),
  odoGpsTolerancePct: z.number().min(1).max(50),
  docAlertDays: z.array(z.number().int().min(0).max(365)).min(1).max(5),
});
export type AuditSettings = z.infer<typeof AuditSettings>;

const IdParam = z.object({ id: Id });

export const fleetRoutes = {
  listVehicles: defineRoute({
    method: 'GET',
    path: '/vehicles',
    summary: "Vehicles in the org (for a driver: only the vehicles they're linked to)",
    tag: 'fleet',
    access: access.anyMember,
    query: z.object({ status: ActiveStatus.optional() }),
    response: z.array(Vehicle),
  }),
  createVehicle: defineRoute({
    method: 'POST',
    path: '/vehicles',
    summary:
      'Add a vehicle, optionally with the drivers who may drive it (in an owner-driver org, the owner is always linked)',
    tag: 'fleet',
    access: access.staff,
    status: 201,
    body: VehicleInput.extend({ driverIds: IdList.optional() }),
    response: Vehicle,
  }),
  getVehicle: defineRoute({
    method: 'GET',
    path: '/vehicles/{id}',
    summary: 'A vehicle',
    tag: 'fleet',
    access: access.anyMember,
    params: IdParam,
    response: Vehicle,
  }),
  updateVehicle: defineRoute({
    method: 'PATCH',
    path: '/vehicles/{id}',
    summary: 'Update a vehicle',
    tag: 'fleet',
    access: access.staff,
    params: IdParam,
    body: VehicleInput.partial().extend({ status: ActiveStatus.optional() }),
    response: Vehicle,
  }),
  setVehicleDrivers: defineRoute({
    method: 'PUT',
    path: '/vehicles/{id}/drivers',
    summary:
      "Set the drivers who may drive a vehicle. A driver with an assigned or running trip in it can't be removed",
    tag: 'fleet',
    access: access.staff,
    params: IdParam,
    body: z.object({ driverIds: IdList }),
    response: Vehicle,
  }),
  listVehicleModels: defineRoute({
    method: 'GET',
    path: '/vehicle-models',
    summary: 'Known vehicle models (used to seed fuel baselines)',
    tag: 'fleet',
    access: access.anyMember,
    response: z.array(VehicleModel),
  }),
  listCatalogBrands: defineRoute({
    method: 'GET',
    path: '/vehicle-catalog/brands',
    summary: 'Vehicle brands from the public vehicle catalogue, for the add-vehicle form',
    tag: 'fleet',
    access: access.anyMember,
    response: z.array(CatalogBrand),
  }),
  listCatalogModels: defineRoute({
    method: 'GET',
    path: '/vehicle-catalog/models',
    summary: 'Models of one catalogue brand',
    tag: 'fleet',
    access: access.anyMember,
    query: z.object({ brand: z.string().min(1).max(64) }),
    response: z.array(CatalogModel),
  }),
  listDrivers: defineRoute({
    method: 'GET',
    path: '/drivers',
    summary: 'Drivers in the org',
    tag: 'fleet',
    access: access.staff,
    query: z.object({ status: ActiveStatus.optional() }),
    response: z.array(Driver),
  }),
  inviteDriver: defineRoute({
    method: 'POST',
    path: '/drivers',
    summary:
      'Invite a driver by phone, optionally with the vehicles they may drive; they sign in to the app with that number',
    tag: 'fleet',
    access: access.staff,
    status: 201,
    body: z.object({
      name: z.string().trim().min(1).max(100),
      phone: PhoneE164,
      vehicleIds: IdList.optional(),
    }),
    response: Driver,
  }),
  getDriver: defineRoute({
    method: 'GET',
    path: '/drivers/{id}',
    summary: 'A driver',
    tag: 'fleet',
    access: access.staff,
    params: IdParam,
    response: Driver,
  }),
  updateDriver: defineRoute({
    method: 'PATCH',
    path: '/drivers/{id}',
    summary:
      'Update a driver. Marking them inactive is refused while they are on a trip (DRIVER_ON_TRIP) ' +
      'or have assigned trips (DRIVER_HAS_TRIPS, listing them); unassignTrips unassigns those first',
    tag: 'fleet',
    access: access.staff,
    params: IdParam,
    body: DriverProfile.extend({
      status: ActiveStatus.optional(),
      /** With status 'inactive': unassign the driver's assigned trips (back to unassigned) first. */
      unassignTrips: z.boolean().optional(),
    }),
    response: Driver,
  }),
  setDriverVehicles: defineRoute({
    method: 'PUT',
    path: '/drivers/{id}/vehicles',
    summary:
      "Set the vehicles a driver may drive. A vehicle they have an assigned or running trip in can't be removed",
    tag: 'fleet',
    access: access.staff,
    params: IdParam,
    body: z.object({ vehicleIds: IdList }),
    response: Driver,
  }),
  setDriverPayRule: defineRoute({
    method: 'PUT',
    path: '/drivers/{id}/pay-rule',
    summary: "Override a driver's pay rule (null = use the org default)",
    tag: 'fleet',
    access: access.roles('owner'),
    params: IdParam,
    body: z.object({ payRule: PayRule.nullable() }),
    response: Driver,
  }),
  listDocuments: defineRoute({
    method: 'GET',
    path: '/documents',
    summary: 'Current documents (renewed ones are hidden unless includeSuperseded)',
    tag: 'fleet',
    access: access.staff,
    query: z.object({
      vehicleId: Id.optional(),
      driverId: Id.optional(),
      expiringWithinDays: z.coerce.number().int().min(0).max(365).optional(),
      includeSuperseded: z.stringbool().optional(),
    }),
    response: z.array(Document),
  }),
  createDocument: defineRoute({
    method: 'POST',
    path: '/documents',
    summary: 'Add a document to a vehicle (RC, insurance, permit, PUC) or a driver (licence)',
    tag: 'fleet',
    access: access.staff,
    status: 201,
    body: DocumentDetails.extend({
      docType: DocType,
      vehicleId: Id.optional(),
      driverId: Id.optional(),
    }),
    response: Document,
  }),
  renewDocument: defineRoute({
    method: 'POST',
    path: '/documents/{id}/renew',
    summary: 'Replace a document with its renewed copy (keeps history, clears its alerts)',
    tag: 'fleet',
    access: access.staff,
    status: 201,
    params: IdParam,
    body: DocumentDetails,
    response: Document,
  }),
  approveDocument: defineRoute({
    method: 'POST',
    path: '/documents/{id}/approve',
    summary: "Approve a driver's upload (a renewal then replaces the old copy)",
    tag: 'fleet',
    access: access.staff,
    params: IdParam,
    response: Document,
  }),
  rejectDocument: defineRoute({
    method: 'POST',
    path: '/documents/{id}/reject',
    summary: "Reject a driver's upload, with the reason they'll see",
    tag: 'fleet',
    access: access.staff,
    params: IdParam,
    body: z.object({ note: z.string().trim().min(1).max(300) }),
    response: Document,
  }),
  myDriver: defineRoute({
    method: 'GET',
    path: '/me/driver',
    summary: "The signed-in driver's own profile in this fleet",
    tag: 'fleet',
    access: access.roles('driver'),
    response: Driver,
  }),
  updateMyDriver: defineRoute({
    method: 'PATCH',
    path: '/me/driver',
    summary: 'Update your own driver profile (name, photo, date of birth, contact details)',
    tag: 'fleet',
    access: access.roles('driver'),
    body: DriverProfile,
    response: Driver,
  }),
  myDocuments: defineRoute({
    method: 'GET',
    path: '/me/documents',
    summary: "The signed-in driver's current documents, including ones waiting for approval",
    tag: 'fleet',
    access: access.roles('driver'),
    response: z.array(Document),
  }),
  submitMyDocument: defineRoute({
    method: 'POST',
    path: '/me/documents',
    summary: 'Add one of your documents; the owner approves it before it counts',
    tag: 'fleet',
    access: access.roles('driver'),
    status: 201,
    body: DocumentDetails.extend({ docType: DriverDocType }),
    response: Document,
  }),
  renewMyDocument: defineRoute({
    method: 'POST',
    path: '/me/documents/{id}/renew',
    summary:
      'Upload a renewed copy of one of your documents; it replaces the old one once approved',
    tag: 'fleet',
    access: access.roles('driver'),
    status: 201,
    params: IdParam,
    body: DocumentDetails,
    response: Document,
  }),
  getAuditSettings: defineRoute({
    method: 'GET',
    path: '/settings/audit',
    summary: 'Fuel and distance audit thresholds',
    tag: 'settings',
    access: access.staff,
    response: AuditSettings,
  }),
  updateAuditSettings: defineRoute({
    method: 'PATCH',
    path: '/settings/audit',
    summary: 'Change audit thresholds',
    tag: 'settings',
    access: access.roles('owner'),
    body: AuditSettings.partial(),
    response: AuditSettings,
  }),
  getDriverPay: defineRoute({
    method: 'GET',
    path: '/settings/driver-pay',
    summary: 'Default driver pay rule',
    tag: 'settings',
    access: access.staff,
    response: PayRule,
  }),
  updateDriverPay: defineRoute({
    method: 'PUT',
    path: '/settings/driver-pay',
    summary: 'Change the default driver pay rule (affects unsettled days only)',
    tag: 'settings',
    access: access.roles('owner'),
    body: PayRule,
    response: PayRule,
  }),
};
