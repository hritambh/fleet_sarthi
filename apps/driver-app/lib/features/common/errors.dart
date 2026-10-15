import '../../app/workspaces.dart';
import '../../core/api/api.dart';
import '../../core/repositories/trips_repository.dart';
import '../../l10n/app_localizations.dart';
import '../owner/owner_text.dart' show formatRegistration;
import 'format.dart';

/// The user's-language text for an API error code; null for codes the app
/// doesn't know (show the server's English message then).
String? errorCodeText(AppLocalizations l, String code) => switch (code) {
  'NETWORK' => l.errorNetwork,
  'VALIDATION_FAILED' => l.errorValidationFailed,
  'UNAUTHENTICATED' => l.errorUnauthenticated,
  'TOKEN_EXPIRED' => l.errorTokenExpired,
  'FORBIDDEN_ROLE' => l.errorForbiddenRole,
  'NO_ACTIVE_ORG' => l.errorNoActiveOrg,
  'NOT_FOUND' => l.errorNotFound,
  'ILLEGAL_TRANSITION' => l.errorIllegalTransition,
  'TRIP_CANCELLED' => l.errorTripCancelled,
  'TRIP_REASSIGNED' => l.errorTripReassigned,
  'VEHICLE_BUSY' => l.errorVehicleBusy,
  'DRIVER_BUSY' => l.errorDriverBusy,
  'CANCELLATION_PENDING' => l.errorCancellationPending,
  'DRIVER_TRIPS_DISABLED' => l.errorDriverTripsDisabled,
  'DRIVER_CHARGES_DISABLED' => l.errorDriverChargesDisabled,
  'RECEIPT_REQUIRED' => l.errorReceiptRequired,
  'ALREADY_SETTLED' => l.errorAlreadySettled,
  'IDEMPOTENCY_CONFLICT' => l.errorIdempotencyConflict,
  'IDEMPOTENCY_KEY_REQUIRED' => l.errorIdempotencyKeyRequired,
  'VERSION_CONFLICT' => l.errorVersionConflict,
  'CONFLICT' => l.errorConflict,
  'FUEL_TYPE_MISMATCH' => l.errorFuelTypeMismatch,
  'ODOMETER_BEFORE_START' => l.errorOdometerBeforeStart,
  'OTP_INVALID' => l.errorOtpInvalid,
  'OTP_EXPIRED' => l.errorOtpExpired,
  'DRIVER_ON_TRIP' => l.errorDriverOnTrip,
  'DRIVER_INACTIVE' => l.errorDriverInactive,
  'DRIVER_HAS_TRIPS' => l.errorDriverHasTrips,
  'VEHICLE_ON_TRIP' => l.errorVehicleOnTrip,
  'DRIVER_NOT_LINKED' => l.errorDriverNotLinked,
  'LINK_IN_USE' => l.errorLinkInUse,
  'INVALID_CREDENTIALS' => l.errorInvalidCredentials,
  'ACCOUNT_EXISTS' => l.errorAccountExists,
  'PHONE_OTP_DISABLED' => l.errorPhoneOtpDisabled,
  'PHONE_NOT_VERIFIED' => l.errorPhoneNotVerified,
  'PHONE_MISMATCH' => l.errorPhoneMismatch,
  'PHONE_VERIFICATION_REQUIRED' => l.errorPhoneVerificationRequired,
  'RATE_LIMITED' => l.errorRateLimited,
  'UPLOAD_NOT_FOUND' => l.errorUploadNotFound,
  'UPLOAD_MISMATCH' => l.errorUploadMismatch,
  'UPLOAD_FAILED' => l.errorUploadFailed,
  'INTERNAL' => l.errorInternal,
  _ => null,
};

/// Any error as text for the user: API errors by code (falling back to the
/// server's message), local checks by reason, anything else as-is.
String errorText(AppLocalizations l, Object error) => switch (error) {
  ApiException(:final code, :final message, :final details) =>
    _detailedText(l, code, details) ?? errorCodeText(l, code) ?? message,
  LocalRejection() => rejectionText(l, error),
  UnsyncedWorkException(:final count) => l.unsyncedBeforeSwitch(count: count),
  _ => l.somethingWentWrong(error: '$error'),
};

/// A more specific text for codes whose details name what went wrong.
String? _detailedText(AppLocalizations l, String code, Object? details) {
  if (details is! Map) return null;
  switch (code) {
    case 'DRIVER_NOT_LINKED':
      final driver = details['driverName'];
      final reg = details['registrationNo'];
      if (driver is String && reg is String) {
        return l.errorDriverNotLinkedNamed(
          driver: driver,
          vehicle: formatRegistration(reg),
        );
      }
    case 'LINK_IN_USE':
      final trips = details['tripIds'];
      if (trips is List && trips.isNotEmpty) {
        return l.errorLinkInUseCount(count: trips.length);
      }
  }
  return null;
}

/// An outbox item's stored error ("CODE: message") in the user's language.
String outboxErrorText(AppLocalizations l, String? stored) {
  if (stored == null) return '';
  final colon = stored.indexOf(': ');
  if (colon < 0) return stored;
  return errorCodeText(l, stored.substring(0, colon)) ??
      stored.substring(colon + 2);
}

String rejectionText(AppLocalizations l, LocalRejection r) =>
    switch (r.reason) {
      RejectionReason.endBeforeStart => l.rejectEndBeforeStart,
      RejectionReason.needDrop => l.rejectNeedDrop,
      RejectionReason.endBelowStart => l.rejectEndBelowStart(km: '${r.km}'),
      RejectionReason.chargesActiveOnly => l.rejectChargesActiveOnly,
      RejectionReason.paymentsAfterStart => l.rejectPaymentsAfterStart,
      RejectionReason.tripCancelled => l.rejectTripCancelled,
      RejectionReason.cancellationPending => l.rejectCancellationPending,
      RejectionReason.noPendingCancellation => l.rejectNoPendingCancellation,
      RejectionReason.notAllowed => l.rejectNotAllowed,
      RejectionReason.wrongState => l.rejectWrongState(
        status: statusLabel(l, r.status ?? ''),
      ),
      RejectionReason.anotherTripRunning => l.rejectAnotherTripRunning(
        route: r.route ?? '',
      ),
    };
