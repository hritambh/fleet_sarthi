import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_api.dart';
import '../../core/api/owner_models.dart';
import '../common/format.dart';
import 'documents_screen.dart';
import 'fuel_screens.dart';
import 'links.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'alerts_inbox.dart';
import 'owner_widgets.dart';
import 'trips/owner_trips_screen.dart';
import 'trip_schedule.dart';

const fuelTypes = ['petrol', 'diesel', 'cng', 'petrol_cng'];

/// The fleet's vehicles; tap one for its documents, fuel audit and trips.
class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final vehicles = ref.watch(fleetVehiclesProvider);
    final action = PageAction(
      key: const Key('add-vehicle'),
      icon: Icons.add,
      label: l.addVehicle,
      onPressed: () => openScreen<void>(context, const VehicleFormScreen()),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l.vehicles),
        actions: [const AlertsBell(), ...action.headerActions(context)],
      ),
      floatingActionButton: action.fab(context),
      body: RefreshPage(
        onRefresh: () => ref.refresh(fleetVehiclesProvider.future),
        children: [
          AsyncView(
            value: vehicles,
            onRetry: () => ref.invalidate(fleetVehiclesProvider),
            builder: (list) => list.isEmpty
                ? EmptyState(l.noVehiclesYet)
                : isDesktop(context)
                ? _VehicleGrid(list)
                : Column(
                    children: [
                      for (final v in list)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            key: ValueKey('vehicle-${v.id}'),
                            leading: const Icon(Icons.directions_car),
                            title: Text(
                              formatRegistration(v.registrationNo),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  [
                                    '${v.make} ${v.model}'.trim(),
                                    if (v.year != null) '${v.year}',
                                    fuelName(l, v.fuelType),
                                    if (v.lastOdometerKm != null)
                                      fmt.km(v.lastOdometerKm!),
                                  ].join(' · '),
                                ),
                                DocumentsDueChip(vehicleId: v.id),
                              ],
                            ),
                            trailing: ToneChip(
                              v.isActive ? l.active : l.inactive,
                              tone: v.isActive ? Tone.success : Tone.neutral,
                            ),
                            onTap: () => openScreen<void>(
                              context,
                              VehicleDetailScreen(vehicleId: v.id),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Vehicles as cards on the desktop.
class _VehicleGrid extends StatelessWidget {
  const _VehicleGrid(this.vehicles);
  final List<Vehicle> vehicles;

  @override
  Widget build(BuildContext context) =>
      CardGrid(children: [for (final v in vehicles) _VehicleCard(v)]);
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard(this.v);
  final Vehicle v;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('vehicle-${v.id}'),
        onTap: () =>
            openScreen<void>(context, VehicleDetailScreen(vehicleId: v.id)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: NumberPlate(formatRegistration(v.registrationNo)),
                  ),
                  const SizedBox(width: 8),
                  const Spacer(),
                  DocumentsDueChip(vehicleId: v.id),
                  const SizedBox(width: 6),
                  ToneChip(
                    v.isActive ? l.active : l.inactive,
                    tone: v.isActive ? Tone.success : Tone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: TaxcyColors.blue50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: TaxcyColors.blue700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${v.make} ${v.model}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          [
                            fuelName(l, v.fuelType),
                            if (v.year != null) '${v.year}',
                          ].join(' · '),
                          style: const TextStyle(color: TaxcyColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.speed, size: 18, color: TaxcyColors.muted),
                  const SizedBox(width: 6),
                  Text(
                    v.lastOdometerKm == null ? '–' : fmt.km(v.lastOdometerKm!),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: TaxcyColors.muted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The body for POST/PATCH /vehicles, or the problem with the input.
({Map<String, Object?>? body, String? problem}) vehicleBody(
  String Function(String key) text, {
  required String registrationInvalid,
  required String requiredText,
  required String fuelType,
  String? vehicleModelId,
  String? status,
}) {
  final reg = normalizeRegistration(text('registrationNo'));
  if (reg == null) return (body: null, problem: registrationInvalid);
  if (text('make').trim().isEmpty || text('model').trim().isEmpty) {
    return (body: null, problem: requiredText);
  }
  final year = int.tryParse(text('year'));
  final km = int.tryParse(text('odometer'));
  return (
    body: {
      'registrationNo': reg,
      'make': text('make').trim(),
      'model': text('model').trim(),
      'fuelType': fuelType,
      'year': ?year,
      'vehicleModelId': ?vehicleModelId,
      'lastOdometerKm': ?km,
      'status': ?status,
    },
    problem: null,
  );
}

/// Adds a vehicle, or edits [vehicle] (including deactivating it).
class VehicleFormScreen extends ConsumerStatefulWidget {
  const VehicleFormScreen({this.vehicle, super.key});
  final Vehicle? vehicle;

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  late final Map<String, TextEditingController> _fields = {
    'registrationNo': TextEditingController(
      text: widget.vehicle == null
          ? ''
          : formatRegistration(widget.vehicle!.registrationNo),
    ),
    'make': TextEditingController(text: widget.vehicle?.make ?? ''),
    'model': TextEditingController(text: widget.vehicle?.model ?? ''),
    'year': TextEditingController(text: widget.vehicle?.year?.toString() ?? ''),
    'odometer': TextEditingController(
      text: widget.vehicle?.lastOdometerKm?.toString() ?? '',
    ),
  };
  late String _fuelType = widget.vehicle?.fuelType ?? 'diesel';
  late String? _modelId = widget.vehicle?.vehicleModelId;
  late String _status = widget.vehicle?.status ?? 'active';

  /// Drivers to link when adding; an existing vehicle's are edited on its page.
  /// Null until the owner changes it: every active driver.
  Set<String>? _driverIds;

  Set<String> _chosenDrivers(List<Driver> drivers) =>
      _driverIds ??
      {
        for (final d in drivers)
          if (d.isActive) d.id,
      };
  String? _problem;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final editing = widget.vehicle;
    final result = vehicleBody(
      (key) => _fields[key]!.text,
      registrationInvalid: l.registrationInvalid,
      requiredText: l.required,
      fuelType: _fuelType,
      vehicleModelId: _modelId,
      status: editing == null ? null : _status,
    );
    setState(() => _problem = result.problem);
    final body = result.body;
    if (body == null) return;
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final ok = await runAction(context, () async {
      final api = ref.read(ownerApiProvider);
      if (editing == null) {
        final driverIds = _chosenDrivers(
          ref.read(driversProvider).value ?? const [],
        );
        await api.createVehicle({
          ...body,
          if (driverIds.isNotEmpty) 'driverIds': driverIds.toList(),
        });
      } else {
        await api.updateVehicle(editing.id, body);
      }
      refreshAfter(ref, {OwnerArea.fleet});
    });
    if (ok) {
      navigator.pop();
    } else if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final models = ref.watch(vehicleModelsProvider).value ?? const [];
    final drivers = widget.vehicle == null
        ? ref.watch(driversProvider).value ?? const <Driver>[]
        : const <Driver>[];
    TextField field(
      String key,
      String label, {
      TextInputType? keyboard,
      String? helper,
    }) => TextField(
      key: Key('vehicle-$key'),
      controller: _fields[key],
      keyboardType: keyboard,
      inputFormatters: keyboard == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      textCapitalization: key == 'registrationNo'
          ? TextCapitalization.characters
          : TextCapitalization.words,
      decoration: InputDecoration(labelText: label, helperText: helper),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? l.addVehicle : l.editVehicle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                field('registrationNo', l.registrationNumber),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: models.any((m) => m.id == _modelId)
                      ? _modelId
                      : null,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l.knownModel,
                    helperText: l.knownModelHint,
                  ),
                  items: [
                    DropdownMenuItem<String?>(child: Text(l.otherModel)),
                    for (final m in models)
                      DropdownMenuItem<String?>(
                        value: m.id,
                        child: Text(
                          '${m.make} ${m.model} (${fuelName(l, m.fuelType)})',
                        ),
                      ),
                  ],
                  onChanged: (id) => setState(() {
                    _modelId = id;
                    final m = models.where((m) => m.id == id).firstOrNull;
                    if (m != null) {
                      _fields['make']!.text = m.make;
                      _fields['model']!.text = m.model;
                      _fuelType = m.fuelType;
                    }
                  }),
                ),
                const SizedBox(height: 12),
                field('make', l.make),
                const SizedBox(height: 12),
                field('model', l.model),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey('fuel-$_fuelType'),
                  isExpanded: true,
                  initialValue: _fuelType,
                  decoration: InputDecoration(labelText: l.fuelType),
                  items: [
                    for (final f in fuelTypes)
                      DropdownMenuItem(value: f, child: Text(fuelName(l, f))),
                  ],
                  onChanged: (v) => setState(() => _fuelType = v ?? _fuelType),
                ),
                const SizedBox(height: 12),
                field('year', l.year, keyboard: TextInputType.number),
                const SizedBox(height: 12),
                field(
                  'odometer',
                  l.currentOdometer,
                  keyboard: TextInputType.number,
                ),
                if (widget.vehicle == null) ...[
                  const SizedBox(height: 12),
                  LinkSelectField(
                    key: const Key('vehicle-drivers'),
                    label: l.driversOptional,
                    helper: l.driversOptionalHint,
                    sheetTitle: l.drivers,
                    options: driverOptions(l, drivers),
                    value: _chosenDrivers(drivers),
                    emptyText: l.noDriversToLink,
                    onChanged: (ids) => setState(() => _driverIds = ids),
                  ),
                ],
                if (widget.vehicle != null) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: const Key('vehicle-status'),
                    isExpanded: true,
                    initialValue: _status,
                    decoration: InputDecoration(labelText: l.status),
                    items: [
                      DropdownMenuItem(value: 'active', child: Text(l.active)),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text(l.inactiveVehicleOption),
                      ),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                ],
                if (_problem != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _problem!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  key: const Key('vehicle-save'),
                  onPressed: _busy ? null : _save,
                  child: Text(widget.vehicle == null ? l.addVehicle : l.save),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One vehicle: summary, then its documents, fuel audit and recent trips.
class VehicleDetailScreen extends ConsumerWidget {
  const VehicleDetailScreen({required this.vehicleId, super.key});
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final vehicle = ref.watch(fleetVehicleProvider(vehicleId));
    final v = vehicle.value;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            v == null ? l.vehicle : formatRegistration(v.registrationNo),
          ),
          actions: [
            if (v != null) ...[
              IconButton(
                tooltip: l.edit,
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    openScreen<void>(context, VehicleFormScreen(vehicle: v)),
              ),
              IconButton(
                key: const Key('vehicle-toggle-active'),
                tooltip: v.isActive ? l.deactivate : l.activate,
                icon: Icon(
                  v.isActive ? Icons.block : Icons.check_circle_outline,
                ),
                onPressed: () => runAction(context, () async {
                  await ref.read(ownerApiProvider).updateVehicle(v.id, {
                    'status': v.isActive ? 'inactive' : 'active',
                  });
                  refreshAfter(ref, {OwnerArea.fleet});
                }),
              ),
            ],
          ],
          bottom: ownerTabBar(context, [
            Tab(text: l.documents),
            Tab(text: l.fuel),
            Tab(key: const Key('tab-schedule'), text: l.schedule),
            Tab(text: l.recentTrips),
          ]),
        ),
        body: AsyncView(
          value: vehicle,
          onRetry: () => ref.invalidate(fleetVehicleProvider(vehicleId)),
          builder: (v) => Column(
            children: [
              PageWidth(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: StatGrid([
                    StatTile(
                      label: l.model,
                      value: '${v.make} ${v.model}'.trim(),
                      hint: v.year?.toString(),
                    ),
                    StatTile(label: l.fuelType, value: fuelName(l, v.fuelType)),
                    StatTile(
                      label: l.lastOdometer,
                      value: v.lastOdometerKm == null
                          ? l.noValue
                          : fmt.km(v.lastOdometerKm!),
                    ),
                    StatTile(
                      label: l.status,
                      value: v.isActive ? l.active : l.inactive,
                    ),
                  ]),
                ),
              ),
              PageWidth(child: VehicleDriversSection(vehicle: v)),
              Expanded(
                child: TabBarView(
                  children: [
                    _VehicleDocuments(vehicleId),
                    VehicleFuelPanel(vehicleId: vehicleId),
                    TripSchedule(vehicleId: vehicleId),
                    _VehicleTrips(vehicleId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Who may drive [vehicle], with "Edit drivers".
class VehicleDriversSection extends ConsumerWidget {
  const VehicleDriversSection({required this.vehicle, super.key});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final drivers = ref.watch(driversProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.drivers,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton.icon(
                key: const Key('edit-vehicle-drivers'),
                icon: const Icon(Icons.people_alt_outlined, size: 18),
                label: Text(l.editDrivers),
                onPressed: drivers.isLoading
                    ? null
                    : () => editVehicleDrivers(
                        context,
                        ref,
                        vehicle,
                        drivers.value ?? const [],
                      ),
              ),
            ],
          ),
          LinkChips(
            labels: [for (final d in vehicle.drivers) d.name],
            emptyText: l.noLinkedDrivers,
          ),
        ],
      ),
    );
  }
}

/// Opens the sheet for who may drive [vehicle] and saves the choice.
Future<void> editVehicleDrivers(
  BuildContext context,
  WidgetRef ref,
  Vehicle vehicle,
  List<Driver> drivers,
) async {
  final l = context.l10n;
  final linked = {for (final d in vehicle.drivers) d.id};
  final saved = await pickLinks(
    context,
    title: l.editDrivers,
    intro: l.editDriversIntro(
      vehicle: formatRegistration(vehicle.registrationNo),
    ),
    options: driverOptions(l, drivers, keep: linked),
    // Nothing linked yet: start with every driver ticked.
    selected: linked.isEmpty
        ? {
            for (final d in drivers)
              if (d.isActive) d.id,
          }
        : linked,
    emptyText: l.noDriversToLink,
    onSave: (ids) =>
        ref.read(ownerApiProvider).setVehicleDrivers(vehicle.id, ids.toList()),
  );
  if (saved != null) refreshAfter(ref, {OwnerArea.fleet});
}

class _VehicleDocuments extends ConsumerWidget {
  const _VehicleDocuments(this.vehicleId);
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = (
      vehicleId: vehicleId,
      driverId: null,
      expiringWithinDays: null,
    );
    return RefreshPage(
      onRefresh: () => ref.refresh(documentsProvider(query).future),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            key: const Key('vehicle-add-document'),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.addDocument),
            onPressed: () => openScreen<void>(
              context,
              DocumentFormScreen(vehicleId: vehicleId),
            ),
          ),
        ),
        DocumentsList(query: query),
      ],
    );
  }
}

class _VehicleTrips extends ConsumerWidget {
  const _VehicleTrips(this.vehicleId);
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = TripFilter(vehicleId: vehicleId, limit: 50);
    final trips = ref.watch(ownerTripsProvider(filter));
    return RefreshPage(
      onRefresh: () => ref.refresh(ownerTripsProvider(filter).future),
      children: [
        AsyncView(
          value: trips,
          onRetry: () => ref.invalidate(ownerTripsProvider(filter)),
          builder: (list) => list.isEmpty
              ? EmptyState(context.l10n.noTripsShort)
              : Column(children: [for (final t in list) OwnerTripTile(t)]),
        ),
      ],
    );
  }
}
