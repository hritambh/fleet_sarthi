import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/api/owner_models.dart';
import '../common/format.dart';
import 'alerts_inbox.dart';
import 'fuel_screens.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';

/// The month as YYYY-MM.
String monthKey(int year, int month) =>
    '$year-${month.toString().padLeft(2, '0')}';

/// Daily fuel bought, revenue and km for a chosen month, per-trip averages,
/// and under them the per-vehicle fuel audit.
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({this.now, super.key});

  /// Today, for tests; defaults to the clock.
  final DateTime? now;

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late final DateTime _today = DateTime.parse(istToday(widget.now));
  late int _year = _today.year;
  late int _month = _today.month;

  String get _key => monthKey(_year, _month);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final data = ref.watch(dailyAnalyticsProvider(_key));
    final monthName = fmt.dateFormat('MMMM');
    final years = [for (var y = _today.year; y > _today.year - 4; y--) y];
    Widget box(Widget child) => SizedBox(width: 180, child: child);
    return Scaffold(
      appBar: AppBar(title: Text(l.analytics), actions: const [AlertsBell()]),
      body: RefreshPage(
        onRefresh: () async {
          ref
            ..invalidate(dailyAnalyticsProvider(_key))
            ..invalidate(vehicleAuditProvider)
            ..invalidate(fleetVehiclesProvider);
          await ref.read(dailyAnalyticsProvider(_key).future);
        },
        children: [
          Text(l.analyticsIntro, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              box(
                DropdownButtonFormField<int>(
                  key: const Key('analytics-month'),
                  initialValue: _month,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l.month,
                    isDense: true,
                  ),
                  items: [
                    for (var m = 1; m <= 12; m++)
                      DropdownMenuItem(
                        value: m,
                        child: Text(monthName.format(DateTime(2000, m))),
                      ),
                  ],
                  onChanged: (v) => setState(() => _month = v ?? _month),
                ),
              ),
              box(
                DropdownButtonFormField<int>(
                  key: const Key('analytics-year'),
                  initialValue: _year,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.year, isDense: true),
                  items: [
                    for (final y in years)
                      DropdownMenuItem(value: y, child: Text('$y')),
                  ],
                  onChanged: (v) => setState(() => _year = v ?? _year),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AsyncView(
            value: data,
            onRetry: () => ref.invalidate(dailyAnalyticsProvider(_key)),
            builder: (a) => _MonthCharts(a, year: _year, month: _month),
          ),
          const FuelAuditList(),
        ],
      ),
    );
  }
}

class _MonthCharts extends StatelessWidget {
  const _MonthCharts(this.a, {required this.year, required this.month});
  final DailyAnalytics a;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final dash = '–';
    final averages = [
      MetricCard(
        key: const Key('avg-km'),
        icon: Icons.route,
        accent: TaxcyColors.blue600,
        label: l.avgKmPerTrip,
        value: a.kmAvg == null ? dash : fmt.km(a.kmAvg!),
        hint: l.tripsInMonth(count: a.trips),
      ),
      MetricCard(
        key: const Key('avg-revenue'),
        icon: Icons.currency_rupee,
        accent: Colors.green.shade700,
        label: l.avgRevenuePerTrip,
        value: a.revenueAvgPaise == null ? dash : fmt.inr(a.revenueAvgPaise!),
      ),
      MetricCard(
        key: const Key('avg-fuel'),
        icon: Icons.local_gas_station_outlined,
        accent: Colors.amber.shade800,
        label: l.avgFuelCostPerTrip,
        value: a.fuelCostAvgPaise == null ? dash : fmt.inr(a.fuelCostAvgPaise!),
      ),
    ];
    final desktop = isDesktop(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: l.perTripAverages,
          child: desktop
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, card) in averages.indexed) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(child: card),
                      ],
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (final card in averages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: card,
                      ),
                  ],
                ),
        ),
        _DailyChartCard(
          key: const Key('chart-fuel'),
          title: l.fuelBoughtPerDay,
          analytics: a,
          year: year,
          month: month,
          color: Colors.amber.shade700,
          metric: _fuelMetric,
        ),
        _DailyChartCard(
          key: const Key('chart-revenue'),
          title: l.revenuePerDay,
          analytics: a,
          year: year,
          month: month,
          color: Colors.green.shade600,
          metric: (vehicle) => _Metric(
            value: (r) => r.revenuePaise.toDouble(),
            format: (fmt, v) => fmt.inr(v.round()),
          ),
        ),
        _DailyChartCard(
          key: const Key('chart-km'),
          title: l.kmPerDay,
          analytics: a,
          year: year,
          month: month,
          color: TaxcyColors.blue600,
          metric: (vehicle) => _Metric(
            value: (r) => r.km.toDouble(),
            format: (fmt, v) => fmt.km(v.round()),
          ),
        ),
      ],
    );
  }

  /// Litres or kg for a single-fuel vehicle; rupees for all vehicles together
  /// or a petrol + CNG car, since litres and kg can't be added up.
  static _Metric _fuelMetric(AnalyticsVehicle? vehicle) =>
      switch (vehicle?.fuelType) {
        'petrol' || 'diesel' => _Metric(
          value: (r) => r.fuelLitresMilli / 1000,
          format: (fmt, v) => fmt.quantity((v * 1000).round(), 'petrol'),
        ),
        'cng' => _Metric(
          value: (r) => r.fuelKgMilli / 1000,
          format: (fmt, v) => fmt.quantity((v * 1000).round(), 'cng'),
        ),
        _ => _Metric(
          value: (r) => r.fuelCostPaise.toDouble(),
          format: (fmt, v) => fmt.inr(v.round()),
          inRupees: true,
        ),
      };
}

