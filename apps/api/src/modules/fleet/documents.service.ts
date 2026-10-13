import { Injectable } from '@nestjs/common';
import type { Document, DocumentFile, DocType } from '@taxcy/contracts';
import type { Prisma, TenantTx } from '@taxcy/db';
import {
  daysUntil,
  expiryBucket,
  expiryRequired,
  expirySeverity,
  explainExpiry,
  explainSubmission,
  istBusinessDate,
  isVehicleDocType,
} from '@taxcy/domain';
import { AppError, notFound } from '../../platform/errors.js';
import { newId } from '../../platform/ids.js';
import { AlertsRepository } from '../alerts/alerts.repository.js';
import { SettingsService } from './settings.service.js';

type DocumentRow = Prisma.DocumentGetPayload<object>;

const isoDate = (d: Date) => d.toISOString().slice(0, 10);

const DOCUMENT_CONTENT_TYPES = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'application/pdf',
]);
const dedupePrefix = (docId: string) => `doc:${docId}:`;
/** The "driver uploaded a document" alert for one pending document. */
const submissionKey = (docId: string) => `docsub:${docId}`;

export interface DocumentDetails {
  number?: string | undefined;
  validFrom?: Date | undefined;
  expiresOn?: Date | undefined;
  mediaId?: string | undefined;
  mediaIds?: string[] | undefined;
}

/** A driver's own upload: it waits for the owner's approval. */
export interface Submitter {
  userId: string;
  driverId: string;
}

/** The document's files in order, from mediaIds or the older single mediaId. */
const fileIds = (input: DocumentDetails): string[] => [
  ...new Set(input.mediaIds ?? (input.mediaId ? [input.mediaId] : [])),
];

const assertExpiry = (docType: DocType, expiresOn: Date | undefined) => {
  if (!expiresOn && expiryRequired(docType)) {
    throw new AppError('VALIDATION_FAILED', 'This document needs an expiry date', {
      field: 'expiresOn',
    });
  }
};

@Injectable()
export class DocumentsService {
  constructor(
    private readonly alerts: AlertsRepository,
    private readonly settings: SettingsService,
  ) {}

  async list(
    tx: TenantTx,
    filter: {
      vehicleId?: string | undefined;
      driverId?: string | undefined;
      expiringWithinDays?: number | undefined;
      includeSuperseded?: boolean | undefined;
    },
  ): Promise<Document[]> {
    const { audit } = await this.settings.get(tx);
    const today = istBusinessDate(new Date());
    const rows = await tx.document.findMany({
      where: {
        orgId: tx.orgId,
        ...(filter.vehicleId ? { vehicleId: filter.vehicleId } : {}),
        ...(filter.driverId ? { driverId: filter.driverId } : {}),
        ...(filter.includeSuperseded ? {} : { supersededBy: null }),
        // What's due only counts documents the owner has approved.
        ...(filter.expiringWithinDays === undefined
          ? {}
          : {
              reviewStatus: 'approved',
              expiresOn: {
                lte: new Date(
                  Date.parse(`${today}T00:00:00Z`) + filter.expiringWithinDays * 86_400_000,
                ),
              },
            }),
      },
      orderBy: [{ expiresOn: { sort: 'asc', nulls: 'last' } }, { createdAt: 'asc' }],
    });
    const files = await this.filesFor(tx, rows);
    return rows.map((r) => this.toDocument(r, today, audit.docAlertDays, files));
  }

