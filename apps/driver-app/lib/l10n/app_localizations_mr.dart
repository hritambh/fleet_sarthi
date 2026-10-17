// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'फ्लीट सारथी';

  @override
  String get signOut => 'साइन आउट करा';

  @override
  String get language => 'भाषा';

  @override
  String get languageDevice => 'फोनची भाषा';

  @override
  String get appearance => 'दिसणे';

  @override
  String get themeSystem => 'फोनचे सेटिंग';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get switchToDark => 'डार्क मोडवर जा';

  @override
  String get switchToLight => 'लाइट मोडवर जा';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get save => 'सेव्ह करा';

  @override
  String get back => 'मागे';

  @override
  String get close => 'बंद करा';

  @override
  String get optional => 'ऐच्छिक';

  @override
  String get notSet => 'सेट केलेले नाही';

  @override
  String get noValue => '—';

  @override
  String somethingWentWrong({required String error}) {
    return 'काहीतरी चुकले: $error';
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
  String get today => 'आज';

  @override
  String get tomorrow => 'उद्या';

  @override
  String get yesterday => 'काल';

  @override
  String dayAndTime({required String day, required String time}) {
    return '$day, $time';
  }

  @override
  String get loginIntro =>
      'तुमच्या मोबाईल नंबरने साइन इन करा. ड्रायव्हरनी फ्लीट मालकाने नोंदवलेला नंबर वापरावा.';

  @override
  String loginCodeSent({required String phone}) {
    return '$phone वर पाठवलेला कोड टाका';
  }

  @override
  String get mobileNumber => 'मोबाईल नंबर';

  @override
  String get sixDigitCode => '6 अंकी कोड';

  @override
  String get sendCode => 'कोड पाठवा';

  @override
  String get useDifferentNumber => 'दुसरा नंबर वापरा';

  @override
  String get enterTenDigitMobile => 'तुमचा 10 अंकी मोबाईल नंबर टाका';

  @override
  String get enterSixDigitCode => '6 अंकी कोड टाका';

  @override
  String get loginCheckNumber => 'नंबर तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get ownerMode => 'मालक मोड';

  @override
  String get driverMode => 'ड्रायव्हर मोड';

  @override
  String get errorNetwork =>
      'कनेक्शन नाही. इंटरनेट तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get errorValidationFailed =>
      'काही माहिती बरोबर नाही. ती तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get errorUnauthenticated =>
      'तुम्ही साइन आउट झाला आहात. पुन्हा साइन इन करा.';

  @override
  String get errorTokenExpired => 'तुमचे सेशन संपले. पुन्हा साइन इन करा.';

  @override
  String get errorForbiddenRole => 'हे करण्याची तुम्हाला परवानगी नाही.';

  @override
  String get errorNoActiveOrg => 'तुमचा नंबर अजून कोणत्याही फ्लीटमध्ये नाही.';

  @override
  String get errorNotFound => 'सापडले नाही. ते काढून टाकले असेल.';

  @override
  String get errorIllegalTransition =>
      'ट्रिपच्या सध्याच्या स्थितीत हे करता येत नाही. रिफ्रेश करून पुन्हा प्रयत्न करा.';

  @override
  String get errorTripCancelled => 'ही ट्रिप रद्द झाली आहे.';

  @override
  String get errorTripReassigned => 'ही ट्रिप दुसऱ्या ड्रायव्हरला दिली आहे.';

  @override
  String get errorVehicleBusy => 'त्या वेळेत ही गाडी आधीच बुक आहे.';

  @override
  String get errorDriverBusy => 'त्या वेळेत हा ड्रायव्हर आधीच बुक आहे.';

  @override
  String get errorCancellationPending =>
      'रद्द करण्याची एक विनंती आधीच निर्णयाची वाट पाहत आहे.';

  @override
  String get errorAlreadySettled => 'त्या दिवसाचा हिशोब आधीच झाला आहे.';

  @override
  String get errorIdempotencyConflict =>
      'हे आधीच वेगळ्या माहितीसह पाठवले गेले आहे.';

  @override
  String get errorIdempotencyKeyRequired =>
      'विनंती अपूर्ण होती. पुन्हा प्रयत्न करा.';

  @override
  String get errorVersionConflict =>
      'त्याच वेळी दुसऱ्या कोणीतरी हे बदलले. रिफ्रेश करून पुन्हा प्रयत्न करा.';

  @override
  String get errorConflict => 'हे आधीच्या नोंदीशी जुळत नाही.';

  @override
  String get errorFuelTypeMismatch =>
      'हे इंधन गाडीच्या इंधन प्रकाराशी जुळत नाही.';

  @override
  String get errorOdometerBeforeStart =>
      'ओडोमीटर रीडिंग ट्रिप सुरू करतानापेक्षा कमी आहे.';

  @override
  String get errorOtpInvalid =>
      'हा कोड बरोबर नाही. तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get errorOtpExpired => 'कोडची वेळ संपली. नवीन कोड मागवा.';

  @override
  String get errorInvalidCredentials => 'मोबाईल नंबर किंवा पासवर्ड चुकीचा आहे.';

  @override
  String get errorAccountExists =>
      'या नंबरचे खाते आधीच आहे. लॉग इन करा, किंवा पासवर्ड रीसेट करा.';

  @override
  String get errorRateLimited =>
      'खूप जास्त प्रयत्न झाले. काही मिनिटे थांबा आणि पुन्हा प्रयत्न करा.';

  @override
  String get errorUploadNotFound =>
      'फोटो अजून सर्व्हरवर पोहोचला नाही. थोड्या वेळाने पुन्हा प्रयत्न करा.';

  @override
  String get errorUploadMismatch =>
      'अपलोड केलेला फोटो जुळला नाही. पुन्हा काढा.';

  @override
  String get errorUploadFailed =>
      'फोटो अपलोड झाला नाही. पुन्हा प्रयत्न केला जाईल.';

  @override
  String get errorInternal => 'सर्व्हरवर काहीतरी चुकले. पुन्हा प्रयत्न करा.';

  @override
  String get statusCreated => 'दिलेली नाही';

  @override
  String get statusAssigned => 'दिलेली';

  @override
  String get statusStarted => 'रस्त्यावर';

  @override
  String get statusEnded => 'संपली';

  @override
  String get statusSettled => 'हिशोब झाला';

  @override
  String get statusCancelled => 'रद्द';

  @override
  String get myTrips => 'माझ्या ट्रिप';

  @override
  String get newTrip => 'नवीन ट्रिप';

  @override
  String get logFuel => 'इंधन नोंदवा';

  @override
  String get groupOnTheRoad => 'रस्त्यावर';

  @override
  String get groupToday => 'आज';

  @override
  String get groupUpcoming => 'पुढच्या';

  @override
  String get groupRecent => 'अलीकडच्या';

  @override
  String get noTripsYet => 'अजून ट्रिप नाहीत. रिफ्रेश करण्यासाठी खाली ओढा.';

  @override
  String get conflictCancelledShort => 'मालकाने रद्द केली';

  @override
  String get conflictReassignedShort => 'दुसऱ्याला दिली';

  @override
  String get tripNotFoundOnPhone => 'या फोनवर ट्रिप सापडली नाही';

  @override
  String includesKm({required String km}) {
    return '$km km समाविष्ट';
  }

  @override
  String startOdometerKm({required String km}) {
    return 'सुरुवातीचे ओडोमीटर: $km km';
  }

  @override
  String endOdometerKm({required String km}) {
    return 'शेवटचे ओडोमीटर: $km km';
  }

  @override
  String get cancellationRequested => 'रद्द करण्याची विनंती केली';

  @override
  String get cancellationWaiting =>
      'तुमचे मालक मंजूर किंवा नामंजूर करण्याची वाट पाहत आहे.';

  @override
  String get charges => 'खर्च';

  @override
  String get fuel => 'इंधन';

  @override
  String get collected => 'जमा केले';

  @override
  String get startTrip => 'ट्रिप सुरू करा';

  @override
  String get chargeButton => 'खर्च';

  @override
  String get requestCancellation => 'रद्द करण्याची विनंती करा';

  @override
  String get endTrip => 'ट्रिप संपवा';

  @override
  String get conflictCancelledBanner => 'ही ट्रिप मालकाने रद्द केली';

  @override
  String get conflictReassignedBanner =>
      'ही ट्रिप दुसऱ्या ड्रायव्हरला दिली आहे';

  @override
  String get conflictBannerDetail =>
      'यासाठी तुम्ही ऑफलाइन नोंदवलेले काहीही लागू झाले नाही. तुमचे फोटो मात्र मालकाला पाठवले गेले.';

  @override
  String get elapsed => 'झाले';

  @override
  String get kmByGps => 'GPS नुसार km';

  @override
  String get methodCash => 'रोख';

  @override
  String get methodUpi => 'UPI';

  @override
  String get methodCard => 'कार्ड';

  @override
  String get chargeToll => 'टोल';

  @override
  String get chargeParking => 'पार्किंग';

  @override
  String get chargeStateTax => 'राज्य कर';

  @override
  String get chargeDriverAllowance => 'ड्रायव्हर भत्ता';

  @override
  String get chargeNightCharge => 'रात्रीचा चार्ज';

  @override
  String get chargeExtraKm => 'जास्तीचे km';

  @override
  String get chargeOther => 'इतर';

  @override
  String get chargeNoteExtraFare => 'जास्तीचे भाडे · ग्राहक भरतो';

  @override
  String get chargeNotePaidByYou => 'तुम्ही भरले · हिशोबात परत मिळेल';

  @override
  String get chargeNoteBilled => 'ग्राहकाच्या बिलात';

  @override
  String get fuelPetrol => 'पेट्रोल';

  @override
  String get fuelDiesel => 'डिझेल';

  @override
  String get fuelCng => 'CNG';

  @override
  String get fuelEv => 'EV';

  @override
  String get evNoFuel => 'इलेक्ट्रिक गाड्यांना इंधन भरणे किंवा इंधन ऑडिट नसते.';

  @override
  String get fuelPetrolCng => 'पेट्रोल + CNG';

  @override
  String get paidByChoiceMe => 'मी (रोख)';

  @override
  String get paidByOwner => 'मालक';

  @override
  String get paidByFuelCard => 'फ्युएल कार्ड';

  @override
  String get paidByLabelYou => 'तुम्ही भरले';

  @override
  String get paidByLabelOwner => 'मालकाने भरले';

  @override
  String get paidByLabelDriverCash => 'ड्रायव्हरने रोख भरले';

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
    return '$label · फुल टाकी';
  }

  @override
  String get addCharge => 'खर्च जोडा';

  @override
  String get chargeType => 'प्रकार';

  @override
  String get amount => 'रक्कम';

  @override
  String get extraFareTitle => 'ग्राहकाच्या भाड्यात जोडले';

  @override
  String get extraFareSubtitle => 'भाड्यासोबत ग्राहकाकडून घ्या.';

  @override
  String get iPaidThis => 'हे मी भरले';

  @override
  String get paidBackInSettlement => 'तुमच्या हिशोबात तुम्हाला परत मिळेल';

  @override
  String get receiptPhotoOptional => 'पावतीचा फोटो (ऐच्छिक)';

  @override
  String get odometerPhoto => 'ओडोमीटरचा फोटो';

  @override
  String get takeOdometerPhoto => 'ओडोमीटरचा फोटो काढा';

  @override
  String get odometerReading => 'ओडोमीटर रीडिंग';

  @override
  String get typeExactly => 'जसे दिसते तसेच टाका';

  @override
  String startedAtKm({required String km}) {
    return '$km km वर सुरू झाली';
  }

  @override
  String kmOverIncluded({required String over, required String included}) {
    return 'भाड्यात समाविष्ट $included km पेक्षा $over km जास्त. खाली जास्तीच्या km चा चार्ज जोडा.';
  }

  @override
  String get chargesYouPaidOrAdded => 'तुम्ही भरलेले किंवा जोडलेले खर्च';

  @override
  String addedDuringTrip({required String note}) {
    return 'ट्रिपमध्ये जोडले · $note';
  }

  @override
  String get extraFare => 'जास्तीचे भाडे';

  @override
  String get iPaid => 'मी भरले';

  @override
  String get addChargeRow => 'टोल, रात्रीचा चार्ज, जास्तीचे km जोडा…';

  @override
  String get fuelFilledOnTrip => 'या ट्रिपमध्ये भरलेले इंधन';

  @override
  String fuelPaidByYouNote({required String amount}) {
    return 'तुम्ही भरलेले $amount चे इंधन तुमच्या हिशोबात परत मिळेल; ग्राहक त्याचे पैसे देत नाही.';
  }

  @override
  String customerPaidExpected({required String amount}) {
    return 'ग्राहकाने भरले · अपेक्षित $amount';
  }

  @override
  String fareBreakdownFare({required String amount}) {
    return 'भाडे $amount';
  }

  @override
  String fareBreakdownExtra({required String amount}) {
    return 'जास्तीचे भाडे $amount';
  }

  @override
  String fareBreakdownExpenses({required String amount}) {
    return 'टोल व खर्च $amount';
  }

  @override
  String alreadyRecorded({required String amount}) {
    return 'ट्रिपमध्ये $amount आधीच नोंदवले';
  }

  @override
  String get splitPayment => 'पेमेंट विभागा';

  @override
  String get cancelRequestIntro =>
      'तुमचे मालक हे मंजूर किंवा नामंजूर करतील. तोपर्यंत ट्रिप चालू राहील.';

  @override
  String get reason => 'कारण';

  @override
  String get reasonHint => 'उदा. ग्राहक लोणावळ्याला उतरला';

  @override
  String get reasonRequired => 'मालकाला कारण सांगा';

  @override
  String get sendRequest => 'विनंती पाठवा';

  @override
  String get tripTypeOneWay => 'एकेरी';

  @override
  String get tripTypeRoundTrip => 'येऊन-जाऊन';

  @override
  String get tripTypeLocal => 'लोकल';

  @override
  String hours({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count तास',
      one: '1 तास',
    );
    return '$_temp0';
  }

  @override
  String get pickup => 'पिकअप';

  @override
  String get enterPickup => 'पिकअप टाका';

  @override
  String get drop => 'ड्रॉप';

  @override
  String get enterDrop => 'ड्रॉप टाका';

  @override
  String get starts => 'सुरुवात';

  @override
  String get expectedDuration => 'अंदाजे वेळ';

  @override
  String get vehicle => 'गाडी';

  @override
  String get fare => 'भाडे';

  @override
  String get includedKm => 'समाविष्ट km';

  @override
  String get includedKmInvalid => 'km टाका, किंवा रिकामे ठेवा';

  @override
  String get customerNameOptional => 'ग्राहकाचे नाव (ऐच्छिक)';

  @override
  String get customerMobileOptional => 'ग्राहकाचा मोबाईल (ऐच्छिक)';

  @override
  String get editTrip => 'ट्रिप बदला';

  @override
  String get createTrip => 'ट्रिप तयार करा';

  @override
  String get newTripFootnote =>
      'ही ट्रिप तुम्हाला दिली आहे. तुमचा फोन ऑनलाइन झाल्यावर फ्लीट मालकाला ती दिसेल.';

  @override
  String get fuelSaved => 'इंधनाची नोंद सेव्ह झाली; ती आपोआप सिंक होईल';

  @override
  String get noVehicleAssigned =>
      'सध्या तुम्हाला कोणतीही गाडी दिलेली नाही. तुमच्या ट्रिपच्या गाडीसाठी इंधन नोंदवता येते; फ्लीट मालकाला गाडी द्यायला सांगा.';

  @override
  String get vehicleNotDownloaded =>
      'या गाडीची माहिती अजून डाउनलोड झाली नाही. एकदा इंटरनेटला जोडा आणि पुन्हा प्रयत्न करा.';

  @override
  String get vehicleOnThisTrip => 'या ट्रिपची गाडी';

  @override
  String fromYourTrip({required String route}) {
    return 'तुमच्या ट्रिपमधून: $route';
  }

  @override
  String get vehiclesOnYourTrips => 'तुमच्या ट्रिपच्या गाड्या';

  @override
  String fuelKind({required String fuel}) {
    return 'इंधन: $fuel';
  }

  @override
  String get receiptPhoto => 'पावतीचा फोटो';

  @override
  String get takeReceiptPhoto => 'पावतीचा फोटो काढा';

  @override
  String get quantity => 'प्रमाण';

  @override
  String enterQuantity({required String unit}) {
    return 'भरलेले $unit टाका';
  }

  @override
  String get fullTank => 'फुल टाकी';

  @override
  String get fullTankHint => 'टाकी पूर्ण भरली असेल तर चालू करा';

  @override
  String get whoPaid => 'कोणी भरले?';

  @override
  String get saveFuelFill => 'इंधनाची नोंद सेव्ह करा';

  @override
  String get syncStatus => 'सिंक स्थिती';

  @override
  String get syncOffline => 'ऑफलाइन';

  @override
  String syncOfflineSaved({required int count}) {
    return 'ऑफलाइन · फोनवर $count सेव्ह';
  }

  @override
  String syncPending({required int count}) {
    return '$count बाकी';
  }

  @override
  String get synced => 'सिंक झाले';

  @override
  String needAttention({required int count}) {
    return '$count कडे लक्ष द्या';
  }

  @override
  String get attentionTitle => 'हे पाठवता आले नाहीत';

  @override
  String get attentionSubtitle =>
      'सर्व्हरने ते नाकारले. मालकाला विचारा, किंवा पुन्हा प्रयत्न करा.';

  @override
  String get retryAll => 'सगळे पुन्हा प्रयत्न करा';

  @override
  String get outboxMedia => 'फोटो';

  @override
  String get outboxTripCommand => 'ट्रिप अपडेट';

  @override
  String get outboxTripCreate => 'नवीन ट्रिप';

  @override
  String get outboxTripCharge => 'खर्च';

  @override
  String get outboxTripCollection => 'पेमेंट';

  @override
  String get outboxFuelFill => 'इंधन भरणे';

  @override
  String get noPhotoYet => 'अजून फोटो नाही';

  @override
  String get photoTaken => 'फोटो काढला';

  @override
  String get takePhoto => 'फोटो काढा';

  @override
  String get retake => 'पुन्हा काढा';

  @override
  String get enterOdometerKm => 'ओडोमीटर रीडिंग km मध्ये टाका';

  @override
  String mustBeAtLeastKm({required String km}) {
    return 'किमान $km km असावे';
  }

  @override
  String get enterAmount => 'रक्कम ₹ मध्ये टाका';

  @override
  String get amountMoreThanZero => 'रक्कम ₹0 पेक्षा जास्त असावी';

  @override
  String get enterFare => 'भाडे ₹ मध्ये टाका';

  @override
  String get consentTitle => 'ट्रिपदरम्यान लोकेशन';

  @override
  String get consentWhen =>
      'फ्लीट सारथी तुमच्या फोनचे लोकेशन फक्त ट्रिप चालू असतानाच (\"ट्रिप सुरू करा\" आणि \"ट्रिप संपवा\" यांच्या दरम्यान) नोंदवते. नोंद चालू असेपर्यंत पूर्ण वेळ एक नोटिफिकेशन दिसते.';

  @override
  String get consentWhy =>
      'तुमचे फ्लीट मालक त्याचा वापर रूट पाहण्यासाठी आणि अंतर ओडोमीटरशी तपासण्यासाठी करतात. ते ओडोमीटर आणि पावतीच्या फोटोंनाही जोडले जाते. तुम्ही ड्युटीवर नसताना ते घेतले जात नाही.';

  @override
  String get consentRetention =>
      'रूटची माहिती 12 महिन्यांपर्यंत ठेवली जाते आणि नंतर हटवली जाते.';

  @override
  String get consentContinue => 'समजले, पुढे चला';

  @override
  String cameraUnavailable({required String error}) {
    return 'कॅमेरा उपलब्ध नाही: $error';
  }

  @override
  String couldNotTakePhoto({required String error}) {
    return 'फोटो काढता आला नाही: $error';
  }

  @override
  String get fitOdometer => 'पूर्ण ओडोमीटर फ्रेममध्ये येऊ द्या';

  @override
  String get fitReceipt => 'पूर्ण पावती फ्रेममध्ये येऊ द्या';

  @override
  String get fitDocument => 'पूर्ण कागदपत्र फ्रेममध्ये येऊ द्या';

  @override
  String get documentPhoto => 'कागदपत्राचा फोटो';

  @override
  String get gpsNotificationTitle => 'ट्रिप चालू आहे';

  @override
  String get gpsNotificationText =>
      'फ्लीट सारथी या ट्रिपचा तुमचा रूट नोंदवत आहे.';

  @override
  String get rejectEndBeforeStart => 'ट्रिप सुरू झाल्यानंतरच संपली पाहिजे';

  @override
  String get rejectNeedDrop => 'ट्रिप कुठे जाते ते टाका';

  @override
  String rejectEndBelowStart({required String km}) {
    return 'शेवटचे रीडिंग किमान $km km असावे';
  }

  @override
  String get rejectChargesActiveOnly =>
      'खर्च फक्त चालू ट्रिपमध्येच जोडता येतात';

  @override
  String get rejectPaymentsAfterStart =>
      'ट्रिप सुरू झाल्यावरच पेमेंट नोंदवता येते';

  @override
  String get rejectTripCancelled => 'ही ट्रिप रद्द झाली आहे';

  @override
  String get rejectCancellationPending =>
      'या ट्रिपसाठी रद्द करण्याची विनंती आधीच बाकी आहे';

  @override
  String get rejectNoPendingCancellation =>
      'रद्द करण्याची कोणतीही विनंती बाकी नाही';

  @override
  String rejectAnotherTripRunning({required String route}) {
    return 'दुसरी सुरू करण्याआधी तुमची $route ट्रिप संपवा';
  }

  @override
  String get errorDriverOnTrip =>
      'ड्रायव्हरची एक ट्रिप आधीच रस्त्यावर आहे. दुसरी सुरू करण्याआधी ती संपवा.';

  @override
  String get errorVehicleOnTrip =>
      'ही गाडी आधीच दुसऱ्या ट्रिपवर रस्त्यावर आहे. आधी ती ट्रिप संपवा.';

  @override
  String get rejectNotAllowed => 'या ट्रिपवर तुम्ही हे करू शकत नाही';

  @override
  String rejectWrongState({required String status}) {
    return 'ट्रिप $status असताना हे करता येत नाही';
  }

  @override
  String get navDashboard => 'डॅशबोर्ड';

  @override
  String get navTrips => 'ट्रिप';

  @override
  String get navAlerts => 'अलर्ट';

  @override
  String get navMore => 'अधिक';

  @override
  String get vehicles => 'गाड्या';

  @override
  String get drivers => 'ड्रायव्हर';

  @override
  String get members => 'सदस्य';

  @override
  String get documents => 'कागदपत्रे';

  @override
  String get review => 'तपासणी';

  @override
  String get settlements => 'हिशोब';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get loadFailed => 'हे लोड करता आले नाही.';

  @override
  String get edit => 'बदला';

  @override
  String get all => 'सगळे';

  @override
  String get unassigned => 'दिलेले नाही';

  @override
  String get required => 'आवश्यक';

  @override
  String get roleOwner => 'मालक';

  @override
  String get roleManager => 'मॅनेजर';

  @override
  String get roleDriver => 'ड्रायव्हर';

  @override
  String get ownerOnly => 'फक्त मालकच हे बदलू शकतो.';

  @override
  String get severityCritical => 'गंभीर';

  @override
  String get severityWarning => 'इशारा';

  @override
  String get severityInfo => 'माहिती';

  @override
  String get seeAll => 'सगळे पहा';

  @override
  String get pickDate => 'तारीख निवडा';

  @override
  String get status => 'स्थिती';

  @override
  String get name => 'नाव';

  @override
  String get note => 'टीप';

  @override
  String get total => 'एकूण';

  @override
  String get active => 'सक्रिय';

  @override
  String get inactive => 'निष्क्रिय';

  @override
  String percentValue({required String value}) {
    return '$value%';
  }

  @override
  String minutesShort({required int count}) {
    return '$count मिनिटे';
  }

  @override
  String listAnd({required String first, required String last}) {
    return '$first आणि $last';
  }

  @override
  String get todaysTrips => 'आजच्या ट्रिप';

  @override
  String get noTripsToday => 'आज कोणतीही ट्रिप नाही';

  @override
  String get needsAttention => 'तुमचे लक्ष हवे';

  @override
  String get criticalAlerts => 'गंभीर अलर्ट';

  @override
  String get openAlerts => 'उघडे अलर्ट';

  @override
  String get toReview => 'तपासायचे';

  @override
  String get documentsDueSoon => 'लवकर संपणारी कागदपत्रे';

  @override
  String get nothingExpiring => 'पुढच्या 30 दिवसांत काहीही संपत नाही';

  @override
  String get noOpenAlerts => 'उघडे अलर्ट नाहीत';

  @override
  String get allStatuses => 'सगळ्या स्थिती';

  @override
  String get anyDate => 'कोणतीही तारीख';

  @override
  String get allDrivers => 'सगळे ड्रायव्हर';

  @override
  String get allVehicles => 'सगळ्या गाड्या';

  @override
  String get noTripsMatch => 'या फिल्टरनुसार कोणतीही ट्रिप नाही';

  @override
  String localTrip({required String from}) {
    return '$from (लोकल)';
  }

  @override
  String get tripType => 'ट्रिपचा प्रकार';

  @override
  String get quotedFare => 'सांगितलेले भाडे';

  @override
  String get includedKmHint => 'भाड्यात येणारे km, उदा. 300 km पॅकेजसाठी 300';

  @override
  String get customerName => 'ग्राहकाचे नाव';

  @override
  String get customerMobile => 'ग्राहकाचा मोबाईल';

  @override
  String get ends => 'शेवट';

  @override
  String get vehicleOptional => 'गाडी (ऐच्छिक)';

  @override
  String get driverOptional => 'ड्रायव्हर (ऐच्छिक)';

  @override
  String get assignLater => 'नंतर द्या';

  @override
  String get pickBothOrNeither =>
      'गाडी आणि ड्रायव्हर दोन्ही निवडा, किंवा एकही नाही';

  @override
  String get tripDetails => 'ट्रिप';

  @override
  String get customer => 'ग्राहक';

  @override
  String get driver => 'ड्रायव्हर';

  @override
  String get startedAt => 'सुरू झाली';

  @override
  String get endedAt => 'संपली';

  @override
  String get cancelledAt => 'रद्द झाली';

  @override
  String get odometerDistance => 'ओडोमीटर अंतर';

  @override
  String kmOverDriven({required String over, required String driven}) {
    return '$over km जास्त ($driven km चालवली)';
  }

  @override
  String drivenKm({required String km}) {
    return '$km km चालवली';
  }

  @override
  String get cancellationFare => 'रद्द करण्याचे भाडे';

  @override
  String get assign => 'सोपवा';

  @override
  String get reassign => 'पुन्हा सोपवा';

  @override
  String get unassign => 'सोपवणे रद्द करा';

  @override
  String get cancelTrip => 'ट्रिप रद्द करा';

  @override
  String get cancelTripTitle => 'ही ट्रिप रद्द करा';

  @override
  String get assignTripTitle => 'ट्रिप सोपवा';

  @override
  String get reassignTripTitle => 'ट्रिप पुन्हा सोपवा';

  @override
  String get overlapNote =>
      'त्याच वेळेसाठी आधीच बुक असलेली गाडी किंवा ड्रायव्हर सोपवता येत नाही.';

  @override
  String get cancellationRequestTitle => 'रद्द करण्याची विनंती';

  @override
  String requestedBy({required String role, required String when}) {
    return '$role ने $when ला विनंती केली';
  }

  @override
  String odometerAtKm({required String km}) {
    return 'ओडोमीटर $km';
  }

  @override
  String decisionNote({required String note}) {
    return 'निर्णयाची नोंद: $note';
  }

  @override
  String get approveCancellation => 'रद्द करण्यास मंजुरी द्या';

  @override
  String get reject => 'नाकारा';

  @override
  String get approve => 'मंजूर करा';

  @override
  String get approveIntro =>
      'ट्रिप रद्द होईल. आधीच चालवलेल्या अंतराचे पैसे तुम्ही घेऊ शकता.';

  @override
  String get cancellationFareHint => 'शुल्क नसेल तर 0';

  @override
  String get rejectTitle => 'रद्द करणे नाकारा';

  @override
  String get noteForDriver => 'ड्रायव्हरसाठी नोंद';

  @override
  String get rejectConfirm => 'नाकारा — ट्रिप सुरू राहील';

  @override
  String get requestPending => 'बाकी';

  @override
  String get requestApproved => 'मंजूर';

  @override
  String get requestRejected => 'नाकारली';

  @override
  String get requestWithdrawn => 'मागे घेतली';

  @override
  String get odometerEvidence => 'ओडोमीटरचा पुरावा';

  @override
  String get startLabel => 'सुरुवात';

  @override
  String get endLabel => 'शेवट';

  @override
  String get notRecordedYet => 'अजून नोंद नाही';

  @override
  String get typed => 'टाइप केलेले';

  @override
  String get readFromPhoto => 'फोटोवरून वाचलेले';

  @override
  String get differsSentToReview => 'फरक आहे: तपासणीसाठी पाठवले';

  @override
  String capturedAt({required String when}) {
    return '$when ला घेतले';
  }

  @override
  String get photoNotUploaded =>
      'फोटो अजून अपलोड झाला नाही (फोन कदाचित अजून ऑफलाइन आहे).';

  @override
  String get routeTitle => 'मार्ग';

  @override
  String get routeAfterStart => 'ट्रिप सुरू झाल्यावर मार्ग दिसेल';

  @override
  String gpsPointsShown({required int count}) {
    return '$count GPS पॉइंट दाखवले';
  }

  @override
  String pointsRemoved({
    required String inaccurate,
    required String mock,
    required String impossible,
  }) {
    return '$inaccurate चुकीचे, $mock बनावट आणि $impossible अशक्य पॉइंट काढले';
  }

  @override
  String get verdictOkLabel => 'ओडोमीटर GPS शी जुळतो';

  @override
  String get verdictOkText =>
      'ओडोमीटरचे अंतर GPS मार्गाच्या परवानगी असलेल्या फरकात आहे.';

  @override
  String get verdictFlaggedLabel => 'ओडोमीटर GPS पेक्षा जास्त';

  @override
  String get verdictFlaggedText =>
      'ओडोमीटरचे अंतर GPS मार्गापेक्षा खूप जास्त आहे. तपशीलासाठी अलर्ट पहा.';

  @override
  String get verdictInconclusiveLabel => 'ठरवण्यासाठी पुरेसा GPS नाही';

  @override
  String get verdictInconclusiveText =>
      'फोनने ट्रिपचा खूप कमी भाग नोंदवला (बहुतेक बॅटरी-सेव्हिंग सेटिंगमुळे). अशा वेळी अलर्ट येत नाही.';

  @override
  String checkedAt({required String when}) {
    return '$when ला तपासले';
  }

  @override
  String get gps => 'GPS';

  @override
  String get odometer => 'ओडोमीटर';

  @override
  String get gpsCoverage => 'GPS कव्हरेज';

  @override
  String get longestGap => 'सर्वात मोठा खंड';

  @override
  String get distanceCheckPending =>
      'ट्रिप संपल्यावर काही सेकंदांत अंतराची तपासणी होते.';

  @override
  String get noCharges => 'टोल, पार्किंग किंवा इतर शुल्क नाही.';

  @override
  String get addChargeTitle => 'शुल्क जोडा';

  @override
  String get driverPaidCheckbox =>
      'ड्रायव्हरने हे स्वतःच्या खिशातून भरले (सेटलमेंटमध्ये परत मिळेल)';

  @override
  String get extraFareInfo =>
      'जादा भाडे: ठरलेल्या भाड्यावर, ग्राहक देत असलेल्या रकमेत जोडले जाते.';

  @override
  String get driverPaid => 'ड्रायव्हरने भरले';

  @override
  String get billedOnly => 'फक्त बिलात';

  @override
  String byRole({required String text, required String role}) {
    return '$text · $role कडून';
  }

  @override
  String get voidAction => 'रद्द करा';

  @override
  String get paymentsCollected => 'मिळालेले पेमेंट';

  @override
  String get recordPayment => 'पेमेंट नोंदवा';

  @override
  String get nothingRecorded => 'अजून काहीही नोंदवलेले नाही.';

  @override
  String get method => 'पद्धत';

  @override
  String get methodCashOption => 'रोख (ड्रायव्हर सेटलमेंटच्या वेळी देतो)';

  @override
  String get methodUpiOption => 'UPI (थेट तुम्हाला मिळते)';

  @override
  String get methodCardOption => 'कार्ड (थेट तुम्हाला मिळते)';

  @override
  String get referenceOptional => 'रेफरन्स (ऐच्छिक)';

  @override
  String get referenceHint => 'UPI रेफरन्स किंवा कार्ड स्लिप नंबर';

  @override
  String get record => 'नोंदवा';

  @override
  String get timeline => 'टाइमलाइन';

  @override
  String get noEvents => 'कोणत्याही घटना नाहीत';

  @override
  String eventBy({required String event, required String role}) {
    return '$role ने $event';
  }

  @override
  String eventBySystem({required String event}) {
    return '$event (सिस्टम)';
  }

  @override
  String onDevice({required String when}) {
    return 'डिव्हाइसवर $when';
  }

  @override
  String syncedLater({required String when, required int count}) {
    return 'सर्व्हरवर $when ला पोहोचले ($count मिनिटांनी)';
  }

  @override
  String get eventCreated => 'तयार केली';

  @override
  String get eventAssigned => 'सोपवली';

  @override
  String get eventReassigned => 'पुन्हा सोपवली';

  @override
  String get eventUnassigned => 'सोपवणे रद्द केले';

  @override
  String get eventStarted => 'सुरू केली';

  @override
  String get eventEnded => 'संपवली';

  @override
  String get eventCancellationRequested => 'रद्द करण्याची विनंती केली';

  @override
  String get eventCancellationApproved => 'रद्द करण्यास मंजुरी दिली';

  @override
  String get eventCancellationRejected => 'रद्द करणे नाकारले';

  @override
  String get eventCancellationWithdrawn => 'रद्द करण्याची विनंती मागे घेतली';

  @override
  String get eventCancelled => 'रद्द केली';

  @override
  String get eventSettled => 'सेटल केली';

  @override
  String get addVehicle => 'गाडी जोडा';

  @override
  String get editVehicle => 'गाडी बदला';

  @override
  String get registrationNumber => 'नोंदणी क्रमांक';

  @override
  String get registrationInvalid => 'MH 12 AB 1234 सारखा नोंदणी क्रमांक वापरा';

  @override
  String get brand => 'ब्रँड';

  @override
  String get search => 'शोधा';

  @override
  String get othersGroup => 'इतर';

  @override
  String get otherModel => 'इतर / यादीत नाही';

  @override
  String get catalogUnavailable => 'यादी लोड झाली नाही; त्याऐवजी टाइप करा';

  @override
  String get make => 'कंपनी';

  @override
  String get model => 'मॉडेल';

  @override
  String get fuelType => 'इंधनाचा प्रकार';

  @override
  String get year => 'वर्ष';

  @override
  String get currentOdometer => 'सध्याचा ओडोमीटर';

  @override
  String get inactiveVehicleOption => 'निष्क्रिय (सोपवण्यातून लपवलेली)';

  @override
  String get deactivate => 'निष्क्रिय करा';

  @override
  String get activate => 'सक्रिय करा';

  @override
  String get noVehiclesYet =>
      'अजून गाड्या नाहीत. ट्रिप सोपवायला सुरुवात करण्यासाठी तुमची पहिली गाडी जोडा.';

  @override
  String get lastOdometer => 'शेवटचा ओडोमीटर';

  @override
  String get recentTrips => 'अलीकडच्या ट्रिप';

  @override
  String get noTripsShort => 'अजून ट्रिप नाहीत';

  @override
  String get fuelAudit => 'इंधन ऑडिट';

  @override
  String get inviteDriver => 'ड्रायव्हरला आमंत्रित करा';

  @override
  String get inviteDriverIntro =>
      'ड्रायव्हर या नंबरने फ्लीट सारथी ॲपमध्ये साइन इन करतो; पासवर्डची गरज नाही.';

  @override
  String get enterIndianMobile => '10 अंकी भारतीय मोबाइल नंबर टाका';

  @override
  String get sendInvite => 'आमंत्रण पाठवा';

  @override
  String get noDriversYet =>
      'अजून ड्रायव्हर नाहीत. फोनने ड्रायव्हरना आमंत्रित करा; ते त्या नंबरने आणि पासवर्डने साइन अप करतात.';

  @override
  String payDefault({required String rule}) {
    return 'डीफॉल्ट · $rule';
  }

  @override
  String get notSignedInYet => 'अजून साइन इन केलेले नाही';

  @override
  String get inactiveDriverOption => 'निष्क्रिय (सोपवता येत नाही)';

  @override
  String get pay => 'पगार';

  @override
  String get onlyOwnerPay => 'फक्त मालकच पगार बदलू शकतो.';

  @override
  String get payDifferently => 'या ड्रायव्हरला डीफॉल्टपेक्षा वेगळा पगार द्या';

  @override
  String get checkPayRule => 'पगाराच्या नियमाची मूल्ये तपासा';

  @override
  String get payRuleHow => 'ड्रायव्हरला पगार कसा मिळतो';

  @override
  String get payNone => 'काही नाही (पगारी, फ्लीट सारथीबाहेर पगार दिला जातो)';

  @override
  String get payPercent => 'भाड्याची टक्केवारी';

  @override
  String get payPerTrip => 'प्रत्येक ट्रिपला ठरलेली रक्कम';

  @override
  String get payPerKm => 'चालवलेल्या प्रत्येक km ला';

  @override
  String get payFixedDaily => 'कामाच्या प्रत्येक दिवसाला ठरलेली रक्कम';

  @override
  String get percent => 'टक्के';

  @override
  String get ofBase => 'कशाचे';

  @override
  String get baseQuoted => 'ठरलेले भाडे';

  @override
  String get baseExpected => 'शुल्कासह भाडे';

  @override
  String get amountPerTrip => 'प्रत्येक ट्रिपची रक्कम';

  @override
  String get ratePerKm => 'प्रति km दर';

  @override
  String get amountPerDay => 'कामाच्या प्रत्येक दिवसाची रक्कम';

  @override
  String get allowanceToDriver => 'ड्रायव्हर भत्ता ड्रायव्हरला मिळतो';

  @override
  String get allowanceHint =>
      'ग्राहक देत असलेला बाटा ड्रायव्हरच्या कमाईत जोडला जातो.';

  @override
  String get ruleNoPay => 'सेटलमेंटमध्ये पगार नाही';

  @override
  String rulePercentQuoted({required String percent}) {
    return 'ठरलेल्या भाड्याचे $percent%';
  }

  @override
  String rulePercentExpected({required String percent}) {
    return 'शुल्कासह भाड्याचे $percent%';
  }

  @override
  String rulePerTrip({required String amount}) {
    return 'प्रत्येक ट्रिपला $amount';
  }

  @override
  String rulePerKm({required String amount}) {
    return 'प्रति km $amount';
  }

  @override
  String ruleFixedDaily({required String amount}) {
    return 'कामाच्या प्रत्येक दिवसाला $amount';
  }

  @override
  String rulePlusAllowance({required String rule}) {
    return '$rule + ड्रायव्हर भत्ता';
  }

  @override
  String get inviteManager => 'मॅनेजरला आमंत्रित करा';

  @override
  String get inviteManagerIntro =>
      'मॅनेजर ट्रिप, अलर्ट आणि सेटलमेंट सांभाळतात, पण सेटिंग किंवा पगार बदलू शकत नाहीत.';

  @override
  String get removeManager => 'मॅनेजरचा ॲक्सेस काढा';

  @override
  String removeManagerConfirm({required String name}) {
    return '$name यांचा मॅनेजर ॲक्सेस काढायचा? त्यांच्या इतर भूमिका तशाच राहतील.';
  }

  @override
  String get remove => 'काढा';

  @override
  String get memberInvited => 'आमंत्रित';

  @override
  String get memberActive => 'सक्रिय';

  @override
  String get memberSuspended => 'निलंबित';

  @override
  String get membersIntro => 'या फ्लीटचा ॲक्सेस असलेले लोक.';

  @override
  String get addDocument => 'कागदपत्र जोडा';

  @override
  String get renew => 'नूतनीकरण करा';

  @override
  String renewTitle({required String doc}) {
    return '$doc चे नूतनीकरण करा';
  }

  @override
  String get renewIntro =>
      'नवीन प्रत सध्याच्या प्रतीची जागा घेते (जुनी इतिहासात राहते), आणि तिचे मुदत संपण्याचे अलर्ट काढले जातात.';

  @override
  String get documentType => 'कागदपत्र';

  @override
  String get documentFor => 'कोणासाठी';

  @override
  String get documentNumber => 'क्रमांक';

  @override
  String get validFrom => 'पासून वैध';

  @override
  String get expiresOn => 'मुदत संपण्याची तारीख';

  @override
  String get expiresOnHint => 'मुदत संपण्याआधी आणि संपल्यावर अलर्ट येतात.';

  @override
  String get saveRenewal => 'नूतनीकरण सेव्ह करा';

  @override
  String get noDocuments => 'अजून कागदपत्रे नाहीत.';

  @override
  String get docRc => 'नोंदणी (RC)';

  @override
  String get docInsurance => 'विमा';

  @override
  String get docPermit => 'परमिट';

  @override
  String get docPuc => 'प्रदूषण (PUC)';

  @override
  String get docLicence => 'ड्रायव्हिंग लायसन्स';

  @override
  String get docValid => 'वैध';

  @override
  String docExpiresIn({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिवसांत मुदत संपते',
      one: 'उद्या मुदत संपते',
      zero: 'आज मुदत संपते',
    );
    return '$_temp0';
  }

  @override
  String get docExpired => 'मुदत संपली';

  @override
  String get docSuperseded => 'नूतनीकरण झाले';

  @override
  String get filterAllDocs => 'सर्व सध्याची कागदपत्रे';

  @override
  String get filterDue30 => '30 दिवसांत संपणारी किंवा संपलेली';

  @override
  String get filterDue7 => '7 दिवसांत संपणारी किंवा संपलेली';

  @override
  String get filterDue0 => 'संपलेली किंवा आज संपणारी';

  @override
  String get viewPhoto => 'फोटो पहा';

  @override
  String get documentPhotoOptional => 'फोटो (ऐच्छिक)';

  @override
  String get pickVehicleOrDriver => 'कोणासाठी आहे ते निवडा';

  @override
  String get fuelIntro =>
      'प्रत्येक गाडीची तुलना तिच्याच इतिहासाशी, सायकलनुसार (फुल टँक ते फुल टँक) केली जाते.';

  @override
  String get efficiencyByCycle => 'सायकलनुसार इंधन ॲव्हरेज';

  @override
  String get costByCycle => 'सायकलनुसार चालवण्याचा खर्च';

  @override
  String get noCycles =>
      'अजून फुल-टँक सायकल नाहीत. ॲव्हरेज दोन फुल-टँक भरण्यांदरम्यान मोजले जाते.';

  @override
  String get usual => 'नेहमीचे';

  @override
  String usualValue({required String value}) {
    return 'नेहमीचे $value';
  }

  @override
  String get cyclesInBaseline => 'बेसलाइनमधील सायकल';

  @override
  String get verdictOk => 'ठीक';

  @override
  String get verdictFlagged => 'संशयास्पद';

  @override
  String get verdictInvalid => 'अवैध';

  @override
  String get fuelFills => 'इंधन भरणे';

  @override
  String get noFills => 'इंधन भरल्याची नोंद नाही';

  @override
  String get fullTankShort => 'फुल';

  @override
  String get partialTank => 'अर्धवट';

  @override
  String get voidFill => 'भरणे रद्द करा';

  @override
  String get voidFillTitle => 'हे भरणे रद्द करा';

  @override
  String voidFillIntro({
    required String quantity,
    required String amount,
    required String when,
  }) {
    return '$when ला $amount ला $quantity. गाडीचे इंधन ऑडिट याशिवाय पुन्हा मोजले जाईल.';
  }

  @override
  String get voidReasonHint => 'उदा. 40 L ऐवजी 60 L टाइप केले';

  @override
  String get keepIt => 'ठेवा';

  @override
  String receiptAmount({required String amount}) {
    return 'पावती: $amount';
  }

  @override
  String sigmaRule({required String value}) {
    return '$valueσ';
  }

  @override
  String percentRule({required String value}) {
    return '$value% (नवीन गाडी)';
  }

  @override
  String cycleRange({required String from, required String to}) {
    return '$from → $to';
  }

  @override
  String get noCyclesShort => 'सायकल नाहीत';

  @override
  String get chartThisCycle => 'प्रत्येक सायकल';

  @override
  String perKmValue({required String amount}) {
    return '$amount/km';
  }

  @override
  String get allKinds => 'सर्व प्रकार';

  @override
  String get alertOpen => 'उघडा';

  @override
  String get alertAcknowledged => 'पाहिला';

  @override
  String get alertResolved => 'सोडवला';

  @override
  String get alertDismissed => 'फेटाळला';

  @override
  String get acknowledge => 'पाहिले';

  @override
  String get dismiss => 'फेटाळा';

  @override
  String get dismissFalseAlarm => 'खोटा अलार्म म्हणून फेटाळा';

  @override
  String get markResolved => 'सोडवला म्हणून नोंदवा';

  @override
  String get falseAlarm => 'खोटा अलार्म';

  @override
  String get allClear => 'सर्व ठीक: कोणताही उघडा अलर्ट नाही';

  @override
  String get noAlertsMatch => 'जुळणारे अलर्ट नाहीत';

  @override
  String get openTrip => 'ट्रिप उघडा';

  @override
  String get openFuelHistory => 'इंधन इतिहास उघडा';

  @override
  String get openVehicle => 'गाडी उघडा';

  @override
  String get openDocuments => 'कागदपत्रे उघडा';

  @override
  String get alertsIntro =>
      'इंधनाचा अलर्ट खोटा अलार्म म्हणून फेटाळल्यास ती सायकल गाडीच्या सामान्य मर्यादेत धरली जाते.';

  @override
  String get kindFuelEfficiencyLow => 'इंधन नेहमीपेक्षा जास्त लागले';

  @override
  String get kindFuelCostHigh => 'चालवण्याचा खर्च नेहमीपेक्षा जास्त';

  @override
  String get kindOdoGps => 'ओडोमीटर GPS पेक्षा जास्त';

  @override
  String get kindDocExpiring => 'कागदपत्राची मुदत संपत आहे';

  @override
  String get kindDocExpired => 'कागदपत्राची मुदत संपली';

  @override
  String get kindCancellationRequested => 'रद्द करण्याची विनंती';

  @override
  String get kindGpsCoverageLow => 'GPS कव्हरेज कमी';

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
  String get alertFuelDiesel => 'डिझेल';

  @override
  String get alertFuelCng => 'CNG';

  @override
  String get alertFuelPetrolCng => 'पेट्रोल + CNG';

  @override
  String alertFuelEfficiencyTitle({required String vehicle}) {
    return '$vehicle ला नेहमीपेक्षा जास्त इंधन लागले';
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
    return '$from ते $to दरम्यान ती $used $unit $fuel मध्ये $km km चालली, म्हणजे $value km/$unit. ही गाडी साधारण $baseline km/$unit देते, म्हणजे हे नेहमीपेक्षा $worse% वाईट आहे. अपेक्षेपेक्षा अंदाजे $extra $unit (सुमारे $extraCost) जास्त $fuel लागले.';
  }

  @override
  String alertFuelCostTitle({required String vehicle}) {
    return '$vehicle चालवण्याचा खर्च नेहमीपेक्षा जास्त आला';
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
    return '$from ते $to दरम्यान ती $cost च्या इंधनात $km km चालली, म्हणजे $perKm/km. या गाडीचा खर्च साधारण $usualPerKm/km असतो, म्हणजे हे नेहमीपेक्षा $worse% जास्त आहे.';
  }

  @override
  String alertPetrolShare({required String amount}) {
    return 'त्यापैकी $amount पेट्रोल होते.';
  }

  @override
  String alertFillsLoggedBy({required String names}) {
    return 'या काळातील इंधन भरण्याची नोंद $names यांनी केली.';
  }

  @override
  String get alertCheckReceiptsOdometer => 'पावत्या आणि ओडोमीटरचे फोटो तपासा.';

  @override
  String get alertCheckPetrolReceipts =>
      'गाडी विनाकारण पेट्रोलवर चालवली का ते तपासा, आणि पावत्या तपासा.';

  @override
  String alertOdoGpsTitle({
    required String date,
    required String route,
    required String vehicle,
  }) {
    return '$date च्या ट्रिपमध्ये ($route, $vehicle) ओडोमीटरवर GPS मार्गापेक्षा जास्त km दिसतात';
  }

  @override
  String get alertOdoGpsVehicleUnknown => 'गाडी';

  @override
  String alertOdoGpsBody({
    required String odometer,
    required String gps,
    required String excess,
    required String tolerance,
  }) {
    return 'ओडोमीटरनुसार $odometer km आहे, पण फोनच्या GPS ने $gps km नोंदवले. ओडोमीटरचे अंतर $excess% जास्त आहे; परवानगी असलेला फरक $tolerance% आहे. सुरुवातीचे आणि शेवटचे ओडोमीटर फोटो तपासा.';
  }

  @override
  String alertDocExpiredTitle({required String doc, required String subject}) {
    return '$subject च्या $doc ची मुदत संपली आहे';
  }

  @override
  String alertDocExpiredBody({
    required String doc,
    required String subject,
    required String date,
  }) {
    return '$subject च्या $doc ची मुदत $date ला संपली. त्याशिवाय गाडी चालवल्यास दंड होऊ शकतो आणि विम्याचे क्लेम नाकारले जाऊ शकतात. नूतनीकरण करा आणि नवीन प्रत अपलोड करा.';
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
      other: '$subject च्या $doc ची मुदत $count दिवसांत संपते',
      one: '$subject च्या $doc ची मुदत उद्या संपते',
      zero: '$subject च्या $doc ची मुदत आज संपते',
    );
    return '$_temp0';
  }

  @override
  String alertDocExpiringBody({
    required String doc,
    required String subject,
    required String date,
  }) {
    return '$subject च्या $doc ची मुदत $date ला संपते. त्याआधी नूतनीकरण करा आणि नवीन प्रत अपलोड करा.';
  }

  @override
  String alertCancellationTitle({required String from}) {
    return '$from पासूनची ट्रिप रद्द करण्याची विनंती';
  }

  @override
  String alertCancellationBody({
    required String driver,
    required String reason,
    required String km,
  }) {
    return '$driver यांनी ही चालू ट्रिप रद्द करायला सांगितले: \"$reason\". ओडोमीटरवर $km km होते. ट्रिप पेजवर मंजूर करा (हवे तर रद्द करण्याच्या भाड्यासह) किंवा नाकारा.';
  }

  @override
  String get alertTheDriver => 'ड्रायव्हर';

  @override
  String get reviewIntro =>
      'ज्या गोष्टींबद्दल फ्लीट सारथीला खात्री नाही. यामुळे ड्रायव्हरचे काम थांबले नाही; तुमचा निर्णय नोंद दुरुस्त करतो.';

  @override
  String get nothingToReview => 'तपासण्यासारखे काही नाही';

  @override
  String get noItems => 'काहीही नाही';

  @override
  String get reviewOcrOdometer =>
      'ओडोमीटरचा फोटो टाइप केलेल्या रीडिंगशी जुळत नाही';

  @override
  String get reviewOcrReceipt => 'पावती टाइप केलेल्या रकमेशी जुळत नाही';

  @override
  String get reviewOdometerRegression => 'ओडोमीटर मागे गेला';

  @override
  String get reviewImplausibleEfficiency => 'इंधनाचे आकडे पटण्यासारखे नाहीत';

  @override
  String get reviewMockLocation => 'बनावट GPS लोकेशन आढळले';

  @override
  String get reviewOrphanEvidence => 'रद्द झालेल्या ट्रिपचा फोटो';

  @override
  String get reviewClockSkew => 'फोनचे घड्याळ चुकीचे होते';

  @override
  String get reviewUploadMismatch => 'अपलोड केलेली फाइल जुळली नाही';

  @override
  String get reviewKeptTyped => 'टाइप केलेले मूल्य ठेवले';

  @override
  String get reviewUsedPhoto => 'फोटोतील मूल्य वापरले';

  @override
  String get reviewCorrected => 'दुरुस्त केले';

  @override
  String get typedByDriver => 'ड्रायव्हरने टाइप केलेले';

  @override
  String get readFromThePhoto => 'फोटोवरून वाचलेले';

  @override
  String get keepTyped => 'टाइप केलेले मूल्य ठेवा';

  @override
  String get usePhotoValue => 'फोटोतील मूल्य वापरा';

  @override
  String get enterCorrectValue => 'योग्य मूल्य टाका';

  @override
  String get markReviewed => 'तपासले म्हणून नोंदवा';

  @override
  String get correctValueTitle => 'योग्य मूल्य टाका';

  @override
  String get odometerKmLabel => 'ओडोमीटर (km)';

  @override
  String get correctionHint =>
      'या मूल्याने इंधन आणि अंतराच्या तपासण्या पुन्हा मोजल्या जातात.';

  @override
  String get saveCorrection => 'दुरुस्ती सेव्ह करा';

  @override
  String get reasonOdometerNotIncreasing =>
      'शेवटच्या भरण्याच्या वेळचे ओडोमीटर रीडिंग सुरुवातीच्या भरण्यापेक्षा जास्त नाही.';

  @override
  String get reasonDistanceTooLong =>
      'दोन फुल-टँक भरण्यांदरम्यान 3,000 km पेक्षा जास्त अंतर झाले, म्हणजे काही भरण्यांची नोंद बहुधा झाली नाही.';

  @override
  String get reasonImplausiblyGood =>
      'ॲव्हरेज ही गाडी नेहमी देते त्यापेक्षा खूपच चांगले आहे, याचा अर्थ बहुधा एखाद्या भरण्याची नोंद झाली नाही.';

  @override
  String get reasonNoFuel =>
      'दोन फुल-टँक भरण्यांदरम्यान कोणत्याही इंधनाची नोंद नाही.';

  @override
  String get settlementsIntro =>
      'दिवसासाठी (IST) प्रत्येक ड्रायव्हरची एक ओळ. ट्रिप आणि पेमेंट सिंक होताना ड्राफ्ट अपडेट होतात.';

  @override
  String noActivity({required String date}) {
    return '$date ला ड्रायव्हरची कोणतीही हालचाल नाही';
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
  String get expected => 'अपेक्षित';

  @override
  String get online => 'ऑनलाइन';

  @override
  String get expenses => 'खर्च';

  @override
  String get earnings => 'कमाई';

  @override
  String get lateItems => 'उशिरा आलेल्या नोंदी';

  @override
  String get net => 'निव्वळ';

  @override
  String get draft => 'ड्राफ्ट';

  @override
  String shortfall({required String amount}) {
    return 'कमी $amount';
  }

  @override
  String get expectedFare => 'अपेक्षित भाडे';

  @override
  String get cashCollected => 'मिळालेली रोकड';

  @override
  String get onlineToYou => 'ऑनलाइन (तुम्हाला)';

  @override
  String get driversExpenses => 'ड्रायव्हरचा खर्च';

  @override
  String get driversEarnings => 'ड्रायव्हरची कमाई';

  @override
  String get shortfallLabel => 'कमी';

  @override
  String get shortfallHint => 'अपेक्षित भाड्यातून मिळालेली सर्व रक्कम वजा';

  @override
  String get settlementLabel => 'हिशोब';

  @override
  String get netFormula =>
      'निव्वळ = मिळालेली रोकड − ड्रायव्हरने भरलेला खर्च − ड्रायव्हरची कमाई ± आधीच हिशोब झालेल्या दिवसांच्या उशिरा आलेल्या नोंदी.';

  @override
  String driverPaysYou({required String amount}) {
    return 'ड्रायव्हर तुम्हाला $amount देईल';
  }

  @override
  String youPayDriver({required String amount}) {
    return 'तुम्ही ड्रायव्हरला $amount द्या';
  }

  @override
  String get nothingToHandOver => 'देण्यासारखे काही नाही';

  @override
  String settledOn({required String when}) {
    return '$when हिशोब झाला. नंतरचे बदल पुढच्या दिवसात जातील.';
  }

  @override
  String get markSettledHint =>
      'रोकड मिळाल्यावर हिशोब झाला म्हणून नोंदवा. यामुळे दिवस लॉक होईल.';

  @override
  String get markSettled => 'हिशोब झाला';

  @override
  String lateFrom({required String date}) {
    return '$date चे, त्या दिवसाचा हिशोब झाल्यानंतर सिंक झाले';
  }

  @override
  String get lineTrip => 'ट्रिप';

  @override
  String get lineCharge => 'शुल्क';

  @override
  String get linePayment => 'पेमेंट';

  @override
  String get lineFuel => 'इंधन';

  @override
  String get lineAdjustment => 'उशिरा आलेली नोंद';

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
    return '$kind, ड्रायव्हरने भरले';
  }

  @override
  String itemChargeBilled({required String kind}) {
    return '$kind, ग्राहकाच्या बिलात';
  }

  @override
  String itemChargeExtraFare({required String kind}) {
    return '$kind, जादा भाडे';
  }

  @override
  String itemOnTrip({required String text, required String route}) {
    return '$text · $route';
  }

  @override
  String itemPayment({required String method}) {
    return '$method पेमेंट';
  }

  @override
  String itemReference({required String text, required String reference}) {
    return '$text (संदर्भ $reference)';
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
  String get auditThresholds => 'ऑडिट मर्यादा';

  @override
  String get fuelKSigma => 'इंधन अलर्ट संवेदनशीलता (k σ)';

  @override
  String get fuelKSigmaHint =>
      'नेहमीपेक्षा इतक्या standard deviation ने खराब सायकल असल्यास अलर्ट द्या. कमी = जास्त अलर्ट.';

  @override
  String get fuelMinCycles => 'σ वापरण्यापूर्वीच्या सायकल';

  @override
  String get fuelMinCyclesHint =>
      'नवीन गाड्यांच्या इतक्या सामान्य सायकल होईपर्यंत टक्केवारी नियम वापरला जातो.';

  @override
  String get fuelPct => 'नवीन गाडीची मर्यादा (%)';

  @override
  String get fuelPctHint =>
      'नवीन गाड्यांसाठी, सायकल नेहमीच्या आकड्यापेक्षा इतकी खराब असल्यास अलर्ट द्या.';

  @override
  String get fuelAlpha => 'बेसलाइन प्रतिसाद (α)';

  @override
  String get fuelAlphaHint =>
      'नेहमीचा आकडा अलीकडच्या सायकलनुसार किती लवकर बदलतो (0.05–0.9).';

  @override
  String get odoTolerance => 'ओडोमीटर विरुद्ध GPS फरक मर्यादा (%)';

  @override
  String get odoToleranceHint =>
      'ज्या ट्रिपचे ओडोमीटर अंतर GPS मार्गापेक्षा इतक्यापेक्षा जास्त आहे त्यांना अलर्ट द्या.';

  @override
  String get docAlertDays => 'कागदपत्र अलर्ट दिवस';

  @override
  String get docAlertDaysHint =>
      'स्वल्पविरामाने वेगळे करा, उदा. 30, 7, 1. मुदत संपल्यावरही अलर्ट येतो.';

  @override
  String get checkThresholds =>
      'आकडे तपासा: काही परवानगी असलेल्या मर्यादेबाहेर आहेत.';

  @override
  String get savedThresholds =>
      'सेव्ह झाले. पुढच्या मोजणीपासून इंधन ऑडिट नवीन मर्यादा वापरेल.';

  @override
  String get saveThresholds => 'मर्यादा सेव्ह करा';

  @override
  String get defaultDriverPay => 'ड्रायव्हरचा डीफॉल्ट पगार';

  @override
  String get defaultPayIntro =>
      'ज्या ड्रायव्हरचा स्वतःचा पगार नियम नाही, त्या सर्वांच्या हिशोबात हे वापरले जाते.';

  @override
  String get savedPay => 'सेव्ह झाले. आधीच हिशोब झालेले दिवस बदलत नाहीत.';

  @override
  String get saveDefaultPay => 'डीफॉल्ट पगार सेव्ह करा';

  @override
  String get settingsOwnerOnly => 'फक्त मालकच सेटिंग्ज बदलू शकतो.';

  @override
  String signedInAs({required String name, required String roles}) {
    return '$name · $roles';
  }

  @override
  String get password => 'पासवर्ड';

  @override
  String get logIn => 'लॉग इन करा';

  @override
  String get forgotPassword => 'पासवर्ड विसरलात?';

  @override
  String get newHereSignUp => 'फ्लीट सारथीवर नवीन आहात? साइन अप करा';

  @override
  String get haveAccountLogIn => 'आधीच अकाउंट आहे? लॉग इन करा';

  @override
  String get backToLogIn => 'लॉग इनवर परत जा';

  @override
  String get signUpTitle => 'तुमचे अकाउंट तयार करा';

  @override
  String get signUpIntro =>
      'तुमच्या मोबाइल नंबरसाठी पासवर्ड निवडा. ड्रायव्हरनी फ्लीट मालकाने नोंदवलेला नंबर वापरावा.';

  @override
  String get createAccount => 'अकाउंट तयार करा';

  @override
  String get yourNameOptional => 'तुमचे नाव (ऐच्छिक)';

  @override
  String get newPassword => 'नवीन पासवर्ड';

  @override
  String get confirmPassword => 'पासवर्ड पुन्हा टाका';

  @override
  String get currentPassword => 'सध्याचा पासवर्ड';

  @override
  String get passwordHint => 'किमान 8 अक्षरे';

  @override
  String get enterPassword => 'तुमचा पासवर्ड टाका';

  @override
  String get passwordTooShort => 'किमान 8 अक्षरे वापरा.';

  @override
  String get passwordTooLong => 'जास्तीत जास्त 128 अक्षरे वापरा.';

  @override
  String get passwordsDontMatch => 'दोन्ही पासवर्ड जुळत नाहीत.';

  @override
  String get showPassword => 'पासवर्ड दाखवा';

  @override
  String get hidePassword => 'पासवर्ड लपवा';

  @override
  String get resetPasswordTitle => 'तुमचा पासवर्ड रीसेट करा';

  @override
  String get resetPasswordIntro =>
      'आम्ही तुमच्या मोबाइल नंबरवर रीसेट कोड पाठवू. मग नवीन पासवर्ड निवडा.';

  @override
  String get resetPassword => 'पासवर्ड रीसेट करा';

  @override
  String get saveAndLogIn => 'पासवर्ड सेव्ह करा आणि लॉग इन करा';

  @override
  String get resendCode => 'कोड पुन्हा पाठवा';

  @override
  String resendCodeIn({required String seconds}) {
    return '$seconds s मध्ये कोड पुन्हा पाठवा';
  }

  @override
  String get codeResent => 'आम्ही नवीन कोड पाठवला आहे.';

  @override
  String get resetCodeInApiLog =>
      'लोकल किंवा डेमोवर टेस्ट करत आहात? कोड SMS ने येत नाही: तो API सर्व्हरच्या लॉगमध्ये दिसतो.';

  @override
  String get accountSecurity => 'अकाउंट सुरक्षा';

  @override
  String get signInMethods => 'तुम्ही कसे साइन इन करता';

  @override
  String get passwordIsSet => 'सेट आहे';

  @override
  String get passwordNotSet => 'अजून सेट नाही';

  @override
  String get setPassword => 'पासवर्ड सेट करा';

  @override
  String get setPasswordIntro =>
      'मग तुम्ही मोबाइल नंबर आणि पासवर्डने लॉग इन करू शकता.';

  @override
  String get changePassword => 'पासवर्ड बदला';

  @override
  String get savePassword => 'पासवर्ड सेव्ह करा';

  @override
  String get passwordSaved => 'पासवर्ड सेव्ह झाला';

  @override
  String get currentPasswordWrong => 'तुमचा सध्याचा पासवर्ड चुकीचा आहे.';

  @override
  String get editDrivers => 'ड्रायव्हर बदला';

  @override
  String get editVehicles => 'गाड्या बदला';

  @override
  String get noLinkedDrivers =>
      'अजून कोणताही ड्रायव्हर जोडलेला नाही. या गाडीची ट्रिप फक्त जोडलेल्या ड्रायव्हरला देता येते.';

  @override
  String get noLinkedVehicles =>
      'अजून कोणतीही गाडी जोडलेली नाही. या ड्रायव्हरला फक्त जोडलेल्या गाडीची ट्रिप मिळू शकते.';

  @override
  String editDriversIntro({required String vehicle}) {
    return '$vehicle कोण चालवू शकतो? ट्रिपमध्ये ही गाडी फक्त या ड्रायव्हरसोबत जोडता येते.';
  }

  @override
  String editVehiclesIntro({required String name}) {
    return '$name कोणत्या गाड्या चालवू शकतो? त्यांना फक्त याच गाड्यांच्या ट्रिप मिळतील.';
  }

  @override
  String get driversOptional => 'ड्रायव्हर (ऐच्छिक)';

  @override
  String get vehiclesOptional => 'गाड्या (ऐच्छिक)';

  @override
  String get driversOptionalHint =>
      'ही गाडी कोण चालवू शकतो. हे नंतर बदलता येईल.';

  @override
  String get vehiclesOptionalHint =>
      'ते कोणत्या गाड्या चालवू शकतात. हे नंतर बदलता येईल.';

  @override
  String get noneSelected => 'अजून काही नाही';

  @override
  String get noDriversToLink =>
      'अजून ड्रायव्हर नाहीत. आधी ड्रायव्हरला आमंत्रण द्या.';

  @override
  String get noVehiclesToLink => 'अजून गाड्या नाहीत. आधी गाडी जोडा.';

  @override
  String get vehicleHasNoDrivers =>
      'या गाडीला कोणताही ड्रायव्हर जोडलेला नाही. आधी गाडीच्या पेजवर ड्रायव्हर जोडा.';

  @override
  String get driverHasNoVehicles =>
      'या ड्रायव्हरला कोणतीही गाडी जोडलेली नाही. आधी ड्रायव्हरच्या पेजवर गाड्या जोडा.';

  @override
  String get noVehiclesLinkedToYou =>
      'तुम्हाला अजून कोणतीही गाडी जोडलेली नाही. तुमच्या फ्लीट मालकाला तुम्हाला गाडी जोडायला सांगा.';

  @override
  String get noVehiclesLinkedHint =>
      'तुम्ही ऑफलाइन असाल तर एकदा इंटरनेट चालू करा, म्हणजे ॲप त्या लोड करू शकेल.';

  @override
  String get errorDriverNotLinked =>
      'ड्रायव्हर या गाडीला जोडलेला नाही. मालक गाडीच्या पेजवर त्याला जोडू शकतो.';

  @override
  String errorDriverNotLinkedNamed({
    required String driver,
    required String vehicle,
  }) {
    return '$driver हा $vehicle ला जोडलेला नाही. आधी गाडीच्या पेजवर जोडा.';
  }

  @override
  String get errorLinkInUse =>
      'या गाडीत ड्रायव्हरच्या दिलेल्या किंवा चालू ट्रिप आहेत. काढण्यापूर्वी त्या दुसऱ्याला द्या किंवा पूर्ण करा.';

  @override
  String errorLinkInUseCount({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'या गाडीत ड्रायव्हरच्या $count दिलेल्या किंवा चालू ट्रिप आहेत. काढण्यापूर्वी त्या दुसऱ्याला द्या किंवा पूर्ण करा.',
      one:
          'या गाडीत ड्रायव्हरची 1 दिलेली किंवा चालू ट्रिप आहे. काढण्यापूर्वी ती दुसऱ्याला द्या किंवा पूर्ण करा.',
    );
    return '$_temp0';
  }

  @override
  String get switchWorkspace => 'मोड किंवा फ्लीट बदला';

  @override
  String workspaceManage({required String fleet}) {
    return '$fleet सांभाळा';
  }

  @override
  String workspaceDrive({required String fleet}) {
    return '$fleet साठी गाडी चालवा';
  }

  @override
  String get workspaceManageHint =>
      'मालक मोड: गाड्या, ड्रायव्हर, ट्रिप आणि पैसे';

  @override
  String get workspaceDriveHint =>
      'ड्रायव्हर मोड: तुमच्या ट्रिप, इंधन आणि फोटो';

  @override
  String get setUpMyFleet => 'माझ्या गाड्या आहेत: माझा फ्लीट सेट करा';

  @override
  String unsyncedBeforeSwitch({required int count}) {
    return 'या फोनवरील $count ट्रिप अपडेट अजून पाठवलेले नाहीत. ऑनलाइन या, सिंक होऊ द्या, मग बदला.';
  }

  @override
  String get getStartedTitle => 'फ्लीट सारथीमध्ये स्वागत आहे';

  @override
  String get getStartedDriveTitle => 'गाडी मालकासाठी गाडी चालवा';

  @override
  String getStartedDriveBody({required String phone}) {
    return 'मालकाला त्यांच्या फ्लीट सारथीमध्ये $phone ड्रायव्हर म्हणून जोडायला सांगा. मग पुन्हा तपासा वर टॅप करा.';
  }

  @override
  String get checkAgain => 'पुन्हा तपासा';

  @override
  String get stillNoFleet => 'अजून कोणत्याही मालकाने तुम्हाला जोडलेले नाही.';

  @override
  String get getStartedOwnTitle => 'तुमच्या स्वतःच्या गाड्या आहेत?';

  @override
  String get getStartedOwnBody =>
      'गाड्या आणि ड्रायव्हर जोडण्यासाठी तुमचा फ्लीट सेट करा. त्याच अकाउंटवरून तुम्ही इतर मालकांसाठीही गाडी चालवू शकता.';

  @override
  String get createFleetTitle => 'तुमचा फ्लीट सेट करा';

  @override
  String get fleetNameLabel => 'फ्लीट किंवा व्यवसायाचे नाव';

  @override
  String get fleetNameTooShort => 'किमान 2 अक्षरे टाका';

  @override
  String get iDriveToo => 'मी माझ्या गाड्या स्वतःही चालवतो';

  @override
  String get createFleet => 'फ्लीट तयार करा';

  @override
  String get addMapPin => 'नकाशावर पिन लावा';

  @override
  String get changePin => 'बदला';

  @override
  String get removePin => 'पिन काढा';

  @override
  String get pickupOnMap => 'नकाशावर पिकअप';

  @override
  String get dropOnMap => 'नकाशावर ड्रॉप';

  @override
  String get pinPickerHint =>
      'पिन लावण्यासाठी नकाशावर टॅप करा. हलवण्यासाठी पुन्हा टॅप करा.';

  @override
  String get usePin => 'हा पिन वापरा';

  @override
  String get navGroupOverview => 'आढावा';

  @override
  String get navGroupFleet => 'फ्लीट';

  @override
  String get navGroupMoney => 'पैसे';

  @override
  String get navGroupSetup => 'सेटअप';

  @override
  String get greetingMorning => 'सुप्रभात';

  @override
  String get greetingAfternoon => 'नमस्कार';

  @override
  String get greetingEvening => 'शुभ संध्याकाळ';

  @override
  String get colRoute => 'मार्ग';

  @override
  String get colCustomer => 'ग्राहक';

  @override
  String get colFare => 'भाडे';

  @override
  String get colDocument => 'कागदपत्र';

  @override
  String get colFor => 'कोणासाठी';

  @override
  String get colNumber => 'नंबर';

  @override
  String get colRole => 'भूमिका';

  @override
  String get colBalance => 'शिल्लक';

  @override
  String get colShortfall => 'कमी';

  @override
  String get usualEfficiency => 'नेहमीचे ॲव्हरेज';

  @override
  String get alertsInbox => 'अलर्ट आणि तपासणी';

  @override
  String get documentsExpiredChip => 'कागदपत्राची मुदत संपली';

  @override
  String get documentsDueChip => 'कागदपत्राची मुदत जवळ';

  @override
  String get managersSection => 'मॅनेजर';

  @override
  String get noManagersYet => 'अजून मॅनेजर नाहीत.';

  @override
  String get shareTripHeading => 'ट्रिपचे तपशील';

  @override
  String get shareCustomer => 'ग्राहक';

  @override
  String get sharePickup => 'पिकअप';

  @override
  String get shareDrop => 'ड्रॉप';

  @override
  String get sharePickupTime => 'पिकअपची वेळ';

  @override
  String get shareCab => 'कॅब';

  @override
  String get shareDriver => 'ड्रायव्हर';

  @override
  String get shareFare => 'भाडे';

  @override
  String shareFareWithKm({required String fare, required String km}) {
    return '$fare ($km समाविष्ट)';
  }

  @override
  String get copyDetails => 'तपशील कॉपी करा';

  @override
  String get detailsCopied => 'ट्रिपचे तपशील कॉपी झाले';

  @override
  String get shareOnWhatsApp => 'WhatsApp वर पाठवा';

  @override
  String get whatsAppUnavailable => 'WhatsApp उघडता आले नाही';

  @override
  String get analytics => 'विश्लेषण';

  @override
  String get analyticsIntro =>
      'महिन्यातील रोजचे घेतलेले इंधन, कमाई आणि km, गाडीनुसार.';

  @override
  String get month => 'महिना';

  @override
  String get perTripAverages => 'प्रति ट्रिप सरासरी';

  @override
  String get avgKmPerTrip => 'प्रति ट्रिप km';

  @override
  String get avgRevenuePerTrip => 'प्रति ट्रिप कमाई';

  @override
  String get avgFuelCostPerTrip => 'प्रति ट्रिप इंधन खर्च (अंदाजे)';

  @override
  String tripsInMonth({required int count}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'या महिन्यात $count ट्रिप',
      one: 'या महिन्यात 1 ट्रिप',
    );
    return '$_temp0';
  }

  @override
  String get fuelBoughtPerDay => 'रोज घेतलेले इंधन';

  @override
  String get revenuePerDay => 'रोजची कमाई';

  @override
  String get kmPerDay => 'रोज चाललेले km';

  @override
  String monthTotal({required String total}) {
    return 'महिन्याची एकूण: $total';
  }

  @override
  String get fuelInRupeesNote =>
      '₹ मध्ये दाखवले आहे, कारण लिटर आणि kg एकत्र जोडता येत नाहीत.';

  @override
  String get noActivityThisMonth => 'या महिन्यात काहीही नाही.';

  @override
  String get customDay => 'कस्टम';

  @override
  String tripsOnDay({required String date}) {
    return '$date च्या ट्रिप';
  }

  @override
  String get availableCabs => 'उपलब्ध कॅब';

  @override
  String get availableDrivers => 'उपलब्ध ड्रायव्हर';

  @override
  String get tripsUnassigned => 'न दिलेल्या ट्रिप';

  @override
  String get completedTrips => 'पूर्ण झालेल्या ट्रिप';

  @override
  String percentReady({required int percent}) {
    return '$percent% तयार';
  }

  @override
  String cabsFooter({required int onTrip, required int inactive}) {
    return '$onTrip ट्रिपवर · $inactive बंद';
  }

  @override
  String driversFooter({required int onTrip, required int assigned}) {
    return '$onTrip ट्रिपवर · $assigned ट्रिप दिलेले';
  }

  @override
  String get standby => 'स्टँडबाय';

  @override
  String get needsCab => 'कॅब हवी';

  @override
  String get pending => 'बाकी';

  @override
  String get resolveQueue => 'रांग सोडवा';

  @override
  String get runs => 'फेऱ्या';

  @override
  String grossFare({required String amount}) {
    return '$amount एकूण भाडे';
  }

  @override
  String busyFromTo({required String from, required String to}) {
    return '$from – $to व्यस्त';
  }

  @override
  String get busyPickCleared =>
      'तुम्ही निवडलेली गाडी किंवा ड्रायव्हर नवीन वेळेला बुक आहे, म्हणून निवड काढली.';

  @override
  String get busyPickWarning =>
      'ही गाडी किंवा ड्रायव्हर या वेळेला आधीच बुक आहे.';

  @override
  String youAreBusy({required String when}) {
    return 'या वेळेला तुमची आधीच एक ट्रिप आहे ($when).';
  }

  @override
  String get uploadFile => 'फाइल अपलोड करा';

  @override
  String get chooseOtherFile => 'दुसरी फाइल निवडा';

  @override
  String get uploadFileHint =>
      'किंवा PDF किंवा इमेज (JPG, PNG, WebP) अपलोड करा, 15 MB पर्यंत.';

  @override
  String get fileTooLarge => 'ती फाइल 15 MB पेक्षा मोठी आहे.';

  @override
  String get pdfDocument => 'PDF कागदपत्र';

  @override
  String get imageFile => 'इमेज';

  @override
  String get viewDocument => 'कागदपत्र पाहा';

  @override
  String get documentUnavailable =>
      'कागदपत्र उघडता आले नाही. पुन्हा प्रयत्न करा.';

  @override
  String get schedule => 'वेळापत्रक';

  @override
  String get noTripsThisDay => 'या दिवशी ट्रिप नाहीत.';

  @override
  String get previousMonth => 'मागचा महिना';

  @override
  String get nextMonth => 'पुढचा महिना';

  @override
  String get logInWithOtp => 'OTP ने लॉग इन करा';

  @override
  String get noAccountForNumber =>
      'या नंबरचे अजून अकाउंट नाही. त्याऐवजी साइन अप करा.';

  @override
  String get signUpVerifyHint =>
      'नंबर तुमचाच आहे हे तपासण्यासाठी आम्ही OTP पाठवू.';

  @override
  String get verifyAndCreateAccount => 'नंबर तपासा आणि अकाउंट तयार करा';

  @override
  String get resetWithOtpIntro =>
      'OTP ने तुमचा मोबाइल नंबर तपासा, मग नवीन पासवर्ड निवडा.';

  @override
  String get numberVerified => 'नंबर तपासला गेला';

  @override
  String get verifyWithOtp => 'OTP ने तपासा';

  @override
  String get phoneVerifyTitle => 'तुमचा नंबर तपासा';

  @override
  String get stubVerifyHint =>
      'टेस्ट मोड: SMS पाठवला जात नाही. खालचा नंबर तपासलेला मानला जाईल.';

  @override
  String get errorPhoneOtpDisabled => 'OTP साइन-इन सध्या उपलब्ध नाही.';

  @override
  String get errorPhoneNotVerified =>
      'तुमचा नंबर तपासता आला नाही. पुन्हा प्रयत्न करा.';

  @override
  String get errorPhoneMismatch =>
      'तुम्ही तपासलेला नंबर तुम्ही टाकलेला नंबर नाही.';

  @override
  String get errorPhoneVerificationRequired =>
      'साइन अप करण्यासाठी तुमचा मोबाइल नंबर तपासा.';

  @override
  String get verify => 'तपासा';

  @override
  String get allowPopups =>
      'तुमचा नंबर तपासण्यासाठी या साइटला पॉप-अपची परवानगी द्या, मग पुन्हा प्रयत्न करा.';

  @override
  String get tripInProgress => 'ट्रिप चालू आहे';

  @override
  String get nextTrip => 'पुढची ट्रिप';

  @override
  String startsIn({required String time}) {
    return '$time मध्ये सुरू';
  }

  @override
  String get startingNow => 'आता सुरू होत आहे';

  @override
  String runningLate({required String time}) {
    return '$time उशीर';
  }

  @override
  String get todayAtAGlance => 'आजचा आढावा';

  @override
  String get lastSevenDays => 'मागचे 7 दिवस';

  @override
  String get statTripsDone => 'पूर्ण ट्रिप';

  @override
  String get statKmDriven => 'चाललेले km';

  @override
  String get statCollected => 'जमा';

  @override
  String ofTotal({required int done, required int total}) {
    return '$total पैकी $done';
  }

  @override
  String cashAmount({required String amount}) {
    return 'रोकड $amount';
  }

  @override
  String get callCustomer => 'कॉल करा';

  @override
  String get directions => 'रस्ता दाखवा';

  @override
  String kmSoFar({required String km}) {
    return 'आतापर्यंत $km';
  }

  @override
  String durationHm({required int h, required String m}) {
    return '$h तास $m मिनिट';
  }

  @override
  String durationM({required int m}) {
    return '$m मिनिट';
  }

  @override
  String get syncNow => 'आता सिंक करा';

  @override
  String get noTripsAssigned => 'अजून कोणतीही ट्रिप दिलेली नाही';

  @override
  String get noTripsHint =>
      'फ्लीट मालकाने ट्रिप दिल्यावर ती इथे दिसेल. रिफ्रेश करण्यासाठी खाली ओढा, किंवा स्वतः ट्रिप सुरू करा.';

  @override
  String get detailsTab => 'तपशील';

  @override
  String get documentFiles => 'फाइल (फोटो किंवा PDF)';

  @override
  String photoNumber({required int number}) {
    return 'फोटो $number';
  }

  @override
  String tooManyFiles({required int count}) {
    return 'एका कागदपत्रात जास्तीत जास्त $count फाइल असू शकतात.';
  }

  @override
  String fileTooLargeNamed({required String name}) {
    return '$name 15 MB पेक्षा मोठी आहे.';
  }

  @override
  String get uploadFiles => 'फाइल अपलोड करा';

  @override
  String viewFiles({required int count}) {
    return 'फाइल पाहा ($count)';
  }

  @override
  String get open => 'उघडा';

  @override
  String get filters => 'फिल्टर';

  @override
  String filtersCount({required int count}) {
    return 'फिल्टर ($count)';
  }

  @override
  String get clearAll => 'सर्व काढा';

  @override
  String get apply => 'लागू करा';

  @override
  String get severity => 'गंभीरता';

  @override
  String get alertKindTitle => 'प्रकार';

  @override
  String get quickOpsHub => 'झटपट कामे';

  @override
  String get fastDispatch => 'झटपट डिस्पॅच';

  @override
  String get addTrip => 'ट्रिप जोडा';

  @override
  String get tagDriver => 'ड्रायव्हर द्या';

  @override
  String get addDriverQuick => '+ ड्रायव्हर जोडा';

  @override
  String get addCabQuick => '+ कॅब जोडा';

  @override
  String get scheduledRides => 'ठरलेल्या राइड';

  @override
  String scheduledRidesOn({required String date}) {
    return 'ठरलेल्या राइड · $date';
  }

  @override
  String get noTripsWaiting => 'ड्रायव्हरची वाट पाहणारी कोणतीही ट्रिप नाही.';

  @override
  String get pickTripToAssign => 'देण्यासाठी ट्रिप निवडा';

  @override
  String get docAadhaar => 'आधार कार्ड';

  @override
  String get docPan => 'PAN कार्ड';

  @override
  String get docPoliceVerification => 'पोलीस व्हेरिफिकेशन';

  @override
  String get docBadge => 'बॅज / PSV लायसन्स';

  @override
  String get docPhoto => 'फोटो';

  @override
  String get noExpiry => 'मुदत नाही';

  @override
  String get docPendingApproval => 'मंजुरीची वाट';

  @override
  String get docRejected => 'नाकारले';

  @override
  String docRejectedBecause({required String note}) {
    return 'नाकारले: $note';
  }

  @override
  String get addedByDriver => 'ड्रायव्हरने जोडले';

  @override
  String get renewalOf => 'नूतनीकरण';

  @override
  String get approveDocument => 'मंजूर करा';

  @override
  String get rejectDocument => 'नाकारा';

  @override
  String get rejectDocumentTitle => 'हे कागदपत्र नाकारायचे?';

  @override
  String get rejectReasonLabel => 'कारण (ड्रायव्हरला दिसेल)';

  @override
  String get documentApproved => 'कागदपत्र मंजूर झाले';

  @override
  String get kindDocSubmitted => 'मंजुरीसाठी कागदपत्र';

  @override
  String alertDocSubmittedTitle({required String driver, required String doc}) {
    return '$driver ने त्यांचे $doc जोडले';
  }

  @override
  String alertDocRenewedTitle({required String driver, required String doc}) {
    return '$driver ने नूतनीकरण केलेले $doc अपलोड केले';
  }

  @override
  String get alertDocSubmittedBody =>
      'ते तपासा आणि त्यांच्या कागदपत्रे टॅबवर मंजूर करा किंवा नाकारा.';

  @override
  String get navHome => 'होम';

  @override
  String get navMyDocuments => 'कागदपत्रे';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get assignedTab => 'दिलेल्या';

  @override
  String get pastTab => 'मागील';

  @override
  String get noAssignedTrips => 'सध्या तुम्हाला कोणतीही ट्रिप दिलेली नाही.';

  @override
  String get noPastTrips => 'या महिन्यात कोणतीही ट्रिप नाही.';

  @override
  String get myDocumentsIntro =>
      'तुमचे लायसन्स, आधार आणि इतर कागदपत्रे जोडा. प्रत्येक कागद ग्राह्य धरण्यापूर्वी तुमचे फ्लीट मालक ते तपासतील.';

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String get editName => 'नाव बदला';

  @override
  String get yourName => 'तुमचे नाव';

  @override
  String get nameSaved => 'नाव सेव्ह झाले';

  @override
  String get fleetLabel => 'फ्लीट';

  @override
  String get phoneNumberLabel => 'मोबाइल नंबर';

  @override
  String get cabsYouDrive => 'तुम्ही चालवू शकता अशा कॅब';

  @override
  String get noCabsLinked =>
      'अजून कोणतीही कॅब जोडलेली नाही. तुमच्या फ्लीट मालकांना विचारा.';

  @override
  String driverSince({required String date}) {
    return '$date पासून ड्रायव्हर';
  }

  @override
  String get when => 'कधी';

  @override
  String confirmUpload({required int count}) {
    return 'अपलोड पक्के करा ($count)';
  }

  @override
  String get fileReadyToUpload => 'निवडले · अजून अपलोड झाले नाही';

  @override
  String get fileUploading => 'अपलोड होत आहे…';

  @override
  String get fileUploaded => 'अपलोड झाले';

  @override
  String get fileUploadFailed => 'अपलोड अयशस्वी · पुन्हा प्रयत्न करा';

  @override
  String get uploadFilesFirst =>
      'निवडलेल्या फाइल्स आधी अपलोड करण्यासाठी \'अपलोड पक्के करा\' वर टॅप करा.';

  @override
  String filesUploadedCount({required int count}) {
    return '$count फाइल्स अपलोड झाल्या';
  }

  @override
  String get colFiles => 'फाइल्स';

  @override
  String get noFiles => 'फाइल्स नाहीत';

  @override
  String get fixHighlighted => 'हायलाइट केलेली माहिती भरा.';

  @override
  String get documentSentForApproval =>
      'कागदपत्र जोडले. तुमचे फ्लीट मालक ते मंजूर करतील.';

  @override
  String get documentSaved => 'कागदपत्र सेव्ह झाले';

  @override
  String uploadAndSave({required int count}) {
    return '$count फाइल्स अपलोड करा आणि सेव्ह करा';
  }

  @override
  String get photoMustBeImage => 'फोटो निवडा (JPG, PNG किंवा WebP).';

  @override
  String get invalidEmail => 'योग्य ईमेल पत्ता टाका';

  @override
  String get invalidMobile => '10 अंकी मोबाइल नंबर टाका';

  @override
  String get dateOfBirth => 'जन्मतारीख';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get addressLabel => 'पत्ता';

  @override
  String get emergencyContact => 'आपत्कालीन संपर्क';

  @override
  String get contactName => 'संपर्क व्यक्तीचे नाव';

  @override
  String get contactPhone => 'संपर्क मोबाइल नंबर';

  @override
  String get editProfile => 'प्रोफाइल बदला';

  @override
  String get editDetails => 'माहिती बदला';

  @override
  String get choosePhoto => 'फोटो निवडा';

  @override
  String get changePhone => 'मोबाइल नंबर बदला';

  @override
  String get changePhoneIntro =>
      'तुमच्या मोबाइल नंबरनेच तुम्ही लॉग इन करता. नवीन नंबर तुमचाच आहे हे तपासण्यासाठी आम्ही त्यावर कोड पाठवू.';

  @override
  String codeSentTo({required String phone}) {
    return '$phone वर पाठवलेला 6 अंकी कोड टाका';
  }

  @override
  String get verifyAndChange => 'तपासा आणि बदला';

  @override
  String get phoneChanged => 'मोबाइल नंबर बदलला';

  @override
  String get profileSaved => 'प्रोफाइल सेव्ह झाले';

  @override
  String get personalDetails => 'वैयक्तिक माहिती';

  @override
  String get discardDocumentTitle => 'हे कागदपत्र रद्द करायचे?';

  @override
  String get discardDocumentBody =>
      'हे सेव्ह झालेले नाही. तुम्ही जोडलेल्या फाइल्स आणि माहिती निघून जाईल.';

  @override
  String get keepEditing => 'बदल चालू ठेवा';

  @override
  String get discard => 'रद्द करा';

  @override
  String uploadingStep({required int n, required int count}) {
    return '$count पैकी $n अपलोड होत आहे…';
  }

  @override
  String get savingStep => 'सेव्ह होत आहे…';

  @override
  String get welcomeSignIn => 'साइन इन करा';

  @override
  String get welcomeGetStarted => 'सुरू करा';

  @override
  String get welcomeHaveAccount => 'माझे खाते आहे';

  @override
  String get welcomeAbout => 'फ्लीट सारथी म्हणजे काय?';

  @override
  String get welcomeEyebrow => 'मालक-ड्रायव्हर आणि 2–15 गाड्यांच्या फ्लीटसाठी';

  @override
  String get welcomeHeadlineLead => 'तुमच्या गाड्यांनी आज';

  @override
  String get welcomeHeadlineAccent => 'खरंच काय केलं ते जाणा.';

  @override
  String get welcomeSubhead =>
      'फोटो-पुराव्यासह ट्रिप, प्रत्येक गाडीच्या स्वतःच्या मायलेजशी तपासलेले इंधन, GPS अंतर तपासणी आणि प्रत्येक ड्रायव्हरचा रोजचा रोख हिशोब. तुमच्यासाठी आणि तुमच्या ड्रायव्हर्ससाठी एकच ॲप.';

  @override
  String get welcomeTrustOffline => 'ऑफलाइन चालते';

  @override
  String get welcomeTrustPlatforms => 'Android, iPhone आणि वेब';

  @override
  String get welcomeTrustLanguages => 'मराठी, English, हिन्दी, ಕನ್ನಡ';

  @override
  String get welcomeTrustNoCard => 'कार्डची गरज नाही';

  @override
  String get welcomeMockToday => 'आज';

  @override
  String get welcomeMockLive => 'लाइव्ह';

  @override
  String get welcomeMockTrips => 'ट्रिप';

  @override
  String get welcomeMockKm => 'चाललेले km';

  @override
  String get welcomeMockCash => 'येणे रोख';

  @override
  String get welcomeMockMileage => 'मायलेज, शेवटचे 8 फिल';

  @override
  String get welcomeMockFuelTitle => 'इंधन तपासणी';

  @override
  String get welcomeMockFuelBody =>
      'MH 12 AB 4521 ने 9.1 km/l दिले, नेहमीच्या 11.7 पेक्षा 22% कमी';

  @override
  String get welcomeMockGpsTitle => 'अंतर तपासले';

  @override
  String get welcomeMockGpsBody => 'पुणे → मुंबई: GPS 148 km, ओडोमीटर 151 km';

  @override
  String get welcomeMockSettleTitle => 'रमेश · आज हिशोब करा';

  @override
  String get welcomeMockSettleBody => 'भाडे ₹4,200 − खर्च ₹640';

  @override
  String get welcomeBuiltFor => 'कोणासाठी';

  @override
  String get welcomeForDco => 'मालक-ड्रायव्हर (DCO)';

  @override
  String get welcomeForSmallFleets => '2–15 गाड्यांचे फ्लीट';

  @override
  String get welcomeForIntercity => 'इंटरसिटी आणि आउटस्टेशन';

  @override
  String get welcomeForLocal => 'लोकल आणि एअरपोर्ट फेऱ्या';

  @override
  String get welcomeFeaturesKicker => 'सगळं एकाच ॲपमध्ये';

  @override
  String get welcomeFeaturesTitle =>
      'भारतातील कॅब फ्लीट खरंच जसे चालतात, तसे बनवलेले';

  @override
  String get welcomeFeatureFuelTitle => 'इंधन ऑडिट';

  @override
  String get welcomeFeatureFuelBody =>
      'प्रत्येक गाडीचे मायलेज तिच्या स्वतःच्या बेसलाइनशी, किंवा पेट्रोल + CNG गाड्यांसाठी प्रति km खर्च.';

  @override
  String get welcomeFeatureTripsTitle => 'पुराव्यासह ट्रिप';

  @override
  String get welcomeFeatureTripsBody =>
      'ट्रिप तयार करा आणि द्या, मग ओडोमीटरचे फोटो आणि नकाशावर GPS मार्ग पाहा.';

  @override
  String get welcomeFeatureSettleTitle => 'रोजचा हिशोब';

  @override
  String get welcomeFeatureSettleBody =>
      'भाडे, रोख, ऑनलाइन पेमेंट, खर्च आणि तुमचे पगार नियम, सगळं मिळून एक निव्वळ रक्कम.';

  @override
  String get welcomeFeatureDocsTitle => 'कागदपत्रांची आठवण';

  @override
  String get welcomeFeatureDocsBody =>
      'RC, विमा, परमिट, PUC आणि लायसन्स: मुदत संपण्याच्या 30, 7 आणि 1 दिवस आधी सूचना.';

  @override
  String get welcomeFeatureOfflineTitle => 'नेटवर्क नसतानाही चालते';

  @override
  String get welcomeFeatureOfflineBody =>
      'घाट रस्त्यांवर आणि हायवेवरही ड्रायव्हर ॲप नोंद करत राहते, आणि नेटवर्क आल्यावर सिंक करते.';

  @override
  String get welcomeFeatureDcoTitle => 'मालकी आणि ड्रायव्हिंग';

  @override
  String get welcomeFeatureDcoBody =>
      'एकाच खात्यातून तुमचा फ्लीट चालवा आणि दुसऱ्याच्या फ्लीटमध्ये गाडी चालवा. एका टॅपमध्ये बदला.';

  @override
  String get welcomeStepsKicker => 'हे कसे काम करते';

  @override
  String get welcomeStepsTitle => 'पुढच्या ट्रिपआधीच सुरू';

  @override
  String get welcomeStep1Title => 'तुमच्या गाड्या आणि ड्रायव्हर जोडा';

  @override
  String get welcomeStep1Body =>
      'तुमच्या मोबाइल नंबरने साइन अप करा, गाड्या जोडा आणि ड्रायव्हर्सना त्यांच्या नंबरने जोडा.';

  @override
  String get welcomeStep2Title => 'ड्रायव्हर फोनवरून नोंद करतात';

  @override
  String get welcomeStep2Body =>
      'मीटरच्या फोटोसह ट्रिप सुरू करा आणि संपवा, पावतीसह इंधन नोंदवा, टोल आणि रोख जोडा.';

  @override
  String get welcomeStep3Title => 'तुम्हाला रोज खरी माहिती दिसते';

  @override
  String get welcomeStep3Body =>
      'काही गडबड वाटली तर सूचना, आणि दिवसाच्या शेवटी प्रत्येक ड्रायव्हरचा हिशोब.';

  @override
  String get welcomeOwnersTitle => 'मालकांसाठी';

  @override
  String get welcomeOwners1 => 'प्रत्येक गाडी आणि ड्रायव्हर एकाच डॅशबोर्डवर';

  @override
  String get welcomeOwners2 =>
      'रद्द करण्याच्या विनंत्या मंजूर करा आणि फ्लॅग केलेल्या ट्रिप तपासा';

  @override
  String get welcomeOwners3 => 'पगार नियम एकदाच ठरवा; हिशोब त्याप्रमाणे होतो';

  @override
  String get welcomeOwners4 => 'फोनवर किंवा लॅपटॉपवर वापरा';

  @override
  String get welcomeDriversTitle => 'ड्रायव्हर्ससाठी';

  @override
  String get welcomeDrivers1 =>
      'मराठी, English, हिंदी किंवा कन्नडमध्ये सोप्या स्क्रीन';

  @override
  String get welcomeDrivers2 => 'आजच्या ट्रिप क्रमाने, सुरू करायला एक टॅप';

  @override
  String get welcomeDrivers3 => 'नेटवर्क गेले तरी काहीही हरवत नाही';

  @override
  String get welcomeDrivers4 => 'लायसन्स आणि कागदपत्रे नेहमी अद्ययावत';

  @override
  String get welcomeFaqTitle => 'मालक विचारतात ते प्रश्न';

  @override
  String get welcomeFaqOfflineQ => 'माझ्या ड्रायव्हर्सना सतत इंटरनेट लागते का?';

  @override
  String get welcomeFaqOfflineA =>
      'नाही. ड्रायव्हर ॲप सगळं फोनवर सेव्ह करते आणि नेटवर्क आल्यावर क्रमाने पाठवते.';

  @override
  String get welcomeFaqDcoQ =>
      'मी माझी स्वतःची गाडी चालवत असेन तर वापरू शकतो का?';

  @override
  String get welcomeFaqDcoA =>
      'हो. मालक-ड्रायव्हरना मालकाच्या आणि ड्रायव्हरच्या दोन्ही स्क्रीन मिळतात, आणि त्यांच्यामध्ये बदलता येते.';

  @override
  String get welcomeFaqPrivacyQ => 'माझ्या फ्लीटचा डेटा खाजगी आहे का?';

  @override
  String get welcomeFaqPrivacyA =>
      'हो. प्रत्येक फ्लीटचा डेटा अगदी डेटाबेसपर्यंत वेगळा ठेवला जातो, आणि तुम्ही जोडलेल्या लोकांनाच तो दिसतो.';

  @override
  String get welcomeFaqPhoneQ => 'ड्रायव्हरला कोणता फोन लागतो?';

  @override
  String get welcomeFaqPhoneA =>
      'कॅमेरा असलेला कोणताही Android फोन किंवा iPhone (iOS 14 किंवा नवीन). मालक फ्लीट सारथी वेब ब्राउझरमध्येही वापरू शकतात.';

  @override
  String get welcomeFaqLanguageQ => 'हे माझ्या भाषेत आहे का?';

  @override
  String get welcomeFaqLanguageA =>
      'हो. प्रत्येक स्क्रीन मराठी, English, हिंदी आणि कन्नडमध्ये आहे; वरून कधीही भाषा बदला.';

  @override
  String get welcomeFinalTitle => 'अंदाज लावणे थांबवा. खरं जाणून घ्या.';

  @override
  String get welcomeFinalBody =>
      'फक्त तुमच्या मोबाइल नंबरने काही मिनिटांत तुमचा फ्लीट सेट करा.';

  @override
  String get loginTagline => 'प्रत्येक किलोमीटरचा हिशोब.';

  @override
  String get loginAboutCompany =>
      'भारतभरातील मालक-ड्रायव्हर आणि छोट्या फ्लीटसाठी फ्लीट ऑडिट आणि कॅब व्यवस्थापन.';

  @override
  String get welcomeFooter => 'भारतात बनवलेले, भारताच्या कॅब फ्लीटसाठी.';

  @override
  String get welcomeShowcaseKicker => 'प्रत्यक्ष पाहा';

  @override
  String get welcomeShowcaseTitle =>
      'तुम्ही रोज ज्या अडचणींना तोंड देता, त्यांसाठी एकच ॲप';

  @override
  String get welcomeShowcaseSubtitle =>
      'तुम्ही गाडीत नसता तेव्हा वहीवर आणि WhatsApp मेसेजवर विश्वास ठेवता. पाहा काय बदलते.';

  @override
  String get welcomeTabFuel => 'इंधन';

  @override
  String get welcomeTabSettlement => 'हिशोब';

  @override
  String get welcomeTabDocuments => 'कागदपत्रे';

  @override
  String get welcomeTabOffline => 'ऑफलाइन';

  @override
  String get welcomeUcFuelTitle => 'पंपावर उभे न राहता इंधन चोरी पकडा';

  @override
  String get welcomeUcFuelBody =>
      'ड्रायव्हर पावतीचा फोटो काढतात आणि फुल-टँक फिल मार्क करतात. फ्लीट सारथी प्रत्येक गाडीचे स्वतःचे मायलेज, प्रत्येक सायकलला मोजते, आणि ते कमी होताच लगेच सांगते.';

  @override
  String get welcomeUcFuelPoint1 =>
      'प्रत्येक गाडीची स्वतःची बेसलाइन, ब्रोशरचा आकडा नाही';

  @override
  String get welcomeUcFuelPoint2 => 'पेट्रोल + CNG गाड्यांसाठी प्रति km खर्च';

  @override
  String get welcomeUcFuelPoint3 =>
      'सोप्या शब्दांत सूचना, समजायला अवघड चार्ट नाहीत';

  @override
  String get welcomeUcFuelThisCycle => 'ही सायकल';

  @override
  String get welcomeUcFuelUsual => 'नेहमीचे';

  @override
  String get welcomeUcTripsTitle =>
      'प्रत्येक किलोमीटरला फोटो आणि GPS चा पुरावा';

  @override
  String get welcomeUcTripsBody =>
      'ड्रायव्हर प्रत्येक ट्रिप ओडोमीटरच्या फोटोने सुरू करतात आणि संपवतात. रीडिंग फोटो आणि GPS मार्गाशी तपासले जाते, आणि जे जुळत नाही ते तुमच्या तपासणीसाठी थांबते.';

  @override
  String get welcomeUcTripsPoint1 => 'सुरुवातीला आणि शेवटी मीटरचे फोटो';

  @override
  String get welcomeUcTripsPoint2 => 'प्रत्येक ट्रिपचा मार्ग नकाशावर';

  @override
  String get welcomeUcTripsPoint3 =>
      'न जुळणाऱ्या गोष्टी तुमच्या तपासणी यादीत जातात';

  @override
  String get welcomeUcTripStart => 'सुरुवात';

  @override
  String get welcomeUcTripEnd => 'शेवट';

  @override
  String get welcomeUcTripRoute => 'पुणे → मुंबई';

  @override
  String get welcomeUcTripDriver => 'रमेश · MH 12 AB 4521';

  @override
  String get welcomeUcTripCheck => 'GPS 148 km · ओडोमीटर 151 km';

  @override
  String get welcomeUcSettleTitle =>
      'प्रत्येक ड्रायव्हरच्या दिवसाचा हिशोब एका आकड्यात';

  @override
  String get welcomeUcSettleBody =>
      'भाडे, रोख, UPI आणि कार्डने मिळालेले पैसे, टोल आणि पार्किंग, आणि तुमचा पगार नियम मिळून एक रक्कम: ड्रायव्हर तुम्हाला काय देतो, किंवा तुम्ही त्याला किती देणे आहे.';

  @override
  String get welcomeUcSettlePoint1 =>
      'प्रत्येक ड्रायव्हरसाठी पगार नियम एकदाच ठरवा';

  @override
  String get welcomeUcSettlePoint2 => 'रोख आणि ऑनलाइन पैसे वेगळे';

  @override
  String get welcomeUcSettlePoint3 => 'पावत्यांसह टोल आणि पार्किंग';

  @override
  String get welcomeUcSettleHeader => 'रमेश · आज';

  @override
  String get welcomeUcSettleFare => 'भाडे';

  @override
  String get welcomeUcSettleCash => 'रोख मिळाले';

  @override
  String get welcomeUcSettleOnline => 'ऑनलाइन मिळाले (UPI, कार्ड)';

  @override
  String get welcomeUcSettleExpenses => 'भरलेले टोल आणि पार्किंग';

  @override
  String get welcomeUcSettlePay => 'ड्रायव्हरचा पगार (भाड्याच्या 30%)';

  @override
  String get welcomeUcSettleNet => 'रमेश देणार';

  @override
  String get welcomeUcDocsTitle => 'मुदत संपलेल्या परमिटमुळे कधीही अडकू नका';

  @override
  String get welcomeUcDocsBody =>
      'प्रत्येक गाडी आणि ड्रायव्हरचे RC, विमा, परमिट, PUC आणि ड्रायव्हिंग लायसन्स एकाच ठिकाणी, प्रत्येकाची मुदत संपण्याच्या 30, 7 आणि 1 दिवस आधी आठवण.';

  @override
  String get welcomeUcDocsPoint1 => 'प्रत्येक गाडी आणि प्रत्येक ड्रायव्हर';

  @override
  String get welcomeUcDocsPoint2 => 'फोटो किंवा PDF अपलोड करा';

  @override
  String get welcomeUcDocsPoint3 => 'मुदतीच्या आधी आठवण, नंतर नाही';

  @override
  String get welcomeUcDocsHeader => 'लवकरच मुदत संपणार';

  @override
  String get welcomeUcDocsRow1 => 'MH 12 AB 4521 · विमा';

  @override
  String get welcomeUcDocsDue1 => '7 दिवसांत';

  @override
  String get welcomeUcDocsRow2 => 'सुरेश · ड्रायव्हिंग लायसन्स';

  @override
  String get welcomeUcDocsDue2 => 'उद्या';

  @override
  String get welcomeUcDocsRow3 => 'MH 14 CD 7788 · परमिट';

  @override
  String get welcomeUcDocsDue3 => '30 दिवसांत';

  @override
  String get welcomeUcDocsRow4 => 'MH 12 AB 4521 · PUC';

  @override
  String get welcomeUcDocsDue4 => 'वैध';

  @override
  String get welcomeUcOfflineTitle => 'हायवे आणि घाट रस्त्यांसाठी बनवलेले';

  @override
  String get welcomeUcOfflineBody =>
      'नेटवर्क नाही? ड्रायव्हर ॲप ट्रिप, इंधन आणि पेमेंटची नोंद फोनवर करत राहते आणि नेटवर्क आल्यावर क्रमाने पाठवते. काहीही हरवत नाही, आणि काहीही दोनदा मोजले जात नाही.';

  @override
  String get welcomeUcOfflinePoint1 => 'अजिबात नेटवर्क नसतानाही चालते';

  @override
  String get welcomeUcOfflinePoint2 => 'आपोआप, क्रमाने सिंक होते';

  @override
  String get welcomeUcOfflinePoint3 =>
      'पुन्हा प्रयत्न करणे सुरक्षित, कधीही डुप्लिकेट नाही';

  @override
  String get welcomeUcOfflineBanner => 'नेटवर्क नाही · या फोनवर सेव्ह होत आहे';

  @override
  String get welcomeUcOfflineTrip => 'ट्रिप चालू · पुणे → लोणावळा';

  @override
  String get welcomeUcOfflineFuel => 'इंधन फिल सेव्ह झाले · ₹2,150';

  @override
  String get welcomeUcOfflineCash => 'रोख मिळाले · ₹1,200';

  @override
  String get welcomeUcOfflineWaiting => '3 बदल सिंकच्या प्रतीक्षेत';

  @override
  String percentFree({required int percent}) {
    return '$percent% मोकळे';
  }

  @override
  String cabHoursFree({required String reg, required int hours}) {
    return '$reg: $hours तास मोकळी';
  }

  @override
  String moreCabs({required int count}) {
    return '+$count आणखी';
  }

  @override
  String get welcomeMockCabsToday => 'आजच्या कॅब';

  @override
  String get welcomeTabAvailability => 'उपलब्धता';

  @override
  String get welcomeUcAvailTitle => 'कोणती कॅब कधी मोकळी आहे, तासागणिक पाहा';

  @override
  String get welcomeUcAvailBody =>
      'प्रत्येक कॅबचा दिवस एका ओळीत: मोकळी असताना हिरवा, ट्रिपवर असताना लाल. ग्राहकाला शब्द देण्याआधीच नवीन बुकिंगसाठी मोकळा वेळ शोधा.';

  @override
  String get welcomeUcAvailPoint1 => 'थेट डॅशबोर्डवर, कोणत्याही दिवसासाठी';

  @override
  String get welcomeUcAvailPoint2 => 'रात्रभरच्या ट्रिप बरोबर मोजल्या जातात';

  @override
  String get welcomeUcAvailPoint3 => 'तुमच्या फ्लीटमधील मोकळ्या तासांचा वाटा';

  @override
  String get welcomeUcAvailFreeNow => 'आता मोकळ्या: 5 पैकी 2';

  @override
  String nSelected({required int count}) {
    return '$count निवडले';
  }

  @override
  String get dateRangeLabel => 'तारखा';

  @override
  String get rangeFrom => 'पासून';

  @override
  String get rangeTo => 'पर्यंत';

  @override
  String get thisMonth => 'हा महिना';

  @override
  String get thisWeek => 'हा आठवडा';

  @override
  String get customRange => 'हवी ती तारीख';

  @override
  String get kindTripUnassigned => 'गाडी किंवा ड्रायव्हर नाही';

  @override
  String alertTripUnassignedTitle({required String route}) {
    return '$route ला अजून गाडी किंवा ड्रायव्हर नाही';
  }

  @override
  String alertTripUnassignedBody({required String when}) {
    return 'ही $when सुरू होते. त्याआधी गाडी आणि ड्रायव्हर द्या.';
  }

  @override
  String alertTripUnassignedOverdueBody({required String when}) {
    return 'ही $when सुरू व्हायची होती आणि अजूनही गाडी किंवा ड्रायव्हर नाही. एखादा द्या, किंवा ट्रिप रद्द करा.';
  }

  @override
  String docNumberLabel({required String doc}) {
    return '$doc नंबर';
  }

  @override
  String docNumberHint({required String example}) {
    return 'उदा. $example';
  }

  @override
  String get docNumberMissing => 'नंबर टाका';

  @override
  String docNumberFormat({required String example}) {
    return 'हे बरोबर वाटत नाही. हे $example सारखे असावे';
  }

  @override
  String get aadhaarFormat =>
      '12 अंकी आधार नंबर टाका (तो कधीही 0 किंवा 1 ने सुरू होत नाही)';

  @override
  String get aadhaarChecksum => 'हा वैध आधार नंबर नाही. अंक तपासा.';

  @override
  String get expiryBeforeStart => '\'पासून वैध\' तारखेनंतरची असावी';

  @override
  String get errorDriverInactive =>
      'फ्लीट मालकांनी निष्क्रिय केले आहे: नवीन ट्रिप तयार करता किंवा देता येणार नाहीत.';

  @override
  String get errorDriverHasTrips =>
      'ड्रायव्हरकडे अजून ट्रिप दिलेल्या आहेत. आधी त्या काढून घ्या.';

  @override
  String driverHasTripsTitle({required int count, required String name}) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name कडे $count येणाऱ्या ट्रिप आहेत',
      one: '$name कडे 1 येणारी ट्रिप आहे',
    );
    return '$_temp0';
  }

  @override
  String get driverHasTripsBody =>
      'त्यांना निष्क्रिय करण्यासाठी आधी या ट्रिप काढून घ्या. त्या न दिलेल्या ट्रिपच्या यादीत परत जातात, म्हणजे तुम्ही त्या दुसऱ्या ड्रायव्हरला देऊ शकता.';

  @override
  String get unassignAndDeactivate => 'ट्रिप काढा आणि निष्क्रिय करा';

  @override
  String driverOnTripTitle({required String name}) {
    return '$name सध्या ट्रिपवर आहेत';
  }

  @override
  String get driverOnTripBody => 'ट्रिप संपल्यावर त्यांना निष्क्रिय करा.';

  @override
  String get driverInactiveBanner =>
      'तुमच्या फ्लीट मालकांनी तुम्हाला निष्क्रिय केले आहे. तुम्ही मागील ट्रिप पाहू शकता, पण नवीन तयार करू शकत नाही.';

  @override
  String get driverTripsTurnedOff =>
      'तुमच्या फ्लीट मालकांनी ड्रायव्हर ॲपमधून ट्रिप तयार करणे बंद केले आहे.';

  @override
  String get errorDriverTripsDisabled =>
      'तुमच्या फ्लीट मालकांनी ड्रायव्हरने तयार केलेल्या ट्रिप बंद केल्या आहेत.';

  @override
  String get errorDriverChargesDisabled =>
      'तुमच्या फ्लीट मालकांनी ड्रायव्हरने जोडलेले खर्च बंद केले आहेत.';

  @override
  String get errorReceiptRequired => 'इंधनाच्या पावतीचा फोटो जोडा.';

  @override
  String get settingsIntro =>
      'तुमच्या फ्लीटसाठी फ्लीट सारथी कसे काम करेल ते निवडा. प्रत्येक पानावर सेटिंग काय बदलते आणि कधी लागू होते ते लिहिले आहे.';

  @override
  String get settingsGroupFleet => 'तुमचा फ्लीट';

  @override
  String get settingsGroupYou => 'तुम्ही';

  @override
  String get settingsGeneral => 'सामान्य';

  @override
  String get settingsGeneralDesc => 'तुमच्या फ्लीटचे नाव';

  @override
  String get settingsTrips => 'ट्रिप आणि ड्रायव्हर';

  @override
  String get settingsTripsDesc => 'ड्रायव्हर काय करू शकतात, आणि अंतर तपासणी';

  @override
  String get settingsFuel => 'इंधन ऑडिट';

  @override
  String get settingsFuelDesc => 'पावत्या, आणि फिल कधी फ्लॅग होतो';

  @override
  String get settingsReminders => 'कागदपत्रे आणि आठवणी';

  @override
  String get settingsRemindersDesc =>
      'कागदपत्रांची मुदत संपण्याआधी कधी आठवण मिळते';

  @override
  String get settingsPayDesc =>
      'ज्या ड्रायव्हर्सचा स्वतःचा नियम नाही त्यांचा पगार';

  @override
  String get settingsTeam => 'टीम आणि भूमिका';

  @override
  String get settingsTeamDesc => 'मॅनेजर, आणि प्रत्येक भूमिका काय करू शकते';

  @override
  String get settingsLanguageDesc => 'या डिव्हाइसवरील ॲपची भाषा';

  @override
  String get settingsSecurityDesc => 'तुमचा पासवर्ड आणि मोबाइल नंबर';

  @override
  String settingsAffects({required String area}) {
    return 'परिणाम: $area';
  }

  @override
  String settingsApplies({required String when}) {
    return 'कधी: $when';
  }

  @override
  String get settingsSaveChanges => 'बदल सेव्ह करा';

  @override
  String get settingsResetDefaults => 'मूळ सेटिंग्ज परत आणा';

  @override
  String get settingsResetDone =>
      'मूळ सेटिंग्ज भरल्या. लागू करण्यासाठी सेव्ह करा.';

  @override
  String get settingsSaved => 'सेव्ह झाले.';

  @override
  String get settingsDiscardTitle => 'तुमचे बदल रद्द करायचे?';

  @override
  String get settingsDiscardBody =>
      'तुम्ही या पानावर सेटिंग्ज बदलल्या पण सेव्ह केल्या नाहीत.';

  @override
  String get settingsUnsaved => 'सेव्ह न केलेले बदल';

  @override
  String settingsDefaultIs({required String value}) {
    return 'मूळ: $value';
  }

  @override
  String get settingsOn => 'चालू';

  @override
  String get settingsOff => 'बंद';

  @override
  String get fleetNameHelp =>
      'ॲपमध्ये तुमच्या मॅनेजर आणि ड्रायव्हर्सना, आणि तुम्ही ग्राहकांना पाठवलेल्या ट्रिप मेसेजमध्ये दिसते.';

  @override
  String get fleetNameAffects =>
      'वर्कस्पेस बदलणे, डॅशबोर्ड, शेअर केलेले ट्रिप मेसेज';

  @override
  String get fleetNameWhen =>
      'सगळीकडे एकाच वेळी; ट्रिप आणि हिशोबात नाव साठवले जात नाही';

  @override
  String get fleetNameInvalid => '2 ते 100 अक्षरे वापरा.';

  @override
  String get ruleDriverTrips => 'ड्रायव्हर स्वतःच्या ट्रिप तयार करू शकतात';

  @override
  String get ruleDriverTripsHelp =>
      'ड्रायव्हर्सना \'नवीन ट्रिप\' बटण मिळते आणि ते त्यांना जोडलेल्या गाडीत स्वतःसाठी ट्रिप बुक करू शकतात. बंद असताना फक्त तुम्ही आणि तुमचे मॅनेजर ट्रिप तयार करतात.';

  @override
  String get ruleDriverTripsAffects => 'ड्रायव्हर ॲप: नवीन ट्रिप';

  @override
  String get ruleNewTripsOnly =>
      'फक्त नवीन ट्रिप; आधीच तयार झालेल्या ट्रिप आहेत तशाच राहतात';

  @override
  String get ruleDriverCharges => 'ड्रायव्हर खर्च जोडू शकतात';

  @override
  String get ruleDriverChargesHelp =>
      'ड्रायव्हर ट्रिपदरम्यान आणि ट्रिप संपवताना टोल, पार्किंग आणि इतर खर्च जोडू शकतात. ड्रायव्हरने भरलेले खर्च त्याच्या रोजच्या हिशोबात धरले जातात. बंद असताना फक्त तुम्ही आणि तुमचे मॅनेजर खर्च जोडतात.';

  @override
  String get ruleDriverChargesAffects =>
      'ड्रायव्हर ॲप: ट्रिप खर्च; रोजचा हिशोब';

  @override
  String get ruleNewChargesOnly => 'फक्त नवीन खर्च; आधी जोडलेले खर्च राहतात';

  @override
  String get ruleOfflineNote =>
      'तुम्ही नियम बदलण्याआधी ज्या ड्रायव्हरने ऑफलाइन काही नोंद केली असेल, त्याचा फोन सिंक झाल्यावर ती नाकारलेली दिसेल, आणि लक्ष देण्याची गरज म्हणून मार्क होईल.';

  @override
  String get odoToleranceAffects =>
      'संपलेल्या ट्रिपवरील ओडोमीटर विरुद्ध GPS अंतर तपासणी';

  @override
  String get odoToleranceWhen =>
      'सेव्ह केल्यानंतरच्या तपासण्या; आधीचे निकाल राहतात';

  @override
  String get ruleReceipt => 'इंधन पावतीचा फोटो आवश्यक';

  @override
  String get ruleReceiptHelp =>
      'प्रत्येक इंधन फिलसाठी पावतीचा फोटो लागतो. जिथे छापील पावती मिळत नाही तिथे ड्रायव्हर अनेकदा इंधन भरत असतील तर बंद करा.';

  @override
  String get ruleReceiptAffects => 'ड्रायव्हर ॲप: इंधन नोंदवा';

  @override
  String get ruleNewFillsOnly => 'फक्त नवीन फिल; आधी नोंदवलेले फिल राहतात';

  @override
  String get fuelThresholdsTitle => 'फिल कधी फ्लॅग होतो';

  @override
  String get fuelThresholdsAffects =>
      'इंधन सूचना आणि प्रत्येक गाडीचे नेहमीचे मायलेज';

  @override
  String get fuelThresholdsWhen =>
      'प्रत्येक गाडीची पुढची इंधन तपासणी (तिचा पुढचा फिल); आधी आलेल्या सूचना राहतात';

  @override
  String get remindersAffects =>
      'गाडी आणि ड्रायव्हरच्या कागदपत्रांच्या मुदत संपण्याच्या सूचना';

  @override
  String get remindersWhen =>
      'पुढच्या रोजच्या तपासणीपासून, सकाळी साधारण 6 वाजता';

  @override
  String get remindersSeverity =>
      'मुदत संपण्याच्या 7 दिवस किंवा त्यापेक्षा कमी आधीच्या सूचना इशारा असतात; 1 दिवस किंवा कमी, किंवा मुदत संपलेल्या, गंभीर असतात.';

  @override
  String get payAffects =>
      'स्वतःचा पगार नियम नसलेल्या ड्रायव्हर्सचा रोजचा हिशोब';

  @override
  String get payWhen =>
      'हिशोब न झालेले दिवस; हिशोब झालेल्या दिवसांचा पगार तोच राहतो';

  @override
  String get rolesTitle => 'प्रत्येक भूमिका काय करू शकते';

  @override
  String get roleOwnerCan => 'सगळं, या सेटिंग्ज, पगार नियम आणि मॅनेजरसह.';

  @override
  String get roleManagerCan =>
      'फ्लीट चालवतो: ट्रिप, गाड्या, ड्रायव्हर, कागदपत्रे, इंधन आणि हिशोब. सेटिंग्ज पाहू शकतो पण बदलू शकत नाही.';

  @override
  String get roleDriverCan =>
      'ड्रायव्हर ॲपमध्ये स्वतःच्या ट्रिप, इंधन फिल, खर्च आणि कागदपत्रे.';

  @override
  String settingsRange({required String min, required String max}) {
    return '$min ते $max मधील नंबर टाका.';
  }

  @override
  String get settingsDaysInvalid =>
      '0 ते 365 मधील जास्तीत जास्त 5 पूर्ण संख्या, उदा. 30, 7, 1.';

  @override
  String get placesCredit =>
      'Powered by Geoapify · © OpenStreetMap contributors';

  @override
  String get pickSourceTitle => 'कुठून अपलोड करायचे';

  @override
  String get pickFromPhotos => 'फोटो गॅलरी';

  @override
  String get pickFromFiles => 'फाइल्स (PDF किंवा फोटो)';
}
