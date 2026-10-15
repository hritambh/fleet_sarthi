import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_models.dart';
import '../common/errors.dart';
import '../common/format.dart';
import 'owner_providers.dart';
import 'owner_text.dart';

/// Content width on wide screens (tablets).
const ownerMaxWidth = 960.0;

/// From this width owner mode uses the desktop layout: a sidebar, wider pages,
/// tables and multi-column dashboards (the web build on a laptop or monitor).
const desktopMinWidth = 1100.0;

/// Content width in the desktop layout.
const desktopMaxWidth = 1320.0;

bool isDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= desktopMinWidth;

/// Centres [child] and caps its width, so lists don't stretch across a desktop.
class PageWidth extends StatelessWidget {
  const PageWidth({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isDesktop(context) ? desktopMaxWidth : ownerMaxWidth,
      ),
      // Narrower content (a filter, a short card) lines up on the left
      // instead of centring; it keeps its own width.
      child: Align(alignment: AlignmentDirectional.topStart, child: child),
    ),
  );
}

/// A page's main action ("Add vehicle"): a button in the header on the
/// desktop, a floating button on phones.
class PageAction {
  const PageAction({
    required this.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Key key;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  List<Widget> headerActions(BuildContext context) => isDesktop(context)
      ? [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: FilledButton.icon(
              key: key,
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            ),
          ),
        ]
      : const [];

  Widget? fab(BuildContext context) => isDesktop(context)
      ? null
      : FloatingActionButton.extended(
          key: key,
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        );
}

/// Loading spinner, an error with a retry button, or the data. Owner mode is
/// online-first, so every screen goes through this.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    required this.value,
    required this.onRetry,
    required this.builder,
    super.key,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) => switch (value) {
    AsyncData(:final value) => builder(value),
    AsyncError(:final error) => ErrorPanel(error: error, onRetry: onRetry),
    _ => const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator()),
    ),
  };
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({required this.error, required this.onRetry, super.key});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_off, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 8),
        Text(context.l10n.loadFailed, textAlign: TextAlign.center),
        Text(
          errorText(context.l10n, error),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('retry'),
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.retry),
        ),
      ],
    ),
  );
}

/// A scrollable page with pull-to-refresh.
class RefreshPage extends StatelessWidget {
  const RefreshPage({
    required this.onRefresh,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 96),
    super.key,
  });

  final Future<void> Function() onRefresh;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      // More breathing room around desktop pages.
      padding: isDesktop(context)
          ? padding.copyWith(left: 28, right: 28, top: 24)
          : padding,
      children: [for (final child in children) PageWidth(child: child)],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: TaxcyColors.muted),
    ),
  );
}

/// A titled white card with optional actions on the right of the title.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.title,
    this.actions = const [],
    super.key,
  });

  final String? title;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  else
                    const Spacer(),
                  ...actions,
                ],
              ),
            ),
          child,
        ],
      ),
    ),
  );
}

/// A small label above a value, for summary grids.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    this.hint,
    this.valueColor,
    super.key,
  });

  final String label;
  final String value;
  final String? hint;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: TaxcyColors.muted, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: valueColor,
          ),
        ),
        if (hint != null)
          Text(
            hint!,
            style: const TextStyle(color: TaxcyColors.muted, fontSize: 12),
          ),
      ],
    ),
  );
}

