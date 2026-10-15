import 'package:flutter/material.dart';

import 'format.dart';

/// Names the page for the browser tab (and the Android recents list):
/// "Trips - Fleet Sarthi".
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Title(
    title: '$title - ${context.l10n.appTitle}',
    color: Theme.of(context).colorScheme.primary,
    child: child,
  );
}
