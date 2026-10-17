// Sending a trip's details to the customer: copied as text, or opened in
// WhatsApp addressed to the customer's number.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/models.dart';
import '../../common/format.dart';
import '../owner_providers.dart';
import '../owner_text.dart';

/// Opens a URL outside the app; replaced in tests.
final urlOpenerProvider = Provider<Future<bool> Function(Uri)>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
);

/// The trip as a message for the customer: pickup, drop, time, cab, driver
/// (with [driverPhone] when known) and fare. Dates are absolute
/// ("12 Oct, 2:30 pm"), never "Today".
String tripShareText(Fmt fmt, Trip t, {String? driverPhone}) {
  final l = fmt.l;
  final start = t.scheduledStartAt;
  final fare = t.includedKm == null
      ? fmt.inr(t.quotedFarePaise)
      : l.shareFareWithKm(
          fare: fmt.inr(t.quotedFarePaise),
          km: fmt.km(t.includedKm!),
        );
  return [
    l.shareTripHeading,
    if (t.customerName != null) '${l.shareCustomer}: ${t.customerName}',
    '${l.sharePickup}: ${t.fromText}',
    if (t.toText != null) '${l.shareDrop}: ${t.toText}',
    '${l.sharePickupTime}: ${fmt.date(start)}, ${fmt.time(start)}',
    if (t.vehicle != null)
      '${l.shareCab}: ${[if (t.vehicle!.model.isNotEmpty) t.vehicle!.model, formatRegistration(t.vehicle!.registrationNo)].join(' · ')}',
    if (t.driverName != null)
      '${l.shareDriver}: ${t.driverName}'
          '${driverPhone == null ? '' : ' (${formatPhone(driverPhone)})'}',
    '${l.shareFare}: $fare',
  ].join('\n');
}

/// wa.me link with [text] pre-filled, addressed to [phoneE164] when known
/// (otherwise WhatsApp asks whom to send it to).
Uri whatsAppUri(String text, String? phoneE164) {
  final digits = phoneE164?.replaceAll(RegExp(r'\D'), '') ?? '';
  return Uri.https('wa.me', digits.isEmpty ? '/' : '/$digits', {'text': text});
}

/// [tripShareText] for [trip], with its driver's phone once drivers load.
String tripShareTextFor(BuildContext context, WidgetRef ref, Trip trip) {
  final drivers = ref.watch(driversProvider).value ?? const [];
  final driverPhone = drivers
      .where((d) => d.id == trip.driverId)
      .firstOrNull
      ?.phone;
  return tripShareText(context.fmt, trip, driverPhone: driverPhone);
}

/// Copies [text] (the trip's details) and says so.
Future<void> copyTripDetails(BuildContext context, String text) async {
  final l = context.l10n;
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l.detailsCopied)));
}

/// The WhatsApp button for [trip]. Copying the details is in the trip's menu.
class TripWhatsAppButton extends ConsumerWidget {
  const TripWhatsAppButton(this.trip, {super.key});
  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final text = tripShareTextFor(context, ref, trip);
    return FilledButton.icon(
      key: const Key('trip-whatsapp'),
      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1FA855)),
      icon: const Icon(Icons.chat),
      label: Text(l.shareOnWhatsApp),
      onPressed: () async {
        final opened = await ref.read(urlOpenerProvider)(
          whatsAppUri(text, trip.customerPhone),
        );
        if (opened || !context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.whatsAppUnavailable)));
      },
    );
  }
}
