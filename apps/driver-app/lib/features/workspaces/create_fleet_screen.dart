import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../common/errors.dart';
import '../common/format.dart';

/// Sets up a fleet the user owns. They keep any fleets they drive for, and
/// switch between them from the menu.
class CreateFleetScreen extends ConsumerStatefulWidget {
  const CreateFleetScreen({super.key});

  @override
  ConsumerState<CreateFleetScreen> createState() => _CreateFleetScreenState();
}

class _CreateFleetScreenState extends ConsumerState<CreateFleetScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  var _alsoDrives = false;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    final l = context.l10n;
    try {
      await ref
          .read(authProvider.notifier)
          .createFleet(name: _name.text.trim(), alsoDrives: _alsoDrives);
      // The app now opens the new fleet in owner mode underneath.
      navigator.popUntil((route) => route.isFirst);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorText(l, error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.createFleetTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    key: const Key('fleet-name'),
                    controller: _name,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(labelText: l.fleetNameLabel),
                    validator: (v) => (v ?? '').trim().length < 2
                        ? l.fleetNameTooShort
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    key: const Key('fleet-also-drives'),
                    contentPadding: EdgeInsets.zero,
                    value: _alsoDrives,
                    onChanged: (v) => setState(() => _alsoDrives = v ?? false),
                    title: Text(l.iDriveToo),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('create-fleet'),
                    onPressed: _busy ? null : _submit,
                    child: Text(l.createFleet),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
