import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import 'package:flutter/services.dart';

import '../../core/api/doc_rules.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_models.dart';
import '../../core/media/file_pick.dart';
import '../../core/media/upload_now.dart';
import '../../l10n/app_localizations.dart';
import '../common/format.dart';
import '../driver/driver_providers.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';
import 'trips/trip_share.dart';
import '../common/pick_source.dart';

/// A document's expiry date, or "No expiry".
String documentExpiryText(BuildContext context, FleetDocument d) {
  final expiresOn = d.expiresOn;
  return expiresOn == null
      ? context.l10n.noExpiry
      : context.fmt.calendarDate(expiresOn);
}

/// Documents matching [query], each with view and renew; a driver's uploads
/// waiting for approval come first, with approve and reject. Shows whose
/// document it is unless the list is already for one vehicle or driver.
///
/// [DocumentsList.mine] is the driver's own list in the driver app: no review,
/// and what they add or renew goes to the owner for approval.
class DocumentsList extends ConsumerWidget {
  const DocumentsList({required DocumentQuery this.query, super.key})
    : mine = false;

  const DocumentsList.mine({super.key}) : query = null, mine = true;

  final DocumentQuery? query;
  final bool mine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final query = this.query;
    final docs = query == null
        ? ref.watch(myDocumentsProvider)
        : ref.watch(documentsProvider(query));
    final vehicles = mine
        ? const <Vehicle>[]
        : ref.watch(fleetVehiclesProvider).value ?? const <Vehicle>[];
    final drivers = mine
        ? const <Driver>[]
        : ref.watch(driversProvider).value ?? const <Driver>[];
    final scoped = mine || query?.vehicleId != null || query?.driverId != null;
    // Who added it and why it was turned down, under the document's name.
    String? reviewLine(FleetDocument d) {
      if (d.isRejected) {
        return l.docRejectedBecause(note: d.reviewNote ?? l.noValue);
      }
      if (!d.isPending || mine) return null;
      final parts = [
        if (d.submittedByDriver) l.addedByDriver,
        if (d.replacesId != null) l.renewalOf,
      ];
      return parts.isEmpty ? null : parts.join(' · ');
    }

    String subject(FleetDocument d) {
      if (d.vehicleId != null) {
        final v = vehicles.where((v) => v.id == d.vehicleId).firstOrNull;
        return v == null ? l.noValue : formatRegistration(v.registrationNo);
      }
      return drivers.where((x) => x.id == d.driverId).firstOrNull?.name ??
          l.noValue;
    }

    void reload() => query == null
        ? ref.invalidate(myDocumentsProvider)
        : ref.invalidate(documentsProvider(query));

