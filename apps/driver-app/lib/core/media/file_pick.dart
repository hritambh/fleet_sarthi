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

/// A file the owner picked from the phone or computer, stored like a photo
/// until it's uploaded.
class PickedFile {
  const PickedFile({required this.file, required this.name});
  final CapturedPhoto file;
  final String name;

  bool get isPdf => file.contentType == 'application/pdf';
}

/// The picked file was larger than [maxUploadBytes].
class FileTooLargeException implements Exception {
  const FileTooLargeException();
}

/// Picks a PDF or image for [kind]; null when cancelled. Replaced in tests.
typedef FilePick = Future<PickedFile?> Function(String kind);

/// Production picking: the system file chooser, PDFs and images only.
Future<PickedFile?> pickDocumentFile(PhotoStore store, String kind) async {
  final picked = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: _contentTypes.keys.toList(),
  );
  if (picked == null) return null;
  final type = _contentTypes[picked.name.split('.').last.toLowerCase()];
  if (type == null) return null;
  if ((await picked.length() ?? 0) > maxUploadBytes) {
    throw const FileTooLargeException();
  }
  final bytes = await picked.readAsBytes();
  if (bytes.length > maxUploadBytes) throw const FileTooLargeException();
  final id = const Uuid().v4();
  return PickedFile(
    name: picked.name,
    file: CapturedPhoto(
      id: id,
      kind: kind,
      path: await store.save(id, bytes),
      sha256: sha256Of(bytes),
      byteSize: bytes.length,
      contentType: type,
      capturedAt: DateTime.now(),
    ),
  );
}
