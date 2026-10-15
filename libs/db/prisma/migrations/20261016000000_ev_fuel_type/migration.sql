-- Electric vehicles. They have no fuel fills and no fuel audit.
ALTER TYPE fuel_type ADD VALUE IF NOT EXISTS 'ev';
