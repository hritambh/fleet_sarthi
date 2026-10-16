import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/api/json.dart';
import '../../../core/api/models.dart';
import '../../../core/api/owner_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/format.dart';
import '../../common/place_field.dart';
import '../links.dart';
import '../owner_providers.dart';
import '../owner_widgets.dart';
import 'owner_trip_detail_screen.dart';
import 'pin_picker.dart';

/// What the create-trip form collected.
class NewTripInput {
  const NewTripInput({
    required this.tripType,
    required this.fromText,
    required this.toText,
    required this.start,
    required this.end,
    required this.fare,
    this.includedKm = '',
    this.customerName = '',
    this.customerPhone = '',
    this.vehicleId,
    this.driverId,
    this.fromPoint,
    this.toPoint,
  });

  final String tripType;
  final String fromText;
  final String toText;
  final DateTime start;
  final DateTime end;

  /// As typed: rupees, km and phone digits.
  final String fare;
  final String includedKm;
  final String customerName;
  final String customerPhone;
  final String? vehicleId;
  final String? driverId;

  /// Optional map pins for the pickup and drop.
  final GeoPoint? fromPoint;
  final GeoPoint? toPoint;
}

/// The POST /trips body for [input], or the first problem with it (in the
/// user's language). Mirrors the API's checks.
({JsonMap? body, String? problem}) newTripBody(
  AppLocalizations l,
  NewTripInput input, {
  String? id,
}) {
  final fare = parseRupees(input.fare);
  final kmText = input.includedKm.trim();
  final km = kmText.isEmpty ? null : int.tryParse(kmText);
  final local = input.tripType == 'local_rental';
  final String? problem;
  if (input.fromText.trim().isEmpty) {
    problem = l.enterPickup;
  } else if (!local && input.toText.trim().isEmpty) {
    problem = l.enterDrop;
  } else if (fare == null) {
    problem = l.enterFare;
  } else if (kmText.isNotEmpty && (km == null || km < 1 || km > 20000)) {
    problem = l.includedKmInvalid;
  } else if (!input.end.isAfter(input.start)) {
    problem = l.rejectEndBeforeStart;
  } else if ((input.vehicleId == null) != (input.driverId == null)) {
    problem = l.pickBothOrNeither;
  } else {
    problem = null;
  }
  if (problem != null) return (body: null, problem: problem);
  final digits = input.customerPhone.replaceAll(RegExp(r'\D'), '');
  final name = input.customerName.trim();
  return (
    body: {
      'id': ?id,
      'tripType': input.tripType,
      'from': {
        'text': input.fromText.trim(),
        'point': ?input.fromPoint?.toJson(),
      },
      if (!local)
        'to': {'text': input.toText.trim(), 'point': ?input.toPoint?.toJson()},
      'scheduledStartAt': input.start.toUtc().toIso8601String(),
      'scheduledEndAt': input.end.toUtc().toIso8601String(),
      'quotedFarePaise': fare,
      'includedKm': ?km,
      if (name.isNotEmpty)
        'customer': {
          'name': name,
          if (digits.length >= 10)
            'phone': '+91${digits.substring(digits.length - 10)}',
        },
      if (input.vehicleId != null) ...{
        'vehicleId': input.vehicleId,
        'driverId': input.driverId,
      },
    },
    problem: null,
  );
}

