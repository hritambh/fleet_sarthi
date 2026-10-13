import { useTranslation } from 'react-i18next';
import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
  type TooltipContentProps,
} from 'recharts';
import type { ChartData, ChartRow, Series } from '../lib/analytics.js';
import { fmtDate, fmtDecimal1, fmtInr, fmtKm, fmtNumber } from '../lib/format.js';
import { Table, Td, Th } from './ui.js';

// Chrome from the same recessive blue-grey set as the fuel chart, so the two pages
// read as one system. Light-only, like the rest of the console.
const COLORS = {
  surface: '#ffffff',
  grid: '#e3eaf6',
  axis: '#bccbe3',
  muted: '#637594',
  ink: '#121b2f',
  secondary: '#4a5a77',
};

/** How a measure is written: rupees, kilometres, litres/kg, or a bare number. */
export type ValueFormat = 'inr' | 'km' | 'count' | 'L' | 'kg';

function useFormatter(format: ValueFormat) {
  const { t } = useTranslation();
  return {
    value: (v: number): string => {
      if (format === 'inr') return fmtInr(Math.round(v * 100));
      if (format === 'km') return fmtKm(v);
      if (format === 'count') return fmtDecimal1(v);
      return t('units.quantity', { value: fmtDecimal1(v), unit: t(`units.${format}`) });
    },
    // A count can span less than 1 (trips per vehicle), where rounding every tick to a
    // whole number would print the same label several times down the axis.
    tick: (v: number): string => {
      if (format === 'inr') return fmtInr(Math.round(v * 100));
      if (format === 'count') return Number.isInteger(v) ? fmtNumber(v) : fmtDecimal1(v);
      return fmtNumber(Math.round(v));
    },
  };
}

function ChartTooltip({
  active,
  payload,
  series,
  format,
}: {
  active: boolean | undefined;
  payload: readonly { payload?: unknown }[] | undefined;
  series: readonly Series[];
  format: ValueFormat;
}) {
  const fmt = useFormatter(format);
  const row = payload?.[0]?.payload as ChartRow | undefined;
  if (!active || !row) return null;
  // Everything that actually happened that day; zero rows would just be noise.
  const shown = series.filter((s) => {
    const v = row[s.key];
    return typeof v === 'number' && v !== 0;
  });
  return (
    <div className="rounded-md border border-slate-200 bg-white px-3 py-2 text-xs shadow-md">
      <p className="mb-1 font-medium" style={{ color: COLORS.secondary }}>
        {fmtDate(`${row.day}T00:00:00+05:30`)}
      </p>
      {shown.length === 0 ? (
        <p style={{ color: COLORS.secondary }}>—</p>
      ) : (
        <ul className="space-y-0.5">
          {shown.map((s) => (
            <li key={s.key} className="flex items-center gap-2">
              <span
                className="inline-block h-0.5 w-3 shrink-0"
                style={{
                  background: s.dashed
                    ? `repeating-linear-gradient(90deg, ${s.color} 0 3px, transparent 3px 5px)`
                    : s.color,
                }}
                aria-hidden
              />
              <span style={{ color: COLORS.secondary }}>{s.label}</span>
              <strong className="ml-auto tabular-nums" style={{ color: COLORS.ink }}>
                {fmt.value(row[s.key] as number)}
              </strong>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

/** Identity is never colour alone: the legend names every series next to its mark. */
function Legend({ series }: { series: readonly Series[] }) {
  const { t } = useTranslation();
  return (
    <ul
      className="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-xs"
      style={{ color: COLORS.secondary }}
      aria-label={t('analytics.chartKey')}
    >
      {series.map((s) => (
        <li key={s.key} className="flex items-center gap-1.5">
          <span
            className="inline-block w-4 shrink-0 rounded-full"
            style={{
              height: s.emphasis ? 3 : 2,
              background: s.dashed
                ? `repeating-linear-gradient(90deg, ${s.color} 0 4px, transparent 4px 7px)`
                : s.color,
            }}
            aria-hidden
          />
          {s.label}
        </li>
      ))}
    </ul>
  );
}

/** The relief for series colours that sit below 3:1 on white: every figure in text. */
function SeriesTable({
  data,
  format,
  label,
}: {
  data: ChartData;
  format: ValueFormat;
  label: string;
}) {
  const { t } = useTranslation();
  const fmt = useFormatter(format);
  return (
    <details className="mt-3">
      <summary className="cursor-pointer text-sm font-medium text-brand-700">
        {t('analytics.showTable')}
      </summary>
      <div className="mt-2 overflow-x-auto">
        <Table>
          <caption className="sr-only">{label}</caption>
          <thead>
            <tr>
              <Th>{t('analytics.dayCol')}</Th>
              {data.series.map((s) => (
                <Th key={s.key} align="right">
                  {s.label}
                </Th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.rows.map((row) => (
              <tr key={row.day}>
                <Td>{fmtDate(`${row.day}T00:00:00+05:30`)}</Td>
                {data.series.map((s) => {
                  const v = row[s.key];
                  return (
                    <Td key={s.key} align="right">
                      {typeof v === 'number' ? fmt.value(v) : '—'}
                    </Td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </Table>
      </div>
    </details>
  );
}

/**
 * One measure a day across a month. Every series on a chart shares a unit, so there
 * is a single y-axis; measures in different units get their own chart.
 */
export function AnalyticsChart({
  data,
  format,
  caption,
  tableLabel,
  height = 'h-64',
}: {
  data: ChartData;
  format: ValueFormat;
  caption: string;
  tableLabel: string;
  height?: string;
}) {
  const fmt = useFormatter(format);
  const { t } = useTranslation();
  return (
    <figure>
      <figcaption className="mb-2 text-xs text-slate-500">{caption}</figcaption>
      <div className={`${height} rounded-md`} style={{ background: COLORS.surface }}>
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data.rows} margin={{ top: 12, right: 12, bottom: 4, left: 0 }}>
            <CartesianGrid stroke={COLORS.grid} strokeWidth={1} vertical={false} />
            <XAxis
              dataKey="label"
              stroke={COLORS.axis}
              tick={{ fill: COLORS.muted, fontSize: 12 }}
              tickLine={false}
              interval="preserveStartEnd"
              minTickGap={12}
            />
            <YAxis
              stroke={COLORS.axis}
              tick={{ fill: COLORS.muted, fontSize: 12 }}
              tickLine={false}
              axisLine={false}
              width={56}
              domain={[0, 'auto']}
              tickFormatter={fmt.tick}
            />
            {data.series.map((s) => (
              <Line
                key={s.key}
                dataKey={s.key}
                name={s.label}
                stroke={s.color}
                strokeWidth={s.emphasis ? 3 : 2}
                {...(s.dashed ? { strokeDasharray: '4 3' } : {})}
                strokeLinejoin="round"
                strokeLinecap="round"
                dot={false}
                activeDot={{ r: 4, stroke: COLORS.surface, strokeWidth: 2, fill: s.color }}
                connectNulls={false}
                isAnimationActive={false}
              />
            ))}
            <Tooltip
              cursor={{ stroke: COLORS.axis, strokeWidth: 1 }}
              content={(props: TooltipContentProps) => (
                <ChartTooltip
                  active={props.active}
                  payload={props.payload}
                  series={data.series}
                  format={format}
                />
              )}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
      {/* A lone series is named by the card title, so it needs no legend box. */}
      {data.series.length > 1 && <Legend series={data.series} />}
      <p className="sr-only">{t('analytics.tableHint')}</p>
      <SeriesTable data={data} format={format} label={tableLabel} />
    </figure>
  );
}