class _Metric {
  const _Metric({
    required this.value,
    required this.format,
    this.inRupees = false,
  });
  final double Function(AnalyticsDayRow row) value;
  final String Function(Fmt fmt, double value) format;

  /// Fuel shown as money because units can't be mixed.
  final bool inRupees;
}

/// One metric per day of the month as bars, for one vehicle or all of them.
class _DailyChartCard extends StatefulWidget {
  const _DailyChartCard({
    required this.title,
    required this.analytics,
    required this.year,
    required this.month,
    required this.color,
    required this.metric,
    super.key,
  });

  final String title;
  final DailyAnalytics analytics;
  final int year;
  final int month;
  final Color color;
  final _Metric Function(AnalyticsVehicle? vehicle) metric;

  @override
  State<_DailyChartCard> createState() => _DailyChartCardState();
}

class _DailyChartCardState extends State<_DailyChartCard> {
  String? _vehicleId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final a = widget.analytics;
    final vehicle = a.vehicles.where((v) => v.id == _vehicleId).firstOrNull;
    final metric = widget.metric(vehicle);
    final days = DateUtils.getDaysInMonth(widget.year, widget.month);
    final perDay = List<double>.filled(days, 0);
    for (final r in a.rows) {
      if (_vehicleId != null && r.vehicleId != _vehicleId) continue;
      final day = int.parse(r.date.substring(8, 10));
      if (day >= 1 && day <= days) perDay[day - 1] += metric.value(r);
    }
    final total = perDay.fold<double>(0, (s, v) => s + v);
    return SectionCard(
      title: widget.title,
      actions: [
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String?>(
            initialValue: _vehicleId,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.vehicle, isDense: true),
            items: [
              DropdownMenuItem<String?>(child: Text(l.allVehicles)),
              for (final v in a.vehicles)
                DropdownMenuItem<String?>(
                  value: v.id,
                  child: Text(
                    formatRegistration(v.registrationNo),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _vehicleId = v),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.monthTotal(total: metric.format(fmt, total)),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (metric.inRupees)
            Text(
              l.fuelInRupeesNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 12),
          if (total == 0)
            EmptyState(l.noActivityThisMonth)
          else
            _Bars(
              values: perDay,
              color: widget.color,
              format: (v) => metric.format(fmt, v),
            ),
        ],
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars({
    required this.values,
    required this.color,
    required this.format,
  });
  final List<double> values;
  final Color color;
  final String Function(double) format;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<double>(0, (m, v) => v > m ? v : m);
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: max * 1.15,
          gridData: const FlGridData(drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                '${group.x}: ${format(rod.toY)}',
                const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (x, meta) {
                  final day = x.round();
                  if (day != 1 && day % 5 != 0) return const SizedBox.shrink();
                  return Text('$day', style: const TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          barGroups: [
            for (final (i, v) in values.indexed)
              BarChartGroupData(
                x: i + 1,
                barRods: [
                  BarChartRodData(
                    toY: v,
                    color: color,
                    width: 6,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