  /**
   * Adds a document. With [by] (a driver's own upload) it's pending until the
   * owner approves it, and the owner gets an alert.
   */
  async create(
    tx: TenantTx,
    input: DocumentDetails & {
      docType: DocType;
      vehicleId?: string | undefined;
      driverId?: string | undefined;
    },
    by?: Submitter,
  ): Promise<Document> {
    if (Boolean(input.vehicleId) === Boolean(input.driverId)) {
      throw new AppError(
        'VALIDATION_FAILED',
        'A document belongs to exactly one vehicle or one driver',
      );
    }
    if (isVehicleDocType(input.docType) !== Boolean(input.vehicleId)) {
      throw new AppError(
        'VALIDATION_FAILED',
        'RC, insurance, permit and PUC belong to vehicles; licences, IDs and photos to drivers',
      );
    }
    assertExpiry(input.docType, input.expiresOn);
    if (
      input.vehicleId &&
      !(await tx.vehicle.count({ where: { id: input.vehicleId, orgId: tx.orgId } }))
    ) {
      throw notFound('Vehicle');
    }
    if (
      input.driverId &&
      !(await tx.driver.count({ where: { id: input.driverId, orgId: tx.orgId } }))
    ) {
      throw notFound('Driver');
    }
    const files = fileIds(input);
    for (const mediaId of files) await this.assertMedia(tx, mediaId);
    const row = await tx.document.create({
      data: {
        id: newId(),
        orgId: tx.orgId,
        docType: input.docType,
        vehicleId: input.vehicleId ?? null,
        driverId: input.driverId ?? null,
        number: input.number ?? null,
        validFrom: input.validFrom ?? null,
        expiresOn: input.expiresOn ?? null,
        mediaId: files[0] ?? null,
        ...(by ? { reviewStatus: 'pending', submittedBy: by.userId } : {}),
      },
    });
    await this.saveFiles(tx, row.id, files);
    if (by) await this.raiseSubmitted(tx, row);
    else await this.evaluateAlerts(tx, row);
    return this.present(tx, row);
  }

  /**
   * The renewed copy replaces the old one; the old one's alerts are resolved.
   * A driver's renewal ([by]) waits for approval and replaces it only then.
   */
  async renew(
    tx: TenantTx,
    id: string,
    input: DocumentDetails,
    by?: Submitter,
  ): Promise<Document> {
    const old = await tx.document.findFirst({
      where: { id, orgId: tx.orgId, ...(by ? { driverId: by.driverId } : {}) },
    });
    if (!old) throw notFound('Document');
    if (old.supersededBy) throw new AppError('CONFLICT', 'This document has already been renewed');
    if (by && old.reviewStatus !== 'approved') {
      throw new AppError('CONFLICT', 'Only an approved document can be renewed');
    }
    if (
      by &&
      (await tx.document.count({
        where: { orgId: tx.orgId, replacesId: old.id, reviewStatus: 'pending' },
      }))
    ) {
      throw new AppError('CONFLICT', 'A renewal of this document is already waiting for approval');
    }
    assertExpiry(old.docType, input.expiresOn);
    const files = fileIds(input);
    for (const mediaId of files) await this.assertMedia(tx, mediaId);
    const row = await tx.document.create({
      data: {
        id: newId(),
        orgId: tx.orgId,
        docType: old.docType,
        vehicleId: old.vehicleId,
        driverId: old.driverId,
        number: input.number ?? old.number,
        validFrom: input.validFrom ?? null,
        expiresOn: input.expiresOn ?? null,
        mediaId: files[0] ?? null,
        ...(by
          ? { reviewStatus: 'pending', submittedBy: by.userId, replacesId: old.id }
          : {}),
      },
    });
    await this.saveFiles(tx, row.id, files);
    if (by) {
      await this.raiseSubmitted(tx, row);
    } else {
      await this.supersede(tx, old.id, row.id);
      await this.evaluateAlerts(tx, row);
    }
    return this.present(tx, row);
  }

  /** Approves a driver's upload; a renewal then replaces the old copy. */
  async approve(tx: TenantTx, id: string): Promise<Document> {
    const doc = await this.requirePending(tx, id);
    const row = await tx.document.update({
      where: { id: doc.id },
      data: { reviewStatus: 'approved', reviewNote: null, reviewedAt: new Date() },
    });
    if (doc.replacesId) await this.supersede(tx, doc.replacesId, doc.id);
    await this.alerts.autoResolvePrefix(tx, submissionKey(doc.id));
    await this.evaluateAlerts(tx, row);
    return this.present(tx, row);
  }

