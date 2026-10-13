-- A document can hold several files (e.g. RC front and back, a multi-page PDF).
-- documents.media_id stays as the first file for older clients.
-- CreateTable
CREATE TABLE "document_files" (
    "org_id" UUID NOT NULL,
    "document_id" UUID NOT NULL,
    "media_id" UUID NOT NULL,
    "position" SMALLINT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "document_files_pkey" PRIMARY KEY ("document_id","media_id")
);

-- CreateIndex
CREATE INDEX "document_files_org_id_idx" ON "document_files"("org_id");

-- AddForeignKey
ALTER TABLE "document_files" ADD CONSTRAINT "document_files_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "documents"("id") ON DELETE CASCADE ON UPDATE CASCADE;


ALTER TABLE document_files ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON document_files
  USING (org_id = NULLIF(current_setting('app.org_id', true), '')::uuid OR current_setting('app.bypass_rls', true) = 'on')
  WITH CHECK (org_id = NULLIF(current_setting('app.org_id', true), '')::uuid OR current_setting('app.bypass_rls', true) = 'on');

-- Existing data: each document's single file becomes its first file.
INSERT INTO document_files (org_id, document_id, media_id, position)
SELECT org_id, id, media_id, 0
FROM documents
WHERE media_id IS NOT NULL
ON CONFLICT DO NOTHING;
