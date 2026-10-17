// Which drivers may drive which vehicles. A trip can only pair a driver with a
// vehicle they're linked to, so owners and managers edit the links from either
// side (a vehicle's drivers, a driver's vehicles) with the same multi-select
// sheet, and the add-vehicle and invite-driver forms can set them up front.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_models.dart';
import '../../l10n/app_localizations.dart';
import '../common/errors.dart';
import '../common/format.dart';
import 'owner_providers.dart';
import 'owner_text.dart';

/// One choice in the links sheet.
class LinkOption {
  const LinkOption({required this.id, required this.label, this.subtitle});
  final String id;
  final String label;
  final String? subtitle;
}

/// The fleet's active drivers as choices, plus any inactive ones in [keep]
/// (already linked), so saving doesn't drop them by accident.
List<LinkOption> driverOptions(
  AppLocalizations l,
  List<Driver> drivers, {
  Set<String> keep = const {},
}) => [
  for (final d in drivers)
    if (d.isActive || keep.contains(d.id))
      LinkOption(
        id: d.id,
        label: d.name,
        subtitle: [
          formatPhone(d.phone),
          if (!d.isActive) l.inactive,
        ].join(' · '),
      ),
];

/// The fleet's active vehicles as choices, plus any inactive ones in [keep].
List<LinkOption> vehicleOptions(
  AppLocalizations l,
  List<Vehicle> vehicles, {
  Set<String> keep = const {},
}) => [
  for (final v in vehicles)
    if (v.isActive || keep.contains(v.id))
      LinkOption(
        id: v.id,
        label: formatRegistration(v.registrationNo),
        subtitle: [
          '${v.make} ${v.model}'.trim(),
          if (!v.isActive) l.inactive,
        ].join(' · '),
      ),
];

/// Opens the multi-select sheet. With [onSave], the sheet saves the choice
/// itself (showing any error in place) and closes once it worked; without, it
/// just returns the choice. Null when dismissed.
Future<Set<String>?> pickLinks(
  BuildContext context, {
  required String title,
  required List<LinkOption> options,
  required Set<String> selected,
  required String emptyText,
  String? intro,
  Future<void> Function(Set<String> ids)? onSave,
}) => showModalBottomSheet<Set<String>>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => LinksSheet(
    title: title,
    intro: intro,
    options: options,
    selected: selected,
    emptyText: emptyText,
    onSave: onSave,
  ),
);

class LinksSheet extends StatefulWidget {
  const LinksSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.emptyText,
    this.intro,
    this.onSave,
    super.key,
  });

  final String title;
  final String? intro;
  final List<LinkOption> options;
  final Set<String> selected;
  final String emptyText;
  final Future<void> Function(Set<String> ids)? onSave;

  @override
  State<LinksSheet> createState() => _LinksSheetState();
}

class _LinksSheetState extends State<LinksSheet> {
  late final Set<String> _selected = {...widget.selected};
  String? _error;
  bool _busy = false;

  Future<void> _save() async {
    final onSave = widget.onSave;
    final navigator = Navigator.of(context);
    if (onSave == null) {
      navigator.pop(_selected);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await onSave(_selected);
      navigator.pop(_selected);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = errorText(context.l10n, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            if (widget.intro != null) ...[
              const SizedBox(height: 4),
              Text(widget.intro!, style: TextStyle(color: context.tc.muted)),
            ],
            const SizedBox(height: 8),
            Flexible(
              child: widget.options.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        widget.emptyText,
                        key: const Key('links-empty'),
                        style: TextStyle(color: context.tc.muted),
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (final o in widget.options)
                          CheckboxListTile(
                            key: ValueKey('link-${o.id}'),
                            contentPadding: EdgeInsets.zero,
                            value: _selected.contains(o.id),
                            title: Text(o.label),
                            subtitle: o.subtitle == null || o.subtitle!.isEmpty
                                ? null
                                : Text(o.subtitle!),
                            onChanged: _busy
                                ? null
                                : (on) => setState(() {
                                    if (on ?? false) {
                                      _selected.add(o.id);
                                    } else {
                                      _selected.remove(o.id);
                                    }
                                  }),
                          ),
                      ],
                    ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                key: const Key('links-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  child: Text(l.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const Key('links-save'),
                  onPressed: _busy ? null : _save,
                  child: Text(l.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// What's linked, as chips, or [emptyText] when nothing is.
class LinkChips extends StatelessWidget {
  const LinkChips({required this.labels, required this.emptyText, super.key});
  final List<String> labels;
  final String emptyText;

  @override
  Widget build(BuildContext context) => labels.isEmpty
      ? Text(
          emptyText,
          key: const Key('links-none'),
          style: TextStyle(color: context.tc.muted),
        )
      : Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final label in labels)
              Chip(label: Text(label), visualDensity: VisualDensity.compact),
          ],
        );
}

/// A form field for picking links before the vehicle or driver exists: shows
/// the choice and opens the sheet on tap.
class LinkSelectField extends StatelessWidget {
  const LinkSelectField({
    required this.label,
    required this.helper,
    required this.sheetTitle,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.emptyText,
    super.key,
  });

  final String label;
  final String helper;
  final String sheetTitle;
  final List<LinkOption> options;
  final Set<String> value;
  final ValueChanged<Set<String>> onChanged;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final chosen = [
      for (final o in options)
        if (value.contains(o.id)) o.label,
    ];
    return InkWell(
      onTap: () async {
        final picked = await pickLinks(
          context,
          title: sheetTitle,
          options: options,
          selected: value,
          emptyText: emptyText,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 2,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          chosen.isEmpty ? context.l10n.noneSelected : chosen.join(', '),
        ),
      ),
    );
  }
}

/// Whether [driverId] may drive [vehicleId], by the fleet's vehicles. True
/// while they're loading (the server checks anyway).
bool pairLinked(WidgetRef ref, String vehicleId, String driverId) {
  final vehicles = ref.read(fleetVehiclesProvider).value;
  final vehicle = vehicles?.where((v) => v.id == vehicleId).firstOrNull;
  return vehicle?.isLinkedTo(driverId) ?? true;
}