  /** Rejects a driver's upload with the reason they'll see in their app. */
  async reject(tx: TenantTx, id: string, note: string): Promise<Document> {
    const doc = await this.requirePending(tx, id);
    const row = await tx.document.update({
      where: { id: doc.id },
      data: { reviewStatus: 'rejected', reviewNote: note, reviewedAt: new Date() },
    });
    await this.alerts.autoResolvePrefix(tx, submissionKey(doc.id));
    return this.present(tx, row);
  }

  /**
   * Raises the alert for the document's current expiry bucket (30/7/1 days ahead, or
   * expired) and resolves alerts for earlier buckets, so only the latest shows.
   * Documents waiting for approval, rejected ones and ones without an expiry
   * never raise one.
   */
  async evaluateAlerts(
    tx: TenantTx,
    doc: DocumentRow,
    today = istBusinessDate(new Date()),
  ): Promise<void> {
    if (doc.supersededBy) return;
    if (doc.reviewStatus !== 'approved' || !doc.expiresOn) {
      await this.alerts.autoResolvePrefix(tx, dedupePrefix(doc.id));
      return;
    }
    const { audit } = await this.settings.get(tx);
    const expiresOn = isoDate(doc.expiresOn);
    const bucket = expiryBucket(expiresOn, today, audit.docAlertDays);
    if (bucket === null) {
      await this.alerts.autoResolvePrefix(tx, dedupePrefix(doc.id));
      return;
    }
    const dedupeKey = `${dedupePrefix(doc.id)}${String(bucket)}`;
    const text = explainExpiry({
      docType: doc.docType,
      subject: await this.subjectLabel(tx, doc),
      subjectKind: doc.vehicleId ? 'vehicle' : 'driver',
      expiresOn,
      today,
    });
    await this.alerts.raise(tx, {
      kind: bucket === 'expired' ? 'document_expired' : 'document_expiring',
      severity: expirySeverity(bucket),
      ...text,
      subjectType: 'document',
      subjectId: doc.id,
      vehicleId: doc.vehicleId,
      driverId: doc.driverId,
      data: { docType: doc.docType, expiresOn, bucket },
      dedupeKey,
    });
    await this.alerts.autoResolvePrefix(tx, dedupePrefix(doc.id), dedupeKey);
  }

  private async requirePending(tx: TenantTx, id: string): Promise<DocumentRow> {
    const doc = await tx.document.findFirst({ where: { id, orgId: tx.orgId } });
    if (!doc) throw notFound('Document');
    if (doc.reviewStatus !== 'pending') {
      throw new AppError('CONFLICT', 'This document is not waiting for approval');
    }
    return doc;
  }

  private async supersede(tx: TenantTx, oldId: string, newId: string): Promise<void> {
    await tx.document.update({ where: { id: oldId }, data: { supersededBy: newId } });
    await this.alerts.autoResolvePrefix(tx, dedupePrefix(oldId));
  }

  private async raiseSubmitted(tx: TenantTx, doc: DocumentRow): Promise<void> {
    const driverName = await this.subjectLabel(tx, doc);
    await this.alerts.raise(tx, {
      kind: 'document_submitted',
      severity: 'info',
      ...explainSubmission({
        docType: doc.docType,
        driverName,
        renewal: doc.replacesId !== null,
      }),
      subjectType: 'document',
      subjectId: doc.id,
      driverId: doc.driverId,
      data: { docType: doc.docType },
      dedupeKey: submissionKey(doc.id),
    });
  }

  private async subjectLabel(tx: TenantTx, doc: DocumentRow): Promise<string> {
    if (doc.vehicleId) {
      const v = await tx.vehicle.findUnique({
        where: { id: doc.vehicleId },
        select: { registrationNo: true },
      });
      return v?.registrationNo ?? 'vehicle';
    }
    const d = doc.driverId
      ? await tx.driver.findUnique({ where: { id: doc.driverId }, select: { name: true } })
      : null;
    return d?.name ?? 'driver';
  }