    // Kept fresh, so what's added elsewhere (the driver's app, another tab or
    // browser window) shows up here too.
    return KeepFresh(
      onRefresh: reload,
      child: AsyncView(
        value: docs,
        onRetry: reload,
        builder: (all) {
          // Waiting for approval first, then the rest in expiry order.
          final list = [
            ...all.where((d) => d.isPending),
            ...all.where((d) => !d.isPending),
          ];
          return list.isEmpty
              ? EmptyState(l.noDocuments)
              : isDesktop(context)
              ? DesktopTable(
                  key: const Key('document-table'),
                  columns: [
                    TableColumn(l.colDocument, flex: 3),
                    if (!scoped) TableColumn(l.colFor, flex: 3),
                    TableColumn(l.colNumber, flex: 3),
                    TableColumn(l.colFiles, flex: 3),
                    TableColumn(l.expiresOn, flex: 2),
                    TableColumn(l.status, flex: 2),
                    const TableColumn('', flex: 1, end: true),
                  ],
                  rows: [
                    for (final d in list)
                      TableRowData(
                        key: ValueKey('document-${d.id}'),
                        cells: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                docTypeLabel(l, d.docType),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (reviewLine(d) case final line?)
                                Text(
                                  line,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: TaxcyColors.muted,
                                  ),
                                ),
                            ],
                          ),
                          if (!scoped)
                            d.vehicleId != null
                                ? NumberPlate(subject(d))
                                : Row(
                                    children: [
                                      InitialsAvatar(subject(d), radius: 14),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          subject(d),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                          Text(
                            d.number ?? '–',
                            style: const TextStyle(color: TaxcyColors.muted),
                          ),
                          _FilesStrip(
                            d,
                            onOpen: () => _openFiles(context, ref, d),
                          ),
                          Text(documentExpiryText(context, d)),
                          DocumentStatusChip(d),
                          _menu(context, ref, d),
                        ],
                      ),
                  ],
                )
              : Column(
                  children: [
                    for (final d in list)
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          key: ValueKey('document-${d.id}'),
                          title: Text(
                            scoped
                                ? docTypeLabel(l, d.docType)
                                : '${docTypeLabel(l, d.docType)} · ${subject(d)}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  [
                                    ?d.number,
                                    '${l.expiresOn}: ${documentExpiryText(context, d)}',
                                  ].join(' · '),
                                  ?reviewLine(d),
                                ].join('\n'),
                              ),
                              const SizedBox(height: 6),
                              _FilesStrip(
                                d,
                                onOpen: () => _openFiles(context, ref, d),
                              ),
                            ],
                          ),
                          // Capped, with the status shortened ("…") rather
                          // than the menu pushed off, so a long Kannada or
                          // Marathi status can't take the whole tile.
                          trailing: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 170),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(child: DocumentStatusChip(d)),
                                const SizedBox(width: 4),
                                _menu(context, ref, d),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
        },
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref, FleetDocument d) =>
      runAction(context, () async {
        await ref.read(ownerApiProvider).approveDocument(d.id);
        refreshAfter(ref, {OwnerArea.documents, OwnerArea.alerts});
      });

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    FleetDocument d,
  ) async {
    final l = context.l10n;
    final note = await askText(
      context,
      title: l.rejectDocumentTitle,
      label: l.rejectReasonLabel,
      confirm: l.rejectDocument,
      destructive: true,
    );
    if (note == null || !context.mounted) return;
    await runAction(context, () async {
      await ref.read(ownerApiProvider).rejectDocument(d.id, note);
      refreshAfter(ref, {OwnerArea.documents, OwnerArea.alerts});
    });
  }

  /// The document's files: one photo full size, one PDF outside the app,
  /// several in a list.
  Future<void> _openFiles(
    BuildContext context,
    WidgetRef ref,
    FleetDocument d,
  ) async {
    final files = d.files;
    if (files.isEmpty) return;
    if (files.length > 1) return _viewAll(context, ref, d);
    if (files.single.isPdf) return openDocumentFile(context, ref, files.single);
    return _viewPhoto(context, d, files.single);
  }

  Widget _menu(BuildContext context, WidgetRef ref, FleetDocument d) {
    final l = context.l10n;
    final files = d.files;
    final review = !mine && d.isPending;
    return PopupMenuButton<String>(
      key: ValueKey('document-menu-${d.id}'),
      onSelected: (action) => switch (action) {
        'view' => _openFiles(context, ref, d),
        'approve' => _approve(context, ref, d),
        'reject' => _reject(context, ref, d),
        _ => openScreen<void>(
          context,
          DocumentFormScreen(renewing: d, mine: mine),
        ),
      },
      itemBuilder: (_) => [
        if (review) ...[
          PopupMenuItem(
            key: const Key('document-approve'),
            value: 'approve',
            child: Text(l.approveDocument),
          ),
          PopupMenuItem(
            key: const Key('document-reject'),
            value: 'reject',
            child: Text(l.rejectDocument),
          ),
        ],
        if (files.isNotEmpty)
          PopupMenuItem(
            key: const Key('document-view'),
            value: 'view',
            child: Text(
              files.length > 1
                  ? l.viewFiles(count: files.length)
                  : files.single.isPdf
                  ? l.viewDocument
                  : l.viewPhoto,
            ),
          ),
        if (d.status != 'superseded' && d.reviewStatus == 'approved')
          PopupMenuItem(
            key: const Key('document-renew'),
            value: 'renew',
            child: Text(l.renew),
          ),
      ],
    );
  }

  Future<void> _viewPhoto(
    BuildContext context,
    FleetDocument d,
    DocumentFile file,
  ) => showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(docTypeLabel(dialog.l10n, d.docType)),
      content: SizedBox(
        width: 480,
        child: MediaPhoto(file.mediaId, height: 420),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(),
          child: Text(dialog.l10n.close),
        ),
      ],
    ),
  );

  /// Every file of [d]: photos inline, PDFs as rows that open outside the app.
  Future<void> _viewAll(BuildContext context, WidgetRef ref, FleetDocument d) =>
      showDialog<void>(
        context: context,
        builder: (dialog) {
          final l = dialog.l10n;
          return AlertDialog(
            key: const Key('document-files-dialog'),
            title: Text(docTypeLabel(l, d.docType)),
            content: SizedBox(
              width: 520,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (i, f) in d.files.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: f.isPdf
                          ? ListTile(
                              key: ValueKey('document-pdf-$i'),
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red.shade700,
                              ),
                              title: Text(l.pdfDocument),
                              trailing: TextButton(
                                onPressed: () =>
                                    openDocumentFile(dialog, ref, f),
                                child: Text(l.open),
                              ),
                            )
                          : MediaPhoto(f.mediaId, height: 300),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialog).pop(),
                child: Text(l.close),
              ),
            ],
          );
        },
      );
}

