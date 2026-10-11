-- A driver, and a vehicle, can have only one trip on the road at a time. The API
-- checks this when a trip starts; these indexes are the backstop for two starts at
-- once. Not in schema.prisma: Prisma doesn't model partial indexes.
--
-- Fails with a clear message if some driver or vehicle already has two running trips:
-- end or cancel the extra trips first, then run the migration again.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM trips WHERE status = 'started' AND driver_id IS NOT NULL
    GROUP BY driver_id HAVING count(*) > 1
  ) OR EXISTS (
    SELECT 1 FROM trips WHERE status = 'started' AND vehicle_id IS NOT NULL
    GROUP BY vehicle_id HAVING count(*) > 1
  ) THEN
    RAISE EXCEPTION 'Some drivers or vehicles have more than one trip on the road. End the extra trips, then run the migration again.';
  END IF;
END $$;

CREATE UNIQUE INDEX trips_one_running_per_driver ON trips (driver_id) WHERE status = 'started';
CREATE UNIQUE INDEX trips_one_running_per_vehicle ON trips (vehicle_id) WHERE status = 'started';
