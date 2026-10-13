import '../core/api/models.dart';
import 'preferences.dart';

/// One thing the signed-in person can do in one fleet: run it (owner or
/// manager) or drive for it. Roles belong to a fleet, not to the account, so a
/// person can have several: an owner who also drives someone else's vehicle
/// manages their own fleet and drives in the other one.
class Workspace {
  const Workspace(this.membership, this.mode);

  final Membership membership;
  final AppMode mode;

  String get orgId => membership.orgId;
}

/// Every workspace of [session]: the fleets they run first, then the fleets
/// they drive for, each in membership order.
List<Workspace> workspacesFor(Session session) => [
  for (final m in session.memberships)
    if (m.isStaff) Workspace(m, AppMode.owner),
  for (final m in session.memberships)
    if (m.isDriver) Workspace(m, AppMode.driver),
];

/// Thrown when switching fleets would drop driver data this device hasn't sent
/// yet ([count] items); the driver goes online and waits for sync first.
class UnsyncedWorkException implements Exception {
  const UnsyncedWorkException(this.count);

  final int count;

  @override
  String toString() => 'UnsyncedWorkException($count)';
}
