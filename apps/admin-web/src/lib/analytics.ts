import { i18n } from '../i18n/index.js';
import type { MonthlyAnalytics } from './api-types.js';
import { fmtRegistration } from './format.js';

/**
 * Categorical slots from the data-viz reference palette, in its fixed order.
 * Validated for lines (adjacent pairs) on a white surface; three slots fall below
 * 3:1 contrast, so every chart ships the table view as relief.
 */
const SERIES_COLORS = [
  '#2a78d6',
  '#eb6834',
  '#1baf7a',
  '#eda100',
  '#e87ba4',
  '#008300',
  '#6250d6',
  '#e34948',
] as const;

export const MAX_VEHICLE_SERIES = SERIES_COLORS.length;

/** A fleet total is not one of the categorical entities, so it wears ink instead of a hue. */
export const TOTAL_COLOR = '#121b2f';

export interface Series {
  key: string;
  label: string;
  color: string;
  /** Collected revenue, drawn against the billed line of the same colour. */
  dashed?: boolean;
  /** The fleet total, drawn heavier than the vehicles behind it. */
  emphasis?: boolean;
}

export type ChartRow = { day: string; label: string } & Record<string, number | null | string>;

export interface ChartData {
  rows: ChartRow[];
  series: Series[];
}

type Vehicle = MonthlyAnalytics['vehicles'][number];

const OTHER = 'other';

/** Day-of-month, so a month of ticks stays readable. */
const dayLabel = (day: string) => String(Number(day.slice(8, 10)));

const baseRows = (days: readonly string[]): ChartRow[] =>
  days.map((day) => ({ day, label: dayLabel(day) }));

/**
 * Colour belongs to the vehicle, by its place in the fleet, so a chart that leaves a
 * vehicle out (no fuel that month) never repaints the ones that remain. Hues are
 * never cycled: past the eighth vehicle the rest fold into one "other" series.
 */
interface Palette {
  /** The series key a vehicle draws on: its own id, or the shared "other" key. */
  keyOf: (vehicleId: string) => string;
  colorOf: (key: string) => string;
  labelOf: (key: string) => string;
  /** Series keys in fleet order, each appearing once. */
  keys: (vehicles: readonly Vehicle[]) => string[];
}

export function palette(all: readonly Vehicle[]): Palette {
  const folds = all.length > MAX_VEHICLE_SERIES;
  const namedCount = folds ? MAX_VEHICLE_SERIES - 1 : all.length;
  const slotOf = new Map<string, number>();
  all.forEach((v, i) => {
    if (i < namedCount) slotOf.set(v.id, i);
  });
  const labels = new Map(all.map((v) => [v.id, fmtRegistration(v.registrationNo)]));
  const otherCount = all.length - namedCount;

  const keyOf = (vehicleId: string) => (slotOf.has(vehicleId) ? vehicleId : OTHER);
  return {
    keyOf,
    colorOf: (key) =>
      key === OTHER
        ? (SERIES_COLORS[MAX_VEHICLE_SERIES - 1] as string)
        : (SERIES_COLORS[slotOf.get(key) ?? 0] as string),
    labelOf: (key) =>
      key === OTHER
        ? i18n.t('analytics.otherVehicles', { count: otherCount })
        : (labels.get(key) ?? key),
    keys: (vehicles) => {
      const seen = new Set<string>();
      const out: string[] = [];
      for (const v of all) {
        if (!vehicles.some((x) => x.id === v.id)) continue;
        const key = keyOf(v.id);
        if (seen.has(key)) continue;
        seen.add(key);
        out.push(key);
      }
      return out;
    },
  };
}

export interface FuelChart {
  unit: 'L' | 'kg';
  chart: ChartData;
}

/**
 * Fuel put in per vehicle per day, one chart per unit: litres and kilograms are
 * different quantities and must never share a y-axis. A bifuel vehicle was filled
 * with both, so it appears on both charts.
 */
