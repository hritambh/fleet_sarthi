import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/json.dart';
import '../../core/api/owner_models.dart';
import '../../core/media/captured_photo.dart';
import '../../core/media/file_pick.dart';
import '../../core/media/upload_now.dart';
import '../common/format.dart';
import '../login/auth_widgets.dart';
import '../owner/owner_text.dart';
import '../owner/owner_widgets.dart';
import '../common/pick_source.dart';

/// Edits a driver's profile: photo, name, date of birth, email, address and an
/// emergency contact. The driver uses it for themselves and the owner for any
/// of their drivers; [onSave] sends the changes (null clears a field).
class DriverProfileFormScreen extends ConsumerStatefulWidget {
  const DriverProfileFormScreen({
    required this.driver,
    required this.onSave,
    super.key,
  });

  final Driver driver;
  final Future<void> Function(JsonMap body) onSave;

  @override
  ConsumerState<DriverProfileFormScreen> createState() =>
      _DriverProfileFormScreenState();
}

class _DriverProfileFormScreenState
    extends ConsumerState<DriverProfileFormScreen> {
  late final d = widget.driver;
  late final _name = TextEditingController(text: d.name);
  late final _email = TextEditingController(text: d.email ?? '');
  late final _address = TextEditingController(text: d.address ?? '');
  late final _emergencyName = TextEditingController(
    text: d.emergencyContactName ?? '',
  );
  late final _emergencyPhone = TextEditingController(
    text: d.emergencyContactPhone?.replaceFirst('+91', '') ?? '',
  );
  late String? _dateOfBirth = d.dateOfBirth;

  /// A new photo picked here, waiting to be uploaded on save.
  CapturedPhoto? _photo;
  Uint8List? _photoBytes;
  bool _removePhoto = false;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _problem;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _email,
      _address,
      _emergencyName,
      _emergencyPhone,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _setPhoto(CapturedPhoto photo) async {
    // The preview only; the photo is still uploaded if it can't be shown.
    Uint8List? bytes;
    try {
      bytes = await ref.read(photoStoreProvider).read(photo.path);
    } on Object {
      bytes = null;
    }
    if (!mounted) return;
    setState(() {
      _photo = photo;
      _photoBytes = bytes;
      _removePhoto = false;
      _problem = null;
    });
  }

  Future<void> _takePhoto() async {
    final photo = await ref.read(photoCaptureProvider)(context, 'other');
    if (photo != null) await _setPhoto(photo);
  }

  Future<void> _choosePhoto() async {
    final l = context.l10n;
    try {
      // A profile photo is always an image: on an iPhone, the photo library.
      final picked = await ref.read(filePickProvider)(
        'other',
        source: pickNeedsSource ? PickSource.photos : PickSource.files,
      );
      if (picked.isEmpty || !mounted) return;
      final image = picked.where((f) => !f.isPdf).firstOrNull;
      if (image == null) {
        setState(() => _problem = l.photoMustBeImage);
        return;
      }
      await _setPhoto(image.file);
    } on FileTooLargeException catch (e) {
      if (mounted) setState(() => _problem = l.fileTooLargeNamed(name: e.name));
    }
  }

  String? _orNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _save() async {
    final l = context.l10n;
    final name = _name.text.trim();
    final email = _orNull(_email);
    final phone = _emergencyPhone.text.replaceAll(RegExp(r'\D'), '');
    setState(() {
      _nameError = name.isEmpty ? l.required : null;
      _emailError =
          email != null &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
          ? l.invalidEmail
          : null;
      _phoneError = phone.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(phone)
          ? l.invalidMobile
          : null;
    });
    if (_nameError != null || _emailError != null || _phoneError != null) {
      return;
    }
    setState(() {
      _busy = true;
      _problem = null;
    });
    final navigator = Navigator.of(context);
    final ok = await runAction(context, () async {
      String? photoId = _removePhoto ? null : d.photoMediaId;
      final photo = _photo;
      if (photo != null) {
        photoId = await uploadPhotoNow(
          ref.read(apiProvider),
          photo,
          readBytes: ref.read(photoStoreProvider).read,
          deviceId: await ref.read(sessionStoreProvider).deviceId(),
        );
      }
      await widget.onSave({
        'name': name,
        'photoMediaId': photoId,
        'dateOfBirth': _dateOfBirth,
        'email': email,
        'address': _orNull(_address),
        'emergencyContactName': _orNull(_emergencyName),
        'emergencyContactPhone': phone.isEmpty ? null : indianE164(phone),
      });
    });
    if (ok) {
      navigator.pop(true);
    } else if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final now = DateTime.now();
    final bytes = _photoBytes;
    final hasPhoto =
        !_removePhoto && (_photo != null || d.photoMediaId != null);
    return Scaffold(
      appBar: AppBar(title: Text(l.editProfile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: bytes != null && !_removePhoto
                      ? CircleAvatar(
                          key: const Key('profile-photo-new'),
                          radius: 48,
                          backgroundImage: MemoryImage(bytes),
                          onBackgroundImageError: (_, _) {},
                        )
                      : InitialsAvatar(
                          _name.text,
                          radius: 48,
                          photoMediaId: _removePhoto ? null : d.photoMediaId,
                        ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      key: const Key('profile-photo-take'),
                      onPressed: _busy ? null : _takePhoto,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(l.takePhoto),
                    ),
                    TextButton.icon(
                      key: const Key('profile-photo-choose'),
                      onPressed: _busy ? null : _choosePhoto,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l.choosePhoto),
                    ),
                    if (hasPhoto)
                      TextButton.icon(
                        key: const Key('profile-photo-remove'),
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                _removePhoto = true;
                                _photo = null;
                                _photoBytes = null;
                              }),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l.remove),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('profile-name-field'),
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l.yourName,
                    errorText: _nameError,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  key: const Key('profile-dob'),
                  onTap: () async {
                    final picked = await pickIsoDate(
                      context,
                      value: _dateOfBirth ?? '${now.year - 30}-01-01',
                      first: DateTime(now.year - 80),
                      last: DateTime(now.year - 18, now.month, now.day),
                    );
                    if (picked != null) setState(() => _dateOfBirth = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l.dateOfBirth,
                      suffixIcon: const Icon(Icons.cake_outlined, size: 18),
                    ),
                    child: Text(
                      _dateOfBirth == null
                          ? l.optional
                          : fmt.calendarDate(_dateOfBirth!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('profile-email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l.emailLabel,
                    hintText: l.optional,
                    errorText: _emailError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('profile-address'),
                  controller: _address,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l.addressLabel,
                    hintText: l.optional,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l.emergencyContact,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                TextField(
                  key: const Key('profile-emergency-name'),
                  controller: _emergencyName,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: l.contactName),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('profile-emergency-phone'),
                  controller: _emergencyPhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: const [IndianMobileFormatter()],
                  decoration: InputDecoration(
                    labelText: l.contactPhone,
                    prefixText: '+91 ',
                    errorText: _phoneError,
                  ),
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
                FilledButton(
                  key: const Key('profile-save'),
                  onPressed: _busy ? null : _save,
                  child: Text(l.save),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Changes the signed-in user's mobile number (their login): sends a code to
/// the new number, then checks it. True when the number changed.
Future<bool?> showChangePhone(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (_) => const _ChangePhoneDialog(),
);

class _ChangePhoneDialog extends ConsumerStatefulWidget {
  const _ChangePhoneDialog();

  @override
  ConsumerState<_ChangePhoneDialog> createState() => _ChangePhoneDialogState();
}

class _ChangePhoneDialogState extends ConsumerState<_ChangePhoneDialog> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  String get _digits => _phone.text.replaceAll(RegExp(r'\D'), '');

  Future<void> _send() async {
    final l = context.l10n;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(_digits)) {
      setState(() => _error = l.invalidMobile);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await runAction(
      context,
      () => ref.read(meApiProvider).requestPhoneOtp(indianE164(_digits)),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _codeSent = ok;
    });
  }

  Future<void> _verify() async {
    final l = context.l10n;
    final code = _code.text.trim();
    if (code.length != 6) {
      setState(() => _error = l.enterSixDigitCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    final ok = await runAction(
      context,
      () => ref
          .read(authProvider.notifier)
          .changePhone(indianE164(_digits), code),
    );
    if (ok) {
      navigator.pop(true);
    } else if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      key: const Key('change-phone-dialog'),
      title: Text(l.changePhone),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.changePhoneIntro),
            const SizedBox(height: 12),
            PhoneField(
              controller: _phone,
              enabled: !_codeSent && !_busy,
              autofocus: true,
            ),
            if (_codeSent) ...[
              const SizedBox(height: 12),
              Text(l.codeSentTo(phone: '+91 $_digits')),
              const SizedBox(height: 8),
              CodeField(controller: _code, onSubmitted: _verify),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l.cancel),
        ),
        FilledButton(
          key: const Key('change-phone-submit'),
          onPressed: _busy ? null : (_codeSent ? _verify : _send),
          child: Text(_codeSent ? l.verifyAndChange : l.sendCode),
        ),
      ],
    );
  }
}

/// A driver's photo and personal details, read-only (the owner's driver page).
class DriverPersonalDetails extends StatelessWidget {
  const DriverPersonalDetails(this.driver, {super.key});
  final Driver driver;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final d = driver;
    final emergency = [
      ?d.emergencyContactName,
      if (d.emergencyContactPhone case final p?) formatPhone(p),
    ].join(' · ');
    final rows = [
      (
        l.dateOfBirth,
        d.dateOfBirth == null ? null : fmt.calendarDate(d.dateOfBirth!),
      ),
      (l.emailLabel, d.email),
      (l.addressLabel, d.address),
      (l.emergencyContact, emergency.isEmpty ? null : emergency),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InitialsAvatar(d.name, radius: 28, photoMediaId: d.photoMediaId),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, value) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          label,
                          style: TextStyle(color: context.tc.muted),
                        ),
                      ),
                      Expanded(child: Text(value ?? '–')),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
