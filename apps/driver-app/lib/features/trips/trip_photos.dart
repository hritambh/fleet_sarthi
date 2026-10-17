import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../common/format.dart';
import '../owner/owner_widgets.dart';

/// A photo taken on this phone, read from the local store (null when it was
/// taken elsewhere or is gone). It shows before, or without, the upload.
final localPhotoProvider = FutureProvider.autoDispose
    .family<Uint8List?, String>((ref, mediaId) async {
      final db = ref.watch(databaseProvider);
      final row = await (db.select(
        db.photos,
      )..where((p) => p.id.equals(mediaId))).getSingleOrNull();
      if (row == null) return null;
      try {
        return await ref.watch(photoStoreProvider).read(row.path);
      } on Object {
        return null;
      }
    });

/// A trip photo (odometer, fuel receipt): this phone's copy when it has one,
/// else the uploaded file. Tap to see it full size.
class TripPhoto extends ConsumerWidget {
  const TripPhoto(this.mediaId, {required this.label, super.key});
  final String mediaId;
  final String label;

  static const _height = 120.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = ref.watch(localPhotoProvider(mediaId)).value;
    Widget image({required double height, BoxFit fit = BoxFit.cover}) =>
        local != null
        ? Image.memory(local, height: height, fit: fit)
        : MediaPhoto(mediaId, height: height);
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: ValueKey('trip-photo-$mediaId'),
            borderRadius: BorderRadius.circular(8),
            onTap: () => showDialog<void>(
              context: context,
              builder: (dialog) => Dialog(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Flexible(
                      child: InteractiveViewer(
                        child: image(height: 520, fit: BoxFit.contain),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialog).pop(),
                      child: Text(context.l10n.close),
                    ),
                  ],
                ),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 150,
                height: _height,
                child: image(height: _height),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: TaxcyColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Every photo of a trip with its caption: start and end odometer, and each
/// fuel fill's odometer and receipt.
List<(String, String)> tripPhotos(BuildContext context, Trip t) {
  final l = context.l10n;
  final fmt = context.fmt;
  return [
    if (t.startOdometer != null)
      (t.startOdometer!.mediaId, '${l.startLabel} · ${l.odometerPhoto}'),
    if (t.endOdometer != null)
      (t.endOdometer!.mediaId, '${l.endLabel} · ${l.odometerPhoto}'),
    for (final f in t.fuelFills) ...[
      if (f.odometerMediaId != null)
        (f.odometerMediaId!, '${fuelFillLabel(fmt, f)} · ${l.odometerPhoto}'),
      if (f.receiptMediaId != null)
        (f.receiptMediaId!, '${fuelFillLabel(fmt, f)} · ${l.receiptPhoto}'),
    ],
  ];
}

/// The trip's photos as a wrapping row of thumbnails, or nothing.
class TripPhotosSection extends StatelessWidget {
  const TripPhotosSection(this.trip, {super.key});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final photos = tripPhotos(context, trip);
    if (photos.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const Key('trip-photos'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          context.l10n.tripPhotos,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (id, label) in photos) TripPhoto(id, label: label),
          ],
        ),
      ],
    );
  }
}
