import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import 'captured_photo.dart';
import 'photo_store.dart';

/// The largest file the API accepts (libs/contracts media.ts).
const maxUploadBytes = 15 * 1024 * 1024;

const _contentTypes = {
  'pdf': 'application/pdf',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
};

/// A file the owner picked from the phone or computer, or took with the
/// camera, stored like a photo until it's uploaded.
class PickedFile {
  const PickedFile({required this.file, required this.name});
  final CapturedPhoto file;
  final String name;

  bool get isPdf => file.contentType == 'application/pdf';
}

/// A picked file was larger than [maxUploadBytes]; nothing was picked.
class FileTooLargeException implements Exception {
  const FileTooLargeException(this.name);
  final String name;
}

/// Where a picked file comes from. The phone's file chooser covers both on
/// Android and the web; an iPhone's Files app doesn't show the Photos library,
/// so there the person picks one (see choosePickSource).
enum PickSource { files, photos }

/// Picks PDFs and images for [kind]; empty when cancelled. Replaced in tests.
typedef FilePick =
    Future<List<PickedFile>> Function(String kind, {PickSource source});

/// Production picking: the system file chooser (PDFs and images only), or the
/// photo library, several at once.
Future<List<PickedFile>> pickDocumentFiles(
  PhotoStore store,
  String kind, {
  PickSource source = PickSource.files,
}) async {
  final photos = source == PickSource.photos;
  final picked = await FilePicker.pickFiles(
    type: photos ? FileType.image : FileType.custom,
    allowedExtensions: photos ? null : _contentTypes.keys.toList(),
    // Photos come back as JPEG: iPhone photos are often HEIC, which uploads
    // don't accept.
    compressionQuality: photos ? 85 : 0,
  );
  final files = <PickedFile>[];
  for (final p in picked) {
    final type = _contentTypes[p.name.split('.').last.toLowerCase()];
    if (type == null) continue;
    if ((await p.length() ?? 0) > maxUploadBytes) {
      throw FileTooLargeException(p.name);
    }
    final bytes = await p.readAsBytes();
    if (bytes.length > maxUploadBytes) throw FileTooLargeException(p.name);
    final id = const Uuid().v4();
    files.add(
      PickedFile(
        name: p.name,
        file: CapturedPhoto(
          id: id,
          kind: kind,
          path: await store.save(id, bytes),
          sha256: sha256Of(bytes),
          byteSize: bytes.length,
          contentType: type,
          capturedAt: DateTime.now(),
        ),
      ),
    );
  }
  return files;
}
