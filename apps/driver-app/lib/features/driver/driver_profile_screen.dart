import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/owner_models.dart';
import '../account/account_security_screen.dart';
import '../common/format.dart';
import '../common/language_picker.dart';
import '../owner/owner_text.dart';
import '../owner/owner_widgets.dart';
import '../workspaces/workspace_switcher.dart';
import 'driver_profile_form.dart';
import 'driver_providers.dart';

/// Who the driver is in this fleet: photo, name, mobile number (they can
/// change both), personal details, the cabs they may drive, and account
/// settings (fleet, language, security, sign out).
class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    Driver driver,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = context.l10n.profileSaved;
    final done = await openScreen<bool>(
      context,
      DriverProfileFormScreen(
        driver: driver,
        onSave: (body) async {
          await ref.read(authProvider.notifier).saveProfile(body);
          ref.invalidate(myDriverProvider);
        },
      ),
    );
    if (done ?? false) messenger.showSnackBar(SnackBar(content: Text(saved)));
  }

  Future<void> _changePhone(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final changed = context.l10n.phoneChanged;
    if (await showChangePhone(context) ?? false) {
      ref.invalidate(myDriverProvider);
      messenger.showSnackBar(SnackBar(content: Text(changed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final session = ref.watch(authProvider).value;
    final me = ref.watch(myDriverProvider);
    final driver = me.value;
    final name = driver?.name ?? session?.name ?? '';
    final phone = session?.phone ?? driver?.phone ?? '';
    const muted = TextStyle(color: TaxcyColors.muted);
    String orDash(String? v) => v == null || v.isEmpty ? '–' : v;
    Widget detail(IconData icon, String label, String value, String key) =>
        ListTile(
          key: Key(key),
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon),
          title: Text(label),
          subtitle: Text(value),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: RefreshPage(
        onRefresh: () => ref.refresh(myDriverProvider.future),
        children: [
          PageWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        InitialsAvatar(
                          name,
                          radius: 32,
                          photoMediaId: driver?.photoMediaId,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                key: const Key('profile-name'),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (phone.isNotEmpty)
                                Text(formatPhone(phone), style: muted),
                              if (driver != null)
                                Text(
                                  l.driverSince(
                                    date: fmt.calendarDate(
                                      istDate(driver.createdAt),
                                    ),
                                  ),
                                  style: muted,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: const Key('profile-edit'),
                          tooltip: l.editProfile,
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: driver == null
                              ? null
                              : () => _editProfile(context, ref, driver),
                        ),
                      ],
                    ),
                  ),
                ),
                SectionCard(
                  title: l.personalDetails,
                  actions: [
                    TextButton.icon(
                      key: const Key('profile-edit-details'),
                      onPressed: driver == null
                          ? null
                          : () => _editProfile(context, ref, driver),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(l.editProfile),
                    ),
                  ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        key: const Key('profile-phone'),
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.phone_outlined),
                        title: Text(l.phoneNumberLabel),
                        subtitle: Text(
                          phone.isEmpty ? '–' : formatPhone(phone),
                        ),
                        trailing: IconButton(
                          key: const Key('profile-change-phone'),
                          tooltip: l.changePhone,
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _changePhone(context, ref),
                        ),
                      ),
                      detail(
                        Icons.cake_outlined,
                        l.dateOfBirth,
                        driver?.dateOfBirth == null
                            ? '–'
                            : fmt.calendarDate(driver!.dateOfBirth!),
                        'profile-dob-value',
                      ),
                      detail(
                        Icons.mail_outline,
                        l.emailLabel,
                        orDash(driver?.email),
                        'profile-email-value',
                      ),
                      detail(
                        Icons.home_outlined,
                        l.addressLabel,
                        orDash(driver?.address),
                        'profile-address-value',
                      ),
                      detail(
                        Icons.contact_emergency_outlined,
                        l.emergencyContact,
                        orDash(
                          [
                            ?driver?.emergencyContactName,
                            if (driver?.emergencyContactPhone case final p?)
                              formatPhone(p),
                          ].join(' · '),
                        ),
                        'profile-emergency-value',
                      ),
                      detail(
                        Icons.business_outlined,
                        l.fleetLabel,
                        orDash(session?.activeMembership?.orgName),
                        'profile-fleet',
                      ),
                    ],
                  ),
                ),
                SectionCard(
                  title: l.cabsYouDrive,
                  child: AsyncView(
                    value: me,
                    onRetry: () => ref.invalidate(myDriverProvider),
                    builder: (d) => d.vehicles.isEmpty
                        ? EmptyState(l.noCabsLinked)
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final v in d.vehicles)
                                NumberPlate(
                                  formatRegistration(v.registrationNo),
                                  key: ValueKey('profile-cab-${v.id}'),
                                ),
                            ],
                          ),
                  ),
                ),
                SectionCard(
                  child: Column(
                    children: [
                      ListTile(
                        key: const Key('profile-workspace'),
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.swap_horiz),
                        title: Text(l.switchWorkspace),
                        onTap: () => showWorkspaceSwitcher(context, ref),
                      ),
                      ListTile(
                        key: const Key('profile-language'),
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.translate),
                        title: Text(l.language),
                        onTap: () => showLanguagePicker(context, ref),
                      ),
                      ListTile(
                        key: const Key('profile-security'),
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.lock_outline),
                        title: Text(l.accountSecurity),
                        onTap: () => openScreen<void>(
                          context,
                          const AccountSecurityScreen(),
                        ),
                      ),
                      ListTile(
                        key: const Key('profile-sign-out'),
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          l.signOut,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onTap: () => ref.read(authProvider.notifier).signOut(),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'v$appVersion',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: TaxcyColors.muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
