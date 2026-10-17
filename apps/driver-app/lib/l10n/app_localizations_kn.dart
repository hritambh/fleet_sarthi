// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'ಫ್ಲೀಟ್ ಸಾರಥಿ';

  @override
  String get signOut => 'ಸೈನ್ ಔಟ್';

  @override
  String get language => 'ಭಾಷೆ';

  @override
  String get languageDevice => 'ಫೋನ್‌ನ ಭಾಷೆ';

  @override
  String get appearance => 'ತೋರಿಕೆ';

  @override
  String get themeSystem => 'ಫೋನ್‌ನ ಸೆಟ್ಟಿಂಗ್';

  @override
  String get themeLight => 'ಲೈಟ್';

  @override
  String get themeDark => 'ಡಾರ್ಕ್';

  @override
  String get switchToDark => 'ಡಾರ್ಕ್ ಮೋಡ್‌ಗೆ ಬದಲಿಸಿ';

  @override
  String get switchToLight => 'ಲೈಟ್ ಮೋಡ್‌ಗೆ ಬದಲಿಸಿ';

  @override
  String get retry => 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get cancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get save => 'ಉಳಿಸಿ';

  @override
  String get back => 'ಹಿಂದೆ';

  @override
  String get close => 'ಮುಚ್ಚಿ';

  @override
  String get optional => 'ಐಚ್ಛಿಕ';

  @override
  String get notSet => 'ಹೊಂದಿಸಿಲ್ಲ';

  @override
  String get noValue => '—';

  @override
  String somethingWentWrong({required String error}) {
    return 'ಏನೋ ತಪ್ಪಾಗಿದೆ: $error';
  }

  @override
  String kmValue({required String km}) {
    return '$km km';
  }

  @override
  String get unitLitres => 'L';

  @override
  String get unitKg => 'kg';

  @override
  String get unitKm => 'km';

  @override
  String get today => 'ಇಂದು';

  @override
  String get tomorrow => 'ನಾಳೆ';

  @override
  String get yesterday => 'ನಿನ್ನೆ';

  @override
  String dayAndTime({required String day, required String time}) {
    return '$day, $time';
  }

  @override
  String get loginIntro =>
      'ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್‌ನಿಂದ ಸೈನ್ ಇನ್ ಮಾಡಿ. ಡ್ರೈವರ್‌ಗಳು ತಮ್ಮ ಫ್ಲೀಟ್ ಮಾಲೀಕರು ನೋಂದಾಯಿಸಿದ ನಂಬರ್ ಬಳಸಿ.';

  @override
  String loginCodeSent({required String phone}) {
    return '$phone ಗೆ ಕಳುಹಿಸಿದ ಕೋಡ್ ನಮೂದಿಸಿ';
  }

  @override
  String get mobileNumber => 'ಮೊಬೈಲ್ ನಂಬರ್';

  @override
  String get sixDigitCode => '6 ಅಂಕಿಯ ಕೋಡ್';

  @override
  String get sendCode => 'ಕೋಡ್ ಕಳುಹಿಸಿ';

  @override
  String get useDifferentNumber => 'ಬೇರೆ ನಂಬರ್ ಬಳಸಿ';

  @override
  String get enterTenDigitMobile => 'ನಿಮ್ಮ 10 ಅಂಕಿಯ ಮೊಬೈಲ್ ನಂಬರ್ ನಮೂದಿಸಿ';

  @override
  String get enterSixDigitCode => '6 ಅಂಕಿಯ ಕೋಡ್ ನಮೂದಿಸಿ';

  @override
  String get loginCheckNumber => 'ನಂಬರ್ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get ownerMode => 'ಮಾಲೀಕ ಮೋಡ್';

  @override
  String get driverMode => 'ಡ್ರೈವರ್ ಮೋಡ್';

  @override
  String get errorNetwork =>
      'ಸಂಪರ್ಕ ಇಲ್ಲ. ಇಂಟರ್ನೆಟ್ ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorValidationFailed =>
      'ಕೆಲವು ವಿವರಗಳು ಸರಿಯಾಗಿಲ್ಲ. ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorUnauthenticated =>
      'ನೀವು ಸೈನ್ ಔಟ್ ಆಗಿದ್ದೀರಿ. ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get errorTokenExpired => 'ನಿಮ್ಮ ಸೆಷನ್ ಮುಗಿದಿದೆ. ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get errorForbiddenRole => 'ಇದನ್ನು ಮಾಡಲು ನಿಮಗೆ ಅನುಮತಿ ಇಲ್ಲ.';

  @override
  String get errorNoActiveOrg => 'ನಿಮ್ಮ ನಂಬರ್ ಇನ್ನೂ ಯಾವುದೇ ಫ್ಲೀಟ್‌ನಲ್ಲಿ ಇಲ್ಲ.';

  @override
  String get errorNotFound => 'ಸಿಗಲಿಲ್ಲ. ಇದನ್ನು ತೆಗೆದುಹಾಕಿರಬಹುದು.';

  @override
  String get errorIllegalTransition =>
      'ಟ್ರಿಪ್‌ನ ಈಗಿನ ಸ್ಥಿತಿಯಲ್ಲಿ ಇದನ್ನು ಮಾಡಲು ಆಗುವುದಿಲ್ಲ. ರಿಫ್ರೆಶ್ ಮಾಡಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorTripCancelled => 'ಈ ಟ್ರಿಪ್ ರದ್ದಾಗಿದೆ.';

  @override
  String get errorTripReassigned =>
      'ಈ ಟ್ರಿಪ್ ಅನ್ನು ಬೇರೆ ಡ್ರೈವರ್‌ಗೆ ವಹಿಸಲಾಗಿದೆ.';

  @override
  String get errorVehicleBusy => 'ಆ ವಾಹನ ಅದೇ ಸಮಯಕ್ಕೆ ಈಗಾಗಲೇ ಬುಕ್ ಆಗಿದೆ.';

  @override
  String get errorDriverBusy => 'ಆ ಡ್ರೈವರ್ ಅದೇ ಸಮಯಕ್ಕೆ ಈಗಾಗಲೇ ಬುಕ್ ಆಗಿದ್ದಾರೆ.';

  @override
  String get errorCancellationPending =>
      'ಒಂದು ರದ್ದತಿ ವಿನಂತಿ ಈಗಾಗಲೇ ನಿರ್ಧಾರಕ್ಕಾಗಿ ಕಾಯುತ್ತಿದೆ.';

  @override
  String get errorAlreadySettled => 'ಆ ದಿನದ ಸೆಟಲ್‌ಮೆಂಟ್ ಈಗಾಗಲೇ ಆಗಿದೆ.';

  @override
  String get errorIdempotencyConflict =>
      'ಇದನ್ನು ಈಗಾಗಲೇ ಬೇರೆ ವಿವರಗಳೊಂದಿಗೆ ಕಳುಹಿಸಲಾಗಿದೆ.';

  @override
  String get errorIdempotencyKeyRequired =>
      'ವಿನಂತಿ ಅಪೂರ್ಣವಾಗಿತ್ತು. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorVersionConflict =>
      'ಅದೇ ಸಮಯದಲ್ಲಿ ಬೇರೆಯವರು ಇದನ್ನು ಬದಲಾಯಿಸಿದ್ದಾರೆ. ರಿಫ್ರೆಶ್ ಮಾಡಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorConflict => 'ಇದು ಈಗಿರುವ ದಾಖಲೆಯೊಂದಿಗೆ ಹೊಂದಾಣಿಕೆಯಾಗುತ್ತಿಲ್ಲ.';

  @override
  String get errorFuelTypeMismatch =>
      'ಆ ಇಂಧನ ವಾಹನದ ಇಂಧನ ಪ್ರಕಾರಕ್ಕೆ ಹೊಂದುವುದಿಲ್ಲ.';

  @override
  String get errorOdometerBeforeStart =>
      'ಓಡೋಮೀಟರ್ ರೀಡಿಂಗ್ ಟ್ರಿಪ್ ಆರಂಭದಲ್ಲಿದ್ದಕ್ಕಿಂತ ಕಡಿಮೆ ಇದೆ.';

  @override
  String get errorOtpInvalid => 'ಆ ಕೋಡ್ ಸರಿಯಿಲ್ಲ. ಪರಿಶೀಲಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorOtpExpired => 'ಕೋಡ್‌ನ ಅವಧಿ ಮುಗಿದಿದೆ. ಹೊಸ ಕೋಡ್ ಕೇಳಿ.';

  @override
  String get errorInvalidCredentials =>
      'ಮೊಬೈಲ್ ನಂಬರ್ ಅಥವಾ ಪಾಸ್‌ವರ್ಡ್ ತಪ್ಪಾಗಿದೆ.';

  @override
  String get errorAccountExists =>
      'ಈ ನಂಬರ್‌ಗೆ ಈಗಾಗಲೇ ಖಾತೆ ಇದೆ. ಲಾಗ್ ಇನ್ ಮಾಡಿ, ಅಥವಾ ಪಾಸ್‌ವರ್ಡ್ ರೀಸೆಟ್ ಮಾಡಿ.';

  @override
  String get errorRateLimited =>
      'ತುಂಬಾ ಪ್ರಯತ್ನಗಳು. ಕೆಲವು ನಿಮಿಷ ಕಾದು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorUploadNotFound =>
      'ಫೋಟೋ ಇನ್ನೂ ಸರ್ವರ್ ತಲುಪಿಲ್ಲ. ಸ್ವಲ್ಪ ಸಮಯದ ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorUploadMismatch =>
      'ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ ಫೋಟೋ ಹೊಂದುತ್ತಿಲ್ಲ. ಮತ್ತೆ ತೆಗೆಯಿರಿ.';

  @override
  String get errorUploadFailed =>
      'ಫೋಟೋ ಅಪ್‌ಲೋಡ್ ವಿಫಲವಾಗಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲಾಗುವುದು.';

  @override
  String get errorInternal => 'ಸರ್ವರ್‌ನಲ್ಲಿ ಏನೋ ತಪ್ಪಾಗಿದೆ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get statusCreated => 'ವಹಿಸಿಲ್ಲ';

  @override
  String get statusAssigned => 'ವಹಿಸಲಾಗಿದೆ';

  @override
  String get statusStarted => 'ರಸ್ತೆಯಲ್ಲಿದೆ';

  @override
  String get statusEnded => 'ಮುಗಿದಿದೆ';

  @override
  String get statusSettled => 'ಸೆಟಲ್ ಆಗಿದೆ';

  @override
  String get statusCancelled => 'ರದ್ದಾಗಿದೆ';

  @override
  String get myTrips => 'ನನ್ನ ಟ್ರಿಪ್‌ಗಳು';

  @override
  String get newTrip => 'ಹೊಸ ಟ್ರಿಪ್';

  @override
  String get logFuel => 'ಇಂಧನ ದಾಖಲಿಸಿ';

  @override
  String get groupOnTheRoad => 'ರಸ್ತೆಯಲ್ಲಿ';

  @override
  String get groupToday => 'ಇಂದು';

  @override
  String get groupUpcoming => 'ಮುಂಬರುವ';

  @override
  String get groupRecent => 'ಇತ್ತೀಚಿನ';

  @override
  String get noTripsYet =>
      'ಇನ್ನೂ ಯಾವುದೇ ಟ್ರಿಪ್ ಇಲ್ಲ. ರಿಫ್ರೆಶ್ ಮಾಡಲು ಕೆಳಗೆ ಎಳೆಯಿರಿ.';

  @override
  String get conflictCancelledShort => 'ಮಾಲೀಕರು ರದ್ದುಮಾಡಿದ್ದಾರೆ';

  @override
  String get conflictReassignedShort => 'ಬೇರೆಯವರಿಗೆ ವಹಿಸಲಾಗಿದೆ';

  @override
  String get tripNotFoundOnPhone => 'ಈ ಫೋನ್‌ನಲ್ಲಿ ಟ್ರಿಪ್ ಸಿಗಲಿಲ್ಲ';

  @override
  String includesKm({required String km}) {
    return '$km km ಸೇರಿದೆ';
  }

  @override
  String startOdometerKm({required String km}) {
    return 'ಆರಂಭದ ಓಡೋಮೀಟರ್: $km km';
  }

  @override
  String endOdometerKm({required String km}) {
    return 'ಕೊನೆಯ ಓಡೋಮೀಟರ್: $km km';
  }

  @override
  String get cancellationRequested => 'ರದ್ದತಿಗೆ ವಿನಂತಿಸಲಾಗಿದೆ';

  @override
  String get cancellationWaiting =>
      'ನಿಮ್ಮ ಮಾಲೀಕರು ಒಪ್ಪುವುದು ಅಥವಾ ತಿರಸ್ಕರಿಸುವುದಕ್ಕಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ.';

  @override
  String get charges => 'ಶುಲ್ಕಗಳು';

  @override
  String get fuel => 'ಇಂಧನ';

  @override
  String get collected => 'ಸಂಗ್ರಹಿಸಿದ್ದು';

  @override
  String get startTrip => 'ಟ್ರಿಪ್ ಆರಂಭಿಸಿ';

  @override
  String get chargeButton => 'ಶುಲ್ಕ';

  @override
  String get requestCancellation => 'ರದ್ದತಿಗೆ ವಿನಂತಿಸಿ';

  @override
  String get endTrip => 'ಟ್ರಿಪ್ ಮುಗಿಸಿ';

  @override
  String get conflictCancelledBanner =>
      'ಈ ಟ್ರಿಪ್ ಅನ್ನು ಮಾಲೀಕರು ರದ್ದುಮಾಡಿದ್ದಾರೆ';

  @override
  String get conflictReassignedBanner =>
      'ಈ ಟ್ರಿಪ್ ಅನ್ನು ಬೇರೆ ಡ್ರೈವರ್‌ಗೆ ವಹಿಸಲಾಗಿದೆ';

  @override
  String get conflictBannerDetail =>
      'ಇದಕ್ಕಾಗಿ ನೀವು ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ದಾಖಲಿಸಿದ್ದು ಅನ್ವಯವಾಗಿಲ್ಲ. ನಿಮ್ಮ ಫೋಟೋಗಳನ್ನು ಮಾಲೀಕರಿಗೆ ಕಳುಹಿಸಲಾಗಿದೆ.';

  @override
  String get elapsed => 'ಕಳೆದ ಸಮಯ';

  @override
  String get kmByGps => 'GPS ಪ್ರಕಾರ km';

  @override
  String get methodCash => 'ನಗದು';

  @override
  String get methodUpi => 'UPI';

  @override
  String get methodCard => 'ಕಾರ್ಡ್';

  @override
  String get chargeToll => 'ಟೋಲ್';

  @override
  String get chargeParking => 'ಪಾರ್ಕಿಂಗ್';

  @override
  String get chargeStateTax => 'ರಾಜ್ಯ ತೆರಿಗೆ';

  @override
  String get chargeDriverAllowance => 'ಡ್ರೈವರ್ ಭತ್ಯೆ';

  @override
  String get chargeNightCharge => 'ರಾತ್ರಿ ಶುಲ್ಕ';

  @override
  String get chargeExtraKm => 'ಹೆಚ್ಚುವರಿ km';

  @override
  String get chargeOther => 'ಇತರೆ';

  @override
  String get chargeNoteExtraFare => 'ಹೆಚ್ಚುವರಿ ಬಾಡಿಗೆ · ಗ್ರಾಹಕರು ಪಾವತಿಸುತ್ತಾರೆ';

  @override
  String get chargeNotePaidByYou =>
      'ನೀವು ಪಾವತಿಸಿದ್ದು · ಸೆಟಲ್‌ಮೆಂಟ್‌ನಲ್ಲಿ ವಾಪಸ್';

  @override
  String get chargeNoteBilled => 'ಗ್ರಾಹಕರ ಬಿಲ್‌ಗೆ ಸೇರಿಸಲಾಗಿದೆ';

  @override
  String get fuelPetrol => 'ಪೆಟ್ರೋಲ್';

  @override
  String get fuelDiesel => 'ಡೀಸೆಲ್';

  @override
  String get fuelCng => 'CNG';

  @override
  String get fuelEv => 'EV';

  @override
  String get evNoFuel =>
      'ಎಲೆಕ್ಟ್ರಿಕ್ ವಾಹನಗಳಿಗೆ ಇಂಧನ ತುಂಬಿಸುವಿಕೆ ಅಥವಾ ಇಂಧನ ಆಡಿಟ್ ಇಲ್ಲ.';

  @override
  String get fuelPetrolCng => 'ಪೆಟ್ರೋಲ್ + CNG';

  @override
  String get paidByChoiceMe => 'ನಾನು (ನಗದು)';

  @override
  String get paidByOwner => 'ಮಾಲೀಕರು';

  @override
  String get paidByFuelCard => 'ಫ್ಯೂಯಲ್ ಕಾರ್ಡ್';

  @override
  String get paidByLabelYou => 'ನೀವು ಪಾವತಿಸಿದ್ದು';

  @override
  String get paidByLabelOwner => 'ಮಾಲೀಕರು ಪಾವತಿಸಿದ್ದು';

  @override
  String get paidByLabelDriverCash => 'ಡ್ರೈವರ್ ನಗದು ಪಾವತಿಸಿದ್ದು';

  @override
  String fuelFillLabel({
    required String fuel,
    required String quantity,
    required String unit,
  }) {
    return '$fuel $quantity $unit';
  }

  @override
  String fullTankSuffix({required String label}) {
    return '$label · ಫುಲ್ ಟ್ಯಾಂಕ್';
  }

  @override
  String get addCharge => 'ಶುಲ್ಕ ಸೇರಿಸಿ';

  @override
  String get chargeType => 'ಪ್ರಕಾರ';

  @override
  String get amount => 'ಮೊತ್ತ';

  @override
  String get extraFareTitle => 'ಗ್ರಾಹಕರ ಬಾಡಿಗೆಗೆ ಸೇರಿಸಲಾಗಿದೆ';

  @override
  String get extraFareSubtitle => 'ಬಾಡಿಗೆಯ ಜೊತೆ ಗ್ರಾಹಕರಿಂದ ಪಡೆಯಿರಿ.';

  @override
  String get iPaidThis => 'ಇದನ್ನು ನಾನು ಪಾವತಿಸಿದೆ';

  @override
  String get paidBackInSettlement =>
      'ನಿಮ್ಮ ಸೆಟಲ್‌ಮೆಂಟ್‌ನಲ್ಲಿ ನಿಮಗೆ ವಾಪಸ್ ಸಿಗುತ್ತದೆ';

  @override
  String get receiptPhotoOptional => 'ರಸೀದಿ ಫೋಟೋ (ಐಚ್ಛಿಕ)';

  @override
  String get odometerPhoto => 'ಓಡೋಮೀಟರ್ ಫೋಟೋ';

  @override
  String get takeOdometerPhoto => 'ಓಡೋಮೀಟರ್‌ನ ಫೋಟೋ ತೆಗೆಯಿರಿ';

  @override
  String get odometerReading => 'ಓಡೋಮೀಟರ್ ರೀಡಿಂಗ್';

  @override
  String get typeExactly => 'ತೋರಿಸಿದಂತೆಯೇ ಟೈಪ್ ಮಾಡಿ';

  @override
  String startedAtKm({required String km}) {
    return '$km km ನಲ್ಲಿ ಆರಂಭವಾಯಿತು';
  }

  @override
  String kmOverIncluded({required String over, required String included}) {
    return 'ಬಾಡಿಗೆಯಲ್ಲಿ ಸೇರಿರುವ $included km ಗಿಂತ $over km ಹೆಚ್ಚು. ಕೆಳಗೆ ಹೆಚ್ಚುವರಿ km ಶುಲ್ಕ ಸೇರಿಸಿ.';
  }

  @override
  String get chargesYouPaidOrAdded => 'ನೀವು ಪಾವತಿಸಿದ ಅಥವಾ ಸೇರಿಸಿದ ಶುಲ್ಕಗಳು';

  @override
  String addedDuringTrip({required String note}) {
    return 'ಟ್ರಿಪ್ ಸಮಯದಲ್ಲಿ ಸೇರಿಸಿದ್ದು · $note';
  }

  @override
  String get extraFare => 'ಹೆಚ್ಚುವರಿ ಬಾಡಿಗೆ';

  @override
  String get iPaid => 'ನಾನು ಪಾವತಿಸಿದೆ';

  @override
  String get addChargeRow => 'ಟೋಲ್, ರಾತ್ರಿ ಶುಲ್ಕ, ಹೆಚ್ಚುವರಿ km ಸೇರಿಸಿ…';

  @override
  String get fuelFilledOnTrip => 'ಈ ಟ್ರಿಪ್‌ನಲ್ಲಿ ತುಂಬಿಸಿದ ಇಂಧನ';

  @override
  String fuelPaidByYouNote({required String amount}) {
    return 'ನೀವು ಪಾವತಿಸಿದ $amount ಇಂಧನ ನಿಮ್ಮ ಸೆಟಲ್‌ಮೆಂಟ್‌ನಲ್ಲಿ ವಾಪಸ್ ಸಿಗುತ್ತದೆ; ಗ್ರಾಹಕರು ಇದನ್ನು ಪಾವತಿಸುವುದಿಲ್ಲ.';
  }

  @override
  String customerPaidExpected({required String amount}) {
    return 'ಗ್ರಾಹಕರು ಪಾವತಿಸಿದ್ದು · ನಿರೀಕ್ಷಿತ $amount';
  }

  @override
  String fareBreakdownFare({required String amount}) {
    return 'ಬಾಡಿಗೆ $amount';
  }

  @override
  String fareBreakdownExtra({required String amount}) {
    return 'ಹೆಚ್ಚುವರಿ ಬಾಡಿಗೆ $amount';
  }

  @override
  String fareBreakdownExpenses({required String amount}) {
    return 'ಟೋಲ್ ಮತ್ತು ಖರ್ಚು $amount';
  }

  @override
  String alreadyRecorded({required String amount}) {
    return 'ಟ್ರಿಪ್ ಸಮಯದಲ್ಲಿ ಈಗಾಗಲೇ $amount ದಾಖಲಾಗಿದೆ';
  }

  @override
  String get splitPayment => 'ಭಾಗವಾಗಿ ಪಾವತಿ';

  @override
  String get cancelRequestIntro =>
      'ನಿಮ್ಮ ಮಾಲೀಕರು ಇದನ್ನು ಒಪ್ಪುತ್ತಾರೆ ಅಥವಾ ತಿರಸ್ಕರಿಸುತ್ತಾರೆ. ಅಲ್ಲಿಯವರೆಗೆ ಟ್ರಿಪ್ ಮುಂದುವರಿಯುತ್ತದೆ.';

  @override
  String get reason => 'ಕಾರಣ';

  @override
  String get reasonHint => 'ಉದಾ. ಗ್ರಾಹಕರು ಲೋನಾವಲಾದಲ್ಲಿ ಇಳಿದರು';

  @override
  String get reasonRequired => 'ಕಾರಣವನ್ನು ಮಾಲೀಕರಿಗೆ ತಿಳಿಸಿ';

  @override
  String get sendRequest => 'ವಿನಂತಿ ಕಳುಹಿಸಿ';

  @override
  String get tripTypeOneWay => 'ಒನ್ ವೇ';

  @override
  String get tripTypeRoundTrip => 'ರೌಂಡ್ ಟ್ರಿಪ್';

  @override
  String get tripTypeLocal => 'ಲೋಕಲ್';

  @override
  String hours({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಗಂಟೆ',
      one: '1 ಗಂಟೆ',
    );
    return '$_temp0';
  }

  @override
  String get pickup => 'ಪಿಕಪ್';

  @override
  String get enterPickup => 'ಪಿಕಪ್ ಸ್ಥಳ ನಮೂದಿಸಿ';

  @override
  String get drop => 'ಡ್ರಾಪ್';

  @override
  String get enterDrop => 'ಡ್ರಾಪ್ ಸ್ಥಳ ನಮೂದಿಸಿ';

  @override
  String get starts => 'ಆರಂಭ';

  @override
  String get expectedDuration => 'ನಿರೀಕ್ಷಿತ ಅವಧಿ';

  @override
  String get vehicle => 'ವಾಹನ';

  @override
  String get fare => 'ಬಾಡಿಗೆ';

  @override
  String get includedKm => 'ಸೇರಿರುವ km';

  @override
  String get includedKmInvalid => 'km ನಮೂದಿಸಿ, ಅಥವಾ ಖಾಲಿ ಬಿಡಿ';

  @override
  String get customerNameOptional => 'ಗ್ರಾಹಕರ ಹೆಸರು (ಐಚ್ಛಿಕ)';

  @override
  String get customerMobileOptional => 'ಗ್ರಾಹಕರ ಮೊಬೈಲ್ (ಐಚ್ಛಿಕ)';

  @override
  String get editTrip => 'ಟ್ರಿಪ್ ಬದಲಿಸಿ';

  @override
  String get createTrip => 'ಟ್ರಿಪ್ ರಚಿಸಿ';

  @override
  String get newTripFootnote =>
      'ಟ್ರಿಪ್ ಅನ್ನು ನಿಮಗೆ ವಹಿಸಲಾಗಿದೆ. ನಿಮ್ಮ ಫೋನ್ ಆನ್‌ಲೈನ್ ಆದ ಮೇಲೆ ಫ್ಲೀಟ್ ಮಾಲೀಕರಿಗೆ ಕಾಣುತ್ತದೆ.';

  @override
  String get fuelSaved =>
      'ಇಂಧನ ತುಂಬಿಸಿದ್ದು ಉಳಿಸಲಾಗಿದೆ; ಇದು ತಾನಾಗಿಯೇ ಸಿಂಕ್ ಆಗುತ್ತದೆ';

  @override
  String get noVehicleAssigned =>
      'ಈಗ ನಿಮಗೆ ಯಾವುದೇ ವಾಹನ ವಹಿಸಿಲ್ಲ. ನಿಮ್ಮ ಟ್ರಿಪ್‌ನ ವಾಹನಕ್ಕೆ ಇಂಧನ ದಾಖಲಿಸಬಹುದು; ವಾಹನ ವಹಿಸಲು ನಿಮ್ಮ ಫ್ಲೀಟ್ ಮಾಲೀಕರನ್ನು ಕೇಳಿ.';

  @override
  String get vehicleNotDownloaded =>
      'ಈ ವಾಹನದ ವಿವರಗಳು ಇನ್ನೂ ಡೌನ್‌ಲೋಡ್ ಆಗಿಲ್ಲ. ಒಮ್ಮೆ ಇಂಟರ್ನೆಟ್‌ಗೆ ಸಂಪರ್ಕಿಸಿ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get vehicleOnThisTrip => 'ಈ ಟ್ರಿಪ್‌ನ ವಾಹನ';

  @override
  String fromYourTrip({required String route}) {
    return 'ನಿಮ್ಮ ಟ್ರಿಪ್‌ನಿಂದ: $route';
  }

  @override
  String get vehiclesOnYourTrips => 'ನಿಮ್ಮ ಟ್ರಿಪ್‌ಗಳ ವಾಹನಗಳು';

  @override
  String fuelKind({required String fuel}) {
    return 'ಇಂಧನ: $fuel';
  }

  @override
  String get receiptPhoto => 'ರಸೀದಿ ಫೋಟೋ';

  @override
  String get takeReceiptPhoto => 'ರಸೀದಿಯ ಫೋಟೋ ತೆಗೆಯಿರಿ';

  @override
  String get quantity => 'ಪ್ರಮಾಣ';

  @override
  String enterQuantity({required String unit}) {
    return 'ತುಂಬಿಸಿದ $unit ನಮೂದಿಸಿ';
  }

  @override
  String get fullTank => 'ಫುಲ್ ಟ್ಯಾಂಕ್';

  @override
  String get fullTankHint => 'ಟ್ಯಾಂಕ್ ಪೂರ್ತಿ ತುಂಬಿಸಿದ್ದರೆ ಆನ್ ಮಾಡಿ';

  @override
  String get whoPaid => 'ಯಾರು ಪಾವತಿಸಿದರು?';

  @override
  String get saveFuelFill => 'ಇಂಧನ ತುಂಬಿಸಿದ್ದು ಉಳಿಸಿ';

  @override
  String get syncStatus => 'ಸಿಂಕ್ ಸ್ಥಿತಿ';

  @override
  String get syncOffline => 'ಆಫ್‌ಲೈನ್';

  @override
  String syncOfflineSaved({required int count}) {
    return 'ಆಫ್‌ಲೈನ್ · ಫೋನ್‌ನಲ್ಲಿ $count ಉಳಿಸಲಾಗಿದೆ';
  }

  @override
  String syncPending({required int count}) {
    return '$count ಬಾಕಿ ಇದೆ';
  }

  @override
  String get synced => 'ಸಿಂಕ್ ಆಗಿದೆ';

  @override
  String needAttention({required int count}) {
    return '$count ಗಮನಿಸಬೇಕಾಗಿದೆ';
  }

  @override
  String get attentionTitle => 'ಇವುಗಳನ್ನು ಕಳುಹಿಸಲು ಆಗಲಿಲ್ಲ';

  @override
  String get attentionSubtitle =>
      'ಸರ್ವರ್ ಇವುಗಳನ್ನು ತಿರಸ್ಕರಿಸಿದೆ. ನಿಮ್ಮ ಮಾಲೀಕರನ್ನು ಕೇಳಿ, ಅಥವಾ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get retryAll => 'ಎಲ್ಲವನ್ನೂ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get outboxMedia => 'ಫೋಟೋ';

  @override
  String get outboxTripCommand => 'ಟ್ರಿಪ್ ಅಪ್‌ಡೇಟ್';

  @override
  String get outboxTripCreate => 'ಹೊಸ ಟ್ರಿಪ್';

  @override
  String get outboxTripCharge => 'ಶುಲ್ಕ';

  @override
  String get outboxTripCollection => 'ಪಾವತಿ';

  @override
  String get outboxFuelFill => 'ಇಂಧನ ತುಂಬಿಸಿದ್ದು';

  @override
  String get noPhotoYet => 'ಇನ್ನೂ ಫೋಟೋ ಇಲ್ಲ';

  @override
  String get photoTaken => 'ಫೋಟೋ ತೆಗೆಯಲಾಗಿದೆ';

  @override
  String get takePhoto => 'ಫೋಟೋ ತೆಗೆಯಿರಿ';

  @override
  String get retake => 'ಮತ್ತೆ ತೆಗೆಯಿರಿ';

  @override
  String get enterOdometerKm => 'ಓಡೋಮೀಟರ್ ರೀಡಿಂಗ್ ಅನ್ನು km ನಲ್ಲಿ ನಮೂದಿಸಿ';

  @override
  String mustBeAtLeastKm({required String km}) {
    return 'ಕನಿಷ್ಠ $km km ಇರಬೇಕು';
  }

  @override
  String get enterAmount => '₹ ನಲ್ಲಿ ಮೊತ್ತ ನಮೂದಿಸಿ';

  @override
  String get amountMoreThanZero => 'ಮೊತ್ತ ₹0 ಗಿಂತ ಹೆಚ್ಚಿರಬೇಕು';

  @override
  String get enterFare => '₹ ನಲ್ಲಿ ಬಾಡಿಗೆ ನಮೂದಿಸಿ';

  @override
  String get consentTitle => 'ಟ್ರಿಪ್ ಸಮಯದಲ್ಲಿ ಲೊಕೇಶನ್';

  @override
  String get consentWhen =>
      'ಫ್ಲೀಟ್ ಸಾರಥಿ ಟ್ರಿಪ್ ನಡೆಯುತ್ತಿರುವಾಗ ಮಾತ್ರ (\"ಟ್ರಿಪ್ ಆರಂಭಿಸಿ\" ಮತ್ತು \"ಟ್ರಿಪ್ ಮುಗಿಸಿ\" ನಡುವೆ) ನಿಮ್ಮ ಫೋನ್‌ನ ಲೊಕೇಶನ್ ದಾಖಲಿಸುತ್ತದೆ. ದಾಖಲಿಸುತ್ತಿರುವಷ್ಟು ಹೊತ್ತು ಒಂದು ನೋಟಿಫಿಕೇಶನ್ ಕಾಣುತ್ತದೆ.';

  @override
  String get consentWhy =>
      'ನಿಮ್ಮ ಫ್ಲೀಟ್ ಮಾಲೀಕರು ಇದರಿಂದ ಮಾರ್ಗವನ್ನು ನೋಡುತ್ತಾರೆ ಮತ್ತು ದೂರವನ್ನು ಓಡೋಮೀಟರ್ ಜೊತೆ ಹೋಲಿಸುತ್ತಾರೆ. ಇದನ್ನು ಓಡೋಮೀಟರ್ ಮತ್ತು ರಸೀದಿ ಫೋಟೋಗಳ ಜೊತೆಗೂ ಸೇರಿಸಲಾಗುತ್ತದೆ. ನೀವು ಡ್ಯೂಟಿಯಲ್ಲಿ ಇಲ್ಲದಿದ್ದಾಗ ಇದನ್ನು ಸಂಗ್ರಹಿಸುವುದಿಲ್ಲ.';

  @override
  String get consentRetention =>
      'ಮಾರ್ಗದ ಡೇಟಾವನ್ನು 12 ತಿಂಗಳವರೆಗೆ ಇಟ್ಟು ನಂತರ ಅಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get consentContinue => 'ನನಗೆ ಅರ್ಥವಾಯಿತು, ಮುಂದುವರಿಸಿ';

  @override
  String cameraUnavailable({required String error}) {
    return 'ಕ್ಯಾಮೆರಾ ಲಭ್ಯವಿಲ್ಲ: $error';
  }

  @override
  String couldNotTakePhoto({required String error}) {
    return 'ಫೋಟೋ ತೆಗೆಯಲು ಆಗಲಿಲ್ಲ: $error';
  }

  @override
  String get fitOdometer => 'ಪೂರ್ತಿ ಓಡೋಮೀಟರ್ ಫ್ರೇಮ್‌ನಲ್ಲಿ ಬರುವಂತೆ ಇಡಿ';

  @override
  String get fitReceipt => 'ಪೂರ್ತಿ ರಸೀದಿ ಫ್ರೇಮ್‌ನಲ್ಲಿ ಬರುವಂತೆ ಇಡಿ';

  @override
  String get fitDocument => 'ಪೂರ್ತಿ ದಾಖಲೆ ಫ್ರೇಮ್‌ನಲ್ಲಿ ಬರುವಂತೆ ಇಡಿ';

  @override
  String get documentPhoto => 'ದಾಖಲೆ ಫೋಟೋ';

  @override
  String get gpsNotificationTitle => 'ಟ್ರಿಪ್ ನಡೆಯುತ್ತಿದೆ';

  @override
  String get gpsNotificationText =>
      'ಫ್ಲೀಟ್ ಸಾರಥಿ ಈ ಟ್ರಿಪ್‌ನ ನಿಮ್ಮ ಮಾರ್ಗವನ್ನು ದಾಖಲಿಸುತ್ತಿದೆ.';

  @override
  String get rejectEndBeforeStart => 'ಟ್ರಿಪ್ ಆರಂಭವಾದ ನಂತರವೇ ಮುಗಿಯಬೇಕು';

  @override
  String get rejectNeedDrop => 'ಟ್ರಿಪ್ ಎಲ್ಲಿಗೆ ಹೋಗುತ್ತದೆ ಎಂದು ನಮೂದಿಸಿ';

  @override
  String rejectEndBelowStart({required String km}) {
    return 'ಕೊನೆಯ ರೀಡಿಂಗ್ ಕನಿಷ್ಠ $km km ಇರಬೇಕು';
  }

  @override
  String get rejectChargesActiveOnly =>
      'ನಡೆಯುತ್ತಿರುವ ಟ್ರಿಪ್‌ಗೆ ಮಾತ್ರ ಶುಲ್ಕ ಸೇರಿಸಬಹುದು';

  @override
  String get rejectPaymentsAfterStart =>
      'ಟ್ರಿಪ್ ಆರಂಭವಾದ ನಂತರ ಪಾವತಿಗಳನ್ನು ದಾಖಲಿಸಬಹುದು';

  @override
  String get rejectTripCancelled => 'ಈ ಟ್ರಿಪ್ ರದ್ದಾಗಿದೆ';

  @override
  String get rejectCancellationPending =>
      'ಈ ಟ್ರಿಪ್‌ಗೆ ಒಂದು ರದ್ದತಿ ವಿನಂತಿ ಈಗಾಗಲೇ ಬಾಕಿ ಇದೆ';

  @override
  String get rejectNoPendingCancellation => 'ಯಾವುದೇ ರದ್ದತಿ ವಿನಂತಿ ಬಾಕಿ ಇಲ್ಲ';

  @override
  String rejectAnotherTripRunning({required String route}) {
    return 'ಇನ್ನೊಂದು ಆರಂಭಿಸುವ ಮೊದಲು ನಿಮ್ಮ ಟ್ರಿಪ್ $route ಮುಗಿಸಿ';
  }

  @override
  String get errorDriverOnTrip =>
      'ಡ್ರೈವರ್‌ನ ಒಂದು ಟ್ರಿಪ್ ಈಗಾಗಲೇ ರಸ್ತೆಯಲ್ಲಿದೆ. ಇನ್ನೊಂದು ಆರಂಭಿಸುವ ಮೊದಲು ಅದನ್ನು ಮುಗಿಸಿ.';

  @override
  String get errorVehicleOnTrip =>
      'ಈ ವಾಹನ ಈಗಾಗಲೇ ಬೇರೆ ಟ್ರಿಪ್‌ನಲ್ಲಿ ರಸ್ತೆಯಲ್ಲಿದೆ. ಮೊದಲು ಆ ಟ್ರಿಪ್ ಮುಗಿಸಿ.';

  @override
  String get rejectNotAllowed => 'ಈ ಟ್ರಿಪ್‌ನಲ್ಲಿ ನೀವು ಇದನ್ನು ಮಾಡುವಂತಿಲ್ಲ';

  @override
  String rejectWrongState({required String status}) {
    return 'ಟ್ರಿಪ್ $status ಇರುವಾಗ ಇದನ್ನು ಮಾಡಲು ಆಗುವುದಿಲ್ಲ';
  }

  @override
  String get navDashboard => 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್';

  @override
  String get navTrips => 'ಟ್ರಿಪ್‌ಗಳು';

  @override
  String get navAlerts => 'ಅಲರ್ಟ್‌ಗಳು';

  @override
  String get navMore => 'ಇನ್ನಷ್ಟು';

  @override
  String get vehicles => 'ವಾಹನಗಳು';

  @override
  String get drivers => 'ಡ್ರೈವರ್‌ಗಳು';

  @override
  String get members => 'ಸದಸ್ಯರು';

  @override
  String get documents => 'ದಾಖಲೆಗಳು';

  @override
  String get review => 'ಪರಿಶೀಲನೆ';

  @override
  String get settlements => 'ಸೆಟಲ್‌ಮೆಂಟ್‌ಗಳು';

  @override
  String get settings => 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get loadFailed => 'ಇದನ್ನು ಲೋಡ್ ಮಾಡಲು ಆಗಲಿಲ್ಲ.';

  @override
  String get edit => 'ಬದಲಿಸಿ';

  @override
  String get all => 'ಎಲ್ಲಾ';

  @override
  String get unassigned => 'ವಹಿಸಿಲ್ಲ';

  @override
  String get required => 'ಅಗತ್ಯ';

  @override
  String get roleOwner => 'ಮಾಲೀಕ';

  @override
  String get roleManager => 'ಮ್ಯಾನೇಜರ್';

  @override
  String get roleDriver => 'ಡ್ರೈವರ್';

  @override
  String get ownerOnly => 'ಇದನ್ನು ಮಾಲೀಕರು ಮಾತ್ರ ಬದಲಿಸಬಹುದು.';

  @override
  String get severityCritical => 'ಗಂಭೀರ';

  @override
  String get severityWarning => 'ಎಚ್ಚರಿಕೆ';

  @override
  String get severityInfo => 'ಮಾಹಿತಿ';

  @override
  String get seeAll => 'ಎಲ್ಲವನ್ನೂ ನೋಡಿ';

  @override
  String get pickDate => 'ದಿನಾಂಕ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get status => 'ಸ್ಥಿತಿ';

  @override
  String get name => 'ಹೆಸರು';

  @override
  String get note => 'ಟಿಪ್ಪಣಿ';

  @override
  String get total => 'ಒಟ್ಟು';

  @override
  String get active => 'ಸಕ್ರಿಯ';

  @override
  String get inactive => 'ನಿಷ್ಕ್ರಿಯ';

  @override
  String percentValue({required String value}) {
    return '$value%';
  }

  @override
  String minutesShort({required int count}) {
    return '$count ನಿಮಿಷ';
  }

  @override
  String listAnd({required String first, required String last}) {
    return '$first ಮತ್ತು $last';
  }

  @override
  String get todaysTrips => 'ಇಂದಿನ ಟ್ರಿಪ್‌ಗಳು';

  @override
  String get noTripsToday => 'ಇಂದು ಯಾವುದೇ ಟ್ರಿಪ್ ನಿಗದಿಯಾಗಿಲ್ಲ';

  @override
  String get needsAttention => 'ನಿಮ್ಮ ಗಮನ ಬೇಕಾಗಿದೆ';

  @override
  String get criticalAlerts => 'ಗಂಭೀರ ಅಲರ್ಟ್‌ಗಳು';

  @override
  String get openAlerts => 'ಬಾಕಿ ಅಲರ್ಟ್‌ಗಳು';

  @override
  String get toReview => 'ಪರಿಶೀಲಿಸಬೇಕಾದವು';

  @override
  String get documentsDueSoon => 'ಶೀಘ್ರದಲ್ಲೇ ಅವಧಿ ಮುಗಿಯುವ ದಾಖಲೆಗಳು';

  @override
  String get nothingExpiring =>
      'ಮುಂದಿನ 30 ದಿನಗಳಲ್ಲಿ ಯಾವುದರ ಅವಧಿಯೂ ಮುಗಿಯುವುದಿಲ್ಲ';

  @override
  String get noOpenAlerts => 'ಯಾವುದೇ ಬಾಕಿ ಅಲರ್ಟ್ ಇಲ್ಲ';

  @override
  String get allStatuses => 'ಎಲ್ಲಾ ಸ್ಥಿತಿಗಳು';

  @override
  String get anyDate => 'ಯಾವುದೇ ದಿನಾಂಕ';

  @override
  String get allDrivers => 'ಎಲ್ಲಾ ಡ್ರೈವರ್‌ಗಳು';

  @override
  String get allVehicles => 'ಎಲ್ಲಾ ವಾಹನಗಳು';

  @override
  String get noTripsMatch => 'ಈ ಫಿಲ್ಟರ್‌ಗಳಿಗೆ ಯಾವುದೇ ಟ್ರಿಪ್ ಹೊಂದುವುದಿಲ್ಲ';

  @override
  String localTrip({required String from}) {
    return '$from (ಲೋಕಲ್)';
  }

  @override
  String get tripType => 'ಟ್ರಿಪ್ ಪ್ರಕಾರ';

  @override
  String get quotedFare => 'ಹೇಳಿದ ಬಾಡಿಗೆ';

  @override
  String get includedKmHint =>
      'ಬಾಡಿಗೆಯಲ್ಲಿ ಸೇರಿರುವ km, ಉದಾ. 300 km ಪ್ಯಾಕೇಜ್‌ಗೆ 300';

  @override
  String get customerName => 'ಗ್ರಾಹಕರ ಹೆಸರು';

  @override
  String get customerMobile => 'ಗ್ರಾಹಕರ ಮೊಬೈಲ್';

  @override
  String get ends => 'ಮುಕ್ತಾಯ';

  @override
  String get vehicleOptional => 'ವಾಹನ (ಐಚ್ಛಿಕ)';

  @override
  String get driverOptional => 'ಡ್ರೈವರ್ (ಐಚ್ಛಿಕ)';

  @override
  String get assignLater => 'ನಂತರ ವಹಿಸಿ';

  @override
  String get pickBothOrNeither =>
      'ವಾಹನ ಮತ್ತು ಡ್ರೈವರ್ ಎರಡನ್ನೂ ಆಯ್ಕೆಮಾಡಿ, ಅಥವಾ ಯಾವುದನ್ನೂ ಬೇಡ';

  @override
  String get tripDetails => 'ಟ್ರಿಪ್';

  @override
  String get customer => 'ಗ್ರಾಹಕ';

  @override
  String get driver => 'ಡ್ರೈವರ್';

  @override
  String get startedAt => 'ಶುರುವಾಗಿದೆ';

  @override
  String get endedAt => 'ಮುಗಿದಿದೆ';

  @override
  String get cancelledAt => 'ರದ್ದಾಗಿದೆ';

  @override
  String get odometerDistance => 'ಓಡೋಮೀಟರ್ ದೂರ';

  @override
  String kmOverDriven({required String over, required String driven}) {
    return '$over km ಹೆಚ್ಚು ($driven km ಓಡಿಸಲಾಗಿದೆ)';
  }

  @override
  String drivenKm({required String km}) {
    return '$km km ಓಡಿಸಲಾಗಿದೆ';
  }

  @override
  String get cancellationFare => 'ರದ್ದತಿ ಶುಲ್ಕ';

  @override
  String get assign => 'ನಿಯೋಜಿಸಿ';

  @override
  String get reassign => 'ಮರು ನಿಯೋಜಿಸಿ';

  @override
  String get unassign => 'ನಿಯೋಜನೆ ತೆಗೆಯಿರಿ';

  @override
  String get cancelTrip => 'ಟ್ರಿಪ್ ರದ್ದು ಮಾಡಿ';

  @override
  String get cancelTripTitle => 'ಈ ಟ್ರಿಪ್ ರದ್ದು ಮಾಡಿ';

  @override
  String get assignTripTitle => 'ಟ್ರಿಪ್ ನಿಯೋಜಿಸಿ';

  @override
  String get reassignTripTitle => 'ಟ್ರಿಪ್ ಮರು ನಿಯೋಜಿಸಿ';

  @override
  String get overlapNote =>
      'ಅದೇ ಸಮಯಕ್ಕೆ ಈಗಾಗಲೇ ಬುಕ್ ಆಗಿರುವ ವಾಹನ ಅಥವಾ ಡ್ರೈವರ್ ಅನ್ನು ನಿಯೋಜಿಸಲು ಆಗುವುದಿಲ್ಲ.';

  @override
  String get cancellationRequestTitle => 'ರದ್ದತಿ ವಿನಂತಿ';

  @override
  String requestedBy({required String role, required String when}) {
    return '$when ರಂದು $role ವಿನಂತಿಸಿದ್ದಾರೆ';
  }

  @override
  String odometerAtKm({required String km}) {
    return 'ಓಡೋಮೀಟರ್ $km';
  }

  @override
  String decisionNote({required String note}) {
    return 'ನಿರ್ಧಾರದ ಟಿಪ್ಪಣಿ: $note';
  }

  @override
  String get approveCancellation => 'ರದ್ದತಿ ಒಪ್ಪಿಕೊಳ್ಳಿ';

  @override
  String get reject => 'ತಿರಸ್ಕರಿಸಿ';

  @override
  String get approve => 'ಒಪ್ಪಿಕೊಳ್ಳಿ';

  @override
  String get approveIntro =>
      'ಟ್ರಿಪ್ ರದ್ದಾಗುತ್ತದೆ. ಈಗಾಗಲೇ ಓಡಿಸಿದ ದೂರಕ್ಕೆ ಶುಲ್ಕ ಹಾಕಬಹುದು.';

  @override
  String get cancellationFareHint => 'ಶುಲ್ಕ ಇಲ್ಲದಿದ್ದರೆ 0';

  @override
  String get rejectTitle => 'ರದ್ದತಿ ತಿರಸ್ಕರಿಸಿ';

  @override
  String get noteForDriver => 'ಡ್ರೈವರ್‌ಗೆ ಟಿಪ್ಪಣಿ';

  @override
  String get rejectConfirm => 'ತಿರಸ್ಕರಿಸಿ — ಟ್ರಿಪ್ ಮುಂದುವರಿಯುತ್ತದೆ';

  @override
  String get requestPending => 'ಬಾಕಿ ಇದೆ';

  @override
  String get requestApproved => 'ಒಪ್ಪಿಗೆಯಾಗಿದೆ';

  @override
  String get requestRejected => 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ';

  @override
  String get requestWithdrawn => 'ಹಿಂಪಡೆಯಲಾಗಿದೆ';

  @override
  String get odometerEvidence => 'ಓಡೋಮೀಟರ್ ಪುರಾವೆ';

  @override
  String get startLabel => 'ಶುರು';

  @override
  String get endLabel => 'ಕೊನೆ';

  @override
  String get notRecordedYet => 'ಇನ್ನೂ ದಾಖಲಾಗಿಲ್ಲ';

  @override
  String get typed => 'ಟೈಪ್ ಮಾಡಿದ್ದು';

  @override
  String get readFromPhoto => 'ಫೋಟೋದಿಂದ ಓದಿದ್ದು';

  @override
  String get differsSentToReview =>
      'ಹೊಂದುತ್ತಿಲ್ಲ: ಪರಿಶೀಲನೆ ಪಟ್ಟಿಗೆ ಕಳುಹಿಸಲಾಗಿದೆ';

  @override
  String capturedAt({required String when}) {
    return '$when ತೆಗೆದದ್ದು';
  }

  @override
  String get photoNotUploaded =>
      'ಫೋಟೋ ಇನ್ನೂ ಅಪ್‌ಲೋಡ್ ಆಗಿಲ್ಲ (ಫೋನ್ ಇನ್ನೂ ಆಫ್‌ಲೈನ್ ಇರಬಹುದು).';

  @override
  String get routeTitle => 'ಮಾರ್ಗ';

  @override
  String get routeAfterStart => 'ಟ್ರಿಪ್ ಶುರುವಾದ ಮೇಲೆ ಮಾರ್ಗ ಕಾಣಿಸುತ್ತದೆ';

  @override
  String gpsPointsShown({required int count}) {
    return '$count GPS ಪಾಯಿಂಟ್‌ಗಳನ್ನು ತೋರಿಸಲಾಗಿದೆ';
  }

  @override
  String pointsRemoved({
    required String inaccurate,
    required String mock,
    required String impossible,
  }) {
    return '$inaccurate ತಪ್ಪಾದ, $mock ನಕಲಿ ಮತ್ತು $impossible ಅಸಾಧ್ಯ ಪಾಯಿಂಟ್‌ಗಳನ್ನು ತೆಗೆಯಲಾಗಿದೆ';
  }

  @override
  String get verdictOkLabel => 'ಓಡೋಮೀಟರ್ GPS ಜೊತೆ ಹೊಂದುತ್ತದೆ';

  @override
  String get verdictOkText =>
      'ಓಡೋಮೀಟರ್ ದೂರ GPS ಮಾರ್ಗಕ್ಕಿಂತ ಅನುಮತಿಸಿದ ವ್ಯತ್ಯಾಸದೊಳಗೆ ಇದೆ.';

  @override
  String get verdictFlaggedLabel => 'ಓಡೋಮೀಟರ್ GPS ಗಿಂತ ಹೆಚ್ಚು';

  @override
  String get verdictFlaggedText =>
      'ಓಡೋಮೀಟರ್ ದೂರ GPS ಮಾರ್ಗಕ್ಕಿಂತ ತುಂಬಾ ಹೆಚ್ಚಿದೆ. ವಿವರಗಳಿಗೆ ಅಲರ್ಟ್ ನೋಡಿ.';

  @override
  String get verdictInconclusiveLabel => 'ತೀರ್ಮಾನಿಸಲು ಸಾಕಷ್ಟು GPS ಇಲ್ಲ';

  @override
  String get verdictInconclusiveText =>
      'ಫೋನ್ ಟ್ರಿಪ್‌ನ ತುಂಬಾ ಕಡಿಮೆ ಭಾಗವನ್ನು ದಾಖಲಿಸಿದೆ (ಹೆಚ್ಚಾಗಿ ಬ್ಯಾಟರಿ ಉಳಿತಾಯ ಸೆಟ್ಟಿಂಗ್‌ಗಳಿಂದ). ಇಂಥ ಸಂದರ್ಭದಲ್ಲಿ ಅಲರ್ಟ್ ಬರುವುದಿಲ್ಲ.';

  @override
  String checkedAt({required String when}) {
    return '$when ಪರಿಶೀಲಿಸಲಾಗಿದೆ';
  }

  @override
  String get gps => 'GPS';

  @override
  String get odometer => 'ಓಡೋಮೀಟರ್';

  @override
  String get gpsCoverage => 'GPS ಕವರೇಜ್';

  @override
  String get longestGap => 'ಅತಿ ದೊಡ್ಡ ಅಂತರ';

  @override
  String get distanceCheckPending =>
      'ಟ್ರಿಪ್ ಮುಗಿದ ಕೆಲವು ಸೆಕೆಂಡುಗಳ ನಂತರ ದೂರದ ಪರಿಶೀಲನೆ ನಡೆಯುತ್ತದೆ.';

  @override
  String get noCharges => 'ಟೋಲ್, ಪಾರ್ಕಿಂಗ್ ಅಥವಾ ಬೇರೆ ಶುಲ್ಕಗಳಿಲ್ಲ.';

  @override
  String get addChargeTitle => 'ಶುಲ್ಕ ಸೇರಿಸಿ';

  @override
  String get driverPaidCheckbox =>
      'ಡ್ರೈವರ್ ಇದನ್ನು ತನ್ನ ಜೇಬಿನಿಂದ ಕಟ್ಟಿದ್ದಾರೆ (ಸೆಟಲ್‌ಮೆಂಟ್‌ನಲ್ಲಿ ವಾಪಸ್ ಕೊಡಲಾಗುತ್ತದೆ)';

  @override
  String get extraFareInfo =>
      'ಹೆಚ್ಚುವರಿ ಶುಲ್ಕ: ಹೇಳಿದ ದರದ ಮೇಲೆ, ಗ್ರಾಹಕ ಕೊಡುವ ಮೊತ್ತಕ್ಕೆ ಸೇರುತ್ತದೆ.';

  @override
  String get driverPaid => 'ಡ್ರೈವರ್ ಕಟ್ಟಿದ್ದಾರೆ';

  @override
  String get billedOnly => 'ಬಿಲ್‌ನಲ್ಲಿ ಮಾತ್ರ';

  @override
  String byRole({required String text, required String role}) {
    return '$text · $role ಅವರಿಂದ';
  }

  @override
  String get voidAction => 'ರದ್ದುಗೊಳಿಸಿ';

  @override
  String get paymentsCollected => 'ಸಂಗ್ರಹಿಸಿದ ಪಾವತಿಗಳು';

  @override
  String get recordPayment => 'ಪಾವತಿ ದಾಖಲಿಸಿ';

  @override
  String get nothingRecorded => 'ಇನ್ನೂ ಏನೂ ದಾಖಲಾಗಿಲ್ಲ.';

  @override
  String get method => 'ವಿಧಾನ';

  @override
  String get methodCashOption => 'ನಗದು (ಡ್ರೈವರ್ ಸೆಟಲ್‌ಮೆಂಟ್‌ನಲ್ಲಿ ಕೊಡುತ್ತಾರೆ)';

  @override
  String get methodUpiOption => 'UPI (ನೇರವಾಗಿ ನಿಮಗೆ ಬರುತ್ತದೆ)';

  @override
  String get methodCardOption => 'ಕಾರ್ಡ್ (ನೇರವಾಗಿ ನಿಮಗೆ ಬರುತ್ತದೆ)';

  @override
  String get referenceOptional => 'ರೆಫರೆನ್ಸ್ (ಐಚ್ಛಿಕ)';

  @override
  String get referenceHint => 'UPI ರೆಫರೆನ್ಸ್ ಅಥವಾ ಕಾರ್ಡ್ ಸ್ಲಿಪ್ ನಂಬರ್';

  @override
  String get record => 'ದಾಖಲಿಸಿ';

  @override
  String get timeline => 'ಟೈಮ್‌ಲೈನ್';

  @override
  String get noEvents => 'ಯಾವ ಘಟನೆಗಳೂ ಇಲ್ಲ';

  @override
  String eventBy({required String event, required String role}) {
    return '$role ಅವರಿಂದ $event';
  }

  @override
  String eventBySystem({required String event}) {
    return '$event (ಸಿಸ್ಟಮ್)';
  }

  @override
  String onDevice({required String when}) {
    return 'ಸಾಧನದಲ್ಲಿ $when';
  }

  @override
  String syncedLater({required String when, required int count}) {
    return 'ಸರ್ವರ್‌ಗೆ $when ತಲುಪಿತು ($count ನಿಮಿಷ ತಡವಾಗಿ)';
  }

  @override
  String get eventCreated => 'ರಚಿಸಲಾಗಿದೆ';

  @override
  String get eventAssigned => 'ನಿಯೋಜಿಸಲಾಗಿದೆ';

  @override
  String get eventReassigned => 'ಮರು ನಿಯೋಜಿಸಲಾಗಿದೆ';

  @override
  String get eventUnassigned => 'ನಿಯೋಜನೆ ತೆಗೆಯಲಾಗಿದೆ';

  @override
  String get eventStarted => 'ಶುರುವಾಗಿದೆ';

  @override
  String get eventEnded => 'ಮುಗಿದಿದೆ';

  @override
  String get eventCancellationRequested => 'ರದ್ದತಿ ವಿನಂತಿಸಲಾಗಿದೆ';

  @override
  String get eventCancellationApproved => 'ರದ್ದತಿ ಒಪ್ಪಿಗೆಯಾಗಿದೆ';

  @override
  String get eventCancellationRejected => 'ರದ್ದತಿ ತಿರಸ್ಕರಿಸಲಾಗಿದೆ';

  @override
  String get eventCancellationWithdrawn => 'ರದ್ದತಿ ಹಿಂಪಡೆಯಲಾಗಿದೆ';

  @override
  String get eventCancelled => 'ರದ್ದಾಗಿದೆ';

  @override
  String get eventSettled => 'ಸೆಟಲ್ ಆಗಿದೆ';

  @override
  String get addVehicle => 'ವಾಹನ ಸೇರಿಸಿ';

  @override
  String get editVehicle => 'ವಾಹನ ಬದಲಿಸಿ';

  @override
  String get registrationNumber => 'ನೋಂದಣಿ ಸಂಖ್ಯೆ';

  @override
  String get registrationInvalid => 'MH 12 AB 1234 ತರಹದ ನೋಂದಣಿ ಸಂಖ್ಯೆ ಬಳಸಿ';

  @override
  String get brand => 'ಬ್ರ್ಯಾಂಡ್';

  @override
  String get search => 'ಹುಡುಕಿ';

  @override
  String get othersGroup => 'ಇತರೆ';

  @override
  String get otherModel => 'ಬೇರೆ / ಪಟ್ಟಿಯಲ್ಲಿಲ್ಲ';

  @override
  String get catalogUnavailable => 'ಪಟ್ಟಿ ಲೋಡ್ ಆಗಲಿಲ್ಲ; ಬದಲಿಗೆ ಟೈಪ್ ಮಾಡಿ';

  @override
  String get make => 'ಕಂಪನಿ';

  @override
  String get model => 'ಮಾಡೆಲ್';

  @override
  String get fuelType => 'ಇಂಧನದ ಪ್ರಕಾರ';

  @override
  String get year => 'ವರ್ಷ';

  @override
  String get currentOdometer => 'ಈಗಿನ ಓಡೋಮೀಟರ್';

  @override
  String get inactiveVehicleOption => 'ನಿಷ್ಕ್ರಿಯ (ನಿಯೋಜನೆಯಲ್ಲಿ ಕಾಣುವುದಿಲ್ಲ)';

  @override
  String get deactivate => 'ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get activate => 'ಸಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String get noVehiclesYet =>
      'ಇನ್ನೂ ವಾಹನಗಳಿಲ್ಲ. ಟ್ರಿಪ್ ನಿಯೋಜಿಸಲು ನಿಮ್ಮ ಮೊದಲ ಕಾರು ಸೇರಿಸಿ.';

  @override
  String get lastOdometer => 'ಕೊನೆಯ ಓಡೋಮೀಟರ್';

  @override
  String get recentTrips => 'ಇತ್ತೀಚಿನ ಟ್ರಿಪ್‌ಗಳು';

  @override
  String get noTripsShort => 'ಇನ್ನೂ ಟ್ರಿಪ್‌ಗಳಿಲ್ಲ';

  @override
  String get fuelAudit => 'ಇಂಧನ ಆಡಿಟ್';

  @override
  String get inviteDriver => 'ಡ್ರೈವರ್ ಆಹ್ವಾನಿಸಿ';

  @override
  String get inviteDriverIntro =>
      'ಡ್ರೈವರ್ ಈ ನಂಬರ್‌ನಿಂದ ಫ್ಲೀಟ್ ಸಾರಥಿ ಆ್ಯಪ್‌ಗೆ ಸೈನ್ ಇನ್ ಮಾಡುತ್ತಾರೆ; ಪಾಸ್‌ವರ್ಡ್ ಬೇಕಿಲ್ಲ.';

  @override
  String get enterIndianMobile => '10 ಅಂಕಿಯ ಭಾರತೀಯ ಮೊಬೈಲ್ ನಂಬರ್ ಹಾಕಿ';

  @override
  String get sendInvite => 'ಆಹ್ವಾನ ಕಳುಹಿಸಿ';

  @override
  String get noDriversYet =>
      'ಇನ್ನೂ ಡ್ರೈವರ್‌ಗಳಿಲ್ಲ. ಫೋನ್ ನಂಬರ್ ಮೂಲಕ ಡ್ರೈವರ್‌ಗಳನ್ನು ಆಹ್ವಾನಿಸಿ; ಅವರು ಅದೇ ನಂಬರ್ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್‌ನಿಂದ ಸೈನ್ ಅಪ್ ಮಾಡುತ್ತಾರೆ.';

  @override
  String payDefault({required String rule}) {
    return 'ಡೀಫಾಲ್ಟ್ · $rule';
  }

  @override
  String get notSignedInYet => 'ಇನ್ನೂ ಸೈನ್ ಇನ್ ಮಾಡಿಲ್ಲ';

  @override
  String get inactiveDriverOption => 'ನಿಷ್ಕ್ರಿಯ (ನಿಯೋಜಿಸಲು ಆಗುವುದಿಲ್ಲ)';

  @override
  String get pay => 'ಸಂಬಳ';

  @override
  String get onlyOwnerPay => 'ಮಾಲೀಕರು ಮಾತ್ರ ಸಂಬಳ ಬದಲಿಸಬಹುದು.';

  @override
  String get payDifferently =>
      'ಈ ಡ್ರೈವರ್‌ಗೆ ಡೀಫಾಲ್ಟ್‌ಗಿಂತ ಬೇರೆ ರೀತಿಯಲ್ಲಿ ಸಂಬಳ ಕೊಡಿ';

  @override
  String get checkPayRule => 'ಸಂಬಳದ ನಿಯಮದ ಮೌಲ್ಯಗಳನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get payRuleHow => 'ಡ್ರೈವರ್‌ಗೆ ಹೇಗೆ ಸಂಬಳ ಕೊಡಲಾಗುತ್ತದೆ';

  @override
  String get payNone => 'ಇಲ್ಲ (ಮಾಸಿಕ ಸಂಬಳ, ಫ್ಲೀಟ್ ಸಾರಥಿ ಹೊರಗೆ ಕೊಡಲಾಗುತ್ತದೆ)';

  @override
  String get payPercent => 'ಶುಲ್ಕದ ಶೇಕಡಾ';

  @override
  String get payPerTrip => 'ಪ್ರತಿ ಟ್ರಿಪ್‌ಗೆ ನಿಗದಿತ ಮೊತ್ತ';

  @override
  String get payPerKm => 'ಓಡಿಸಿದ ಪ್ರತಿ km ಗೆ';

  @override
  String get payFixedDaily => 'ಪ್ರತಿ ಕೆಲಸದ ದಿನಕ್ಕೆ ನಿಗದಿತ ಮೊತ್ತ';

  @override
  String get percent => 'ಶೇಕಡಾ';

  @override
  String get ofBase => 'ಯಾವುದರ';

  @override
  String get baseQuoted => 'ಹೇಳಿದ ದರ';

  @override
  String get baseExpected => 'ಶುಲ್ಕಗಳು ಸೇರಿದ ದರ';

  @override
  String get amountPerTrip => 'ಪ್ರತಿ ಟ್ರಿಪ್‌ಗೆ ಮೊತ್ತ';

  @override
  String get ratePerKm => 'ಪ್ರತಿ km ದರ';

  @override
  String get amountPerDay => 'ಪ್ರತಿ ಕೆಲಸದ ದಿನಕ್ಕೆ ಮೊತ್ತ';

  @override
  String get allowanceToDriver => 'ಡ್ರೈವರ್ ಭತ್ಯೆ ಡ್ರೈವರ್‌ಗೆ ಹೋಗುತ್ತದೆ';

  @override
  String get allowanceHint => 'ಗ್ರಾಹಕ ಕೊಡುವ ಬಾಟಾ ಡ್ರೈವರ್‌ನ ಗಳಿಕೆಗೆ ಸೇರುತ್ತದೆ.';

  @override
  String get ruleNoPay => 'ಸೆಟಲ್‌ಮೆಂಟ್‌ನಲ್ಲಿ ಸಂಬಳ ಇಲ್ಲ';

  @override
  String rulePercentQuoted({required String percent}) {
    return 'ಹೇಳಿದ ದರದ $percent%';
  }

  @override
  String rulePercentExpected({required String percent}) {
    return 'ಶುಲ್ಕಗಳು ಸೇರಿದ ದರದ $percent%';
  }

  @override
  String rulePerTrip({required String amount}) {
    return 'ಪ್ರತಿ ಟ್ರಿಪ್‌ಗೆ $amount';
  }

  @override
  String rulePerKm({required String amount}) {
    return 'ಪ್ರತಿ km ಗೆ $amount';
  }

  @override
  String ruleFixedDaily({required String amount}) {
    return 'ಪ್ರತಿ ಕೆಲಸದ ದಿನಕ್ಕೆ $amount';
  }

  @override
  String rulePlusAllowance({required String rule}) {
    return '$rule + ಡ್ರೈವರ್ ಭತ್ಯೆ';
  }

  @override
  String get inviteManager => 'ಮ್ಯಾನೇಜರ್ ಆಹ್ವಾನಿಸಿ';

  @override
  String get inviteManagerIntro =>
      'ಮ್ಯಾನೇಜರ್‌ಗಳು ಟ್ರಿಪ್, ಅಲರ್ಟ್ ಮತ್ತು ಸೆಟಲ್‌ಮೆಂಟ್ ನೋಡಿಕೊಳ್ಳುತ್ತಾರೆ, ಆದರೆ ಸೆಟ್ಟಿಂಗ್ಸ್ ಅಥವಾ ಸಂಬಳ ಬದಲಿಸಲು ಆಗುವುದಿಲ್ಲ.';

  @override
  String get removeManager => 'ಮ್ಯಾನೇಜರ್ ಪ್ರವೇಶ ತೆಗೆಯಿರಿ';

  @override
  String removeManagerConfirm({required String name}) {
    return '$name ಅವರ ಮ್ಯಾನೇಜರ್ ಪ್ರವೇಶ ತೆಗೆಯಬೇಕೇ? ಅವರ ಬೇರೆ ಪಾತ್ರಗಳು ಹಾಗೇ ಇರುತ್ತವೆ.';
  }

  @override
  String get remove => 'ತೆಗೆಯಿರಿ';

  @override
  String get memberInvited => 'ಆಹ್ವಾನಿಸಲಾಗಿದೆ';

  @override
  String get memberActive => 'ಸಕ್ರಿಯ';

  @override
  String get memberSuspended => 'ಅಮಾನತು';

  @override
  String get membersIntro => 'ಈ ಫ್ಲೀಟ್‌ಗೆ ಪ್ರವೇಶ ಇರುವವರು.';

  @override
  String get addDocument => 'ದಾಖಲೆ ಸೇರಿಸಿ';

  @override
  String get renew => 'ನವೀಕರಿಸಿ';

  @override
  String renewTitle({required String doc}) {
    return '$doc ನವೀಕರಿಸಿ';
  }

  @override
  String get renewIntro =>
      'ನವೀಕರಿಸಿದ ಪ್ರತಿ ಈಗಿನದರ ಜಾಗಕ್ಕೆ ಬರುತ್ತದೆ (ಹಳೆಯದು ಇತಿಹಾಸದಲ್ಲಿ ಇರುತ್ತದೆ), ಮತ್ತು ಅದರ ಅವಧಿ ಮುಗಿಯುವ ಅಲರ್ಟ್‌ಗಳನ್ನು ತೆರವುಗೊಳಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get documentType => 'ದಾಖಲೆ';

  @override
  String get documentFor => 'ಯಾರಿಗೆ';

  @override
  String get documentNumber => 'ಸಂಖ್ಯೆ';

  @override
  String get validFrom => 'ಮಾನ್ಯತೆ ಶುರು ದಿನ';

  @override
  String get expiresOn => 'ಅವಧಿ ಮುಗಿಯುವ ದಿನ';

  @override
  String get expiresOnHint =>
      'ಅವಧಿ ಮುಗಿಯುವ ಮೊದಲು ಮತ್ತು ಮುಗಿದ ದಿನ ಅಲರ್ಟ್ ಬರುತ್ತದೆ.';

  @override
  String get saveRenewal => 'ನವೀಕರಣ ಉಳಿಸಿ';

  @override
  String get noDocuments => 'ಇನ್ನೂ ದಾಖಲೆಗಳಿಲ್ಲ.';

  @override
  String get docRc => 'ನೋಂದಣಿ (RC)';

  @override
  String get docInsurance => 'ವಿಮೆ';

  @override
  String get docPermit => 'ಪರ್ಮಿಟ್';

  @override
  String get docPuc => 'ಮಾಲಿನ್ಯ (PUC)';

  @override
  String get docLicence => 'ಡ್ರೈವಿಂಗ್ ಲೈಸೆನ್ಸ್';

  @override
  String get docValid => 'ಮಾನ್ಯ';

  @override
  String docExpiresIn({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ದಿನಗಳಲ್ಲಿ ಅವಧಿ ಮುಗಿಯುತ್ತದೆ',
      one: 'ನಾಳೆ ಅವಧಿ ಮುಗಿಯುತ್ತದೆ',
      zero: 'ಇಂದು ಅವಧಿ ಮುಗಿಯುತ್ತದೆ',
    );
    return '$_temp0';
  }

  @override
  String get docExpired => 'ಅವಧಿ ಮುಗಿದಿದೆ';

  @override
  String get docSuperseded => 'ನವೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get filterAllDocs => 'ಎಲ್ಲಾ ಈಗಿನ ದಾಖಲೆಗಳು';

  @override
  String get filterDue30 => '30 ದಿನಗಳಲ್ಲಿ ಮುಗಿಯುವ ಅಥವಾ ಮುಗಿದಿರುವ';

  @override
  String get filterDue7 => '7 ದಿನಗಳಲ್ಲಿ ಮುಗಿಯುವ ಅಥವಾ ಮುಗಿದಿರುವ';

  @override
  String get filterDue0 => 'ಮುಗಿದಿರುವ ಅಥವಾ ಇಂದು ಮುಗಿಯುವ';

  @override
  String get viewPhoto => 'ಫೋಟೋ ನೋಡಿ';

  @override
  String get documentPhotoOptional => 'ಫೋಟೋ (ಐಚ್ಛಿಕ)';

  @override
  String get pickVehicleOrDriver => 'ಯಾರಿಗೆ ಎಂದು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get fuelIntro =>
      'ಪ್ರತಿ ವಾಹನವನ್ನು ಅದರದೇ ಹಿಂದಿನ ದಾಖಲೆಯ ಜೊತೆ, ಸೈಕಲ್‌ನಿಂದ ಸೈಕಲ್‌ಗೆ (ಫುಲ್ ಟ್ಯಾಂಕ್‌ನಿಂದ ಫುಲ್ ಟ್ಯಾಂಕ್‌ಗೆ) ಹೋಲಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get efficiencyByCycle => 'ಪ್ರತಿ ಸೈಕಲ್‌ನ ಮೈಲೇಜ್';

  @override
  String get costByCycle => 'ಪ್ರತಿ ಸೈಕಲ್‌ನ ಓಡಾಟದ ಖರ್ಚು';

  @override
  String get noCycles =>
      'ಇನ್ನೂ ಫುಲ್ ಟ್ಯಾಂಕ್ ಸೈಕಲ್‌ಗಳಿಲ್ಲ. ಮೈಲೇಜ್ ಅನ್ನು ಎರಡು ಫುಲ್ ಟ್ಯಾಂಕ್ ತುಂಬಿಸುವಿಕೆಗಳ ನಡುವೆ ಅಳೆಯಲಾಗುತ್ತದೆ.';

  @override
  String get usual => 'ಸಾಮಾನ್ಯ';

  @override
  String usualValue({required String value}) {
    return 'ಸಾಮಾನ್ಯ $value';
  }

  @override
  String get cyclesInBaseline => 'ಆಧಾರದಲ್ಲಿರುವ ಸೈಕಲ್‌ಗಳು';

  @override
  String get verdictOk => 'OK';

  @override
  String get verdictFlagged => 'ಗುರುತಿಸಲಾಗಿದೆ';

  @override
  String get verdictInvalid => 'ಅಮಾನ್ಯ';

  @override
  String get fuelFills => 'ಇಂಧನ ತುಂಬಿಸಿದ್ದು';

  @override
  String get noFills => 'ಯಾವ ತುಂಬಿಸುವಿಕೆಯೂ ದಾಖಲಾಗಿಲ್ಲ';

  @override
  String get fullTankShort => 'ಫುಲ್';

  @override
  String get partialTank => 'ಭಾಗಶಃ';

  @override
  String get voidFill => 'ತುಂಬಿಸಿದ್ದು ರದ್ದುಗೊಳಿಸಿ';

  @override
  String get voidFillTitle => 'ಈ ತುಂಬಿಸುವಿಕೆ ರದ್ದುಗೊಳಿಸಿ';

  @override
  String voidFillIntro({
    required String quantity,
    required String amount,
    required String when,
  }) {
    return '$when ರಂದು $amount ಕ್ಕೆ $quantity. ಇದನ್ನು ಬಿಟ್ಟು ವಾಹನದ ಇಂಧನ ಆಡಿಟ್ ಮತ್ತೆ ಲೆಕ್ಕ ಹಾಕಲಾಗುತ್ತದೆ.';
  }

  @override
  String get voidReasonHint => 'ಉದಾ. 40 L ಬದಲು 60 L ಟೈಪ್ ಮಾಡಲಾಗಿದೆ';

  @override
  String get keepIt => 'ಹಾಗೇ ಇರಲಿ';

  @override
  String receiptAmount({required String amount}) {
    return 'ರಸೀದಿ: $amount';
  }

  @override
  String sigmaRule({required String value}) {
    return '$valueσ';
  }

  @override
  String percentRule({required String value}) {
    return '$value% (ಹೊಸ ವಾಹನ)';
  }

  @override
  String cycleRange({required String from, required String to}) {
    return '$from → $to';
  }

  @override
  String get noCyclesShort => 'ಸೈಕಲ್‌ಗಳಿಲ್ಲ';

  @override
  String get chartThisCycle => 'ಪ್ರತಿ ಸೈಕಲ್';

  @override
  String perKmValue({required String amount}) {
    return '$amount/km';
  }

  @override
  String get allKinds => 'ಎಲ್ಲಾ ಬಗೆಯ';

  @override
  String get alertOpen => 'ತೆರೆದಿದೆ';

  @override
  String get alertAcknowledged => 'ಗಮನಿಸಲಾಗಿದೆ';

  @override
  String get alertResolved => 'ಪರಿಹಾರವಾಗಿದೆ';

  @override
  String get alertDismissed => 'ತಳ್ಳಿಹಾಕಲಾಗಿದೆ';

  @override
  String get acknowledge => 'ಗಮನಿಸಿದೆ';

  @override
  String get dismiss => 'ತಳ್ಳಿಹಾಕಿ';

  @override
  String get dismissFalseAlarm => 'ಸುಳ್ಳು ಅಲರ್ಟ್ ಎಂದು ತಳ್ಳಿಹಾಕಿ';

  @override
  String get markResolved => 'ಪರಿಹಾರವಾಗಿದೆ ಎಂದು ಗುರುತಿಸಿ';

  @override
  String get falseAlarm => 'ಸುಳ್ಳು ಅಲರ್ಟ್';

  @override
  String get allClear => 'ಎಲ್ಲಾ ಸರಿ: ಯಾವ ತೆರೆದ ಅಲರ್ಟ್‌ಗಳೂ ಇಲ್ಲ';

  @override
  String get noAlertsMatch => 'ಹೊಂದುವ ಅಲರ್ಟ್‌ಗಳಿಲ್ಲ';

  @override
  String get openTrip => 'ಟ್ರಿಪ್ ತೆರೆಯಿರಿ';

  @override
  String get openFuelHistory => 'ಇಂಧನ ಇತಿಹಾಸ ತೆರೆಯಿರಿ';

  @override
  String get openVehicle => 'ವಾಹನ ತೆರೆಯಿರಿ';

  @override
  String get openDocuments => 'ದಾಖಲೆಗಳನ್ನು ತೆರೆಯಿರಿ';

  @override
  String get alertsIntro =>
      'ಇಂಧನ ಅಲರ್ಟ್ ಅನ್ನು ಸುಳ್ಳು ಅಲರ್ಟ್ ಎಂದು ತಳ್ಳಿಹಾಕಿದರೆ, ಆ ಸೈಕಲ್ ವಾಹನದ ಸಾಮಾನ್ಯ ಮಿತಿಗೆ ಸೇರುತ್ತದೆ.';

  @override
  String get kindFuelEfficiencyLow => 'ಇಂಧನ ಬಳಕೆ ಸಾಮಾನ್ಯಕ್ಕಿಂತ ಹೆಚ್ಚು';

  @override
  String get kindFuelCostHigh => 'ಓಡಾಟದ ಖರ್ಚು ಸಾಮಾನ್ಯಕ್ಕಿಂತ ಹೆಚ್ಚು';

  @override
  String get kindOdoGps => 'ಓಡೋಮೀಟರ್ GPS ಗಿಂತ ಹೆಚ್ಚು';

  @override
  String get kindDocExpiring => 'ದಾಖಲೆಯ ಅವಧಿ ಮುಗಿಯುತ್ತಿದೆ';

  @override
  String get kindDocExpired => 'ದಾಖಲೆಯ ಅವಧಿ ಮುಗಿದಿದೆ';

  @override
  String get kindCancellationRequested => 'ರದ್ದತಿ ವಿನಂತಿಸಲಾಗಿದೆ';

  @override
  String get kindGpsCoverageLow => 'ಕಳಪೆ GPS ಕವರೇಜ್';

  @override
  String alertVehicle({
    required String registrationNo,
    required String model,
    required String fuel,
  }) {
    return '$registrationNo ($model, $fuel)';
  }

  @override
  String get alertFuelPetrol => 'ಪೆಟ್ರೋಲ್';

  @override
  String get alertFuelDiesel => 'ಡೀಸೆಲ್';

  @override
  String get alertFuelCng => 'CNG';

  @override
  String get alertFuelPetrolCng => 'ಪೆಟ್ರೋಲ್ + CNG';

  @override
  String alertFuelEfficiencyTitle({required String vehicle}) {
    return '$vehicle ಸಾಮಾನ್ಯಕ್ಕಿಂತ ಹೆಚ್ಚು ಇಂಧನ ಬಳಸಿದೆ';
  }

  @override
  String alertFuelEfficiencyBody({
    required String from,
    required String to,
    required String km,
    required String used,
    required String unit,
    required String fuel,
    required String value,
    required String baseline,
    required String worse,
    required String extra,
    required String extraCost,
  }) {
    return '$from ರಿಂದ $to ವರೆಗೆ ಇದು $used $unit $fuel ನಲ್ಲಿ $km km ಓಡಿದೆ, ಅಂದರೆ $value km/$unit. ಈ ಕಾರು ಸಾಮಾನ್ಯವಾಗಿ ಸುಮಾರು $baseline km/$unit ಕೊಡುತ್ತದೆ, ಹಾಗಾಗಿ ಇದು ಸಾಮಾನ್ಯಕ್ಕಿಂತ $worse% ಕಡಿಮೆ. ಅಂದರೆ ನಿರೀಕ್ಷೆಗಿಂತ ಸುಮಾರು $extra $unit (ಸುಮಾರು $extraCost) ಹೆಚ್ಚು $fuel.';
  }

  @override
  String alertFuelCostTitle({required String vehicle}) {
    return '$vehicle ಓಡಿಸುವ ಖರ್ಚು ಸಾಮಾನ್ಯಕ್ಕಿಂತ ಹೆಚ್ಚಾಗಿದೆ';
  }

  @override
  String alertFuelCostBody({
    required String from,
    required String to,
    required String km,
    required String cost,
    required String perKm,
    required String usualPerKm,
    required String worse,
  }) {
    return '$from ರಿಂದ $to ವರೆಗೆ ಇದು $cost ಇಂಧನದಲ್ಲಿ $km km ಓಡಿದೆ, ಅಂದರೆ $perKm/km. ಈ ಕಾರಿಗೆ ಸಾಮಾನ್ಯವಾಗಿ ಸುಮಾರು $usualPerKm/km ಖರ್ಚಾಗುತ್ತದೆ, ಹಾಗಾಗಿ ಇದು ಸಾಮಾನ್ಯಕ್ಕಿಂತ $worse% ಹೆಚ್ಚು.';
  }

  @override
  String alertPetrolShare({required String amount}) {
    return 'ಅದರಲ್ಲಿ $amount ಪೆಟ್ರೋಲ್.';
  }

  @override
  String alertFillsLoggedBy({required String names}) {
    return 'ಈ ಅವಧಿಯಲ್ಲಿ ಇಂಧನ ತುಂಬಿಸಿದ್ದನ್ನು $names ದಾಖಲಿಸಿದ್ದಾರೆ.';
  }

  @override
  String get alertCheckReceiptsOdometer =>
      'ರಸೀದಿಗಳು ಮತ್ತು ಓಡೋಮೀಟರ್ ಫೋಟೋಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get alertCheckPetrolReceipts =>
      'ಕಾರನ್ನು ಅನಗತ್ಯವಾಗಿ ಪೆಟ್ರೋಲ್‌ನಲ್ಲಿ ಓಡಿಸಲಾಗಿದೆಯೇ ಎಂದು ನೋಡಿ, ಮತ್ತು ರಸೀದಿಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String alertOdoGpsTitle({
    required String date,
    required String route,
    required String vehicle,
  }) {
    return '$date ರ ಟ್ರಿಪ್ ($route, $vehicle) ನಲ್ಲಿ GPS ಮಾರ್ಗಕ್ಕಿಂತ ಓಡೋಮೀಟರ್‌ನಲ್ಲಿ ಹೆಚ್ಚು km ಇದೆ';
  }

  @override
  String get alertOdoGpsVehicleUnknown => 'ವಾಹನ';

  @override
  String alertOdoGpsBody({
    required String odometer,
    required String gps,
    required String excess,
    required String tolerance,
  }) {
    return 'ಓಡೋಮೀಟರ್ ರೀಡಿಂಗ್ $odometer km ಎನ್ನುತ್ತದೆ, ಆದರೆ ಫೋನ್‌ನ GPS $gps km ದಾಖಲಿಸಿದೆ. ಓಡೋಮೀಟರ್ ದೂರ $excess% ಹೆಚ್ಚು; ಅನುಮತಿಸಿದ ವ್ಯತ್ಯಾಸ $tolerance%. ಶುರು ಮತ್ತು ಕೊನೆಯ ಓಡೋಮೀಟರ್ ಫೋಟೋಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';
  }

  @override
  String alertDocExpiredTitle({required String doc, required String subject}) {
    return '$subject ಅವರ $doc ಅವಧಿ ಮುಗಿದಿದೆ';
  }

  @override
  String alertDocExpiredBody({
    required String doc,
    required String subject,
    required String date,
  }) {
    return '$subject ಅವರ $doc ಅವಧಿ $date ರಂದು ಮುಗಿದಿದೆ. ಇದು ಇಲ್ಲದೆ ಓಡಿಸಿದರೆ ದಂಡ ಮತ್ತು ವಿಮಾ ಕ್ಲೇಮ್ ತಿರಸ್ಕಾರದ ಅಪಾಯ ಇದೆ. ಇದನ್ನು ನವೀಕರಿಸಿ ಹೊಸ ಪ್ರತಿ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ.';
  }

  @override
  String alertDocExpiringTitle({
    required int count,
    required String doc,
    required String subject,
  }) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$subject ಅವರ $doc ಅವಧಿ $count ದಿನಗಳಲ್ಲಿ ಮುಗಿಯುತ್ತದೆ',
      one: '$subject ಅವರ $doc ಅವಧಿ ನಾಳೆ ಮುಗಿಯುತ್ತದೆ',
      zero: '$subject ಅವರ $doc ಅವಧಿ ಇಂದು ಮುಗಿಯುತ್ತದೆ',
    );
    return '$_temp0';
  }

  @override
  String alertDocExpiringBody({
    required String doc,
    required String subject,
    required String date,
  }) {
    return '$subject ಅವರ $doc ಅವಧಿ $date ರಂದು ಮುಗಿಯುತ್ತದೆ. ಅದಕ್ಕೂ ಮೊದಲು ನವೀಕರಿಸಿ ಹೊಸ ಪ್ರತಿ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ.';
  }

  @override
  String alertCancellationTitle({required String from}) {
    return '$from ನಿಂದ ಹೊರಡುವ ಟ್ರಿಪ್‌ಗೆ ರದ್ದತಿ ವಿನಂತಿ';
  }

  @override
  String alertCancellationBody({
    required String driver,
    required String reason,
    required String km,
  }) {
    return '$driver ಈ ನಡೆಯುತ್ತಿರುವ ಟ್ರಿಪ್ ರದ್ದು ಮಾಡಲು ಕೇಳಿದ್ದಾರೆ: \"$reason\". ಓಡೋಮೀಟರ್ $km km ತೋರಿಸಿತ್ತು. ಟ್ರಿಪ್ ಪುಟದಲ್ಲಿ ಒಪ್ಪಿಕೊಳ್ಳಿ (ಬೇಕಿದ್ದರೆ ರದ್ದತಿ ಶುಲ್ಕದೊಂದಿಗೆ) ಅಥವಾ ತಿರಸ್ಕರಿಸಿ.';
  }

  @override
  String get alertTheDriver => 'ಡ್ರೈವರ್';

  @override
  String get reviewIntro =>
      'ಫ್ಲೀಟ್ ಸಾರಥಿಗೆ ಖಚಿತವಿಲ್ಲದ ವಿಷಯಗಳು. ಇವು ಯಾವುದೂ ಡ್ರೈವರ್‌ನನ್ನು ತಡೆದಿಲ್ಲ; ನಿಮ್ಮ ನಿರ್ಧಾರ ದಾಖಲೆಯನ್ನು ಸರಿಪಡಿಸುತ್ತದೆ.';

  @override
  String get nothingToReview => 'ಪರಿಶೀಲಿಸಲು ಏನೂ ಇಲ್ಲ';

  @override
  String get noItems => 'ಏನೂ ಇಲ್ಲ';

  @override
  String get reviewOcrOdometer =>
      'ಓಡೋಮೀಟರ್ ಫೋಟೋ ಟೈಪ್ ಮಾಡಿದ ರೀಡಿಂಗ್‌ಗೆ ಹೊಂದುತ್ತಿಲ್ಲ';

  @override
  String get reviewOcrReceipt => 'ರಸೀದಿ ಟೈಪ್ ಮಾಡಿದ ಮೊತ್ತಕ್ಕೆ ಹೊಂದುತ್ತಿಲ್ಲ';

  @override
  String get reviewOdometerRegression => 'ಓಡೋಮೀಟರ್ ಹಿಂದಕ್ಕೆ ಹೋಗಿದೆ';

  @override
  String get reviewImplausibleEfficiency => 'ಇಂಧನದ ಅಂಕಿಗಳು ನಂಬಲಾಗದಂತಿವೆ';

  @override
  String get reviewMockLocation => 'ನಕಲಿ GPS ಲೊಕೇಶನ್ ಪತ್ತೆಯಾಗಿದೆ';

  @override
  String get reviewOrphanEvidence => 'ರದ್ದಾದ ಟ್ರಿಪ್‌ನ ಫೋಟೋ';

  @override
  String get reviewClockSkew => 'ಫೋನ್ ಗಡಿಯಾರ ತಪ್ಪಾಗಿತ್ತು';

  @override
  String get reviewUploadMismatch => 'ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ ಫೈಲ್ ಹೊಂದಲಿಲ್ಲ';

  @override
  String get reviewKeptTyped => 'ಟೈಪ್ ಮಾಡಿದ ಮೌಲ್ಯ ಇಡಲಾಗಿದೆ';

  @override
  String get reviewUsedPhoto => 'ಫೋಟೋದ ಮೌಲ್ಯ ಬಳಸಲಾಗಿದೆ';

  @override
  String get reviewCorrected => 'ಸರಿಪಡಿಸಲಾಗಿದೆ';

  @override
  String get typedByDriver => 'ಡ್ರೈವರ್ ಟೈಪ್ ಮಾಡಿದ್ದು';

  @override
  String get readFromThePhoto => 'ಫೋಟೋದಿಂದ ಓದಿದ್ದು';

  @override
  String get keepTyped => 'ಟೈಪ್ ಮಾಡಿದ ಮೌಲ್ಯ ಇಡಿ';

  @override
  String get usePhotoValue => 'ಫೋಟೋದ ಮೌಲ್ಯ ಬಳಸಿ';

  @override
  String get enterCorrectValue => 'ಸರಿಯಾದ ಮೌಲ್ಯ ಹಾಕಿ';

  @override
  String get markReviewed => 'ಪರಿಶೀಲಿಸಲಾಗಿದೆ ಎಂದು ಗುರುತಿಸಿ';

  @override
  String get correctValueTitle => 'ಸರಿಯಾದ ಮೌಲ್ಯ ಹಾಕಿ';

  @override
  String get odometerKmLabel => 'ಓಡೋಮೀಟರ್ (km)';

  @override
  String get correctionHint =>
      'ಈ ಮೌಲ್ಯದಿಂದ ಇಂಧನ ಮತ್ತು ದೂರದ ಪರಿಶೀಲನೆಗಳನ್ನು ಮತ್ತೆ ಲೆಕ್ಕ ಹಾಕಲಾಗುತ್ತದೆ.';

  @override
  String get saveCorrection => 'ತಿದ್ದುಪಡಿ ಉಳಿಸಿ';

  @override
  String get reasonOdometerNotIncreasing =>
      'ಕೊನೆಯ ತುಂಬಿಸುವಿಕೆಯ ಓಡೋಮೀಟರ್ ರೀಡಿಂಗ್ ಮೊದಲ ತುಂಬಿಸುವಿಕೆಗಿಂತ ಹೆಚ್ಚಿಲ್ಲ.';

  @override
  String get reasonDistanceTooLong =>
      'ಎರಡು ಫುಲ್ ಟ್ಯಾಂಕ್ ತುಂಬಿಸುವಿಕೆಗಳ ನಡುವೆ 3,000 km ಗಿಂತ ಹೆಚ್ಚು ಓಡಿದೆ, ಹಾಗಾಗಿ ಕೆಲವು ತುಂಬಿಸುವಿಕೆಗಳು ದಾಖಲಾಗಿಲ್ಲದಿರಬಹುದು.';

  @override
  String get reasonImplausiblyGood =>
      'ಮೈಲೇಜ್ ಈ ಕಾರು ಸಾಮಾನ್ಯವಾಗಿ ಕೊಡುವುದಕ್ಕಿಂತ ತುಂಬಾ ಚೆನ್ನಾಗಿದೆ, ಅಂದರೆ ಸಾಮಾನ್ಯವಾಗಿ ಒಂದು ತುಂಬಿಸುವಿಕೆ ದಾಖಲಾಗಿಲ್ಲ.';

  @override
  String get reasonNoFuel =>
      'ಎರಡು ಫುಲ್ ಟ್ಯಾಂಕ್ ತುಂಬಿಸುವಿಕೆಗಳ ನಡುವೆ ಯಾವ ಇಂಧನವೂ ದಾಖಲಾಗಿಲ್ಲ.';

  @override
  String get settlementsIntro =>
      'ದಿನಕ್ಕೆ (IST) ಪ್ರತಿ ಡ್ರೈವರ್‌ಗೆ ಒಂದು ಸಾಲು. ಟ್ರಿಪ್ ಮತ್ತು ಪಾವತಿಗಳು ಸಿಂಕ್ ಆದಂತೆ ಡ್ರಾಫ್ಟ್‌ಗಳು ಅಪ್‌ಡೇಟ್ ಆಗುತ್ತವೆ.';

  @override
  String noActivity({required String date}) {
    return '$date ರಂದು ಯಾವ ಡ್ರೈವರ್ ಚಟುವಟಿಕೆಯೂ ಇಲ್ಲ';
  }

  @override
  String tripsCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ಟ್ರಿಪ್‌ಗಳು',
      one: '1 ಟ್ರಿಪ್',
    );
    return '$_temp0';
  }

  @override
  String get expected => 'ನಿರೀಕ್ಷಿತ';

  @override
  String get online => 'ಆನ್‌ಲೈನ್';

  @override
  String get expenses => 'ಖರ್ಚುಗಳು';

  @override
  String get earnings => 'ಗಳಿಕೆ';

  @override
  String get lateItems => 'ತಡವಾಗಿ ಬಂದವು';

  @override
  String get net => 'ನಿವ್ವಳ';

  @override
  String get draft => 'ಡ್ರಾಫ್ಟ್';

  @override
  String shortfall({required String amount}) {
    return 'ಕೊರತೆ $amount';
  }

  @override
  String get expectedFare => 'ನಿರೀಕ್ಷಿತ ಬಾಡಿಗೆ';

  @override
  String get cashCollected => 'ಸಂಗ್ರಹಿಸಿದ ನಗದು';

  @override
  String get onlineToYou => 'ಆನ್‌ಲೈನ್ (ನಿಮಗೆ)';

  @override
  String get driversExpenses => 'ಡ್ರೈವರ್ ಖರ್ಚುಗಳು';

  @override
  String get driversEarnings => 'ಡ್ರೈವರ್ ಗಳಿಕೆ';

  @override
  String get shortfallLabel => 'ಕೊರತೆ';

  @override
  String get shortfallHint => 'ನಿರೀಕ್ಷಿತ ಬಾಡಿಗೆಯಿಂದ ಸಂಗ್ರಹಿಸಿದ ಎಲ್ಲವನ್ನೂ ಕಳೆದು';

  @override
  String get settlementLabel => 'ಲೆಕ್ಕ ಚುಕ್ತಾ';

  @override
  String get netFormula =>
      'ನಿವ್ವಳ = ಸಂಗ್ರಹಿಸಿದ ನಗದು − ಡ್ರೈವರ್ ಕಟ್ಟಿದ ಖರ್ಚು − ಡ್ರೈವರ್ ಗಳಿಕೆ ± ಈಗಾಗಲೇ ಚುಕ್ತಾ ಆದ ದಿನಗಳ ತಡವಾದ ಐಟಂಗಳು.';

  @override
  String driverPaysYou({required String amount}) {
    return 'ಡ್ರೈವರ್ ನಿಮಗೆ $amount ಕೊಡಬೇಕು';
  }

  @override
  String youPayDriver({required String amount}) {
    return 'ನೀವು ಡ್ರೈವರ್‌ಗೆ $amount ಕೊಡಬೇಕು';
  }

  @override
  String get nothingToHandOver => 'ಕೊಡಲು ಏನೂ ಇಲ್ಲ';

  @override
  String settledOn({required String when}) {
    return '$when ಚುಕ್ತಾ ಆಗಿದೆ. ನಂತರದ ಬದಲಾವಣೆಗಳು ಮುಂದಿನ ದಿನಕ್ಕೆ ಹೋಗುತ್ತವೆ.';
  }

  @override
  String get markSettledHint =>
      'ನಗದು ಸಿಕ್ಕ ನಂತರ ಚುಕ್ತಾ ಎಂದು ಗುರುತಿಸಿ. ಇದು ಆ ದಿನವನ್ನು ಲಾಕ್ ಮಾಡುತ್ತದೆ.';

  @override
  String get markSettled => 'ಚುಕ್ತಾ ಎಂದು ಗುರುತಿಸಿ';

  @override
  String lateFrom({required String date}) {
    return '$date ದಿನದ್ದು, ಆ ದಿನ ಚುಕ್ತಾ ಆದ ನಂತರ ಸಿಂಕ್ ಆಗಿದೆ';
  }

  @override
  String get lineTrip => 'ಟ್ರಿಪ್';

  @override
  String get lineCharge => 'ಶುಲ್ಕ';

  @override
  String get linePayment => 'ಪಾವತಿ';

  @override
  String get lineFuel => 'ಇಂಧನ';

  @override
  String get lineAdjustment => 'ತಡವಾದ ಐಟಂ';

  @override
  String itemTripVehicle({
    required String route,
    required String registrationNo,
  }) {
    return '$route ($registrationNo)';
  }

  @override
  String itemCancelled({required String text}) {
    return '$text · ರದ್ದಾಗಿದೆ';
  }

  @override
  String itemChargeDriverPaid({required String kind}) {
    return '$kind, ಡ್ರೈವರ್ ಕಟ್ಟಿದ್ದು';
  }

  @override
  String itemChargeBilled({required String kind}) {
    return '$kind, ಗ್ರಾಹಕರಿಗೆ ಬಿಲ್ ಮಾಡಲಾಗಿದೆ';
  }

  @override
  String itemChargeExtraFare({required String kind}) {
    return '$kind, ಹೆಚ್ಚುವರಿ ಬಾಡಿಗೆ';
  }

  @override
  String itemOnTrip({required String text, required String route}) {
    return '$text · $route';
  }

  @override
  String itemPayment({required String method}) {
    return '$method ಪಾವತಿ';
  }

  @override
  String itemReference({required String text, required String reference}) {
    return '$text (ರೆಫ್ $reference)';
  }

  @override
  String itemFuel({
    required String fuel,
    required String quantity,
    required String amount,
    required String payer,
  }) {
    return '$fuel $quantity, $amount, $payer';
  }

  @override
  String get auditThresholds => 'ಆಡಿಟ್ ಮಿತಿಗಳು';

  @override
  String get fuelKSigma => 'ಇಂಧನ ಅಲರ್ಟ್ ಸಂವೇದನೆ (k σ)';

  @override
  String get fuelKSigmaHint =>
      'ಸಾಮಾನ್ಯಕ್ಕಿಂತ ಇಷ್ಟು ಸ್ಟ್ಯಾಂಡರ್ಡ್ ಡೀವಿಯೇಷನ್ ಕೆಟ್ಟದಾದ ಸೈಕಲ್ ಅನ್ನು ಗುರುತಿಸಿ. ಕಡಿಮೆ = ಹೆಚ್ಚು ಅಲರ್ಟ್‌ಗಳು.';

  @override
  String get fuelMinCycles => 'σ ಬಳಸುವ ಮೊದಲು ಸೈಕಲ್‌ಗಳು';

  @override
  String get fuelMinCyclesHint =>
      'ಇಷ್ಟು ಸಾಮಾನ್ಯ ಸೈಕಲ್‌ಗಳು ಆಗುವವರೆಗೆ ಹೊಸ ವಾಹನಗಳಿಗೆ ಶೇಕಡಾ ನಿಯಮ ಬಳಸಲಾಗುತ್ತದೆ.';

  @override
  String get fuelPct => 'ಹೊಸ ವಾಹನದ ಮಿತಿ (%)';

  @override
  String get fuelPctHint =>
      'ಹೊಸ ವಾಹನಗಳಿಗೆ, ಸಾಮಾನ್ಯ ಅಂಕಿಗಿಂತ ಇಷ್ಟು ಕೆಟ್ಟದಾದ ಸೈಕಲ್ ಅನ್ನು ಗುರುತಿಸಿ.';

  @override
  String get fuelAlpha => 'ಬೇಸ್‌ಲೈನ್ ಪ್ರತಿಕ್ರಿಯೆ (α)';

  @override
  String get fuelAlphaHint =>
      'ಸಾಮಾನ್ಯ ಅಂಕಿ ಇತ್ತೀಚಿನ ಸೈಕಲ್‌ಗಳನ್ನು ಎಷ್ಟು ಬೇಗ ಅನುಸರಿಸುತ್ತದೆ (0.05–0.9).';

  @override
  String get odoTolerance => 'ಓಡೋಮೀಟರ್ ಮತ್ತು GPS ವ್ಯತ್ಯಾಸ ಮಿತಿ (%)';

  @override
  String get odoToleranceHint =>
      'ಓಡೋಮೀಟರ್ ದೂರ GPS ಮಾರ್ಗಕ್ಕಿಂತ ಇಷ್ಟಕ್ಕಿಂತ ಹೆಚ್ಚಿದ್ದರೆ ಆ ಟ್ರಿಪ್‌ಗಳನ್ನು ಗುರುತಿಸಿ.';

  @override
  String get docAlertDays => 'ದಾಖಲೆ ಅಲರ್ಟ್ ದಿನಗಳು';

  @override
  String get docAlertDaysHint =>
      'ಕಾಮಾ ಹಾಕಿ ಬರೆಯಿರಿ, ಉದಾ. 30, 7, 1. ಅವಧಿ ಮುಗಿದಾಗಲೂ ಅಲರ್ಟ್ ಬರುತ್ತದೆ.';

  @override
  String get checkThresholds =>
      'ಮೌಲ್ಯಗಳನ್ನು ಪರಿಶೀಲಿಸಿ: ಕೆಲವು ಅನುಮತಿಸಿದ ಮಿತಿಯ ಹೊರಗಿವೆ.';

  @override
  String get savedThresholds =>
      'ಉಳಿಸಲಾಗಿದೆ. ಮುಂದಿನ ಮರುಲೆಕ್ಕದಿಂದ ಇಂಧನ ಆಡಿಟ್ ಹೊಸ ಮಿತಿಗಳನ್ನು ಬಳಸುತ್ತದೆ.';

  @override
  String get saveThresholds => 'ಮಿತಿಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get defaultDriverPay => 'ಡೀಫಾಲ್ಟ್ ಡ್ರೈವರ್ ಸಂಬಳ';

  @override
  String get defaultPayIntro =>
      'ಸ್ವಂತ ಸಂಬಳ ನಿಯಮ ಇಲ್ಲದ ಪ್ರತಿ ಡ್ರೈವರ್‌ನ ಲೆಕ್ಕ ಚುಕ್ತಾದಲ್ಲಿ ಇದನ್ನು ಬಳಸಲಾಗುತ್ತದೆ.';

  @override
  String get savedPay => 'ಉಳಿಸಲಾಗಿದೆ. ಈಗಾಗಲೇ ಚುಕ್ತಾ ಆದ ದಿನಗಳು ಬದಲಾಗುವುದಿಲ್ಲ.';

  @override
  String get saveDefaultPay => 'ಡೀಫಾಲ್ಟ್ ಸಂಬಳ ಉಳಿಸಿ';

  @override
  String get settingsOwnerOnly =>
      'ಮಾಲೀಕರು ಮಾತ್ರ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಬದಲಾಯಿಸಬಹುದು.';

  @override
  String signedInAs({required String name, required String roles}) {
    return '$name · $roles';
  }

  @override
  String get password => 'ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get logIn => 'ಲಾಗ್ ಇನ್';

  @override
  String get forgotPassword => 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರಾ?';

  @override
  String get newHereSignUp => 'ಫ್ಲೀಟ್ ಸಾರಥಿಗೆ ಹೊಸಬರೇ? ಸೈನ್ ಅಪ್ ಮಾಡಿ';

  @override
  String get haveAccountLogIn => 'ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ? ಲಾಗ್ ಇನ್ ಮಾಡಿ';

  @override
  String get backToLogIn => 'ಲಾಗ್ ಇನ್‌ಗೆ ಹಿಂತಿರುಗಿ';

  @override
  String get signUpTitle => 'ನಿಮ್ಮ ಖಾತೆ ರಚಿಸಿ';

  @override
  String get signUpIntro =>
      'ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್‌ಗೆ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆಮಾಡಿ. ಡ್ರೈವರ್‌ಗಳು ಫ್ಲೀಟ್ ಮಾಲೀಕರು ನೋಂದಾಯಿಸಿದ ನಂಬರ್ ಬಳಸಬೇಕು.';

  @override
  String get createAccount => 'ಖಾತೆ ರಚಿಸಿ';

  @override
  String get yourNameOptional => 'ನಿಮ್ಮ ಹೆಸರು (ಐಚ್ಛಿಕ)';

  @override
  String get newPassword => 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get confirmPassword => 'ಪಾಸ್‌ವರ್ಡ್ ಮತ್ತೆ ಟೈಪ್ ಮಾಡಿ';

  @override
  String get currentPassword => 'ಈಗಿನ ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get passwordHint => 'ಕನಿಷ್ಠ 8 ಅಕ್ಷರಗಳು';

  @override
  String get enterPassword => 'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ';

  @override
  String get passwordTooShort => 'ಕನಿಷ್ಠ 8 ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ.';

  @override
  String get passwordTooLong => 'ಗರಿಷ್ಠ 128 ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ.';

  @override
  String get passwordsDontMatch => 'ಎರಡೂ ಪಾಸ್‌ವರ್ಡ್‌ಗಳು ಹೊಂದುತ್ತಿಲ್ಲ.';

  @override
  String get showPassword => 'ಪಾಸ್‌ವರ್ಡ್ ತೋರಿಸಿ';

  @override
  String get hidePassword => 'ಪಾಸ್‌ವರ್ಡ್ ಮರೆಮಾಡಿ';

  @override
  String get resetPasswordTitle => 'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ರೀಸೆಟ್ ಮಾಡಿ';

  @override
  String get resetPasswordIntro =>
      'ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್‌ಗೆ ರೀಸೆಟ್ ಕೋಡ್ ಕಳುಹಿಸುತ್ತೇವೆ. ನಂತರ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get resetPassword => 'ಪಾಸ್‌ವರ್ಡ್ ರೀಸೆಟ್ ಮಾಡಿ';

  @override
  String get saveAndLogIn => 'ಪಾಸ್‌ವರ್ಡ್ ಉಳಿಸಿ ಲಾಗ್ ಇನ್ ಮಾಡಿ';

  @override
  String get resendCode => 'ಕೋಡ್ ಮತ್ತೆ ಕಳುಹಿಸಿ';

  @override
  String resendCodeIn({required String seconds}) {
    return '$seconds ಸೆ. ನಂತರ ಕೋಡ್ ಮತ್ತೆ ಕಳುಹಿಸಿ';
  }

  @override
  String get codeResent => 'ಹೊಸ ಕೋಡ್ ಕಳುಹಿಸಿದ್ದೇವೆ.';

  @override
  String get resetCodeInApiLog =>
      'ಲೋಕಲ್ ಅಥವಾ ಡೆಮೊದಲ್ಲಿ ಟೆಸ್ಟ್ ಮಾಡುತ್ತಿದ್ದೀರಾ? ಕೋಡ್ SMS ಮೂಲಕ ಬರುವುದಿಲ್ಲ: ಅದು API ಸರ್ವರ್ ಲಾಗ್‌ನಲ್ಲಿ ಕಾಣುತ್ತದೆ.';

  @override
  String get accountSecurity => 'ಖಾತೆ ಸುರಕ್ಷತೆ';

  @override
  String get signInMethods => 'ನೀವು ಸೈನ್ ಇನ್ ಮಾಡುವ ವಿಧಾನ';

  @override
  String get passwordIsSet => 'ಹೊಂದಿಸಲಾಗಿದೆ';

  @override
  String get passwordNotSet => 'ಇನ್ನೂ ಹೊಂದಿಸಿಲ್ಲ';

  @override
  String get setPassword => 'ಪಾಸ್‌ವರ್ಡ್ ಹೊಂದಿಸಿ';

  @override
  String get setPasswordIntro =>
      'ನಂತರ ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್‌ನಿಂದ ಲಾಗ್ ಇನ್ ಮಾಡಬಹುದು.';

  @override
  String get changePassword => 'ಪಾಸ್‌ವರ್ಡ್ ಬದಲಿಸಿ';

  @override
  String get savePassword => 'ಪಾಸ್‌ವರ್ಡ್ ಉಳಿಸಿ';

  @override
  String get passwordSaved => 'ಪಾಸ್‌ವರ್ಡ್ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get currentPasswordWrong => 'ನಿಮ್ಮ ಈಗಿನ ಪಾಸ್‌ವರ್ಡ್ ತಪ್ಪಾಗಿದೆ.';

  @override
  String get editDrivers => 'ಡ್ರೈವರ್‌ಗಳನ್ನು ಬದಲಿಸಿ';

  @override
  String get editVehicles => 'ವಾಹನಗಳನ್ನು ಬದಲಿಸಿ';

  @override
  String get noLinkedDrivers =>
      'ಇನ್ನೂ ಯಾವ ಡ್ರೈವರ್ ಲಿಂಕ್ ಆಗಿಲ್ಲ. ಈ ವಾಹನದ ಟ್ರಿಪ್‌ಗಳು ಲಿಂಕ್ ಆದ ಡ್ರೈವರ್‌ಗೆ ಮಾತ್ರ ಹೋಗುತ್ತವೆ.';

  @override
  String get noLinkedVehicles =>
      'ಇನ್ನೂ ಯಾವ ವಾಹನ ಲಿಂಕ್ ಆಗಿಲ್ಲ. ಈ ಡ್ರೈವರ್‌ಗೆ ಲಿಂಕ್ ಆದ ವಾಹನದಲ್ಲಿ ಮಾತ್ರ ಟ್ರಿಪ್ ಸಿಗುತ್ತದೆ.';

  @override
  String editDriversIntro({required String vehicle}) {
    return '$vehicle ಅನ್ನು ಯಾರು ಓಡಿಸಬಹುದು? ಟ್ರಿಪ್‌ಗಳಲ್ಲಿ ಇದನ್ನು ಈ ಡ್ರೈವರ್‌ಗಳ ಜೊತೆ ಮಾತ್ರ ಸೇರಿಸಬಹುದು.';
  }

  @override
  String editVehiclesIntro({required String name}) {
    return '$name ಯಾವ ವಾಹನಗಳನ್ನು ಓಡಿಸಬಹುದು? ಇವುಗಳಲ್ಲಿ ಮಾತ್ರ ಅವರಿಗೆ ಟ್ರಿಪ್ ಸಿಗುತ್ತದೆ.';
  }

  @override
  String get driversOptional => 'ಡ್ರೈವರ್‌ಗಳು (ಐಚ್ಛಿಕ)';

  @override
  String get vehiclesOptional => 'ವಾಹನಗಳು (ಐಚ್ಛಿಕ)';

  @override
  String get driversOptionalHint => 'ಇದನ್ನು ಯಾರು ಓಡಿಸಬಹುದು. ನಂತರ ಬದಲಿಸಬಹುದು.';

  @override
  String get vehiclesOptionalHint =>
      'ಅವರು ಯಾವ ವಾಹನಗಳನ್ನು ಓಡಿಸಬಹುದು. ನಂತರ ಬದಲಿಸಬಹುದು.';

  @override
  String get noneSelected => 'ಇನ್ನೂ ಯಾವುದೂ ಇಲ್ಲ';

  @override
  String get noDriversToLink =>
      'ಇನ್ನೂ ಡ್ರೈವರ್‌ಗಳಿಲ್ಲ. ಮೊದಲು ಡ್ರೈವರ್‌ನನ್ನು ಆಹ್ವಾನಿಸಿ.';

  @override
  String get noVehiclesToLink => 'ಇನ್ನೂ ವಾಹನಗಳಿಲ್ಲ. ಮೊದಲು ವಾಹನ ಸೇರಿಸಿ.';

  @override
  String get vehicleHasNoDrivers =>
      'ಈ ವಾಹನಕ್ಕೆ ಯಾವ ಡ್ರೈವರ್ ಲಿಂಕ್ ಆಗಿಲ್ಲ. ಮೊದಲು ವಾಹನದ ಪುಟದಲ್ಲಿ ಡ್ರೈವರ್‌ಗಳನ್ನು ಲಿಂಕ್ ಮಾಡಿ.';

  @override
  String get driverHasNoVehicles =>
      'ಈ ಡ್ರೈವರ್‌ಗೆ ಯಾವ ವಾಹನ ಲಿಂಕ್ ಆಗಿಲ್ಲ. ಮೊದಲು ಡ್ರೈವರ್‌ನ ಪುಟದಲ್ಲಿ ವಾಹನಗಳನ್ನು ಲಿಂಕ್ ಮಾಡಿ.';

  @override
  String get noVehiclesLinkedToYou =>
      'ನಿಮಗೆ ಇನ್ನೂ ಯಾವ ವಾಹನ ಲಿಂಕ್ ಆಗಿಲ್ಲ. ವಾಹನಕ್ಕೆ ಲಿಂಕ್ ಮಾಡಲು ಫ್ಲೀಟ್ ಮಾಲೀಕರನ್ನು ಕೇಳಿ.';

  @override
  String get noVehiclesLinkedHint =>
      'ನೀವು ಆಫ್‌ಲೈನ್ ಇದ್ದರೆ, ಆ್ಯಪ್ ಅವುಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಒಮ್ಮೆ ಇಂಟರ್ನೆಟ್‌ಗೆ ಕನೆಕ್ಟ್ ಮಾಡಿ.';

  @override
  String get errorDriverNotLinked =>
      'ಡ್ರೈವರ್ ಈ ವಾಹನಕ್ಕೆ ಲಿಂಕ್ ಆಗಿಲ್ಲ. ಮಾಲೀಕರು ವಾಹನದ ಪುಟದಲ್ಲಿ ಲಿಂಕ್ ಮಾಡಬಹುದು.';

  @override
  String errorDriverNotLinkedNamed({
    required String driver,
    required String vehicle,
  }) {
    return '$driver ಅವರು $vehicle ಗೆ ಲಿಂಕ್ ಆಗಿಲ್ಲ. ಮೊದಲು ವಾಹನದ ಪುಟದಲ್ಲಿ ಲಿಂಕ್ ಮಾಡಿ.';
  }

  @override
  String get errorLinkInUse =>
      'ಈ ವಾಹನದಲ್ಲಿ ಡ್ರೈವರ್‌ಗೆ ನಿಯೋಜಿತ ಅಥವಾ ನಡೆಯುತ್ತಿರುವ ಟ್ರಿಪ್‌ಗಳಿವೆ. ಅನ್‌ಲಿಂಕ್ ಮಾಡುವ ಮೊದಲು ಅವುಗಳನ್ನು ಬೇರೆಯವರಿಗೆ ಕೊಡಿ ಅಥವಾ ಮುಗಿಸಿ.';

  @override
  String errorLinkInUseCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ಈ ವಾಹನದಲ್ಲಿ ಡ್ರೈವರ್‌ಗೆ $count ನಿಯೋಜಿತ ಅಥವಾ ನಡೆಯುತ್ತಿರುವ ಟ್ರಿಪ್‌ಗಳಿವೆ. ಅನ್‌ಲಿಂಕ್ ಮಾಡುವ ಮೊದಲು ಅವುಗಳನ್ನು ಬೇರೆಯವರಿಗೆ ಕೊಡಿ ಅಥವಾ ಮುಗಿಸಿ.',
      one:
          'ಈ ವಾಹನದಲ್ಲಿ ಡ್ರೈವರ್‌ಗೆ 1 ನಿಯೋಜಿತ ಅಥವಾ ನಡೆಯುತ್ತಿರುವ ಟ್ರಿಪ್ ಇದೆ. ಅನ್‌ಲಿಂಕ್ ಮಾಡುವ ಮೊದಲು ಅದನ್ನು ಬೇರೆಯವರಿಗೆ ಕೊಡಿ ಅಥವಾ ಮುಗಿಸಿ.',
    );
    return '$_temp0';
  }

  @override
  String get switchWorkspace => 'ಮೋಡ್ ಅಥವಾ ಫ್ಲೀಟ್ ಬದಲಿಸಿ';

  @override
  String workspaceManage({required String fleet}) {
    return '$fleet ನಿರ್ವಹಿಸಿ';
  }

  @override
  String workspaceDrive({required String fleet}) {
    return '$fleet ಗಾಗಿ ಓಡಿಸಿ';
  }

  @override
  String get workspaceManageHint =>
      'ಮಾಲೀಕ ಮೋಡ್: ವಾಹನಗಳು, ಡ್ರೈವರ್‌ಗಳು, ಟ್ರಿಪ್‌ಗಳು ಮತ್ತು ಹಣ';

  @override
  String get workspaceDriveHint =>
      'ಡ್ರೈವರ್ ಮೋಡ್: ನಿಮ್ಮ ಟ್ರಿಪ್‌ಗಳು, ಇಂಧನ ಮತ್ತು ಫೋಟೋಗಳು';

  @override
  String get setUpMyFleet => 'ನನ್ನ ಬಳಿ ವಾಹನಗಳಿವೆ: ನನ್ನ ಫ್ಲೀಟ್ ಸೆಟ್ ಅಪ್ ಮಾಡಿ';

  @override
  String unsyncedBeforeSwitch({required int count}) {
    return 'ಈ ಫೋನ್‌ನಲ್ಲಿರುವ $count ಟ್ರಿಪ್ ಅಪ್‌ಡೇಟ್‌ಗಳು ಇನ್ನೂ ಕಳುಹಿಸಿಲ್ಲ. ಆನ್‌ಲೈನ್‌ಗೆ ಬನ್ನಿ, ಸಿಂಕ್ ಆಗಲು ಬಿಡಿ, ನಂತರ ಬದಲಿಸಿ.';
  }

  @override
  String get getStartedTitle => 'ಫ್ಲೀಟ್ ಸಾರಥಿಗೆ ಸ್ವಾಗತ';

  @override
  String get getStartedDriveTitle => 'ವಾಹನ ಮಾಲೀಕರಿಗಾಗಿ ಓಡಿಸಿ';

  @override
  String getStartedDriveBody({required String phone}) {
    return '$phone ಅನ್ನು ಅವರ ಫ್ಲೀಟ್ ಸಾರಥಿಯಲ್ಲಿ ಡ್ರೈವರ್ ಆಗಿ ಸೇರಿಸಲು ಮಾಲೀಕರನ್ನು ಕೇಳಿ. ನಂತರ ಮತ್ತೆ ಪರಿಶೀಲಿಸಿ ಒತ್ತಿ.';
  }

  @override
  String get checkAgain => 'ಮತ್ತೆ ಪರಿಶೀಲಿಸಿ';

  @override
  String get stillNoFleet => 'ಇನ್ನೂ ಯಾವ ಮಾಲೀಕರೂ ನಿಮ್ಮನ್ನು ಸೇರಿಸಿಲ್ಲ.';

  @override
  String get getStartedOwnTitle => 'ನಿಮ್ಮ ಬಳಿ ವಾಹನಗಳಿವೆಯೇ?';

  @override
  String get getStartedOwnBody =>
      'ವಾಹನಗಳು ಮತ್ತು ಡ್ರೈವರ್‌ಗಳನ್ನು ಸೇರಿಸಲು ನಿಮ್ಮ ಫ್ಲೀಟ್ ಸೆಟ್ ಅಪ್ ಮಾಡಿ. ಅದೇ ಖಾತೆಯಿಂದ ಬೇರೆ ಮಾಲೀಕರಿಗಾಗಿಯೂ ಓಡಿಸಬಹುದು.';

  @override
  String get createFleetTitle => 'ನಿಮ್ಮ ಫ್ಲೀಟ್ ಸೆಟ್ ಅಪ್ ಮಾಡಿ';

  @override
  String get fleetNameLabel => 'ಫ್ಲೀಟ್ ಅಥವಾ ವ್ಯಾಪಾರದ ಹೆಸರು';

  @override
  String get fleetNameTooShort => 'ಕನಿಷ್ಠ 2 ಅಕ್ಷರಗಳನ್ನು ನಮೂದಿಸಿ';

  @override
  String get iDriveToo => 'ನನ್ನ ಸ್ವಂತ ವಾಹನಗಳನ್ನು ನಾನೂ ಓಡಿಸುತ್ತೇನೆ';

  @override
  String get createFleet => 'ಫ್ಲೀಟ್ ರಚಿಸಿ';

  @override
  String get addMapPin => 'ಮ್ಯಾಪ್ ಪಿನ್ ಸೇರಿಸಿ';

  @override
  String get changePin => 'ಬದಲಿಸಿ';

  @override
  String get removePin => 'ಪಿನ್ ತೆಗೆಯಿರಿ';

  @override
  String get pickupOnMap => 'ಮ್ಯಾಪ್‌ನಲ್ಲಿ ಪಿಕಪ್';

  @override
  String get dropOnMap => 'ಮ್ಯಾಪ್‌ನಲ್ಲಿ ಡ್ರಾಪ್';

  @override
  String get pinPickerHint =>
      'ಪಿನ್ ಹಾಕಲು ಮ್ಯಾಪ್ ಮೇಲೆ ಒತ್ತಿ. ಸರಿಸಲು ಮತ್ತೆ ಒತ್ತಿ.';

  @override
  String get usePin => 'ಈ ಪಿನ್ ಬಳಸಿ';

  @override
  String get navGroupOverview => 'ಸಾರಾಂಶ';

  @override
  String get navGroupFleet => 'ಫ್ಲೀಟ್';

  @override
  String get navGroupMoney => 'ಹಣ';

  @override
  String get navGroupSetup => 'ಸೆಟಪ್';

  @override
  String get greetingMorning => 'ಶುಭೋದಯ';

  @override
  String get greetingAfternoon => 'ಶುಭ ಮಧ್ಯಾಹ್ನ';

  @override
  String get greetingEvening => 'ಶುಭ ಸಂಜೆ';

  @override
  String get colRoute => 'ಮಾರ್ಗ';

  @override
  String get colCustomer => 'ಗ್ರಾಹಕ';

  @override
  String get colFare => 'ಬಾಡಿಗೆ';

  @override
  String get colDocument => 'ದಾಖಲೆ';

  @override
  String get colFor => 'ಯಾರಿಗೆ';

  @override
  String get colNumber => 'ನಂಬರ್';

  @override
  String get colRole => 'ಪಾತ್ರ';

  @override
  String get colBalance => 'ಬಾಕಿ';

  @override
  String get colShortfall => 'ಕೊರತೆ';

  @override
  String get usualEfficiency => 'ಸಾಮಾನ್ಯ ಮೈಲೇಜ್';

  @override
  String get alertsInbox => 'ಅಲರ್ಟ್‌ಗಳು ಮತ್ತು ಪರಿಶೀಲನೆ';

  @override
  String get documentsExpiredChip => 'ದಾಖಲೆ ಅವಧಿ ಮುಗಿದಿದೆ';

  @override
  String get documentsDueChip => 'ದಾಖಲೆ ನವೀಕರಣ ಬಾಕಿ';

  @override
  String get managersSection => 'ಮ್ಯಾನೇಜರ್‌ಗಳು';

  @override
  String get noManagersYet => 'ಇನ್ನೂ ಮ್ಯಾನೇಜರ್‌ಗಳಿಲ್ಲ.';

  @override
  String get shareTripHeading => 'ಟ್ರಿಪ್ ವಿವರಗಳು';

  @override
  String get shareCustomer => 'ಗ್ರಾಹಕ';

  @override
  String get sharePickup => 'ಪಿಕಪ್';

  @override
  String get shareDrop => 'ಡ್ರಾಪ್';

  @override
  String get sharePickupTime => 'ಪಿಕಪ್ ಸಮಯ';

  @override
  String get shareCab => 'ಕ್ಯಾಬ್';

  @override
  String get shareDriver => 'ಡ್ರೈವರ್';

  @override
  String get shareFare => 'ಬಾಡಿಗೆ';

  @override
  String shareFareWithKm({required String fare, required String km}) {
    return '$fare ($km ಸೇರಿ)';
  }

  @override
  String get copyDetails => 'ವಿವರಗಳನ್ನು ಕಾಪಿ ಮಾಡಿ';

  @override
  String get detailsCopied => 'ಟ್ರಿಪ್ ವಿವರಗಳು ಕಾಪಿ ಆಗಿವೆ';

  @override
  String get shareOnWhatsApp => 'WhatsApp ನಲ್ಲಿ ಕಳುಹಿಸಿ';

  @override
  String get whatsAppUnavailable => 'WhatsApp ತೆರೆಯಲು ಆಗಲಿಲ್ಲ';

  @override
  String get analytics => 'ವಿಶ್ಲೇಷಣೆ';

  @override
  String get analyticsIntro =>
      'ತಿಂಗಳ ದಿನನಿತ್ಯದ ಇಂಧನ ಖರೀದಿ, ಆದಾಯ ಮತ್ತು km, ವಾಹನವಾರು.';

  @override
  String get month => 'ತಿಂಗಳು';

  @override
  String get perTripAverages => 'ಪ್ರತಿ ಟ್ರಿಪ್ ಸರಾಸರಿ';

  @override
  String get avgKmPerTrip => 'ಪ್ರತಿ ಟ್ರಿಪ್ km';

  @override
  String get avgRevenuePerTrip => 'ಪ್ರತಿ ಟ್ರಿಪ್ ಆದಾಯ';

  @override
  String get avgFuelCostPerTrip => 'ಪ್ರತಿ ಟ್ರಿಪ್ ಇಂಧನ ಖರ್ಚು (ಅಂದಾಜು)';

  @override
  String tripsInMonth({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ಈ ತಿಂಗಳು $count ಟ್ರಿಪ್‌ಗಳು',
      one: 'ಈ ತಿಂಗಳು 1 ಟ್ರಿಪ್',
    );
    return '$_temp0';
  }

  @override
  String get fuelBoughtPerDay => 'ದಿನಕ್ಕೆ ಖರೀದಿಸಿದ ಇಂಧನ';

  @override
  String get revenuePerDay => 'ದಿನಕ್ಕೆ ಆದಾಯ';

  @override
  String get kmPerDay => 'ದಿನಕ್ಕೆ ಓಡಿದ km';

  @override
  String monthTotal({required String total}) {
    return 'ತಿಂಗಳ ಒಟ್ಟು: $total';
  }

  @override
  String get fuelInRupeesNote =>
      'ಲೀಟರ್ ಮತ್ತು kg ಸೇರಿಸಲು ಆಗದ ಕಾರಣ ₹ ನಲ್ಲಿ ತೋರಿಸಲಾಗಿದೆ.';

  @override
  String get noActivityThisMonth => 'ಈ ತಿಂಗಳು ಏನೂ ಇಲ್ಲ.';

  @override
  String get customDay => 'ಕಸ್ಟಮ್';

  @override
  String tripsOnDay({required String date}) {
    return '$date ರ ಟ್ರಿಪ್‌ಗಳು';
  }

  @override
  String get availableCabs => 'ಲಭ್ಯವಿರುವ ಕ್ಯಾಬ್‌ಗಳು';

  @override
  String get availableDrivers => 'ಲಭ್ಯವಿರುವ ಡ್ರೈವರ್‌ಗಳು';

  @override
  String get tripsUnassigned => 'ನಿಯೋಜಿಸದ ಟ್ರಿಪ್‌ಗಳು';

  @override
  String get completedTrips => 'ಮುಗಿದ ಟ್ರಿಪ್‌ಗಳು';

  @override
  String percentReady({required int percent}) {
    return '$percent% ಸಿದ್ಧ';
  }

  @override
  String cabsFooter({required int onTrip, required int inactive}) {
    return '$onTrip ಟ್ರಿಪ್‌ನಲ್ಲಿ · $inactive ನಿಷ್ಕ್ರಿಯ';
  }

  @override
  String driversFooter({required int onTrip, required int assigned}) {
    return '$onTrip ಟ್ರಿಪ್‌ನಲ್ಲಿ · $assigned ನಿಯೋಜಿತ';
  }

  @override
  String get standby => 'ಸ್ಟ್ಯಾಂಡ್‌ಬೈ';

  @override
  String get needsCab => 'ಕ್ಯಾಬ್ ಬೇಕು';

  @override
  String get pending => 'ಬಾಕಿ';

  @override
  String get resolveQueue => 'ಬಾಕಿ ಪಟ್ಟಿ ಬಗೆಹರಿಸಿ';

  @override
  String get runs => 'ಓಡಾಟಗಳು';

  @override
  String grossFare({required String amount}) {
    return '$amount ಒಟ್ಟು ಬಾಡಿಗೆ';
  }

  @override
  String busyFromTo({required String from, required String to}) {
    return '$from – $to ಬ್ಯುಸಿ';
  }

  @override
  String get busyPickCleared =>
      'ನೀವು ಆರಿಸಿದ ವಾಹನ ಅಥವಾ ಡ್ರೈವರ್ ಹೊಸ ಸಮಯದಲ್ಲಿ ಬುಕ್ ಆಗಿದೆ, ಆದ್ದರಿಂದ ಅದನ್ನು ತೆಗೆದುಹಾಕಲಾಗಿದೆ.';

  @override
  String get busyPickWarning =>
      'ಈ ವಾಹನ ಅಥವಾ ಡ್ರೈವರ್ ಈ ಸಮಯದಲ್ಲಿ ಈಗಾಗಲೇ ಬುಕ್ ಆಗಿದೆ.';

  @override
  String youAreBusy({required String when}) {
    return 'ಈ ಸಮಯದಲ್ಲಿ ನಿಮಗೆ ಈಗಾಗಲೇ ಒಂದು ಟ್ರಿಪ್ ಇದೆ ($when).';
  }

  @override
  String get uploadFile => 'ಫೈಲ್ ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get chooseOtherFile => 'ಬೇರೆ ಫೈಲ್ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get uploadFileHint =>
      'ಅಥವಾ PDF ಅಥವಾ ಚಿತ್ರ (JPG, PNG, WebP) ಅಪ್‌ಲೋಡ್ ಮಾಡಿ, 15 MB ವರೆಗೆ.';

  @override
  String get fileTooLarge => 'ಆ ಫೈಲ್ 15 MB ಗಿಂತ ದೊಡ್ಡದಾಗಿದೆ.';

  @override
  String get pdfDocument => 'PDF ದಾಖಲೆ';

  @override
  String get imageFile => 'ಚಿತ್ರ';

  @override
  String get viewDocument => 'ದಾಖಲೆ ನೋಡಿ';

  @override
  String get documentUnavailable => 'ದಾಖಲೆ ತೆರೆಯಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get schedule => 'ವೇಳಾಪಟ್ಟಿ';

  @override
  String get noTripsThisDay => 'ಈ ದಿನ ಯಾವ ಟ್ರಿಪ್‌ಗಳೂ ಇಲ್ಲ.';

  @override
  String get previousMonth => 'ಹಿಂದಿನ ತಿಂಗಳು';

  @override
  String get nextMonth => 'ಮುಂದಿನ ತಿಂಗಳು';

  @override
  String get logInWithOtp => 'OTP ಮೂಲಕ ಲಾಗ್ ಇನ್';

  @override
  String get noAccountForNumber =>
      'ಈ ನಂಬರ್‌ಗೆ ಇನ್ನೂ ಖಾತೆ ಇಲ್ಲ. ಬದಲಿಗೆ ಸೈನ್ ಅಪ್ ಮಾಡಿ.';

  @override
  String get signUpVerifyHint =>
      'ನಂಬರ್ ನಿಮ್ಮದೇ ಎಂದು ಖಚಿತಪಡಿಸಲು OTP ಕಳುಹಿಸುತ್ತೇವೆ.';

  @override
  String get verifyAndCreateAccount => 'ನಂಬರ್ ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಖಾತೆ ರಚಿಸಿ';

  @override
  String get resetWithOtpIntro =>
      'OTP ಮೂಲಕ ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್ ಪರಿಶೀಲಿಸಿ, ನಂತರ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ಆಯ್ಕೆಮಾಡಿ.';

  @override
  String get numberVerified => 'ನಂಬರ್ ಪರಿಶೀಲಿಸಲಾಗಿದೆ';

  @override
  String get verifyWithOtp => 'OTP ಮೂಲಕ ಪರಿಶೀಲಿಸಿ';

  @override
  String get phoneVerifyTitle => 'ನಿಮ್ಮ ನಂಬರ್ ಪರಿಶೀಲಿಸಿ';

  @override
  String get stubVerifyHint =>
      'ಟೆಸ್ಟ್ ಮೋಡ್: SMS ಕಳುಹಿಸುವುದಿಲ್ಲ. ಕೆಳಗಿನ ನಂಬರ್ ಪರಿಶೀಲಿಸಿದಂತೆ ಪರಿಗಣಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get errorPhoneOtpDisabled => 'OTP ಸೈನ್ ಇನ್ ಈಗ ಲಭ್ಯವಿಲ್ಲ.';

  @override
  String get errorPhoneNotVerified =>
      'ನಿಮ್ಮ ನಂಬರ್ ಪರಿಶೀಲಿಸಲು ಆಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get errorPhoneMismatch =>
      'ನೀವು ಪರಿಶೀಲಿಸಿದ ನಂಬರ್ ನೀವು ನಮೂದಿಸಿದ ನಂಬರ್ ಅಲ್ಲ.';

  @override
  String get errorPhoneVerificationRequired =>
      'ಸೈನ್ ಅಪ್ ಮಾಡಲು ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್ ಪರಿಶೀಲಿಸಿ.';

  @override
  String get verify => 'ಪರಿಶೀಲಿಸಿ';

  @override
  String get allowPopups =>
      'ನಿಮ್ಮ ನಂಬರ್ ಪರಿಶೀಲಿಸಲು ಈ ಸೈಟ್‌ಗೆ ಪಾಪ್-ಅಪ್‌ಗಳನ್ನು ಅನುಮತಿಸಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';

  @override
  String get tripInProgress => 'ಟ್ರಿಪ್ ನಡೆಯುತ್ತಿದೆ';

  @override
  String get nextTrip => 'ಮುಂದಿನ ಟ್ರಿಪ್';

  @override
  String startsIn({required String time}) {
    return '$time ನಲ್ಲಿ ಆರಂಭ';
  }

  @override
  String get startingNow => 'ಈಗ ಆರಂಭವಾಗುತ್ತಿದೆ';

  @override
  String runningLate({required String time}) {
    return '$time ತಡ';
  }

  @override
  String get todayAtAGlance => 'ಇಂದಿನ ಸಾರಾಂಶ';

  @override
  String get lastSevenDays => 'ಕಳೆದ 7 ದಿನಗಳು';

  @override
  String get statTripsDone => 'ಮುಗಿದ ಟ್ರಿಪ್‌ಗಳು';

  @override
  String get statKmDriven => 'ಓಡಿಸಿದ km';

  @override
  String get statCollected => 'ಸಂಗ್ರಹಿಸಿದ್ದು';

  @override
  String ofTotal({required int done, required int total}) {
    return '$total ರಲ್ಲಿ $done';
  }

  @override
  String cashAmount({required String amount}) {
    return 'ನಗದು $amount';
  }

  @override
  String get callCustomer => 'ಕರೆ ಮಾಡಿ';

  @override
  String get directions => 'ದಾರಿ';

  @override
  String kmSoFar({required String km}) {
    return 'ಇದುವರೆಗೆ $km';
  }

  @override
  String durationHm({required int h, required String m}) {
    return '$h ಗಂ $m ನಿಮಿ';
  }

  @override
  String durationM({required int m}) {
    return '$m ನಿಮಿ';
  }

  @override
  String get syncNow => 'ಈಗ ಸಿಂಕ್ ಮಾಡಿ';

  @override
  String get noTripsAssigned => 'ಇನ್ನೂ ಯಾವ ಟ್ರಿಪ್ ನಿಯೋಜಿಸಿಲ್ಲ';

  @override
  String get noTripsHint =>
      'ಫ್ಲೀಟ್ ಮಾಲೀಕರು ಟ್ರಿಪ್ ನಿಯೋಜಿಸಿದಾಗ ಅದು ಇಲ್ಲಿ ಕಾಣುತ್ತದೆ. ರಿಫ್ರೆಶ್ ಮಾಡಲು ಕೆಳಗೆ ಎಳೆಯಿರಿ, ಅಥವಾ ನೀವೇ ಒಂದು ಆರಂಭಿಸಿ.';

  @override
  String get detailsTab => 'ವಿವರಗಳು';

  @override
  String get documentFiles => 'ಫೈಲ್‌ಗಳು (ಫೋಟೋಗಳು ಅಥವಾ PDF)';

  @override
  String photoNumber({required int number}) {
    return 'ಫೋಟೋ $number';
  }

  @override
  String tooManyFiles({required int count}) {
    return 'ಒಂದು ದಾಖಲೆಗೆ $count ಫೈಲ್‌ಗಳವರೆಗೆ ಇರಬಹುದು.';
  }

  @override
  String fileTooLargeNamed({required String name}) {
    return '$name 15 MB ಗಿಂತ ದೊಡ್ಡದಾಗಿದೆ.';
  }

  @override
  String get uploadFiles => 'ಫೈಲ್‌ಗಳನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String viewFiles({required int count}) {
    return 'ಫೈಲ್‌ಗಳನ್ನು ನೋಡಿ ($count)';
  }

  @override
  String get open => 'ತೆರೆಯಿರಿ';

  @override
  String get filters => 'ಫಿಲ್ಟರ್‌ಗಳು';

  @override
  String filtersCount({required int count}) {
    return 'ಫಿಲ್ಟರ್‌ಗಳು ($count)';
  }

  @override
  String get clearAll => 'ಎಲ್ಲಾ ತೆಗೆಯಿರಿ';

  @override
  String get apply => 'ಅನ್ವಯಿಸಿ';

  @override
  String get severity => 'ತೀವ್ರತೆ';

  @override
  String get alertKindTitle => 'ವಿಧ';

  @override
  String get quickOpsHub => 'ಕ್ವಿಕ್ ಆಪರೇಷನ್ಸ್ ಹಬ್';

  @override
  String get fastDispatch => 'ಫಾಸ್ಟ್-ಡಿಸ್ಪ್ಯಾಚ್';

  @override
  String get addTrip => 'ಟ್ರಿಪ್ ಸೇರಿಸಿ';

  @override
  String get tagDriver => 'ಡ್ರೈವರ್ ಟ್ಯಾಗ್ ಮಾಡಿ';

  @override
  String get addDriverQuick => '+ ಡ್ರೈವರ್ ಸೇರಿಸಿ';

  @override
  String get addCabQuick => '+ ಕ್ಯಾಬ್ ಸೇರಿಸಿ';

  @override
  String get scheduledRides => 'ನಿಗದಿತ ರೈಡ್‌ಗಳು';

  @override
  String scheduledRidesOn({required String date}) {
    return 'ನಿಗದಿತ ರೈಡ್‌ಗಳು · $date';
  }

  @override
  String get noTripsWaiting => 'ಡ್ರೈವರ್‌ಗಾಗಿ ಕಾಯುತ್ತಿರುವ ಟ್ರಿಪ್‌ಗಳಿಲ್ಲ.';

  @override
  String get pickTripToAssign => 'ನಿಯೋಜಿಸಲು ಟ್ರಿಪ್ ಆರಿಸಿ';

  @override
  String get docAadhaar => 'ಆಧಾರ್ ಕಾರ್ಡ್';

  @override
  String get docPan => 'PAN ಕಾರ್ಡ್';

  @override
  String get docPoliceVerification => 'ಪೊಲೀಸ್ ಪರಿಶೀಲನೆ';

  @override
  String get docBadge => 'ಬ್ಯಾಡ್ಜ್ / PSV ಲೈಸೆನ್ಸ್';

  @override
  String get docPhoto => 'ಫೋಟೋ';

  @override
  String get noExpiry => 'ಅವಧಿ ಮುಗಿಯುವುದಿಲ್ಲ';

  @override
  String get docPendingApproval => 'ಅನುಮೋದನೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ';

  @override
  String get docRejected => 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ';

  @override
  String docRejectedBecause({required String note}) {
    return 'ತಿರಸ್ಕರಿಸಲಾಗಿದೆ: $note';
  }

  @override
  String get addedByDriver => 'ಡ್ರೈವರ್ ಸೇರಿಸಿದ್ದು';

  @override
  String get renewalOf => 'ನವೀಕರಣ';

  @override
  String get approveDocument => 'ಅನುಮೋದಿಸಿ';

  @override
  String get rejectDocument => 'ತಿರಸ್ಕರಿಸಿ';

  @override
  String get rejectDocumentTitle => 'ಈ ದಾಖಲೆ ತಿರಸ್ಕರಿಸಬೇಕೇ?';

  @override
  String get rejectReasonLabel => 'ಕಾರಣ (ಡ್ರೈವರ್ ಇದನ್ನು ನೋಡುತ್ತಾರೆ)';

  @override
  String get documentApproved => 'ದಾಖಲೆ ಅನುಮೋದಿಸಲಾಗಿದೆ';

  @override
  String get kindDocSubmitted => 'ಅನುಮೋದಿಸಬೇಕಾದ ದಾಖಲೆ';

  @override
  String alertDocSubmittedTitle({required String driver, required String doc}) {
    return '$driver ತಮ್ಮ $doc ಸೇರಿಸಿದ್ದಾರೆ';
  }

  @override
  String alertDocRenewedTitle({required String driver, required String doc}) {
    return '$driver ನವೀಕರಿಸಿದ $doc ಅಪ್‌ಲೋಡ್ ಮಾಡಿದ್ದಾರೆ';
  }

  @override
  String get alertDocSubmittedBody =>
      'ಅದನ್ನು ಪರಿಶೀಲಿಸಿ, ಅವರ ದಾಖಲೆಗಳು ಟ್ಯಾಬ್‌ನಲ್ಲಿ ಅನುಮೋದಿಸಿ ಅಥವಾ ತಿರಸ್ಕರಿಸಿ.';

  @override
  String get navHome => 'ಮುಖಪುಟ';

  @override
  String get navMyDocuments => 'ದಾಖಲೆಗಳು';

  @override
  String get navProfile => 'ಪ್ರೊಫೈಲ್';

  @override
  String get assignedTab => 'ನೀಡಿರುವವು';

  @override
  String get pastTab => 'ಹಿಂದಿನವು';

  @override
  String get noAssignedTrips => 'ಈಗ ನಿಮಗೆ ಯಾವುದೇ ಟ್ರಿಪ್ ನೀಡಿಲ್ಲ.';

  @override
  String get noPastTrips => 'ಈ ತಿಂಗಳು ಯಾವುದೇ ಟ್ರಿಪ್ ಇಲ್ಲ.';

  @override
  String get myDocumentsIntro =>
      'ನಿಮ್ಮ ಲೈಸೆನ್ಸ್, ಆಧಾರ್ ಮತ್ತು ಇತರ ಕಾಗದಪತ್ರಗಳನ್ನು ಸೇರಿಸಿ. ಪ್ರತಿಯೊಂದನ್ನೂ ನಿಮ್ಮ ಫ್ಲೀಟ್ ಮಾಲೀಕರು ಪರಿಶೀಲಿಸಿದ ನಂತರವೇ ಅದು ಮಾನ್ಯವಾಗುತ್ತದೆ.';

  @override
  String get profileTitle => 'ಪ್ರೊಫೈಲ್';

  @override
  String get editName => 'ಹೆಸರು ಬದಲಿಸಿ';

  @override
  String get yourName => 'ನಿಮ್ಮ ಹೆಸರು';

  @override
  String get nameSaved => 'ಹೆಸರು ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get fleetLabel => 'ಫ್ಲೀಟ್';

  @override
  String get phoneNumberLabel => 'ಮೊಬೈಲ್ ನಂಬರ್';

  @override
  String get cabsYouDrive => 'ನೀವು ಓಡಿಸಬಹುದಾದ ಕ್ಯಾಬ್‌ಗಳು';

  @override
  String get noCabsLinked =>
      'ಇನ್ನೂ ಯಾವುದೇ ಕ್ಯಾಬ್ ಲಿಂಕ್ ಆಗಿಲ್ಲ. ನಿಮ್ಮ ಫ್ಲೀಟ್ ಮಾಲೀಕರನ್ನು ಕೇಳಿ.';

  @override
  String driverSince({required String date}) {
    return '$date ರಿಂದ ಡ್ರೈವರ್';
  }

  @override
  String get when => 'ಯಾವಾಗ';

  @override
  String confirmUpload({required int count}) {
    return 'ಅಪ್‌ಲೋಡ್ ಖಚಿತಪಡಿಸಿ ($count)';
  }

  @override
  String get fileReadyToUpload => 'ಆಯ್ಕೆ ಮಾಡಲಾಗಿದೆ · ಇನ್ನೂ ಅಪ್‌ಲೋಡ್ ಆಗಿಲ್ಲ';

  @override
  String get fileUploading => 'ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ…';

  @override
  String get fileUploaded => 'ಅಪ್‌ಲೋಡ್ ಆಗಿದೆ';

  @override
  String get fileUploadFailed => 'ಅಪ್‌ಲೋಡ್ ವಿಫಲವಾಗಿದೆ · ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ';

  @override
  String get uploadFilesFirst =>
      'ಆಯ್ಕೆ ಮಾಡಿದ ಫೈಲ್‌ಗಳನ್ನು ಮೊದಲು ಅಪ್‌ಲೋಡ್ ಮಾಡಲು \'ಅಪ್‌ಲೋಡ್ ಖಚಿತಪಡಿಸಿ\' ಒತ್ತಿ.';

  @override
  String filesUploadedCount({required int count}) {
    return '$count ಫೈಲ್‌ಗಳು ಅಪ್‌ಲೋಡ್ ಆಗಿವೆ';
  }

  @override
  String get colFiles => 'ಫೈಲ್‌ಗಳು';

  @override
  String get noFiles => 'ಫೈಲ್‌ಗಳಿಲ್ಲ';

  @override
  String get fixHighlighted => 'ಹೈಲೈಟ್ ಮಾಡಿದ ಜಾಗಗಳನ್ನು ತುಂಬಿಸಿ.';

  @override
  String get documentSentForApproval =>
      'ದಾಖಲೆ ಸೇರಿಸಲಾಗಿದೆ. ನಿಮ್ಮ ಫ್ಲೀಟ್ ಮಾಲೀಕರು ಅದನ್ನು ಅನುಮೋದಿಸುತ್ತಾರೆ.';

  @override
  String get documentSaved => 'ದಾಖಲೆ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String uploadAndSave({required int count}) {
    return '$count ಫೈಲ್‌ಗಳನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ ಉಳಿಸಿ';
  }

  @override
  String get photoMustBeImage => 'ಒಂದು ಫೋಟೋ ಆಯ್ಕೆಮಾಡಿ (JPG, PNG ಅಥವಾ WebP).';

  @override
  String get invalidEmail => 'ಸರಿಯಾದ ಇಮೇಲ್ ವಿಳಾಸ ನಮೂದಿಸಿ';

  @override
  String get invalidMobile => '10 ಅಂಕಿಯ ಮೊಬೈಲ್ ನಂಬರ್ ನಮೂದಿಸಿ';

  @override
  String get dateOfBirth => 'ಹುಟ್ಟಿದ ದಿನಾಂಕ';

  @override
  String get emailLabel => 'ಇಮೇಲ್';

  @override
  String get addressLabel => 'ವಿಳಾಸ';

  @override
  String get emergencyContact => 'ತುರ್ತು ಸಂಪರ್ಕ';

  @override
  String get contactName => 'ಸಂಪರ್ಕದ ಹೆಸರು';

  @override
  String get contactPhone => 'ಸಂಪರ್ಕದ ಮೊಬೈಲ್ ನಂಬರ್';

  @override
  String get editProfile => 'ಪ್ರೊಫೈಲ್ ಬದಲಿಸಿ';

  @override
  String get editDetails => 'ವಿವರಗಳನ್ನು ಬದಲಿಸಿ';

  @override
  String get choosePhoto => 'ಫೋಟೋ ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get changePhone => 'ಮೊಬೈಲ್ ನಂಬರ್ ಬದಲಿಸಿ';

  @override
  String get changePhoneIntro =>
      'ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್‌ನಿಂದಲೇ ನೀವು ಲಾಗಿನ್ ಆಗುತ್ತೀರಿ. ಅದು ನಿಮ್ಮದೇ ಎಂದು ಪರಿಶೀಲಿಸಲು ಹೊಸ ನಂಬರ್‌ಗೆ ಕೋಡ್ ಕಳುಹಿಸುತ್ತೇವೆ.';

  @override
  String codeSentTo({required String phone}) {
    return '$phone ಗೆ ಕಳುಹಿಸಿದ 6 ಅಂಕಿಯ ಕೋಡ್ ನಮೂದಿಸಿ';
  }

  @override
  String get verifyAndChange => 'ಪರಿಶೀಲಿಸಿ ಬದಲಿಸಿ';

  @override
  String get phoneChanged => 'ಮೊಬೈಲ್ ನಂಬರ್ ಬದಲಾಗಿದೆ';

  @override
  String get profileSaved => 'ಪ್ರೊಫೈಲ್ ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get personalDetails => 'ವೈಯಕ್ತಿಕ ವಿವರಗಳು';

  @override
  String get discardDocumentTitle => 'ಈ ದಾಖಲೆಯನ್ನು ಬಿಟ್ಟುಬಿಡಬೇಕೇ?';

  @override
  String get discardDocumentBody =>
      'ಇದನ್ನು ಉಳಿಸಿಲ್ಲ. ನೀವು ಸೇರಿಸಿದ ಫೈಲ್‌ಗಳು ಮತ್ತು ವಿವರಗಳು ಕಳೆದುಹೋಗುತ್ತವೆ.';

  @override
  String get keepEditing => 'ಬದಲಿಸುವುದನ್ನು ಮುಂದುವರಿಸಿ';

  @override
  String get discard => 'ಬಿಟ್ಟುಬಿಡಿ';

  @override
  String uploadingStep({required int n, required int count}) {
    return '$count ರಲ್ಲಿ $n ಅಪ್‌ಲೋಡ್ ಆಗುತ್ತಿದೆ…';
  }

  @override
  String get savingStep => 'ಉಳಿಸಲಾಗುತ್ತಿದೆ…';

  @override
  String get welcomeSignIn => 'ಸೈನ್ ಇನ್';

  @override
  String get welcomeGetStarted => 'ಶುರು ಮಾಡಿ';

  @override
  String get welcomeHaveAccount => 'ನನಗೆ ಖಾತೆ ಇದೆ';

  @override
  String get welcomeAbout => 'ಫ್ಲೀಟ್ ಸಾರಥಿ ಎಂದರೇನು?';

  @override
  String get welcomeEyebrow =>
      'ಮಾಲೀಕ-ಡ್ರೈವರ್‌ಗಳು ಮತ್ತು 2–15 ಕಾರುಗಳ ಫ್ಲೀಟ್‌ಗಳಿಗಾಗಿ';

  @override
  String get welcomeHeadlineLead => 'ಇಂದು ನಿಮ್ಮ ಕಾರುಗಳು';

  @override
  String get welcomeHeadlineAccent => 'ನಿಜವಾಗಿ ಏನು ಮಾಡಿದವು ಎಂದು ತಿಳಿಯಿರಿ.';

  @override
  String get welcomeSubhead =>
      'ಫೋಟೋ ಪುರಾವೆಯಿರುವ ಟ್ರಿಪ್‌ಗಳು, ಪ್ರತಿ ಕಾರಿನ ಸ್ವಂತ ಮೈಲೇಜ್‌ಗೆ ಹೋಲಿಸಿ ಇಂಧನ ಪರಿಶೀಲನೆ, GPS ದೂರ ಪರಿಶೀಲನೆ ಮತ್ತು ಪ್ರತಿ ಡ್ರೈವರ್‌ಗೆ ದಿನದ ನಗದು ಸೆಟಲ್‌ಮೆಂಟ್. ನಿಮಗೂ ನಿಮ್ಮ ಡ್ರೈವರ್‌ಗಳಿಗೂ ಒಂದೇ ಆ್ಯಪ್.';

  @override
  String get welcomeTrustOffline => 'ಆಫ್‌ಲೈನ್‌ನಲ್ಲೂ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String get welcomeTrustPlatforms => 'Android, iPhone ಮತ್ತು ವೆಬ್';

  @override
  String get welcomeTrustLanguages => 'ಕನ್ನಡ, English, हिन्दी, मराठी';

  @override
  String get welcomeTrustNoCard => 'ಕಾರ್ಡ್ ಬೇಕಿಲ್ಲ';

  @override
  String get welcomeMockToday => 'ಇಂದು';

  @override
  String get welcomeMockLive => 'ಲೈವ್';

  @override
  String get welcomeMockTrips => 'ಟ್ರಿಪ್‌ಗಳು';

  @override
  String get welcomeMockKm => 'ಓಡಿಸಿದ km';

  @override
  String get welcomeMockCash => 'ಬಾಕಿ ನಗದು';

  @override
  String get welcomeMockMileage => 'ಮೈಲೇಜ್, ಕೊನೆಯ 8 ಫಿಲ್‌ಗಳು';

  @override
  String get welcomeMockFuelTitle => 'ಇಂಧನ ಪರಿಶೀಲನೆ';

  @override
  String get welcomeMockFuelBody =>
      'MH 12 AB 4521 9.1 km/l ಕೊಟ್ಟಿದೆ, ಅದರ ಸಾಮಾನ್ಯ 11.7 ಕ್ಕಿಂತ 22% ಕಡಿಮೆ';

  @override
  String get welcomeMockGpsTitle => 'ದೂರ ಪರಿಶೀಲಿಸಲಾಗಿದೆ';

  @override
  String get welcomeMockGpsBody => 'ಪುಣೆ → ಮುಂಬೈ: GPS 148 km, ಓಡೋಮೀಟರ್ 151 km';

  @override
  String get welcomeMockSettleTitle => 'ರಮೇಶ್ · ಇಂದು ಸೆಟಲ್ ಮಾಡಿ';

  @override
  String get welcomeMockSettleBody => 'ಬಾಡಿಗೆ ₹4,200 − ಖರ್ಚು ₹640';

  @override
  String get welcomeBuiltFor => 'ಯಾರಿಗಾಗಿ';

  @override
  String get welcomeForDco => 'ಮಾಲೀಕ-ಡ್ರೈವರ್‌ಗಳು (DCO)';

  @override
  String get welcomeForSmallFleets => '2–15 ಕಾರುಗಳ ಫ್ಲೀಟ್‌ಗಳು';

  @override
  String get welcomeForIntercity => 'ಇಂಟರ್‌ಸಿಟಿ ಮತ್ತು ಔಟ್‌ಸ್ಟೇಷನ್';

  @override
  String get welcomeForLocal => 'ಲೋಕಲ್ ಮತ್ತು ಏರ್‌ಪೋರ್ಟ್ ಟ್ರಿಪ್‌ಗಳು';

  @override
  String get welcomeFeaturesKicker => 'ಎಲ್ಲವೂ ಒಂದೇ ಆ್ಯಪ್‌ನಲ್ಲಿ';

  @override
  String get welcomeFeaturesTitle =>
      'ಭಾರತದ ಕ್ಯಾಬ್ ಫ್ಲೀಟ್‌ಗಳು ನಿಜವಾಗಿ ನಡೆಯುವ ರೀತಿಗೆ ತಕ್ಕಂತೆ';

  @override
  String get welcomeFeatureFuelTitle => 'ಇಂಧನ ಆಡಿಟ್';

  @override
  String get welcomeFeatureFuelBody =>
      'ಪ್ರತಿ ಕಾರಿನ ಮೈಲೇಜ್ ಅದರದೇ ಬೇಸ್‌ಲೈನ್‌ಗೆ ಹೋಲಿಸಿ, ಅಥವಾ ಪೆಟ್ರೋಲ್ + CNG ಕಾರುಗಳಿಗೆ ಪ್ರತಿ km ಖರ್ಚು.';

  @override
  String get welcomeFeatureTripsTitle => 'ಪುರಾವೆಯಿರುವ ಟ್ರಿಪ್‌ಗಳು';

  @override
  String get welcomeFeatureTripsBody =>
      'ಟ್ರಿಪ್‌ಗಳನ್ನು ರಚಿಸಿ ಮತ್ತು ನೀಡಿ, ನಂತರ ಓಡೋಮೀಟರ್ ಫೋಟೋಗಳು ಮತ್ತು ನಕ್ಷೆಯಲ್ಲಿ GPS ಮಾರ್ಗ ನೋಡಿ.';

  @override
  String get welcomeFeatureSettleTitle => 'ದಿನದ ಸೆಟಲ್‌ಮೆಂಟ್';

  @override
  String get welcomeFeatureSettleBody =>
      'ಬಾಡಿಗೆ, ನಗದು, ಆನ್‌ಲೈನ್ ಪಾವತಿಗಳು, ಖರ್ಚುಗಳು ಮತ್ತು ನಿಮ್ಮ ಸಂಬಳ ನಿಯಮಗಳು, ಎಲ್ಲವೂ ಸೇರಿ ಒಂದೇ ನಿವ್ವಳ ಮೊತ್ತ.';

  @override
  String get welcomeFeatureDocsTitle => 'ದಾಖಲೆ ರಿಮೈಂಡರ್‌ಗಳು';

  @override
  String get welcomeFeatureDocsBody =>
      'RC, ಇನ್ಶೂರೆನ್ಸ್, ಪರ್ಮಿಟ್, PUC ಮತ್ತು ಲೈಸೆನ್ಸ್: ಅವಧಿ ಮುಗಿಯುವ 30, 7 ಮತ್ತು 1 ದಿನ ಮೊದಲು ಅಲರ್ಟ್.';

  @override
  String get welcomeFeatureOfflineTitle => 'ಸಿಗ್ನಲ್ ಇಲ್ಲದೆಯೂ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String get welcomeFeatureOfflineBody =>
      'ಘಾಟ್ ರಸ್ತೆಗಳಲ್ಲೂ ಹೈವೇಗಳಲ್ಲೂ ಡ್ರೈವರ್ ಆ್ಯಪ್ ದಾಖಲಿಸುತ್ತಲೇ ಇರುತ್ತದೆ, ನೆಟ್‌ವರ್ಕ್ ಬಂದಾಗ ಸಿಂಕ್ ಆಗುತ್ತದೆ.';

  @override
  String get welcomeFeatureDcoTitle => 'ಮಾಲೀಕರೂ ಆಗಿ, ಓಡಿಸಿಯೂ';

  @override
  String get welcomeFeatureDcoBody =>
      'ಒಂದೇ ಖಾತೆಯಿಂದ ನಿಮ್ಮ ಫ್ಲೀಟ್ ನಡೆಸಿ ಮತ್ತು ಬೇರೆಯವರ ಫ್ಲೀಟ್‌ನಲ್ಲಿ ಓಡಿಸಿ. ಒಂದೇ ಟ್ಯಾಪ್‌ನಲ್ಲಿ ಬದಲಿಸಿ.';

  @override
  String get welcomeStepsKicker => 'ಇದು ಹೇಗೆ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String get welcomeStepsTitle => 'ನಿಮ್ಮ ಮುಂದಿನ ಟ್ರಿಪ್‌ಗೂ ಮೊದಲೇ ಸಿದ್ಧ';

  @override
  String get welcomeStep1Title => 'ನಿಮ್ಮ ಕಾರುಗಳು ಮತ್ತು ಡ್ರೈವರ್‌ಗಳನ್ನು ಸೇರಿಸಿ';

  @override
  String get welcomeStep1Body =>
      'ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್‌ನಿಂದ ಸೈನ್ ಅಪ್ ಮಾಡಿ, ವಾಹನಗಳನ್ನು ಸೇರಿಸಿ ಮತ್ತು ಡ್ರೈವರ್‌ಗಳನ್ನು ಅವರ ನಂಬರ್‌ನಿಂದ ಸೇರಿಸಿ.';

  @override
  String get welcomeStep2Title => 'ಡ್ರೈವರ್‌ಗಳು ತಮ್ಮ ಫೋನ್‌ನಿಂದ ದಾಖಲಿಸುತ್ತಾರೆ';

  @override
  String get welcomeStep2Body =>
      'ಮೀಟರ್ ಫೋಟೋದೊಂದಿಗೆ ಟ್ರಿಪ್ ಶುರು ಮತ್ತು ಮುಗಿಸಿ, ರಸೀದಿಯೊಂದಿಗೆ ಇಂಧನ ದಾಖಲಿಸಿ, ಟೋಲ್ ಮತ್ತು ನಗದು ಸೇರಿಸಿ.';

  @override
  String get welcomeStep3Title => 'ನಿಮಗೆ ಪ್ರತಿದಿನ ಸತ್ಯ ಕಾಣುತ್ತದೆ';

  @override
  String get welcomeStep3Body =>
      'ಏನಾದರೂ ಸರಿಯಿಲ್ಲ ಎನಿಸಿದಾಗ ಅಲರ್ಟ್, ಮತ್ತು ದಿನದ ಕೊನೆಯಲ್ಲಿ ಪ್ರತಿ ಡ್ರೈವರ್‌ಗೆ ಸೆಟಲ್‌ಮೆಂಟ್.';

  @override
  String get welcomeOwnersTitle => 'ಮಾಲೀಕರಿಗಾಗಿ';

  @override
  String get welcomeOwners1 =>
      'ಪ್ರತಿ ಕಾರು ಮತ್ತು ಡ್ರೈವರ್ ಒಂದೇ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ನಲ್ಲಿ';

  @override
  String get welcomeOwners2 =>
      'ರದ್ದತಿಗಳನ್ನು ಅನುಮೋದಿಸಿ, ಫ್ಲ್ಯಾಗ್ ಆದ ಟ್ರಿಪ್‌ಗಳನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String get welcomeOwners3 =>
      'ಸಂಬಳ ನಿಯಮಗಳನ್ನು ಒಮ್ಮೆ ಹೊಂದಿಸಿ; ಸೆಟಲ್‌ಮೆಂಟ್‌ಗಳು ಅವನ್ನೇ ಅನುಸರಿಸುತ್ತವೆ';

  @override
  String get welcomeOwners4 => 'ನಿಮ್ಮ ಫೋನ್‌ ಅಥವಾ ಲ್ಯಾಪ್‌ಟಾಪ್‌ನಲ್ಲಿ ಬಳಸಿ';

  @override
  String get welcomeDriversTitle => 'ಡ್ರೈವರ್‌ಗಳಿಗಾಗಿ';

  @override
  String get welcomeDrivers1 =>
      'ಕನ್ನಡ, English, ಹಿಂದಿ ಅಥವಾ ಮರಾಠಿಯಲ್ಲಿ ಸರಳ ಸ್ಕ್ರೀನ್‌ಗಳು';

  @override
  String get welcomeDrivers2 =>
      'ಇಂದಿನ ಟ್ರಿಪ್‌ಗಳು ಕ್ರಮವಾಗಿ, ಶುರು ಮಾಡಲು ಒಂದೇ ಟ್ಯಾಪ್';

  @override
  String get welcomeDrivers3 => 'ನೆಟ್‌ವರ್ಕ್ ಹೋದರೂ ಏನೂ ಕಳೆದುಹೋಗುವುದಿಲ್ಲ';

  @override
  String get welcomeDrivers4 => 'ಲೈಸೆನ್ಸ್ ಮತ್ತು ದಾಖಲೆಗಳು ಯಾವಾಗಲೂ ಅಪ್‌ಡೇಟ್';

  @override
  String get welcomeFaqTitle => 'ಮಾಲೀಕರು ಕೇಳುವ ಪ್ರಶ್ನೆಗಳು';

  @override
  String get welcomeFaqOfflineQ => 'ನನ್ನ ಡ್ರೈವರ್‌ಗಳಿಗೆ ಯಾವಾಗಲೂ ಇಂಟರ್ನೆಟ್ ಬೇಕೇ?';

  @override
  String get welcomeFaqOfflineA =>
      'ಬೇಡ. ಡ್ರೈವರ್ ಆ್ಯಪ್ ಎಲ್ಲವನ್ನೂ ಫೋನ್‌ನಲ್ಲೇ ಉಳಿಸುತ್ತದೆ ಮತ್ತು ನೆಟ್‌ವರ್ಕ್ ಬಂದಾಗ ಕ್ರಮವಾಗಿ ಕಳುಹಿಸುತ್ತದೆ.';

  @override
  String get welcomeFaqDcoQ =>
      'ನನ್ನ ಸ್ವಂತ ಕಾರನ್ನು ನಾನೇ ಓಡಿಸಿದರೆ ಇದನ್ನು ಬಳಸಬಹುದೇ?';

  @override
  String get welcomeFaqDcoA =>
      'ಹೌದು. ಮಾಲೀಕ-ಡ್ರೈವರ್‌ಗಳಿಗೆ ಮಾಲೀಕರ ಸ್ಕ್ರೀನ್‌ಗಳು ಮತ್ತು ಡ್ರೈವರ್ ಸ್ಕ್ರೀನ್‌ಗಳು ಎರಡೂ ಸಿಗುತ್ತವೆ, ಅವುಗಳ ನಡುವೆ ಬದಲಿಸಬಹುದು.';

  @override
  String get welcomeFaqPrivacyQ => 'ನನ್ನ ಫ್ಲೀಟ್‌ನ ಡೇಟಾ ಖಾಸಗಿಯಾಗಿದೆಯೇ?';

  @override
  String get welcomeFaqPrivacyA =>
      'ಹೌದು. ಪ್ರತಿ ಫ್ಲೀಟ್‌ನ ಡೇಟಾವನ್ನು ಡೇಟಾಬೇಸ್ ಮಟ್ಟದವರೆಗೂ ಪ್ರತ್ಯೇಕವಾಗಿ ಇಡಲಾಗುತ್ತದೆ, ಮತ್ತು ನೀವು ಸೇರಿಸಿದವರು ಮಾತ್ರ ಅದನ್ನು ನೋಡಬಹುದು.';

  @override
  String get welcomeFaqPhoneQ => 'ಡ್ರೈವರ್‌ಗೆ ಯಾವ ಫೋನ್ ಬೇಕು?';

  @override
  String get welcomeFaqPhoneA =>
      'ಕ್ಯಾಮೆರಾ ಇರುವ ಯಾವುದೇ Android ಫೋನ್ ಅಥವಾ iPhone (iOS 14 ಅಥವಾ ಹೊಸದು). ಮಾಲೀಕರು ಫ್ಲೀಟ್ ಸಾರಥಿಯನ್ನು ವೆಬ್ ಬ್ರೌಸರ್‌ನಲ್ಲೂ ಬಳಸಬಹುದು.';

  @override
  String get welcomeFaqLanguageQ => 'ಇದು ನನ್ನ ಭಾಷೆಯಲ್ಲಿ ಇದೆಯೇ?';

  @override
  String get welcomeFaqLanguageA =>
      'ಹೌದು. ಪ್ರತಿ ಸ್ಕ್ರೀನ್ ಕನ್ನಡ, English, ಹಿಂದಿ ಮತ್ತು ಮರಾಠಿಯಲ್ಲಿ ಇದೆ; ಮೇಲಿನಿಂದ ಯಾವಾಗ ಬೇಕಾದರೂ ಭಾಷೆ ಬದಲಿಸಿ.';

  @override
  String get welcomeFinalTitle => 'ಊಹಿಸುವುದನ್ನು ನಿಲ್ಲಿಸಿ. ನಿಜ ತಿಳಿಯಿರಿ.';

  @override
  String get welcomeFinalBody =>
      'ಕೇವಲ ನಿಮ್ಮ ಮೊಬೈಲ್ ನಂಬರ್‌ನಿಂದ ಕೆಲವೇ ನಿಮಿಷಗಳಲ್ಲಿ ನಿಮ್ಮ ಫ್ಲೀಟ್ ಸಿದ್ಧಪಡಿಸಿ.';

  @override
  String get loginTagline => 'ಪ್ರತಿ ಕಿಲೋಮೀಟರ್‌ಗೂ ಲೆಕ್ಕ.';

  @override
  String get loginAboutCompany =>
      'ಭಾರತದಾದ್ಯಂತ ಮಾಲೀಕ-ಡ್ರೈವರ್‌ಗಳು ಮತ್ತು ಸಣ್ಣ ಫ್ಲೀಟ್‌ಗಳಿಗೆ ಫ್ಲೀಟ್ ಆಡಿಟ್ ಮತ್ತು ಕ್ಯಾಬ್ ನಿರ್ವಹಣೆ.';

  @override
  String get welcomeFooter =>
      'ಭಾರತದಲ್ಲಿ ತಯಾರಾಗಿದೆ, ಭಾರತದ ಕ್ಯಾಬ್ ಫ್ಲೀಟ್‌ಗಳಿಗಾಗಿ.';

  @override
  String get welcomeShowcaseKicker => 'ಕೆಲಸದಲ್ಲಿ ನೋಡಿ';

  @override
  String get welcomeShowcaseTitle =>
      'ನೀವು ಪ್ರತಿದಿನ ಎದುರಿಸುವ ಸಮಸ್ಯೆಗಳಿಗೆ ಒಂದೇ ಆ್ಯಪ್';

  @override
  String get welcomeShowcaseSubtitle =>
      'ನೀವು ಕಾರಿನಲ್ಲಿ ಇಲ್ಲದಾಗ, ನೋಟ್‌ಬುಕ್ ಮತ್ತು WhatsApp ಮೆಸೇಜ್‌ಗಳನ್ನೇ ನಂಬಬೇಕಾಗುತ್ತದೆ. ಏನು ಬದಲಾಗುತ್ತದೆ ಎಂದು ಇಲ್ಲಿ ನೋಡಿ.';

  @override
  String get welcomeTabFuel => 'ಇಂಧನ';

  @override
  String get welcomeTabSettlement => 'ಸೆಟಲ್‌ಮೆಂಟ್';

  @override
  String get welcomeTabDocuments => 'ದಾಖಲೆಗಳು';

  @override
  String get welcomeTabOffline => 'ಆಫ್‌ಲೈನ್';

  @override
  String get welcomeUcFuelTitle => 'ಪಂಪ್ ಬಳಿ ನಿಲ್ಲದೆ ಇಂಧನ ಕಳ್ಳತನ ಹಿಡಿಯಿರಿ';

  @override
  String get welcomeUcFuelBody =>
      'ಡ್ರೈವರ್‌ಗಳು ರಸೀದಿಯ ಫೋಟೋ ತೆಗೆದು, ಫುಲ್ ಟ್ಯಾಂಕ್ ಫಿಲ್‌ಗಳನ್ನು ಗುರುತಿಸುತ್ತಾರೆ. ಫ್ಲೀಟ್ ಸಾರಥಿ ಪ್ರತಿ ಕಾರಿನ ಸ್ವಂತ ಮೈಲೇಜ್ ಅನ್ನು ಪ್ರತಿ ಸೈಕಲ್‌ಗೆ ಲೆಕ್ಕ ಹಾಕುತ್ತದೆ, ಮತ್ತು ಅದು ಕಡಿಮೆಯಾದ ತಕ್ಷಣ ನಿಮಗೆ ತಿಳಿಸುತ್ತದೆ.';

  @override
  String get welcomeUcFuelPoint1 =>
      'ಪ್ರತಿ ಕಾರಿಗೂ ಅದರದೇ ಬೇಸ್‌ಲೈನ್, ಬ್ರೋಷರ್ ಅಂಕಿ ಅಲ್ಲ';

  @override
  String get welcomeUcFuelPoint2 => 'ಪೆಟ್ರೋಲ್ + CNG ಕಾರುಗಳಿಗೆ ಪ್ರತಿ km ಖರ್ಚು';

  @override
  String get welcomeUcFuelPoint3 =>
      'ಸರಳ ಮಾತಿನಲ್ಲಿ ಅಲರ್ಟ್, ಅರ್ಥ ಮಾಡಿಕೊಳ್ಳಬೇಕಾದ ಚಾರ್ಟ್‌ಗಳಲ್ಲ';

  @override
  String get welcomeUcFuelThisCycle => 'ಈ ಸೈಕಲ್';

  @override
  String get welcomeUcFuelUsual => 'ಸಾಮಾನ್ಯ';

  @override
  String get welcomeUcTripsTitle => 'ಪ್ರತಿ ಕಿಲೋಮೀಟರ್‌ಗೂ ಫೋಟೋ ಮತ್ತು GPS ಪುರಾವೆ';

  @override
  String get welcomeUcTripsBody =>
      'ಡ್ರೈವರ್‌ಗಳು ಪ್ರತಿ ಟ್ರಿಪ್ ಅನ್ನು ಓಡೋಮೀಟರ್ ಫೋಟೋದೊಂದಿಗೆ ಶುರು ಮಾಡಿ ಮುಗಿಸುತ್ತಾರೆ. ರೀಡಿಂಗ್ ಅನ್ನು ಫೋಟೋ ಮತ್ತು GPS ಮಾರ್ಗದೊಂದಿಗೆ ಹೋಲಿಸಲಾಗುತ್ತದೆ, ಹೊಂದಾಣಿಕೆಯಾಗದ್ದು ನಿಮ್ಮ ಪರಿಶೀಲನೆಗೆ ಕಾಯುತ್ತದೆ.';

  @override
  String get welcomeUcTripsPoint1 => 'ಶುರು ಮತ್ತು ಕೊನೆಯಲ್ಲಿ ಮೀಟರ್ ಫೋಟೋಗಳು';

  @override
  String get welcomeUcTripsPoint2 => 'ಪ್ರತಿ ಟ್ರಿಪ್‌ಗೂ ನಕ್ಷೆಯಲ್ಲಿ ಮಾರ್ಗ';

  @override
  String get welcomeUcTripsPoint3 =>
      'ಹೊಂದಾಣಿಕೆಯಾಗದವು ನಿಮ್ಮ ಪರಿಶೀಲನಾ ಪಟ್ಟಿಗೆ ಹೋಗುತ್ತವೆ';

  @override
  String get welcomeUcTripStart => 'ಶುರು';

  @override
  String get welcomeUcTripEnd => 'ಕೊನೆ';

  @override
  String get welcomeUcTripRoute => 'ಪುಣೆ → ಮುಂಬೈ';

  @override
  String get welcomeUcTripDriver => 'ರಮೇಶ್ · MH 12 AB 4521';

  @override
  String get welcomeUcTripCheck => 'GPS 148 km · ಓಡೋಮೀಟರ್ 151 km';

  @override
  String get welcomeUcSettleTitle =>
      'ಪ್ರತಿ ಡ್ರೈವರ್‌ನ ದಿನವನ್ನು ಒಂದೇ ಅಂಕಿಯಲ್ಲಿ ಸೆಟಲ್ ಮಾಡಿ';

  @override
  String get welcomeUcSettleBody =>
      'ಬಾಡಿಗೆ, ನಗದು, UPI ಮತ್ತು ಕಾರ್ಡ್ ಸಂಗ್ರಹ, ಟೋಲ್ ಮತ್ತು ಪಾರ್ಕಿಂಗ್, ಮತ್ತು ನಿಮ್ಮ ಸಂಬಳ ನಿಯಮ ಸೇರಿ ಒಂದೇ ಮೊತ್ತ: ಡ್ರೈವರ್ ಕೊಡಬೇಕಾದದ್ದು, ಅಥವಾ ನೀವು ಅವರಿಗೆ ಕೊಡಬೇಕಾದದ್ದು.';

  @override
  String get welcomeUcSettlePoint1 =>
      'ಪ್ರತಿ ಡ್ರೈವರ್‌ಗೆ ಸಂಬಳ ನಿಯಮ ಒಮ್ಮೆ ಹೊಂದಿಸಿ';

  @override
  String get welcomeUcSettlePoint2 => 'ನಗದು ಮತ್ತು ಆನ್‌ಲೈನ್ ಹಣ ಬೇರೆ ಬೇರೆ';

  @override
  String get welcomeUcSettlePoint3 => 'ರಸೀದಿಯೊಂದಿಗೆ ಟೋಲ್ ಮತ್ತು ಪಾರ್ಕಿಂಗ್';

  @override
  String get welcomeUcSettleHeader => 'ರಮೇಶ್ · ಇಂದು';

  @override
  String get welcomeUcSettleFare => 'ಬಾಡಿಗೆ';

  @override
  String get welcomeUcSettleCash => 'ನಗದಿನಲ್ಲಿ ಸಂಗ್ರಹಿಸಿದ್ದು';

  @override
  String get welcomeUcSettleOnline =>
      'ಆನ್‌ಲೈನ್‌ನಲ್ಲಿ ಸಂಗ್ರಹಿಸಿದ್ದು (UPI, ಕಾರ್ಡ್)';

  @override
  String get welcomeUcSettleExpenses => 'ಕಟ್ಟಿದ ಟೋಲ್ ಮತ್ತು ಪಾರ್ಕಿಂಗ್';

  @override
  String get welcomeUcSettlePay => 'ಡ್ರೈವರ್ ಸಂಬಳ (ಬಾಡಿಗೆಯ 30%)';

  @override
  String get welcomeUcSettleNet => 'ರಮೇಶ್ ಕೊಡಬೇಕಾದದ್ದು';

  @override
  String get welcomeUcDocsTitle =>
      'ಅವಧಿ ಮುಗಿದ ಪರ್ಮಿಟ್‌ನೊಂದಿಗೆ ಎಂದಿಗೂ ಸಿಕ್ಕಿಬೀಳಬೇಡಿ';

  @override
  String get welcomeUcDocsBody =>
      'ಪ್ರತಿ ಕಾರು ಮತ್ತು ಡ್ರೈವರ್‌ನ RC, ಇನ್ಶೂರೆನ್ಸ್, ಪರ್ಮಿಟ್, PUC ಮತ್ತು ಡ್ರೈವಿಂಗ್ ಲೈಸೆನ್ಸ್ ಒಂದೇ ಕಡೆ, ಪ್ರತಿಯೊಂದರ ಅವಧಿ ಮುಗಿಯುವ 30, 7 ಮತ್ತು 1 ದಿನ ಮೊದಲು ರಿಮೈಂಡರ್.';

  @override
  String get welcomeUcDocsPoint1 => 'ಪ್ರತಿ ಕಾರು ಮತ್ತು ಪ್ರತಿ ಡ್ರೈವರ್';

  @override
  String get welcomeUcDocsPoint2 => 'ಫೋಟೋ ಅಥವಾ PDF ಅಪ್‌ಲೋಡ್ ಮಾಡಿ';

  @override
  String get welcomeUcDocsPoint3 => 'ಗಡುವಿನ ನಂತರವಲ್ಲ, ಮೊದಲೇ ನೆನಪಿಸಲಾಗುತ್ತದೆ';

  @override
  String get welcomeUcDocsHeader => 'ಶೀಘ್ರದಲ್ಲೇ ಅವಧಿ ಮುಗಿಯುತ್ತಿದೆ';

  @override
  String get welcomeUcDocsRow1 => 'MH 12 AB 4521 · ಇನ್ಶೂರೆನ್ಸ್';

  @override
  String get welcomeUcDocsDue1 => '7 ದಿನಗಳಲ್ಲಿ';

  @override
  String get welcomeUcDocsRow2 => 'ಸುರೇಶ್ · ಡ್ರೈವಿಂಗ್ ಲೈಸೆನ್ಸ್';

  @override
  String get welcomeUcDocsDue2 => 'ನಾಳೆ';

  @override
  String get welcomeUcDocsRow3 => 'MH 14 CD 7788 · ಪರ್ಮಿಟ್';

  @override
  String get welcomeUcDocsDue3 => '30 ದಿನಗಳಲ್ಲಿ';

  @override
  String get welcomeUcDocsRow4 => 'MH 12 AB 4521 · PUC';

  @override
  String get welcomeUcDocsDue4 => 'ಮಾನ್ಯ';

  @override
  String get welcomeUcOfflineTitle =>
      'ಹೈವೇ ಮತ್ತು ಘಾಟ್ ರಸ್ತೆಗಳಿಗಾಗಿ ತಯಾರಿಸಲಾಗಿದೆ';

  @override
  String get welcomeUcOfflineBody =>
      'ಸಿಗ್ನಲ್ ಇಲ್ಲವೇ? ಡ್ರೈವರ್ ಆ್ಯಪ್ ಟ್ರಿಪ್‌ಗಳು, ಇಂಧನ ಮತ್ತು ಪಾವತಿಗಳನ್ನು ಫೋನ್‌ನಲ್ಲೇ ದಾಖಲಿಸುತ್ತಾ ಇರುತ್ತದೆ ಮತ್ತು ನೆಟ್‌ವರ್ಕ್ ಬಂದಾಗ ಕ್ರಮವಾಗಿ ಕಳುಹಿಸುತ್ತದೆ. ಏನೂ ಕಳೆದುಹೋಗುವುದಿಲ್ಲ, ಏನೂ ಎರಡು ಸಲ ಲೆಕ್ಕವಾಗುವುದಿಲ್ಲ.';

  @override
  String get welcomeUcOfflinePoint1 => 'ನೆಟ್‌ವರ್ಕ್ ಇಲ್ಲದೆಯೂ ಕೆಲಸ ಮಾಡುತ್ತದೆ';

  @override
  String get welcomeUcOfflinePoint2 => 'ತಾನಾಗಿಯೇ ಕ್ರಮವಾಗಿ ಸಿಂಕ್ ಆಗುತ್ತದೆ';

  @override
  String get welcomeUcOfflinePoint3 =>
      'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿದರೂ ಸುರಕ್ಷಿತ, ಎಂದಿಗೂ ಡಬಲ್ ಆಗುವುದಿಲ್ಲ';

  @override
  String get welcomeUcOfflineBanner =>
      'ನೆಟ್‌ವರ್ಕ್ ಇಲ್ಲ · ಈ ಫೋನ್‌ನಲ್ಲಿ ಉಳಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get welcomeUcOfflineTrip => 'ಟ್ರಿಪ್ ನಡೆಯುತ್ತಿದೆ · ಪುಣೆ → ಲೋನಾವಾಲಾ';

  @override
  String get welcomeUcOfflineFuel => 'ಇಂಧನ ಫಿಲ್ ಉಳಿಸಲಾಗಿದೆ · ₹2,150';

  @override
  String get welcomeUcOfflineCash => 'ನಗದು ಸಂಗ್ರಹಿಸಲಾಗಿದೆ · ₹1,200';

  @override
  String get welcomeUcOfflineWaiting => '3 ಬದಲಾವಣೆಗಳು ಸಿಂಕ್‌ಗೆ ಕಾಯುತ್ತಿವೆ';

  @override
  String percentFree({required int percent}) {
    return '$percent% ಖಾಲಿ';
  }

  @override
  String cabHoursFree({required String reg, required int hours}) {
    return '$reg: $hours ಗಂಟೆ ಖಾಲಿ';
  }

  @override
  String moreCabs({required int count}) {
    return '+$count ಇನ್ನಷ್ಟು';
  }

  @override
  String get welcomeMockCabsToday => 'ಇಂದಿನ ಕ್ಯಾಬ್‌ಗಳು';

  @override
  String get welcomeTabAvailability => 'ಲಭ್ಯತೆ';

  @override
  String get welcomeUcAvailTitle => 'ಯಾವ ಕ್ಯಾಬ್ ಖಾಲಿ ಇದೆ ಎಂದು ಗಂಟೆಗಂಟೆಗೆ ನೋಡಿ';

  @override
  String get welcomeUcAvailBody =>
      'ಪ್ರತಿ ಕ್ಯಾಬ್‌ನ ದಿನ ಒಂದೇ ಸಾಲಿನಲ್ಲಿ: ಖಾಲಿ ಇರುವಾಗ ಹಸಿರು, ಟ್ರಿಪ್‌ನಲ್ಲಿರುವಾಗ ಕೆಂಪು. ಗ್ರಾಹಕರಿಗೆ ಮಾತು ಕೊಡುವ ಮೊದಲೇ ಹೊಸ ಬುಕಿಂಗ್‌ಗೆ ಖಾಲಿ ಸಮಯ ಕಂಡುಕೊಳ್ಳಿ.';

  @override
  String get welcomeUcAvailPoint1 => 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ನಲ್ಲೇ, ಯಾವುದೇ ದಿನಕ್ಕೆ';

  @override
  String get welcomeUcAvailPoint2 =>
      'ರಾತ್ರಿಯಿಡೀ ನಡೆಯುವ ಟ್ರಿಪ್‌ಗಳೂ ಸರಿಯಾಗಿ ಲೆಕ್ಕ';

  @override
  String get welcomeUcAvailPoint3 => 'ನಿಮ್ಮ ಫ್ಲೀಟ್‌ನಲ್ಲಿ ಖಾಲಿ ಗಂಟೆಗಳ ಪಾಲು';

  @override
  String get welcomeUcAvailFreeNow => 'ಈಗ ಖಾಲಿ: 5 ರಲ್ಲಿ 2';

  @override
  String nSelected({required int count}) {
    return '$count ಆಯ್ಕೆಯಾಗಿವೆ';
  }

  @override
  String get dateRangeLabel => 'ದಿನಾಂಕಗಳು';

  @override
  String get rangeFrom => 'ಇಂದ';

  @override
  String get rangeTo => 'ವರೆಗೆ';

  @override
  String get thisMonth => 'ಈ ತಿಂಗಳು';

  @override
  String get thisWeek => 'ಈ ವಾರ';

  @override
  String get customRange => 'ಬೇಕಾದ ಅವಧಿ';

  @override
  String get kindTripUnassigned => 'ವಾಹನ ಅಥವಾ ಡ್ರೈವರ್ ಇಲ್ಲ';

  @override
  String alertTripUnassignedTitle({required String route}) {
    return '$route ಗೆ ಇನ್ನೂ ವಾಹನ ಅಥವಾ ಡ್ರೈವರ್ ಇಲ್ಲ';
  }

  @override
  String alertTripUnassignedBody({required String when}) {
    return 'ಇದು $when ಶುರುವಾಗುತ್ತದೆ. ಅದಕ್ಕೂ ಮೊದಲು ವಾಹನ ಮತ್ತು ಡ್ರೈವರ್ ನೀಡಿ.';
  }

  @override
  String alertTripUnassignedOverdueBody({required String when}) {
    return 'ಇದು $when ಶುರುವಾಗಬೇಕಿತ್ತು, ಇನ್ನೂ ವಾಹನ ಅಥವಾ ಡ್ರೈವರ್ ಇಲ್ಲ. ಒಬ್ಬರನ್ನು ನೀಡಿ, ಅಥವಾ ಟ್ರಿಪ್ ರದ್ದುಮಾಡಿ.';
  }

  @override
  String docNumberLabel({required String doc}) {
    return '$doc ನಂಬರ್';
  }

  @override
  String docNumberHint({required String example}) {
    return 'ಉದಾ. $example';
  }

  @override
  String get docNumberMissing => 'ನಂಬರ್ ನಮೂದಿಸಿ';

  @override
  String docNumberFormat({required String example}) {
    return 'ಸರಿ ಕಾಣುತ್ತಿಲ್ಲ. ಇದು $example ತರಹ ಇರಬೇಕು';
  }

  @override
  String get aadhaarFormat =>
      '12 ಅಂಕಿಯ ಆಧಾರ್ ನಂಬರ್ ನಮೂದಿಸಿ (ಇದು 0 ಅಥವಾ 1 ರಿಂದ ಶುರುವಾಗುವುದಿಲ್ಲ)';

  @override
  String get aadhaarChecksum =>
      'ಇದು ಮಾನ್ಯವಾದ ಆಧಾರ್ ನಂಬರ್ ಅಲ್ಲ. ಅಂಕಿಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.';

  @override
  String get expiryBeforeStart => 'ಮಾನ್ಯತೆ ಶುರುವಾಗುವ ದಿನಾಂಕದ ನಂತರ ಇರಬೇಕು';

  @override
  String get errorDriverInactive =>
      'ಫ್ಲೀಟ್ ಮಾಲೀಕರು ನಿಷ್ಕ್ರಿಯ ಎಂದು ಗುರುತಿಸಿದ್ದಾರೆ: ಹೊಸ ಟ್ರಿಪ್‌ಗಳನ್ನು ರಚಿಸಲು ಅಥವಾ ನೀಡಲು ಆಗುವುದಿಲ್ಲ.';

  @override
  String get errorDriverHasTrips =>
      'ಡ್ರೈವರ್‌ಗೆ ಇನ್ನೂ ಟ್ರಿಪ್‌ಗಳು ನೀಡಲಾಗಿವೆ. ಮೊದಲು ಅವನ್ನು ತೆಗೆದುಹಾಕಿ.';

  @override
  String driverHasTripsTitle({required int count, required String name}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name ಗೆ $count ಮುಂದಿನ ಟ್ರಿಪ್‌ಗಳಿವೆ',
      one: '$name ಗೆ 1 ಮುಂದಿನ ಟ್ರಿಪ್ ಇದೆ',
    );
    return '$_temp0';
  }

  @override
  String get driverHasTripsBody =>
      'ಅವರನ್ನು ನಿಷ್ಕ್ರಿಯ ಎಂದು ಗುರುತಿಸಲು, ಮೊದಲು ಈ ಟ್ರಿಪ್‌ಗಳನ್ನು ಅವರಿಂದ ತೆಗೆದುಹಾಕಿ. ಅವು ನೀಡದ ಟ್ರಿಪ್‌ಗಳ ಪಟ್ಟಿಗೆ ಹಿಂತಿರುಗುತ್ತವೆ, ಆಗ ನೀವು ಅವನ್ನು ಬೇರೆ ಡ್ರೈವರ್‌ಗೆ ನೀಡಬಹುದು.';

  @override
  String get unassignAndDeactivate => 'ಟ್ರಿಪ್‌ಗಳನ್ನು ತೆಗೆದು ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಿ';

  @override
  String driverOnTripTitle({required String name}) {
    return '$name ಈಗ ಟ್ರಿಪ್‌ನಲ್ಲಿದ್ದಾರೆ';
  }

  @override
  String get driverOnTripBody =>
      'ಟ್ರಿಪ್ ಮುಗಿದ ನಂತರ ಅವರನ್ನು ನಿಷ್ಕ್ರಿಯ ಎಂದು ಗುರುತಿಸಿ.';

  @override
  String get driverInactiveBanner =>
      'ನಿಮ್ಮ ಫ್ಲೀಟ್ ಮಾಲೀಕರು ನಿಮ್ಮನ್ನು ನಿಷ್ಕ್ರಿಯ ಎಂದು ಗುರುತಿಸಿದ್ದಾರೆ. ನಿಮ್ಮ ಹಿಂದಿನ ಟ್ರಿಪ್‌ಗಳನ್ನು ನೋಡಬಹುದು, ಆದರೆ ಹೊಸದನ್ನು ರಚಿಸಲು ಆಗುವುದಿಲ್ಲ.';

  @override
  String get driverTripsTurnedOff =>
      'ನಿಮ್ಮ ಫ್ಲೀಟ್ ಮಾಲೀಕರು ಡ್ರೈವರ್ ಆ್ಯಪ್‌ನಿಂದ ಟ್ರಿಪ್ ರಚಿಸುವುದನ್ನು ಆಫ್ ಮಾಡಿದ್ದಾರೆ.';

  @override
  String get errorDriverTripsDisabled =>
      'ನಿಮ್ಮ ಫ್ಲೀಟ್ ಮಾಲೀಕರು ಡ್ರೈವರ್‌ಗಳು ರಚಿಸುವ ಟ್ರಿಪ್‌ಗಳನ್ನು ಆಫ್ ಮಾಡಿದ್ದಾರೆ.';

  @override
  String get errorDriverChargesDisabled =>
      'ನಿಮ್ಮ ಫ್ಲೀಟ್ ಮಾಲೀಕರು ಡ್ರೈವರ್‌ಗಳು ಸೇರಿಸುವ ಶುಲ್ಕಗಳನ್ನು ಆಫ್ ಮಾಡಿದ್ದಾರೆ.';

  @override
  String get errorReceiptRequired => 'ಇಂಧನ ರಸೀದಿಯ ಫೋಟೋ ಸೇರಿಸಿ.';

  @override
  String get settingsIntro =>
      'ನಿಮ್ಮ ಫ್ಲೀಟ್‌ಗೆ ಫ್ಲೀಟ್ ಸಾರಥಿ ಹೇಗೆ ಕೆಲಸ ಮಾಡಬೇಕು ಎಂದು ಆಯ್ಕೆಮಾಡಿ. ಪ್ರತಿ ಸೆಟ್ಟಿಂಗ್ ಏನನ್ನು ಬದಲಿಸುತ್ತದೆ ಮತ್ತು ಯಾವಾಗ ಜಾರಿಗೆ ಬರುತ್ತದೆ ಎಂದು ಪ್ರತಿ ಪುಟ ಹೇಳುತ್ತದೆ.';

  @override
  String get settingsGroupFleet => 'ನಿಮ್ಮ ಫ್ಲೀಟ್';

  @override
  String get settingsGroupYou => 'ನೀವು';

  @override
  String get settingsGeneral => 'ಸಾಮಾನ್ಯ';

  @override
  String get settingsGeneralDesc => 'ನಿಮ್ಮ ಫ್ಲೀಟ್‌ನ ಹೆಸರು';

  @override
  String get settingsTrips => 'ಟ್ರಿಪ್‌ಗಳು ಮತ್ತು ಡ್ರೈವರ್‌ಗಳು';

  @override
  String get settingsTripsDesc =>
      'ಡ್ರೈವರ್‌ಗಳು ಏನು ಮಾಡಬಹುದು, ಮತ್ತು ದೂರ ಪರಿಶೀಲನೆ';

  @override
  String get settingsFuel => 'ಇಂಧನ ಆಡಿಟ್';

  @override
  String get settingsFuelDesc => 'ರಸೀದಿಗಳು, ಮತ್ತು ಫಿಲ್ ಯಾವಾಗ ಫ್ಲ್ಯಾಗ್ ಆಗುತ್ತದೆ';

  @override
  String get settingsReminders => 'ದಾಖಲೆಗಳು ಮತ್ತು ರಿಮೈಂಡರ್‌ಗಳು';

  @override
  String get settingsRemindersDesc =>
      'ಕಾಗದಪತ್ರಗಳ ಅವಧಿ ಮುಗಿಯುವ ಮೊದಲು ಯಾವಾಗ ನೆನಪಿಸಬೇಕು';

  @override
  String get settingsPayDesc => 'ಸ್ವಂತ ನಿಯಮ ಇಲ್ಲದ ಡ್ರೈವರ್‌ಗಳ ಸಂಬಳ';

  @override
  String get settingsTeam => 'ತಂಡ ಮತ್ತು ಪಾತ್ರಗಳು';

  @override
  String get settingsTeamDesc =>
      'ಮ್ಯಾನೇಜರ್‌ಗಳು, ಮತ್ತು ಪ್ರತಿ ಪಾತ್ರ ಏನು ಮಾಡಬಹುದು';

  @override
  String get settingsLanguageDesc => 'ಈ ಸಾಧನದಲ್ಲಿ ಆ್ಯಪ್‌ನ ಭಾಷೆ';

  @override
  String get settingsSecurityDesc => 'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ಮತ್ತು ಮೊಬೈಲ್ ನಂಬರ್';

  @override
  String settingsAffects({required String area}) {
    return 'ಪರಿಣಾಮ: $area';
  }

  @override
  String settingsApplies({required String when}) {
    return 'ಯಾವಾಗ: $when';
  }

  @override
  String get settingsSaveChanges => 'ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ';

  @override
  String get settingsResetDefaults => 'ಡೀಫಾಲ್ಟ್‌ಗೆ ಮರುಹೊಂದಿಸಿ';

  @override
  String get settingsResetDone =>
      'ಡೀಫಾಲ್ಟ್‌ಗಳನ್ನು ತುಂಬಲಾಗಿದೆ. ಜಾರಿಗೊಳಿಸಲು ಉಳಿಸಿ.';

  @override
  String get settingsSaved => 'ಉಳಿಸಲಾಗಿದೆ.';

  @override
  String get settingsDiscardTitle => 'ನಿಮ್ಮ ಬದಲಾವಣೆಗಳನ್ನು ಬಿಟ್ಟುಬಿಡಬೇಕೇ?';

  @override
  String get settingsDiscardBody =>
      'ನೀವು ಈ ಪುಟದಲ್ಲಿ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಬದಲಿಸಿದ್ದೀರಿ ಆದರೆ ಉಳಿಸಿಲ್ಲ.';

  @override
  String get settingsUnsaved => 'ಉಳಿಸದ ಬದಲಾವಣೆಗಳು';

  @override
  String settingsDefaultIs({required String value}) {
    return 'ಡೀಫಾಲ್ಟ್: $value';
  }

  @override
  String get settingsOn => 'ಆನ್';

  @override
  String get settingsOff => 'ಆಫ್';

  @override
  String get fleetNameHelp =>
      'ಆ್ಯಪ್‌ನಲ್ಲಿ ನಿಮ್ಮ ಮ್ಯಾನೇಜರ್‌ಗಳು ಮತ್ತು ಡ್ರೈವರ್‌ಗಳಿಗೆ, ಮತ್ತು ನೀವು ಗ್ರಾಹಕರಿಗೆ ಕಳುಹಿಸುವ ಟ್ರಿಪ್ ಮೆಸೇಜ್‌ಗಳಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ.';

  @override
  String get fleetNameAffects =>
      'ವರ್ಕ್‌ಸ್ಪೇಸ್ ಬದಲಾವಣೆ, ಡ್ಯಾಶ್‌ಬೋರ್ಡ್, ಹಂಚಿದ ಟ್ರಿಪ್ ಮೆಸೇಜ್‌ಗಳು';

  @override
  String get fleetNameWhen =>
      'ಎಲ್ಲೆಡೆ ತಕ್ಷಣ; ಟ್ರಿಪ್‌ಗಳು ಮತ್ತು ಸೆಟಲ್‌ಮೆಂಟ್‌ಗಳು ಹೆಸರನ್ನು ಉಳಿಸಿಕೊಳ್ಳುವುದಿಲ್ಲ';

  @override
  String get fleetNameInvalid => '2 ರಿಂದ 100 ಅಕ್ಷರಗಳನ್ನು ಬಳಸಿ.';

  @override
  String get ruleDriverTrips => 'ಡ್ರೈವರ್‌ಗಳು ತಮ್ಮದೇ ಟ್ರಿಪ್‌ಗಳನ್ನು ರಚಿಸಬಹುದು';

  @override
  String get ruleDriverTripsHelp =>
      'ಡ್ರೈವರ್‌ಗಳಿಗೆ \'ಹೊಸ ಟ್ರಿಪ್\' ಬಟನ್ ಸಿಗುತ್ತದೆ, ಅವರು ಲಿಂಕ್ ಆಗಿರುವ ಕಾರಿನಲ್ಲಿ ತಮಗಾಗಿ ಟ್ರಿಪ್ ಬುಕ್ ಮಾಡಬಹುದು. ಆಫ್ ಆಗಿದ್ದಾಗ, ನೀವು ಮತ್ತು ನಿಮ್ಮ ಮ್ಯಾನೇಜರ್‌ಗಳು ಮಾತ್ರ ಟ್ರಿಪ್ ರಚಿಸುತ್ತೀರಿ.';

  @override
  String get ruleDriverTripsAffects => 'ಡ್ರೈವರ್ ಆ್ಯಪ್: ಹೊಸ ಟ್ರಿಪ್';

  @override
  String get ruleNewTripsOnly =>
      'ಹೊಸ ಟ್ರಿಪ್‌ಗಳಿಗೆ ಮಾತ್ರ; ಈಗಾಗಲೇ ರಚಿಸಿದ ಟ್ರಿಪ್‌ಗಳು ಹಾಗೆಯೇ ಇರುತ್ತವೆ';

  @override
  String get ruleDriverCharges => 'ಡ್ರೈವರ್‌ಗಳು ಶುಲ್ಕ ಸೇರಿಸಬಹುದು';

  @override
  String get ruleDriverChargesHelp =>
      'ಟ್ರಿಪ್ ಸಮಯದಲ್ಲಿ ಮತ್ತು ಮುಗಿಸುವಾಗ ಡ್ರೈವರ್‌ಗಳು ಟೋಲ್, ಪಾರ್ಕಿಂಗ್ ಮತ್ತು ಇತರ ಶುಲ್ಕಗಳನ್ನು ಸೇರಿಸಬಹುದು. ಡ್ರೈವರ್ ಕಟ್ಟಿದ ಶುಲ್ಕಗಳು ಅವರ ದಿನದ ಸೆಟಲ್‌ಮೆಂಟ್‌ಗೆ ಸೇರುತ್ತವೆ. ಆಫ್ ಆಗಿದ್ದಾಗ, ನೀವು ಮತ್ತು ನಿಮ್ಮ ಮ್ಯಾನೇಜರ್‌ಗಳು ಮಾತ್ರ ಶುಲ್ಕ ಸೇರಿಸುತ್ತೀರಿ.';

  @override
  String get ruleDriverChargesAffects =>
      'ಡ್ರೈವರ್ ಆ್ಯಪ್: ಟ್ರಿಪ್ ಶುಲ್ಕಗಳು; ದಿನದ ಸೆಟಲ್‌ಮೆಂಟ್';

  @override
  String get ruleNewChargesOnly =>
      'ಹೊಸ ಶುಲ್ಕಗಳಿಗೆ ಮಾತ್ರ; ಈಗಾಗಲೇ ಸೇರಿಸಿದ ಶುಲ್ಕಗಳು ಹಾಗೆಯೇ ಇರುತ್ತವೆ';

  @override
  String get ruleOfflineNote =>
      'ನೀವು ನಿಯಮ ಬದಲಿಸುವ ಮೊದಲು ಡ್ರೈವರ್ ಆಫ್‌ಲೈನ್‌ನಲ್ಲಿ ಏನಾದರೂ ದಾಖಲಿಸಿದ್ದರೆ, ಅವರ ಫೋನ್ ಸಿಂಕ್ ಆದಾಗ ಅದು ತಿರಸ್ಕರಿಸಲ್ಪಡುತ್ತದೆ ಮತ್ತು ಗಮನ ಬೇಕಾದದ್ದು ಎಂದು ಗುರುತಿಸಲಾಗುತ್ತದೆ.';

  @override
  String get odoToleranceAffects =>
      'ಮುಗಿದ ಟ್ರಿಪ್‌ಗಳಲ್ಲಿ ಓಡೋಮೀಟರ್ ಮತ್ತು GPS ದೂರ ಹೋಲಿಕೆ';

  @override
  String get odoToleranceWhen =>
      'ನೀವು ಉಳಿಸಿದ ನಂತರದ ಪರಿಶೀಲನೆಗಳು; ಹಿಂದಿನ ಫಲಿತಾಂಶಗಳು ಹಾಗೆಯೇ ಇರುತ್ತವೆ';

  @override
  String get ruleReceipt => 'ಇಂಧನ ರಸೀದಿಯ ಫೋಟೋ ಕಡ್ಡಾಯ';

  @override
  String get ruleReceiptHelp =>
      'ಪ್ರತಿ ಇಂಧನ ಫಿಲ್‌ಗೆ ರಸೀದಿಯ ಫೋಟೋ ಬೇಕು. ಮುದ್ರಿತ ರಸೀದಿ ಕೊಡದ ಕಡೆ ಡ್ರೈವರ್‌ಗಳು ಆಗಾಗ ಇಂಧನ ತುಂಬಿಸುತ್ತಿದ್ದರೆ ಇದನ್ನು ಆಫ್ ಮಾಡಿ.';

  @override
  String get ruleReceiptAffects => 'ಡ್ರೈವರ್ ಆ್ಯಪ್: ಇಂಧನ ದಾಖಲಿಸಿ';

  @override
  String get ruleNewFillsOnly =>
      'ಹೊಸ ಫಿಲ್‌ಗಳಿಗೆ ಮಾತ್ರ; ಈಗಾಗಲೇ ದಾಖಲಿಸಿದ ಫಿಲ್‌ಗಳು ಹಾಗೆಯೇ ಇರುತ್ತವೆ';

  @override
  String get fuelThresholdsTitle => 'ಫಿಲ್ ಯಾವಾಗ ಫ್ಲ್ಯಾಗ್ ಆಗುತ್ತದೆ';

  @override
  String get fuelThresholdsAffects =>
      'ಇಂಧನ ಅಲರ್ಟ್‌ಗಳು ಮತ್ತು ಪ್ರತಿ ವಾಹನದ ಸಾಮಾನ್ಯ ಮೈಲೇಜ್';

  @override
  String get fuelThresholdsWhen =>
      'ಪ್ರತಿ ವಾಹನದ ಮುಂದಿನ ಇಂಧನ ಪರಿಶೀಲನೆ (ಅದರ ಮುಂದಿನ ಫಿಲ್); ಈಗಾಗಲೇ ಬಂದ ಅಲರ್ಟ್‌ಗಳು ಹಾಗೆಯೇ ಇರುತ್ತವೆ';

  @override
  String get remindersAffects =>
      'ವಾಹನ ಮತ್ತು ಡ್ರೈವರ್ ದಾಖಲೆಗಳ ಅವಧಿ ಮುಗಿಯುವ ಅಲರ್ಟ್‌ಗಳು';

  @override
  String get remindersWhen =>
      'ಮುಂದಿನ ದೈನಂದಿನ ಪರಿಶೀಲನೆಯಿಂದ, ಸುಮಾರು ಬೆಳಿಗ್ಗೆ 6 ಗಂಟೆಗೆ';

  @override
  String get remindersSeverity =>
      'ಅವಧಿ ಮುಗಿಯಲು 7 ದಿನ ಅಥವಾ ಕಡಿಮೆ ಇರುವ ಅಲರ್ಟ್‌ಗಳು ಎಚ್ಚರಿಕೆಗಳು; 1 ದಿನ ಅಥವಾ ಕಡಿಮೆ, ಅಥವಾ ಈಗಾಗಲೇ ಅವಧಿ ಮುಗಿದಿದ್ದರೆ, ಗಂಭೀರ.';

  @override
  String get payAffects =>
      'ಸ್ವಂತ ಸಂಬಳ ನಿಯಮ ಇಲ್ಲದ ಡ್ರೈವರ್‌ಗಳ ದಿನದ ಸೆಟಲ್‌ಮೆಂಟ್‌ಗಳು';

  @override
  String get payWhen =>
      'ಇನ್ನೂ ಸೆಟಲ್ ಆಗದ ದಿನಗಳು; ಸೆಟಲ್ ಆದ ದಿನಗಳು ಆಗಿನ ಸಂಬಳವನ್ನೇ ಉಳಿಸಿಕೊಳ್ಳುತ್ತವೆ';

  @override
  String get rolesTitle => 'ಪ್ರತಿ ಪಾತ್ರ ಏನು ಮಾಡಬಹುದು';

  @override
  String get roleOwnerCan =>
      'ಎಲ್ಲವೂ, ಈ ಸೆಟ್ಟಿಂಗ್‌ಗಳು, ಸಂಬಳ ನಿಯಮಗಳು ಮತ್ತು ಮ್ಯಾನೇಜರ್‌ಗಳು ಸೇರಿ.';

  @override
  String get roleManagerCan =>
      'ಫ್ಲೀಟ್ ನಡೆಸುತ್ತಾರೆ: ಟ್ರಿಪ್‌ಗಳು, ವಾಹನಗಳು, ಡ್ರೈವರ್‌ಗಳು, ದಾಖಲೆಗಳು, ಇಂಧನ ಮತ್ತು ಸೆಟಲ್‌ಮೆಂಟ್‌ಗಳು. ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ನೋಡಬಹುದು ಆದರೆ ಬದಲಿಸಲು ಆಗುವುದಿಲ್ಲ.';

  @override
  String get roleDriverCan =>
      'ಡ್ರೈವರ್ ಆ್ಯಪ್‌ನಲ್ಲಿ ತಮ್ಮದೇ ಟ್ರಿಪ್‌ಗಳು, ಇಂಧನ ಫಿಲ್‌ಗಳು, ಶುಲ್ಕಗಳು ಮತ್ತು ದಾಖಲೆಗಳು.';

  @override
  String settingsRange({required String min, required String max}) {
    return '$min ರಿಂದ $max ವರೆಗಿನ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ.';
  }

  @override
  String get settingsDaysInvalid =>
      '0 ರಿಂದ 365 ರವರೆಗಿನ 5 ಪೂರ್ಣ ಸಂಖ್ಯೆಗಳವರೆಗೆ, ಉದಾ. 30, 7, 1.';

  @override
  String get placesCredit =>
      'Powered by Geoapify · © OpenStreetMap contributors';

  @override
  String get pickSourceTitle => 'ಎಲ್ಲಿಂದ ಅಪ್‌ಲೋಡ್ ಮಾಡಬೇಕು';

  @override
  String get pickFromPhotos => 'ಫೋಟೋ ಗ್ಯಾಲರಿ';

  @override
  String get pickFromFiles => 'ಫೈಲ್‌ಗಳು (PDF ಅಥವಾ ಚಿತ್ರ)';
}