/// Owner/manager creates a trip, optionally assigning a vehicle and driver; or,
/// given a [trip] that has not started, edits its details (the vehicle and
/// driver are changed with Assign on the trip itself).
class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({this.trip, super.key});

  final Trip? trip;

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  // One id per form, so a retried submit can't create the trip twice.
  final _id = const Uuid().v4();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _fare = TextEditingController();
  final _km = TextEditingController();
  final _customer = TextEditingController();
  final _phone = TextEditingController();
  String _tripType = 'one_way';
  late DateTime _start = _nextHour(DateTime.now());
  late DateTime _end = _start.add(const Duration(hours: 4));
  String? _vehicleId;
  String? _driverId;
  GeoPoint? _fromPoint;
  GeoPoint? _toPoint;
  String? _problem;
  bool _busy = false;

  /// A picked vehicle or driver turned out busy at the new times and was cleared.
  bool _cleared = false;

  static DateTime _nextHour(DateTime t) =>
      DateTime(t.year, t.month, t.day, t.hour + 1);

  bool get _editing => widget.trip != null;

  @override
  void initState() {
    super.initState();
    final t = widget.trip;
    if (t == null) return;
    _tripType = t.tripType;
    _from.text = t.fromText;
    _to.text = t.toText ?? '';
    _start = t.scheduledStartAt.toLocal();
    _end = t.scheduledEndAt.toLocal();
    final paise = t.quotedFarePaise;
    _fare.text = (paise / 100).toStringAsFixed(paise % 100 == 0 ? 0 : 2);
    _km.text = t.includedKm?.toString() ?? '';
    _customer.text = t.customerName ?? '';
    final digits = (t.customerPhone ?? '').replaceAll(RegExp(r'\D'), '');
    _phone.text = digits.length > 10
        ? digits.substring(digits.length - 10)
        : digits;
    _fromPoint = t.fromPoint;
    _toPoint = t.toPoint;
  }

  @override
  void dispose() {
    for (final c in [_from, _to, _fare, _km, _customer, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime current) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    final result = newTripBody(
      context.l10n,
      NewTripInput(
        tripType: _tripType,
        fromText: _from.text,
        toText: _to.text,
        start: _start,
        end: _end,
        fare: _fare.text,
        includedKm: _km.text,
        customerName: _customer.text,
        customerPhone: _phone.text,
        vehicleId: _vehicleId,
        driverId: _driverId,
        fromPoint: _fromPoint,
        toPoint: _toPoint,
      ),
      id: _editing ? null : _id,
    );
    setState(() => _problem = result.problem);
    final body = result.body;
    if (body == null) return;
    setState(() => _busy = true);
    final l = context.l10n;
    final navigator = Navigator.of(context);
    // Check the picks again just before creating: the lists may be stale if
    // the vehicle or driver was booked on another device since they loaded.
    // A busy pick is cleared by the listener in build. If the check itself
    // fails, carry on: the server still refuses a clash.
    final vehicleId = _vehicleId;
    final driverId = _driverId;
    if (!_editing && (vehicleId != null || driverId != null)) {
      try {
        final fresh = await ref.refresh(
          availabilityProvider((
            from: _start,
            to: _end,
            excludeTripId: null,
          )).future,
        );
        final clash = fresh.vehicles.containsKey(vehicleId)
            ? l.errorVehicleBusy
            : fresh.drivers.containsKey(driverId)
            ? l.errorDriverBusy
            : null;
        if (clash != null) {
          if (mounted) {
            setState(() {
              _problem = clash;
              _busy = false;
              // The problem says why; the "new time" note doesn't apply.
              _cleared = false;
            });
          }
          return;
        }
      } on Object {
        // Fall through to the server's own check.
      }
    }
    if (!mounted) return;
    final editing = widget.trip;
    if (editing != null) {
      final ok = await runAction(context, () async {
        await ref.read(ownerApiProvider).updateTrip(editing.id, body);
        refreshAfter(ref, {OwnerArea.trips});
        navigator.pop();
      });
      if (!ok && mounted) setState(() => _busy = false);
      return;
    }
    final ok = await runAction(context, () async {
      final trip = await ref.read(ownerApiProvider).createTrip(body);
      refreshAfter(ref, {OwnerArea.trips});
      await navigator.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OwnerTripDetailScreen(tripId: trip.id),
        ),
      );
    });
    if (!ok && mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final local = _tripType == 'local_rental';
    // Who is already booked in this window: shown greyed out in the pickers,
    // and a pick that becomes busy when the times change is cleared.
    final window = !_editing && _end.isAfter(_start)
        ? (from: _start, to: _end, excludeTripId: null)
        : null;
    final availability = window == null
        ? Availability.none
        : ref.watch(availabilityProvider(window)).value ?? Availability.none;
    if (window != null) {
      ref.listen(availabilityProvider(window), (_, next) {
        final a = next.value;
        if (a == null) return;
        final vehicleBusy = a.vehicles.containsKey(_vehicleId);
        final driverBusy = a.drivers.containsKey(_driverId);
        if (!vehicleBusy && !driverBusy) return;
        setState(() {
          if (vehicleBusy) _vehicleId = null;
          if (driverBusy) _driverId = null;
          _cleared = true;
        });
      });
    }
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? l.editTrip : l.newTrip)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  segments: [
                    for (final t in const [
                      'one_way',
                      'round_trip',
                      'local_rental',
                    ])
                      ButtonSegment(value: t, label: Text(tripTypeLabel(l, t))),
                  ],
                  selected: {_tripType},
                  onSelectionChanged: (s) =>
                      setState(() => _tripType = s.first),
                ),
                const SizedBox(height: 12),
                // Picking a suggested city also drops the pin there.
                PlaceField(
                  fieldKey: const Key('owner-trip-from'),
                  controller: _from,
                  decoration: InputDecoration(
                    labelText: l.pickup,
                    prefixIcon: const Icon(Icons.trip_origin),
                  ),
                  onPicked: (s) => setState(() => _fromPoint = s.point),
                ),
                PinField(
                  key: const Key('owner-trip-from-pin'),
                  title: l.pickupOnMap,
                  value: _fromPoint,
                  near: _toPoint,
                  onChanged: (p) => setState(() => _fromPoint = p),
                ),
                if (!local) ...[
                  const SizedBox(height: 12),
                  PlaceField(
                    fieldKey: const Key('owner-trip-to'),
                    controller: _to,
                    decoration: InputDecoration(
                      labelText: l.drop,
                      prefixIcon: const Icon(Icons.place),
                    ),
                    onPicked: (s) => setState(() => _toPoint = s.point),
                  ),
                  PinField(
                    key: const Key('owner-trip-to-pin'),
                    title: l.dropOnMap,
                    value: _toPoint,
                    near: _fromPoint,
                    onChanged: (p) => setState(() => _toPoint = p),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: l.starts,
                        text: fmt.dayTime(_start),
                        onTap: () async {
                          final picked = await _pick(_start);
                          if (picked == null) return;
                          setState(() {
                            final length = _end.difference(_start);
                            _start = picked;
                            _end = picked.add(length);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(
                        label: l.ends,
                        text: fmt.dayTime(_end),
                        onTap: () async {
                          final picked = await _pick(_end);
                          if (picked != null) setState(() => _end = picked);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('owner-trip-fare'),
                        controller: _fare,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l.quotedFare,
                          prefixText: '₹ ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        key: const Key('owner-trip-km'),
                        controller: _km,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: l.includedKm,
                          helperText: l.includedKmHint,
                          helperMaxLines: 2,
                          suffixText: l.unitKm,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customer,
                  decoration: InputDecoration(
                    labelText: l.customerNameOptional,
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l.customerMobileOptional,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                ),
                if (!_editing) ...[
                  const SizedBox(height: 12),
                  // Only linked pairs can be assigned: the drivers follow the
                  // vehicle, and with no vehicle yet, the vehicles follow the driver.
                  VehiclePicker(
                    value: _vehicleId,
                    label: l.vehicleOptional,
                    noneLabel: l.assignLater,
                    driverId: _vehicleId == null ? _driverId : null,
                    busy: availability.vehicles,
                    onChanged: (v) => setState(() {
                      _cleared = false;
                      _vehicleId = v;
                      final driver = _driverId;
                      if (v != null &&
                          driver != null &&
                          !pairLinked(ref, v, driver)) {
                        _driverId = null;
                      }
                    }),
                  ),
                  const SizedBox(height: 12),
                  DriverPicker(
                    value: _driverId,
                    label: l.driverOptional,
                    noneLabel: l.assignLater,
                    vehicleId: _vehicleId,
                    busy: availability.drivers,
                    onChanged: (v) => setState(() {
                      _cleared = false;
                      _driverId = v;
                    }),
                  ),
                  if (_cleared) ...[
                    const SizedBox(height: 8),
                    Text(
                      l.busyPickCleared,
                      key: const Key('busy-pick-cleared'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
                if (_problem != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _problem!,
                    key: const Key('owner-trip-problem'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: Key(_editing ? 'owner-save-trip' : 'owner-create-trip'),
                  onPressed: _busy ? null : _save,
                  icon: Icon(_editing ? Icons.check : Icons.add),
                  label: Text(_editing ? l.save : l.createTrip),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.text,
    required this.onTap,
  });

  final String label;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.schedule),
      ),
      child: Text(text),
    ),
  );
}
