import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../core/api/models.dart';
import '../../common/format.dart';
import 'route_map.dart';

/// Where the map opens with no pin yet (the seeded demo fleet is in Pune).
const _pune = LatLng(18.5204, 73.8567);

/// An optional map pin for a trip's pickup or drop, under its address field:
/// "Add map pin" opens [PinPickerScreen]; once set, the coordinates with
/// change and remove. The address text stays what the driver reads; the pin
/// only adds a precise spot.
class PinField extends StatelessWidget {
  const PinField({
    required this.title,
    required this.value,
    required this.onChanged,
    this.near,
    super.key,
  });

  /// The picker's title, e.g. "Pickup on the map".
  final String title;
  final GeoPoint? value;
  final ValueChanged<GeoPoint?> onChanged;

  /// Where to open the map when there's no pin yet (e.g. the other pin).
  final GeoPoint? near;

  Future<void> _pick(BuildContext context) async {
    final picked = await Navigator.of(context).push<GeoPoint>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            PinPickerScreen(title: title, initial: value, near: near),
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pin = value;
    if (pin == null) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () => _pick(context),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: Text(l.addMapPin),
        ),
      );
    }
    return Row(
      children: [
        const Icon(Icons.location_on, size: 18, color: TaxcyColors.blue700),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            formatPin(pin),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextButton(onPressed: () => _pick(context), child: Text(l.changePin)),
        IconButton(
          tooltip: l.removePin,
          icon: const Icon(Icons.close),
          onPressed: () => onChanged(null),
        ),
      ],
    );
  }
}

/// "18.52040, 73.85670": five decimals is about a metre.
String formatPin(GeoPoint p) =>
    '${p.lat.toStringAsFixed(5)}, ${p.lng.toStringAsFixed(5)}';

/// Full-screen OpenStreetMap: tap to drop the pin, tap again to move it, then
/// "Use this pin". Pops the [GeoPoint] (six decimals, as the API stores it).
class PinPickerScreen extends ConsumerStatefulWidget {
  const PinPickerScreen({
    required this.title,
    this.initial,
    this.near,
    super.key,
  });

  final String title;
  final GeoPoint? initial;
  final GeoPoint? near;

  @override
  ConsumerState<PinPickerScreen> createState() => _PinPickerScreenState();
}

class _PinPickerScreenState extends ConsumerState<PinPickerScreen> {
  late GeoPoint? _pin = widget.initial;

  static double _round(double v) => double.parse(v.toStringAsFixed(6));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pin = _pin;
    final start = pin ?? widget.near;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          FlutterMap(
            key: const Key('pin-map'),
            options: MapOptions(
              initialCenter: start == null
                  ? _pune
                  : LatLng(start.lat, start.lng),
              initialZoom: start == null ? 11 : 14,
              // Without double-tap zoom the map reports a tap at once instead
              // of waiting to see if a second tap follows; pinch and the
              // scroll wheel still zoom.
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.doubleTapZoom,
              ),
              onTap: (_, point) => setState(
                () => _pin = GeoPoint(
                  _round(point.latitude),
                  _round(point.longitude),
                ),
              ),
            ),
            children: [
              if (ref.watch(mapTilesProvider))
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.taxcy.app',
                ),
              if (pin != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(pin.lat, pin.lng),
                      // The icon's tip, not its centre, marks the spot.
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: TaxcyColors.blue700,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              // OSM's tile policy asks for visible attribution.
              const Align(
                alignment: Alignment.bottomRight,
                child: ColoredBox(
                  color: Colors.white70,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  pin == null ? l.pinPickerHint : formatPin(pin),
                  key: const Key('pin-status'),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            key: const Key('pin-use'),
            onPressed: pin == null
                ? null
                : () => Navigator.of(context).pop(pin),
            icon: const Icon(Icons.check),
            label: Text(l.usePin),
          ),
        ),
      ),
    );
  }
}