  /** A document's file: a photo or a PDF registered as a 'document' upload. */
  private async assertMedia(tx: TenantTx, mediaId: string | undefined): Promise<void> {
    if (!mediaId) return;
    const media = await tx.mediaObject.findFirst({
      where: { id: mediaId, orgId: tx.orgId },
      select: { kind: true, contentType: true },
    });
    if (!media) throw notFound('Media');
    if (media.kind !== 'document' || !DOCUMENT_CONTENT_TYPES.has(media.contentType)) {
      throw new AppError('VALIDATION_FAILED', 'A document must be a photo or a PDF upload', {
        mediaId,
      });
    }
  }

  private async saveFiles(tx: TenantTx, documentId: string, mediaIds: readonly string[]) {
    if (!mediaIds.length) return;
    await tx.documentFile.createMany({
      data: mediaIds.map((mediaId, position) => ({
        orgId: tx.orgId,
        documentId,
        mediaId,
        position,
      })),
    });
  }

  /** Each document's files in order, with their content types, by document id. */
  private async filesFor(
    tx: TenantTx,
    rows: readonly DocumentRow[],
  ): Promise<Map<string, DocumentFile[]>> {
    if (!rows.length) return new Map();
    const links = await tx.documentFile.findMany({
      where: { orgId: tx.orgId, documentId: { in: rows.map((r) => r.id) } },
      orderBy: [{ documentId: 'asc' }, { position: 'asc' }],
    });
    // A document saved before files existed only has documents.media_id.
    const linked = new Set(links.map((f) => f.documentId));
    const all = [
      ...links.map((f) => ({ documentId: f.documentId, mediaId: f.mediaId })),
      ...rows.flatMap((r) =>
        r.mediaId && !linked.has(r.id) ? [{ documentId: r.id, mediaId: r.mediaId }] : [],
      ),
    ];
    const media = await tx.mediaObject.findMany({
      where: { orgId: tx.orgId, id: { in: all.map((f) => f.mediaId) } },
      select: { id: true, contentType: true },
    });
    const types = new Map(media.map((m) => [m.id, m.contentType]));
    const byDocument = new Map<string, DocumentFile[]>();
    for (const f of all) {
      const contentType = types.get(f.mediaId);
      if (!contentType) continue;
      const list = byDocument.get(f.documentId) ?? [];
      list.push({ mediaId: f.mediaId, contentType });
      byDocument.set(f.documentId, list);
    }
    return byDocument;
  }

  private async present(tx: TenantTx, row: DocumentRow): Promise<Document> {
    const { audit } = await this.settings.get(tx);
    const files = await this.filesFor(tx, [row]);
    return this.toDocument(row, istBusinessDate(new Date()), audit.docAlertDays, files);
  }

  private toDocument(
    row: DocumentRow,
    today: string,
    alertDays: readonly number[],
    filesByDocument: ReadonlyMap<string, DocumentFile[]>,
  ): Document {
    const files = filesByDocument.get(row.id) ?? [];
    const daysLeft = row.expiresOn ? daysUntil(isoDate(row.expiresOn), today) : null;
    const status = row.supersededBy
      ? 'superseded'
      : daysLeft === null
        ? 'valid'
        : daysLeft < 0
          ? 'expired'
          : daysLeft <= Math.max(...alertDays)
            ? 'expiring'
            : 'valid';
    return {
      id: row.id,
      docType: row.docType,
      vehicleId: row.vehicleId,
      driverId: row.driverId,
      number: row.number,
      validFrom: row.validFrom,
      expiresOn: row.expiresOn,
      mediaId: files[0]?.mediaId ?? row.mediaId,
      mediaContentType: files[0]?.contentType ?? null,
      files,
      supersededBy: row.supersededBy,
      daysLeft,
      status,
      reviewStatus: reviewStatusOf(row.reviewStatus),
      reviewNote: row.reviewNote,
      submittedByDriver: row.submittedBy !== null,
      replacesId: row.replacesId,
      createdAt: row.createdAt,
    };
  }
}

const REVIEW_STATUSES = ['pending', 'approved', 'rejected'] as const;
const reviewStatusOf = (s: string): Document['reviewStatus'] =>
  REVIEW_STATUSES.find((r) => r === s) ?? 'approved';
