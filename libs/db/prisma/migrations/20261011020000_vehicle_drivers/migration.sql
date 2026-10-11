-- Which drivers may drive which vehicles (many to many, within one org).
-- CreateTable
CREATE TABLE "vehicle_drivers" (
    "org_id" UUID NOT NULL,
    "vehicle_id" UUID NOT NULL,
    "driver_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "vehicle_drivers_pkey" PRIMARY KEY ("vehicle_id","driver_id")
);

-- CreateIndex
CREATE INDEX "vehicle_drivers_driver_id_idx" ON "vehicle_drivers"("driver_id");

-- CreateIndex
CREATE INDEX "vehicle_drivers_org_id_idx" ON "vehicle_drivers"("org_id");

-- AddForeignKey
ALTER TABLE "vehicle_drivers" ADD CONSTRAINT "vehicle_drivers_vehicle_id_fkey" FOREIGN KEY ("vehicle_id") REFERENCES "vehicles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "vehicle_drivers" ADD CONSTRAINT "vehicle_drivers_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "drivers"("id") ON DELETE CASCADE ON UPDATE CASCADE;


ALTER TABLE vehicle_drivers ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON vehicle_drivers
  USING (org_id = NULLIF(current_setting('app.org_id', true), '')::uuid OR current_setting('app.bypass_rls', true) = 'on')
  WITH CHECK (org_id = NULLIF(current_setting('app.org_id', true), '')::uuid OR current_setting('app.bypass_rls', true) = 'on');

-- Existing data: link every driver to the vehicles they've had trips in, and in
-- owner-driver (DCO) orgs, the owner to every vehicle. Owners can change the links.
INSERT INTO vehicle_drivers (org_id, vehicle_id, driver_id)
SELECT DISTINCT org_id, vehicle_id, driver_id
FROM trips
WHERE vehicle_id IS NOT NULL AND driver_id IS NOT NULL
ON CONFLICT DO NOTHING;

INSERT INTO vehicle_drivers (org_id, vehicle_id, driver_id)
SELECT v.org_id, v.id, d.id
FROM vehicles v
JOIN organizations o ON o.id = v.org_id AND o.kind = 'dco'
JOIN drivers d ON d.org_id = v.org_id
JOIN memberships m ON m.id = d.membership_id AND 'owner' = ANY (m.roles)
ON CONFLICT DO NOTHING;
