import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/media/file_pick.dart';
import 'format.dart';

/// Whether picking needs a choice of source: on an iPhone the Files app
/// doesn't show the Photos library. Android's and the browser's chooser cover
/// both.
bool get pickNeedsSource =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Where to pick a document from: on an iPhone, a sheet offering the photo
/// library or Files; elsewhere straight to the file chooser. Null when the
/// sheet is dismissed.
Future<PickSource?> choosePickSource(BuildContext context) async {
  if (!pickNeedsSource) return PickSource.files;
  final l = context.l10n;
  return showModalBottomSheet<PickSource>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              l.pickSourceTitle,
              style: Theme.of(sheet).textTheme.titleMedium,
            ),
          ),
          ListTile(
            key: const Key('pick-photos'),
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l.pickFromPhotos),
            onTap: () => Navigator.of(sheet).pop(PickSource.photos),
          ),
          ListTile(
            key: const Key('pick-files'),
            leading: const Icon(Icons.folder_open_outlined),
            title: Text(l.pickFromFiles),
            onTap: () => Navigator.of(sheet).pop(PickSource.files),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
