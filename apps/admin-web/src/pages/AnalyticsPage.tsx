import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Link } from 'react-router';
import { AnalyticsChart } from '../components/AnalyticsChart.js';
import { Card, EmptyState, Field, PageHeader, QueryState, Select } from '../components/ui.js';
import {
  averageCharts,
  distanceChart,
  fuelCharts,
  revenueChart,
  type AverageChart,
} from '../lib/analytics.js';
import type { MonthlyAnalytics } from '../lib/api-types.js';
import { istToday } from '../lib/format.js';
import { useMonthlyAnalytics } from '../lib/queries.js';
import { VehicleFuelList } from './FuelPages.js';

/** Five years back is as far as any fleet here has records. */
const YEARS_BACK = 5;

function MonthFilter({
  year,
  month,
  onChange,
}: {
  year: number;
  month: number;
  onChange: (next: { year: number; month: number }) => void;
}) {
  const { t, i18n } = useTranslation();
  const thisYear = Number(istToday().slice(0, 4));
  const years = Array.from({ length: YEARS_BACK }, (_, i) => thisYear - i);
  const monthName = new Intl.DateTimeFormat(i18n.language, { month: 'long', timeZone: 'UTC' });
  return (
    <div className="flex flex-wrap items-end gap-3">
      <Field label={t('analytics.month')}>
        {(props) => (
          <Select
            {...props}
            className="w-40"
            value={String(month)}
            onChange={(e) => {
              onChange({ year, month: Number(e.target.value) });
            }}
          >
            {Array.from({ length: 12 }, (_, i) => i + 1).map((m) => (
              <option key={m} value={m}>
                {monthName.format(new Date(Date.UTC(2000, m - 1, 1)))}
              </option>
            ))}
          </Select>
        )}
      </Field>
      <Field label={t('analytics.year')}>
        {(props) => (
          <Select
            {...props}
            className="w-28"
            value={String(year)}
            onChange={(e) => {
              onChange({ year: Number(e.target.value), month });
            }}
          >
            {years.map((y) => (
              <option key={y} value={y}>
                {y}
              </option>
            ))}
          </Select>
        )}
      </Field>
    </div>
  );
}

function FuelSection({ data }: { data: MonthlyAnalytics }) {
  const { t } = useTranslation();
  const charts = fuelCharts(data);
  return (
    <Card title={t('analytics.fuel.title')}>
      {charts.length === 0 ? (
        <EmptyState title={t('analytics.noData')} />
      ) : (
        <div className="space-y-6">
          {charts.map(({ unit, chart }) => (
            <AnalyticsChart
              key={unit}
              data={chart}
              format={unit}
              caption={t(`analytics.fuel.caption.${unit}`)}
              tableLabel={t(`analytics.fuel.caption.${unit}`)}
            />
          ))}
        </div>
      )}
    </Card>
  );
}

function AveragesSection({ data }: { data: MonthlyAnalytics }) {
  const { t } = useTranslation();
  const charts: AverageChart[] = averageCharts(data);
  return (
    <Card title={t('analytics.averages.title')}>
      <p className="mb-4 text-sm text-slate-600">{t('analytics.averages.description')}</p>
      <div className="grid gap-6 lg:grid-cols-2">
        {charts.map(({ kind, format, chart }) => (
          <div key={kind}>
            <h3 className="mb-1 text-sm font-semibold text-slate-900">
              {t(`analytics.average.${kind}`)}
            </h3>
            <AnalyticsChart
              data={chart}
              format={format}
              caption={t(`analytics.averageHint.${kind}`)}
              tableLabel={t(`analytics.average.${kind}`)}
              height="h-52"
            />
          </div>
        ))}
      </div>
    </Card>
  );
}

export function AnalyticsPage() {
  const { t } = useTranslation();
  const today = istToday();
  const [period, setPeriod] = useState({
    year: Number(today.slice(0, 4)),
    month: Number(today.slice(5, 7)),
  });
  const analytics = useMonthlyAnalytics(period);

  return (
    <>
      <PageHeader title={t('nav.analytics')} description={t('analytics.description')} />
      <div className="space-y-4">
        <Card>
          <MonthFilter year={period.year} month={period.month} onChange={setPeriod} />
        </Card>
        <QueryState query={analytics}>
          {(data) =>
            data.vehicles.length === 0 ? (
              <EmptyState title={t('analytics.noVehicles')}>
                <Link className="text-brand-700 hover:underline" to="/vehicles">
                  {t('fleet.fuel.addVehicle')}
                </Link>
              </EmptyState>
            ) : data.days.length === 0 ? (
              <EmptyState title={t('analytics.futureMonth')} />
            ) : (
              <div className="space-y-4">
                <FuelSection data={data} />
                <Card title={t('analytics.revenue.title')}>
                  <AnalyticsChart
                    data={revenueChart(data)}
                    format="inr"
                    caption={t('analytics.revenue.caption')}
                    tableLabel={t('analytics.revenue.title')}
                  />
                </Card>
                <Card title={t('analytics.distance.title')}>
                  <AnalyticsChart
                    data={distanceChart(data)}
                    format="km"
                    caption={t('analytics.distance.caption')}
                    tableLabel={t('analytics.distance.title')}
                  />
                </Card>
                <AveragesSection data={data} />
                <Card title={t('analytics.fuelByVehicle')}>
                  <p className="mb-3 text-sm text-slate-600">{t('fleet.fuel.description')}</p>
                  <VehicleFuelList />
                </Card>
              </div>
            )
          }
        </QueryState>
      </div>
    </>
  );
}
