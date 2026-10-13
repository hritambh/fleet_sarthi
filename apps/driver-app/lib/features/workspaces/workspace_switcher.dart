import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart' show screensFor;
import '../../app/preferences.dart';
import '../../app/providers.dart';
import '../../app/workspaces.dart';
import '../common/errors.dart';
import '../common/format.dart';
import 'create_fleet_screen.dart';

/// Lists everything the user can do, across fleets: the fleets they run (owner
/// mode) and the ones they drive for (driver mode). Someone who runs no fleet
/// also gets "set up my fleet".
Future<void> showWorkspaceSwitcher(BuildContext context, WidgetRef ref) {
  final session = ref.read(authProvider).value;
  if (session == null) return Future.value();
  final mode = screensFor(session, ref.read(appModeProvider));
  final workspaces = workspacesFor(session);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) {
      final l = sheet.l10n;
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                l.switchWorkspace,
                style: Theme.of(sheet).textTheme.titleMedium,
              ),
            ),
            for (final w in workspaces)
              _WorkspaceTile(
                workspace: w,
                current: w.orgId == session.activeOrgId && w.mode == mode,
                onTap: () {
                  Navigator.of(sheet).pop();
                  openWorkspace(context, ref, w);
                },
              ),
            if (!workspaces.any((w) => w.mode == AppMode.owner))
              ListTile(
                key: const Key('set-up-fleet'),
                leading: const Icon(Icons.add_business),
                title: Text(l.setUpMyFleet),
                onTap: () {
                  Navigator.of(sheet).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CreateFleetScreen(),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    },
  );
}

/// Opens [workspace], showing why not (e.g. trip data still to sync) if it
/// can't.
Future<void> openWorkspace(
  BuildContext context,
  WidgetRef ref,
  Workspace workspace,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l = context.l10n;
  try {
    await ref.read(authProvider.notifier).open(workspace);
  } on Object catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(errorText(l, error))));
  }
}

class _WorkspaceTile extends StatelessWidget {
  const _WorkspaceTile({
    required this.workspace,
    required this.current,
    required this.onTap,
  });

  final Workspace workspace;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fleet = workspace.membership.orgName;
    final owner = workspace.mode == AppMode.owner;
    return ListTile(
      key: Key('workspace-${workspace.mode.name}-${workspace.orgId}'),
      selected: current,
      leading: Icon(owner ? Icons.business_center : Icons.local_taxi),
      title: Text(
        owner
            ? l.workspaceManage(fleet: fleet)
            : l.workspaceDrive(fleet: fleet),
      ),
      subtitle: Text(owner ? l.workspaceManageHint : l.workspaceDriveHint),
      trailing: current ? const Icon(Icons.check) : null,
      onTap: current ? () => Navigator.of(context).pop() : onTap,
    );
  }
}