/// Calls [onRefresh] every [every] while on screen and whenever the app (or
/// the browser tab) comes back to the front.
class KeepFresh extends StatefulWidget {
  const KeepFresh({
    required this.onRefresh,
    required this.child,
    this.every = const Duration(seconds: 30),
    super.key,
  });

  final VoidCallback onRefresh;
  final Duration every;
  final Widget child;

  @override
  State<KeepFresh> createState() => _KeepFreshState();
}

class _KeepFreshState extends State<KeepFresh> {
  late final Timer _timer = Timer.periodic(
    widget.every,
    (_) => widget.onRefresh(),
  );
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () => widget.onRefresh(),
    onShow: () => widget.onRefresh(),
  );

  @override
  void initState() {
    super.initState();
    _timer;
    _lifecycle;
  }

  @override
  void dispose() {
    _timer.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A document's files at a glance: up to three thumbnails (PDFs as a red
/// icon) and "+n"; tap to open them. "No files" when there are none.
class _FilesStrip extends StatelessWidget {
  const _FilesStrip(this.doc, {required this.onOpen});
  final FleetDocument doc;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final files = doc.files;
    if (files.isEmpty) {
      return Text(
        context.l10n.noFiles,
        style: const TextStyle(fontSize: 12, color: TaxcyColors.muted),
      );
    }
    return InkWell(
      key: ValueKey('document-files-${doc.id}'),
      onTap: onOpen,
      borderRadius: BorderRadius.circular(6),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final f in files.take(3)) _FileThumb(f),
          if (files.length > 3)
            Text(
              '+${files.length - 3}',
              style: const TextStyle(fontSize: 12, color: TaxcyColors.muted),
            ),
        ],
      ),
    );
  }
}

class _FileThumb extends ConsumerWidget {
  const _FileThumb(this.file);
  final DocumentFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget box(Widget child) => Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: TaxcyColors.blue50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: TaxcyColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
    if (file.isPdf) {
      return box(
        Icon(Icons.picture_as_pdf, color: Colors.red.shade700, size: 22),
      );
    }
    final placeholder = const Icon(
      Icons.image_outlined,
      size: 20,
      color: TaxcyColors.muted,
    );
    return box(switch (ref.watch(mediaUrlProvider(file.mediaId))) {
      AsyncData(:final value) => Image.network(
        value.url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
      _ => placeholder,
    });
  }
}