/// A headline number on the desktop dashboard: a tinted icon, the value large,
/// a label and an optional hint; clickable when [onTap] is set.
class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    this.hint,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: accent, width: 3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: TaxcyColors.blue950,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: TaxcyColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hint != null)
                    Text(
                      hint!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: TaxcyColors.muted,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A dashboard headline: icon and an optional pill on top, the label, a large
/// value with a smaller suffix ("18 / 24"), then an optional progress bar,
/// footer line and link. [highlight] tints it orange for "needs action".
class KpiCard extends StatelessWidget {
  const KpiCard({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    this.suffix,
    this.pill,
    this.progress,
    this.footer,
    this.link,
    this.highlight = false,
    this.badge,
    this.detail,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final String? suffix;
  final String? pill;

  /// 0 to 1.
  final double? progress;
  final String? footer;

  /// A call to action at the bottom, e.g. "Resolve queue".
  final String? link;
  final bool highlight;

  /// Shown top right instead of [pill].
  final Widget? badge;

  /// Shown under the value instead of [progress] and [footer].
  final Widget? detail;
  final VoidCallback? onTap;

  static const _orange = Color(0xFFF08A24);

  @override
  Widget build(BuildContext context) {
    final tint = highlight ? _orange : accent;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: highlight ? const Color(0xFFFDE7D3) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: highlight
                          ? _orange
                          : accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: highlight ? Colors.white : accent,
                    ),
                  ),
                  const Spacer(),
                  if (badge case final badge?)
                    Flexible(child: badge)
                  else if (pill != null)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: highlight
                              ? TaxcyColors.ink
                              : tint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          pill!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: highlight ? Colors.white : tint,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: TaxcyColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: TaxcyColors.blue950,
                  ),
                  children: [
                    if (suffix != null)
                      TextSpan(
                        text: ' $suffix',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: TaxcyColors.muted,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (detail case final detail?) ...[
                const SizedBox(height: 10),
                detail,
              ] else if (progress != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress!.clamp(0, 1),
                    minHeight: 6,
                    color: tint,
                    backgroundColor: TaxcyColors.border,
                  ),
                ),
              ],
              if (detail == null && footer != null) ...[
                const SizedBox(height: 8),
                Text(
                  footer!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TaxcyColors.muted,
                  ),
                ),
              ],
              if (link != null) ...[
                const SizedBox(height: 8),
                Text(
                  link!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    color: TaxcyColors.ink,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StatGrid extends StatelessWidget {
  const StatGrid(this.children, {super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 12, runSpacing: 12, children: children);
}

/// A coloured pill: green for good, amber for attention, red for bad, blue otherwise.
class ToneChip extends StatelessWidget {
  const ToneChip(this.text, {this.tone = Tone.neutral, super.key});
  final String text;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      Tone.success => (Colors.green.shade50, Colors.green.shade800),
      Tone.warning => (Colors.amber.shade50, Colors.amber.shade900),
      Tone.danger => (Colors.red.shade50, Colors.red.shade800),
      Tone.brand => (TaxcyColors.blue100, TaxcyColors.blue900),
      Tone.neutral => (TaxcyColors.blue50, TaxcyColors.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum Tone { success, warning, danger, brand, neutral }

Tone severityTone(String severity) => switch (severity) {
  'critical' => Tone.danger,
  'warning' => Tone.warning,
  _ => Tone.brand,
};

class SeverityChip extends StatelessWidget {
  const SeverityChip(this.severity, {super.key});
  final String severity;

  @override
  Widget build(BuildContext context) => ToneChip(
    severityLabel(context.l10n, severity),
    tone: severityTone(severity),
  );
}

/// Runs an owner action: shows the error (translated) in a snackbar if it
/// fails, and [done] if given when it succeeds. Returns whether it worked.
Future<bool> runAction(
  BuildContext context,
  Future<void> Function() action, {
  String? done,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l = context.l10n;
  try {
    await action();
    if (done != null) messenger.showSnackBar(SnackBar(content: Text(done)));
    return true;
  } on Object catch (error) {
    messenger.showSnackBar(
      SnackBar(
        key: const Key('action-error'),
        content: Text(errorText(l, error)),
      ),
    );
    return false;
  }
}

/// Tabs under a page header: dark on the desktop's white header
/// (desktopContentTheme), white on the phone's blue bar. Scrollable, so long
/// Hindi labels fit on a narrow phone.
TabBar ownerTabBar(BuildContext context, List<Widget> tabs) {
  final desktop = isDesktop(context);
  return TabBar(
    isScrollable: true,
    tabAlignment: TabAlignment.start,
    labelColor: desktop ? TaxcyColors.blue800 : Colors.white,
    unselectedLabelColor: desktop ? TaxcyColors.ink : TaxcyColors.blue100,
    indicatorColor: desktop ? TaxcyColors.blue700 : Colors.white,
    tabs: tabs,
  );
}

/// Pushes [screen] on the root navigator.
Future<T?> openScreen<T>(BuildContext context, Widget screen) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => screen));

/// A dialog asking for one line (or paragraph) of text; null when cancelled.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String label,
  required String confirm,
  String? intro,
  String? hint,
  String initial = '',
  bool required = true,
  bool destructive = false,
  TextInputType keyboard = TextInputType.text,
  String? Function(String value)? validate,
}) => showDialog<String>(
  context: context,
  builder: (_) => _TextDialog(
    title: title,
    label: label,
    confirm: confirm,
    intro: intro,
    hint: hint,
    initial: initial,
    required: required,
    destructive: destructive,
    keyboard: keyboard,
    validate: validate,
  ),
);

class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.title,
    required this.label,
    required this.confirm,
    required this.initial,
    required this.required,
    required this.destructive,
    required this.keyboard,
    this.intro,
    this.hint,
    this.validate,
  });

  final String title;
  final String label;
  final String confirm;
  final String? intro;
  final String? hint;
  final String initial;
  final bool required;
  final bool destructive;
  final TextInputType keyboard;
  final String? Function(String value)? validate;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _text = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _text.text.trim();
    final error = widget.required && value.isEmpty
        ? context.l10n.required
        : widget.validate?.call(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.intro != null) ...[
            Text(widget.intro!),
            const SizedBox(height: 12),
          ],
          TextField(
            key: const Key('dialog-text'),
            controller: _text,
            autofocus: true,
            keyboardType: widget.keyboard,
            maxLines: widget.keyboard == TextInputType.text ? 3 : 1,
            minLines: 1,
            decoration: InputDecoration(
              labelText: widget.label,
              helperText: widget.hint,
              errorText: _error,
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.l10n.back),
      ),
      FilledButton(
        key: const Key('dialog-confirm'),
        style: widget.destructive
            ? FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              )
            : null,
        onPressed: _submit,
        child: Text(widget.confirm),
      ),
    ],
  );
}

