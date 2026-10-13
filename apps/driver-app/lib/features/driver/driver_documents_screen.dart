import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/format.dart';
import '../owner/documents_screen.dart';
import '../owner/owner_widgets.dart';
import 'driver_providers.dart';

/// The driver's own documents (licence, Aadhaar, PAN…): what they add or renew
/// waits for the fleet owner's approval, and shows on the owner's driver page.
class DriverDocumentsScreen extends ConsumerWidget {
  const DriverDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.navMyDocuments)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('my-document-add'),
        onPressed: () =>
            openScreen<void>(context, const DocumentFormScreen(mine: true)),
        icon: const Icon(Icons.add),
        label: Text(l.addDocument),
      ),
      body: RefreshPage(
        onRefresh: () => ref.refresh(myDocumentsProvider.future),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Text(
              l.myDocumentsIntro,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const DocumentsList.mine(),
        ],
      ),
    );
  }
}
