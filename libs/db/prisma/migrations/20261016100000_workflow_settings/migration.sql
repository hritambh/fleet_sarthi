-- AlterTable
ALTER TABLE "org_settings" ADD COLUMN     "drivers_can_add_charges" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "drivers_can_create_trips" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "fuel_receipt_required" BOOLEAN NOT NULL DEFAULT true;