/// Yes/no confirmation; true when confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirm,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(dialog.l10n.back),
          ),
          FilledButton(
            key: const Key('confirm-yes'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(confirm),
          ),
        ],
      ),
    ) ??
    false;

/// A photo stored on the server, fetched through a short-lived signed URL.
class MediaPhoto extends ConsumerWidget {
  const MediaPhoto(this.mediaId, {this.height = 160, super.key});
  final String mediaId;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(mediaUrlProvider(mediaId));
    final notUploaded = Container(
      height: 56,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: TaxcyColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.image_not_supported_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.photoNotUploaded,
              style: const TextStyle(fontSize: 12, color: TaxcyColors.muted),
            ),
          ),
        ],
      ),
    );
    return switch (url) {
      AsyncData(:final value) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          value.url,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => notUploaded,
        ),
      ),
      AsyncError() => notUploaded,
      _ => SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// Picks one of the fleet's active vehicles ('' for none, when [noneLabel] is set).
/// With [driverId], only the vehicles that driver is linked to.
class VehiclePicker extends ConsumerWidget {
  const VehiclePicker({
    required this.value,
    required this.onChanged,
    required this.label,
    this.noneLabel,
    this.activeOnly = true,
    this.driverId,
    this.busy = const {},
    super.key,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final String? noneLabel;
  final bool activeOnly;
  final String? driverId;

  /// Vehicles booked during the trip's time, by id: listed but not pickable.
  final Map<String, Busy> busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(fleetVehiclesProvider).value;
    final vehicles = loaded ?? const <Vehicle>[];
    final forDriver = driverId;
    final list = vehicles
        .where(
          (v) =>
              (!activeOnly || v.isActive || v.id == value) &&
              (forDriver == null || v.isLinkedTo(forDriver)),
        )
        .toList();
    final unlinked = forDriver != null && loaded != null && list.isEmpty;
    return DropdownButtonFormField<String?>(
      key: ValueKey('vehicle-picker-$label-$forDriver-${list.length}'),
      initialValue: list.any((v) => v.id == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        helperText: unlinked ? context.l10n.driverHasNoVehicles : null,
        helperMaxLines: 3,
      ),
      items: [
        if (noneLabel != null)
          DropdownMenuItem<String?>(child: Text(noneLabel!)),
        for (final Vehicle v in list)
          _pickerItem(
            context,
            id: v.id,
            text: '${formatRegistration(v.registrationNo)} · ${v.model}',
            busy: v.id == value ? null : busy[v.id],
          ),
      ],
      onChanged: onChanged,
    );
  }
}

/// Picks one of the fleet's active drivers ('' for none, when [noneLabel] is set).
/// With [vehicleId], only the drivers linked to that vehicle, and a hint when
/// there are none.
class DriverPicker extends ConsumerWidget {
  const DriverPicker({
    required this.value,
    required this.onChanged,
    required this.label,
    this.noneLabel,
    this.vehicleId,
    this.busy = const {},
    super.key,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final String? noneLabel;
  final String? vehicleId;

  /// Drivers booked during the trip's time, by id: listed but not pickable.
  final Map<String, Busy> busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = vehicleId == null
        ? null
        : (ref.watch(fleetVehiclesProvider).value ?? const <Vehicle>[])
              .where((v) => v.id == vehicleId)
              .firstOrNull;
    final drivers = (ref.watch(driversProvider).value ?? const [])
        .where(
          (d) =>
              (d.isActive || d.id == value) &&
              (vehicle == null || vehicle.isLinkedTo(d.id)),
        )
        .toList();
    final unlinked = vehicle != null && vehicle.drivers.isEmpty;
    return DropdownButtonFormField<String?>(
      key: ValueKey('driver-picker-$label-${vehicle?.id}-${drivers.length}'),
      initialValue: drivers.any((d) => d.id == value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        helperText: unlinked ? context.l10n.vehicleHasNoDrivers : null,
        helperMaxLines: 3,
      ),
      items: [
        if (noneLabel != null)
          DropdownMenuItem<String?>(child: Text(noneLabel!)),
        for (final d in drivers)
          _pickerItem(
            context,
            id: d.id,
            text: d.name,
            busy: d.id == value ? null : busy[d.id],
          ),
      ],
      onChanged: onChanged,
    );
  }
}

/// "Busy 2:00 pm – 6:00 pm" (with the day when it isn't the same day).
String busyText(Fmt fmt, Busy b) {
  final from = b.from.toLocal();
  final to = b.to.toLocal();
  final sameDay =
      from.year == to.year && from.month == to.month && from.day == to.day;
  return fmt.l.busyFromTo(
    from: fmt.dayTime(b.from),
    to: sameDay ? fmt.time(b.to) : fmt.dayTime(b.to),
  );
}

/// A vehicle or driver in a picker; disabled and labelled when [busy].
DropdownMenuItem<String?> _pickerItem(
  BuildContext context, {
  required String id,
  required String text,
  required Busy? busy,
}) => DropdownMenuItem<String?>(
  key: ValueKey('pick-$id'),
  value: id,
  enabled: busy == null,
  child: Text(
    busy == null ? text : '$text · ${busyText(context.fmt, busy)}',
    overflow: TextOverflow.ellipsis,
    style: busy == null ? null : const TextStyle(color: TaxcyColors.muted),
  ),
);

/// Picks a calendar date; [value] and the result are YYYY-MM-DD.
Future<String?> pickIsoDate(
  BuildContext context, {
  String? value,
  DateTime? first,
  DateTime? last,
}) async {
  final now = DateTime.now();
  final initial = value == null ? now : DateTime.parse(value);
  final picked = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first ?? DateTime(now.year - 5),
    lastDate: last ?? DateTime(now.year + 10),
  );
  if (picked == null) return null;
  return '${picked.year.toString().padLeft(4, '0')}-'
      '${picked.month.toString().padLeft(2, '0')}-'
      '${picked.day.toString().padLeft(2, '0')}';
}

/// Unawaited navigation and refreshes, for onTap handlers.
void fire(Future<void> future) => unawaited(future);

/// Whether the signed-in member is the owner (managers can't change settings
/// or pay; the server enforces it too).
final isOwnerProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).value?.isOwner ?? false,
);