/// Opens a document's PDF outside the app: a new browser tab, or the phone's
/// PDF viewer.
Future<void> openDocumentFile(
  BuildContext context,
  WidgetRef ref,
  DocumentFile file,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final unavailable = context.l10n.documentUnavailable;
  try {
    final media = await ref.read(mediaUrlProvider(file.mediaId).future);
    final opened = await ref.read(urlOpenerProvider)(Uri.parse(media.url));
    if (!opened) throw StateError('not opened');
  } on Object {
    messenger.showSnackBar(SnackBar(content: Text(unavailable)));
  }
}

/// Most files one document holds (MAX_DOCUMENT_FILES in libs/contracts).
const maxDocumentFiles = 10;

class DocumentStatusChip extends StatelessWidget {
  const DocumentStatusChip(this.doc, {super.key});
  final FleetDocument doc;

  @override
  Widget build(BuildContext context) => ToneChip(
    documentStatusText(context.l10n, doc),
    tone: doc.isPending
        ? Tone.warning
        : doc.isRejected
        ? Tone.danger
        : switch (doc.status) {
            'expired' => Tone.danger,
            'expiring' => (doc.daysLeft ?? 0) <= 7 ? Tone.danger : Tone.warning,
            'superseded' => Tone.neutral,
            _ => Tone.success,
          },
  );
}

/// On a vehicle or driver row: a chip when one of their documents has expired
/// or expires within 30 days, nothing otherwise. Every row shares one query.
class DocumentsDueChip extends ConsumerWidget {
  const DocumentsDueChip({this.vehicleId, this.driverId, super.key});
  final String? vehicleId;
  final String? driverId;

  static const dueQuery = (
    vehicleId: null,
    driverId: null,
    expiringWithinDays: 30,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final docs = ref.watch(documentsProvider(dueQuery)).value ?? const [];
    final mine = docs.where(
      (d) =>
          (d.status == 'expired' || d.status == 'expiring') &&
          (vehicleId != null
              ? d.vehicleId == vehicleId
              : d.driverId == driverId),
    );
    if (mine.isEmpty) return const SizedBox.shrink();
    final expired = mine.any((d) => d.status == 'expired');
    return ToneChip(
      key: Key('docs-due-${vehicleId ?? driverId}'),
      expired ? l.documentsExpiredChip : l.documentsDueChip,
      tone: expired ? Tone.danger : Tone.warning,
    );
  }
}

/// Adds a document (for [vehicleId] or [driverId] when given) or renews [renewing].
/// The files are uploaded straight away through the media flow.
///
/// With [mine], a driver adds or renews their own document from the driver
/// app; it waits for the owner's approval.
class DocumentFormScreen extends ConsumerStatefulWidget {
  const DocumentFormScreen({
    this.renewing,
    this.vehicleId,
    this.driverId,
    this.mine = false,
    super.key,
  });

  final FleetDocument? renewing;
  final String? vehicleId;
  final String? driverId;
  final bool mine;

