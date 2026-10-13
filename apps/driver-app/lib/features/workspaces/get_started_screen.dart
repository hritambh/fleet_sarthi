import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../common/errors.dart';
import '../common/format.dart';
import '../common/language_picker.dart';
import 'create_fleet_screen.dart';

/// For someone signed in without a fleet: they either drive for an owner (who
/// adds their number, then "check again" picks it up) or own vehicles and set
/// up their own fleet. Same account either way.
class GetStartedScreen extends ConsumerStatefulWidget {
  const GetStartedScreen({super.key});

  @override
  ConsumerState<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen> {
  var _checking = false;

  Future<void> _checkAgain() async {
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l10n;
    setState(() => _checking = true);
    try {
      final found = await ref.read(authProvider.notifier).refreshFleets();
      if (!found) {
        messenger.showSnackBar(SnackBar(content: Text(l.stillNoFleet)));
      }
    } on Object catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(errorText(l, error))));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final phone = ref.watch(authProvider).value?.phone ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(l.getStartedTitle),
        actions: const [LanguageButton()],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_taxi),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l.getStartedDriveTitle,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(l.getStartedDriveBody(phone: phone)),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const Key('check-again'),
                          onPressed: _checking ? null : _checkAgain,
                          icon: const Icon(Icons.refresh),
                          label: Text(l.checkAgain),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.business_center),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l.getStartedOwnTitle,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(l.getStartedOwnBody),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          key: const Key('set-up-fleet'),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CreateFleetScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.add_business),
                          label: Text(l.setUpMyFleet),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.read(authProvider.notifier).signOut(),
                  child: Text(l.signOut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