/// A column of a [DesktopTable]: its header, its share of the width, and
/// whether its cells line up on the right (amounts).
class TableColumn {
  const TableColumn(this.label, {this.flex = 2, this.end = false});
  final String label;
  final int flex;
  final bool end;
}

/// One row of a [DesktopTable]; [onTap] makes it clickable.
class TableRowData {
  const TableRowData({required this.key, required this.cells, this.onTap})
    : heading = null;

  /// A full-width label row that groups the rows below it (a date, say).
  const TableRowData.heading(String this.heading, {required this.key})
    : cells = const [],
      onTap = null;

  final Key key;
  final List<Widget> cells;
  final VoidCallback? onTap;
  final String? heading;
}

/// A table for the desktop layout: a tinted header, then one row per item that
/// highlights on hover and opens on click.
class DesktopTable extends StatelessWidget {
  const DesktopTable({required this.columns, required this.rows, super.key});
  final List<TableColumn> columns;
  final List<TableRowData> rows;

  Widget _cells(List<Widget> children) => Row(
    children: [
      for (var i = 0; i < columns.length; i++)
        Expanded(
          flex: columns[i].flex,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Align(
              alignment: columns[i].end
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: children[i],
            ),
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      color: TaxcyColors.muted,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    );
    return Card(
      margin: const EdgeInsets.only(top: 4),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: TaxcyColors.blue50,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: _cells([
              for (final c in columns)
                Text(c.label.toUpperCase(), style: headerStyle),
            ]),
          ),
          for (final row in rows)
            if (row.heading != null)
              Container(
                key: row.key,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: TaxcyColors.blue50,
                  border: Border(top: BorderSide(color: TaxcyColors.border)),
                ),
                child: Text(
                  row.heading!,
                  style: const TextStyle(
                    color: TaxcyColors.blue700,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              InkWell(
                key: row.key,
                hoverColor: TaxcyColors.blue50,
                onTap: row.onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: TaxcyColors.border)),
                  ),
                  child: _cells(row.cells),
                ),
              ),
        ],
      ),
    );
  }
}

