import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/api.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_models.dart';
import '../../core/repositories/trips_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/errors.dart';
import '../common/format.dart';
import '../owner/owner_widgets.dart' show busyText;
import 'trip_detail_screen.dart';

const _tripTypes = ['one_way', 'round_trip', 'local_rental'];
const _durations = [1, 2, 4, 8, 12, 24];

typedef _Window = ({DateTime from, DateTime to});

/// Who is booked during a window: this driver and the vehicles linked to them
/// (the server scopes it). Null when the server can't be reached, so the form
/// keeps working offline.
final _availabilityProvider = FutureProvider.autoDispose
    .family<Availability?, _Window>((ref, w) async {
      try {
        return await ref.watch(apiProvider).availability(w.from, w.to);
      } on ApiException catch (error) {
        if (error.isNetwork) return null;
        rethrow;
      }
    });

/// A trip the driver books themselves (e.g. a walk-in customer). It's assigned
/// to them in the vehicle they pick, and works offline like everything else.
class NewTripScreen extends ConsumerStatefulWidget {
  const NewTripScreen({super.key});

  @override
  ConsumerState<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends ConsumerState<NewTripScreen> {
  final _form = GlobalKey<FormState>();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _fare = TextEditingController();
  final _includedKm = TextEditingController();
  final _customer = TextEditingController();
  final _phone = TextEditingController();
  String _tripType = 'one_way';
  DateTime _start = _roundUp(DateTime.now());
  int _hours = 4;
  String? _vehicleId;
  String? _error;
  bool _busy = false;

  static DateTime _roundUp(DateTime t) {
    final next = t.add(Duration(minutes: 5 - t.minute % 5));
    return DateTime(next.year, next.month, next.day, next.hour, next.minute);
  }

  @override
  void dispose() {
    for (final c in [_from, _to, _fare, _includedKm, _customer, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (time == null) return;
    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _error = null;
    });
  }

  _Window get _window =>
      (from: _start, to: _start.add(Duration(hours: _hours)));

  /// Why [vehicle] or the driver can't take a trip in [w], checked afresh just
  /// before creating, so a booking made on another device since the form
  /// loaded doesn't slip through. Offline (or if the server can't say), only
  /// the driver's own trips on this phone are checked; the server still has
  /// the final word when the trip syncs.
  Future<String?> _clash(
    Vehicle vehicle,
    _Window w,
    AppLocalizations l,
    Fmt fmt,
  ) async {
    Availability? fresh;
    try {
      fresh = await ref.refresh(_availabilityProvider(w).future);
    } on ApiException {
      fresh = null;
    }
    if (fresh != null) {
      final me = fresh.drivers.values.firstOrNull;
      if (me != null) return l.youAreBusy(when: busyText(fmt, me));
      if (fresh.vehicles.containsKey(vehicle.id)) return l.errorVehicleBusy;
      return null;
    }
    final own = await ref
        .read(tripsRepositoryProvider)
        .overlappingOwnTrip(w.from, w.to);
    if (own == null) return null;
    return l.youAreBusy(
      when: busyText(
        fmt,
        Busy(
          id: '',
          tripId: own.id,
          from: own.scheduledStartAt,
          to: own.scheduledEndAt,
        ),
      ),
    );
  }

  Future<void> _save(Vehicle vehicle) async {
    if (!_form.currentState!.validate()) return;
    final l = context.l10n;
    final fmt = context.fmt;
    final window = _window;
    setState(() {
      _busy = true;
      _error = null;
    });
    final phone = _phone.text.replaceAll(RegExp(r'\D'), '');
    try {
      final clash = await _clash(vehicle, window, l, fmt);
      if (clash != null) {
        if (mounted) setState(() => _error = clash);
        return;
      }
      final trip = await ref
          .read(tripsRepositoryProvider)
          .create(
            tripType: _tripType,
            fromText: _from.text.trim(),
            toText: _to.text.trim(),
            scheduledStartAt: _start,
            scheduledEndAt: _start.add(Duration(hours: _hours)),
            quotedFarePaise: parseRupees(_fare.text)!,
            includedKm: int.tryParse(_includedKm.text.trim()),
            customerName: _customer.text.trim().isEmpty
                ? null
                : _customer.text.trim(),
            customerPhone: phone.length == 10 ? '+91$phone' : null,
            vehicle: vehicle,
          );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => TripDetailScreen(tripId: trip.id),
        ),
      );
    } on LocalRejection catch (error) {
      setState(() => _error = rejectionText(context.l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesProvider);
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.newTrip)),
      body: vehicles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(errorText(l, error))),
        data: (list) {
          // The server only sends the vehicles this driver is linked to.
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  key: const Key('no-linked-vehicles'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.no_crash_outlined,
                      size: 48,
                      color: TaxcyColors.muted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.noVehiclesLinkedToYou,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.noVehiclesLinkedHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: TaxcyColors.muted),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      key: const Key('reload-vehicles'),
                      onPressed: () => ref.invalidate(vehiclesProvider),
                      icon: const Icon(Icons.refresh),
                      label: Text(l.retry),
                    ),
                  ],
                ),
              ),
            );
          }
          // Who is booked at the chosen time (none known while offline): busy
          // vehicles are listed but not pickable, and a busy driver can't
          // create the trip.
          final availability = ref.watch(_availabilityProvider(_window)).value;
          final busy = availability?.vehicles ?? const <String, Busy>{};
          final meBusy = availability?.drivers.values.firstOrNull;
          bool free(Vehicle v) => !busy.containsKey(v.id);
          // A pick that's booked at the chosen time gives way to the first
          // free vehicle (with a note); null when every vehicle is booked.
          final picked = list.where((v) => v.id == _vehicleId).firstOrNull;
          final pickedBusy = picked != null && !free(picked);
          final vehicle = picked != null && !pickedBusy
              ? picked
              : list.where(free).firstOrNull;
          final blocked = meBusy != null
              ? l.youAreBusy(when: busyText(context.fmt, meBusy))
              : vehicle == null
              ? l.errorVehicleBusy
              : null;
          final local = _tripType == 'local_rental';
          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<String>(
                  segments: [
                    for (final type in _tripTypes)
                      ButtonSegment(
                        value: type,
                        label: Text(tripTypeLabel(l, type)),
                      ),
                  ],
                  selected: {_tripType},
                  onSelectionChanged: (s) =>
                      setState(() => _tripType = s.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('trip-from'),
                  controller: _from,
                  decoration: InputDecoration(
                    labelText: l.pickup,
                    prefixIcon: const Icon(Icons.trip_origin),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? l.enterPickup : null,
                ),
                if (!local) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('trip-to'),
                    controller: _to,
                    decoration: InputDecoration(
                      labelText: l.drop,
                      prefixIcon: const Icon(Icons.place),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l.enterDrop : null,
                  ),
                ],
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickStart,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l.starts,
                      prefixIcon: const Icon(Icons.schedule),
                    ),
                    child: Text(context.fmt.dayTime(_start)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _hours,
                  decoration: InputDecoration(
                    labelText: l.expectedDuration,
                    prefixIcon: const Icon(Icons.timelapse),
                  ),
                  items: [
                    for (final h in _durations)
                      DropdownMenuItem(
                        value: h,
                        child: Text(l.hours(count: h)),
                      ),
                  ],
                  onChanged: (v) => setState(() {
                    _hours = v ?? _hours;
                    _error = null;
                  }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('trip-vehicle'),
                  isExpanded: true,
                  initialValue: vehicle?.id,
                  decoration: InputDecoration(
                    labelText: l.vehicle,
                    prefixIcon: const Icon(Icons.directions_car),
                  ),
                  items: [
                    for (final v in list)
                      DropdownMenuItem(
                        key: ValueKey('pick-${v.id}'),
                        value: v.id,
                        enabled: free(v),
                        child: Text(
                          free(v)
                              ? '${v.registrationNo} · ${v.model}'
                              : '${v.registrationNo} · ${v.model} · '
                                    '${busyText(context.fmt, busy[v.id]!)}',
                          overflow: TextOverflow.ellipsis,
                          style: free(v)
                              ? null
                              : const TextStyle(color: TaxcyColors.muted),
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() {
                    _vehicleId = v;
                    _error = null;
                  }),
                ),
                if (pickedBusy && vehicle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l.busyPickCleared,
                    key: const Key('busy-pick-cleared'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const Key('trip-fare'),
                        controller: _fare,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l.fare,
                          prefixText: '₹ ',
                        ),
                        validator: (v) => validateFare(l, v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        key: const Key('trip-included-km'),
                        controller: _includedKm,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: l.includedKm,
                          helperText: l.optional,
                          suffixText: l.unitKm,
                        ),
                        validator: (v) => validateIncludedKm(l, v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customer,
                  decoration: InputDecoration(
                    labelText: l.customerNameOptional,
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: l.customerMobileOptional,
                    prefixText: '+91 ',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                if ((_error ?? blocked) case final message?) ...[
                  const SizedBox(height: 12),
                  Text(
                    message,
                    key: const Key('trip-problem'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const Key('create-trip'),
                  onPressed: _busy || blocked != null || vehicle == null
                      ? null
                      : () => _save(vehicle),
                  icon: const Icon(Icons.add),
                  label: Text(l.createTrip),
                ),
                const SizedBox(height: 8),
                Text(
                  l.newTripFootnote,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
