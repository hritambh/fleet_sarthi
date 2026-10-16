import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/places/places_api.dart';
import 'format.dart';

/// A pickup or drop text field that suggests places in India (towns,
/// localities, stations) once three letters are typed and typing pauses.
///
/// Suggestions are optional: whatever is typed is kept, Enter doesn't pick
/// one, and [onPicked] is only called when a suggestion is tapped. Offline or
/// with place search switched off on the server, it is a plain text field.
class PlaceField extends ConsumerStatefulWidget {
  const PlaceField({
    required this.fieldKey,
    required this.controller,
    required this.decoration,
    this.validator,
    this.onPicked,
    super.key,
  });

  /// Key of the text field itself (tests and the forms find it by this).
  final Key fieldKey;
  final TextEditingController controller;
  final InputDecoration decoration;
  final FormFieldValidator<String>? validator;
  final ValueChanged<PlaceSuggestion>? onPicked;

  /// How long typing must pause before the search is asked.
  static const debounce = Duration(milliseconds: 400);

  @override
  ConsumerState<PlaceField> createState() => _PlaceFieldState();
}

class _PlaceFieldState extends ConsumerState<PlaceField> {
  final _focus = FocusNode();

  /// Bumped on every keystroke, so a slower, older search can tell it's stale.
  int _query = 0;

  /// The label just picked: the field now shows it, and there's no need to
  /// search for it again.
  String? _picked;

  /// What the list shows now, kept while a newer search is on its way.
  List<PlaceSuggestion> _shown = const [];

  /// The pause before the search: a newer keystroke, or leaving the screen,
  /// cancels it.
  Timer? _debounce;
  Completer<bool>? _waiting;

  /// Waiting for the search: a small spinner shows in the field.
  bool _searching = false;

  @override
  void dispose() {
    _cancelPause();
    _focus.dispose();
    super.dispose();
  }

  /// An answer that never comes, for a search that outlived the field:
  /// RawAutocomplete uses its context when the options arrive without
  /// checking it's still mounted, so a late answer would throw.
  Future<List<PlaceSuggestion>> get _never =>
      Completer<List<PlaceSuggestion>>().future;

  /// True once typing has paused; false if cancelled first.
  Future<bool> _pause() {
    _cancelPause();
    final waiting = _waiting = Completer<bool>();
    _debounce = Timer(PlaceField.debounce, () => waiting.complete(true));
    return waiting.future;
  }

  void _cancelPause() {
    _debounce?.cancel();
    final waiting = _waiting;
    if (waiting != null && !waiting.isCompleted) waiting.complete(false);
  }

  Future<List<PlaceSuggestion>> _options(TextEditingValue value) async {
    final text = value.text.trim();
    final ticket = ++_query;
    if (text.replaceAll(' ', '').length < PlacesApi.minLetters ||
        text == _picked) {
      _cancelPause();
      if (_searching && mounted) setState(() => _searching = false);
      return _shown = const [];
    }
    if (!mounted) return _never;
    // Read before any await: the screen may close mid-search.
    final places = ref.read(placesApiProvider);
    final paused = await _pause();
    if (!mounted) return _never;
    if (!paused || ticket != _query) return _shown;
    setState(() => _searching = true);
    final found = await places.search(text);
    if (!mounted) return _never;
    if (ticket != _query) return _shown; // a newer search owns the spinner
    setState(() => _searching = false);
    return _shown = found;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => RawAutocomplete<PlaceSuggestion>(
      textEditingController: widget.controller,
      focusNode: _focus,
      displayStringForOption: (s) => s.label,
      optionsBuilder: _options,
      onSelected: (s) {
        _picked = s.label;
        widget.onPicked?.call(s);
      },
      fieldViewBuilder: (context, controller, focusNode, _) => TextFormField(
        key: widget.fieldKey,
        controller: controller,
        focusNode: focusNode,
        decoration: _searching
            ? widget.decoration.copyWith(
                suffixIcon: const Padding(
                  key: Key('place-searching'),
                  padding: EdgeInsets.all(14),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : widget.decoration,
        validator: widget.validator,
        textInputAction: TextInputAction.next,
      ),
      optionsViewBuilder: (context, onSelected, options) => _Options(
        options: options.toList(),
        width: constraints.maxWidth,
        onSelected: onSelected,
      ),
    ),
  );
}

class _Options extends StatelessWidget {
  const _Options({
    required this.options,
    required this.width,
    required this.onSelected,
  });

  final List<PlaceSuggestion> options;
  final double width;
  final AutocompleteOnSelected<PlaceSuggestion> onSelected;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.topStart,
    child: Material(
      key: const Key('place-options'),
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 300, maxWidth: width),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            for (final s in options)
              ListTile(
                key: ValueKey('place-option-${s.label}'),
                dense: true,
                leading: const Icon(Icons.place_outlined, size: 20),
                title: Text(
                  s.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: s.detail == null
                    ? null
                    : Text(
                        s.detail!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                onTap: () => onSelected(s),
              ),
            // Geoapify's free plan and OpenStreetMap's licence both ask for
            // this wherever their results show.
            Padding(
              key: const Key('place-credit'),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Text(
                context.l10n.placesCredit,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