export function fuelCharts(data: MonthlyAnalytics): FuelChart[] {
  const p = palette(data.vehicles);
  const units: ('L' | 'kg')[] = ['L', 'kg'];
  return units.flatMap((unit) => {
    const rowsForUnit = data.fuel.filter((f) => f.unit === unit);
    if (rowsForUnit.length === 0) return [];
    const vehicles = data.vehicles.filter((v) => rowsForUnit.some((f) => f.vehicleId === v.id));
    const rows = baseRows(data.days);
    const series: Series[] = p.keys(vehicles).map((key) => ({
      key,
      label: p.labelOf(key),
      color: p.colorOf(key),
    }));
    for (const f of rowsForUnit) {
      const key = p.keyOf(f.vehicleId);
      rows.forEach((row, i) => {
        row[key] = ((row[key] as number | undefined) ?? 0) + (f.quantity[i] ?? 0);
      });
    }
    // A vehicle with no fill on a day used nothing, which is a real zero, not a gap.
    for (const row of rows) {
      for (const s of series) row[s.key] ??= 0;
    }
    return [{ unit, chart: { rows, series } }];
  });
}

/**
 * Revenue per vehicle per day in rupees. Colour identifies the vehicle; the line
 * style separates what was billed (solid) from what was collected (dashed).
 */
export function revenueChart(data: MonthlyAnalytics): ChartData {
  const p = palette(data.vehicles);
  const rows = baseRows(data.days);
  const series: Series[] = [];
  for (const key of p.keys(data.vehicles)) {
    const label = p.labelOf(key);
    const color = p.colorOf(key);
    series.push({ key: `${key}:billed`, label, color });
    series.push({
      key: `${key}:collected`,
      label: i18n.t('analytics.collectedOf', { vehicle: label }),
      color,
      dashed: true,
    });
  }
  for (const r of data.revenue) {
    const key = p.keyOf(r.vehicleId);
    rows.forEach((row, i) => {
      const billed = `${key}:billed`;
      const collected = `${key}:collected`;
      row[billed] = ((row[billed] as number | undefined) ?? 0) + (r.billedPaise[i] ?? 0) / 100;
      row[collected] =
        ((row[collected] as number | undefined) ?? 0) + (r.collectedPaise[i] ?? 0) / 100;
    });
  }
  for (const row of rows) {
    for (const s of series) row[s.key] ??= 0;
  }
  return { rows, series };
}

/** Distance per day: the fleet total in ink, with each vehicle behind it. */
export function distanceChart(data: MonthlyAnalytics): ChartData {
  const p = palette(data.vehicles);
  const rows = baseRows(data.days);
  const series: Series[] = [
    { key: 'total', label: i18n.t('analytics.fleetTotal'), color: TOTAL_COLOR, emphasis: true },
    ...p.keys(data.vehicles).map((key) => ({
      key,
      label: p.labelOf(key),
      color: p.colorOf(key),
    })),
  ];
  rows.forEach((row, i) => {
    row['total'] = data.distanceTotalKm[i] ?? 0;
  });
  for (const d of data.distance) {
    const key = p.keyOf(d.vehicleId);
    rows.forEach((row, i) => {
      row[key] = ((row[key] as number | undefined) ?? 0) + (d.km[i] ?? 0);
    });
  }
  for (const row of rows) {
    for (const s of series) row[s.key] ??= 0;
  }
  return { rows, series };
}

export type AverageKind = 'revenuePerTrip' | 'kmPerTrip' | 'fuelCostPerTrip' | 'tripsPerVehicle';

export interface AverageChart {
  kind: AverageKind;
  /** Decides the axis and tooltip formatting. */
  format: 'inr' | 'km' | 'count';
  chart: ChartData;
}

/**
 * The four fleet-wide per-trip averages. Each is its own chart with its own axis:
 * rupees, kilometres and a plain count cannot share one scale.
 */
export function averageCharts(data: MonthlyAnalytics): AverageChart[] {
  const rows = baseRows(data.days);
  const p = data.perTrip;
  const specs: { kind: AverageKind; format: AverageChart['format']; values: (number | null)[] }[] =
    [
      {
        kind: 'revenuePerTrip',
        format: 'inr',
        values: p.revenuePerTripPaise.map((v) => (v === null ? null : v / 100)),
      },
      { kind: 'kmPerTrip', format: 'km', values: p.kmPerTrip },
      {
        kind: 'fuelCostPerTrip',
        format: 'inr',
        values: p.fuelCostPerTripPaise.map((v) => (v === null ? null : v / 100)),
      },
      { kind: 'tripsPerVehicle', format: 'count', values: p.tripsPerVehicle },
    ];
  return specs.map(({ kind, format, values }) => ({
    kind,
    format,
    chart: {
      rows: rows.map((row, i) => ({ ...row, [kind]: values[i] ?? null })),
      series: [
        {
          key: kind,
          label: i18n.t(`analytics.average.${kind}`),
          color: SERIES_COLORS[0],
        },
      ],
    },
  }));
}
