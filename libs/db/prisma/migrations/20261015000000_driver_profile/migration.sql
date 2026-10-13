-- A driver's profile in their fleet: photo, date of birth, email, address and
-- an emergency contact. The driver and the fleet owner can both edit them.
ALTER TABLE drivers
  ADD COLUMN photo_media_id UUID,
  ADD COLUMN date_of_birth DATE,
  ADD COLUMN email TEXT,
  ADD COLUMN address TEXT,
  ADD COLUMN emergency_contact_name TEXT,
  ADD COLUMN emergency_contact_phone TEXT;
