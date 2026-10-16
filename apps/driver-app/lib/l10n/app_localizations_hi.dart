// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Fleet Sarthi';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get language => 'भाषा';

  @override
  String get languageDevice => 'फ़ोन की भाषा';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सेव करें';

  @override
  String get back => 'वापस';

  @override
  String get close => 'बंद करें';

  @override
  String get optional => 'ज़रूरी नहीं';

  @override
  String get notSet => 'तय नहीं';

  @override
  String get noValue => '—';

  @override
  String somethingWentWrong({required String error}) {
    return 'कुछ गड़बड़ हो गई: $error';
  }

  @override
  String kmValue({required String km}) {
    return '$km किमी';
  }

  @override
  String get unitLitres => 'लीटर';

  @override
  String get unitKg => 'किलो';

  @override
  String get unitKm => 'किमी';

  @override
  String get today => 'आज';

  @override
  String get tomorrow => 'कल';

  @override
  String get yesterday => 'कल';

  @override
  String dayAndTime({required String day, required String time}) {
    return '$day, $time';
  }

  @override
  String get loginIntro =>
      'अपने मोबाइल नंबर से साइन इन करें। ड्राइवर वही नंबर डालें जो फ़्लीट मालिक ने दर्ज किया है।';

  @override
  String loginCodeSent({required String phone}) {
    return '$phone पर भेजा गया कोड डालें';
  }

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get sixDigitCode => '6 अंकों का कोड';

  @override
  String get sendCode => 'कोड भेजें';

  @override
  String get useDifferentNumber => 'दूसरा नंबर डालें';

  @override
  String get enterTenDigitMobile => 'अपना 10 अंकों का मोबाइल नंबर डालें';

  @override
  String get enterSixDigitCode => '6 अंकों का कोड डालें';

  @override
  String get loginCheckNumber => 'नंबर जाँचें और फिर कोशिश करें।';

  @override
  String get ownerMode => 'मालिक मोड';

  @override
  String get driverMode => 'ड्राइवर मोड';

  @override
  String get errorNetwork =>
      'इंटरनेट नहीं है। कनेक्शन जाँचें और फिर कोशिश करें।';

  @override
  String get errorValidationFailed =>
      'कुछ जानकारी सही नहीं है। जाँचकर फिर कोशिश करें।';

  @override
  String get errorUnauthenticated =>
      'आप साइन आउट हो गए हैं। फिर से साइन इन करें।';

  @override
  String get errorTokenExpired => 'आपका सेशन खत्म हो गया। फिर से साइन इन करें।';

  @override
  String get errorForbiddenRole => 'आपको यह करने की अनुमति नहीं है।';

  @override
  String get errorNoActiveOrg => 'आपका नंबर अभी किसी फ़्लीट में नहीं है।';

  @override
  String get errorNotFound => 'नहीं मिला। शायद हटा दिया गया है।';

  @override
  String get errorIllegalTransition =>
      'ट्रिप की अभी की स्थिति में यह नहीं हो सकता। रीफ़्रेश करके फिर कोशिश करें।';

  @override
  String get errorTripCancelled => 'यह ट्रिप रद्द हो चुकी है।';

  @override
  String get errorTripReassigned =>
      'यह ट्रिप किसी दूसरे ड्राइवर को दे दी गई है।';

  @override
  String get errorVehicleBusy => 'यह गाड़ी उस समय पहले से बुक है।';

  @override
  String get errorDriverBusy => 'यह ड्राइवर उस समय पहले से बुक है।';

  @override
  String get errorCancellationPending =>
      'रद्द करने का एक अनुरोध पहले से फ़ैसले का इंतज़ार कर रहा है।';

  @override
  String get errorAlreadySettled => 'उस दिन का हिसाब पहले ही हो चुका है।';

  @override
  String get errorIdempotencyConflict =>
      'यह पहले अलग जानकारी के साथ भेजा जा चुका है।';

  @override
  String get errorIdempotencyKeyRequired => 'अनुरोध अधूरा था। फिर कोशिश करें।';

  @override
  String get errorVersionConflict =>
      'किसी और ने इसी समय इसे बदल दिया। रीफ़्रेश करके फिर कोशिश करें।';

  @override
  String get errorConflict => 'यह पहले से मौजूद रिकॉर्ड से टकराता है।';

  @override
  String get errorFuelTypeMismatch => 'यह ईंधन गाड़ी के ईंधन से मेल नहीं खाता।';

  @override
  String get errorOdometerBeforeStart =>
      'ओडोमीटर रीडिंग ट्रिप शुरू होने की रीडिंग से कम है।';

  @override
  String get errorOtpInvalid => 'कोड सही नहीं है। जाँचकर फिर कोशिश करें।';

  @override
  String get errorOtpExpired => 'कोड की समय-सीमा खत्म हो गई। नया कोड मँगाएँ।';

  @override
  String get errorInvalidCredentials => 'मोबाइल नंबर या पासवर्ड ग़लत है।';

  @override
  String get errorAccountExists =>
      'इस नंबर का अकाउंट पहले से है। लॉग इन करें, या पासवर्ड रीसेट करें।';

  @override
  String get errorRateLimited =>
      'बहुत ज़्यादा कोशिशें हुईं। कुछ मिनट रुककर फिर कोशिश करें।';

  @override
  String get errorUploadNotFound =>
      'फ़ोटो अभी सर्वर तक नहीं पहुँची। थोड़ी देर में फिर कोशिश करें।';

  @override
  String get errorUploadMismatch =>
      'अपलोड की गई फ़ोटो मेल नहीं खाई। फ़ोटो दोबारा लें।';

  @override
  String get errorUploadFailed =>
      'फ़ोटो अपलोड नहीं हुई। दोबारा कोशिश की जाएगी।';

  @override
  String get errorInternal => 'सर्वर पर कुछ गड़बड़ हुई। फिर कोशिश करें।';

  @override
  String get statusCreated => 'असाइन नहीं';

  @override
  String get statusAssigned => 'असाइन';

  @override
  String get statusStarted => 'रास्ते में';

  @override
  String get statusEnded => 'खत्म';

  @override
  String get statusSettled => 'हिसाब हो गया';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get myTrips => 'मेरी ट्रिप';

  @override
  String get newTrip => 'नई ट्रिप';

  @override
  String get logFuel => 'फ़्यूल दर्ज करें';

  @override
  String get groupOnTheRoad => 'रास्ते में';

  @override
  String get groupToday => 'आज';

  @override
  String get groupUpcoming => 'आने वाली';

  @override
  String get groupRecent => 'हाल की';

  @override
  String get noTripsYet => 'अभी कोई ट्रिप नहीं। रीफ़्रेश के लिए नीचे खींचें।';

  @override
  String get conflictCancelledShort => 'मालिक ने रद्द की';

  @override
  String get conflictReassignedShort => 'दूसरे को दी गई';

  @override
  String get tripNotFoundOnPhone => 'यह ट्रिप इस फ़ोन पर नहीं मिली';

  @override
  String includesKm({required String km}) {
    return '$km किमी शामिल';
  }

  @override
  String startOdometerKm({required String km}) {
    return 'शुरू का ओडोमीटर: $km किमी';
  }

  @override
  String endOdometerKm({required String km}) {
    return 'आखिरी ओडोमीटर: $km किमी';
  }

  @override
  String get cancellationRequested => 'रद्द करने का अनुरोध भेजा';

  @override
  String get cancellationWaiting =>
      'मालिक के मंज़ूर या नामंज़ूर करने का इंतज़ार है।';

  @override
  String get charges => 'चार्ज';

  @override
  String get fuel => 'फ़्यूल';

  @override
  String get collected => 'वसूला';

  @override
  String get startTrip => 'ट्रिप शुरू करें';

  @override
  String get chargeButton => 'चार्ज';

  @override
  String get requestCancellation => 'रद्द करने का अनुरोध';

  @override
  String get endTrip => 'ट्रिप खत्म करें';

  @override
  String get conflictCancelledBanner => 'यह ट्रिप मालिक ने रद्द कर दी';

  @override
  String get conflictReassignedBanner =>
      'यह ट्रिप किसी दूसरे ड्राइवर को दे दी गई है';

  @override
  String get conflictBannerDetail =>
      'इसके लिए ऑफ़लाइन दर्ज की गई चीज़ें लागू नहीं हुईं। आपकी फ़ोटो फिर भी मालिक को भेज दी गईं।';

  @override
  String get elapsed => 'बीता समय';

  @override
  String get kmByGps => 'किमी (GPS से)';

  @override
  String get methodCash => 'नकद';

  @override
  String get methodUpi => 'UPI';

  @override
  String get methodCard => 'कार्ड';

  @override
  String get chargeToll => 'टोल';

  @override
  String get chargeParking => 'पार्किंग';

  @override
  String get chargeStateTax => 'स्टेट टैक्स';

  @override
  String get chargeDriverAllowance => 'ड्राइवर भत्ता';

  @override
  String get chargeNightCharge => 'नाइट चार्ज';

  @override
  String get chargeExtraKm => 'अतिरिक्त किमी';

  @override
  String get chargeOther => 'अन्य';

  @override
  String get chargeNoteExtraFare => 'अतिरिक्त किराया · ग्राहक देगा';

  @override
  String get chargeNotePaidByYou => 'आपने दिया · हिसाब में वापस मिलेगा';

  @override
  String get chargeNoteBilled => 'ग्राहक के बिल में';

  @override
  String get fuelPetrol => 'पेट्रोल';

  @override
  String get fuelDiesel => 'डीज़ल';

  @override
  String get fuelCng => 'CNG';

  @override
  String get fuelEv => 'EV (इलेक्ट्रिक)';

  @override
  String get evNoFuel =>
      'इलेक्ट्रिक गाड़ियों में ईंधन भरवाना और फ्यूल ऑडिट नहीं होता।';

  @override
  String get fuelPetrolCng => 'पेट्रोल + CNG';

  @override
  String get paidByChoiceMe => 'मैंने (नकद)';

  @override
  String get paidByOwner => 'मालिक';

  @override
  String get paidByFuelCard => 'फ़्यूल कार्ड';

  @override
  String get paidByLabelYou => 'आपने दिया';

  @override
  String get paidByLabelOwner => 'मालिक ने दिया';

  @override
  String get paidByLabelDriverCash => 'ड्राइवर ने नकद दिया';

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
    return '$label · टंकी फ़ुल';
  }

  @override
  String get addCharge => 'चार्ज जोड़ें';

  @override
  String get chargeType => 'प्रकार';

  @override
  String get amount => 'रकम';

  @override
  String get extraFareTitle => 'ग्राहक के किराए में जुड़ेगा';

  @override
  String get extraFareSubtitle => 'इसे किराए के साथ ग्राहक से लें।';

  @override
  String get iPaidThis => 'यह मैंने दिया';

  @override
  String get paidBackInSettlement => 'हिसाब में आपको वापस मिलेगा';

  @override
  String get receiptPhotoOptional => 'रसीद की फ़ोटो (ज़रूरी नहीं)';

  @override
  String get odometerPhoto => 'ओडोमीटर की फ़ोटो';

  @override
  String get takeOdometerPhoto => 'ओडोमीटर की फ़ोटो लें';

  @override
  String get odometerReading => 'ओडोमीटर रीडिंग';

  @override
  String get typeExactly => 'जैसा दिख रहा है, वैसा ही लिखें';

  @override
  String startedAtKm({required String km}) {
    return '$km किमी पर शुरू हुई';
  }

  @override
  String kmOverIncluded({required String over, required String included}) {
    return 'किराए में शामिल $included किमी से $over किमी ज़्यादा। नीचे अतिरिक्त किमी का चार्ज जोड़ें।';
  }

  @override
  String get chargesYouPaidOrAdded => 'आपके दिए या जोड़े गए चार्ज';

  @override
  String addedDuringTrip({required String note}) {
    return 'ट्रिप के दौरान जोड़ा · $note';
  }

  @override
  String get extraFare => 'अतिरिक्त किराया';

  @override
  String get iPaid => 'मैंने दिया';

  @override
  String get addChargeRow => 'टोल, नाइट चार्ज, अतिरिक्त किमी जोड़ें…';

  @override
  String get fuelFilledOnTrip => 'इस ट्रिप में भरा फ़्यूल';

  @override
  String fuelPaidByYouNote({required String amount}) {
    return 'आपने $amount का फ़्यूल भरवाया, यह हिसाब में आपको वापस मिलेगा; ग्राहक इसका पैसा नहीं देता।';
  }

  @override
  String customerPaidExpected({required String amount}) {
    return 'ग्राहक ने दिया · होना चाहिए $amount';
  }

  @override
  String fareBreakdownFare({required String amount}) {
    return 'किराया $amount';
  }

  @override
  String fareBreakdownExtra({required String amount}) {
    return 'अतिरिक्त किराया $amount';
  }

  @override
  String fareBreakdownExpenses({required String amount}) {
    return 'टोल और खर्च $amount';
  }

  @override
  String alreadyRecorded({required String amount}) {
    return '$amount ट्रिप के दौरान पहले ही दर्ज';
  }

  @override
  String get splitPayment => 'भुगतान बाँटें';

  @override
  String get cancelRequestIntro =>
      'मालिक इसे मंज़ूर या नामंज़ूर करेंगे। तब तक ट्रिप चलती रहेगी।';

  @override
  String get reason => 'कारण';

  @override
  String get reasonHint => 'जैसे: ग्राहक लोनावला में उतर गए';

  @override
  String get reasonRequired => 'मालिक को कारण बताएँ';

  @override
  String get sendRequest => 'अनुरोध भेजें';

  @override
  String get tripTypeOneWay => 'एक तरफ़';

  @override
  String get tripTypeRoundTrip => 'आना-जाना';

  @override
  String get tripTypeLocal => 'लोकल';

  @override
  String hours({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे',
      one: '1 घंटा',
    );
    return '$_temp0';
  }

  @override
  String get pickup => 'पिकअप';

  @override
  String get enterPickup => 'पिकअप की जगह डालें';

  @override
  String get drop => 'ड्रॉप';

  @override
  String get enterDrop => 'ड्रॉप की जगह डालें';

  @override
  String get starts => 'शुरू';

  @override
  String get expectedDuration => 'लगभग कितना समय';

  @override
  String get vehicle => 'गाड़ी';

  @override
  String get fare => 'किराया';

  @override
  String get includedKm => 'शामिल किमी';

  @override
  String get includedKmInvalid => 'किमी डालें, या खाली छोड़ें';

  @override
  String get customerNameOptional => 'ग्राहक का नाम (ज़रूरी नहीं)';

  @override
  String get customerMobileOptional => 'ग्राहक का मोबाइल (ज़रूरी नहीं)';

  @override
  String get editTrip => 'ट्रिप बदलें';

  @override
  String get createTrip => 'ट्रिप बनाएँ';

  @override
  String get newTripFootnote =>
      'यह ट्रिप आपको दी जाएगी। फ़ोन ऑनलाइन होते ही आपके फ़्लीट मालिक को दिखेगी।';

  @override
  String get fuelSaved => 'फ़्यूल दर्ज हो गया; यह अपने आप सिंक हो जाएगा';

  @override
  String get noVehicleAssigned =>
      'अभी आपको कोई गाड़ी नहीं दी गई है। फ़्यूल आपकी ट्रिप वाली गाड़ी के लिए दर्ज होता है; फ़्लीट मालिक से गाड़ी असाइन करवाएँ।';

  @override
  String get vehicleNotDownloaded =>
      'इस गाड़ी की जानकारी अभी डाउनलोड नहीं हुई। एक बार इंटरनेट से जुड़कर फिर कोशिश करें।';

  @override
  String get vehicleOnThisTrip => 'इस ट्रिप की गाड़ी';

  @override
  String fromYourTrip({required String route}) {
    return 'आपकी ट्रिप से: $route';
  }

  @override
  String get vehiclesOnYourTrips => 'आपकी ट्रिप वाली गाड़ियाँ';

  @override
  String fuelKind({required String fuel}) {
    return 'फ़्यूल: $fuel';
  }

  @override
  String get receiptPhoto => 'रसीद की फ़ोटो';

  @override
  String get takeReceiptPhoto => 'रसीद की फ़ोटो लें';

  @override
  String get quantity => 'मात्रा';

  @override
  String enterQuantity({required String unit}) {
    return 'कितने $unit भरे, डालें';
  }

  @override
  String get fullTank => 'टंकी फ़ुल';

  @override
  String get fullTankHint => 'टंकी पूरी भरी हो तो चालू करें';

  @override
  String get whoPaid => 'पैसे किसने दिए?';

  @override
  String get saveFuelFill => 'फ़्यूल सेव करें';

  @override
  String get syncStatus => 'सिंक की स्थिति';

  @override
  String get syncOffline => 'ऑफ़लाइन';

  @override
  String syncOfflineSaved({required int count}) {
    return 'ऑफ़लाइन · $count फ़ोन में सेव';
  }

  @override
  String syncPending({required int count}) {
    return '$count भेजना बाकी';
  }

  @override
  String get synced => 'सिंक हो गया';

  @override
  String needAttention({required int count}) {
    return '$count पर ध्यान दें';
  }

  @override
  String get attentionTitle => 'ये नहीं भेजे जा सके';

  @override
  String get attentionSubtitle =>
      'सर्वर ने इन्हें नहीं माना। मालिक से पूछें, या फिर कोशिश करें।';

  @override
  String get retryAll => 'सब फिर से भेजें';

  @override
  String get outboxMedia => 'फ़ोटो';

  @override
  String get outboxTripCommand => 'ट्रिप अपडेट';

  @override
  String get outboxTripCreate => 'नई ट्रिप';

  @override
  String get outboxTripCharge => 'चार्ज';

  @override
  String get outboxTripCollection => 'भुगतान';

  @override
  String get outboxFuelFill => 'फ़्यूल';

  @override
  String get noPhotoYet => 'अभी फ़ोटो नहीं';

  @override
  String get photoTaken => 'फ़ोटो ली गई';

  @override
  String get takePhoto => 'फ़ोटो लें';

  @override
  String get retake => 'दोबारा लें';

  @override
  String get enterOdometerKm => 'ओडोमीटर रीडिंग किमी में डालें';

  @override
  String mustBeAtLeastKm({required String km}) {
    return 'कम से कम $km किमी होना चाहिए';
  }

  @override
  String get enterAmount => '₹ में रकम डालें';

  @override
  String get amountMoreThanZero => 'रकम ₹0 से ज़्यादा होनी चाहिए';

  @override
  String get enterFare => '₹ में किराया डालें';

  @override
  String get consentTitle => 'ट्रिप के दौरान लोकेशन';

  @override
  String get consentWhen =>
      'फ़्लीट सारथी आपके फ़ोन की लोकेशन सिर्फ़ ट्रिप चलते समय (\"ट्रिप शुरू करें\" से \"ट्रिप खत्म करें\" तक) रिकॉर्ड करता है। रिकॉर्डिंग के पूरे समय एक नोटिफ़िकेशन दिखता रहता है।';

  @override
  String get consentWhy =>
      'आपके फ़्लीट मालिक इससे रास्ता देखते हैं और ओडोमीटर से दूरी मिलाते हैं। यह ओडोमीटर और रसीद की फ़ोटो के साथ भी जुड़ती है। ड्यूटी के बाहर लोकेशन नहीं ली जाती।';

  @override
  String get consentRetention =>
      'रास्ते का डेटा ज़्यादा से ज़्यादा 12 महीने रखा जाता है, फिर मिटा दिया जाता है।';

  @override
  String get consentContinue => 'समझ गया, आगे बढ़ें';

  @override
  String cameraUnavailable({required String error}) {
    return 'कैमरा नहीं खुल रहा: $error';
  }

  @override
  String couldNotTakePhoto({required String error}) {
    return 'फ़ोटो नहीं ली जा सकी: $error';
  }

  @override
  String get fitOdometer => 'पूरा ओडोमीटर फ़्रेम में लाएँ';

  @override
  String get fitReceipt => 'पूरी रसीद फ़्रेम में लाएँ';

  @override
  String get fitDocument => 'पूरा दस्तावेज़ फ़्रेम में लाएँ';

  @override
  String get documentPhoto => 'दस्तावेज़ की फ़ोटो';

  @override
  String get gpsNotificationTitle => 'ट्रिप चल रही है';

  @override
  String get gpsNotificationText =>
      'फ़्लीट सारथी इस ट्रिप का रास्ता रिकॉर्ड कर रहा है।';

  @override
  String get rejectEndBeforeStart =>
      'ट्रिप शुरू होने के बाद ही खत्म हो सकती है';

  @override
  String get rejectNeedDrop => 'ट्रिप कहाँ जाएगी, डालें';

  @override
  String rejectEndBelowStart({required String km}) {
    return 'आखिरी रीडिंग कम से कम $km किमी होनी चाहिए';
  }

  @override
  String get rejectChargesActiveOnly =>
      'चार्ज सिर्फ़ चालू ट्रिप में जोड़े जा सकते हैं';

  @override
  String get rejectPaymentsAfterStart =>
      'भुगतान ट्रिप शुरू होने के बाद ही दर्ज हो सकता है';

  @override
  String get rejectTripCancelled => 'यह ट्रिप रद्द हो चुकी है';

  @override
  String get rejectCancellationPending =>
      'इस ट्रिप के लिए रद्द करने का अनुरोध पहले से बाकी है';

  @override
  String get rejectNoPendingCancellation =>
      'रद्द करने का कोई अनुरोध बाकी नहीं है';

  @override
  String rejectAnotherTripRunning({required String route}) {
    return 'दूसरी ट्रिप शुरू करने से पहले अपनी ट्रिप $route ख़त्म करें';
  }

  @override
  String get errorDriverOnTrip =>
      'ड्राइवर की एक ट्रिप पहले से चल रही है। दूसरी शुरू करने से पहले उसे ख़त्म करें।';

  @override
  String get errorVehicleOnTrip =>
      'यह गाड़ी पहले से दूसरी ट्रिप पर चल रही है। पहले वह ट्रिप ख़त्म करें।';

  @override
  String get rejectNotAllowed => 'आप इस ट्रिप पर यह नहीं कर सकते';

  @override
  String rejectWrongState({required String status}) {
    return 'ट्रिप \"$status\" होने पर यह नहीं हो सकता';
  }

  @override
  String get navDashboard => 'डैशबोर्ड';

  @override
  String get navTrips => 'ट्रिप';

  @override
  String get navAlerts => 'अलर्ट';

  @override
  String get navMore => 'और';

  @override
  String get vehicles => 'गाड़ियाँ';

  @override
  String get drivers => 'ड्राइवर';

  @override
  String get members => 'सदस्य';

  @override
  String get documents => 'दस्तावेज़';

  @override
  String get review => 'जाँच';

  @override
  String get settlements => 'हिसाब';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get loadFailed => 'यह लोड नहीं हो सका।';

  @override
  String get edit => 'बदलें';

  @override
  String get all => 'सभी';

  @override
  String get unassigned => 'असाइन नहीं';

  @override
  String get required => 'ज़रूरी है';

  @override
  String get roleOwner => 'मालिक';

  @override
  String get roleManager => 'मैनेजर';

  @override
  String get roleDriver => 'ड्राइवर';

  @override
  String get ownerOnly => 'इसे सिर्फ़ मालिक बदल सकते हैं।';

  @override
  String get severityCritical => 'गंभीर';

  @override
  String get severityWarning => 'चेतावनी';

  @override
  String get severityInfo => 'जानकारी';

  @override
  String get seeAll => 'सब देखें';

  @override
  String get pickDate => 'तारीख चुनें';

  @override
  String get status => 'स्थिति';

  @override
  String get name => 'नाम';

  @override
  String get note => 'नोट';

  @override
  String get total => 'कुल';

  @override
  String get active => 'चालू';

  @override
  String get inactive => 'बंद';

  @override
  String percentValue({required String value}) {
    return '$value%';
  }

  @override
  String minutesShort({required int count}) {
    return '$count मिनट';
  }

  @override
  String listAnd({required String first, required String last}) {
    return '$first और $last';
  }

  @override
  String get todaysTrips => 'आज की ट्रिप';

  @override
  String get noTripsToday => 'आज कोई ट्रिप तय नहीं है';

  @override
  String get needsAttention => 'आपका ध्यान चाहिए';

  @override
  String get criticalAlerts => 'गंभीर अलर्ट';

  @override
  String get openAlerts => 'खुले अलर्ट';

  @override
  String get toReview => 'जाँचना है';

  @override
  String get documentsDueSoon => 'जल्द खत्म होने वाले दस्तावेज़';

  @override
  String get nothingExpiring => 'अगले 30 दिनों में कुछ खत्म नहीं हो रहा';

  @override
  String get noOpenAlerts => 'कोई खुला अलर्ट नहीं';

  @override
  String get allStatuses => 'सभी स्थितियाँ';

  @override
  String get anyDate => 'कोई भी तारीख';

  @override
  String get allDrivers => 'सभी ड्राइवर';

  @override
  String get allVehicles => 'सभी गाड़ियाँ';

  @override
  String get noTripsMatch => 'इन फ़िल्टर से कोई ट्रिप नहीं मिली';

  @override
  String localTrip({required String from}) {
    return '$from (लोकल)';
  }

  @override
  String get tripType => 'ट्रिप का प्रकार';

  @override
  String get quotedFare => 'तय किराया';

  @override
  String get includedKmHint =>
      'किराए में शामिल किमी, जैसे 300 किमी पैकेज के लिए 300';

  @override
  String get customerName => 'ग्राहक का नाम';

  @override
  String get customerMobile => 'ग्राहक का मोबाइल';

  @override
  String get ends => 'खत्म';

  @override
  String get vehicleOptional => 'गाड़ी (ज़रूरी नहीं)';

  @override
  String get driverOptional => 'ड्राइवर (ज़रूरी नहीं)';

  @override
  String get assignLater => 'बाद में असाइन करें';

  @override
  String get pickBothOrNeither =>
      'गाड़ी और ड्राइवर दोनों चुनें, या कोई भी नहीं';

  @override
  String get tripDetails => 'ट्रिप';

  @override
  String get customer => 'ग्राहक';

  @override
  String get driver => 'ड्राइवर';

  @override
  String get startedAt => 'शुरू हुई';

  @override
  String get endedAt => 'खत्म हुई';

  @override
  String get cancelledAt => 'रद्द हुई';

  @override
  String get odometerDistance => 'ओडोमीटर से दूरी';

  @override
  String kmOverDriven({required String over, required String driven}) {
    return '$over किमी ज़्यादा ($driven किमी चली)';
  }

  @override
  String drivenKm({required String km}) {
    return '$km किमी चली';
  }

  @override
  String get cancellationFare => 'कैंसिलेशन किराया';

  @override
  String get assign => 'असाइन करें';

  @override
  String get reassign => 'दोबारा असाइन करें';

  @override
  String get unassign => 'असाइनमेंट हटाएँ';

  @override
  String get cancelTrip => 'ट्रिप रद्द करें';

  @override
  String get cancelTripTitle => 'यह ट्रिप रद्द करें';

  @override
  String get assignTripTitle => 'ट्रिप असाइन करें';

  @override
  String get reassignTripTitle => 'ट्रिप दोबारा असाइन करें';

  @override
  String get overlapNote =>
      'जो गाड़ी या ड्राइवर उसी समय पहले से बुक है, उसे असाइन नहीं किया जा सकता।';

  @override
  String get cancellationRequestTitle => 'रद्द करने का अनुरोध';

  @override
  String requestedBy({required String role, required String when}) {
    return '$role ने $when को अनुरोध किया';
  }

  @override
  String odometerAtKm({required String km}) {
    return 'ओडोमीटर $km';
  }

  @override
  String decisionNote({required String note}) {
    return 'फ़ैसले का नोट: $note';
  }

  @override
  String get approveCancellation => 'रद्द करना मंज़ूर करें';

  @override
  String get reject => 'नामंज़ूर करें';

  @override
  String get approve => 'मंज़ूर करें';

  @override
  String get approveIntro =>
      'ट्रिप रद्द हो जाएगी। जितनी दूरी चल चुकी है, उसका किराया ले सकते हैं।';

  @override
  String get cancellationFareHint => 'कोई चार्ज नहीं तो 0';

  @override
  String get rejectTitle => 'रद्द करना नामंज़ूर करें';

  @override
  String get noteForDriver => 'ड्राइवर के लिए नोट';

  @override
  String get rejectConfirm => 'नामंज़ूर करें — ट्रिप चलती रहेगी';

  @override
  String get requestPending => 'बाकी';

  @override
  String get requestApproved => 'मंज़ूर';

  @override
  String get requestRejected => 'नामंज़ूर';

  @override
  String get requestWithdrawn => 'वापस लिया';

  @override
  String get odometerEvidence => 'ओडोमीटर का सबूत';

  @override
  String get startLabel => 'शुरू';

  @override
  String get endLabel => 'आखिर';

  @override
  String get notRecordedYet => 'अभी दर्ज नहीं';

  @override
  String get typed => 'लिखा गया';

  @override
  String get readFromPhoto => 'फ़ोटो से पढ़ा';

  @override
  String get differsSentToReview => 'मेल नहीं खाता: जाँच में भेजा गया';

  @override
  String capturedAt({required String when}) {
    return '$when को ली गई';
  }

  @override
  String get photoNotUploaded =>
      'फ़ोटो अभी अपलोड नहीं हुई (फ़ोन शायद अभी ऑफ़लाइन है)।';

  @override
  String get routeTitle => 'रास्ता';

  @override
  String get routeAfterStart => 'ट्रिप शुरू होने पर रास्ता दिखेगा';

  @override
  String gpsPointsShown({required int count}) {
    return '$count GPS पॉइंट दिखाए गए';
  }

  @override
  String pointsRemoved({
    required String inaccurate,
    required String mock,
    required String impossible,
  }) {
    return '$inaccurate गलत, $mock नकली और $impossible असंभव पॉइंट हटाए गए';
  }

  @override
  String get verdictOkLabel => 'ओडोमीटर GPS से मेल खाता है';

  @override
  String get verdictOkText =>
      'ओडोमीटर की दूरी GPS रास्ते से तय अंतर के अंदर है।';

  @override
  String get verdictFlaggedLabel => 'ओडोमीटर GPS से ज़्यादा';

  @override
  String get verdictFlaggedText =>
      'ओडोमीटर की दूरी GPS रास्ते से काफ़ी ज़्यादा है। पूरी जानकारी अलर्ट में देखें।';

  @override
  String get verdictInconclusiveLabel => 'फ़ैसले के लिए GPS काफ़ी नहीं';

  @override
  String get verdictInconclusiveText =>
      'फ़ोन ने ट्रिप का बहुत कम हिस्सा रिकॉर्ड किया (अक्सर बैटरी बचाने की सेटिंग से)। ऐसे में कोई अलर्ट नहीं बनता।';

  @override
  String checkedAt({required String when}) {
    return '$when को जाँचा';
  }

  @override
  String get gps => 'GPS';

  @override
  String get odometer => 'ओडोमीटर';

  @override
  String get gpsCoverage => 'GPS कवरेज';

  @override
  String get longestGap => 'सबसे लंबा अंतराल';

  @override
  String get distanceCheckPending =>
      'दूरी की जाँच ट्रिप खत्म होने के कुछ सेकंड बाद होती है।';

  @override
  String get noCharges => 'कोई टोल, पार्किंग या दूसरा चार्ज नहीं।';

  @override
  String get addChargeTitle => 'चार्ज जोड़ें';

  @override
  String get driverPaidCheckbox =>
      'ड्राइवर ने अपनी जेब से दिया (हिसाब में वापस मिलेगा)';

  @override
  String get extraFareInfo =>
      'अतिरिक्त किराया: तय किराए के ऊपर ग्राहक से लिया जाएगा।';

  @override
  String get driverPaid => 'ड्राइवर ने दिया';

  @override
  String get billedOnly => 'सिर्फ़ बिल में';

  @override
  String byRole({required String text, required String role}) {
    return '$text · $role ने जोड़ा';
  }

  @override
  String get voidAction => 'रद्द करें';

  @override
  String get paymentsCollected => 'मिले भुगतान';

  @override
  String get recordPayment => 'भुगतान दर्ज करें';

  @override
  String get nothingRecorded => 'अभी कुछ दर्ज नहीं।';

  @override
  String get method => 'तरीका';

  @override
  String get methodCashOption => 'नकद (ड्राइवर हिसाब के समय देगा)';

  @override
  String get methodUpiOption => 'UPI (सीधे आपको मिलेगा)';

  @override
  String get methodCardOption => 'कार्ड (सीधे आपको मिलेगा)';

  @override
  String get referenceOptional => 'रेफ़रेंस (ज़रूरी नहीं)';

  @override
  String get referenceHint => 'UPI रेफ़रेंस या कार्ड स्लिप नंबर';

  @override
  String get record => 'दर्ज करें';

  @override
  String get timeline => 'टाइमलाइन';

  @override
  String get noEvents => 'कोई घटना नहीं';

  @override
  String eventBy({required String event, required String role}) {
    return '$event — $role';
  }

  @override
  String eventBySystem({required String event}) {
    return '$event (सिस्टम)';
  }

  @override
  String onDevice({required String when}) {
    return 'फ़ोन पर $when';
  }

  @override
  String syncedLater({required String when, required int count}) {
    return 'सर्वर पर $when पहुँचा ($count मिनट बाद)';
  }

  @override
  String get eventCreated => 'बनाई गई';

  @override
  String get eventAssigned => 'असाइन हुई';

  @override
  String get eventReassigned => 'दोबारा असाइन हुई';

  @override
  String get eventUnassigned => 'असाइनमेंट हटा';

  @override
  String get eventStarted => 'शुरू हुई';

  @override
  String get eventEnded => 'खत्म हुई';

  @override
  String get eventCancellationRequested => 'रद्द करने का अनुरोध';

  @override
  String get eventCancellationApproved => 'रद्द करना मंज़ूर';

  @override
  String get eventCancellationRejected => 'रद्द करना नामंज़ूर';

  @override
  String get eventCancellationWithdrawn => 'रद्द करने का अनुरोध वापस';

  @override
  String get eventCancelled => 'रद्द हुई';

  @override
  String get eventSettled => 'हिसाब हो गया';

  @override
  String get addVehicle => 'गाड़ी जोड़ें';

  @override
  String get editVehicle => 'गाड़ी बदलें';

  @override
  String get registrationNumber => 'रजिस्ट्रेशन नंबर';

  @override
  String get registrationInvalid => 'रजिस्ट्रेशन नंबर MH 12 AB 1234 जैसा लिखें';

  @override
  String get brand => 'ब्रांड';

  @override
  String get search => 'खोजें';

  @override
  String get othersGroup => 'अन्य';

  @override
  String get otherModel => 'दूसरा / सूची में नहीं';

  @override
  String get catalogUnavailable => 'सूची लोड नहीं हो पाई; खुद लिख दें';

  @override
  String get make => 'कंपनी';

  @override
  String get model => 'मॉडल';

  @override
  String get fuelType => 'फ़्यूल का प्रकार';

  @override
  String get year => 'साल';

  @override
  String get currentOdometer => 'अभी का ओडोमीटर';

  @override
  String get inactiveVehicleOption => 'बंद (असाइन के लिए नहीं दिखेगी)';

  @override
  String get deactivate => 'बंद करें';

  @override
  String get activate => 'चालू करें';

  @override
  String get noVehiclesYet =>
      'अभी कोई गाड़ी नहीं। ट्रिप असाइन करने के लिए पहली गाड़ी जोड़ें।';

  @override
  String get lastOdometer => 'आखिरी ओडोमीटर';

  @override
  String get recentTrips => 'हाल की ट्रिप';

  @override
  String get noTripsShort => 'अभी कोई ट्रिप नहीं';

  @override
  String get fuelAudit => 'फ़्यूल ऑडिट';

  @override
  String get inviteDriver => 'ड्राइवर जोड़ें';

  @override
  String get inviteDriverIntro =>
      'ड्राइवर इसी नंबर से फ़्लीट सारथी ऐप में साइन इन करेगा; पासवर्ड की ज़रूरत नहीं।';

  @override
  String get enterIndianMobile => '10 अंकों का भारतीय मोबाइल नंबर डालें';

  @override
  String get sendInvite => 'न्योता भेजें';

  @override
  String get noDriversYet =>
      'अभी कोई ड्राइवर नहीं। फ़ोन नंबर से ड्राइवर जोड़ें; वे उसी नंबर और एक पासवर्ड से साइन अप करेंगे।';

  @override
  String payDefault({required String rule}) {
    return 'डिफ़ॉल्ट · $rule';
  }

  @override
  String get notSignedInYet => 'अभी साइन इन नहीं किया';

  @override
  String get inactiveDriverOption => 'बंद (असाइन नहीं हो सकता)';

  @override
  String get pay => 'पगार';

  @override
  String get onlyOwnerPay => 'पगार सिर्फ़ मालिक बदल सकते हैं।';

  @override
  String get payDifferently => 'इस ड्राइवर को डिफ़ॉल्ट से अलग पगार दें';

  @override
  String get checkPayRule => 'पगार के नियम की वैल्यू जाँचें';

  @override
  String get payRuleHow => 'ड्राइवर को पगार कैसे मिलती है';

  @override
  String get payNone => 'कोई नहीं (तनख्वाह, फ़्लीट सारथी के बाहर)';

  @override
  String get payPercent => 'किराए का प्रतिशत';

  @override
  String get payPerTrip => 'हर ट्रिप की तय रकम';

  @override
  String get payPerKm => 'हर किमी के हिसाब से';

  @override
  String get payFixedDaily => 'हर काम के दिन की तय रकम';

  @override
  String get percent => 'प्रतिशत';

  @override
  String get ofBase => 'किस पर';

  @override
  String get baseQuoted => 'तय किराया';

  @override
  String get baseExpected => 'चार्ज समेत किराया';

  @override
  String get amountPerTrip => 'हर ट्रिप की रकम';

  @override
  String get ratePerKm => 'प्रति किमी रेट';

  @override
  String get amountPerDay => 'हर काम के दिन की रकम';

  @override
  String get allowanceToDriver => 'ड्राइवर भत्ता ड्राइवर को मिलेगा';

  @override
  String get allowanceHint =>
      'ग्राहक जो बाटा देता है, वह ड्राइवर की कमाई में जुड़ता है।';

  @override
  String get ruleNoPay => 'हिसाब में कोई पगार नहीं';

  @override
  String rulePercentQuoted({required String percent}) {
    return 'तय किराए का $percent%';
  }

  @override
  String rulePercentExpected({required String percent}) {
    return 'चार्ज समेत किराए का $percent%';
  }

  @override
  String rulePerTrip({required String amount}) {
    return '$amount प्रति ट्रिप';
  }

  @override
  String rulePerKm({required String amount}) {
    return '$amount प्रति किमी';
  }

  @override
  String ruleFixedDaily({required String amount}) {
    return '$amount प्रति काम का दिन';
  }

  @override
  String rulePlusAllowance({required String rule}) {
    return '$rule + ड्राइवर भत्ता';
  }

  @override
  String get inviteManager => 'मैनेजर जोड़ें';

  @override
  String get inviteManagerIntro =>
      'मैनेजर ट्रिप, अलर्ट और हिसाब संभालते हैं, पर सेटिंग्स या पगार नहीं बदल सकते।';

  @override
  String get removeManager => 'मैनेजर की पहुँच हटाएँ';

  @override
  String removeManagerConfirm({required String name}) {
    return '$name की मैनेजर पहुँच हटाएँ? उनकी बाकी भूमिकाएँ बनी रहेंगी।';
  }

  @override
  String get remove => 'हटाएँ';

  @override
  String get memberInvited => 'न्योता भेजा';

  @override
  String get memberActive => 'चालू';

  @override
  String get memberSuspended => 'रोका गया';

  @override
  String get membersIntro => 'इस फ़्लीट तक पहुँच वाले लोग।';

  @override
  String get addDocument => 'दस्तावेज़ जोड़ें';

  @override
  String get renew => 'रिन्यू करें';

  @override
  String renewTitle({required String doc}) {
    return '$doc रिन्यू करें';
  }

  @override
  String get renewIntro =>
      'नई कॉपी अभी वाली की जगह लेगी (पुरानी रिकॉर्ड में रहेगी), और उसके अलर्ट हट जाएँगे।';

  @override
  String get documentType => 'दस्तावेज़';

  @override
  String get documentFor => 'किसका';

  @override
  String get documentNumber => 'नंबर';

  @override
  String get validFrom => 'कब से मान्य';

  @override
  String get expiresOn => 'कब खत्म';

  @override
  String get expiresOnHint => 'खत्म होने से पहले और खत्म होने पर अलर्ट आएगा।';

  @override
  String get saveRenewal => 'रिन्यूअल सेव करें';

  @override
  String get noDocuments => 'अभी कोई दस्तावेज़ नहीं।';

  @override
  String get docRc => 'रजिस्ट्रेशन (RC)';

  @override
  String get docInsurance => 'बीमा';

  @override
  String get docPermit => 'परमिट';

  @override
  String get docPuc => 'प्रदूषण (PUC)';

  @override
  String get docLicence => 'ड्राइविंग लाइसेंस';

  @override
  String get docValid => 'मान्य';

  @override
  String docExpiresIn({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन में खत्म',
      one: 'कल खत्म',
      zero: 'आज खत्म',
    );
    return '$_temp0';
  }

  @override
  String get docExpired => 'खत्म हो गया';

  @override
  String get docSuperseded => 'रिन्यू हो गया';

  @override
  String get filterAllDocs => 'सभी मौजूदा दस्तावेज़';

  @override
  String get filterDue30 => '30 दिन में खत्म या खत्म हो चुके';

  @override
  String get filterDue7 => '7 दिन में खत्म या खत्म हो चुके';

  @override
  String get filterDue0 => 'खत्म या आज खत्म';

  @override
  String get viewPhoto => 'फ़ोटो देखें';

  @override
  String get documentPhotoOptional => 'फ़ोटो (ज़रूरी नहीं)';

  @override
  String get pickVehicleOrDriver => 'किसका है, चुनें';

  @override
  String get fuelIntro =>
      'हर गाड़ी की तुलना उसके अपने पुराने रिकॉर्ड से होती है, हर साइकिल में (टंकी फ़ुल से टंकी फ़ुल तक)।';

  @override
  String get efficiencyByCycle => 'हर साइकिल का माइलेज';

  @override
  String get costByCycle => 'हर साइकिल का खर्च';

  @override
  String get noCycles =>
      'अभी कोई फ़ुल-टंकी साइकिल नहीं। माइलेज दो फ़ुल-टंकी भराई के बीच नापा जाता है।';

  @override
  String get usual => 'आम तौर पर';

  @override
  String usualValue({required String value}) {
    return 'आम तौर पर $value';
  }

  @override
  String get cyclesInBaseline => 'औसत में साइकिल';

  @override
  String get verdictOk => 'ठीक';

  @override
  String get verdictFlagged => 'संदिग्ध';

  @override
  String get verdictInvalid => 'अमान्य';

  @override
  String get fuelFills => 'फ़्यूल भराई';

  @override
  String get noFills => 'कोई भराई दर्ज नहीं';

  @override
  String get fullTankShort => 'फ़ुल';

  @override
  String get partialTank => 'आंशिक';

  @override
  String get voidFill => 'भराई रद्द करें';

  @override
  String get voidFillTitle => 'यह भराई रद्द करें';

  @override
  String voidFillIntro({
    required String quantity,
    required String amount,
    required String when,
  }) {
    return '$when को $amount में $quantity। गाड़ी का फ़्यूल ऑडिट इसके बिना दोबारा गिना जाएगा।';
  }

  @override
  String get voidReasonHint => 'जैसे: 40 लीटर की जगह 60 लीटर लिख दिया';

  @override
  String get keepIt => 'रहने दें';

  @override
  String receiptAmount({required String amount}) {
    return 'रसीद: $amount';
  }

  @override
  String sigmaRule({required String value}) {
    return '$valueσ';
  }

  @override
  String percentRule({required String value}) {
    return '$value% (नई गाड़ी)';
  }

  @override
  String cycleRange({required String from, required String to}) {
    return '$from → $to';
  }

  @override
  String get noCyclesShort => 'कोई साइकिल नहीं';

  @override
  String get chartThisCycle => 'हर साइकिल';

  @override
  String perKmValue({required String amount}) {
    return '$amount/किमी';
  }

  @override
  String get allKinds => 'सभी प्रकार';

  @override
  String get alertOpen => 'खुला';

  @override
  String get alertAcknowledged => 'देख लिया';

  @override
  String get alertResolved => 'सुलझ गया';

  @override
  String get alertDismissed => 'खारिज';

  @override
  String get acknowledge => 'देख लिया';

  @override
  String get dismiss => 'खारिज करें';

  @override
  String get dismissFalseAlarm => 'गलत अलर्ट मानकर खारिज करें';

  @override
  String get markResolved => 'सुलझा हुआ मानें';

  @override
  String get falseAlarm => 'गलत अलर्ट';

  @override
  String get allClear => 'सब ठीक: कोई खुला अलर्ट नहीं';

  @override
  String get noAlertsMatch => 'कोई अलर्ट नहीं मिला';

  @override
  String get openTrip => 'ट्रिप खोलें';

  @override
  String get openFuelHistory => 'फ़्यूल रिकॉर्ड खोलें';

  @override
  String get openVehicle => 'गाड़ी खोलें';

  @override
  String get openDocuments => 'दस्तावेज़ खोलें';

  @override
  String get alertsIntro =>
      'फ़्यूल अलर्ट को गलत मानकर खारिज करने से वह साइकिल गाड़ी के सामान्य औसत में गिनी जाती है।';

  @override
  String get kindFuelEfficiencyLow => 'फ़्यूल की खपत आम से ज़्यादा';

  @override
  String get kindFuelCostHigh => 'चलाने का खर्च आम से ज़्यादा';

  @override
  String get kindOdoGps => 'ओडोमीटर GPS से ज़्यादा';

  @override
  String get kindDocExpiring => 'दस्तावेज़ खत्म होने वाला';

  @override
  String get kindDocExpired => 'दस्तावेज़ खत्म';

  @override
  String get kindCancellationRequested => 'रद्द करने का अनुरोध';

  @override
  String get kindGpsCoverageLow => 'GPS कवरेज कम';

  @override
  String alertVehicle({
    required String registrationNo,
    required String model,
    required String fuel,
  }) {
    return '$registrationNo ($model, $fuel)';
  }

  @override
  String get alertFuelPetrol => 'पेट्रोल';

  @override
  String get alertFuelDiesel => 'डीज़ल';

  @override
  String get alertFuelCng => 'CNG';

  @override
  String get alertFuelPetrolCng => 'पेट्रोल + CNG';

  @override
  String alertFuelEfficiencyTitle({required String vehicle}) {
    return '$vehicle ने आम से ज़्यादा फ़्यूल खाया';
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
    return '$from से $to के बीच यह $used $unit $fuel में $km किमी चली, यानी $value किमी/$unit। यह गाड़ी आम तौर पर लगभग $baseline किमी/$unit देती है, तो यह सामान्य से $worse% खराब है। उम्मीद से लगभग $extra $unit (करीब $extraCost) ज़्यादा $fuel लगा।';
  }

  @override
  String alertFuelCostTitle({required String vehicle}) {
    return '$vehicle को चलाने का खर्च आम से ज़्यादा रहा';
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
    return '$from से $to के बीच यह $cost के फ़्यूल में $km किमी चली, यानी $perKm/किमी। इस गाड़ी का खर्च आम तौर पर लगभग $usualPerKm/किमी होता है, तो यह सामान्य से $worse% ज़्यादा है।';
  }

  @override
  String alertPetrolShare({required String amount}) {
    return 'इसमें $amount पेट्रोल का था।';
  }

  @override
  String alertFillsLoggedBy({required String names}) {
    return 'इस दौरान की भराई $names ने दर्ज की।';
  }

  @override
  String get alertCheckReceiptsOdometer => 'रसीदें और ओडोमीटर की फ़ोटो जाँचें।';

  @override
  String get alertCheckPetrolReceipts =>
      'देखें कि गाड़ी बेवजह पेट्रोल पर तो नहीं चली, और रसीदें जाँचें।';

  @override
  String alertOdoGpsTitle({
    required String date,
    required String route,
    required String vehicle,
  }) {
    return '$date की ट्रिप ($route, $vehicle) में ओडोमीटर पर GPS रास्ते से ज़्यादा किमी हैं';
  }

  @override
  String get alertOdoGpsVehicleUnknown => 'गाड़ी';

  @override
  String alertOdoGpsBody({
    required String odometer,
    required String gps,
    required String excess,
    required String tolerance,
  }) {
    return 'ओडोमीटर रीडिंग के हिसाब से $odometer किमी है, पर फ़ोन के GPS ने $gps किमी रिकॉर्ड किया। ओडोमीटर की दूरी $excess% ज़्यादा है; $tolerance% तक का अंतर चलता है। शुरू और आखिर की ओडोमीटर फ़ोटो जाँचें।';
  }

  @override
  String alertDocExpiredTitle({required String doc, required String subject}) {
    return '$subject का $doc खत्म हो गया है';
  }

  @override
  String alertDocExpiredBody({
    required String doc,
    required String subject,
    required String date,
  }) {
    return '$subject का $doc $date को खत्म हो गया। इसके बिना चलाने पर जुर्माना हो सकता है और बीमा क्लेम खारिज हो सकता है। इसे रिन्यू करवाकर नई कॉपी अपलोड करें।';
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
      other: '$subject का $doc $count दिन में खत्म हो रहा है',
      one: '$subject का $doc कल खत्म हो रहा है',
      zero: '$subject का $doc आज खत्म हो रहा है',
    );
    return '$_temp0';
  }

  @override
  String alertDocExpiringBody({
    required String doc,
    required String subject,
    required String date,
  }) {
    return '$subject का $doc $date को खत्म होगा। उससे पहले रिन्यू करवाकर नई कॉपी अपलोड करें।';
  }

  @override
  String alertCancellationTitle({required String from}) {
    return '$from से चली ट्रिप को रद्द करने का अनुरोध';
  }

  @override
  String alertCancellationBody({
    required String driver,
    required String reason,
    required String km,
  }) {
    return '$driver ने चलती ट्रिप रद्द करने को कहा है: \"$reason\"। ओडोमीटर $km किमी था। ट्रिप पेज पर मंज़ूर करें (चाहें तो कैंसिलेशन किराए के साथ) या नामंज़ूर करें।';
  }

  @override
  String get alertTheDriver => 'ड्राइवर';

  @override
  String get reviewIntro =>
      'जिन चीज़ों पर फ़्लीट सारथी पक्का नहीं है। इनसे ड्राइवर का काम नहीं रुका; आपका फ़ैसला रिकॉर्ड ठीक करेगा।';

  @override
  String get nothingToReview => 'जाँचने को कुछ नहीं';

  @override
  String get noItems => 'कुछ नहीं';

  @override
  String get reviewOcrOdometer => 'ओडोमीटर फ़ोटो लिखी रीडिंग से मेल नहीं खाती';

  @override
  String get reviewOcrReceipt => 'रसीद लिखी रकम से मेल नहीं खाती';

  @override
  String get reviewOdometerRegression => 'ओडोमीटर पीछे चला गया';

  @override
  String get reviewImplausibleEfficiency => 'फ़्यूल के आँकड़े सही नहीं लगते';

  @override
  String get reviewMockLocation => 'नकली GPS लोकेशन पकड़ी गई';

  @override
  String get reviewOrphanEvidence => 'रद्द ट्रिप की फ़ोटो';

  @override
  String get reviewClockSkew => 'फ़ोन की घड़ी गलत थी';

  @override
  String get reviewUploadMismatch => 'अपलोड की गई फ़ाइल मेल नहीं खाई';

  @override
  String get reviewKeptTyped => 'लिखी वैल्यू रखी';

  @override
  String get reviewUsedPhoto => 'फ़ोटो वाली वैल्यू ली';

  @override
  String get reviewCorrected => 'सुधारा गया';

  @override
  String get typedByDriver => 'ड्राइवर ने लिखा';

  @override
  String get readFromThePhoto => 'फ़ोटो से पढ़ा';

  @override
  String get keepTyped => 'लिखी वैल्यू रखें';

  @override
  String get usePhotoValue => 'फ़ोटो वाली वैल्यू लें';

  @override
  String get enterCorrectValue => 'सही वैल्यू डालें';

  @override
  String get markReviewed => 'जाँच हो गई';

  @override
  String get correctValueTitle => 'सही वैल्यू डालें';

  @override
  String get odometerKmLabel => 'ओडोमीटर (किमी)';

  @override
  String get correctionHint =>
      'फ़्यूल और दूरी की जाँच इसी वैल्यू से दोबारा होगी।';

  @override
  String get saveCorrection => 'सुधार सेव करें';

  @override
  String get reasonOdometerNotIncreasing =>
      'आखिरी भराई पर ओडोमीटर रीडिंग पहली भराई से ज़्यादा नहीं है।';

  @override
  String get reasonDistanceTooLong =>
      'दो फ़ुल-टंकी भराई के बीच 3,000 किमी से ज़्यादा चली, शायद कुछ भराई दर्ज नहीं हुई।';

  @override
  String get reasonImplausiblyGood =>
      'माइलेज इस गाड़ी के आम माइलेज से बहुत बेहतर है, आम तौर पर इसका मतलब है कि कोई भराई दर्ज नहीं हुई।';

  @override
  String get reasonNoFuel =>
      'दो फ़ुल-टंकी भराई के बीच कोई फ़्यूल दर्ज नहीं हुआ।';

  @override
  String get settlementsIntro =>
      'दिन (IST) के हिसाब से हर ड्राइवर की एक लाइन। ट्रिप और भुगतान सिंक होने पर कच्चा हिसाब बदलता रहता है।';

  @override
  String noActivity({required String date}) {
    return '$date को किसी ड्राइवर का काम नहीं';
  }

  @override
  String tripsCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ट्रिप',
      one: '1 ट्रिप',
    );
    return '$_temp0';
  }

  @override
  String get expected => 'होना चाहिए';

  @override
  String get online => 'ऑनलाइन';

  @override
  String get expenses => 'खर्च';

  @override
  String get earnings => 'कमाई';

  @override
  String get lateItems => 'देर से आई चीज़ें';

  @override
  String get net => 'कुल बकाया';

  @override
  String get draft => 'कच्चा';

  @override
  String shortfall({required String amount}) {
    return 'कमी $amount';
  }

  @override
  String get expectedFare => 'होना चाहिए किराया';

  @override
  String get cashCollected => 'नकद वसूला';

  @override
  String get onlineToYou => 'ऑनलाइन (आपको)';

  @override
  String get driversExpenses => 'ड्राइवर का खर्च';

  @override
  String get driversEarnings => 'ड्राइवर की कमाई';

  @override
  String get shortfallLabel => 'कमी';

  @override
  String get shortfallHint => 'होना चाहिए किराया, वसूली गई रकम घटाकर';

  @override
  String get settlementLabel => 'हिसाब';

  @override
  String get netFormula =>
      'बकाया = वसूला नकद − ड्राइवर का खर्च − ड्राइवर की कमाई ± पहले से हिसाब हुए दिनों की देर से आई चीज़ें।';

  @override
  String driverPaysYou({required String amount}) {
    return 'ड्राइवर आपको $amount देगा';
  }

  @override
  String youPayDriver({required String amount}) {
    return 'आप ड्राइवर को $amount देंगे';
  }

  @override
  String get nothingToHandOver => 'कुछ लेना-देना नहीं';

  @override
  String settledOn({required String when}) {
    return '$when को हिसाब हुआ। बाद के बदलाव अगले दिन में जुड़ेंगे।';
  }

  @override
  String get markSettledHint =>
      'नकद मिलने के बाद हिसाब पूरा करें। इससे यह दिन लॉक हो जाएगा।';

  @override
  String get markSettled => 'हिसाब पूरा करें';

  @override
  String lateFrom({required String date}) {
    return '$date का, उस दिन का हिसाब होने के बाद सिंक हुआ';
  }

  @override
  String get lineTrip => 'ट्रिप';

  @override
  String get lineCharge => 'चार्ज';

  @override
  String get linePayment => 'भुगतान';

  @override
  String get lineFuel => 'फ़्यूल';

  @override
  String get lineAdjustment => 'देर से आई चीज़';

  @override
  String itemTripVehicle({
    required String route,
    required String registrationNo,
  }) {
    return '$route ($registrationNo)';
  }

  @override
  String itemCancelled({required String text}) {
    return '$text · रद्द';
  }

  @override
  String itemChargeDriverPaid({required String kind}) {
    return '$kind, ड्राइवर ने दिया';
  }

  @override
  String itemChargeBilled({required String kind}) {
    return '$kind, ग्राहक के बिल में';
  }

  @override
  String itemChargeExtraFare({required String kind}) {
    return '$kind, अतिरिक्त किराया';
  }

  @override
  String itemOnTrip({required String text, required String route}) {
    return '$text · $route';
  }

  @override
  String itemPayment({required String method}) {
    return '$method भुगतान';
  }

  @override
  String itemReference({required String text, required String reference}) {
    return '$text (रेफ़ $reference)';
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
  String get auditThresholds => 'ऑडिट की सीमाएँ';

  @override
  String get fuelKSigma => 'फ़्यूल अलर्ट की संवेदनशीलता (k σ)';

  @override
  String get fuelKSigmaHint =>
      'जो साइकिल आम से इतने स्टैंडर्ड डेविएशन खराब हो, उस पर अलर्ट। कम = ज़्यादा अलर्ट।';

  @override
  String get fuelMinCycles => 'σ से पहले कितनी साइकिल';

  @override
  String get fuelMinCyclesHint =>
      'नई गाड़ियों पर इतनी सामान्य साइकिल होने तक प्रतिशत वाला नियम लगता है।';

  @override
  String get fuelPct => 'नई गाड़ी की सीमा (%)';

  @override
  String get fuelPctHint =>
      'नई गाड़ियों में साइकिल आम से इतना खराब हो तो अलर्ट।';

  @override
  String get fuelAlpha => 'औसत कितनी जल्दी बदले (α)';

  @override
  String get fuelAlphaHint =>
      'आम आँकड़ा हाल की साइकिल के साथ कितनी जल्दी बदले (0.05–0.9)।';

  @override
  String get odoTolerance => 'ओडोमीटर बनाम GPS छूट (%)';

  @override
  String get odoToleranceHint =>
      'जिस ट्रिप में ओडोमीटर की दूरी GPS रास्ते से इससे ज़्यादा हो, उस पर अलर्ट।';

  @override
  String get docAlertDays => 'दस्तावेज़ अलर्ट के दिन';

  @override
  String get docAlertDaysHint =>
      'कॉमा से अलग, जैसे 30, 7, 1। खत्म होने के दिन भी अलर्ट आएगा।';

  @override
  String get checkThresholds => 'वैल्यू जाँचें: कुछ तय सीमा से बाहर हैं।';

  @override
  String get savedThresholds =>
      'सेव हो गया। अगली गणना से फ़्यूल ऑडिट नई सीमाएँ इस्तेमाल करेगा।';

  @override
  String get saveThresholds => 'सीमाएँ सेव करें';

  @override
  String get defaultDriverPay => 'ड्राइवर की डिफ़ॉल्ट पगार';

  @override
  String get defaultPayIntro =>
      'जिन ड्राइवरों का अपना नियम नहीं है, उनके हिसाब में यही लगता है।';

  @override
  String get savedPay =>
      'सेव हो गया। जिन दिनों का हिसाब हो चुका, वे नहीं बदलेंगे।';

  @override
  String get saveDefaultPay => 'डिफ़ॉल्ट पगार सेव करें';

  @override
  String get settingsOwnerOnly => 'सेटिंग्स सिर्फ़ मालिक बदल सकते हैं।';

  @override
  String signedInAs({required String name, required String roles}) {
    return '$name · $roles';
  }

  @override
  String get password => 'पासवर्ड';

  @override
  String get logIn => 'लॉग इन करें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get newHereSignUp => 'फ़्लीट सारथी पर नए हैं? साइन अप करें';

  @override
  String get haveAccountLogIn => 'पहले से अकाउंट है? लॉग इन करें';

  @override
  String get backToLogIn => 'लॉग इन पर वापस जाएँ';

  @override
  String get signUpTitle => 'अपना अकाउंट बनाएँ';

  @override
  String get signUpIntro =>
      'अपने मोबाइल नंबर के लिए एक पासवर्ड चुनें। ड्राइवर वही नंबर डालें जो फ़्लीट मालिक ने दर्ज किया है।';

  @override
  String get createAccount => 'अकाउंट बनाएँ';

  @override
  String get yourNameOptional => 'आपका नाम (ज़रूरी नहीं)';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get confirmPassword => 'पासवर्ड दोबारा डालें';

  @override
  String get currentPassword => 'मौजूदा पासवर्ड';

  @override
  String get passwordHint => 'कम से कम 8 अक्षर';

  @override
  String get enterPassword => 'अपना पासवर्ड डालें';

  @override
  String get passwordTooShort => 'पासवर्ड में कम से कम 8 अक्षर रखें।';

  @override
  String get passwordTooLong => 'पासवर्ड 128 अक्षरों से लंबा न रखें।';

  @override
  String get passwordsDontMatch => 'दोनों पासवर्ड एक जैसे नहीं हैं।';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get resetPasswordTitle => 'पासवर्ड रीसेट करें';

  @override
  String get resetPasswordIntro =>
      'हम आपके मोबाइल नंबर के लिए एक रीसेट कोड भेजेंगे। फिर नया पासवर्ड चुनें।';

  @override
  String get resetPassword => 'पासवर्ड रीसेट करें';

  @override
  String get saveAndLogIn => 'पासवर्ड सेव करके लॉग इन करें';

  @override
  String get resendCode => 'कोड फिर से भेजें';

  @override
  String resendCodeIn({required String seconds}) {
    return '$seconds सेकंड बाद कोड फिर से भेजें';
  }

  @override
  String get codeResent => 'नया कोड भेज दिया है।';

  @override
  String get resetCodeInApiLog =>
      'लोकल या डेमो सर्वर पर कोड SMS से नहीं आता: वह API सर्वर के लॉग में छपता है।';

  @override
  String get accountSecurity => 'अकाउंट सुरक्षा';

  @override
  String get signInMethods => 'आप कैसे साइन इन करते हैं';

  @override
  String get passwordIsSet => 'सेट है';

  @override
  String get passwordNotSet => 'अभी सेट नहीं है';

  @override
  String get setPassword => 'पासवर्ड बनाएँ';

  @override
  String get setPasswordIntro =>
      'फिर आप मोबाइल नंबर और पासवर्ड से लॉग इन कर सकेंगे।';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get savePassword => 'पासवर्ड सेव करें';

  @override
  String get passwordSaved => 'पासवर्ड सेव हो गया';

  @override
  String get currentPasswordWrong => 'मौजूदा पासवर्ड ग़लत है।';

  @override
  String get editDrivers => 'ड्राइवर बदलें';

  @override
  String get editVehicles => 'गाड़ियाँ बदलें';

  @override
  String get noLinkedDrivers =>
      'अभी कोई ड्राइवर जुड़ा नहीं है। इस गाड़ी की ट्रिप सिर्फ़ जुड़े हुए ड्राइवर को दी जा सकती है।';

  @override
  String get noLinkedVehicles =>
      'अभी कोई गाड़ी जुड़ी नहीं है। इस ड्राइवर को सिर्फ़ जुड़ी हुई गाड़ी में ट्रिप दी जा सकती है।';

  @override
  String editDriversIntro({required String vehicle}) {
    return '$vehicle कौन चला सकता है? इस गाड़ी की ट्रिप सिर्फ़ इन्हीं ड्राइवरों को दी जा सकती है।';
  }

  @override
  String editVehiclesIntro({required String name}) {
    return '$name कौन-सी गाड़ियाँ चला सकते हैं? उन्हें सिर्फ़ इन्हीं गाड़ियों में ट्रिप मिल सकती है।';
  }

  @override
  String get driversOptional => 'ड्राइवर (वैकल्पिक)';

  @override
  String get vehiclesOptional => 'गाड़ियाँ (वैकल्पिक)';

  @override
  String get driversOptionalHint =>
      'इसे कौन चला सकता है। बाद में बदल सकते हैं।';

  @override
  String get vehiclesOptionalHint =>
      'वे कौन-सी गाड़ियाँ चला सकते हैं। बाद में बदल सकते हैं।';

  @override
  String get noneSelected => 'अभी कोई नहीं';

  @override
  String get noDriversToLink => 'अभी कोई ड्राइवर नहीं। पहले ड्राइवर जोड़ें।';

  @override
  String get noVehiclesToLink => 'अभी कोई गाड़ी नहीं। पहले गाड़ी जोड़ें।';

  @override
  String get vehicleHasNoDrivers =>
      'इस गाड़ी से कोई ड्राइवर जुड़ा नहीं है। पहले गाड़ी के पेज पर ड्राइवर जोड़ें।';

  @override
  String get driverHasNoVehicles =>
      'इस ड्राइवर से कोई गाड़ी जुड़ी नहीं है। पहले ड्राइवर के पेज पर गाड़ियाँ जोड़ें।';

  @override
  String get noVehiclesLinkedToYou =>
      'अभी आपसे कोई गाड़ी नहीं जुड़ी है। फ़्लीट मालिक से कहें कि आपको किसी गाड़ी से जोड़ दें।';

  @override
  String get noVehiclesLinkedHint =>
      'अगर आप ऑफ़लाइन हैं, तो गाड़ियाँ लाने के लिए एक बार इंटरनेट से जुड़ें।';

  @override
  String get errorDriverNotLinked =>
      'ड्राइवर इस गाड़ी से जुड़ा नहीं है। मालिक गाड़ी के पेज पर उन्हें जोड़ सकते हैं।';

  @override
  String errorDriverNotLinkedNamed({
    required String driver,
    required String vehicle,
  }) {
    return '$driver $vehicle से जुड़े नहीं हैं। पहले गाड़ी के पेज पर उन्हें जोड़ें।';
  }

  @override
  String get errorLinkInUse =>
      'ड्राइवर की इस गाड़ी में असाइन या चल रही ट्रिप हैं। हटाने से पहले उन्हें किसी और को दें या ख़त्म करें।';

  @override
  String errorLinkInUseCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ड्राइवर की इस गाड़ी में $count असाइन या चल रही ट्रिप हैं। हटाने से पहले उन्हें किसी और को दें या ख़त्म करें।',
      one:
          'ड्राइवर की इस गाड़ी में 1 असाइन या चल रही ट्रिप है। हटाने से पहले उसे किसी और को दें या ख़त्म करें।',
    );
    return '$_temp0';
  }

  @override
  String get switchWorkspace => 'मोड या फ़्लीट बदलें';

  @override
  String workspaceManage({required String fleet}) {
    return '$fleet संभालें';
  }

  @override
  String workspaceDrive({required String fleet}) {
    return '$fleet के लिए गाड़ी चलाएँ';
  }

  @override
  String get workspaceManageHint =>
      'मालिक मोड: गाड़ियाँ, ड्राइवर, ट्रिप और हिसाब';

  @override
  String get workspaceDriveHint => 'ड्राइवर मोड: आपकी ट्रिप, ईंधन और फ़ोटो';

  @override
  String get setUpMyFleet => 'मेरी अपनी गाड़ियाँ हैं: अपनी फ़्लीट बनाएँ';

  @override
  String unsyncedBeforeSwitch({required int count}) {
    return 'इस फ़ोन पर ट्रिप के $count अपडेट अभी भेजे नहीं गए हैं। इंटरनेट चालू करें, सिंक होने दें, फिर बदलें।';
  }

  @override
  String get getStartedTitle => 'फ़्लीट सारथी में स्वागत है';

  @override
  String get getStartedDriveTitle => 'किसी गाड़ी मालिक के लिए गाड़ी चलाएँ';

  @override
  String getStartedDriveBody({required String phone}) {
    return 'मालिक से कहें कि वे अपने फ़्लीट सारथी में $phone को ड्राइवर के रूप में जोड़ें। फिर ‘फिर से देखें’ दबाएँ।';
  }

  @override
  String get checkAgain => 'फिर से देखें';

  @override
  String get stillNoFleet => 'अभी किसी मालिक ने आपको नहीं जोड़ा है।';

  @override
  String get getStartedOwnTitle => 'आपकी अपनी गाड़ियाँ हैं?';

  @override
  String get getStartedOwnBody =>
      'गाड़ियाँ और ड्राइवर जोड़ने के लिए अपनी फ़्लीट बनाएँ। इसी अकाउंट से आप दूसरे मालिकों के लिए गाड़ी भी चला सकते हैं।';

  @override
  String get createFleetTitle => 'अपनी फ़्लीट बनाएँ';

  @override
  String get fleetNameLabel => 'फ़्लीट या कारोबार का नाम';

  @override
  String get fleetNameTooShort => 'कम से कम 2 अक्षर लिखें';

  @override
  String get iDriveToo => 'मैं अपनी गाड़ियाँ खुद भी चलाता/चलाती हूँ';

  @override
  String get createFleet => 'फ़्लीट बनाएँ';

  @override
  String get addMapPin => 'मैप पर पिन लगाएँ';

  @override
  String get changePin => 'बदलें';

  @override
  String get removePin => 'पिन हटाएँ';

  @override
  String get pickupOnMap => 'मैप पर पिकअप';

  @override
  String get dropOnMap => 'मैप पर ड्रॉप';

  @override
  String get pinPickerHint =>
      'पिन लगाने के लिए मैप पर टैप करें। बदलने के लिए फिर से टैप करें।';

  @override
  String get usePin => 'यह पिन लगाएँ';

  @override
  String get navGroupOverview => 'सारांश';

  @override
  String get navGroupFleet => 'फ़्लीट';

  @override
  String get navGroupMoney => 'हिसाब';

  @override
  String get navGroupSetup => 'सेटअप';

  @override
  String get greetingMorning => 'सुप्रभात';

  @override
  String get greetingAfternoon => 'नमस्ते';

  @override
  String get greetingEvening => 'शुभ संध्या';

  @override
  String get colRoute => 'रूट';

  @override
  String get colCustomer => 'ग्राहक';

  @override
  String get colFare => 'किराया';

  @override
  String get colDocument => 'दस्तावेज़';

  @override
  String get colFor => 'किसका';

  @override
  String get colNumber => 'नंबर';

  @override
  String get colRole => 'भूमिका';

  @override
  String get colBalance => 'बाकी हिसाब';

  @override
  String get colShortfall => 'कमी';

  @override
  String get usualEfficiency => 'आम माइलेज';

  @override
  String get alertsInbox => 'अलर्ट और जाँच';

  @override
  String get documentsExpiredChip => 'दस्तावेज़ की मियाद ख़त्म';

  @override
  String get documentsDueChip => 'दस्तावेज़ जल्द ख़त्म';

  @override
  String get managersSection => 'मैनेजर';

  @override
  String get noManagersYet => 'अभी कोई मैनेजर नहीं।';

  @override
  String get shareTripHeading => 'ट्रिप की जानकारी';

  @override
  String get shareCustomer => 'ग्राहक';

  @override
  String get sharePickup => 'पिकअप';

  @override
  String get shareDrop => 'ड्रॉप';

  @override
  String get sharePickupTime => 'पिकअप का समय';

  @override
  String get shareCab => 'गाड़ी';

  @override
  String get shareDriver => 'ड्राइवर';

  @override
  String get shareFare => 'किराया';

  @override
  String shareFareWithKm({required String fare, required String km}) {
    return '$fare ($km शामिल)';
  }

  @override
  String get copyDetails => 'जानकारी कॉपी करें';

  @override
  String get detailsCopied => 'ट्रिप की जानकारी कॉपी हो गई';

  @override
  String get shareOnWhatsApp => 'व्हाट्सऐप पर भेजें';

  @override
  String get whatsAppUnavailable => 'व्हाट्सऐप नहीं खुल सका';

  @override
  String get analytics => 'विश्लेषण';

  @override
  String get analyticsIntro =>
      'महीने भर का रोज़ का फ़्यूल, कमाई और किलोमीटर, हर गाड़ी के हिसाब से।';

  @override
  String get month => 'महीना';

  @override
  String get perTripAverages => 'हर ट्रिप का औसत';

  @override
  String get avgKmPerTrip => 'प्रति ट्रिप किलोमीटर';

  @override
  String get avgRevenuePerTrip => 'प्रति ट्रिप कमाई';

  @override
  String get avgFuelCostPerTrip => 'प्रति ट्रिप फ़्यूल ख़र्च (अनुमान)';

  @override
  String tripsInMonth({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इस महीने $count ट्रिप',
    );
    return '$_temp0';
  }

  @override
  String get fuelBoughtPerDay => 'रोज़ भरा गया फ़्यूल';

  @override
  String get revenuePerDay => 'रोज़ की कमाई';

  @override
  String get kmPerDay => 'रोज़ चले किलोमीटर';

  @override
  String monthTotal({required String total}) {
    return 'महीने का कुल: $total';
  }

  @override
  String get fuelInRupeesNote =>
      '₹ में दिखाया है, क्योंकि लीटर और किलो जोड़े नहीं जा सकते।';

  @override
  String get noActivityThisMonth => 'इस महीने कुछ नहीं।';

  @override
  String get customDay => 'तारीख़ चुनें';

  @override
  String tripsOnDay({required String date}) {
    return '$date की ट्रिप';
  }

  @override
  String get availableCabs => 'ख़ाली गाड़ियाँ';

  @override
  String get availableDrivers => 'ख़ाली ड्राइवर';

  @override
  String get tripsUnassigned => 'बिना गाड़ी की ट्रिप';

  @override
  String get completedTrips => 'पूरी हुई ट्रिप';

  @override
  String percentReady({required int percent}) {
    return '$percent% तैयार';
  }

  @override
  String cabsFooter({required int onTrip, required int inactive}) {
    return '$onTrip ट्रिप पर · $inactive बंद';
  }

  @override
  String driversFooter({required int onTrip, required int assigned}) {
    return '$onTrip ट्रिप पर · $assigned को ट्रिप मिली';
  }

  @override
  String get standby => 'तैयार';

  @override
  String get needsCab => 'गाड़ी चाहिए';

  @override
  String get pending => 'बाकी';

  @override
  String get resolveQueue => 'लाइन निपटाएँ';

  @override
  String get runs => 'ट्रिप';

  @override
  String grossFare({required String amount}) {
    return 'कुल किराया $amount';
  }

  @override
  String busyFromTo({required String from, required String to}) {
    return 'व्यस्त $from – $to';
  }

  @override
  String get busyPickCleared =>
      'चुनी गई गाड़ी या ड्राइवर नए समय पर बुक है, इसलिए हटा दिया गया।';

  @override
  String get busyPickWarning => 'यह गाड़ी या ड्राइवर इस समय पहले से बुक है।';

  @override
  String youAreBusy({required String when}) {
    return 'इस समय आपकी पहले से एक ट्रिप है ($when)।';
  }

  @override
  String get uploadFile => 'फ़ाइल अपलोड करें';

  @override
  String get chooseOtherFile => 'दूसरी फ़ाइल चुनें';

  @override
  String get uploadFileHint =>
      'या PDF या फ़ोटो (JPG, PNG, WebP) अपलोड करें, 15 MB तक।';

  @override
  String get fileTooLarge => 'यह फ़ाइल 15 MB से बड़ी है।';

  @override
  String get pdfDocument => 'PDF दस्तावेज़';

  @override
  String get imageFile => 'फ़ोटो';

  @override
  String get viewDocument => 'दस्तावेज़ देखें';

  @override
  String get documentUnavailable =>
      'दस्तावेज़ नहीं खुल सका। फिर से कोशिश करें।';

  @override
  String get schedule => 'शेड्यूल';

  @override
  String get noTripsThisDay => 'इस दिन कोई ट्रिप नहीं।';

  @override
  String get previousMonth => 'पिछला महीना';

  @override
  String get nextMonth => 'अगला महीना';

  @override
  String get logInWithOtp => 'OTP से लॉग इन करें';

  @override
  String get noAccountForNumber =>
      'इस नंबर से अभी कोई अकाउंट नहीं है। साइन अप करें।';

  @override
  String get signUpVerifyHint =>
      'नंबर आपका है, यह पक्का करने के लिए हम OTP भेजेंगे।';

  @override
  String get verifyAndCreateAccount => 'नंबर सत्यापित करें और अकाउंट बनाएँ';

  @override
  String get resetWithOtpIntro =>
      'OTP से अपना मोबाइल नंबर सत्यापित करें, फिर नया पासवर्ड चुनें।';

  @override
  String get numberVerified => 'नंबर सत्यापित हो गया';

  @override
  String get verifyWithOtp => 'OTP से सत्यापित करें';

  @override
  String get phoneVerifyTitle => 'अपना नंबर सत्यापित करें';

  @override
  String get stubVerifyHint =>
      'टेस्ट मोड: कोई SMS नहीं भेजा जाता। नीचे दिया नंबर सत्यापित माना जाएगा।';

  @override
  String get errorPhoneOtpDisabled => 'OTP से साइन इन अभी उपलब्ध नहीं है।';

  @override
  String get errorPhoneNotVerified =>
      'आपका नंबर सत्यापित नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get errorPhoneMismatch =>
      'आपने जो नंबर सत्यापित किया, वह लिखे गए नंबर से अलग है।';

  @override
  String get errorPhoneVerificationRequired =>
      'साइन अप के लिए अपना मोबाइल नंबर सत्यापित करें।';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get allowPopups =>
      'नंबर सत्यापित करने के लिए इस साइट के पॉप-अप चालू करें, फिर से कोशिश करें।';

  @override
  String get tripInProgress => 'ट्रिप चल रही है';

  @override
  String get nextTrip => 'अगली ट्रिप';

  @override
  String startsIn({required String time}) {
    return '$time में शुरू';
  }

  @override
  String get startingNow => 'अभी शुरू';

  @override
  String runningLate({required String time}) {
    return '$time देर';
  }

  @override
  String get todayAtAGlance => 'आज एक नज़र में';

  @override
  String get lastSevenDays => 'पिछले 7 दिन';

  @override
  String get statTripsDone => 'पूरी ट्रिप';

  @override
  String get statKmDriven => 'चली दूरी';

  @override
  String get statCollected => 'वसूली';

  @override
  String ofTotal({required int done, required int total}) {
    return '$total में से $done';
  }

  @override
  String cashAmount({required String amount}) {
    return 'नकद $amount';
  }

  @override
  String get callCustomer => 'कॉल';

  @override
  String get directions => 'रास्ता';

  @override
  String kmSoFar({required String km}) {
    return 'अब तक $km';
  }

  @override
  String durationHm({required int h, required String m}) {
    return '$h घं $m मि';
  }

  @override
  String durationM({required int m}) {
    return '$m मि';
  }

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get noTripsAssigned => 'अभी कोई ट्रिप नहीं मिली';

  @override
  String get noTripsHint =>
      'जब आपका फ़्लीट मालिक कोई ट्रिप देगा, वह यहाँ दिखेगी। रीफ़्रेश के लिए नीचे खींचें, या खुद नई ट्रिप शुरू करें।';

  @override
  String get detailsTab => 'विवरण';

  @override
  String get documentFiles => 'फ़ाइलें (फ़ोटो या PDF)';

  @override
  String photoNumber({required int number}) {
    return 'फ़ोटो $number';
  }

  @override
  String tooManyFiles({required int count}) {
    return 'एक दस्तावेज़ में ज़्यादा से ज़्यादा $count फ़ाइलें हो सकती हैं।';
  }

  @override
  String fileTooLargeNamed({required String name}) {
    return '$name 15 MB से बड़ी है।';
  }

  @override
  String get uploadFiles => 'फ़ाइलें अपलोड करें';

  @override
  String viewFiles({required int count}) {
    return 'फ़ाइलें देखें ($count)';
  }

  @override
  String get open => 'खोलें';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String filtersCount({required int count}) {
    return 'फ़िल्टर ($count)';
  }

  @override
  String get clearAll => 'सब हटाएँ';

  @override
  String get apply => 'लागू करें';

  @override
  String get severity => 'गंभीरता';

  @override
  String get alertKindTitle => 'प्रकार';

  @override
  String get quickOpsHub => 'त्वरित संचालन केंद्र';

  @override
  String get fastDispatch => 'फ़ास्ट-डिस्पैच';

  @override
  String get addTrip => 'ट्रिप जोड़ें';

  @override
  String get tagDriver => 'ड्राइवर टैग करें';

  @override
  String get addDriverQuick => '+ ड्राइवर जोड़ें';

  @override
  String get addCabQuick => '+ कैब जोड़ें';

  @override
  String get scheduledRides => 'निर्धारित सवारियाँ';

  @override
  String scheduledRidesOn({required String date}) {
    return 'निर्धारित सवारियाँ · $date';
  }

  @override
  String get noTripsWaiting => 'कोई ट्रिप ड्राइवर का इंतज़ार नहीं कर रही।';

  @override
  String get pickTripToAssign => 'असाइन करने के लिए ट्रिप चुनें';

  @override
  String get docAadhaar => 'आधार कार्ड';

  @override
  String get docPan => 'पैन कार्ड';

  @override
  String get docPoliceVerification => 'पुलिस सत्यापन';

  @override
  String get docBadge => 'बैज / PSV लाइसेंस';

  @override
  String get docPhoto => 'फ़ोटो';

  @override
  String get noExpiry => 'कोई समाप्ति नहीं';

  @override
  String get docPendingApproval => 'मंज़ूरी का इंतज़ार';

  @override
  String get docRejected => 'अस्वीकृत';

  @override
  String docRejectedBecause({required String note}) {
    return 'अस्वीकृत: $note';
  }

  @override
  String get addedByDriver => 'ड्राइवर ने जोड़ा';

  @override
  String get renewalOf => 'नवीनीकरण';

  @override
  String get approveDocument => 'मंज़ूर करें';

  @override
  String get rejectDocument => 'अस्वीकार करें';

  @override
  String get rejectDocumentTitle => 'यह दस्तावेज़ अस्वीकार करें?';

  @override
  String get rejectReasonLabel => 'कारण (ड्राइवर को दिखेगा)';

  @override
  String get documentApproved => 'दस्तावेज़ मंज़ूर हुआ';

  @override
  String get kindDocSubmitted => 'मंज़ूरी के लिए दस्तावेज़';

  @override
  String alertDocSubmittedTitle({required String driver, required String doc}) {
    return '$driver ने अपना $doc जोड़ा';
  }

  @override
  String alertDocRenewedTitle({required String driver, required String doc}) {
    return '$driver ने नया $doc अपलोड किया';
  }

  @override
  String get alertDocSubmittedBody =>
      'इसे देखें और उनके दस्तावेज़ टैब पर मंज़ूर या अस्वीकार करें।';

  @override
  String get navHome => 'होम';

  @override
  String get navMyDocuments => 'दस्तावेज़';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get assignedTab => 'असाइन';

  @override
  String get pastTab => 'पिछली';

  @override
  String get noAssignedTrips => 'अभी आपको कोई ट्रिप नहीं मिली है।';

  @override
  String get noPastTrips => 'इस महीने कोई ट्रिप नहीं।';

  @override
  String get myDocumentsIntro =>
      'अपना लाइसेंस, आधार और बाकी कागज़ जोड़ें। फ़्लीट मालिक हर एक को जाँचकर मंज़ूर करेंगे।';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String get editName => 'नाम बदलें';

  @override
  String get yourName => 'आपका नाम';

  @override
  String get nameSaved => 'नाम सेव हुआ';

  @override
  String get fleetLabel => 'फ़्लीट';

  @override
  String get phoneNumberLabel => 'मोबाइल नंबर';

  @override
  String get cabsYouDrive => 'आप ये कैब चला सकते हैं';

  @override
  String get noCabsLinked => 'अभी कोई कैब नहीं जुड़ी। फ़्लीट मालिक से पूछें।';

  @override
  String driverSince({required String date}) {
    return '$date से ड्राइवर';
  }

  @override
  String get when => 'कब';

  @override
  String confirmUpload({required int count}) {
    return 'अपलोड की पुष्टि करें ($count)';
  }

  @override
  String get fileReadyToUpload => 'चुनी गई · अभी अपलोड नहीं हुई';

  @override
  String get fileUploading => 'अपलोड हो रही है…';

  @override
  String get fileUploaded => 'अपलोड हो गई';

  @override
  String get fileUploadFailed => 'अपलोड नहीं हुई · फिर कोशिश करें';

  @override
  String get uploadFilesFirst =>
      'पहले चुनी गई फ़ाइलें अपलोड करने के लिए \"अपलोड की पुष्टि करें\" दबाएँ।';

  @override
  String filesUploadedCount({required int count}) {
    return '$count फ़ाइलें अपलोड हुईं';
  }

  @override
  String get colFiles => 'फ़ाइलें';

  @override
  String get noFiles => 'कोई फ़ाइल नहीं';

  @override
  String get fixHighlighted => 'लाल निशान वाले खाने भरें।';

  @override
  String get documentSentForApproval =>
      'दस्तावेज़ जुड़ गया। फ़्लीट मालिक इसे मंज़ूर करेंगे।';

  @override
  String get documentSaved => 'दस्तावेज़ सेव हुआ';

  @override
  String uploadAndSave({required int count}) {
    return '$count फ़ाइलें अपलोड करके सेव करें';
  }

  @override
  String get photoMustBeImage => 'कोई फ़ोटो चुनें (JPG, PNG या WebP)।';

  @override
  String get invalidEmail => 'सही ईमेल पता लिखें';

  @override
  String get invalidMobile => '10 अंकों का मोबाइल नंबर लिखें';

  @override
  String get dateOfBirth => 'जन्म तिथि';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get addressLabel => 'पता';

  @override
  String get emergencyContact => 'आपातकालीन संपर्क';

  @override
  String get contactName => 'संपर्क का नाम';

  @override
  String get contactPhone => 'संपर्क का मोबाइल नंबर';

  @override
  String get editProfile => 'प्रोफ़ाइल बदलें';

  @override
  String get editDetails => 'विवरण बदलें';

  @override
  String get choosePhoto => 'फ़ोटो चुनें';

  @override
  String get changePhone => 'मोबाइल नंबर बदलें';

  @override
  String get changePhoneIntro =>
      'आप इसी मोबाइल नंबर से लॉग इन करते हैं। नए नंबर पर कोड भेजकर जाँचेंगे कि वह आपका है।';

  @override
  String codeSentTo({required String phone}) {
    return '$phone पर भेजा गया 6 अंकों का कोड लिखें';
  }

  @override
  String get verifyAndChange => 'जाँचें और बदलें';

  @override
  String get phoneChanged => 'मोबाइल नंबर बदल गया';

  @override
  String get profileSaved => 'प्रोफ़ाइल सेव हुई';

  @override
  String get personalDetails => 'निजी विवरण';

  @override
  String get discardDocumentTitle => 'यह दस्तावेज़ छोड़ दें?';

  @override
  String get discardDocumentBody =>
      'यह सेव नहीं हुआ है। जोड़ी गई फ़ाइलें और जानकारी हट जाएँगी।';

  @override
  String get keepEditing => 'बदलाव जारी रखें';

  @override
  String get discard => 'छोड़ दें';

  @override
  String uploadingStep({required int n, required int count}) {
    return '$count में से $n अपलोड हो रही है…';
  }

  @override
  String get savingStep => 'सेव हो रहा है…';

  @override
  String get welcomeSignIn => 'साइन इन';

  @override
  String get welcomeGetStarted => 'शुरू करें';

  @override
  String get welcomeHaveAccount => 'मेरा अकाउंट है';

  @override
  String get welcomeAbout => 'फ़्लीट सारथी क्या है?';

  @override
  String get welcomeEyebrow =>
      'ओनर-ड्राइवर और 2–15 गाड़ियों वाले फ़्लीट के लिए';

  @override
  String get welcomeHeadlineLead => 'जानिए आपकी गाड़ियों ने';

  @override
  String get welcomeHeadlineAccent => 'आज असल में क्या किया।';

  @override
  String get welcomeSubhead =>
      'फ़ोटो से पक्की ट्रिप, हर गाड़ी के अपने माइलेज से जाँचा गया ईंधन, GPS से दूरी की जाँच और हर ड्राइवर का रोज़ का कैश हिसाब। आपके और आपके ड्राइवरों के लिए एक ही ऐप।';

  @override
  String get welcomeTrustOffline => 'बिना इंटरनेट भी चले';

  @override
  String get welcomeTrustPlatforms => 'Android और वेब';

  @override
  String get welcomeTrustLanguages => 'हिन्दी, English, ಕನ್ನಡ, मराठी';

  @override
  String get welcomeTrustNoCard => 'कार्ड की ज़रूरत नहीं';

  @override
  String get welcomeMockToday => 'आज';

  @override
  String get welcomeMockLive => 'लाइव';

  @override
  String get welcomeMockTrips => 'ट्रिप';

  @override
  String get welcomeMockKm => 'चली दूरी (km)';

  @override
  String get welcomeMockCash => 'बकाया कैश';

  @override
  String get welcomeMockMileage => 'माइलेज, पिछले 8 फ़िल';

  @override
  String get welcomeMockFuelTitle => 'ईंधन जाँच';

  @override
  String get welcomeMockFuelBody =>
      'MH 12 AB 4521 ने 9.1 km/l दिया, अपने आम 11.7 से 22% कम';

  @override
  String get welcomeMockGpsTitle => 'दूरी सही निकली';

  @override
  String get welcomeMockGpsBody => 'पुणे → मुंबई: GPS 148 km, मीटर 151 km';

  @override
  String get welcomeMockSettleTitle => 'रमेश · आज का हिसाब';

  @override
  String get welcomeMockSettleBody => 'किराया ₹4,200 − ख़र्च ₹640';

  @override
  String get welcomeBuiltFor => 'किसके लिए बना';

  @override
  String get welcomeForDco => 'ओनर-ड्राइवर (DCO)';

  @override
  String get welcomeForSmallFleets => '2–15 गाड़ियों के फ़्लीट';

  @override
  String get welcomeForIntercity => 'इंटरसिटी और आउटस्टेशन';

  @override
  String get welcomeForLocal => 'लोकल और एयरपोर्ट ट्रिप';

  @override
  String get welcomeFeaturesKicker => 'सब कुछ एक ऐप में';

  @override
  String get welcomeFeaturesTitle =>
      'भारतीय कैब फ़्लीट के असली काम के हिसाब से बना';

  @override
  String get welcomeFeatureFuelTitle => 'ईंधन ऑडिट';

  @override
  String get welcomeFeatureFuelBody =>
      'हर गाड़ी का माइलेज उसके अपने औसत से, या पेट्रोल + CNG गाड़ियों के लिए प्रति km ख़र्च।';

  @override
  String get welcomeFeatureTripsTitle => 'सबूत के साथ ट्रिप';

  @override
  String get welcomeFeatureTripsBody =>
      'ट्रिप बनाएँ और ड्राइवर को दें, फिर मीटर की फ़ोटो और नक़्शे पर GPS रूट देखें।';

  @override
  String get welcomeFeatureSettleTitle => 'रोज़ का हिसाब';

  @override
  String get welcomeFeatureSettleBody =>
      'किराया, कैश, ऑनलाइन पेमेंट, ख़र्च और आपके पेमेंट नियम, सब जोड़कर एक बकाया रक़म।';

  @override
  String get welcomeFeatureDocsTitle => 'डॉक्यूमेंट रिमाइंडर';

  @override
  String get welcomeFeatureDocsBody =>
      'RC, बीमा, परमिट, PUC और लाइसेंस: ख़त्म होने से 30, 7 और 1 दिन पहले अलर्ट।';

  @override
  String get welcomeFeatureOfflineTitle => 'नेटवर्क न हो तब भी चले';

  @override
  String get welcomeFeatureOfflineBody =>
      'घाट और हाईवे पर भी ड्राइवर ऐप दर्ज करता रहता है, और नेटवर्क लौटते ही सिंक कर देता है।';

  @override
  String get welcomeFeatureDcoTitle => 'मालिक भी, ड्राइवर भी';

  @override
  String get welcomeFeatureDcoBody =>
      'एक ही अकाउंट से अपना फ़्लीट चलाएँ और किसी और के फ़्लीट में गाड़ी भी चलाएँ। एक टैप में बदलें।';

  @override
  String get welcomeStepsKicker => 'कैसे काम करता है';

  @override
  String get welcomeStepsTitle => 'अगली ट्रिप से पहले तैयार';

  @override
  String get welcomeStep1Title => 'गाड़ियाँ और ड्राइवर जोड़ें';

  @override
  String get welcomeStep1Body =>
      'मोबाइल नंबर से साइन अप करें, गाड़ियाँ जोड़ें और ड्राइवरों को उनके नंबर से जोड़ें।';

  @override
  String get welcomeStep2Title => 'ड्राइवर फ़ोन से दर्ज करें';

  @override
  String get welcomeStep2Body =>
      'मीटर फ़ोटो के साथ ट्रिप शुरू और ख़त्म करें, रसीद के साथ ईंधन दर्ज करें, टोल और कैश जोड़ें।';

  @override
  String get welcomeStep3Title => 'आपको रोज़ सही तस्वीर';

  @override
  String get welcomeStep3Body =>
      'कुछ गड़बड़ लगे तो अलर्ट, और दिन के अंत में हर ड्राइवर का हिसाब।';

  @override
  String get welcomeOwnersTitle => 'मालिकों के लिए';

  @override
  String get welcomeOwners1 => 'हर गाड़ी और ड्राइवर एक डैशबोर्ड पर';

  @override
  String get welcomeOwners2 => 'कैंसलेशन मंज़ूर करें और संदिग्ध ट्रिप जाँचें';

  @override
  String get welcomeOwners3 =>
      'पेमेंट नियम एक बार तय करें, हिसाब उन्हीं से बनेगा';

  @override
  String get welcomeOwners4 => 'फ़ोन या लैपटॉप, कहीं भी चलाएँ';

  @override
  String get welcomeDriversTitle => 'ड्राइवरों के लिए';

  @override
  String get welcomeDrivers1 =>
      'हिन्दी, English, कन्नड़ या मराठी में आसान स्क्रीन';

  @override
  String get welcomeDrivers2 => 'आज की ट्रिप क्रम से, एक टैप में शुरू';

  @override
  String get welcomeDrivers3 => 'नेटवर्क जाए तब भी कुछ नहीं खोता';

  @override
  String get welcomeDrivers4 => 'लाइसेंस और डॉक्यूमेंट हमेशा अपडेट';

  @override
  String get welcomeFaqTitle => 'मालिक अक्सर पूछते हैं';

  @override
  String get welcomeFaqOfflineQ => 'क्या ड्राइवरों को हर समय इंटरनेट चाहिए?';

  @override
  String get welcomeFaqOfflineA =>
      'नहीं। ड्राइवर ऐप सब कुछ फ़ोन में सेव करता है और नेटवर्क आते ही क्रम से भेज देता है।';

  @override
  String get welcomeFaqDcoQ => 'अगर मैं अपनी गाड़ी ख़ुद चलाता हूँ तो?';

  @override
  String get welcomeFaqDcoA =>
      'हाँ। ओनर-ड्राइवर को मालिक और ड्राइवर, दोनों की स्क्रीन मिलती हैं, और वे इनमें बदल सकते हैं।';

  @override
  String get welcomeFaqPrivacyQ => 'क्या मेरे फ़्लीट का डेटा निजी है?';

  @override
  String get welcomeFaqPrivacyA =>
      'हाँ। हर फ़्लीट का डेटा डेटाबेस के स्तर तक अलग रखा जाता है, और सिर्फ़ आपके जोड़े लोग ही उसे देख सकते हैं।';

  @override
  String get welcomeFaqPhoneQ => 'ड्राइवर को कौन-सा फ़ोन चाहिए?';

  @override
  String get welcomeFaqPhoneA =>
      'कैमरा वाला कोई भी Android फ़ोन। मालिक फ़्लीट सारथी को वेब ब्राउज़र में भी चला सकते हैं।';

  @override
  String get welcomeFaqLanguageQ => 'क्या यह मेरी भाषा में है?';

  @override
  String get welcomeFaqLanguageA =>
      'हाँ। हर स्क्रीन हिन्दी, English, कन्नड़ और मराठी में है; ऊपर से कभी भी भाषा बदलें।';

  @override
  String get welcomeFinalTitle => 'अंदाज़ा छोड़िए, पक्का जानिए।';

  @override
  String get welcomeFinalBody =>
      'सिर्फ़ मोबाइल नंबर से कुछ ही मिनटों में अपना फ़्लीट तैयार करें।';

  @override
  String get loginTagline => 'हर किलोमीटर का हिसाब।';

  @override
  String get loginAboutCompany =>
      'भारत के ओनर-ड्राइवरों और छोटी फ्लीट के लिए फ्लीट ऑडिट और कैब संचालन।';

  @override
  String get welcomeFooter => 'भारत में बना, भारत के कैब फ़्लीट के लिए।';

  @override
  String get welcomeShowcaseKicker => 'काम करते हुए देखें';

  @override
  String get welcomeShowcaseTitle => 'रोज़ की परेशानियों का एक ही हल';

  @override
  String get welcomeShowcaseSubtitle =>
      'जब आप गाड़ी में नहीं होते, तो सब कुछ डायरी और WhatsApp मैसेज के भरोसे होता है। देखिए क्या बदलता है।';

  @override
  String get welcomeTabFuel => 'ईंधन';

  @override
  String get welcomeTabSettlement => 'हिसाब';

  @override
  String get welcomeTabDocuments => 'डॉक्यूमेंट';

  @override
  String get welcomeTabOffline => 'ऑफ़लाइन';

  @override
  String get welcomeUcFuelTitle => 'पंप पर खड़े हुए बिना ईंधन की चोरी पकड़ें';

  @override
  String get welcomeUcFuelBody =>
      'ड्राइवर रसीद की फ़ोटो लेते हैं और फ़ुल टैंक फ़िल पर निशान लगाते हैं। फ़्लीट सारथी हर गाड़ी का अपना माइलेज हर बार निकालता है और गिरते ही आपको बताता है।';

  @override
  String get welcomeUcFuelPoint1 =>
      'हर गाड़ी का अपना औसत, कंपनी का आँकड़ा नहीं';

  @override
  String get welcomeUcFuelPoint2 =>
      'पेट्रोल + CNG गाड़ियों के लिए प्रति km ख़र्च';

  @override
  String get welcomeUcFuelPoint3 => 'साफ़ शब्दों में अलर्ट, उलझे चार्ट नहीं';

  @override
  String get welcomeUcFuelThisCycle => 'इस बार';

  @override
  String get welcomeUcFuelUsual => 'इसका औसत';

  @override
  String get welcomeUcTripsTitle => 'हर किलोमीटर के पीछे फ़ोटो और GPS';

  @override
  String get welcomeUcTripsBody =>
      'ड्राइवर हर ट्रिप मीटर की फ़ोटो के साथ शुरू और ख़त्म करते हैं। रीडिंग को फ़ोटो और GPS रूट से मिलाया जाता है, और जो मेल न खाए वह आपकी जाँच के लिए रुकता है।';

  @override
  String get welcomeUcTripsPoint1 => 'शुरू और अंत में मीटर की फ़ोटो';

  @override
  String get welcomeUcTripsPoint2 => 'हर ट्रिप का रूट नक़्शे पर';

  @override
  String get welcomeUcTripsPoint3 => 'गड़बड़ी आपकी जाँच सूची में';

  @override
  String get welcomeUcTripStart => 'शुरू';

  @override
  String get welcomeUcTripEnd => 'अंत';

  @override
  String get welcomeUcTripRoute => 'पुणे → मुंबई';

  @override
  String get welcomeUcTripDriver => 'रमेश · MH 12 AB 4521';

  @override
  String get welcomeUcTripCheck => 'GPS 148 km · मीटर 151 km';

  @override
  String get welcomeUcSettleTitle => 'हर ड्राइवर का दिन, एक आँकड़े में';

  @override
  String get welcomeUcSettleBody =>
      'किराया, कैश, UPI और कार्ड, टोल और पार्किंग, और आपका पेमेंट नियम, सब मिलकर एक रक़म बनती है: ड्राइवर आपको कितना देगा, या आप उसे कितना देंगे।';

  @override
  String get welcomeUcSettlePoint1 => 'हर ड्राइवर का पेमेंट नियम एक बार तय';

  @override
  String get welcomeUcSettlePoint2 => 'कैश और ऑनलाइन पैसा अलग-अलग';

  @override
  String get welcomeUcSettlePoint3 => 'टोल और पार्किंग रसीद के साथ';

  @override
  String get welcomeUcSettleHeader => 'रमेश · आज';

  @override
  String get welcomeUcSettleFare => 'किराया';

  @override
  String get welcomeUcSettleCash => 'कैश में मिला';

  @override
  String get welcomeUcSettleOnline => 'ऑनलाइन मिला (UPI, कार्ड)';

  @override
  String get welcomeUcSettleExpenses => 'टोल और पार्किंग का ख़र्च';

  @override
  String get welcomeUcSettlePay => 'ड्राइवर का हिस्सा (किराये का 30%)';

  @override
  String get welcomeUcSettleNet => 'रमेश जमा करेगा';

  @override
  String get welcomeUcDocsTitle => 'एक्सपायर्ड परमिट के साथ कभी न पकड़े जाएँ';

  @override
  String get welcomeUcDocsBody =>
      'हर गाड़ी और ड्राइवर के RC, बीमा, परमिट, PUC और ड्राइविंग लाइसेंस एक जगह, और हर एक के ख़त्म होने से 30, 7 और 1 दिन पहले रिमाइंडर।';

  @override
  String get welcomeUcDocsPoint1 => 'हर गाड़ी और हर ड्राइवर';

  @override
  String get welcomeUcDocsPoint2 => 'फ़ोटो या PDF अपलोड करें';

  @override
  String get welcomeUcDocsPoint3 => 'डेडलाइन से पहले याद, बाद में नहीं';

  @override
  String get welcomeUcDocsHeader => 'जल्द ख़त्म हो रहे';

  @override
  String get welcomeUcDocsRow1 => 'MH 12 AB 4521 · बीमा';

  @override
  String get welcomeUcDocsDue1 => '7 दिन में';

  @override
  String get welcomeUcDocsRow2 => 'सुरेश · ड्राइविंग लाइसेंस';

  @override
  String get welcomeUcDocsDue2 => 'कल';

  @override
  String get welcomeUcDocsRow3 => 'MH 14 CD 7788 · परमिट';

  @override
  String get welcomeUcDocsDue3 => '30 दिन में';

  @override
  String get welcomeUcDocsRow4 => 'MH 12 AB 4521 · PUC';

  @override
  String get welcomeUcDocsDue4 => 'मान्य';

  @override
  String get welcomeUcOfflineTitle => 'हाईवे और घाट के रास्तों के लिए बना';

  @override
  String get welcomeUcOfflineBody =>
      'नेटवर्क नहीं? ड्राइवर ऐप ट्रिप, ईंधन और पेमेंट फ़ोन में दर्ज करता रहता है और नेटवर्क लौटते ही क्रम से भेज देता है। न कुछ खोता है, न कुछ दो बार गिना जाता है।';

  @override
  String get welcomeUcOfflinePoint1 => 'बिल्कुल बिना नेटवर्क के भी चले';

  @override
  String get welcomeUcOfflinePoint2 => 'अपने आप, क्रम से सिंक';

  @override
  String get welcomeUcOfflinePoint3 => 'दोबारा भेजने पर भी दोहराव नहीं';

  @override
  String get welcomeUcOfflineBanner =>
      'नेटवर्क नहीं · इसी फ़ोन में सेव हो रहा है';

  @override
  String get welcomeUcOfflineTrip => 'ट्रिप चल रही है · पुणे → लोनावला';

  @override
  String get welcomeUcOfflineFuel => 'ईंधन फ़िल सेव · ₹2,150';

  @override
  String get welcomeUcOfflineCash => 'कैश मिला · ₹1,200';

  @override
  String get welcomeUcOfflineWaiting => '3 बदलाव सिंक होने बाकी';

  @override
  String percentFree({required int percent}) {
    return '$percent% ख़ाली';
  }

  @override
  String cabHoursFree({required String reg, required int hours}) {
    return '$reg: $hours घंटे ख़ाली';
  }

  @override
  String moreCabs({required int count}) {
    return '+$count और';
  }

  @override
  String get welcomeMockCabsToday => 'आज की गाड़ियाँ';

  @override
  String get welcomeTabAvailability => 'उपलब्धता';

  @override
  String get welcomeUcAvailTitle => 'घंटे-घंटे देखें कौन-सी गाड़ी ख़ाली है';

  @override
  String get welcomeUcAvailBody =>
      'हर गाड़ी का दिन एक लाइन पर: ख़ाली हो तो हरा, ट्रिप पर हो तो लाल। ग्राहक से वादा करने से पहले नई बुकिंग की जगह देख लें।';

  @override
  String get welcomeUcAvailPoint1 => 'डैशबोर्ड पर ही, किसी भी दिन के लिए';

  @override
  String get welcomeUcAvailPoint2 => 'रात भर की ट्रिप भी सही गिनी जाती हैं';

  @override
  String get welcomeUcAvailPoint3 => 'पूरे फ़्लीट के ख़ाली घंटों का हिस्सा';

  @override
  String get welcomeUcAvailFreeNow => 'अभी ख़ाली: 5 में से 2';

  @override
  String nSelected({required int count}) {
    return '$count चुने गए';
  }

  @override
  String get dateRangeLabel => 'तारीखें';

  @override
  String get rangeFrom => 'से';

  @override
  String get rangeTo => 'तक';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get customRange => 'अपनी तारीखें';

  @override
  String get kindTripUnassigned => 'गाड़ी या ड्राइवर नहीं';

  @override
  String alertTripUnassignedTitle({required String route}) {
    return '$route के लिए अभी गाड़ी या ड्राइवर तय नहीं';
  }

  @override
  String alertTripUnassignedBody({required String when}) {
    return 'यह ट्रिप $when शुरू होगी। उससे पहले गाड़ी और ड्राइवर तय करें।';
  }

  @override
  String alertTripUnassignedOverdueBody({required String when}) {
    return 'इसे $when शुरू होना था, पर अब तक गाड़ी या ड्राइवर तय नहीं है। गाड़ी और ड्राइवर तय करें, या ट्रिप रद्द करें।';
  }

  @override
  String docNumberLabel({required String doc}) {
    return '$doc नंबर';
  }

  @override
  String docNumberHint({required String example}) {
    return 'जैसे $example';
  }

  @override
  String get docNumberMissing => 'नंबर डालें';

  @override
  String docNumberFormat({required String example}) {
    return 'यह सही नहीं लगता। ऐसा होना चाहिए: $example';
  }

  @override
  String get aadhaarFormat =>
      '12 अंकों का आधार नंबर डालें (यह 0 या 1 से शुरू नहीं होता)';

  @override
  String get aadhaarChecksum => 'यह मान्य आधार नंबर नहीं है। अंक जाँचें।';

  @override
  String get expiryBeforeStart => 'मान्य-से तारीख के बाद होनी चाहिए';

  @override
  String get errorDriverInactive =>
      'फ़्लीट मालिक ने निष्क्रिय किया है: नई ट्रिप न बनाई जा सकती है, न दी जा सकती है।';

  @override
  String get errorDriverHasTrips =>
      'ड्राइवर के पास अभी असाइन की गई ट्रिप हैं। पहले उन्हें हटाएँ।';

  @override
  String driverHasTripsTitle({required int count, required String name}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name की $count आने वाली ट्रिप हैं',
      one: '$name की 1 आने वाली ट्रिप है',
    );
    return '$_temp0';
  }

  @override
  String get driverHasTripsBody =>
      'निष्क्रिय करने के लिए पहले ये ट्रिप हटाएँ। ये बिना ड्राइवर वाली सूची में चली जाएँगी, ताकि आप इन्हें दूसरे ड्राइवर को दे सकें।';

  @override
  String get unassignAndDeactivate => 'ट्रिप हटाएँ और निष्क्रिय करें';

  @override
  String driverOnTripTitle({required String name}) {
    return '$name अभी ट्रिप पर हैं';
  }

  @override
  String get driverOnTripBody =>
      'ट्रिप खत्म होने के बाद उन्हें निष्क्रिय करें।';

  @override
  String get driverInactiveBanner =>
      'आपके फ़्लीट मालिक ने आपको निष्क्रिय कर दिया है। आप पुरानी ट्रिप देख सकते हैं, पर नई ट्रिप नहीं बना सकते।';

  @override
  String get driverTripsTurnedOff =>
      'आपके फ़्लीट मालिक ने ड्राइवर ऐप से ट्रिप बनाना बंद कर दिया है।';

  @override
  String get errorDriverTripsDisabled =>
      'आपके फ़्लीट मालिक ने ड्राइवरों का ट्रिप बनाना बंद कर दिया है।';

  @override
  String get errorDriverChargesDisabled =>
      'आपके फ़्लीट मालिक ने ड्राइवरों का चार्ज जोड़ना बंद कर दिया है।';

  @override
  String get errorReceiptRequired => 'ईंधन की रसीद की फ़ोटो जोड़ें।';

  @override
  String get settingsIntro =>
      'चुनें कि फ़्लीट सारथी आपके फ़्लीट के लिए कैसे काम करे। हर पेज बताता है कि सेटिंग क्या बदलती है और कब से लागू होती है।';

  @override
  String get settingsGroupFleet => 'आपका फ़्लीट';

  @override
  String get settingsGroupYou => 'आप';

  @override
  String get settingsGeneral => 'सामान्य';

  @override
  String get settingsGeneralDesc => 'आपके फ़्लीट का नाम';

  @override
  String get settingsTrips => 'ट्रिप और ड्राइवर';

  @override
  String get settingsTripsDesc => 'ड्राइवर क्या कर सकते हैं, और दूरी की जाँच';

  @override
  String get settingsFuel => 'ईंधन ऑडिट';

  @override
  String get settingsFuelDesc => 'रसीद, और कब किसी फ़िल पर अलर्ट आए';

  @override
  String get settingsReminders => 'डॉक्यूमेंट और रिमाइंडर';

  @override
  String get settingsRemindersDesc =>
      'काग़ज़ ख़त्म होने से पहले कब याद दिलाया जाए';

  @override
  String get settingsPayDesc => 'जिन ड्राइवरों का अपना नियम नहीं, उनका पेमेंट';

  @override
  String get settingsTeam => 'टीम और भूमिकाएँ';

  @override
  String get settingsTeamDesc => 'मैनेजर, और हर भूमिका क्या कर सकती है';

  @override
  String get settingsLanguageDesc => 'इस डिवाइस पर ऐप की भाषा';

  @override
  String get settingsSecurityDesc => 'आपका पासवर्ड और मोबाइल नंबर';

  @override
  String settingsAffects({required String area}) {
    return 'असर: $area';
  }

  @override
  String settingsApplies({required String when}) {
    return 'कब से: $when';
  }

  @override
  String get settingsSaveChanges => 'बदलाव सेव करें';

  @override
  String get settingsResetDefaults => 'डिफ़ॉल्ट पर लौटाएँ';

  @override
  String get settingsResetDone =>
      'डिफ़ॉल्ट भर दिए गए। लागू करने के लिए सेव करें।';

  @override
  String get settingsSaved => 'सेव हो गया।';

  @override
  String get settingsDiscardTitle => 'अपने बदलाव छोड़ दें?';

  @override
  String get settingsDiscardBody =>
      'आपने इस पेज पर सेटिंग बदलीं, पर सेव नहीं कीं।';

  @override
  String get settingsUnsaved => 'बिना सेव किए बदलाव';

  @override
  String settingsDefaultIs({required String value}) {
    return 'डिफ़ॉल्ट: $value';
  }

  @override
  String get settingsOn => 'चालू';

  @override
  String get settingsOff => 'बंद';

  @override
  String get fleetNameHelp =>
      'ऐप में आपके मैनेजरों और ड्राइवरों को, और ग्राहकों को भेजे ट्रिप मैसेज में दिखता है।';

  @override
  String get fleetNameAffects =>
      'वर्कस्पेस बदलना, डैशबोर्ड, शेयर किए ट्रिप मैसेज';

  @override
  String get fleetNameWhen =>
      'हर जगह तुरंत; ट्रिप और हिसाब में नाम सेव नहीं होता';

  @override
  String get fleetNameInvalid => '2 से 100 अक्षर लिखें।';

  @override
  String get ruleDriverTrips => 'ड्राइवर अपनी ट्रिप ख़ुद बना सकते हैं';

  @override
  String get ruleDriverTripsHelp =>
      'ड्राइवरों को \'नई ट्रिप\' बटन मिलता है और वे जिस गाड़ी से जुड़े हैं उसमें अपनी ट्रिप बुक कर सकते हैं। बंद होने पर सिर्फ़ आप और आपके मैनेजर ट्रिप बनाते हैं।';

  @override
  String get ruleDriverTripsAffects => 'ड्राइवर ऐप: नई ट्रिप';

  @override
  String get ruleNewTripsOnly =>
      'सिर्फ़ नई ट्रिप; पहले से बनी ट्रिप वैसी ही रहती हैं';

  @override
  String get ruleDriverCharges => 'ड्राइवर चार्ज जोड़ सकते हैं';

  @override
  String get ruleDriverChargesHelp =>
      'ड्राइवर ट्रिप के दौरान और ख़त्म करते समय टोल, पार्किंग और दूसरे चार्ज जोड़ सकते हैं। ड्राइवर के चुकाए चार्ज उसके रोज़ के हिसाब में गिने जाते हैं। बंद होने पर सिर्फ़ आप और आपके मैनेजर चार्ज जोड़ते हैं।';

  @override
  String get ruleDriverChargesAffects =>
      'ड्राइवर ऐप: ट्रिप चार्ज; रोज़ का हिसाब';

  @override
  String get ruleNewChargesOnly =>
      'सिर्फ़ नए चार्ज; पहले जोड़े गए चार्ज बने रहते हैं';

  @override
  String get ruleOfflineNote =>
      'अगर किसी ड्राइवर ने नियम बदलने से पहले बिना इंटरनेट कुछ दर्ज किया था, तो फ़ोन सिंक होने पर वह मना हो जाएगा और \'ध्यान दें\' में दिखेगा।';

  @override
  String get odoToleranceAffects =>
      'ख़त्म हुई ट्रिप पर मीटर बनाम GPS दूरी की जाँच';

  @override
  String get odoToleranceWhen =>
      'सेव करने के बाद होने वाली जाँच; पुराने नतीजे वैसे ही रहते हैं';

  @override
  String get ruleReceipt => 'ईंधन रसीद की फ़ोटो ज़रूरी';

  @override
  String get ruleReceiptHelp =>
      'हर ईंधन फ़िल के साथ रसीद की फ़ोटो चाहिए। अगर ड्राइवर अक्सर ऐसी जगह भरवाते हैं जहाँ छपी रसीद नहीं मिलती, तो बंद करें।';

  @override
  String get ruleReceiptAffects => 'ड्राइवर ऐप: ईंधन दर्ज करें';

  @override
  String get ruleNewFillsOnly =>
      'सिर्फ़ नए फ़िल; पहले दर्ज फ़िल वैसे ही रहते हैं';

  @override
  String get fuelThresholdsTitle => 'कब किसी फ़िल पर अलर्ट आए';

  @override
  String get fuelThresholdsAffects => 'ईंधन अलर्ट और हर गाड़ी का आम माइलेज';

  @override
  String get fuelThresholdsWhen =>
      'हर गाड़ी की अगली ईंधन जाँच (उसका अगला फ़िल); पहले के अलर्ट बने रहते हैं';

  @override
  String get remindersAffects =>
      'गाड़ी और ड्राइवर के डॉक्यूमेंट की एक्सपायरी के अलर्ट';

  @override
  String get remindersWhen => 'अगली रोज़ की जाँच से, लगभग सुबह 6 बजे';

  @override
  String get remindersSeverity =>
      'एक्सपायरी से 7 दिन या उससे कम पहले के अलर्ट चेतावनी हैं; 1 दिन या कम, या एक्सपायर हो चुके, गंभीर हैं।';

  @override
  String get payAffects =>
      'जिन ड्राइवरों का अपना पेमेंट नियम नहीं, उनका रोज़ का हिसाब';

  @override
  String get payWhen =>
      'जिन दिनों का हिसाब बाकी है; हिसाब हो चुके दिन वैसे ही रहते हैं';

  @override
  String get rolesTitle => 'हर भूमिका क्या कर सकती है';

  @override
  String get roleOwnerCan =>
      'सब कुछ, इन सेटिंग, पेमेंट नियमों और मैनेजरों समेत।';

  @override
  String get roleManagerCan =>
      'फ़्लीट चलाते हैं: ट्रिप, गाड़ियाँ, ड्राइवर, डॉक्यूमेंट, ईंधन और हिसाब। सेटिंग देख सकते हैं पर बदल नहीं सकते।';

  @override
  String get roleDriverCan =>
      'ड्राइवर ऐप में अपनी ट्रिप, ईंधन फ़िल, चार्ज और डॉक्यूमेंट।';

  @override
  String settingsRange({required String min, required String max}) {
    return '$min से $max तक की संख्या लिखें।';
  }

  @override
  String get settingsDaysInvalid =>
      '0 से 365 तक की ज़्यादा से ज़्यादा 5 पूरी संख्याएँ, जैसे 30, 7, 1।';

  @override
  String get placesCredit => 'Geoapify द्वारा · © OpenStreetMap योगदानकर्ता';
}