  @override
  ConsumerState<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends ConsumerState<DocumentFormScreen> {
  late final _number = TextEditingController(
    text: _shown(widget.renewing?.docType, widget.renewing?.number ?? ''),
  );
  late String _docType =
      widget.renewing?.docType ??
      (widget.driverId != null || widget.mine
          ? 'driving_licence'
          : 'insurance');
  late String? _vehicleId = widget.vehicleId;
  late String? _driverId = widget.driverId;
  String? _validFrom;
  String? _expiresOn;

  /// Photos taken and files picked, in order; uploaded when saving.
  final _files = <PickedFile>[];

  /// Media id of each uploaded file, by the file's id (kept if saving fails,
  /// so a retry doesn't upload them again).
  final _uploaded = <String, String>{};
  final _uploading = <String>{};
  final _failed = <String>{};
  String? _problem;

  /// Why the expiry date can't be saved (missing, or not after the start),
  /// shown on the field itself.
  String? _expiryError;

  /// Save was pressed: the number's problems show, and update as it's typed.
  bool _checkNumber = false;
  bool _busy = false;

  /// What saving is doing right now ("Uploading 1 of 2…", "Saving…").
  String? _step;

  /// Saved, so leaving doesn't ask to discard.
  bool _saved = false;

  /// Something was picked or typed that leaving would lose.
  bool get _dirty =>
      _files.isNotEmpty ||
      _number.text.trim().isNotEmpty ||
      _validFrom != null ||
      _expiresOn != null;

  Future<void> _confirmLeave() async {
    final l = context.l10n;
    final navigator = Navigator.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        key: const Key('document-discard-dialog'),
        title: Text(l.discardDocumentTitle),
        content: Text(l.discardDocumentBody),
        actions: [
          TextButton(
            key: const Key('document-keep-editing'),
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l.keepEditing),
          ),
          TextButton(
            key: const Key('document-discard'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l.discard),
          ),
        ],
      ),
    );
    if (discard ?? false) {
      setState(() => _saved = true);
      navigator.pop();
    }
  }

  List<PickedFile> get _notUploaded =>
      _files.where((f) => !_uploaded.containsKey(f.file.id)).toList();

  /// Uploads every selected file that isn't uploaded yet, each showing its
  /// state; false when any failed.
  Future<bool> _uploadPending() async {
    final pending = _notUploaded;
    if (pending.isEmpty) return true;
    setState(() {
      _failed.removeAll(pending.map((f) => f.file.id));
      _uploading.addAll(pending.map((f) => f.file.id));
    });
    final deviceId = await ref.read(sessionStoreProvider).deviceId();
    for (final (i, f) in pending.indexed) {
      if (mounted) {
        setState(
          () => _step = context.l10n.uploadingStep(
            n: i + 1,
            count: pending.length,
          ),
        );
      }
      try {
        _uploaded[f.file.id] = await uploadPhotoNow(
          ref.read(apiProvider),
          f.file,
          readBytes: ref.read(photoStoreProvider).read,
          deviceId: deviceId,
        );
      } on Object {
        _failed.add(f.file.id);
      }
      if (!mounted) return false;
      setState(() => _uploading.remove(f.file.id));
    }
    return _failed.isEmpty;
  }

  void _remove(PickedFile f) => setState(() {
    _files.remove(f);
    _uploaded.remove(f.file.id);
    _failed.remove(f.file.id);
  });

  /// A look at a selected file: a photo full size; an uploaded PDF opens
  /// outside the app.
  Future<void> _preview(PickedFile f) async {
    final mediaId = _uploaded[f.file.id];
    if (f.isPdf) {
      if (mediaId != null) {
        await openDocumentFile(
          context,
          ref,
          DocumentFile(mediaId: mediaId, contentType: f.file.contentType),
        );
      }
      return;
    }
    final bytes = await ref.read(photoStoreProvider).read(f.file.path);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        key: const Key('document-file-preview'),
        title: Text(f.name),
        content: SizedBox(
          width: 480,
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.broken_image_outlined, size: 64),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(),
            child: Text(dialog.l10n.close),
          ),
        ],
      ),
    );
  }

  bool get _forDriver => FleetDocument.driverTypes.contains(_docType);
  bool get _expiryRequired => FleetDocument.expiryRequired(_docType);
  DocFields get _fields => fieldsOf(_docType);

  /// A stored number as typed: Aadhaar grouped in fours.
  static String _shown(String? docType, String number) => docType == 'aadhaar'
      ? const AadhaarInputFormatter()
            .formatEditUpdate(
              TextEditingValue.empty,
              TextEditingValue(text: number),
            )
            .text
      : number;

  String get _normalisedNumber => normaliseDocNumber(_docType, _number.text);

  /// What is wrong with the number, in the user's language, or null.
  String? _numberError(AppLocalizations l) {
    final example = docNumberExamples[_docType] ?? '';
    return switch (checkDocNumber(_docType, _normalisedNumber)) {
      null || DocNumberProblem.notAllowed => null,
      DocNumberProblem.missing => l.docNumberMissing,
      DocNumberProblem.format when _docType == 'aadhaar' => l.aadhaarFormat,
      DocNumberProblem.format => l.docNumberFormat(example: example),
      DocNumberProblem.checksum => l.aadhaarChecksum,
    };
  }

  /// Picks another type: details it doesn't have are cleared (so they're
  /// never sent), and an RC starts with the vehicle's registration.
  void _changeType(String docType) => setState(() {
    final changed = docType != _docType;
    _docType = docType;
    final fields = _fields;
    if (fields.number == FieldRule.hidden) _number.clear();
    if (fields.validFrom == FieldRule.hidden) _validFrom = null;
    if (fields.expiresOn == FieldRule.hidden) {
      _expiresOn = null;
      _expiryError = null;
    }
    if (changed && docType == 'aadhaar') {
      _number.text = _shown(docType, _number.text);
    }
    _prefillRegistration();
  });

  /// An RC's number is the vehicle's registration: filled in when empty.
  void _prefillRegistration() {
    if (_docType != 'rc' || _number.text.trim().isNotEmpty) return;
    final vehicle = (ref.read(fleetVehiclesProvider).value ?? const [])
        .where((v) => v.id == _vehicleId)
        .firstOrNull;
    if (vehicle != null) _number.text = vehicle.registrationNo;
  }

  bool get _full => _files.length >= maxDocumentFiles;

  void _add(Iterable<PickedFile> files) {
    final room = maxDocumentFiles - _files.length;
    setState(() {
      _files.addAll(files.take(room));
      _problem = files.length > room
          ? context.l10n.tooManyFiles(count: maxDocumentFiles)
          : null;
    });
  }

  Future<void> _takePhoto() async {
    final photo = await ref.read(photoCaptureProvider)(context, 'document');
    if (photo == null || !mounted) return;
    _add([
      PickedFile(
        file: photo,
        name: context.l10n.photoNumber(number: _files.length + 1),
      ),
    ]);
  }

  Future<void> _pickFiles() async {
    try {
      final source = await choosePickSource(context);
      if (source == null || !mounted) return;
      final picked = await ref.read(filePickProvider)(
        'document',
        source: source,
      );
      if (picked.isEmpty || !mounted) return;
      _add(picked);
    } on FileTooLargeException catch (e) {
      if (mounted) {
        setState(() => _problem = context.l10n.fileTooLargeNamed(name: e.name));
      }
    }
  }

  List<String> get _types => widget.vehicleId != null
      ? FleetDocument.vehicleTypes
      : widget.driverId != null || widget.mine
      ? FleetDocument.driverTypes
      : [...FleetDocument.vehicleTypes, ...FleetDocument.driverTypes];

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final renewing = widget.renewing;
    final subjectMissing =
        renewing == null &&
        !widget.mine &&
        (_forDriver ? _driverId == null : _vehicleId == null);
    final validFrom = _validFrom;
    final expiresOn = _expiresOn;
    final expiryError = expiresOn == null
        ? (_expiryRequired ? l.required : null)
        : validFrom != null && expiresOn.compareTo(validFrom) <= 0
        ? l.expiryBeforeStart
        : null;
    final numberBad = _numberError(l) != null;
    if (expiryError != null || numberBad || subjectMissing) {
      setState(() {
        _expiryError = expiryError;
        _checkNumber = true;
        _problem = subjectMissing ? l.pickVehicleOrDriver : l.fixHighlighted;
      });
      return;
    }
    setState(() {
      _expiryError = null;
      _problem = null;
      _busy = true;
    });
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final added = widget.mine ? l.documentSentForApproval : l.documentSaved;
    // One step: upload what's selected, then save the document.
    if (!await _uploadPending()) {
      if (mounted) {
        setState(() {
          _busy = false;
          _step = null;
          _problem = l.fileUploadFailed;
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() => _step = l.savingStep);
    final ok = await runAction(context, () async {
      final mediaIds = [for (final f in _files) _uploaded[f.file.id]!];
      final number = _normalisedNumber;
      final details = {
        'expiresOn': ?_expiresOn,
        if (number.isNotEmpty) 'number': number,
        'validFrom': ?_validFrom,
        if (mediaIds.isNotEmpty) 'mediaIds': mediaIds,
      };
      if (widget.mine) {
        final me = ref.read(meApiProvider);
        if (renewing != null) {
          await me.renewDocument(renewing.id, details);
        } else {
          await me.submitDocument({...details, 'docType': _docType});
        }
        refreshAfter(ref, {OwnerArea.documents});
        return;
      }
      final api = ref.read(ownerApiProvider);
      if (renewing != null) {
        await api.renewDocument(renewing.id, details);
      } else {
        await api.createDocument({
          ...details,
          'docType': _docType,
          if (_forDriver) 'driverId': _driverId else 'vehicleId': _vehicleId,
        });
      }
      refreshAfter(ref, {OwnerArea.documents, OwnerArea.alerts});
    });
    if (ok) {
      setState(() => _saved = true);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(added)));
    } else if (mounted) {
      setState(() {
        _busy = false;
        _step = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final renewing = widget.renewing;
    final scoped =
        widget.vehicleId != null || widget.driverId != null || widget.mine;
    final fields = _fields;
    final aadhaar = _docType == 'aadhaar';
    final example = docNumberExamples[_docType];
    // Leaving with picked files or typed details asks first, so nothing is
    // lost without noticing (and nothing is left half saved).
    return PopScope(
      canPop: _saved || (!_dirty && !_busy),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_busy) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            renewing == null
                ? l.addDocument
                : l.renewTitle(doc: docTypeLabel(l, renewing.docType)),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PageWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (renewing != null)
                    Text(l.renewIntro)
                  else ...[
                    DropdownButtonFormField<String>(
                      initialValue: _docType,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l.documentType),
                      items: [
                        for (final t in _types)
                          DropdownMenuItem(
                            value: t,
                            child: Text(docTypeLabel(l, t)),
                          ),
                      ],
                      onChanged: (v) => _changeType(v ?? _docType),
                    ),
                    if (!scoped) ...[
                      const SizedBox(height: 12),
                      if (_forDriver)
                        DriverPicker(
                          value: _driverId,
                          label: l.documentFor,
                          onChanged: (v) => setState(() => _driverId = v),
                        )
                      else
                        VehiclePicker(
                          value: _vehicleId,
                          label: l.documentFor,
                          activeOnly: false,
                          onChanged: (v) => setState(() {
                            _vehicleId = v;
                            _prefillRegistration();
                          }),
                        ),
                    ],
                  ],
                  if (fields.number != FieldRule.hidden) ...[
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('document-number'),
                      controller: _number,
                      keyboardType: aadhaar
                          ? TextInputType.number
                          : TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        if (aadhaar)
                          const AadhaarInputFormatter()
                        else ...[
                          const UpperCaseInputFormatter(),
                          if (_docType == 'pan')
                            LengthLimitingTextInputFormatter(10),
                        ],
                      ],
                      onChanged: (_) {
                        if (_checkNumber) setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: l.docNumberLabel(
                          doc: docTypeLabel(l, _docType),
                        ),
                        hintText: example == null
                            ? null
                            : l.docNumberHint(example: example),
                        helperText: fields.number == FieldRule.optional
                            ? l.optional
                            : null,
                        errorText: _checkNumber ? _numberError(l) : null,
                        errorMaxLines: 3,
                      ),
                    ),
                  ],
                  if (fields.validFrom != FieldRule.hidden) ...[
                    const SizedBox(height: 12),
                    _DatePickField(
                      key: const Key('document-valid-from'),
                      label: l.validFrom,
                      value: _validFrom == null
                          ? l.optional
                          : fmt.calendarDate(_validFrom!),
                      onTap: () async {
                        final d = await pickIsoDate(context, value: _validFrom);
                        if (d != null) setState(() => _validFrom = d);
                      },
                    ),
                  ],
                  if (fields.expiresOn != FieldRule.hidden) ...[
                    const SizedBox(height: 12),
                    _DatePickField(
                      key: const Key('document-expires'),
                      label: l.expiresOn,
                      hint: _expiryRequired ? l.expiresOnHint : null,
                      error: _expiryError,
                      value: _expiresOn == null
                          ? (_expiryRequired ? l.pickDate : l.optional)
                          : fmt.calendarDate(_expiresOn!),
                      onTap: () async {
                        final d = await pickIsoDate(context, value: _expiresOn);
                        if (d != null) {
                          setState(() {
                            _expiresOn = d;
                            _expiryError = null;
                          });
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    l.documentFiles,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  for (final (i, f) in _files.indexed)
                    _SelectedFileTile(
                      key: ValueKey('document-file-$i'),
                      index: i,
                      file: f,
                      state: _uploaded.containsKey(f.file.id)
                          ? _FileState.uploaded
                          : _uploading.contains(f.file.id)
                          ? _FileState.uploading
                          : _failed.contains(f.file.id)
                          ? _FileState.failed
                          : _FileState.selected,
                      onTap: () => _preview(f),
                      onRemove: _busy ? null : () => _remove(f),
                    ),
                  if (_files.isNotEmpty) const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('document-take-photo'),
                        onPressed: _busy || _full ? null : _takePhoto,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(l.takePhoto),
                      ),
                      OutlinedButton.icon(
                        key: const Key('document-upload-file'),
                        onPressed: _busy || _full ? null : _pickFiles,
                        icon: const Icon(Icons.upload_file),
                        label: Text(l.uploadFiles),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.uploadFileHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
                  // One step: uploads the selected files, then saves.
                  FilledButton.icon(
                    key: const Key('document-save'),
                    onPressed: _busy ? null : _save,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _notUploaded.isEmpty
                                ? Icons.check
                                : Icons.cloud_upload_outlined,
                          ),
                    label: Text(
                      _busy && _step != null
                          ? _step!
                          : _notUploaded.isNotEmpty
                          ? l.uploadAndSave(count: _notUploaded.length)
                          : renewing == null
                          ? l.addDocument
                          : l.saveRenewal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _FileState { selected, uploading, uploaded, failed }

/// A selected file in the document form: a thumbnail (photos) or PDF icon,
/// its name, whether it's uploaded, and remove. Tap to look at it.
class _SelectedFileTile extends ConsumerWidget {
  const _SelectedFileTile({
    required this.index,
    required this.file,
    required this.state,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final int index;
  final PickedFile file;
  final _FileState state;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final (text, color, icon) = switch (state) {
      _FileState.selected => (
        l.fileReadyToUpload,
        Colors.amber.shade900,
        Icons.schedule,
      ),
      _FileState.uploading => (
        l.fileUploading,
        TaxcyColors.blue700,
        Icons.cloud_upload_outlined,
      ),
      _FileState.uploaded => (
        l.fileUploaded,
        Colors.green.shade700,
        Icons.check_circle,
      ),
      _FileState.failed => (
        l.fileUploadFailed,
        Theme.of(context).colorScheme.error,
        Icons.error_outline,
      ),
    };
    final thumb = file.isPdf
        ? Icon(Icons.picture_as_pdf, color: Colors.red.shade700, size: 32)
        : FutureBuilder(
            future: ref.read(photoStoreProvider).read(file.file.path),
            builder: (_, snap) => snap.data == null || snap.data!.isEmpty
                ? const Icon(Icons.image_outlined, size: 32)
                : Image.memory(
                    snap.data!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.image_outlined, size: 32),
                  ),
          );
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox.square(dimension: 48, child: Center(child: thumb)),
        ),
        title: Text(file.name, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          key: ValueKey('document-file-state-$index'),
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(text, style: TextStyle(color: color, fontSize: 12)),
            ),
          ],
        ),
        trailing: IconButton(
          key: ValueKey('document-file-remove-$index'),
          tooltip: l.remove,
          icon: const Icon(Icons.close),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

class _DatePickField extends StatelessWidget {
  const _DatePickField({
    required this.label,
    required this.value,
    required this.onTap,
    this.hint,
    this.error,
    super.key,
  });

  final String label;
  final String value;
  final String? hint;
  final String? error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        errorText: error,
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
      ),
      child: Text(value),
    ),
  );
}
