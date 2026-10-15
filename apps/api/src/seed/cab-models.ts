import type { FuelType } from '@taxcy/contracts';

/**
 * The cars small Indian fleets actually run as cabs — what an Ola, Uber or
 * Rapido fleet, or a local tours-and-travels operator, puts on the road. These
 * are seeded as global `vehicle_models` rows (orgId null), which is what the
 * add-vehicle form's brand and model dropdowns offer first; anything off this
 * list is still reachable through "Other", from the public India catalogue.
 *
 * Why a curated list and not an API: nothing public records which cars are used
 * as cabs. Wikidata's "has use = taxi" is set on two car models worldwide, and
 * no data.gov.in dataset carries a maker *and* a model, so the Vahan commercial
 * registrations can't answer it either. This is Fleet Sarthi's own judgement,
 * kept as data so an owner or an admin can extend it without a release.
 *
 * `fuelType` is the variant these are usually bought as for fleet work (CNG
 * wherever it's sold, because that's what the economics decide) and only
 * pre-fills the form's fuel dropdown — an owner can change it.
 *
 * `mean`/`std` seed the fuel audit's baseline for a new vehicle, in km per litre
 * or kg, except a bi-fuel car (petrol_cng), which is audited on cost and so is
 * in paise per km. They are real-world fleet figures rather than ARAI ones, and
 * deliberately loose: the audit only uses them until a vehicle has three
 * accepted cycles of its own, after which it learns that vehicle's own number.
 */
export interface CabModel {
  readonly make: string;
  readonly model: string;
  readonly fuelType: Exclude<FuelType, 'ev'>;
  /** km per litre/kg, or paise per km for petrol_cng. */
  readonly mean: number;
  readonly std: number;
}

export const CAB_MODELS: readonly CabModel[] = [
  // Hatchbacks — the Mini/Go end of a fleet.
  { make: 'Maruti Suzuki', model: 'Alto', fuelType: 'cng', mean: 31, std: 2.5 },
  { make: 'Maruti Suzuki', model: 'Wagon R', fuelType: 'cng', mean: 30, std: 2.5 },
  { make: 'Maruti Suzuki', model: 'Celerio', fuelType: 'cng', mean: 31, std: 2.5 },
  { make: 'Maruti Suzuki', model: 'S-Presso', fuelType: 'cng', mean: 30, std: 2.5 },
  { make: 'Maruti Suzuki', model: 'Swift', fuelType: 'petrol', mean: 20, std: 1.8 },
  { make: 'Maruti Suzuki', model: 'Eeco', fuelType: 'cng', mean: 25, std: 2.0 },
  { make: 'Tata', model: 'Tiago', fuelType: 'cng', mean: 26, std: 2.0 },
  { make: 'Hyundai', model: 'Santro', fuelType: 'cng', mean: 29, std: 2.3 },
  { make: 'Hyundai', model: 'Grand i10 Nios', fuelType: 'cng', mean: 27, std: 2.2 },
  { make: 'Renault', model: 'Kwid', fuelType: 'petrol', mean: 21, std: 1.8 },

  // Compact sedans — the Sedan/Prime end, and most airport work.
  { make: 'Maruti Suzuki', model: 'Dzire', fuelType: 'cng', mean: 24, std: 2.0 },
  { make: 'Tata', model: 'Tigor', fuelType: 'cng', mean: 24, std: 2.0 },
  { make: 'Hyundai', model: 'Aura', fuelType: 'cng', mean: 25, std: 2.0 },
  { make: 'Hyundai', model: 'Xcent', fuelType: 'cng', mean: 24, std: 2.0 },
  { make: 'Honda', model: 'Amaze', fuelType: 'petrol', mean: 18, std: 1.6 },
  { make: 'Honda', model: 'City', fuelType: 'petrol', mean: 17, std: 1.5 },
  { make: 'Maruti Suzuki', model: 'Ciaz', fuelType: 'petrol', mean: 20, std: 1.8 },
  { make: 'Toyota', model: 'Etios', fuelType: 'petrol', mean: 14, std: 1.3 },

  // MUVs and MPVs — outstation, weddings and the XL bookings.
  { make: 'Maruti Suzuki', model: 'Ertiga', fuelType: 'petrol_cng', mean: 420, std: 40 },
  { make: 'Maruti Suzuki', model: 'XL6', fuelType: 'petrol', mean: 17, std: 1.5 },
  { make: 'Toyota', model: 'Innova Crysta', fuelType: 'diesel', mean: 11.5, std: 1.0 },
  { make: 'Toyota', model: 'Innova Hycross', fuelType: 'petrol', mean: 16, std: 1.4 },
  { make: 'Toyota', model: 'Rumion', fuelType: 'petrol_cng', mean: 430, std: 40 },
  { make: 'Kia', model: 'Carens', fuelType: 'petrol', mean: 15, std: 1.4 },
  { make: 'Renault', model: 'Triber', fuelType: 'petrol', mean: 18, std: 1.6 },
  { make: 'Mahindra', model: 'Marazzo', fuelType: 'diesel', mean: 15, std: 1.3 },
  { make: 'Mahindra', model: 'Xylo', fuelType: 'diesel', mean: 13, std: 1.2 },
  { make: 'Mahindra', model: 'Bolero', fuelType: 'diesel', mean: 15, std: 1.3 },
  { make: 'Tata', model: 'Sumo', fuelType: 'diesel', mean: 13, std: 1.2 },
  { make: 'Tata', model: 'Winger', fuelType: 'diesel', mean: 12, std: 1.1 },
  { make: 'Force', model: 'Traveller', fuelType: 'diesel', mean: 10, std: 1.0 },
  { make: 'Maruti Suzuki', model: 'Omni', fuelType: 'petrol', mean: 14, std: 1.3 },

  // SUVs that run on the ride-hailing apps and as premium cabs.
  { make: 'Tata', model: 'Nexon', fuelType: 'petrol', mean: 17, std: 1.5 },
  { make: 'Maruti Suzuki', model: 'Brezza', fuelType: 'petrol_cng', mean: 440, std: 40 },
  { make: 'Maruti Suzuki', model: 'Grand Vitara', fuelType: 'petrol', mean: 19, std: 1.7 },
  { make: 'Hyundai', model: 'Venue', fuelType: 'petrol', mean: 18, std: 1.6 },
  { make: 'Hyundai', model: 'Creta', fuelType: 'petrol', mean: 16, std: 1.4 },
  { make: 'Mahindra', model: 'Scorpio', fuelType: 'diesel', mean: 14, std: 1.2 },
  { make: 'Mahindra', model: 'Scorpio-N', fuelType: 'diesel', mean: 15, std: 1.3 },
  { make: 'Mahindra', model: 'XUV700', fuelType: 'diesel', mean: 15, std: 1.3 },
  { make: 'Toyota', model: 'Fortuner', fuelType: 'diesel', mean: 12, std: 1.1 },
];
