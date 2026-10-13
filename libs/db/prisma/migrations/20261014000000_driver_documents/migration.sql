-- Drivers add their own documents (licence, Aadhaar, PAN, police
-- verification, badge, photo); the owner approves them before they count.

-- New driver document types.
ALTER TYPE "doc_type" ADD VALUE IF NOT EXISTS 'aadhaar';
ALTER TYPE "doc_type" ADD VALUE IF NOT EXISTS 'pan';
ALTER TYPE "doc_type" ADD VALUE IF NOT EXISTS 'police_verification';
ALTER TYPE "doc_type" ADD VALUE IF NOT EXISTS 'badge';
ALTER TYPE "doc_type" ADD VALUE IF NOT EXISTS 'photo';

-- Vehicle types belong to a vehicle; every other type to a driver. (Written
-- with the old values only: new enum values can't be used in this transaction.)
ALTER TABLE documents DROP CONSTRAINT documents_dl_on_driver;
ALTER TABLE documents
  ADD CONSTRAINT documents_type_matches_subject
  CHECK ((doc_type IN ('rc', 'insurance', 'permit', 'puc')) = (vehicle_id IS NOT NULL));

-- Aadhaar, PAN and a photo don't expire.
ALTER TABLE documents ALTER COLUMN expires_on DROP NOT NULL;

-- Review: existing documents are approved; a driver's upload starts pending.
ALTER TABLE documents
  ADD COLUMN review_status TEXT NOT NULL DEFAULT 'approved',
  ADD COLUMN submitted_by UUID,
  ADD COLUMN replaces_id UUID,
  ADD COLUMN review_note TEXT,
  ADD COLUMN reviewed_at TIMESTAMPTZ;
ALTER TABLE documents
  ADD CONSTRAINT documents_review_status CHECK (review_status IN ('pending', 'approved', 'rejected'));
