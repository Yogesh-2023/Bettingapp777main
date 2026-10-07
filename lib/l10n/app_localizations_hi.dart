// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get chooseLanguage => 'भाषा चुने';

  @override
  String get skip => 'छोड़ें';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get bengali => 'Bengali';

  @override
  String get marathi => 'Marathi';

  @override
  String get telugu => 'Telugu';

  @override
  String get tamil => 'Tamil';

  @override
  String get welcomeTo => 'स्वागत है';

  @override
  String get indiasBestSattaMatka =>
      'भारत की सर्वश्रेष्ठ सट्टा मटका एप्लिकेशन\nआपका स्वागत है !!!';

  @override
  String get phoneNumber => 'फोन नंबर';

  @override
  String get enterPhoneNumber => 'फोन नंबर दर्ज करें';

  @override
  String get next => 'आगे';

  @override
  String get trustedBy1LakhUsers => '1 लाख उपयोगकर्ताओं द्वारा भरोसेमंद';

  @override
  String get mobileNumberRequired => 'मोबाइल नंबर आवश्यक है';

  @override
  String get enterValid10DigitMobile =>
      'एक वैध 10 अंकों का मोबाइल नंबर दर्ज करें';

  @override
  String serverError(int statusCode) {
    return 'सर्वर त्रुटि: $statusCode';
  }

  @override
  String get requestTimedOut => 'अनुरोध समय समाप्त हो गया। इंटरनेट जांचें।';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया।';

  @override
  String get home => 'होम';

  @override
  String get myBids => 'मेरी बोलियां';

  @override
  String get mpin => 'एम-पिन';

  @override
  String get passbook => 'पासबुक';

  @override
  String get funds => 'फंड';

  @override
  String get videos => 'वीडियो';

  @override
  String get gameRates => 'गेम दरें';

  @override
  String get charts => 'चार्ट';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get shareApplication => 'ऐप साझा करें';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get kingStarline => 'किंग स्टारलाइन';

  @override
  String get kingJackpot => 'किंग जैकपॉट';

  @override
  String get playGame => 'गेम खेलें';

  @override
  String get openBid => 'खुली बोली';

  @override
  String get bettingIsRunning => 'बेटिंग चल रही है';

  @override
  String get closeBid => 'बंद बोली';

  @override
  String get marketClosed => 'बाजार बंद';

  @override
  String get openBids => 'खुली बोलियां:';

  @override
  String get closeBids => 'बंद बोलियां:';

  @override
  String get errorLoadingData => 'डेटा लोड करने में त्रुटि।';

  @override
  String get noGameDataAvailable => 'कोई गेम डेटा उपलब्ध नहीं है।';

  @override
  String get notificationSettings => 'सूचना सेटिंग्स';

  @override
  String get mainNotification => 'मुख्य सूचना';

  @override
  String get gameNotification => 'गेम सूचना';

  @override
  String get kingStarlineNotification => 'किंग स्टारलाइन सूचना';

  @override
  String get kingJackpotNotification => 'किंग जैकपॉट सूचना';

  @override
  String get languageSettings => 'भाषा सेटिंग्स';

  @override
  String get ok => 'ठीक है';

  @override
  String get closedForToday => 'आज के लिए बंद';

  @override
  String get openBidLastTime => 'खुली बोली अंतिम समय';

  @override
  String get openResultTime => 'खुला परिणाम समय';

  @override
  String get closeBidLastTime => 'बंद बोली अंतिम समय';

  @override
  String get closeResultTime => 'बंद परिणाम समय';

  @override
  String get goodLuck => 'शुभकामनाएं';

  @override
  String get bidsPlacedSuccessfully => 'बोलियां सफलतापूर्वक रखी गईं';

  @override
  String get bidPlacementFailed => 'बोली रखने में विफल!';

  @override
  String get pleaseTryAgain => 'कृपया पुनः प्रयास करें।';

  @override
  String get dismiss => 'खारिज करें';

  @override
  String marketClosedMessage(String gameName) {
    return '$gameName बाजार बंद है।';
  }

  @override
  String get noBidsAdded => 'कोई बोली नहीं जोड़ी गई';

  @override
  String get noDataAddedYet => 'अभी तक कोई डेटा नहीं जोड़ा गया';

  @override
  String get submit => 'सबमिट करें';

  @override
  String get odd => 'विषम';

  @override
  String get even => 'सम';

  @override
  String get gameType => 'गेम प्रकार';

  @override
  String get digit => 'अंक';

  @override
  String get points => 'अंक';

  @override
  String get bidId => 'बोली आईडी';

  @override
  String get bidDate => 'बोली तारीख';

  @override
  String get noEntriesFound => 'कोई प्रविष्टि नहीं मिली।';

  @override
  String get noChartDataFound => 'कोई चार्ट डेटा नहीं मिला।';

  @override
  String error(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get noResultsForThisDate => 'इस तारीख के लिए कोई परिणाम नहीं।';

  @override
  String bids(Object count) {
    return 'बोलियां: $count';
  }

  @override
  String total(Object amount) {
    return 'कुल: ₹$amount';
  }

  @override
  String get profilePage => 'प्रोफ़ाइल पेज';

  @override
  String get historyPage => 'इतिहास पेज';

  @override
  String get youCanViewYourMarketBidHistory =>
      'आप अपना मार्केट बोली इतिहास देख सकते हैं';

  @override
  String get youCanViewYourStarlineBidHistory =>
      'आप अपना स्टारलाइन बोली इतिहास देख सकते हैं';

  @override
  String get youCanViewYourJackpotBidHistory =>
      'आप अपना जैकपॉट बोली इतिहास देख सकते हैं';

  @override
  String permissionGranted(String permission) {
    return '$permission अनुमति प्रदान की गई!';
  }

  @override
  String get whatsappNumberNotFound => 'WhatsApp नंबर नहीं मिला।';

  @override
  String get couldNotOpenWhatsapp =>
      'WhatsApp खोल नहीं सके। कृपया ऐप इंस्टॉल करें।';

  @override
  String get noVideosAvailable => 'इस भाषा के लिए कोई वीडियो उपलब्ध नहीं है';

  @override
  String get noAppFoundToOpenLink => 'इस लिंक को खोलने के लिए कोई ऐप नहीं मिला';

  @override
  String get cannotHandleLink => 'इस लिंक को संभाल नहीं सकते';

  @override
  String get screenshotSavedToGallery => 'स्क्रीनशॉट गैलरी में सहेजा गया';

  @override
  String get failedToSaveScreenshot => 'स्क्रीनशॉट सहेजने में विफल';

  @override
  String get qrPayment => 'QR भुगतान';

  @override
  String get saveQrToGallery => 'QR को गैलरी में सहेजें';

  @override
  String get noDepositHistoryFound => 'कोई जमा इतिहास नहीं मिला';

  @override
  String get noWithdrawHistoryFound => 'कोई निकासी इतिहास नहीं मिला।';

  @override
  String get registerIdMissing =>
      'रजिस्टर आईडी गुम है। कृपया फिर से लॉग इन करें।';

  @override
  String get accessTokenNotFound =>
      'Access token not found. Please log in again.';

  @override
  String get registerIdNotFound =>
      'Register ID not found. Please log in again.';

  @override
  String get noBidsYet => 'अभी तक कोई बोली नहीं';

  @override
  String get halfSangamB => 'हाफ संगम बी';

  @override
  String get screenNotFound => 'त्रुटि: स्क्रीन नहीं मिली';

  @override
  String get wallet => 'वॉलेट';

  @override
  String get chat => 'चैट';

  @override
  String get enterValid3To7DigitNumber => 'वैध 3-7 अंकों की संख्या दर्ज करें';

  @override
  String get numberMustHaveAtLeast2UniqueDigits =>
      'संख्या में कम से कम 2 अद्वितीय अंक होने चाहिए';

  @override
  String get enterValid3DigitNumber => 'एक वैध 3 अंकों की संख्या दर्ज करें।';

  @override
  String get invalidTriplePannaNumber => 'अमान्य ट्रिपल पन्ना संख्या।';

  @override
  String get pleaseEnterValid3DigitOpenPanna =>
      'कृपया एक वैध 3 अंकों का खुला पन्ना दर्ज करें।';

  @override
  String get pleaseEnterValid3DigitClosePanna =>
      'कृपया एक वैध 3 अंकों का बंद पन्ना दर्ज करें।';

  @override
  String pointsMustBeBetween(int min) {
    return 'अंक $min और 1000 के बीच होने चाहिए।';
  }

  @override
  String get openDigitEkHiHonaChahiye => 'खुला अंक एक ही होना चाहिए (0-9)।';

  @override
  String get openDigit0Se9KeBeechDo => 'खुला अंक 0 से 9 के बीच दें।';

  @override
  String get valid3DigitPannaDo => 'वैध 3 अंकों का पन्ना दें (जैसे 123)।';

  @override
  String pointsMinSe1000KeBeechDo(int min) {
    return 'अंक $min से 1000 के बीच दें।';
  }

  @override
  String get paymentFailed => 'भुगतान विफल';

  @override
  String get whatsappNumberNotAvailable => 'WhatsApp नंबर उपलब्ध नहीं है';

  @override
  String get errorLaunchingWhatsapp => 'WhatsApp लॉन्च करने में त्रुटि';

  @override
  String get mobileNumberNotAvailable => 'मोबाइल नंबर उपलब्ध नहीं है';

  @override
  String get checkOutSara777App => 'Sara 777 ऐप देखें!';

  @override
  String get imLovingSara777App =>
      'मुझे Sara 777 ऐप पसंद है\n\nअभी ऐप डाउनलोड करें\n\nसे:-\nhttps://admin.sara777.app';

  @override
  String get open => 'खुला';

  @override
  String get close => 'बंद';

  @override
  String get session => 'सत्र';

  @override
  String get remove => 'हटाएं';

  @override
  String get add => 'जोड़ें';

  @override
  String get clear => 'साफ करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get pleaseWait => 'कृपया प्रतीक्षा करें...';

  @override
  String get success => 'सफल';

  @override
  String get failed => 'विफल';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get back => 'वापस';

  @override
  String get nextPage => 'अगला';

  @override
  String get previous => 'पिछला';

  @override
  String get search => 'खोजें';

  @override
  String get filter => 'फ़िल्टर';

  @override
  String get sort => 'क्रमबद्ध करें';

  @override
  String get refresh => 'रिफ्रेश करें';

  @override
  String get noInternetConnection => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get insufficientBalance => 'अपर्याप्त शेष राशि';

  @override
  String get invalidInput => 'अमान्य इनपुट';

  @override
  String get selectGameType => 'गेम प्रकार चुनें';

  @override
  String get selectDigit => 'अंक चुनें';

  @override
  String get enterPoints => 'अंक दर्ज करें:';

  @override
  String get totalPoints => 'कुल अंक';

  @override
  String get totalAmount => 'कुल राशि';

  @override
  String get walletBalanceBeforeDeduction => 'कटौती से पहले वॉलेट बैलेंस';

  @override
  String get walletBalanceAfterDeduction => 'कटौती के बाद वॉलेट बैलेंस';

  @override
  String get noteBidOncePlayedWillNotBeCancelled =>
      '*नोट: एक बार खेली गई बोली रद्द नहीं की जाएगी';

  @override
  String get confirmBid => 'बोली की पुष्टि करें';

  @override
  String get bidDetails => 'बोली विवरण';

  @override
  String get gameName => 'गेम का नाम';

  @override
  String get date => 'तारीख';

  @override
  String get time => 'समय';

  @override
  String get status => 'स्थिति';

  @override
  String get amount => 'राशि';

  @override
  String get result => 'परिणाम';

  @override
  String get win => 'जीत';

  @override
  String get loss => 'हार';

  @override
  String get pending => 'लंबित';

  @override
  String get completed => 'पूर्ण';

  @override
  String get enterOpenPanna => 'खुली पन्ना दर्ज करें :';

  @override
  String get enterClosePanna => 'बंद पन्ना दर्ज करें :';

  @override
  String get sangam => 'संगम';

  @override
  String get bid => 'Bid';

  @override
  String get pleaseAddAtLeastOneBid => 'Please add at least one bid.';

  @override
  String get insufficientWalletBalanceToPlaceBid =>
      'इस बोली को रखने के लिए अपर्याप्त वॉलेट बैलेंस।';

  @override
  String updatedPointsFor(String sangam) {
    return '$sangam के लिए अंक अपडेट किए गए।';
  }

  @override
  String addedBidWithPoints(String sangam, String points) {
    return 'बोली जोड़ी: $sangam $points अंकों के साथ।';
  }

  @override
  String bidRemovedFromList(String sangam) {
    return 'सूची से $sangam के लिए बोली हटाई गई।';
  }

  @override
  String get screenNotMounted => 'स्क्रीन माउंट नहीं है।';

  @override
  String get authenticationErrorPleaseLoginAgain =>
      'प्रमाणीकरण त्रुटि: कृपया फिर से लॉगिन करें।';

  @override
  String get noValidBidsToSubmit => 'सबमिट करने के लिए कोई वैध बोली नहीं।';

  @override
  String unexpectedErrorOccurred(String error) {
    return 'एक अप्रत्याशित त्रुटि हुई: $error';
  }

  @override
  String get ank => 'अंक';

  @override
  String get pana => 'पन्ना';

  @override
  String get addBid => 'बोली जोड़ें';

  @override
  String get pannaAnk => 'पन्ना - अंक';

  @override
  String get pannaDigit => 'पन्ना - अंक';

  @override
  String get type => 'Type';

  @override
  String get halfSangamA => 'हाफ संगम ए';

  @override
  String get noBidsAddedYet => 'अभी तक कोई बोली नहीं जोड़ी गई';

  @override
  String get noBidsPlaced => 'कोई बोली नहीं रखी गई';

  @override
  String get ankOneDigitRequired => 'Ank 1 digit ka do (0–9).';

  @override
  String get ankBetween0And9 => 'Ank 0 se 9 ke beech do.';

  @override
  String get addingThisWillExceedWalletBalance =>
      'इतना जोड़ने से कुल वॉलेट से अधिक हो जाएगा।';

  @override
  String updatedAnkPanna(String ank, String panna) {
    return 'अपडेट किया: $ank-$panna।';
  }

  @override
  String addedAnkPannaWithPoints(String ank, String panna, String pts) {
    return 'जोड़ा: $ank-$panna — $pts अंक।';
  }

  @override
  String removedAnkPanna(String ank, String panna) {
    return 'हटाया गया: $ank-$panna।';
  }

  @override
  String get pleaseAddAtLeastOneBidFirst => 'Pehle kam se kam 1 bid add karo.';

  @override
  String get walletBalanceLow => 'Wallet balance is low.';

  @override
  String get authIssuePleaseLoginAgain =>
      'प्रमाणीकरण समस्या — कृपया फिर से लॉगिन करें।';

  @override
  String get enterOpenDigit => 'खुला अंक दर्ज करें :';

  @override
  String removedSangam(String sangam) {
    return '$sangam हटाया गया।';
  }

  @override
  String get enterAmount => 'राशि दर्ज करें';

  @override
  String get insufficientWalletBalance => 'अपर्याप्त वॉलेट बैलेंस।';

  @override
  String get noBidsToSubmit => 'No bids to submit.';

  @override
  String get noPanasReturnedForDigit => 'No panas returned for this digit.';

  @override
  String bidsForDigitAdded(int count, String digit) {
    return '$count bids for digit $digit added!';
  }

  @override
  String get failedToAddBulkBids => 'Failed to add bulk bids.';

  @override
  String networkError(String error) {
    return 'Network error: $error';
  }

  @override
  String bidForPanaRemoved(String pana) {
    return 'Bid for Pana $pana removed.';
  }

  @override
  String get someOrAllBidsFailed =>
      'Some or all bids failed to submit. Please try again.';

  @override
  String get allBidsSubmittedSuccessfully => 'All bids submitted successfully!';

  @override
  String get noBidsPlacedYetTapNumber => 'No bids placed yet. Tap a number!';

  @override
  String get bidsLabel => 'बोलियां';

  @override
  String get enterValidDoublePana =>
      'Enter a valid Double Pana (3-digit) number.';

  @override
  String updatedDigitSession(String digit, String session) {
    return 'Updated: $digit ($session)';
  }

  @override
  String addedDigitSession(String digit, String session) {
    return 'Added: $digit ($session)';
  }

  @override
  String removedDigitSession(String digit, String session) {
    return 'हटाया गया: $digit ($session)';
  }

  @override
  String removedDigit(String digit) {
    return 'हटाया गया: $digit';
  }

  @override
  String get noEntriesYetAddData => 'No entries yet. Add some data!';

  @override
  String get enter3DigitNumber => '3-अंकीय संख्या दर्ज करें';

  @override
  String get enter3DigitNumberColon => '3-अंकीय संख्या दर्ज करें:';

  @override
  String get gameTypeLabel => 'Game Type';

  @override
  String get amountLabel => 'Amount';

  @override
  String get pointsLabel => 'अंक';

  @override
  String get pleaseSelectOddOrEven => 'Please select Odd or Even.';

  @override
  String addedGroupSession(String group, String session, String digits) {
    return 'Added $group ($session): $digits';
  }

  @override
  String removedDigitType(String digit, String type) {
    return 'Removed $digit ($type).';
  }

  @override
  String get noBidAddedYet => 'No bid added yet';

  @override
  String get biddingIsClosedForSlot => 'Bidding is closed for this slot.';

  @override
  String get pleaseEnterValidSingleDigit =>
      'कृपया एक वैध एकल अंक (0-9) दर्ज करें।';

  @override
  String get pleaseEnterAnAmount => 'Please enter an amount.';

  @override
  String get amountMustBeNumber => 'Amount must be a number.';

  @override
  String amountMustBeBetween(int min, int max) {
    return 'राशि $min और $max के बीच होनी चाहिए।';
  }

  @override
  String get insufficientWalletBalanceToPlaceBids =>
      'इन बोलियों को रखने के लिए अपर्याप्त वॉलेट बैलेंस।';

  @override
  String updatedDigitAmount(String digit, int points) {
    return 'Updated digit $digit amount to $points.';
  }

  @override
  String addedBidDigitAmount(String digit, int points) {
    return 'Added bid: Digit $digit, Amount $points.';
  }

  @override
  String removedBidDigit(String digit) {
    return 'Removed bid: Digit $digit.';
  }

  @override
  String get pleaseAddAtLeastOneBidBeforeSubmitting =>
      'सबमिट करने से पहले कृपया कम से कम एक बोली जोड़ें।';

  @override
  String get insufficientWalletBalanceToSubmit =>
      'Insufficient wallet balance to submit.';

  @override
  String get bidPlacedSuccessfully => 'Bid placed successfully!';

  @override
  String get unknownErrorOccurred => 'एक अज्ञात त्रुटि हुई।';

  @override
  String get entersSingleDigit => 'Enters Single Digit:';

  @override
  String get enterDigit => 'Enter Digit';

  @override
  String get points10To1000KeBeechDo => 'Points 10–1000 ke beech do.';

  @override
  String bidTypeBidAdded(String bidType) {
    return '$bidType bid added!';
  }

  @override
  String get entryDeleted => 'Entry deleted.';

  @override
  String get pehleKoiEntryAddKaro => 'Pehle koi entry add karo.';

  @override
  String removeThisBidTypeSet(String bidType) {
    return 'Remove this $bidType set';
  }

  @override
  String get enterJodi => 'जोड़ी दर्ज करें:';

  @override
  String get enterJodiHint => 'जोड़ी दर्ज करें';

  @override
  String get pleaseEnterValid2DigitJodi => 'Please enter a valid 2-digit Jodi.';

  @override
  String jodiAlreadyExists(String jodi) {
    return 'Jodi $jodi already exists.';
  }

  @override
  String addedJodi(String jodi) {
    return 'Added: $jodi';
  }

  @override
  String bidForJodiRemoved(String jodi) {
    return 'Bid for Jodi $jodi removed.';
  }

  @override
  String get pleaseWaitBidSubmissionInProgress =>
      'कृपया प्रतीक्षा करें, बोली सबमिशन प्रगति में है।';

  @override
  String get jodiDigitMustBeExactly2Numbers =>
      'जोड़ी अंक बिल्कुल 2 संख्याएं होनी चाहिए (00-99)।';

  @override
  String get jodiMustBeNumberBetween00And99 =>
      'जोड़ी 00 और 99 के बीच एक संख्या होनी चाहिए।';

  @override
  String get pleaseEnterValidPoints => 'कृपया वैध अंक दर्ज करें।';

  @override
  String get pointsMustBeBetween10And10000 =>
      'अंक 10 और 10000 के बीच होने चाहिए।';

  @override
  String get insufficientWalletBalanceForThisBid =>
      'इस बोली के लिए अपर्याप्त वॉलेट बैलेंस।';

  @override
  String jodiWithPointsAdded(String digit, String points) {
    return 'जोड़ी $digit $points अंकों के साथ जोड़ी गई।';
  }

  @override
  String jodiPointsUpdatedTo(String digit, String points) {
    return 'जोड़ी $digit अंक $points में अपडेट किए गए।';
  }

  @override
  String get cannotRemoveBidWhileSubmissionInProgress =>
      'सबमिशन प्रगति में होने पर बोली नहीं हटा सकते।';

  @override
  String jodiRemoved(String digit) {
    return 'जोड़ी $digit हटाई गई।';
  }

  @override
  String get submittingYourBids => 'आपकी बोलियां सबमिट की जा रही हैं...';

  @override
  String get bidFailedPleaseTryAgain => 'बोली विफल। कृपया पुनः प्रयास करें।';

  @override
  String networkErrorOrUnexpectedIssue(String error) {
    return 'नेटवर्क त्रुटि या अप्रत्याशित समस्या: $error';
  }

  @override
  String get enterJodiDigit => 'जोड़ी अंक दर्ज करें:';

  @override
  String get bidDigits => 'बोली अंक';

  @override
  String get pleaseEnterValid3DigitNumber => 'Enter a valid 3-digit number.';

  @override
  String get noBidsAddedToSubmit => 'No bids added to submit.';

  @override
  String updatedBidForDigit(String digit) {
    return 'Updated bid for $digit.';
  }

  @override
  String addedBidDigitPoints(String digit, int points) {
    return 'Added bid: $digit - $points points';
  }

  @override
  String removedBidDigitOnly(String digit) {
    return 'Removed bid: $digit';
  }

  @override
  String get enter3DigitTriplePanna => '3-अंकीय ट्रिपल पन्ना दर्ज करें';

  @override
  String get enter3DigitTriplePannaColon => 'Enter 3-Digit Triple Panna:';

  @override
  String get pleaseSelectSPDPOrTP => 'कृपया SP, DP, या TP चुनें।';

  @override
  String get digitMustBeNumber0To9 => 'अंक 0 से 9 तक की संख्या होनी चाहिए।';

  @override
  String addedBidsForCategory(int count, String category) {
    return '$count बोलियां $category के लिए जोड़ी गईं।';
  }

  @override
  String get pleaseAddBidsBeforeSubmitting =>
      'सबमिट करने से पहले कृपया बोलियां जोड़ें।';

  @override
  String get pleaseEnterNumber => 'कृपया एक नंबर दर्ज करें।';

  @override
  String get pleaseEnterValidNumber => 'कृपया एक वैध नंबर (3-7 अंक) दर्ज करें।';

  @override
  String get numberMustContainTwoUniqueDigits =>
      'नंबर में कम से कम दो अद्वितीय अंक होने चाहिए।';

  @override
  String get noValidBidsFound => 'इस नंबर के लिए कोई वैध बोली नहीं मिली।';

  @override
  String addedBidsFromApiResponse(int count) {
    return 'Added $count bids from API response.';
  }

  @override
  String get allBidsAlreadyExist => 'सभी बोलियां पहले से मौजूद हैं।';

  @override
  String bidRequestFailed(int statusCode) {
    return 'Bid request failed with status: $statusCode';
  }

  @override
  String removedBidNumberType(String number, String type) {
    return 'Removed bid: Number $number, Type $type.';
  }

  @override
  String get noBidsAddedForSelectedGameType =>
      'No bids added for the selected game type to submit.';

  @override
  String get insufficientWalletBalanceForSelectedGameType =>
      'Insufficient wallet balance for selected game type.';

  @override
  String get noValidBidsForSelectedGameType =>
      'चयनित गेम प्रकार के लिए कोई वैध बोली नहीं।';

  @override
  String get enterNumber => 'नंबर दर्ज करें:';

  @override
  String get enterNumberHint => 'नंबर दर्ज करें';

  @override
  String get count => 'Count';

  @override
  String get walletBalanceKamHai => 'Wallet balance is low.';

  @override
  String get enterSinglePanaHint => 'Enter Single Pana';

  @override
  String get bidTime => 'बोली समय :';

  @override
  String get bidResultTime => 'बोली परिणाम समय :';

  @override
  String get paymentSuccess => 'भुगतान सफल';

  @override
  String get done => 'पूर्ण';

  @override
  String get accountRecovery => 'खाता पुनर्प्राप्ति';

  @override
  String get accountRecoveryMessage =>
      'एक नया MPIN सेट करके अपने मौजूदा खाते को पुनर्प्राप्त करें\n\nक्या आप जारी रखना चाहते हैं?';

  @override
  String get recover => 'पुनर्प्राप्त करें';

  @override
  String get walletFundHistoryNotAvailable => 'वॉलेट फंड इतिहास उपलब्ध नहीं है';

  @override
  String get termsAndConditions => 'नियम और शर्तें';

  @override
  String get minimumWithdrawAmount => 'न्यूनतम निकासी राशि 1000 ₹ है';

  @override
  String get maximumWithdrawAmount => 'और अधिकतम निकासी राशि 500000 है';

  @override
  String get above5LakhManualRequest =>
      '5 लाख से अधिक पर आपको हमसे मैन्युअल रूप से अनुरोध करना चाहिए।';

  @override
  String get withdrawRequestTiming =>
      'निकासी अनुरोध समय सुबह 09:00 से रात 10:00 तक';

  @override
  String get processTime => 'प्रसंस्करण समय न्यूनतम 1 घंटा अधिकतम 72 घंटे।';

  @override
  String get withdrawAvailableAllDays =>
      'निकासी सप्ताह के सभी 7 दिनों में उपलब्ध है।';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get addFund => 'फंड जोड़ें';

  @override
  String get addMoney => 'पैसा जोड़ें';

  @override
  String get availableBalance => 'उपलब्ध शेष राशि';

  @override
  String get addPointUpi => 'पॉइंट जोड़ें - UPI';

  @override
  String get addPointQrPaytmGateway => 'पॉइंट जोड़ें - QR - PAYTM - GATEWAY';

  @override
  String get howToAddPoint => 'पॉइंट कैसे जोड़ें';

  @override
  String get pleaseContactSupportToKnowHowToAddPoint =>
      'पॉइंट जोड़ने का तरीका जानने के लिए कृपया सपोर्ट से संपर्क करें।';

  @override
  String get selectUpiApp => 'UPI ऐप चुनें';

  @override
  String get upiApp => 'UPI ऐप';

  @override
  String get addFunds => 'फंड जोड़ें';

  @override
  String get upiPayeeDetailsNotConfigured =>
      'UPI प्राप्तकर्ता विवरण कॉन्फ़िगर नहीं किया गया है।';

  @override
  String get invalidUpiIdFormat => 'अमान्य UPI ID प्रारूप';

  @override
  String pleaseEnterValidAmountMin(String amount) {
    return 'कृपया एक वैध राशि दर्ज करें (न्यूनतम ₹$amount)।';
  }

  @override
  String get noUpiAppsFound =>
      'कोई UPI ऐप नहीं मिला। कृपया आगे बढ़ने के लिए एक UPI ऐप इंस्टॉल करें।';

  @override
  String get paymentFailedOrCancelled => 'भुगतान विफल या रद्द कर दिया गया।';

  @override
  String errorOccurredDuringUpiPayment(String error) {
    return 'UPI भुगतान के दौरान एक त्रुटि हुई: $error';
  }

  @override
  String get rangeErrorOccurredDuringUpiPayment =>
      'UPI भुगतान के दौरान RangeError हुआ। कृपया पुनः प्रयास करें।';

  @override
  String get failedToLaunchUpiApp =>
      'अप्रत्याशित त्रुटि के कारण UPI ऐप लॉन्च करने में विफल।';

  @override
  String get invalidServerResponse =>
      'अमान्य सर्वर प्रतिक्रिया (paymentHash/timestamp गुम है)।';

  @override
  String get depositSuccessfulAndUpdated => 'जमा सफल और अपडेट किया गया';

  @override
  String get failedToAddDepositFund => 'जमा फंड जोड़ने में विफल';

  @override
  String failedToCreateFundRequest(int code) {
    return 'फंड अनुरोध बनाने में विफल (HTTP $code)';
  }

  @override
  String failedToCompletePaymentProcess(String error) {
    return 'भुगतान प्रक्रिया पूरी करने में विफल: $error';
  }

  @override
  String get pleaseEnterValidAmount => 'कृपया एक वैध राशि दर्ज करें।';

  @override
  String pleaseEnterAmountGreaterThanOrEqual(int amount) {
    return 'कृपया ₹$amount से अधिक या उसके बराबर राशि दर्ज करें।';
  }

  @override
  String get invalidMobileNumberFound => 'अमान्य मोबाइल नंबर मिला।';

  @override
  String get paymentLinkNotFoundInResponse =>
      'प्रतिक्रिया में भुगतान लिंक नहीं मिला।';

  @override
  String get failedToCreateTransactionLink => 'लेनदेन लिंक बनाने में विफल।';

  @override
  String get bankDetails => 'बैंक विवरण';

  @override
  String get accountHolderName => 'खाता धारक का नाम';

  @override
  String get accountNumber => 'खाता संख्या';

  @override
  String get enterAccountNumber => 'खाता संख्या दर्ज करें';

  @override
  String get ifscCode => 'IFSC कोड';

  @override
  String get bankName => 'बैंक का नाम';

  @override
  String get enterBankName => 'बैंक का नाम दर्ज करें';

  @override
  String get branchName => 'शाखा का नाम';

  @override
  String get enterBranchName => 'शाखा का नाम दर्ज करें';

  @override
  String get addBank => 'बैंक जोड़ें';

  @override
  String get fundDepositHistory => 'फंड जमा इतिहास';

  @override
  String get narration => 'विवरण';

  @override
  String get withdrawFunds => 'निकासी फंड';

  @override
  String get depositHistory => 'जमा इतिहास';

  @override
  String get withdrawHistory => 'निकासी इतिहास';

  @override
  String get fundWithdrawHistory => 'फंड निकासी इतिहास';

  @override
  String get withdrawMode => 'निकासी मोड';

  @override
  String get upiId => 'UPI ID';

  @override
  String get acHolder => 'खाता धारक';

  @override
  String get acNo => 'खाता नं.';

  @override
  String get manualApproveByAdmin => 'एडमिन द्वारा मैन्युअल अनुमोदन';

  @override
  String get enterGooglePayUpiId => 'Google Pay UPI ID दर्ज करें';

  @override
  String get enterPhonepeUpiId => 'PhonePe UPI ID दर्ज करें';

  @override
  String get enterPaytmNumber => 'Paytm नंबर दर्ज करें';

  @override
  String get enterUpiIdNumber => 'UPI ID/नंबर दर्ज करें';

  @override
  String get pleaseLoginAgainToContinue =>
      'कृपया जारी रखने के लिए फिर से लॉगिन करें।';

  @override
  String minimumWithdrawalAmountIs(int amount) {
    return 'न्यूनतम निकासी राशि ₹$amount है।';
  }

  @override
  String get pleaseEnterGooglePayUpiId => 'कृपया Google Pay UPI ID दर्ज करें।';

  @override
  String get pleaseEnterPhonepeUpiId => 'कृपया PhonePe UPI ID दर्ज करें।';

  @override
  String get pleaseEnterPaytmNumber => 'कृपया Paytm नंबर दर्ज करें।';

  @override
  String get pleaseFillAllBankDetails => 'कृपया सभी बैंक विवरण भरें।';

  @override
  String get pleaseSelectWithdrawalMethod => 'कृपया निकासी विधि चुनें।';

  @override
  String get withdrawalRequestSubmittedSuccessfully =>
      'निकासी अनुरोध सफलतापूर्वक सबमिट किया गया!';

  @override
  String get withdrawalRequestFailed => 'निकासी अनुरोध विफल।';

  @override
  String anErrorOccurred(String error) {
    return 'एक त्रुटि हुई: $error';
  }

  @override
  String get jackpotDashboard => 'जैकपॉट डैशबोर्ड';

  @override
  String get history => 'इतिहास';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get jodi => 'जोड़ी';

  @override
  String get closed => 'बंद';

  @override
  String get running => 'चल रहा है';

  @override
  String get noJackpotBidTypesAvailable =>
      'कोई जैकपॉट बिड प्रकार उपलब्ध नहीं है या लोड करने में विफल।';

  @override
  String get theMarketFor => 'के लिए बाजार';

  @override
  String get isCurrentlyClosed => 'वर्तमान में बंद है।';

  @override
  String get failedToLoadJackpotBidTypes =>
      'जैकपॉट बिड प्रकार लोड करने में विफल:';

  @override
  String get noScreenConfiguredForGameType =>
      'गेम प्रकार के लिए कोई स्क्रीन कॉन्फ़िगर नहीं की गई:';

  @override
  String get networkErrorPleaseTryAgainLater =>
      'नेटवर्क त्रुटि। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get failedToLoadGames => 'गेम लोड करने में विफल';

  @override
  String get singleDigit => 'सिंगल डिजिट';

  @override
  String get singlePana => 'सिंगल पाना';

  @override
  String get doublePana => 'डबल पाना';

  @override
  String get triplePana => 'ट्रिपल पाना';

  @override
  String get choiceSpDpTp => 'चॉइस SP DP TP';

  @override
  String get spMotor => 'SP मोटर';

  @override
  String get dpMotor => 'DP मोटर';

  @override
  String get tpMotor => 'TP मोटर';

  @override
  String get fullSangam => 'फुल संगम';

  @override
  String get halfSangam => 'हाफ संगम';

  @override
  String get singleDigitsBulk => 'सिंगल डिजिट बल्क';

  @override
  String get jodiBulk => 'जोड़ी बल्क';

  @override
  String get singlePanaBulk => 'सिंगल पाना बल्क';

  @override
  String get doublePanaBulk => 'डबल पाना बल्क';

  @override
  String get twoDigitPanel => 'Two Digit Panel';

  @override
  String get oddEven => 'Odd Even';

  @override
  String get digitBasedJodi => 'Digit Based Jodi';

  @override
  String get panelGroup => 'Panel Group';

  @override
  String get redBracket => 'Red Bracket';

  @override
  String get groupJodi => 'Group Jodi';

  @override
  String get mainStarlineDashboard => 'MAIN STARLINE DASHBOARD';

  @override
  String get notification => 'Notification';

  @override
  String get runningNow => 'Running Now';

  @override
  String bidClosedAt(String closeTime) {
    return 'Bid closed at $closeTime';
  }

  @override
  String get failedToLoadGameData => 'Failed to load game data.';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get enterYourDetails => 'अपनी जानकारी दर्ज करें';

  @override
  String get enterUsername => 'उपयोगकर्ता नाम दर्ज करें';

  @override
  String get enterPassword => 'पासवर्ड दर्ज करें';

  @override
  String get confirmPassword => 'पासवर्ड पुष्टि करें';

  @override
  String get pleaseEnterUsername => 'कृपया उपयोगकर्ता नाम दर्ज करें';

  @override
  String get pleaseEnterPassword => 'कृपया पासवर्ड दर्ज करें';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'पासवर्ड कम से कम 6 वर्णों का होना चाहिए';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get verifyMobileNumber => 'मोबाइल नंबर\nसत्यापित करें';

  @override
  String get enterPasswordLabel => 'पासवर्ड दर्ज करें';

  @override
  String get toCompleteRegistrationFor => 'पंजीकरण पूरा करने के लिए\n';

  @override
  String get enterYourAccountPassword => 'अपना खाता पासवर्ड दर्ज करें।';

  @override
  String get enterYourPassword => 'अपना पासवर्ड दर्ज करें';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get missingDataRestartRegistration =>
      'डेटा गायब है। पंजीकरण फिर से शुरू करें।';

  @override
  String get errorVerifyingPassword => 'पासवर्ड सत्यापित करने में त्रुटि';

  @override
  String get registrationFailed => 'पंजीकरण विफल';

  @override
  String get prev => 'पिछला';

  @override
  String get description => 'विवरण';

  @override
  String get prevAmt => 'पिछली राशि';

  @override
  String get txnAmt => 'लेन-देन राशि';

  @override
  String get curAmt => 'वर्तमान राशि';

  @override
  String get bidHistory => 'बोली इतिहास';

  @override
  String get noBidEntriesFound => 'कोई बोली प्रविष्टि नहीं मिली।';

  @override
  String get transactionTime => 'लेन-देन समय:';

  @override
  String get statusLabel => 'Status:';

  @override
  String get betterLuckNextTime => 'अगली बार अच्छी किस्मत';

  @override
  String get currentAmount => 'वर्तमान राशि';

  @override
  String get previousAmount => 'पिछली राशि';

  @override
  String get transactionAmount => 'लेन-देन राशि';

  @override
  String get quit => 'बाहर निकलें';

  @override
  String get areYouSureYouWantToQuitTheApp =>
      'क्या आप वाकई ऐप से बाहर निकलना चाहते हैं?';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get noNotificationsFound => 'कोई सूचना नहीं मिली।';

  @override
  String get pleaseEnterAnAmountFirst => 'कृपया पहले एक राशि दर्ज करें।';

  @override
  String get pointsMustBeBetween10And1000 =>
      'अंक 10 और 1000 के बीच होने चाहिए।';

  @override
  String bidForDigitUpdated(String digit, String type, String points) {
    return 'अंक $digit ($type) के लिए बोली $points अंकों में अपडेट की गई।';
  }

  @override
  String addedBidForDigit(String digit, String amount) {
    return 'अंक के लिए बोली जोड़ी: $digit, राशि: $amount';
  }

  @override
  String get noBidsPlacedYetClickNumber =>
      'अभी तक कोई बोली नहीं लगाई गई। बोली जोड़ने के लिए एक नंबर पर क्लिक करें!';

  @override
  String get bidsSubmittedSuccessfully => 'बोलियां सफलतापूर्वक सबमिट की गईं!';

  @override
  String removedBidForDigit(String digit, String amount) {
    return 'अंक के लिए बोली हटाई गई: $digit, राशि: $amount।';
  }

  @override
  String get selectGameTypeColon => 'गेम प्रकार चुनें:';

  @override
  String get enterPointsColon => 'अंक दर्ज करें:';

  @override
  String get loginWithMpin => 'MPIN के साथ लॉगिन करें';

  @override
  String get mpinHint => 'MPIN';

  @override
  String get login => 'लॉगिन';

  @override
  String get forgotMpin => 'MPIN भूल गए?';

  @override
  String get biometricAuthenticationNotAvailable =>
      'बायोमेट्रिक प्रमाणीकरण उपलब्ध नहीं है या समर्थित नहीं है';

  @override
  String get scanYourFingerprintToVerify =>
      'सत्यापित करने के लिए अपनी उंगली स्कैन करें';

  @override
  String get biometricAuthenticationFailed => 'बायोमेट्रिक प्रमाणीकरण विफल';

  @override
  String biometricError(String error) {
    return 'बायोमेट्रिक त्रुटि: $error';
  }

  @override
  String get pleaseEnterYourMpin => 'कृपया अपना MPIN दर्ज करें';

  @override
  String get registrationIdNotFoundPleaseReregister =>
      'रजिस्ट्रेशन ID नहीं मिला। कृपया फिर से पंजीकरण करें।';

  @override
  String get accessTokenNotFoundPleaseRelogin =>
      'एक्सेस टोकन नहीं मिला। कृपया फिर से लॉगिन करें।';

  @override
  String get loginSuccessful => 'लॉगिन सफल!';

  @override
  String get failedToVerifyMpinPleaseTryAgainLater =>
      'MPIN सत्यापित करने में विफल। कृपया बाद में पुनः प्रयास करें।';

  @override
  String errorOccurredDuringMpinVerification(String error) {
    return 'MPIN सत्यापन के दौरान एक त्रुटि हुई: $error';
  }

  @override
  String get invalidMpin => 'अमान्य MPIN';

  @override
  String get pleaseEnterCorrectMpin => 'कृपया सही MPIN दर्ज करें';

  @override
  String get setYourPin => 'अपना PIN सेट करें';

  @override
  String get enterNewMpin => 'नया mPin दर्ज करें';

  @override
  String get enter4DigitMpin => '4 अंकों का mPin दर्ज करें';

  @override
  String get setPin => 'PIN सेट करें';

  @override
  String get pleaseEnterValid4DigitPin =>
      'कृपया एक वैध 4 अंकों का PIN दर्ज करें';

  @override
  String somethingWentWrongWithError(String error) {
    return 'कुछ गलत हो गया: $error';
  }

  @override
  String get changeNewMpin => 'नया MPIN बदलें';

  @override
  String get enter4DigitPin => '4 अंकों का PIN दर्ज करें';

  @override
  String errorWithPlaceholder(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String couldNotLaunchUrl(String url) {
    return 'URL लॉन्च नहीं कर सका: $url';
  }

  @override
  String get single => 'सिंगल';

  @override
  String get singlePanna => 'सिंगल पन्ना';

  @override
  String get doublePanna => 'डबल पन्ना';

  @override
  String get triplePanna => 'ट्रिपल पन्ना';

  @override
  String get gameWinRatioForAllBids => 'सभी बोलियों के लिए गेम जीत अनुपात';

  @override
  String get starlineWinRatioForAllBids =>
      'सभी बोलियों के लिए स्टारलाइन जीत अनुपात';

  @override
  String get jackpotWinRatio => 'जैकपॉट जीत अनुपात';

  @override
  String rateFormat(String label, String value) {
    return '$label: 10 का $value';
  }

  @override
  String failedToLoadGameRates(int statusCode) {
    return 'गेम दरें लोड करने में विफल: $statusCode';
  }

  @override
  String youCanWithdrawBetween(String startTime, String endTime) {
    return 'आप $startTime और $endTime के बीच निकासी कर सकते हैं।';
  }

  @override
  String bidForJodiAddedSuccessfully(String jodi) {
    return 'Jodi $jodi के लिए बोली सफलतापूर्वक जोड़ी गई!';
  }

  @override
  String get bidFailed => 'बोली विफल।';

  @override
  String get submitBid => 'बोली सबमिट करें';

  @override
  String totalBidsWithCount(int count) {
    return 'कुल बोलियां:\n$count';
  }

  @override
  String get pleaseEnterAtLeastOneThreeDigitPanaNumber =>
      'कृपया कम से कम एक 3-अंकीय पन्ना नंबर दर्ज करें।';

  @override
  String get enterPanaNumberColon => 'पन्ना नंबर दर्ज करें:';

  @override
  String invalidPanaWithDigit(String digit) {
    return 'असाधु पन्ना: $digit';
  }

  @override
  String get noValidPanasReturnedFromServer =>
      'सर्वर से कोई वैध पन्ना वापस नहीं आया।';

  @override
  String addedBidsCount(int count) {
    return '$count बोली(यां) जोड़ी गई।';
  }

  @override
  String removedPanaDigit(String digit) {
    return 'हटाया गया: $digit';
  }

  @override
  String get networkErrorCheckInternet =>
      'नेटवर्क त्रुटि। कृपया अपना इंटरनेट कनेक्शन जांचें।';

  @override
  String get enterPanaExampleHint => 'उदाहरण: 123, 445';

  @override
  String get amountMustBeBetween10And10000 =>
      'Amount must be between 10 and 10000.';

  @override
  String get bidsAdded => 'Bids added.';

  @override
  String get addFailed => 'Add failed';

  @override
  String get pleaseAddSomeBidsFirst => 'Please add some bids first.';

  @override
  String get half => 'आधा';

  @override
  String get full => 'पूर्ण';

  @override
  String get bidsColon => 'Bids:';

  @override
  String get totalColon => 'कुल:';

  @override
  String get placeBidFailed => 'बोली रखने में विफल';

  @override
  String get pleaseEnterValidNumberMinimum3Digits =>
      'Please enter a valid number (minimum 3 digits).';

  @override
  String get bidsAddedFromApi => 'API से बोलियां जोड़ी गईं।';

  @override
  String get requestFailed => 'अनुरोध विफल।';

  @override
  String get pleaseEnterAllThreeDigits => 'कृपया तीनों अंक दर्ज करें।';

  @override
  String get eachDigitMustBeSingleNumber =>
      'प्रत्येक अंक एक एकल संख्या (0-9) होनी चाहिए।';

  @override
  String get pleaseSelectSPDPTP => 'कृपया SP, DP या TP चुनें।';

  @override
  String get pleaseSelectOpenClose => 'कृपया OPEN/CLOSE चुनें।';

  @override
  String get spMustHave3UniqueDigits => 'SP में 3 अद्वितीय अंक होने चाहिए।';

  @override
  String get dpMustHaveExactlyTwoSameDigits =>
      'DP में बिल्कुल दो समान अंक होने चाहिए।';

  @override
  String get tpMustHaveAll3DigitsSame => 'TP में सभी 3 अंक समान होने चाहिए।';

  @override
  String updatedPannaCategorySession(
    String panna,
    String category,
    String session,
  ) {
    return 'अपडेट किया: $panna ($category $session)';
  }

  @override
  String addedPannaCategorySession(
    String panna,
    String category,
    String session,
  ) {
    return 'जोड़ा गया: $panna ($category $session)';
  }

  @override
  String removedPannaCategorySession(
    String panna,
    String category,
    String session,
  ) {
    return 'हटाया गया: $panna ($category $session)';
  }

  @override
  String get enterLeftDigit => 'बायां अंक दर्ज करें';

  @override
  String get enterMiddleDigit => 'मध्य अंक दर्ज करें';

  @override
  String get enterRightDigit => 'दायां अंक दर्ज करें';

  @override
  String get panna => 'Panna';

  @override
  String get pleaseEnterValid2DigitJodi0099 =>
      'Please enter a valid 2-digit Jodi (00-99).';

  @override
  String get pointsMustBeAtLeast10 => 'Points must be at least 10.';

  @override
  String get jodisAddedSuccessfully => 'Jodis added successfully!';

  @override
  String removedJodi(String jodi) {
    return 'Removed $jodi.';
  }

  @override
  String get noEntriesYetAddSomeData => 'No entries yet. Add some data!';

  @override
  String get leftDigit => 'बायां अंक';

  @override
  String get rightDigit => 'दायां अंक';

  @override
  String get digits => 'अंक';

  @override
  String get twoDigitNumberDo0099 =>
      'Please enter a valid 2-digit number (00-99).';

  @override
  String get points10Se10000KeBechMeDo =>
      'Points must be between 10 and 10000.';

  @override
  String get authIssueDobaraLoginKaro =>
      'Authentication error. Please log in again.';

  @override
  String get is2DigitKeliyeKoiPanaNahiMila =>
      'No pana found for this 2-digit number.';

  @override
  String get walletMeItnePointsNahiHai => 'Insufficient wallet balance.';

  @override
  String panaAddHue(int count) {
    return '$count pana(s) added.';
  }

  @override
  String get amountsUpdateHoGaye => 'Amounts updated.';

  @override
  String get panaFetchFail => 'Failed to fetch pana.';

  @override
  String get networkErrorThodiDerBaadTryKaro =>
      'Network error. Please try again later.';

  @override
  String panaRemoveHoGaya(String pana) {
    return 'Pana $pana removed.';
  }

  @override
  String get submitSePehleKuchPanaAddKaro =>
      'Please add some pana before submitting.';

  @override
  String get twoDigitsPanel => 'Two Digits Panel';

  @override
  String get enterTwoDigits => 'दो अंक दर्ज करें:';

  @override
  String get sabBidsSuccessfullySubmitHoGaye =>
      'All bids submitted successfully!';

  @override
  String get bidSubmitFailHoGaya => 'Bid submission failed.';

  @override
  String get pleaseEnterAmount => 'Please enter an Amount.';

  @override
  String get unexpectedErrorDuringBidSubmission =>
      'बोली सबमिशन के दौरान एक अप्रत्याशित त्रुटि हुई।';

  @override
  String get enterSingleDigit => 'एकल अंक दर्ज करें:';

  @override
  String get enterSingleDigitHint => 'एकल अंक दर्ज करें';

  @override
  String get errorColon => 'त्रुटि:';

  @override
  String get points10To1000KeBechDo => 'Points must be between 10 and 1000.';

  @override
  String get easyMode => 'आसान मोड';

  @override
  String get specialMode => 'विशेष मोड';

  @override
  String get enterSinglePanna => 'सिंगल पन्ना दर्ज करें:';

  @override
  String get bidPanna => 'बोली पन्ना';

  @override
  String get totalPointsColon => 'कुल अंक:';

  @override
  String get biddingIsClosedForThisSlot => 'इस स्लॉट के लिए बोली बंद है।';

  @override
  String get pleaseFillAllFields => 'कृपया सभी फ़ील्ड भरें।';

  @override
  String get pleaseEnterValidSinglePanna =>
      'कृपया एक वैध सिंगल पन्ना नंबर दर्ज करें।';

  @override
  String get updatedAmountForPanna => 'पन्ना के लिए अपडेट की गई राशि:';

  @override
  String get addedBidPanna => 'बोली जोड़ी गई: पन्ना';

  @override
  String get pleaseAddAtLeastOneBidToConfirm =>
      'कृपया पुष्टि करने के लिए कम से कम एक बोली जोड़ें।';

  @override
  String get insufficientWalletBalanceForAllBids =>
      'सभी बोलियों के लिए अपर्याप्त वॉलेट बैलेंस।';

  @override
  String get and => 'और';

  @override
  String get enterYourMobileNumber => 'अपना मोबाइल नंबर दर्ज करें';

  @override
  String get registerAndLogin => 'रजिस्टर करें और लॉगिन करें';

  @override
  String get username => 'उपयोगकर्ता नाम';

  @override
  String get password => 'पासवर्ड';

  @override
  String get enterValidMobileNumber => 'वैध मोबाइल नंबर दर्ज करें';

  @override
  String get createNewAccount => 'नया खाता बनाएं';
}
