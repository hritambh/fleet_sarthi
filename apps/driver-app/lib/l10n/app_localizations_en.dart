// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fleet Sarthi';

  @override
  String get signOut => 'Sign out';

  @override
  String get language => 'Language';

  @override
  String get languageDevice => 'Phone\'s language';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get optional => 'Optional';

  @override
  String get notSet => 'Not set';

  @override
  String get noValue => '—';

  @override
  String somethingWentWrong({required String error}) {
    return 'Something went wrong: $error';
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
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String dayAndTime({required String day, required String time}) {
    return '$day, $time';
  }

  @override
  String get loginIntro =>
      'Sign in with your mobile number. Drivers use the number their fleet owner registered.';

  @override
  String loginCodeSent({required String phone}) {
    return 'Enter the code we sent to $phone';
  }

  @override
  String get mobileNumber => 'Mobile number';

  @override
  String get sixDigitCode => '6-digit code';

  @override
  String get sendCode => 'Send code';

  @override
  String get useDifferentNumber => 'Use a different number';

  @override
  String get enterTenDigitMobile => 'Enter your 10-digit mobile number';

  @override
  String get enterSixDigitCode => 'Enter the 6-digit code';

  @override
  String get loginCheckNumber => 'Check the number and try again.';

  @override
  String get ownerMode => 'Owner mode';

  @override
  String get driverMode => 'Driver mode';

  @override
  String get errorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get errorValidationFailed =>
      'Some details aren\'t right. Check them and try again.';

  @override
  String get errorUnauthenticated => 'You\'ve been signed out. Sign in again.';

  @override
  String get errorTokenExpired => 'Your session expired. Sign in again.';

  @override
  String get errorForbiddenRole => 'You don\'t have permission to do this.';

  @override
  String get errorNoActiveOrg => 'Your number isn\'t part of a fleet yet.';

  @override
  String get errorNotFound => 'Not found. It may have been removed.';

  @override
  String get errorIllegalTransition =>
      'This can\'t be done in the trip\'s current state. Refresh and try again.';

  @override
  String get errorTripCancelled => 'This trip has been cancelled.';

  @override
  String get errorTripReassigned =>
      'This trip has been reassigned to another driver.';

  @override
  String get errorVehicleBusy =>
      'That vehicle is already booked for an overlapping time.';

  @override
  String get errorDriverBusy =>
      'That driver is already booked for an overlapping time.';

  @override
  String get errorCancellationPending =>
      'A cancellation request is already waiting for a decision.';

  @override
  String get errorAlreadySettled => 'That day is already settled.';

  @override
  String get errorIdempotencyConflict =>
      'This was already sent with different details.';

  @override
  String get errorIdempotencyKeyRequired =>
      'The request was incomplete. Try again.';

  @override
  String get errorVersionConflict =>
      'Someone else changed this at the same time. Refresh and try again.';

  @override
  String get errorConflict => 'This clashes with an existing record.';

  @override
  String get errorFuelTypeMismatch =>
      'That fuel doesn\'t match the vehicle\'s fuel type.';

  @override
  String get errorOdometerBeforeStart =>
      'The odometer reading is lower than at the start of the trip.';

  @override
  String get errorOtpInvalid =>
      'That code is not right. Check it and try again.';

  @override
  String get errorOtpExpired => 'The code expired. Request a new one.';

  @override
  String get errorInvalidCredentials => 'Wrong mobile number or password.';

  @override
  String get errorAccountExists =>
      'This number already has an account. Log in, or reset your password.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get errorUploadNotFound =>
      'The photo hasn\'t reached the server yet. Try again shortly.';

  @override
  String get errorUploadMismatch =>
      'The uploaded photo didn\'t match. Take it again.';

  @override
  String get errorUploadFailed =>
      'The photo upload failed. It will be retried.';

  @override
  String get errorInternal => 'Something went wrong on the server. Try again.';

  @override
  String get statusCreated => 'Not assigned';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusStarted => 'On the road';

  @override
  String get statusEnded => 'Ended';

  @override
  String get statusSettled => 'Settled';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get myTrips => 'My trips';

  @override
  String get newTrip => 'New trip';

  @override
  String get logFuel => 'Log fuel';

  @override
  String get groupOnTheRoad => 'On the road';

  @override
  String get groupToday => 'Today';

  @override
  String get groupUpcoming => 'Upcoming';

  @override
  String get groupRecent => 'Recent';

  @override
  String get noTripsYet => 'No trips yet. Pull down to refresh.';

  @override
  String get conflictCancelledShort => 'Cancelled by owner';

  @override
  String get conflictReassignedShort => 'Reassigned';

  @override
  String get tripNotFoundOnPhone => 'Trip not found on this phone';

  @override
  String includesKm({required String km}) {
    return 'Includes $km km';
  }

  @override
  String startOdometerKm({required String km}) {
    return 'Start odometer: $km km';
  }

  @override
  String endOdometerKm({required String km}) {
    return 'End odometer: $km km';
  }

  @override
  String get cancellationRequested => 'Cancellation requested';

  @override
  String get cancellationWaiting =>
      'Waiting for your owner to approve or reject it.';

  @override
  String get charges => 'Charges';

  @override
  String get fuel => 'Fuel';

  @override
  String get collected => 'Collected';

  @override
  String get startTrip => 'Start trip';

  @override
  String get chargeButton => 'Charge';

  @override
  String get requestCancellation => 'Request cancellation';

  @override
  String get endTrip => 'End trip';

  @override
  String get conflictCancelledBanner => 'This trip was cancelled by the owner';

  @override
  String get conflictReassignedBanner =>
      'This trip has been reassigned to another driver';

  @override
  String get conflictBannerDetail =>
      'Anything you recorded offline for it was not applied. Your photos were still sent to the owner.';

  @override
  String get elapsed => 'elapsed';

  @override
  String get kmByGps => 'km by GPS';

  @override
  String get methodCash => 'Cash';

  @override
  String get methodUpi => 'UPI';

  @override
  String get methodCard => 'Card';

  @override
  String get chargeToll => 'Toll';

  @override
  String get chargeParking => 'Parking';

  @override
  String get chargeStateTax => 'State tax';

  @override
  String get chargeDriverAllowance => 'Driver allowance';

  @override
  String get chargeNightCharge => 'Night charge';

  @override
  String get chargeExtraKm => 'Extra km';

  @override
  String get chargeOther => 'Other';

  @override
  String get chargeNoteExtraFare => 'Extra fare · paid by the customer';

  @override
  String get chargeNotePaidByYou => 'Paid by you · paid back in settlement';

  @override
  String get chargeNoteBilled => 'Billed to the customer';

  @override
  String get fuelPetrol => 'Petrol';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelCng => 'CNG';

  @override
  String get fuelPetrolCng => 'Petrol + CNG';

  @override
  String get paidByChoiceMe => 'Me (cash)';

  @override
  String get paidByOwner => 'Owner';

  @override
  String get paidByFuelCard => 'Fuel card';

  @override
  String get paidByLabelYou => 'Paid by you';

  @override
  String get paidByLabelOwner => 'Paid by owner';

  @override
  String get paidByLabelDriverCash => 'Driver paid cash';

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
    return '$label · full tank';
  }

  @override
  String get addCharge => 'Add charge';

  @override
  String get chargeType => 'Type';

  @override
  String get amount => 'Amount';

  @override
  String get extraFareTitle => 'Added to the customer’s fare';

  @override
  String get extraFareSubtitle => 'Collect it from the customer with the fare.';

  @override
  String get iPaidThis => 'I paid this';

  @override
  String get paidBackInSettlement => 'Paid back to you in your settlement';

  @override
  String get receiptPhotoOptional => 'Receipt photo (optional)';

  @override
  String get odometerPhoto => 'Odometer photo';

  @override
  String get takeOdometerPhoto => 'Take a photo of the odometer';

  @override
  String get odometerReading => 'Odometer reading';

  @override
  String get typeExactly => 'Type it exactly as shown';

  @override
  String startedAtKm({required String km}) {
    return 'Started at $km km';
  }

  @override
  String kmOverIncluded({required String over, required String included}) {
    return '$over km over the $included km included in the fare. Add an extra km charge below.';
  }

  @override
  String get chargesYouPaidOrAdded => 'Charges you paid or added';

  @override
  String addedDuringTrip({required String note}) {
    return 'Added during the trip · $note';
  }

  @override
  String get extraFare => 'Extra fare';

  @override
  String get iPaid => 'I paid';

  @override
  String get addChargeRow => 'Add toll, night charge, extra km…';

  @override
  String get fuelFilledOnTrip => 'Fuel filled on this trip';

  @override
  String fuelPaidByYouNote({required String amount}) {
    return '$amount of fuel paid by you is paid back in your settlement; the customer doesn’t pay for it.';
  }

  @override
  String customerPaidExpected({required String amount}) {
    return 'Customer paid · expected $amount';
  }

  @override
  String fareBreakdownFare({required String amount}) {
    return 'Fare $amount';
  }

  @override
  String fareBreakdownExtra({required String amount}) {
    return 'extra fare $amount';
  }

  @override
  String fareBreakdownExpenses({required String amount}) {
    return 'tolls & expenses $amount';
  }

  @override
  String alreadyRecorded({required String amount}) {
    return '$amount already recorded during the trip';
  }

  @override
  String get splitPayment => 'Split payment';

  @override
  String get cancelRequestIntro =>
      'Your owner will approve or reject this. The trip keeps running until then.';

  @override
  String get reason => 'Reason';

  @override
  String get reasonHint => 'e.g. Customer got off at Lonavala';

  @override
  String get reasonRequired => 'Tell your owner why';

  @override
  String get sendRequest => 'Send request';

  @override
  String get tripTypeOneWay => 'One way';

  @override
  String get tripTypeRoundTrip => 'Round trip';

  @override
  String get tripTypeLocal => 'Local';

  @override
  String hours({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get pickup => 'Pickup';

  @override
  String get enterPickup => 'Enter the pickup';

  @override
  String get drop => 'Drop';

  @override
  String get enterDrop => 'Enter the drop';

  @override
  String get starts => 'Starts';

  @override
  String get expectedDuration => 'Expected duration';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get fare => 'Fare';

  @override
  String get includedKm => 'Included km';

  @override
  String get includedKmInvalid => 'Enter km, or leave empty';

  @override
  String get customerNameOptional => 'Customer name (optional)';

  @override
  String get customerMobileOptional => 'Customer mobile (optional)';

  @override
  String get createTrip => 'Create trip';

  @override
  String get newTripFootnote =>
      'The trip is assigned to you. Your fleet owner sees it once your phone is online.';

  @override
  String get fuelSaved => 'Fuel fill saved; it will sync automatically';

  @override
  String get noVehicleAssigned =>
      'No vehicle is assigned to you right now. Fuel can be logged for the vehicle on your trip; ask your fleet owner to assign one.';

  @override
  String get vehicleNotDownloaded =>
      'This vehicle\'s details haven\'t been downloaded yet. Connect to the internet once and try again.';

  @override
  String get vehicleOnThisTrip => 'The vehicle on this trip';

  @override
  String fromYourTrip({required String route}) {
    return 'From your trip: $route';
  }

  @override
  String get vehiclesOnYourTrips => 'Vehicles on your trips';

  @override
  String fuelKind({required String fuel}) {
    return 'Fuel: $fuel';
  }

  @override
  String get receiptPhoto => 'Receipt photo';

  @override
  String get takeReceiptPhoto => 'Take a photo of the receipt';

  @override
  String get quantity => 'Quantity';

  @override
  String enterQuantity({required String unit}) {
    return 'Enter the $unit filled';
  }

  @override
  String get fullTank => 'Full tank';

  @override
  String get fullTankHint => 'Turn on when the tank was filled completely';

  @override
  String get whoPaid => 'Who paid?';

  @override
  String get saveFuelFill => 'Save fuel fill';

  @override
  String get syncStatus => 'Sync status';

  @override
  String get syncOffline => 'Offline';

  @override
  String syncOfflineSaved({required int count}) {
    return 'Offline · $count saved on phone';
  }

  @override
  String syncPending({required int count}) {
    return '$count pending';
  }

  @override
  String get synced => 'Synced';

  @override
  String needAttention({required int count}) {
    return '$count need attention';
  }

  @override
  String get attentionTitle => 'These could not be sent';

  @override
  String get attentionSubtitle =>
      'The server rejected them. Ask your owner, or retry.';

  @override
  String get retryAll => 'Retry all';

  @override
  String get outboxMedia => 'Photo';

  @override
  String get outboxTripCommand => 'Trip update';

  @override
  String get outboxTripCreate => 'New trip';

  @override
  String get outboxTripCharge => 'Charge';

  @override
  String get outboxTripCollection => 'Payment';

  @override
  String get outboxFuelFill => 'Fuel fill';

  @override
  String get noPhotoYet => 'No photo yet';

  @override
  String get photoTaken => 'Photo taken';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get retake => 'Retake';

  @override
  String get enterOdometerKm => 'Enter the odometer reading in km';

  @override
  String mustBeAtLeastKm({required String km}) {
    return 'Must be at least $km km';
  }

  @override
  String get enterAmount => 'Enter an amount in ₹';

  @override
  String get amountMoreThanZero => 'Amount must be more than ₹0';

  @override
  String get enterFare => 'Enter the fare in ₹';

  @override
  String get consentTitle => 'Location during trips';

  @override
  String get consentWhen =>
      'Fleet Sarthi records your phone\'s location only while a trip is running (between \"Start trip\" and \"End trip\"). A notification is shown the whole time it is recording.';

  @override
  String get consentWhy =>
      'Your fleet owner uses it to see the route and to check the distance against the odometer. It is also attached to odometer and receipt photos. It is not collected when you are off duty.';

  @override
  String get consentRetention =>
      'Route data is kept for up to 12 months and then deleted.';

  @override
  String get consentContinue => 'I understand, continue';

  @override
  String cameraUnavailable({required String error}) {
    return 'Camera unavailable: $error';
  }

  @override
  String couldNotTakePhoto({required String error}) {
    return 'Could not take the photo: $error';
  }

  @override
  String get fitOdometer => 'Fit the whole odometer in the frame';

  @override
  String get fitReceipt => 'Fit the whole receipt in the frame';

  @override
  String get fitDocument => 'Fit the whole document in the frame';

  @override
  String get documentPhoto => 'Document photo';

  @override
  String get gpsNotificationTitle => 'Trip in progress';

  @override
  String get gpsNotificationText =>
      'Fleet Sarthi is recording your route for this trip.';

  @override
  String get rejectEndBeforeStart => 'The trip must end after it starts';

  @override
  String get rejectNeedDrop => 'Enter where the trip goes';

  @override
  String rejectEndBelowStart({required String km}) {
    return 'End reading must be at least $km km';
  }

  @override
  String get rejectChargesActiveOnly =>
      'Charges can only be added to an active trip';

  @override
  String get rejectPaymentsAfterStart =>
      'Payments can be recorded once the trip has started';

  @override
  String get rejectTripCancelled => 'This trip has been cancelled';

  @override
  String get rejectCancellationPending =>
      'A cancellation request is already pending for this trip';

  @override
  String get rejectNoPendingCancellation =>
      'There is no pending cancellation request';

  @override
  String rejectAnotherTripRunning({required String route}) {
    return 'End your trip $route before starting another';
  }

  @override
  String get errorDriverOnTrip =>
      'The driver already has a trip on the road. End it before starting another.';

  @override
  String get errorVehicleOnTrip =>
      'This vehicle is already on the road on another trip. End that trip first.';

  @override
  String get rejectNotAllowed => 'You can\'t do this on this trip';

  @override
  String rejectWrongState({required String status}) {
    return 'This can\'t be done while the trip is $status';
  }

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navTrips => 'Trips';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navMore => 'More';

  @override
  String get vehicles => 'Vehicles';

  @override
  String get drivers => 'Drivers';

  @override
  String get members => 'Members';

  @override
  String get documents => 'Documents';

  @override
  String get review => 'Review';

  @override
  String get settlements => 'Settlements';

  @override
  String get settings => 'Settings';

  @override
  String get loadFailed => 'Could not load this.';

  @override
  String get edit => 'Edit';

  @override
  String get all => 'All';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get required => 'Required';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleDriver => 'Driver';

  @override
  String get ownerOnly => 'Only the owner can change this.';

  @override
  String get severityCritical => 'Critical';

  @override
  String get severityWarning => 'Warning';

  @override
  String get severityInfo => 'Info';

  @override
  String get seeAll => 'See all';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get status => 'Status';

  @override
  String get name => 'Name';

  @override
  String get note => 'Note';

  @override
  String get total => 'Total';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String percentValue({required String value}) {
    return '$value%';
  }

  @override
  String minutesShort({required int count}) {
    return '$count min';
  }

  @override
  String listAnd({required String first, required String last}) {
    return '$first and $last';
  }

  @override
  String get todaysTrips => 'Today’s trips';

  @override
  String get noTripsToday => 'No trips scheduled today';

  @override
  String get needsAttention => 'Needs your attention';

  @override
  String get criticalAlerts => 'Critical alerts';

  @override
  String get openAlerts => 'Open alerts';

  @override
  String get toReview => 'To review';

  @override
  String get documentsDueSoon => 'Documents due soon';

  @override
  String get nothingExpiring => 'Nothing expiring in the next 30 days';

  @override
  String get noOpenAlerts => 'No open alerts';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get anyDate => 'Any date';

  @override
  String get allDrivers => 'All drivers';

  @override
  String get allVehicles => 'All vehicles';

  @override
  String get noTripsMatch => 'No trips match these filters';

  @override
  String localTrip({required String from}) {
    return '$from (local)';
  }

  @override
  String get tripType => 'Trip type';

  @override
  String get quotedFare => 'Quoted fare';

  @override
  String get includedKmHint =>
      'Km covered by the fare, e.g. 300 for a 300 km package';

  @override
  String get customerName => 'Customer name';

  @override
  String get customerMobile => 'Customer mobile';

  @override
  String get ends => 'Ends';

  @override
  String get vehicleOptional => 'Vehicle (optional)';

  @override
  String get driverOptional => 'Driver (optional)';

  @override
  String get assignLater => 'Assign later';

  @override
  String get pickBothOrNeither =>
      'Pick both a vehicle and a driver, or neither';

  @override
  String get tripDetails => 'Trip';

  @override
  String get customer => 'Customer';

  @override
  String get driver => 'Driver';

  @override
  String get startedAt => 'Started';

  @override
  String get endedAt => 'Ended';

  @override
  String get cancelledAt => 'Cancelled';

  @override
  String get odometerDistance => 'Odometer distance';

  @override
  String kmOverDriven({required String over, required String driven}) {
    return '$over km over (driven $driven km)';
  }

  @override
  String drivenKm({required String km}) {
    return 'Driven $km km';
  }

  @override
  String get cancellationFare => 'Cancellation fare';

  @override
  String get assign => 'Assign';

  @override
  String get reassign => 'Reassign';

  @override
  String get unassign => 'Unassign';

  @override
  String get cancelTrip => 'Cancel trip';

  @override
  String get cancelTripTitle => 'Cancel this trip';

  @override
  String get assignTripTitle => 'Assign trip';

  @override
  String get reassignTripTitle => 'Reassign trip';

  @override
  String get overlapNote =>
      'A vehicle or driver already booked for an overlapping time can’t be assigned.';

  @override
  String get cancellationRequestTitle => 'Cancellation request';

  @override
  String requestedBy({required String role, required String when}) {
    return 'Requested by the $role on $when';
  }

  @override
  String odometerAtKm({required String km}) {
    return 'Odometer $km';
  }

  @override
  String decisionNote({required String note}) {
    return 'Decision note: $note';
  }

  @override
  String get approveCancellation => 'Approve cancellation';

  @override
  String get reject => 'Reject';

  @override
  String get approve => 'Approve';

  @override
  String get approveIntro =>
      'The trip becomes cancelled. You can charge for the distance already driven.';

  @override
  String get cancellationFareHint => '0 for no charge';

  @override
  String get rejectTitle => 'Reject cancellation';

  @override
  String get noteForDriver => 'Note for the driver';

  @override
  String get rejectConfirm => 'Reject — the trip continues';

  @override
  String get requestPending => 'Pending';

  @override
  String get requestApproved => 'Approved';

  @override
  String get requestRejected => 'Rejected';

  @override
  String get requestWithdrawn => 'Withdrawn';

  @override
  String get odometerEvidence => 'Odometer evidence';

  @override
  String get startLabel => 'Start';

  @override
  String get endLabel => 'End';

  @override
  String get notRecordedYet => 'Not recorded yet';

  @override
  String get typed => 'Typed';

  @override
  String get readFromPhoto => 'Read from photo';

  @override
  String get differsSentToReview => 'Differs: sent to the review queue';

  @override
  String capturedAt({required String when}) {
    return 'Captured $when';
  }

  @override
  String get photoNotUploaded =>
      'Photo not uploaded yet (the phone may still be offline).';

  @override
  String get routeTitle => 'Route';

  @override
  String get routeAfterStart => 'The route appears once the trip starts';

  @override
  String gpsPointsShown({required int count}) {
    return '$count GPS points shown';
  }

  @override
  String pointsRemoved({
    required String inaccurate,
    required String mock,
    required String impossible,
  }) {
    return 'Removed $inaccurate inaccurate, $mock mock and $impossible impossible points';
  }

  @override
  String get verdictOkLabel => 'Odometer matches GPS';

  @override
  String get verdictOkText =>
      'The odometer distance is within the allowed difference from the GPS route.';

  @override
  String get verdictFlaggedLabel => 'Odometer higher than GPS';

  @override
  String get verdictFlaggedText =>
      'The odometer distance is well above the GPS route. See the alert for details.';

  @override
  String get verdictInconclusiveLabel => 'Not enough GPS to judge';

  @override
  String get verdictInconclusiveText =>
      'The phone recorded too little of the trip (often battery-saving settings). No alert is raised in this case.';

  @override
  String checkedAt({required String when}) {
    return 'checked $when';
  }

  @override
  String get gps => 'GPS';

  @override
  String get odometer => 'Odometer';

  @override
  String get gpsCoverage => 'GPS coverage';

  @override
  String get longestGap => 'Longest gap';

  @override
  String get distanceCheckPending =>
      'The distance check runs a few seconds after the trip ends.';

  @override
  String get noCharges => 'No tolls, parking or other charges.';

  @override
  String get addChargeTitle => 'Add a charge';

  @override
  String get driverPaidCheckbox =>
      'The driver paid this out of pocket (reimbursed in settlement)';

  @override
  String get extraFareInfo =>
      'Extra fare: added to what the customer pays, on top of the quoted fare.';

  @override
  String get driverPaid => 'Driver paid';

  @override
  String get billedOnly => 'Billed only';

  @override
  String byRole({required String text, required String role}) {
    return '$text · by $role';
  }

  @override
  String get voidAction => 'Void';

  @override
  String get paymentsCollected => 'Payments collected';

  @override
  String get recordPayment => 'Record payment';

  @override
  String get nothingRecorded => 'Nothing recorded yet.';

  @override
  String get method => 'Method';

  @override
  String get methodCashOption => 'Cash (driver hands it over at settlement)';

  @override
  String get methodUpiOption => 'UPI (comes straight to you)';

  @override
  String get methodCardOption => 'Card (comes straight to you)';

  @override
  String get referenceOptional => 'Reference (optional)';

  @override
  String get referenceHint => 'UPI reference or card slip number';

  @override
  String get record => 'Record';

  @override
  String get timeline => 'Timeline';

  @override
  String get noEvents => 'No events';

  @override
  String eventBy({required String event, required String role}) {
    return '$event by $role';
  }

  @override
  String eventBySystem({required String event}) {
    return '$event (system)';
  }

  @override
  String onDevice({required String when}) {
    return '$when on the device';
  }

  @override
  String syncedLater({required String when, required int count}) {
    return 'reached the server $when ($count min later)';
  }

  @override
  String get eventCreated => 'Created';

  @override
  String get eventAssigned => 'Assigned';

  @override
  String get eventReassigned => 'Reassigned';

  @override
  String get eventUnassigned => 'Unassigned';

  @override
  String get eventStarted => 'Started';

  @override
  String get eventEnded => 'Ended';

  @override
  String get eventCancellationRequested => 'Cancellation requested';

  @override
  String get eventCancellationApproved => 'Cancellation approved';

  @override
  String get eventCancellationRejected => 'Cancellation rejected';

  @override
  String get eventCancellationWithdrawn => 'Cancellation withdrawn';

  @override
  String get eventCancelled => 'Cancelled';

  @override
  String get eventSettled => 'Settled';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get editVehicle => 'Edit vehicle';

  @override
  String get registrationNumber => 'Registration number';

  @override
  String get registrationInvalid =>
      'Use a registration number like MH 12 AB 1234';

  @override
  String get knownModel => 'Known model';

  @override
  String get knownModelHint =>
      'Picking one seeds the fuel baseline for a new vehicle';

  @override
  String get otherModel => 'Other / not listed';

  @override
  String get make => 'Make';

  @override
  String get model => 'Model';

  @override
  String get fuelType => 'Fuel type';

  @override
  String get year => 'Year';

  @override
  String get currentOdometer => 'Current odometer';

  @override
  String get inactiveVehicleOption => 'Inactive (hidden from assignment)';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get activate => 'Activate';

  @override
  String get noVehiclesYet =>
      'No vehicles yet. Add your first car to start assigning trips.';

  @override
  String get lastOdometer => 'Last odometer';

  @override
  String get recentTrips => 'Recent trips';

  @override
  String get noTripsShort => 'No trips yet';

  @override
  String get fuelAudit => 'Fuel audit';

  @override
  String get inviteDriver => 'Invite driver';

  @override
  String get inviteDriverIntro =>
      'The driver signs in to the Fleet Sarthi app with this number; no password needed.';

  @override
  String get enterIndianMobile => 'Enter a 10-digit Indian mobile number';

  @override
  String get sendInvite => 'Send invite';

  @override
  String get noDriversYet =>
      'No drivers yet. Invite drivers by phone; they sign up with that number and a password.';

  @override
  String payDefault({required String rule}) {
    return 'Default · $rule';
  }

  @override
  String get notSignedInYet => 'Hasn’t signed in yet';

  @override
  String get inactiveDriverOption => 'Inactive (can’t be assigned)';

  @override
  String get pay => 'Pay';

  @override
  String get onlyOwnerPay => 'Only the owner can change pay.';

  @override
  String get payDifferently => 'Pay this driver differently from the default';

  @override
  String get checkPayRule => 'Check the pay rule values';

  @override
  String get payRuleHow => 'How the driver is paid';

  @override
  String get payNone => 'None (salaried, paid outside Fleet Sarthi)';

  @override
  String get payPercent => 'Percent of fare';

  @override
  String get payPerTrip => 'Fixed amount per trip';

  @override
  String get payPerKm => 'Per km driven';

  @override
  String get payFixedDaily => 'Fixed amount per working day';

  @override
  String get percent => 'Percent';

  @override
  String get ofBase => 'Of';

  @override
  String get baseQuoted => 'Quoted fare';

  @override
  String get baseExpected => 'Fare including charges';

  @override
  String get amountPerTrip => 'Amount per trip';

  @override
  String get ratePerKm => 'Rate per km';

  @override
  String get amountPerDay => 'Amount per working day';

  @override
  String get allowanceToDriver => 'Driver allowance goes to the driver';

  @override
  String get allowanceHint =>
      'The bata a customer pays is added to the driver’s earnings.';

  @override
  String get ruleNoPay => 'No pay in settlements';

  @override
  String rulePercentQuoted({required String percent}) {
    return '$percent% of quoted fare';
  }

  @override
  String rulePercentExpected({required String percent}) {
    return '$percent% of fare incl. charges';
  }

  @override
  String rulePerTrip({required String amount}) {
    return '$amount per trip';
  }

  @override
  String rulePerKm({required String amount}) {
    return '$amount per km';
  }

  @override
  String ruleFixedDaily({required String amount}) {
    return '$amount per working day';
  }

  @override
  String rulePlusAllowance({required String rule}) {
    return '$rule + driver allowance';
  }

  @override
  String get inviteManager => 'Invite manager';

  @override
  String get inviteManagerIntro =>
      'Managers run trips, alerts and settlements, but can’t change settings or pay.';

  @override
  String get removeManager => 'Remove manager access';

  @override
  String removeManagerConfirm({required String name}) {
    return 'Remove manager access for $name? Their other roles stay.';
  }

  @override
  String get remove => 'Remove';

  @override
  String get memberInvited => 'Invited';

  @override
  String get memberActive => 'Active';

  @override
  String get memberSuspended => 'Suspended';

  @override
  String get membersIntro => 'People with access to this fleet.';

  @override
  String get addDocument => 'Add document';

  @override
  String get renew => 'Renew';

  @override
  String renewTitle({required String doc}) {
    return 'Renew $doc';
  }

  @override
  String get renewIntro =>
      'The renewed copy replaces the current one (it stays in history), and its expiry alerts are cleared.';

  @override
  String get documentType => 'Document';

  @override
  String get documentFor => 'For';

  @override
  String get documentNumber => 'Number';

  @override
  String get validFrom => 'Valid from';

  @override
  String get expiresOn => 'Expires on';

  @override
  String get expiresOnHint => 'Alerts are raised before expiry, and on expiry.';

  @override
  String get saveRenewal => 'Save renewal';

  @override
  String get noDocuments => 'No documents yet.';

  @override
  String get docRc => 'Registration (RC)';

  @override
  String get docInsurance => 'Insurance';

  @override
  String get docPermit => 'Permit';

  @override
  String get docPuc => 'Pollution (PUC)';

  @override
  String get docLicence => 'Driving licence';

  @override
  String get docValid => 'Valid';

  @override
  String docExpiresIn({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expires in $count days',
      one: 'Expires tomorrow',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String get docExpired => 'Expired';

  @override
  String get docSuperseded => 'Renewed';

  @override
  String get filterAllDocs => 'All current documents';

  @override
  String get filterDue30 => 'Due in 30 days or expired';

  @override
  String get filterDue7 => 'Due in 7 days or expired';

  @override
  String get filterDue0 => 'Expired or due today';

  @override
  String get viewPhoto => 'View photo';

  @override
  String get documentPhotoOptional => 'Photo (optional)';

  @override
  String get pickVehicleOrDriver => 'Pick who it is for';

  @override
  String get fuelIntro =>
      'Each vehicle is compared with its own history, cycle by cycle (full tank to full tank).';

  @override
  String get efficiencyByCycle => 'Fuel efficiency by cycle';

  @override
  String get costByCycle => 'Running cost by cycle';

  @override
  String get noCycles =>
      'No full-tank cycles yet. Efficiency is measured between two full-tank fills.';

  @override
  String get usual => 'Usual';

  @override
  String usualValue({required String value}) {
    return 'usual $value';
  }

  @override
  String get cyclesInBaseline => 'Cycles in baseline';

  @override
  String get verdictOk => 'OK';

  @override
  String get verdictFlagged => 'Flagged';

  @override
  String get verdictInvalid => 'Invalid';

  @override
  String get fuelFills => 'Fuel fills';

  @override
  String get noFills => 'No fills recorded';

  @override
  String get fullTankShort => 'Full';

  @override
  String get partialTank => 'Partial';

  @override
  String get voidFill => 'Void fill';

  @override
  String get voidFillTitle => 'Void this fill';

  @override
  String voidFillIntro({
    required String quantity,
    required String amount,
    required String when,
  }) {
    return '$quantity for $amount on $when. The vehicle’s fuel audit is recomputed without it.';
  }

  @override
  String get voidReasonHint => 'e.g. Typed 60 L instead of 40 L';

  @override
  String get keepIt => 'Keep it';

  @override
  String receiptAmount({required String amount}) {
    return 'receipt: $amount';
  }

  @override
  String sigmaRule({required String value}) {
    return '$valueσ';
  }

  @override
  String percentRule({required String value}) {
    return '$value% (new vehicle)';
  }

  @override
  String cycleRange({required String from, required String to}) {
    return '$from → $to';
  }

  @override
  String get noCyclesShort => 'No cycles';

  @override
  String get chartThisCycle => 'Each cycle';

  @override
  String perKmValue({required String amount}) {
    return '$amount/km';
  }

  @override
  String get allKinds => 'All kinds';

  @override
  String get alertOpen => 'Open';

  @override
  String get alertAcknowledged => 'Acknowledged';

  @override
  String get alertResolved => 'Resolved';

  @override
  String get alertDismissed => 'Dismissed';

  @override
  String get acknowledge => 'Acknowledge';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get dismissFalseAlarm => 'Dismiss as false alarm';

  @override
  String get markResolved => 'Mark resolved';

  @override
  String get falseAlarm => 'False alarm';

  @override
  String get allClear => 'All clear: no open alerts';

  @override
  String get noAlertsMatch => 'No alerts match';

  @override
  String get openTrip => 'Open trip';

  @override
  String get openFuelHistory => 'Open fuel history';

  @override
  String get openVehicle => 'Open vehicle';

  @override
  String get openDocuments => 'Open documents';

  @override
  String get alertsIntro =>
      'Dismissing a fuel alert as a false alarm lets that cycle count towards the vehicle’s normal range.';

  @override
  String get kindFuelEfficiencyLow => 'Fuel use higher than usual';

  @override
  String get kindFuelCostHigh => 'Running cost higher than usual';

  @override
  String get kindOdoGps => 'Odometer higher than GPS';

  @override
  String get kindDocExpiring => 'Document expiring';

  @override
  String get kindDocExpired => 'Document expired';

  @override
  String get kindCancellationRequested => 'Cancellation requested';

  @override
  String get kindGpsCoverageLow => 'Poor GPS coverage';

  @override
  String alertVehicle({
    required String registrationNo,
    required String model,
    required String fuel,
  }) {
    return '$registrationNo ($model, $fuel)';
  }

  @override
  String get alertFuelPetrol => 'petrol';

  @override
  String get alertFuelDiesel => 'diesel';

  @override
  String get alertFuelCng => 'CNG';

  @override
  String get alertFuelPetrolCng => 'petrol + CNG';

  @override
  String alertFuelEfficiencyTitle({required String vehicle}) {
    return '$vehicle used more fuel than usual';
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
    return 'Between $from and $to it ran $km km on $used $unit of $fuel, which is $value km/$unit. This car usually does about $baseline km/$unit, so this is $worse% worse than normal. That\'s roughly $extra $unit (about $extraCost) more $fuel than expected.';
  }

  @override
  String alertFuelCostTitle({required String vehicle}) {
    return '$vehicle cost more to run than usual';
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
    return 'Between $from and $to it ran $km km for $cost of fuel, which is $perKm/km. This car usually costs about $usualPerKm/km, so this is $worse% more than normal.';
  }

  @override
  String alertPetrolShare({required String amount}) {
    return '$amount of that was petrol.';
  }

  @override
  String alertFillsLoggedBy({required String names}) {
    return 'Fills in this period were logged by $names.';
  }

  @override
  String get alertCheckReceiptsOdometer =>
      'Check the receipts and odometer photos.';

  @override
  String get alertCheckPetrolReceipts =>
      'Check whether the car was run on petrol unnecessarily, and check the receipts.';

  @override
  String alertOdoGpsTitle({
    required String date,
    required String route,
    required String vehicle,
  }) {
    return 'Trip on $date ($route, $vehicle) shows more km on the odometer than the GPS route';
  }

  @override
  String get alertOdoGpsVehicleUnknown => 'vehicle';

  @override
  String alertOdoGpsBody({
    required String odometer,
    required String gps,
    required String excess,
    required String tolerance,
  }) {
    return 'The odometer readings say $odometer km, but the phone\'s GPS recorded $gps km. The odometer distance is $excess% higher; the allowed difference is $tolerance%. Check the start and end odometer photos.';
  }

  @override
  String alertDocExpiredTitle({required String doc, required String subject}) {
    return '$doc for $subject has expired';
  }

  @override
  String alertDocExpiredBody({
    required String doc,
    required String subject,
    required String date,
  }) {
    return '$doc for $subject expired on $date. Operating without it risks fines and insurance claims being rejected. Renew it and upload the new copy.';
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
      other: '$doc for $subject expires in $count days',
      one: '$doc for $subject expires tomorrow',
      zero: '$doc for $subject expires today',
    );
    return '$_temp0';
  }

  @override
  String alertDocExpiringBody({
    required String doc,
    required String subject,
    required String date,
  }) {
    return '$doc for $subject expires on $date. Renew it and upload the new copy before then.';
  }

  @override
  String alertCancellationTitle({required String from}) {
    return 'Cancellation requested for the trip from $from';
  }

  @override
  String alertCancellationBody({
    required String driver,
    required String reason,
    required String km,
  }) {
    return '$driver asked to cancel this running trip: \"$reason\". The odometer read $km km. Approve (optionally with a cancellation fare) or reject it on the trip page.';
  }

  @override
  String get alertTheDriver => 'The driver';

  @override
  String get reviewIntro =>
      'Items where Fleet Sarthi isn’t sure. Nothing here blocked the driver; your decision corrects the record.';

  @override
  String get nothingToReview => 'Nothing to review';

  @override
  String get noItems => 'No items';

  @override
  String get reviewOcrOdometer =>
      'Odometer photo doesn’t match the typed reading';

  @override
  String get reviewOcrReceipt => 'Receipt doesn’t match the typed amount';

  @override
  String get reviewOdometerRegression => 'Odometer went backwards';

  @override
  String get reviewImplausibleEfficiency => 'Fuel figures look implausible';

  @override
  String get reviewMockLocation => 'Fake GPS location detected';

  @override
  String get reviewOrphanEvidence => 'Photo from a cancelled trip';

  @override
  String get reviewClockSkew => 'Phone clock was wrong';

  @override
  String get reviewUploadMismatch => 'Uploaded file didn’t match';

  @override
  String get reviewKeptTyped => 'Kept typed value';

  @override
  String get reviewUsedPhoto => 'Used photo value';

  @override
  String get reviewCorrected => 'Corrected';

  @override
  String get typedByDriver => 'Typed by the driver';

  @override
  String get readFromThePhoto => 'Read from the photo';

  @override
  String get keepTyped => 'Keep typed value';

  @override
  String get usePhotoValue => 'Use value from photo';

  @override
  String get enterCorrectValue => 'Enter correct value';

  @override
  String get markReviewed => 'Mark reviewed';

  @override
  String get correctValueTitle => 'Enter the correct value';

  @override
  String get odometerKmLabel => 'Odometer (km)';

  @override
  String get correctionHint =>
      'Fuel and distance checks are recalculated with this value.';

  @override
  String get saveCorrection => 'Save correction';

  @override
  String get reasonOdometerNotIncreasing =>
      'The odometer reading at the closing fill is not higher than at the opening fill.';

  @override
  String get reasonDistanceTooLong =>
      'More than 3,000 km passed between two full-tank fills, so some fills were probably not logged.';

  @override
  String get reasonImplausiblyGood =>
      'The efficiency is far better than this car normally manages, which usually means a fill was not logged.';

  @override
  String get reasonNoFuel =>
      'No fuel was recorded between the two full-tank fills.';

  @override
  String get settlementsIntro =>
      'One row per driver for the day (IST). Drafts update as trips and payments sync.';

  @override
  String noActivity({required String date}) {
    return 'No driver activity on $date';
  }

  @override
  String tripsCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trips',
      one: '1 trip',
    );
    return '$_temp0';
  }

  @override
  String get expected => 'Expected';

  @override
  String get online => 'Online';

  @override
  String get expenses => 'Expenses';

  @override
  String get earnings => 'Earnings';

  @override
  String get lateItems => 'Late items';

  @override
  String get net => 'Net';

  @override
  String get draft => 'Draft';

  @override
  String shortfall({required String amount}) {
    return 'Shortfall $amount';
  }

  @override
  String get expectedFare => 'Expected fare';

  @override
  String get cashCollected => 'Cash collected';

  @override
  String get onlineToYou => 'Online (to you)';

  @override
  String get driversExpenses => 'Driver’s expenses';

  @override
  String get driversEarnings => 'Driver’s earnings';

  @override
  String get shortfallLabel => 'Shortfall';

  @override
  String get shortfallHint => 'Expected fare minus everything collected';

  @override
  String get settlementLabel => 'Settlement';

  @override
  String get netFormula =>
      'Net = cash collected − expenses the driver paid − driver’s earnings ± late items from already-settled days.';

  @override
  String driverPaysYou({required String amount}) {
    return 'Driver pays you $amount';
  }

  @override
  String youPayDriver({required String amount}) {
    return 'You pay the driver $amount';
  }

  @override
  String get nothingToHandOver => 'Nothing to hand over';

  @override
  String settledOn({required String when}) {
    return 'Settled $when. Later changes carry into the next day.';
  }

  @override
  String get markSettledHint =>
      'Mark settled once you’ve received the cash. This locks the day.';

  @override
  String get markSettled => 'Mark settled';

  @override
  String lateFrom({required String date}) {
    return 'From $date, synced after that day was settled';
  }

  @override
  String get lineTrip => 'Trip';

  @override
  String get lineCharge => 'Charge';

  @override
  String get linePayment => 'Payment';

  @override
  String get lineFuel => 'Fuel';

  @override
  String get lineAdjustment => 'Late item';

  @override
  String itemTripVehicle({
    required String route,
    required String registrationNo,
  }) {
    return '$route ($registrationNo)';
  }

  @override
  String itemCancelled({required String text}) {
    return '$text · cancelled';
  }

  @override
  String itemChargeDriverPaid({required String kind}) {
    return '$kind, paid by the driver';
  }

  @override
  String itemChargeBilled({required String kind}) {
    return '$kind, billed to the customer';
  }

  @override
  String itemChargeExtraFare({required String kind}) {
    return '$kind, extra fare';
  }

  @override
  String itemOnTrip({required String text, required String route}) {
    return '$text · $route';
  }

  @override
  String itemPayment({required String method}) {
    return '$method payment';
  }

  @override
  String itemReference({required String text, required String reference}) {
    return '$text (ref $reference)';
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
  String get auditThresholds => 'Audit thresholds';

  @override
  String get fuelKSigma => 'Fuel alert sensitivity (k σ)';

  @override
  String get fuelKSigmaHint =>
      'Flag a cycle this many standard deviations worse than usual. Lower = more alerts.';

  @override
  String get fuelMinCycles => 'Cycles before using σ';

  @override
  String get fuelMinCyclesHint =>
      'New vehicles use the percent rule until they have this many normal cycles.';

  @override
  String get fuelPct => 'New-vehicle threshold (%)';

  @override
  String get fuelPctHint =>
      'For new vehicles, flag a cycle this much worse than the usual figure.';

  @override
  String get fuelAlpha => 'Baseline responsiveness (α)';

  @override
  String get fuelAlphaHint =>
      'How quickly the usual figure follows recent cycles (0.05–0.9).';

  @override
  String get odoTolerance => 'Odometer vs GPS tolerance (%)';

  @override
  String get odoToleranceHint =>
      'Flag trips whose odometer distance exceeds the GPS route by more than this.';

  @override
  String get docAlertDays => 'Document alert days';

  @override
  String get docAlertDaysHint =>
      'Comma-separated, e.g. 30, 7, 1. An alert is also raised on expiry.';

  @override
  String get checkThresholds =>
      'Check the values: some are outside the allowed range.';

  @override
  String get savedThresholds =>
      'Saved. Fuel audits use the new thresholds from the next recompute.';

  @override
  String get saveThresholds => 'Save thresholds';

  @override
  String get defaultDriverPay => 'Default driver pay';

  @override
  String get defaultPayIntro =>
      'Used in settlements for every driver without their own pay rule.';

  @override
  String get savedPay => 'Saved. Days that are already settled don’t change.';

  @override
  String get saveDefaultPay => 'Save default pay';

  @override
  String get settingsOwnerOnly => 'Only the owner can change settings.';

  @override
  String signedInAs({required String name, required String roles}) {
    return '$name · $roles';
  }

  @override
  String get password => 'Password';

  @override
  String get logIn => 'Log in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get newHereSignUp => 'New to Fleet Sarthi? Sign up';

  @override
  String get haveAccountLogIn => 'Already have an account? Log in';

  @override
  String get backToLogIn => 'Back to log in';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get signUpIntro =>
      'Choose a password for your mobile number. Drivers use the number their fleet owner registered.';

  @override
  String get createAccount => 'Create account';

  @override
  String get yourNameOptional => 'Your name (optional)';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Type the password again';

  @override
  String get currentPassword => 'Current password';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get passwordTooShort => 'Use at least 8 characters.';

  @override
  String get passwordTooLong => 'Use at most 128 characters.';

  @override
  String get passwordsDontMatch => 'The two passwords don\'t match.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get resetPasswordTitle => 'Reset your password';

  @override
  String get resetPasswordIntro =>
      'We\'ll send a reset code for your mobile number. Then choose a new password.';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get saveAndLogIn => 'Save password and log in';

  @override
  String get resendCode => 'Resend code';

  @override
  String resendCodeIn({required String seconds}) {
    return 'Resend code in $seconds s';
  }

  @override
  String get codeResent => 'We sent a new code.';

  @override
  String get resetCodeInApiLog =>
      'Testing locally or on the demo? The code isn\'t sent by SMS: it\'s printed in the API server\'s log.';

  @override
  String get accountSecurity => 'Account security';

  @override
  String get signInMethods => 'How you sign in';

  @override
  String get passwordIsSet => 'Set';

  @override
  String get passwordNotSet => 'Not set yet';

  @override
  String get setPassword => 'Set a password';

  @override
  String get setPasswordIntro =>
      'Then you can log in with your mobile number and password.';

  @override
  String get changePassword => 'Change password';

  @override
  String get savePassword => 'Save password';

  @override
  String get passwordSaved => 'Password saved';

  @override
  String get currentPasswordWrong => 'Your current password is wrong.';

  @override
  String get editDrivers => 'Edit drivers';

  @override
  String get editVehicles => 'Edit vehicles';

  @override
  String get noLinkedDrivers =>
      'No drivers linked yet. Trips in this vehicle can only go to a linked driver.';

  @override
  String get noLinkedVehicles =>
      'No vehicles linked yet. This driver can only get trips in a linked vehicle.';

  @override
  String editDriversIntro({required String vehicle}) {
    return 'Who may drive $vehicle? Trips can only pair it with these drivers.';
  }

  @override
  String editVehiclesIntro({required String name}) {
    return 'Which vehicles may $name drive? They can only get trips in these.';
  }

  @override
  String get driversOptional => 'Drivers (optional)';

  @override
  String get vehiclesOptional => 'Vehicles (optional)';

  @override
  String get driversOptionalHint =>
      'Who may drive it. You can change this later.';

  @override
  String get vehiclesOptionalHint =>
      'Which vehicles they may drive. You can change this later.';

  @override
  String get noneSelected => 'None yet';

  @override
  String get noDriversToLink => 'No drivers yet. Invite a driver first.';

  @override
  String get noVehiclesToLink => 'No vehicles yet. Add a vehicle first.';

  @override
  String get vehicleHasNoDrivers =>
      'No drivers are linked to this vehicle. Link drivers on the vehicle\'s page first.';

  @override
  String get driverHasNoVehicles =>
      'No vehicles are linked to this driver. Link vehicles on the driver\'s page first.';

  @override
  String get noVehiclesLinkedToYou =>
      'No vehicles are linked to you yet. Ask your fleet owner to link you to a vehicle.';

  @override
  String get noVehiclesLinkedHint =>
      'If you\'re offline, connect to the internet once so the app can load them.';

  @override
  String get errorDriverNotLinked =>
      'The driver isn\'t linked to this vehicle. The owner can link them on the vehicle\'s page.';

  @override
  String errorDriverNotLinkedNamed({
    required String driver,
    required String vehicle,
  }) {
    return '$driver isn\'t linked to $vehicle. Link them on the vehicle\'s page first.';
  }

  @override
  String get errorLinkInUse =>
      'The driver has assigned or running trips in this vehicle. Reassign or finish them before unlinking.';

  @override
  String errorLinkInUseCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The driver has $count assigned or running trips in this vehicle. Reassign or finish them before unlinking.',
      one:
          'The driver has 1 assigned or running trip in this vehicle. Reassign or finish it before unlinking.',
    );
    return '$_temp0';
  }

  @override
  String get switchWorkspace => 'Switch mode or fleet';

  @override
  String workspaceManage({required String fleet}) {
    return 'Manage $fleet';
  }

  @override
  String workspaceDrive({required String fleet}) {
    return 'Drive for $fleet';
  }

  @override
  String get workspaceManageHint =>
      'Owner mode: vehicles, drivers, trips and money';

  @override
  String get workspaceDriveHint => 'Driver mode: your trips, fuel and photos';

  @override
  String get setUpMyFleet => 'I own vehicles: set up my fleet';

  @override
  String unsyncedBeforeSwitch({required int count}) {
    return '$count trip updates on this phone haven\'t been sent yet. Go online, let them sync, then switch.';
  }

  @override
  String get getStartedTitle => 'Welcome to Fleet Sarthi';

  @override
  String get getStartedDriveTitle => 'Drive for a vehicle owner';

  @override
  String getStartedDriveBody({required String phone}) {
    return 'Ask the owner to add $phone as a driver in their Fleet Sarthi. Then tap Check again.';
  }

  @override
  String get checkAgain => 'Check again';

  @override
  String get stillNoFleet => 'No owner has added you yet.';

  @override
  String get getStartedOwnTitle => 'Own vehicles?';

  @override
  String get getStartedOwnBody =>
      'Set up your fleet to add vehicles and drivers. You can still drive for other owners from the same account.';

  @override
  String get createFleetTitle => 'Set up your fleet';

  @override
  String get fleetNameLabel => 'Fleet or business name';

  @override
  String get fleetNameTooShort => 'Enter at least 2 characters';

  @override
  String get iDriveToo => 'I also drive my own vehicles';

  @override
  String get createFleet => 'Create fleet';

  @override
  String get addMapPin => 'Add map pin';

  @override
  String get changePin => 'Change';

  @override
  String get removePin => 'Remove pin';

  @override
  String get pickupOnMap => 'Pickup on the map';

  @override
  String get dropOnMap => 'Drop on the map';

  @override
  String get pinPickerHint =>
      'Tap the map to drop the pin. Tap again to move it.';

  @override
  String get usePin => 'Use this pin';

  @override
  String get navGroupOverview => 'Overview';

  @override
  String get navGroupFleet => 'Fleet';

  @override
  String get navGroupMoney => 'Money';

  @override
  String get navGroupSetup => 'Setup';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get colRoute => 'Route';

  @override
  String get colCustomer => 'Customer';

  @override
  String get colFare => 'Fare';

  @override
  String get colDocument => 'Document';

  @override
  String get colFor => 'For';

  @override
  String get colNumber => 'Number';

  @override
  String get colRole => 'Role';

  @override
  String get colBalance => 'Balance';

  @override
  String get colShortfall => 'Short';

  @override
  String get usualEfficiency => 'Usual efficiency';

  @override
  String get alertsInbox => 'Alerts & review';

  @override
  String get documentsExpiredChip => 'Document expired';

  @override
  String get documentsDueChip => 'Document due';

  @override
  String get managersSection => 'Managers';

  @override
  String get noManagersYet => 'No managers yet.';

  @override
  String get shareTripHeading => 'Trip details';

  @override
  String get shareCustomer => 'Customer';

  @override
  String get sharePickup => 'Pickup';

  @override
  String get shareDrop => 'Drop';

  @override
  String get sharePickupTime => 'Pickup time';

  @override
  String get shareCab => 'Cab';

  @override
  String get shareDriver => 'Driver';

  @override
  String get shareFare => 'Fare';

  @override
  String shareFareWithKm({required String fare, required String km}) {
    return '$fare ($km included)';
  }

  @override
  String get copyDetails => 'Copy details';

  @override
  String get detailsCopied => 'Trip details copied';

  @override
  String get shareOnWhatsApp => 'Send on WhatsApp';

  @override
  String get whatsAppUnavailable => 'Couldn\'t open WhatsApp';

  @override
  String get analytics => 'Analytics';

  @override
  String get analyticsIntro =>
      'Daily fuel bought, revenue and km for the month, by vehicle.';

  @override
  String get month => 'Month';

  @override
  String get perTripAverages => 'Average per trip';

  @override
  String get avgKmPerTrip => 'Km per trip';

  @override
  String get avgRevenuePerTrip => 'Revenue per trip';

  @override
  String get avgFuelCostPerTrip => 'Fuel cost per trip (est.)';

  @override
  String tripsInMonth({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trips this month',
      one: '1 trip this month',
    );
    return '$_temp0';
  }

  @override
  String get fuelBoughtPerDay => 'Fuel bought per day';

  @override
  String get revenuePerDay => 'Revenue per day';

  @override
  String get kmPerDay => 'Km driven per day';

  @override
  String monthTotal({required String total}) {
    return 'Month total: $total';
  }

  @override
  String get fuelInRupeesNote =>
      'Shown in ₹, since litres and kg can\'t be added together.';

  @override
  String get noActivityThisMonth => 'Nothing this month.';

  @override
  String get customDay => 'Custom';

  @override
  String tripsOnDay({required String date}) {
    return 'Trips on $date';
  }

  @override
  String get availableCabs => 'Available cabs';

  @override
  String get availableDrivers => 'Available drivers';

  @override
  String get tripsUnassigned => 'Trips unassigned';

  @override
  String get completedTrips => 'Completed trips';

  @override
  String percentReady({required int percent}) {
    return '$percent% ready';
  }

  @override
  String cabsFooter({required int onTrip, required int inactive}) {
    return '$onTrip on trip · $inactive inactive';
  }

  @override
  String driversFooter({required int onTrip, required int assigned}) {
    return '$onTrip on trip · $assigned assigned';
  }

  @override
  String get standby => 'Standby';

  @override
  String get needsCab => 'Needs cab';

  @override
  String get pending => 'pending';

  @override
  String get resolveQueue => 'Resolve queue';

  @override
  String get runs => 'runs';

  @override
  String grossFare({required String amount}) {
    return '$amount gross fare';
  }

  @override
  String busyFromTo({required String from, required String to}) {
    return 'Busy $from – $to';
  }

  @override
  String get busyPickCleared =>
      'The vehicle or driver you picked is booked at the new time, so it was cleared.';

  @override
  String get busyPickWarning =>
      'This vehicle or driver is already booked at this time.';

  @override
  String get uploadFile => 'Upload file';

  @override
  String get chooseOtherFile => 'Choose another file';

  @override
  String get uploadFileHint =>
      'Or upload a PDF or image (JPG, PNG, WebP), up to 15 MB.';

  @override
  String get fileTooLarge => 'That file is larger than 15 MB.';

  @override
  String get pdfDocument => 'PDF document';

  @override
  String get imageFile => 'Image';

  @override
  String get viewDocument => 'View document';

  @override
  String get documentUnavailable => 'Couldn\'t open the document. Try again.';

  @override
  String get schedule => 'Schedule';

  @override
  String get noTripsThisDay => 'No trips this day.';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get logInWithOtp => 'Log in with OTP';

  @override
  String get noAccountForNumber =>
      'No account with this number yet. Sign up instead.';

  @override
  String get signUpVerifyHint =>
      'We\'ll send an OTP to confirm the number is yours.';

  @override
  String get verifyAndCreateAccount => 'Verify number & create account';

  @override
  String get resetWithOtpIntro =>
      'Verify your mobile number with an OTP, then choose a new password.';

  @override
  String get numberVerified => 'Number verified';

  @override
  String get verifyWithOtp => 'Verify with OTP';

  @override
  String get phoneVerifyTitle => 'Verify your number';

  @override
  String get stubVerifyHint =>
      'Test mode: no SMS is sent. The number below counts as verified.';

  @override
  String get errorPhoneOtpDisabled => 'OTP sign-in isn\'t available right now.';

  @override
  String get errorPhoneNotVerified =>
      'Couldn\'t verify your number. Try again.';

  @override
  String get errorPhoneMismatch =>
      'The number you verified isn\'t the one you entered.';

  @override
  String get errorPhoneVerificationRequired =>
      'Verify your mobile number to sign up.';

  @override
  String get verify => 'Verify';

  @override
  String get allowPopups =>
      'Allow pop-ups for this site to verify your number, then try again.';

  @override
  String get tripInProgress => 'Trip in progress';

  @override
  String get nextTrip => 'Next trip';

  @override
  String startsIn({required String time}) {
    return 'Starts in $time';
  }

  @override
  String get startingNow => 'Starting now';

  @override
  String runningLate({required String time}) {
    return '$time late';
  }

  @override
  String get todayAtAGlance => 'Today at a glance';

  @override
  String get lastSevenDays => 'Last 7 days';

  @override
  String get statTripsDone => 'Trips done';

  @override
  String get statKmDriven => 'Km driven';

  @override
  String get statCollected => 'Collected';

  @override
  String ofTotal({required int done, required int total}) {
    return '$done of $total';
  }

  @override
  String cashAmount({required String amount}) {
    return 'Cash $amount';
  }

  @override
  String get callCustomer => 'Call';

  @override
  String get directions => 'Directions';

  @override
  String kmSoFar({required String km}) {
    return '$km so far';
  }

  @override
  String durationHm({required int h, required String m}) {
    return '$h h $m min';
  }

  @override
  String durationM({required int m}) {
    return '$m min';
  }

  @override
  String get syncNow => 'Sync now';

  @override
  String get noTripsAssigned => 'No trips assigned yet';

  @override
  String get noTripsHint =>
      'When your fleet owner assigns a trip, it shows up here. Pull down to refresh, or start one yourself.';

  @override
  String get detailsTab => 'Details';

  @override
  String get documentFiles => 'Files (photos or PDFs)';

  @override
  String photoNumber({required int number}) {
    return 'Photo $number';
  }

  @override
  String tooManyFiles({required int count}) {
    return 'A document can have up to $count files.';
  }

  @override
  String fileTooLargeNamed({required String name}) {
    return '$name is larger than 15 MB.';
  }

  @override
  String get uploadFiles => 'Upload files';

  @override
  String viewFiles({required int count}) {
    return 'View files ($count)';
  }

  @override
  String get open => 'Open';

  @override
  String get filters => 'Filters';

  @override
  String filtersCount({required int count}) {
    return 'Filters ($count)';
  }

  @override
  String get clearAll => 'Clear all';

  @override
  String get apply => 'Apply';

  @override
  String get severity => 'Severity';

  @override
  String get alertKindTitle => 'Type';

  @override
  String get quickOpsHub => 'Quick Operations Hub';

  @override
  String get fastDispatch => 'FAST-DISPATCH';

  @override
  String get addTrip => 'Add Trip';

  @override
  String get tagDriver => 'Tag Driver';

  @override
  String get addDriverQuick => '+ Add Driver';

  @override
  String get addCabQuick => '+ Add Cab';

  @override
  String get scheduledRides => 'Scheduled rides';

  @override
  String scheduledRidesOn({required String date}) {
    return 'Scheduled rides · $date';
  }

  @override
  String get noTripsWaiting => 'No trips waiting for a driver.';

  @override
  String get pickTripToAssign => 'Pick a trip to assign';

  @override
  String get docAadhaar => 'Aadhaar card';

  @override
  String get docPan => 'PAN card';

  @override
  String get docPoliceVerification => 'Police verification';

  @override
  String get docBadge => 'Badge / PSV licence';

  @override
  String get docPhoto => 'Photo';

  @override
  String get noExpiry => 'No expiry';

  @override
  String get docPendingApproval => 'Waiting for approval';

  @override
  String get docRejected => 'Rejected';

  @override
  String docRejectedBecause({required String note}) {
    return 'Rejected: $note';
  }

  @override
  String get addedByDriver => 'Added by driver';

  @override
  String get renewalOf => 'Renewal';

  @override
  String get approveDocument => 'Approve';

  @override
  String get rejectDocument => 'Reject';

  @override
  String get rejectDocumentTitle => 'Reject this document?';

  @override
  String get rejectReasonLabel => 'Reason (the driver sees this)';

  @override
  String get documentApproved => 'Document approved';

  @override
  String get kindDocSubmitted => 'Document to approve';

  @override
  String alertDocSubmittedTitle({required String driver, required String doc}) {
    return '$driver added their $doc';
  }

  @override
  String alertDocRenewedTitle({required String driver, required String doc}) {
    return '$driver uploaded a renewed $doc';
  }

  @override
  String get alertDocSubmittedBody =>
      'Check it and approve or reject it on their Documents tab.';

  @override
  String get navHome => 'Home';

  @override
  String get navMyDocuments => 'Documents';

  @override
  String get navProfile => 'Profile';

  @override
  String get assignedTab => 'Assigned';

  @override
  String get pastTab => 'Past';

  @override
  String get noAssignedTrips => 'No trips assigned to you right now.';

  @override
  String get noPastTrips => 'No trips this month.';

  @override
  String get myDocumentsIntro =>
      'Add your licence, Aadhaar and other papers. Your fleet owner checks each one before it counts.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editName => 'Edit name';

  @override
  String get yourName => 'Your name';

  @override
  String get nameSaved => 'Name saved';

  @override
  String get fleetLabel => 'Fleet';

  @override
  String get phoneNumberLabel => 'Mobile number';

  @override
  String get cabsYouDrive => 'Cabs you can drive';

  @override
  String get noCabsLinked => 'No cabs linked yet. Ask your fleet owner.';

  @override
  String driverSince({required String date}) {
    return 'Driver since $date';
  }

  @override
  String get when => 'When';

  @override
  String confirmUpload({required int count}) {
    return 'Confirm upload ($count)';
  }

  @override
  String get fileReadyToUpload => 'Selected · not uploaded yet';

  @override
  String get fileUploading => 'Uploading…';

  @override
  String get fileUploaded => 'Uploaded';

  @override
  String get fileUploadFailed => 'Upload failed · try again';

  @override
  String get uploadFilesFirst =>
      'Tap Confirm upload to upload the selected files first.';

  @override
  String filesUploadedCount({required int count}) {
    return '$count files uploaded';
  }

  @override
  String get colFiles => 'Files';

  @override
  String get noFiles => 'No files';

  @override
  String get fixHighlighted => 'Fill in the highlighted fields.';

  @override
  String get documentSentForApproval =>
      'Document added. Your fleet owner will approve it.';

  @override
  String get documentSaved => 'Document saved';

  @override
  String uploadAndSave({required int count}) {
    return 'Upload $count files & save';
  }

  @override
  String get photoMustBeImage => 'Pick a photo (JPG, PNG or WebP).';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get invalidMobile => 'Enter a 10-digit mobile number';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get emailLabel => 'Email';

  @override
  String get addressLabel => 'Address';

  @override
  String get emergencyContact => 'Emergency contact';

  @override
  String get contactName => 'Contact name';

  @override
  String get contactPhone => 'Contact mobile number';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editDetails => 'Edit details';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get changePhone => 'Change mobile number';

  @override
  String get changePhoneIntro =>
      'Your mobile number is how you log in. We’ll send a code to the new number to check it’s yours.';

  @override
  String codeSentTo({required String phone}) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get verifyAndChange => 'Verify & change';

  @override
  String get phoneChanged => 'Mobile number changed';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get personalDetails => 'Personal details';

  @override
  String get discardDocumentTitle => 'Discard this document?';

  @override
  String get discardDocumentBody =>
      'It hasn’t been saved. The files and details you added will be lost.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String uploadingStep({required int n, required int count}) {
    return 'Uploading $n of $count…';
  }

  @override
  String get savingStep => 'Saving…';

  @override
  String get welcomeSignIn => 'Sign in';

  @override
  String get welcomeGetStarted => 'Get started';

  @override
  String get welcomeHaveAccount => 'I have an account';

  @override
  String get welcomeAbout => 'What is Fleet Sarthi?';

  @override
  String get welcomeEyebrow => 'For owner-drivers and fleets of 2–15 cars';

  @override
  String get welcomeHeadlineLead => 'Know what your cars';

  @override
  String get welcomeHeadlineAccent => 'really did today.';

  @override
  String get welcomeSubhead =>
      'Photo-proof trips, fuel checked against each car\'s own mileage, GPS distance checks and a daily cash settlement for every driver. One app for you and your drivers.';

  @override
  String get welcomeTrustOffline => 'Works offline';

  @override
  String get welcomeTrustPlatforms => 'Android & web';

  @override
  String get welcomeTrustLanguages => 'English & हिन्दी';

  @override
  String get welcomeTrustNoCard => 'No card needed';

  @override
  String get welcomeMockToday => 'Today';

  @override
  String get welcomeMockLive => 'Live';

  @override
  String get welcomeMockTrips => 'Trips';

  @override
  String get welcomeMockKm => 'Km driven';

  @override
  String get welcomeMockCash => 'Cash due';

  @override
  String get welcomeMockMileage => 'Mileage, last 8 fills';

  @override
  String get welcomeMockFuelTitle => 'Fuel check';

  @override
  String get welcomeMockFuelBody =>
      'MH 12 AB 4521 gave 9.1 km/l, 22% below its usual 11.7';

  @override
  String get welcomeMockGpsTitle => 'Distance verified';

  @override
  String get welcomeMockGpsBody => 'Pune → Mumbai: GPS 148 km, odometer 151 km';

  @override
  String get welcomeMockSettleTitle => 'Ramesh · settle today';

  @override
  String get welcomeMockSettleBody => 'Fare ₹4,200 − expenses ₹640';

  @override
  String get welcomeBuiltFor => 'Made for';

  @override
  String get welcomeForDco => 'Owner-drivers (DCOs)';

  @override
  String get welcomeForSmallFleets => 'Fleets of 2–15 cars';

  @override
  String get welcomeForIntercity => 'Intercity & outstation';

  @override
  String get welcomeForLocal => 'Local & airport runs';

  @override
  String get welcomeFeaturesKicker => 'Everything in one app';

  @override
  String get welcomeFeaturesTitle =>
      'Built for the way Indian cab fleets really run';

  @override
  String get welcomeFeatureFuelTitle => 'Fuel audit';

  @override
  String get welcomeFeatureFuelBody =>
      'Mileage per car against its own baseline, or cost per km for petrol + CNG cars.';

  @override
  String get welcomeFeatureTripsTitle => 'Trips with proof';

  @override
  String get welcomeFeatureTripsBody =>
      'Create and assign trips, then see odometer photos and the GPS route on a map.';

  @override
  String get welcomeFeatureSettleTitle => 'Daily settlement';

  @override
  String get welcomeFeatureSettleBody =>
      'Fare, cash, online payments, expenses and your pay rules, worked out to one net amount.';

  @override
  String get welcomeFeatureDocsTitle => 'Document reminders';

  @override
  String get welcomeFeatureDocsBody =>
      'RC, insurance, permit, PUC and licence: alerts 30, 7 and 1 day before they expire.';

  @override
  String get welcomeFeatureOfflineTitle => 'Works without signal';

  @override
  String get welcomeFeatureOfflineBody =>
      'The driver app keeps recording on ghat roads and highways, and syncs when the network returns.';

  @override
  String get welcomeFeatureDcoTitle => 'Own and drive';

  @override
  String get welcomeFeatureDcoBody =>
      'Run your fleet and drive in someone else\'s from the same account. Switch in one tap.';

  @override
  String get welcomeStepsKicker => 'How it works';

  @override
  String get welcomeStepsTitle => 'Up and running before your next trip';

  @override
  String get welcomeStep1Title => 'Add your cars and drivers';

  @override
  String get welcomeStep1Body =>
      'Sign up with your mobile number, add vehicles and add drivers by their number.';

  @override
  String get welcomeStep2Title => 'Drivers record from their phone';

  @override
  String get welcomeStep2Body =>
      'Start and end trips with a meter photo, log fuel with the receipt, add tolls and cash.';

  @override
  String get welcomeStep3Title => 'You see the truth, daily';

  @override
  String get welcomeStep3Body =>
      'Alerts when something looks off, and a settlement for each driver at the end of the day.';

  @override
  String get welcomeOwnersTitle => 'For owners';

  @override
  String get welcomeOwners1 => 'Every car and driver on one dashboard';

  @override
  String get welcomeOwners2 => 'Approve cancellations and review flagged trips';

  @override
  String get welcomeOwners3 => 'Set pay rules once; settlements follow them';

  @override
  String get welcomeOwners4 => 'Use it on your phone or a laptop';

  @override
  String get welcomeDriversTitle => 'For drivers';

  @override
  String get welcomeDrivers1 => 'Simple screens in Hindi or English';

  @override
  String get welcomeDrivers2 => 'Today\'s trips in order, one tap to start';

  @override
  String get welcomeDrivers3 => 'Nothing lost when the network drops';

  @override
  String get welcomeDrivers4 => 'Licence and documents kept up to date';

  @override
  String get welcomeFaqTitle => 'Questions owners ask';

  @override
  String get welcomeFaqOfflineQ => 'Do my drivers need internet all the time?';

  @override
  String get welcomeFaqOfflineA =>
      'No. The driver app saves everything on the phone and sends it in order when the network is back.';

  @override
  String get welcomeFaqDcoQ => 'Can I use it if I drive my own car?';

  @override
  String get welcomeFaqDcoA =>
      'Yes. Owner-drivers get both the owner screens and the driver screens, and switch between them.';

  @override
  String get welcomeFaqPrivacyQ => 'Is my fleet\'s data private?';

  @override
  String get welcomeFaqPrivacyA =>
      'Yes. Each fleet\'s data is kept separate, right down to the database, and only the people you add can see it.';

  @override
  String get welcomeFaqPhoneQ => 'What phone does a driver need?';

  @override
  String get welcomeFaqPhoneA =>
      'Any Android phone with a camera. Owners can also use Fleet Sarthi in a web browser.';

  @override
  String get welcomeFaqLanguageQ => 'Is it available in Hindi?';

  @override
  String get welcomeFaqLanguageA =>
      'Yes. Every screen is in Hindi and English; change the language any time from the top of the screen.';

  @override
  String get welcomeFinalTitle => 'Stop guessing. Start knowing.';

  @override
  String get welcomeFinalBody =>
      'Set up your fleet in a few minutes with just your mobile number.';

  @override
  String get welcomeFooter => 'Made in India, for India\'s cab fleets.';

  @override
  String get welcomeShowcaseKicker => 'See it in action';

  @override
  String get welcomeShowcaseTitle =>
      'One app for the problems you deal with every day';

  @override
  String get welcomeShowcaseSubtitle =>
      'When you\'re not in the car, you\'re trusting a notebook and WhatsApp messages. Here\'s what changes.';

  @override
  String get welcomeTabFuel => 'Fuel';

  @override
  String get welcomeTabSettlement => 'Settlement';

  @override
  String get welcomeTabDocuments => 'Documents';

  @override
  String get welcomeTabOffline => 'Offline';

  @override
  String get welcomeUcFuelTitle =>
      'Catch fuel theft without standing at the pump';

  @override
  String get welcomeUcFuelBody =>
      'Drivers photograph the receipt and mark full-tank fills. Fleet Sarthi works out each car\'s own mileage, cycle by cycle, and tells you the moment one drops.';

  @override
  String get welcomeUcFuelPoint1 =>
      'A baseline for each car, not a brochure figure';

  @override
  String get welcomeUcFuelPoint2 => 'Cost per km for petrol + CNG cars';

  @override
  String get welcomeUcFuelPoint3 =>
      'Alerts in plain words, not charts to decode';

  @override
  String get welcomeUcFuelThisCycle => 'This cycle';

  @override
  String get welcomeUcFuelUsual => 'Its usual';

  @override
  String get welcomeUcTripsTitle => 'Every kilometre backed by a photo and GPS';

  @override
  String get welcomeUcTripsBody =>
      'Drivers start and end each trip with an odometer photo. The reading is checked against the photo and the GPS route, and anything that doesn\'t match waits for your review.';

  @override
  String get welcomeUcTripsPoint1 => 'Meter photos at the start and end';

  @override
  String get welcomeUcTripsPoint2 => 'The route on a map for every trip';

  @override
  String get welcomeUcTripsPoint3 => 'Mismatches go to your review queue';

  @override
  String get welcomeUcTripStart => 'Start';

  @override
  String get welcomeUcTripEnd => 'End';

  @override
  String get welcomeUcTripRoute => 'Pune → Mumbai';

  @override
  String get welcomeUcTripDriver => 'Ramesh · MH 12 AB 4521';

  @override
  String get welcomeUcTripCheck => 'GPS 148 km · odometer 151 km';

  @override
  String get welcomeUcSettleTitle => 'Settle each driver\'s day in one number';

  @override
  String get welcomeUcSettleBody =>
      'Fares, cash, UPI and card collections, tolls and parking, and your pay rule come together into one amount: what the driver hands over, or what you owe them.';

  @override
  String get welcomeUcSettlePoint1 => 'Pay rules set once per driver';

  @override
  String get welcomeUcSettlePoint2 => 'Cash and online money kept apart';

  @override
  String get welcomeUcSettlePoint3 => 'Tolls and parking with receipts';

  @override
  String get welcomeUcSettleHeader => 'Ramesh · today';

  @override
  String get welcomeUcSettleFare => 'Fare';

  @override
  String get welcomeUcSettleCash => 'Collected in cash';

  @override
  String get welcomeUcSettleOnline => 'Collected online (UPI, card)';

  @override
  String get welcomeUcSettleExpenses => 'Tolls & parking paid';

  @override
  String get welcomeUcSettlePay => 'Driver pay (30% of fare)';

  @override
  String get welcomeUcSettleNet => 'Ramesh hands over';

  @override
  String get welcomeUcDocsTitle => 'Never get caught with an expired permit';

  @override
  String get welcomeUcDocsBody =>
      'RC, insurance, permit, PUC and driving licences for every car and driver in one place, with reminders 30, 7 and 1 day before each expires.';

  @override
  String get welcomeUcDocsPoint1 => 'Every car and every driver';

  @override
  String get welcomeUcDocsPoint2 => 'Upload a photo or a PDF';

  @override
  String get welcomeUcDocsPoint3 => 'Reminded before the deadline, not after';

  @override
  String get welcomeUcDocsHeader => 'Expiring soon';

  @override
  String get welcomeUcDocsRow1 => 'MH 12 AB 4521 · Insurance';

  @override
  String get welcomeUcDocsDue1 => 'in 7 days';

  @override
  String get welcomeUcDocsRow2 => 'Suresh · Driving licence';

  @override
  String get welcomeUcDocsDue2 => 'tomorrow';

  @override
  String get welcomeUcDocsRow3 => 'MH 14 CD 7788 · Permit';

  @override
  String get welcomeUcDocsDue3 => 'in 30 days';

  @override
  String get welcomeUcDocsRow4 => 'MH 12 AB 4521 · PUC';

  @override
  String get welcomeUcDocsDue4 => 'valid';

  @override
  String get welcomeUcOfflineTitle => 'Built for highways and ghat roads';

  @override
  String get welcomeUcOfflineBody =>
      'No signal? The driver app keeps recording trips, fuel and payments on the phone and sends them in order when the network returns. Nothing is lost, and nothing is counted twice.';

  @override
  String get welcomeUcOfflinePoint1 => 'Works with no network at all';

  @override
  String get welcomeUcOfflinePoint2 => 'Syncs in order, on its own';

  @override
  String get welcomeUcOfflinePoint3 => 'Safe to retry, never duplicated';

  @override
  String get welcomeUcOfflineBanner => 'No network · saving on this phone';

  @override
  String get welcomeUcOfflineTrip => 'Trip running · Pune → Lonavala';

  @override
  String get welcomeUcOfflineFuel => 'Fuel fill saved · ₹2,150';

  @override
  String get welcomeUcOfflineCash => 'Cash collected · ₹1,200';

  @override
  String get welcomeUcOfflineWaiting => '3 changes waiting to sync';
}
