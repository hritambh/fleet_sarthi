// The pickup and drop fields on a new trip: type a city and pick it from the
// bundled list of Indian cities and towns (see cities.dart), which fills the
// trip's address and its map pin together.
//
// The text field stays an ordinary one, so somewhere not on the list can still
// be typed in and the trip saved — the list adds to the field, it does not gate
// it. For a spot finer than a city, the map pin below is still there.
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'cities.dart';
import 'format.dart';

class AddressField extends StatefulWidget {
  const AddressField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChosen,
    this.cities,
    super.key,
  });

  /// Goes on the text field itself, so it is what a caller or a test finds.
  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final IconData icon;

  /// Given the chosen city, so the caller can keep its pin with the text.
  final ValueChanged<City> onChosen;

  /// The list to offer. Loaded from the bundled asset when not given.
  final Cities? cities;

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  final _focus = FocusNode();
  Cities? _cities;
  List<City> _results = const [];

  /// The text last chosen from the list, so picking a city doesn't immediately
  /// offer it again.
  String? _chosen;

  @override
  void initState() {
    super.initState();
    _cities = widget.cities;
    if (_cities == null) {
      Cities.load().then((cities) {
        if (mounted) setState(() => _cities = cities);
      });
    }
    widget.controller.addListener(_onTyped);
    _focus.addListener(() {
      if (!_focus.hasFocus && _results.isNotEmpty) {
        setState(() => _results = const []);
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTyped);
    _focus.dispose();
    super.dispose();
  }

  void _onTyped() {
    final cities = _cities;
    if (cities == null) return;
    final query = widget.controller.text.trim();
    setState(
      () => _results = query == _chosen ? const [] : cities.search(query),
    );
  }

  void _choose(City city) {
    _chosen = city.label;
    widget.controller.text = city.label;
    widget.onChosen(city);
    setState(() => _results = const []);
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final typed = widget.controller.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: widget.fieldKey,
          controller: widget.controller,
          focusNode: _focus,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.icon),
          ),
        ),
        if (_results.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Keyed by position: two towns can share a name across states.
                for (final (index, city) in _results.indexed)
                  ListTile(
                    key: Key('city-$index'),
                    dense: true,
                    leading: const Icon(
                      Icons.location_city_outlined,
                      color: TaxcyColors.muted,
                    ),
                    title: Text(city.name),
                    subtitle: Text(city.state),
                    onTap: () => _choose(city),
                  ),
              ],
            ),
          )
        else if (_cities != null && typed.isNotEmpty && typed != _chosen)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              l.noPlacesFound,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