/// Cards in as many columns as fit (each at least [minWidth]), up to four.
class CardGrid extends StatelessWidget {
  const CardGrid({required this.children, this.minWidth = 300, super.key});
  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      const gap = 16.0;
      final columns = ((box.maxWidth + gap) / (minWidth + gap)).floor().clamp(
        1,
        4,
      );
      final width = (box.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

/// "Sharma Travels" → "ST".
String initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}

/// A round avatar with someone's initials.
/// Someone's profile photo ([photoMediaId]) in a circle, or their initials.
class InitialsAvatar extends ConsumerWidget {
  const InitialsAvatar(
    this.name, {
    this.radius = 20,
    this.photoMediaId,
    super.key,
  });
  final String name;
  final double radius;
  final String? photoMediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = photoMediaId;
    final url = photo == null
        ? null
        : ref.watch(mediaUrlProvider(photo)).value?.url;
    return CircleAvatar(
      radius: radius,
      backgroundColor: TaxcyColors.blue100,
      foregroundColor: TaxcyColors.blue800,
      foregroundImage: url == null ? null : NetworkImage(url),
      onForegroundImageError: url == null ? null : (_, _) {},
      child: Text(
        initials(name),
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: radius * 0.7),
      ),
    );
  }
}

/// A registration number as a yellow commercial plate, like on a cab.
class NumberPlate extends StatelessWidget {
  const NumberPlate(this.registration, {super.key});
  final String registration;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFD43B),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFF1F2937)),
    ),
    child: Text(
      registration,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: Color(0xFF111827),
      ),
    ),
  );
}
