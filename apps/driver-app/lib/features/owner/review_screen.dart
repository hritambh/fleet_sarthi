import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/owner_models.dart';
import '../common/format.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';
import 'trips/owner_trip_detail_screen.dart';

const reviewStatuses = [
  'open',
  'accepted_typed',
  'accepted_ocr',
  'corrected',
  'dismissed',
];

/// Items Fleet Sarthi isn't sure about: photo vs typed value; the owner decides.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  String? _status = 'open';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = ref.watch(reviewItemsProvider(_status));
    return Scaffold(
      appBar: AppBar(title: Text(l.review)),
      body: RefreshPage(
        onRefresh: () => ref.refresh(reviewItemsProvider(_status).future),
        children: [
          Text(l.reviewIntro, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SizedBox(
            width: 240,
            child: DropdownButtonFormField<String?>(
              initialValue: _status,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.status, isDense: true),
              items: [
                for (final s in reviewStatuses)
                  DropdownMenuItem<String?>(
                    value: s,
                    child: Text(reviewStatusLabel(l, s)),
                  ),
                DropdownMenuItem<String?>(child: Text(l.all)),
              ],
              onChanged: (v) => setState(() => _status = v),
            ),
          ),
          const SizedBox(height: 8),
          AsyncView(
            value: items,
            onRetry: () => ref.invalidate(reviewItemsProvider(_status)),
            builder: (list) => list.isEmpty
                ? EmptyState(_status == 'open' ? l.nothingToReview : l.noItems)
                : Column(children: [for (final i in list) ReviewCard(i)]),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends ConsumerWidget {
  const ReviewCard(this.item, {super.key});
  final ReviewItem item;

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    String resolution, {
    int? correctedValue,
  }) => runAction(context, () async {
    await ref
        .read(ownerApiProvider)
        .resolveReviewItem(item.id, resolution, correctedValue: correctedValue);
    refreshAfter(ref, {OwnerArea.alerts, OwnerArea.fuel, OwnerArea.trips});
  });

  Future<void> _correct(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final paise = item.valueKind == 'paise';
    final value = await askText(
      context,
      title: l.correctValueTitle,
      label: paise ? l.amount : l.odometerKmLabel,
      hint: l.correctionHint,
      confirm: l.saveCorrection,
      keyboard: paise
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      validate: (v) =>
          paise ? validateRupees(l, v, allowZero: true) : validateKm(l, v),
    );
    if (value == null || !context.mounted) return;
    await _resolve(
      context,
      ref,
      'corrected',
      correctedValue: paise ? parseRupees(value) : int.parse(value),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final reason = reviewReasonText(l, item);
    final hasValue = item.valueKind != null;
    final header = Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ToneChip(reviewKindLabel(l, item.kind), tone: Tone.warning),
        if (!item.isOpen) ToneChip(reviewStatusLabel(l, item.status)),
        Text(
          fmt.dayTime(item.createdAt),
          style: const TextStyle(fontSize: 12, color: TaxcyColors.muted),
        ),
      ],
    );
    final hasValues = item.typedValue != null || item.ocrValue != null;
    final openTrip = item.tripId == null
        ? null
        : TextButton(
            onPressed: () => openScreen<void>(
              context,
              OwnerTripDetailScreen(tripId: item.tripId!),
            ),
            child: Text(l.openTrip),
          );
    final actions = !item.isOpen
        ? null
        : Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (hasValue)
                FilledButton(
                  key: const Key('review-keep-typed'),
                  onPressed: () => _resolve(context, ref, 'accepted_typed'),
                  child: Text(l.keepTyped),
                ),
              if (hasValue && item.ocrValue != null)
                OutlinedButton(
                  key: const Key('review-use-photo'),
                  onPressed: () => _resolve(context, ref, 'accepted_ocr'),
                  child: Text(l.usePhotoValue),
                ),
              if (hasValue)
                OutlinedButton(
                  key: const Key('review-correct'),
                  onPressed: () => _correct(context, ref),
                  child: Text(l.enterCorrectValue),
                ),
              TextButton(
                key: const Key('review-dismiss'),
                onPressed: () => _resolve(context, ref, 'dismissed'),
                child: Text(hasValue ? l.dismiss : l.markReviewed),
              ),
            ],
          );

    if (isDesktop(context)) {
      // The photo beside the two readings, so they're compared at a glance.
      return Card(
        key: ValueKey('review-${item.id}'),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.mediaId != null) ...[
                SizedBox(
                  width: 360,
                  child: MediaPhoto(item.mediaId!, height: 240),
                ),
                const SizedBox(width: 24),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    if (reason != null) ...[
                      const SizedBox(height: 10),
                      Text(reason, style: const TextStyle(fontSize: 15)),
                    ],
                    if (hasValues) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _Reading(
                            label: l.typedByDriver,
                            value: reviewValueText(fmt, item, item.typedValue),
                          ),
                          const SizedBox(width: 16),
                          _Reading(
                            label: l.readFromThePhoto,
                            value: reviewValueText(fmt, item, item.ocrValue),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (actions != null) Expanded(child: actions),
                        ?openTrip,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      key: ValueKey('review-${item.id}'),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            if (reason != null) ...[const SizedBox(height: 8), Text(reason)],
            if (item.mediaId != null) ...[
              const SizedBox(height: 8),
              MediaPhoto(item.mediaId!, height: 180),
            ],
            if (hasValues) ...[
              const SizedBox(height: 8),
              StatGrid([
                StatTile(
                  label: l.typedByDriver,
                  value: reviewValueText(fmt, item, item.typedValue),
                ),
                StatTile(
                  label: l.readFromThePhoto,
                  value: reviewValueText(fmt, item, item.ocrValue),
                ),
              ]),
            ],
            ?openTrip,
            if (actions != null) ...[const SizedBox(height: 8), actions],
          ],
        ),
      ),
    );
  }
}

/// One reading in a large box, for the desktop review card.
class _Reading extends StatelessWidget {
  const _Reading({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: 200,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: TaxcyColors.blue50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: TaxcyColors.blue100),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: TaxcyColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: TaxcyColors.blue950,
          ),
        ),
      ],
    ),
  );
}
