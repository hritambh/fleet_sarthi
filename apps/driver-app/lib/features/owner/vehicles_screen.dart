import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_api.dart';
import '../../core/api/owner_models.dart';
import '../../l10n/app_localizations.dart';
import '../common/format.dart';
import 'documents_screen.dart';
import 'fuel_screens.dart';
import 'links.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'alerts_inbox.dart';
import 'owner_widgets.dart';
import 'vehicle_catalog.dart';
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

/// The "Other / not listed" choice, as a dropdown value no brand can collide
/// with. A heading's value is built from it too, so every item stays distinct.
const _otherOption = '__other__';

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

  /// Set when the owner picks "Other" for the brand or the model, which hands
  /// that field back to them as free text. The make and model controllers stay
  /// the source of truth either way; the dropdowns write into them, and the
  /// dropdowns read their own value back out of them.
  bool _ownBrand = false;
  bool _ownModel = false;

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

  TextField _field(
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

  /// Brand, then model. Both dropdowns lead with the cars Indian fleets
  /// actually run as cabs — the known-model list (`/vehicle-models`), which
  /// also carries each one's fuel type and seeds its fuel baseline — and follow
  /// it with the rest of what is sold in India, from the public catalogue
  /// (`/vehicle-catalog/*`). "Other" hands the field back as free text, so a
  /// vehicle can always be added even with both lists empty.
  ///
  /// The make and model text controllers stay the form's source of truth: the
  /// dropdowns write into them and read their own selection back out, which is
  /// how editing a vehicle opens on the brand and model it was saved with.
  List<Widget> _brandAndModel(AppLocalizations l, List<VehicleModel> cabs) {
    final brands = ref.watch(catalogBrandsProvider);
    final brandList = brands.value ?? const <CatalogBrand>[];
    final cabMakes = <String>{for (final m in cabs) m.make}.toList()..sort();
    // The wider list, less the brands the cab list already offers.
    final otherBrands = [
      for (final b in brandList)
        if (!cabMakes.any((make) => sameMake(make, b.name))) b.name,
    ];

    final typedMake = _fields['make']!.text;
    final make = _ownBrand
        ? null
        : [
            ...cabMakes,
            ...otherBrands,
          ].where((n) => sameMake(n, typedMake)).firstOrNull;

    final cabModels = make == null
        ? const <VehicleModel>[]
        : [
            for (final m in cabs)
              if (sameMake(m.make, make)) m,
          ];
    // The chosen brand in the wider catalogue, which is what lists its models.
    final catalogBrand = make == null ? null : brandForMake(brandList, make);
    final catalogModels = catalogBrand == null
        ? null
        : ref.watch(catalogModelsProvider(catalogBrand.id));
    final otherModels = [
      for (final name in catalogModels?.value ?? const <String>[])
        if (!cabModels.any((m) => sameName(m.model, name))) name,
    ];

    final typedModel = _fields['model']!.text;
    final model = _ownModel || make == null
        ? null
        : [
            ...cabModels.map((m) => m.model),
            ...otherModels,
          ].where((n) => sameName(n, typedModel)).firstOrNull;

    void chooseBrand(String? value) => setState(() {
      _ownBrand = value == _otherOption;
      _ownModel = false;
      _modelId = null;
      _fields['model']!.clear();
      if (!_ownBrand && value != null) _fields['make']!.text = value;
    });

    void chooseModel(String? value) => setState(() {
      _ownModel = value == _otherOption;
      if (_ownModel || value == null) return;
      _fields['model']!.text = value;
      // A cab-list model brings its id, which seeds the fuel baseline, and the
      // fuel type it is usually bought as.
      final row = cabModels.where((m) => m.model == value).firstOrNull;
      _modelId = row?.id;
      if (row != null) _fuelType = row.fuelType;
    });

    return [
      _picker(
        key: 'vehicle-brand',
        label: l.brand,
        value: _ownBrand ? _otherOption : make,
        groups: [
          (l.cabModelsGroup, cabMakes),
          (l.indiaModelsGroup, otherBrands),
        ],
        other: l.otherModel,
        helper: brands.hasError ? l.catalogUnavailable : null,
        onChanged: chooseBrand,
      ),
      if (_ownBrand ||
          (!brands.isLoading && brandList.isEmpty && cabMakes.isEmpty)) ...[
        const SizedBox(height: 12),
        _field('make', l.make),
      ],
      const SizedBox(height: 12),
      if (make != null)
        _picker(
          key: 'vehicle-model-pick',
          label: l.model,
          value: _ownModel ? _otherOption : model,
          groups: [
            (l.cabModelsGroup, [for (final m in cabModels) m.model]),
            (l.indiaModelsGroup, otherModels),
          ],
          other: l.otherModel,
          helper: catalogModels?.hasError ?? false
              ? l.catalogUnavailable
              : null,
          onChanged: chooseModel,
        ),
      if (make == null || _ownModel) ...[
        if (make != null) const SizedBox(height: 12),
        _field('model', l.model),
      ],
    ];
  }

  /// A dropdown over named groups of options, each group under a heading that
  /// only appears when more than one group has anything in it, with "Other"
  /// last. [key] stays put while the shown value changes, which a FormField
  /// only picks up from a fresh key of its own.
  Widget _picker({
    required String key,
    required String label,
    required String? value,
    required List<(String, List<String>)> groups,
    required String other,
    required String? helper,
    required void Function(String?) onChanged,
  }) {
    final filled = groups.where((g) => g.$2.isNotEmpty).toList();
    final headings = filled.length > 1;
    var heading = 0;
    return KeyedSubtree(
      key: Key(key),
      child: DropdownButtonFormField<String?>(
        key: ValueKey('$key-$value'),
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, helperText: helper),
        items: [
          for (final (name, options) in filled) ...[
            if (headings)
              DropdownMenuItem<String?>(
                enabled: false,
                value: '$_otherOption-heading-${heading++}',
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            for (final option in options)
              DropdownMenuItem<String?>(value: option, child: Text(option)),
          ],
          DropdownMenuItem<String?>(value: _otherOption, child: Text(other)),
        ],
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final models = ref.watch(vehicleModelsProvider).value ?? const [];
    final drivers = widget.vehicle == null
        ? ref.watch(driversProvider).value ?? const <Driver>[]
        : const <Driver>[];
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
                _field('registrationNo', l.registrationNumber),
                const SizedBox(height: 12),
                ..._brandAndModel(l, models),
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
                _field('year', l.year, keyboard: TextInputType.number),
                const SizedBox(height: 12),
                _field(
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
    final filter = TripFilter(vehicleIds: {vehicleId}, limit: 50);
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
