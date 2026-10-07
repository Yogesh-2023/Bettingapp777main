// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get chooseLanguage => 'भाषा निवडा';

  @override
  String get skip => 'वगळा';

  @override
  String get continueButton => 'सुरू ठेवा';

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
  String get welcomeTo => 'स्वागत आहे';

  @override
  String get indiasBestSattaMatka =>
      'भारताची सर्वोत्तम सट्टा मटका अॅप्लिकेशन\nआपले स्वागत आहे !!!';

  @override
  String get phoneNumber => 'फोन नंबर';

  @override
  String get enterPhoneNumber => 'फोन नंबर प्रविष्ट करा';

  @override
  String get next => 'पुढे';

  @override
  String get trustedBy1LakhUsers => '1 लाख वापरकर्त्यांद्वारे विश्वासार्ह';

  @override
  String get mobileNumberRequired => 'मोबाइल नंबर आवश्यक आहे';

  @override
  String get enterValid10DigitMobile => 'वैध 10 अंकी मोबाइल नंबर प्रविष्ट करा';

  @override
  String serverError(int statusCode) {
    return 'सर्व्हर त्रुटी: $statusCode';
  }

  @override
  String get requestTimedOut => 'विनंती वेळ संपली. इंटरनेट तपासा.';

  @override
  String get somethingWentWrong => 'काहीतरी चुकीचे झाले.';

  @override
  String get home => 'होम';

  @override
  String get myBids => 'माझ्या बोली';

  @override
  String get mpin => 'एम-पिन';

  @override
  String get passbook => 'पासबुक';

  @override
  String get funds => 'निधी';

  @override
  String get videos => 'व्हिडिओ';

  @override
  String get gameRates => 'गेम दर';

  @override
  String get charts => 'चार्ट';

  @override
  String get settings => 'सेटिंग्ज';

  @override
  String get shareApplication => 'अॅप शेअर करा';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get kingStarline => 'किंग स्टारलाइन';

  @override
  String get kingJackpot => 'किंग जॅकपॉट';

  @override
  String get playGame => 'गेम खेळा';

  @override
  String get openBid => 'उघडी बोली';

  @override
  String get bettingIsRunning => 'बेटिंग चालू आहे';

  @override
  String get closeBid => 'बंद बोली';

  @override
  String get marketClosed => 'बाजार बंद';

  @override
  String get openBids => 'उघड्या बोली:';

  @override
  String get closeBids => 'बंद बोली:';

  @override
  String get errorLoadingData => 'डेटा लोड करताना त्रुटी.';

  @override
  String get noGameDataAvailable => 'गेम डेटा उपलब्ध नाही.';

  @override
  String get notificationSettings => 'सूचना सेटिंग्ज';

  @override
  String get mainNotification => 'मुख्य सूचना';

  @override
  String get gameNotification => 'गेम सूचना';

  @override
  String get kingStarlineNotification => 'किंग स्टारलाइन सूचना';

  @override
  String get kingJackpotNotification => 'किंग जॅकपॉट सूचना';

  @override
  String get languageSettings => 'भाषा सेटिंग्ज';

  @override
  String get ok => 'ठीक आहे';

  @override
  String get closedForToday => 'आजसाठी बंद';

  @override
  String get openBidLastTime => 'उघडी बोली अंतिम वेळ';

  @override
  String get openResultTime => 'उघडा परिणाम वेळ';

  @override
  String get closeBidLastTime => 'बंद बोली अंतिम वेळ';

  @override
  String get closeResultTime => 'बंद परिणाम वेळ';

  @override
  String get goodLuck => 'शुभेच्छा';

  @override
  String get bidsPlacedSuccessfully => 'बोली यशस्वीरित्या ठेवल्या';

  @override
  String get bidPlacementFailed => 'Bid Placement Failed!';

  @override
  String get pleaseTryAgain => 'Please try again.';

  @override
  String get dismiss => 'Dismiss';

  @override
  String marketClosedMessage(String gameName) {
    return '$gameName market is closed.';
  }

  @override
  String get noBidsAdded => 'कोणतीही बोली जोडली नाही';

  @override
  String get noDataAddedYet => 'अद्याप कोणतीही डेटा जोडली नाही';

  @override
  String get submit => 'सबमिट करा';

  @override
  String get odd => 'Odd';

  @override
  String get even => 'Even';

  @override
  String get gameType => 'गेम प्रकार';

  @override
  String get digit => 'अंक';

  @override
  String get points => 'पॉईंट्स';

  @override
  String get bidId => 'बोली ID';

  @override
  String get bidDate => 'बोली तारीख';

  @override
  String get noEntriesFound => 'कोणतीही प्रविष्टी सापडली नाही.';

  @override
  String get noChartDataFound => 'No chart data found.';

  @override
  String error(String error) {
    return 'त्रुटी: $error';
  }

  @override
  String get noResultsForThisDate => 'No results for this date.';

  @override
  String bids(Object count) {
    return 'Bids';
  }

  @override
  String total(Object amount) {
    return 'Total';
  }

  @override
  String get profilePage => 'Profile Page';

  @override
  String get historyPage => 'इतिहास पेज';

  @override
  String get youCanViewYourMarketBidHistory =>
      'आप आपला मार्केट बोली इतिहास पाहू शकता';

  @override
  String get youCanViewYourStarlineBidHistory =>
      'आप आपला स्टारलाइन बोली इतिहास पाहू शकता';

  @override
  String get youCanViewYourJackpotBidHistory =>
      'आप आपला जॅकपॉट बोली इतिहास पाहू शकता';

  @override
  String permissionGranted(String permission) {
    return '$permission permission granted!';
  }

  @override
  String get whatsappNumberNotFound => 'WhatsApp number not found.';

  @override
  String get couldNotOpenWhatsapp =>
      'Could not open WhatsApp. Please install the app.';

  @override
  String get noVideosAvailable => 'No videos available for this language';

  @override
  String get noAppFoundToOpenLink => 'No app found to open this link';

  @override
  String get cannotHandleLink => 'Cannot handle this link';

  @override
  String get screenshotSavedToGallery => 'Screenshot saved to gallery';

  @override
  String get failedToSaveScreenshot => 'Failed to save screenshot';

  @override
  String get qrPayment => 'QR Payment';

  @override
  String get saveQrToGallery => 'Save QR to Gallery';

  @override
  String get noDepositHistoryFound => 'No deposit history found';

  @override
  String get noWithdrawHistoryFound => 'निकासी इतिहास सापडला नाही.';

  @override
  String get registerIdMissing => 'Register ID missing. Please log in again.';

  @override
  String get accessTokenNotFound =>
      'Access token not found. Please log in again.';

  @override
  String get registerIdNotFound =>
      'Register ID not found. Please log in again.';

  @override
  String get noBidsYet => 'No bids yet';

  @override
  String get halfSangamB => 'हाफ संगम बी';

  @override
  String get screenNotFound => 'Error: Screen not found';

  @override
  String get wallet => 'Wallet';

  @override
  String get chat => 'Chat';

  @override
  String get enterValid3To7DigitNumber => 'Enter valid 3–7 digit number';

  @override
  String get numberMustHaveAtLeast2UniqueDigits =>
      'Number must have at least 2 unique digits';

  @override
  String get enterValid3DigitNumber => 'Enter a valid 3-digit number.';

  @override
  String get invalidTriplePannaNumber => 'Invalid Triple Panna number.';

  @override
  String get pleaseEnterValid3DigitOpenPanna =>
      'कृपया वैध 3 अंकी उघडी पन्ना प्रविष्ट करा.';

  @override
  String get pleaseEnterValid3DigitClosePanna =>
      'कृपया वैध 3 अंकी बंद पन्ना प्रविष्ट करा.';

  @override
  String pointsMustBeBetween(int min) {
    return 'Points must be between $min and 1000.';
  }

  @override
  String get openDigitEkHiHonaChahiye => 'उघडा अंक एकच असावा (0-9).';

  @override
  String get openDigit0Se9KeBeechDo => 'उघडा अंक 0 ते 9 दरम्यान द्या.';

  @override
  String get valid3DigitPannaDo => 'वैध 3 अंकी पन्ना द्या (उदा. 123).';

  @override
  String pointsMinSe1000KeBeechDo(int min) {
    return 'अंक $min ते 1000 दरम्यान द्या.';
  }

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get whatsappNumberNotAvailable => 'WhatsApp number not available';

  @override
  String get errorLaunchingWhatsapp => 'Error launching WhatsApp';

  @override
  String get mobileNumberNotAvailable => 'Mobile number is not available';

  @override
  String get checkOutSara777App => 'Check out the Sara 777 App!';

  @override
  String get imLovingSara777App =>
      'I\'m loving Sara 777 App\n\nDownload App now\n\nFrom:-\nhttps://admin.mhmatka.app';

  @override
  String get open => 'Open';

  @override
  String get close => 'Close';

  @override
  String get session => 'Session';

  @override
  String get remove => 'Remove';

  @override
  String get add => 'Add';

  @override
  String get clear => 'Clear';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get loading => 'Loading...';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get success => 'Success';

  @override
  String get failed => 'Failed';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get nextPage => 'पुढील';

  @override
  String get previous => 'Previous';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get refresh => 'Refresh';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get insufficientBalance => 'Insufficient balance';

  @override
  String get invalidInput => 'Invalid input';

  @override
  String get selectGameType => 'Select Game Type';

  @override
  String get selectDigit => 'Select Digit';

  @override
  String get enterPoints => 'पॉईंट्स प्रविष्ट करा:';

  @override
  String get totalPoints => 'Total Points';

  @override
  String get totalAmount => 'एकूण रक्कम';

  @override
  String get walletBalanceBeforeDeduction => 'कपात करण्यापूर्वी वॉलेट शिल्लक';

  @override
  String get walletBalanceAfterDeduction => 'कपात केल्यानंतर वॉलेट शिल्लक';

  @override
  String get noteBidOncePlayedWillNotBeCancelled =>
      '*नोट: एकदा खेळलेली बोली रद्द केली जाणार नाही';

  @override
  String get confirmBid => 'बोली पुष्टी करा';

  @override
  String get bidDetails => 'Bid Details';

  @override
  String get gameName => 'Game Name';

  @override
  String get date => 'तारीख';

  @override
  String get time => 'वेळ';

  @override
  String get status => 'Status';

  @override
  String get amount => 'रक्कम';

  @override
  String get result => 'Result';

  @override
  String get win => 'Win';

  @override
  String get loss => 'Loss';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get enterOpenPanna => 'उघडी पन्ना प्रविष्ट करा :';

  @override
  String get enterClosePanna => 'बंद पन्ना प्रविष्ट करा :';

  @override
  String get sangam => 'संगम';

  @override
  String get bid => 'Bid';

  @override
  String get pleaseAddAtLeastOneBid => 'Please add at least one bid.';

  @override
  String get insufficientWalletBalanceToPlaceBid =>
      'ही बोली ठेवण्यासाठी अपर्याप्त वॉलेट शिल्लक.';

  @override
  String updatedPointsFor(String sangam) {
    return '$sangam साठी अंक अद्यतनित केले.';
  }

  @override
  String addedBidWithPoints(String sangam, String points) {
    return 'बोली जोडली: $sangam $points अंकांसह.';
  }

  @override
  String bidRemovedFromList(String sangam) {
    return 'सूचीतून $sangam साठी बोली काढली.';
  }

  @override
  String get screenNotMounted => 'स्क्रीन माउंट केलेली नाही.';

  @override
  String get authenticationErrorPleaseLoginAgain =>
      'प्रमाणीकरण त्रुटी: कृपया पुन्हा लॉग इन करा.';

  @override
  String get noValidBidsToSubmit => 'सबमिट करण्यासाठी कोणतीही वैध बोली नाही.';

  @override
  String unexpectedErrorOccurred(String error) {
    return 'अप्रत्याशित त्रुटी आली: $error';
  }

  @override
  String get ank => 'अंक';

  @override
  String get pana => 'पन्ना';

  @override
  String get addBid => 'बोली जोडा';

  @override
  String get pannaAnk => 'पन्ना - अंक';

  @override
  String get pannaDigit => 'पन्ना - अंक';

  @override
  String get type => 'Type';

  @override
  String get halfSangamA => 'हाफ संगम ए';

  @override
  String get noBidsAddedYet => 'अद्याप कोणतीही बोली जोडली नाही';

  @override
  String get noBidsPlaced => 'कोणतीही बोली ठेवली नाही';

  @override
  String get ankOneDigitRequired => 'Ank 1 digit ka do (0–9).';

  @override
  String get ankBetween0And9 => 'Ank 0 se 9 ke beech do.';

  @override
  String get addingThisWillExceedWalletBalance =>
      'हे जोडल्याने एकूण वॉलेटपेक्षा जास्त होईल.';

  @override
  String updatedAnkPanna(String ank, String panna) {
    return 'अद्यतनित: $ank-$panna.';
  }

  @override
  String addedAnkPannaWithPoints(String ank, String panna, String pts) {
    return 'जोडले: $ank-$panna — $pts अंक.';
  }

  @override
  String removedAnkPanna(String ank, String panna) {
    return 'काढले: $ank-$panna.';
  }

  @override
  String get pleaseAddAtLeastOneBidFirst => 'कृपया प्रथम किमान एक बोली जोडा.';

  @override
  String get walletBalanceLow => 'वॉलेट शिल्लक कमी आहे.';

  @override
  String get authIssuePleaseLoginAgain =>
      'प्रमाणीकरण समस्या — कृपया पुन्हा लॉगिन करा.';

  @override
  String get enterOpenDigit => 'उघडा अंक प्रविष्ट करा :';

  @override
  String removedSangam(String sangam) {
    return '$sangam काढले.';
  }

  @override
  String get enterAmount => 'रक्कम प्रविष्ट करा';

  @override
  String get insufficientWalletBalance => 'अपर्याप्त वॉलेट शिल्लक.';

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
  String get bidsLabel => 'बोली';

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
    return 'काढले: $digit ($session)';
  }

  @override
  String removedDigit(String digit) {
    return 'काढले: $digit';
  }

  @override
  String get noEntriesYetAddData => 'No entries yet. Add some data!';

  @override
  String get enter3DigitNumber => '3-अंकी संख्या प्रविष्ट करा';

  @override
  String get enter3DigitNumberColon => '3-अंकी संख्या प्रविष्ट करा:';

  @override
  String get gameTypeLabel => 'Game Type';

  @override
  String get amountLabel => 'Amount';

  @override
  String get pointsLabel => 'गुण';

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
      'कृपया वैध एकल अंक (0-9) प्रविष्ट करा.';

  @override
  String get pleaseEnterAnAmount => 'Please enter an amount.';

  @override
  String get amountMustBeNumber => 'Amount must be a number.';

  @override
  String amountMustBeBetween(int min, int max) {
    return 'रक्कम $min आणि $max दरम्यान असणे आवश्यक आहे.';
  }

  @override
  String get insufficientWalletBalanceToPlaceBids =>
      'या बोली ठेवण्यासाठी अपर्याप्त वॉलेट शिल्लक.';

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
      'सबमिट करण्यापूर्वी कृपया किमान एक बोली जोडा.';

  @override
  String get insufficientWalletBalanceToSubmit =>
      'Insufficient wallet balance to submit.';

  @override
  String get bidPlacedSuccessfully => 'Bid placed successfully!';

  @override
  String get unknownErrorOccurred => 'अज्ञात त्रुटी आली.';

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
    return 'हे $bidType सेट काढा';
  }

  @override
  String get enterJodi => 'जोडी प्रविष्ट करा:';

  @override
  String get enterJodiHint => 'जोडी प्रविष्ट करा';

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
      'कृपया प्रतीक्षा करा, बोली सबमिशन प्रगतीत आहे.';

  @override
  String get jodiDigitMustBeExactly2Numbers =>
      'जोडी अंक नक्की 2 संख्या असावे (00-99).';

  @override
  String get jodiMustBeNumberBetween00And99 =>
      'जोडी 00 आणि 99 दरम्यानची संख्या असावी.';

  @override
  String get pleaseEnterValidPoints => 'कृपया वैध पॉईंट्स प्रविष्ट करा.';

  @override
  String get pointsMustBeBetween10And10000 =>
      'पॉईंट्स 10 आणि 10000 दरम्यान असावेत.';

  @override
  String get insufficientWalletBalanceForThisBid =>
      'या बोलीसाठी अपुरे वॉलेट बॅलन्स.';

  @override
  String jodiWithPointsAdded(String digit, String points) {
    return 'जोडी $digit $points पॉईंट्ससह जोडली.';
  }

  @override
  String jodiPointsUpdatedTo(String digit, String points) {
    return 'जोडी $digit पॉईंट्स $points मध्ये अद्यतनित केले.';
  }

  @override
  String get cannotRemoveBidWhileSubmissionInProgress =>
      'सबमिशन प्रगतीत असताना बोली काढू शकत नाही.';

  @override
  String jodiRemoved(String digit) {
    return 'जोडी $digit काढली.';
  }

  @override
  String get submittingYourBids => 'तुमच्या बोल्या सबमिट करत आहे...';

  @override
  String get bidFailedPleaseTryAgain =>
      'बोली अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String networkErrorOrUnexpectedIssue(String error) {
    return 'नेटवर्क त्रुटी किंवा अनपेक्षित समस्या: $error';
  }

  @override
  String get enterJodiDigit => 'जोडी अंक प्रविष्ट करा:';

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
  String get enter3DigitTriplePanna => '3-अंकी ट्रिपल पन्ना प्रविष्ट करा';

  @override
  String get enter3DigitTriplePannaColon => 'Enter 3-Digit Triple Panna:';

  @override
  String get pleaseSelectSPDPOrTP => 'कृपया SP, DP, किंवा TP निवडा.';

  @override
  String get digitMustBeNumber0To9 => 'अंक 0 ते 9 मधील संख्या असणे आवश्यक आहे.';

  @override
  String addedBidsForCategory(int count, String category) {
    return '$count बोली $category साठी जोडल्या.';
  }

  @override
  String get pleaseAddBidsBeforeSubmitting =>
      'सबमिट करण्यापूर्वी कृपया बोली जोडा.';

  @override
  String get pleaseEnterNumber => 'कृपया नंबर प्रविष्ट करा.';

  @override
  String get pleaseEnterValidNumber => 'कृपया वैध नंबर (3-7 अंक) प्रविष्ट करा.';

  @override
  String get numberMustContainTwoUniqueDigits =>
      'नंबरमध्ये किमान दोन अद्वितीय अंक असणे आवश्यक आहे.';

  @override
  String get noValidBidsFound => 'या नंबरसाठी कोणतीही वैध बोली सापडली नाही.';

  @override
  String addedBidsFromApiResponse(int count) {
    return 'Added $count bids from API response.';
  }

  @override
  String get allBidsAlreadyExist => 'सर्व बोली आधीच अस्तित्वात आहेत.';

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
      'निवडलेल्या गेम प्रकारासाठी कोणतीही वैध बोली नाही.';

  @override
  String get enterNumber => 'नंबर प्रविष्ट करा:';

  @override
  String get enterNumberHint => 'नंबर प्रविष्ट करा';

  @override
  String get count => 'Count';

  @override
  String get walletBalanceKamHai => 'Wallet balance is low.';

  @override
  String get enterSinglePanaHint => 'Enter Single Pana';

  @override
  String get bidTime => 'बोली वेळ :';

  @override
  String get bidResultTime => 'बोली परिणाम वेळ :';

  @override
  String get paymentSuccess => 'पेमेंट यशस्वी';

  @override
  String get done => 'पूर्ण';

  @override
  String get accountRecovery => 'खाते पुनर्प्राप्ती';

  @override
  String get accountRecoveryMessage =>
      'नवीन MPIN सेट करून आपले विद्यमान खाते पुनर्प्राप्त करा\n\nआपण पुढे जाऊ इच्छिता?';

  @override
  String get recover => 'पुनर्प्राप्त करा';

  @override
  String get walletFundHistoryNotAvailable => 'वॉलेट फंड इतिहास उपलब्ध नाही';

  @override
  String get termsAndConditions => 'अटी आणि नियम';

  @override
  String get minimumWithdrawAmount => 'किमान निकासी रक्कम 1000 ₹ आहे';

  @override
  String get maximumWithdrawAmount => 'आणि कमाल निकासी रक्कम 500000 आहे';

  @override
  String get above5LakhManualRequest =>
      '5 लाखांपेक्षा जास्त असल्यास आपल्याला आम्हाला मॅन्युअली विनंती करावी लागेल.';

  @override
  String get withdrawRequestTiming =>
      'निकासी विनंती वेळ सकाळी 09:00 ते रात्री 10:00 पर्यंत';

  @override
  String get processTime => 'प्रक्रिया वेळ किमान 1 तास कमाल 72 तास.';

  @override
  String get withdrawAvailableAllDays =>
      'निकासी आठवड्याच्या सर्व 7 दिवसांमध्ये उपलब्ध आहे.';

  @override
  String get accept => 'स्वीकारा';

  @override
  String get addFund => 'फंड जोडा';

  @override
  String get addMoney => 'पैसे जोडा';

  @override
  String get availableBalance => 'उपलब्ध शिल्लक';

  @override
  String get addPointUpi => 'पॉइंट जोडा - UPI';

  @override
  String get addPointQrPaytmGateway => 'पॉइंट जोडा - QR - PAYTM - GATEWAY';

  @override
  String get howToAddPoint => 'पॉइंट कसे जोडायचे';

  @override
  String get pleaseContactSupportToKnowHowToAddPoint =>
      'पॉइंट कसे जोडायचे हे जाणून घेण्यासाठी कृपया समर्थनाशी संपर्क साधा.';

  @override
  String get selectUpiApp => 'UPI अॅप निवडा';

  @override
  String get upiApp => 'UPI अॅप';

  @override
  String get addFunds => 'फंड जोडा';

  @override
  String get upiPayeeDetailsNotConfigured =>
      'UPI प्राप्तकर्ता तपशील कॉन्फिगर केलेले नाहीत.';

  @override
  String get invalidUpiIdFormat => 'अवैध UPI ID स्वरूप';

  @override
  String pleaseEnterValidAmountMin(String amount) {
    return 'कृपया वैध रक्कम प्रविष्ट करा (किमान ₹$amount).';
  }

  @override
  String get noUpiAppsFound =>
      'UPI अॅप सापडले नाहीत. कृपया पुढे जाण्यासाठी UPI अॅप इंस्टॉल करा.';

  @override
  String get paymentFailedOrCancelled => 'पेमेंट अयशस्वी झाली किंवा रद्द केली.';

  @override
  String errorOccurredDuringUpiPayment(String error) {
    return 'UPI पेमेंट दरम्यान त्रुटी आली: $error';
  }

  @override
  String get rangeErrorOccurredDuringUpiPayment =>
      'UPI पेमेंट दरम्यान RangeError आला. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get failedToLaunchUpiApp =>
      'अनपेक्षित त्रुटीमुळे UPI अॅप लॉन्च करण्यात अयशस्वी.';

  @override
  String get invalidServerResponse =>
      'अवैध सर्व्हर प्रतिसाद (paymentHash/timestamp गहाळ आहे).';

  @override
  String get depositSuccessfulAndUpdated => 'ठेव यशस्वी आणि अद्यतनित केली';

  @override
  String get failedToAddDepositFund => 'ठेव फंड जोडण्यात अयशस्वी';

  @override
  String failedToCreateFundRequest(int code) {
    return 'फंड विनंती तयार करण्यात अयशस्वी (HTTP $code)';
  }

  @override
  String failedToCompletePaymentProcess(String error) {
    return 'पेमेंट प्रक्रिया पूर्ण करण्यात अयशस्वी: $error';
  }

  @override
  String get pleaseEnterValidAmount => 'कृपया वैध रक्कम प्रविष्ट करा.';

  @override
  String pleaseEnterAmountGreaterThanOrEqual(int amount) {
    return 'कृपया ₹$amount पेक्षा जास्त किंवा समान रक्कम प्रविष्ट करा.';
  }

  @override
  String get invalidMobileNumberFound => 'अवैध मोबाइल नंबर सापडला.';

  @override
  String get paymentLinkNotFoundInResponse =>
      'प्रतिसादात पेमेंट लिंक सापडला नाही.';

  @override
  String get failedToCreateTransactionLink =>
      'व्यवहार लिंक तयार करण्यात अयशस्वी.';

  @override
  String get bankDetails => 'बँक तपशील';

  @override
  String get accountHolderName => 'खाते धारकाचे नाव';

  @override
  String get accountNumber => 'खाते क्रमांक';

  @override
  String get enterAccountNumber => 'खाते क्रमांक प्रविष्ट करा';

  @override
  String get ifscCode => 'IFSC कोड';

  @override
  String get bankName => 'बँकेचे नाव';

  @override
  String get enterBankName => 'बँकेचे नाव प्रविष्ट करा';

  @override
  String get branchName => 'शाखेचे नाव';

  @override
  String get enterBranchName => 'शाखेचे नाव प्रविष್ಟ करा';

  @override
  String get addBank => 'बँक जोडा';

  @override
  String get fundDepositHistory => 'फंड ठेव इतिहास';

  @override
  String get narration => 'वर्णन';

  @override
  String get withdrawFunds => 'निकासी फंड';

  @override
  String get depositHistory => 'ठेव इतिहास';

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
  String get acNo => 'खाता क्र.';

  @override
  String get manualApproveByAdmin => 'अॅडमिन द्वारा मॅन्युअल मंजुरी';

  @override
  String get enterGooglePayUpiId => 'Google Pay UPI ID प्रविष्ट करा';

  @override
  String get enterPhonepeUpiId => 'PhonePe UPI ID प्रविष्ट करा';

  @override
  String get enterPaytmNumber => 'Paytm नंबर प्रविष्ट करा';

  @override
  String get enterUpiIdNumber => 'UPI ID/नंबर प्रविष्ट करा';

  @override
  String get pleaseLoginAgainToContinue =>
      'कृपया सुरू ठेवण्यासाठी पुन्हा लॉग इन करा.';

  @override
  String minimumWithdrawalAmountIs(int amount) {
    return 'किमान निकासी रक्कम ₹$amount आहे.';
  }

  @override
  String get pleaseEnterGooglePayUpiId =>
      'कृपया Google Pay UPI ID प्रविष्ट करा.';

  @override
  String get pleaseEnterPhonepeUpiId => 'कृपया PhonePe UPI ID प्रविष्ट करा.';

  @override
  String get pleaseEnterPaytmNumber => 'कृपया Paytm नंबर प्रविष्ट करा.';

  @override
  String get pleaseFillAllBankDetails => 'कृपया सर्व बँक तपशील भरा.';

  @override
  String get pleaseSelectWithdrawalMethod => 'कृपया निकासी पद्धत निवडा.';

  @override
  String get withdrawalRequestSubmittedSuccessfully =>
      'निकासी विनंती यशस्वीरित्या सबमिट केली!';

  @override
  String get withdrawalRequestFailed => 'निकासी विनंती अयशस्वी.';

  @override
  String anErrorOccurred(String error) {
    return 'त्रुटी आली: $error';
  }

  @override
  String get jackpotDashboard => 'जॅकपॉट डॅशबोर्ड';

  @override
  String get history => 'इतिहास';

  @override
  String get notifications => 'अधिसूचना';

  @override
  String get jodi => 'Jodi';

  @override
  String get closed => 'बंद';

  @override
  String get running => 'चालू आहे';

  @override
  String get noJackpotBidTypesAvailable =>
      'जॅकपॉट बिड प्रकार उपलब्ध नाहीत किंवा लोड करण्यात अयशस्वी.';

  @override
  String get theMarketFor => 'साठी बाजार';

  @override
  String get isCurrentlyClosed => 'सध्या बंद आहे.';

  @override
  String get failedToLoadJackpotBidTypes =>
      'जॅकपॉट बिड प्रकार लोड करण्यात अयशस्वी:';

  @override
  String get noScreenConfiguredForGameType =>
      'गेम प्रकारासाठी स्क्रीन कॉन्फिगर केलेले नाही:';

  @override
  String get networkErrorPleaseTryAgainLater =>
      'नेटवर्क त्रुटी. कृपया नंतर पुन्हा प्रयत्न करा.';

  @override
  String get failedToLoadGames => 'गेम लोड करण्यात अयशस्वी';

  @override
  String get singleDigit => 'Single Digit';

  @override
  String get singlePana => 'Single Pana';

  @override
  String get doublePana => 'Double Pana';

  @override
  String get triplePana => 'Triple Pana';

  @override
  String get choiceSpDpTp => 'Choice SP DP TP';

  @override
  String get spMotor => 'SP Motor';

  @override
  String get dpMotor => 'DP Motor';

  @override
  String get tpMotor => 'TP Motor';

  @override
  String get fullSangam => 'Full Sangam';

  @override
  String get halfSangam => 'Half Sangam';

  @override
  String get singleDigitsBulk => 'Single Digits Bulk';

  @override
  String get jodiBulk => 'Jodi Bulk';

  @override
  String get singlePanaBulk => 'Single Pana Bulk';

  @override
  String get doublePanaBulk => 'Double Pana Bulk';

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
  String get createAccount => 'खाते तयार करा';

  @override
  String get enterYourDetails => 'तुमची माहिती प्रविष्ट करा';

  @override
  String get enterUsername => 'वापरकर्ता नाव प्रविष्ट करा';

  @override
  String get enterPassword => 'पासवर्ड प्रविष्ट करा';

  @override
  String get confirmPassword => 'पासवर्ड पुष्टी करा';

  @override
  String get pleaseEnterUsername => 'कृपया वापरकर्ता नाव प्रविष्ट करा';

  @override
  String get pleaseEnterPassword => 'कृपया पासवर्ड प्रविष्ट करा';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'पासवर्ड किमान 6 वर्णांचा असावा';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड जुळत नाहीत';

  @override
  String get verifyMobileNumber => 'मोबाईल नंबर\nसत्यापित करा';

  @override
  String get enterPasswordLabel => 'पासवर्ड प्रविष्ट करा';

  @override
  String get toCompleteRegistrationFor => 'नोंदणी पूर्ण करण्यासाठी\n';

  @override
  String get enterYourAccountPassword => 'तुमचा खाता पासवर्ड प्रविष्ट करा.';

  @override
  String get enterYourPassword => 'तुमचा पासवर्ड प्रविष्ट करा';

  @override
  String get verify => 'सत्यापित करा';

  @override
  String get missingDataRestartRegistration =>
      'डेटा गहाळ आहे. नोंदणी पुन्हा सुरू करा.';

  @override
  String get errorVerifyingPassword => 'पासवर्ड सत्यापित करताना त्रुटी';

  @override
  String get registrationFailed => 'नोंदणी अयशस्वी';

  @override
  String get prev => 'मागील';

  @override
  String get description => 'वर्णन';

  @override
  String get prevAmt => 'मागील रक्कम';

  @override
  String get txnAmt => 'व्यवहार रक्कम';

  @override
  String get curAmt => 'वर्तमान रक्कम';

  @override
  String get bidHistory => 'बोली इतिहास';

  @override
  String get noBidEntriesFound => 'बोली प्रविष्टी सापडली नाही.';

  @override
  String get transactionTime => 'व्यवहार वेळ:';

  @override
  String get statusLabel => 'Status:';

  @override
  String get betterLuckNextTime => 'पुढच्या वेळी चांगली किस्मत';

  @override
  String get currentAmount => 'वर्तमान रक्कम';

  @override
  String get previousAmount => 'मागील रक्कम';

  @override
  String get transactionAmount => 'व्यवहार रक्कम';

  @override
  String get quit => 'बाहेर पडा';

  @override
  String get areYouSureYouWantToQuitTheApp =>
      'तुम्हाला खात्री आहे की तुम्ही अॅपमधून बाहेर पडू इच्छिता?';

  @override
  String get yes => 'होय';

  @override
  String get no => 'नाही';

  @override
  String get noNotificationsFound => 'कोणतीही सूचना सापडली नाही.';

  @override
  String get pleaseEnterAnAmountFirst => 'कृपया प्रथम रक्कम प्रविष्ट करा.';

  @override
  String get pointsMustBeBetween10And1000 =>
      'पॉइंट्स 10 आणि 1000 दरम्यान असावेत.';

  @override
  String bidForDigitUpdated(String digit, String type, String points) {
    return 'अंक $digit ($type) साठी बोली $points पॉइंट्समध्ये अद्यतनित केली.';
  }

  @override
  String addedBidForDigit(String digit, String amount) {
    return 'अंकासाठी बोली जोडली: $digit, रक्कम: $amount';
  }

  @override
  String get noBidsPlacedYetClickNumber =>
      'अद्याप कोणतीही बोली ठेवलेली नाही. बोली जोडण्यासाठी नंबरवर क्लिक करा!';

  @override
  String get bidsSubmittedSuccessfully => 'बोली यशस्वीरित्या सबमिट केली!';

  @override
  String removedBidForDigit(String digit, String amount) {
    return 'अंकासाठी बोली काढली: $digit, रक्कम: $amount.';
  }

  @override
  String get selectGameTypeColon => 'गेम प्रकार निवडा:';

  @override
  String get enterPointsColon => 'पॉइंट्स प्रविष्ट करा:';

  @override
  String get loginWithMpin => 'MPIN सह लॉगिन करा';

  @override
  String get mpinHint => 'MPIN';

  @override
  String get login => 'लॉगिन';

  @override
  String get forgotMpin => 'MPIN विसरलात?';

  @override
  String get biometricAuthenticationNotAvailable =>
      'बायोमेट्रिक प्रमाणीकरण उपलब्ध नाही किंवा समर्थित नाही';

  @override
  String get scanYourFingerprintToVerify =>
      'सत्यापित करण्यासाठी आपली बोट स्कॅन करा';

  @override
  String get biometricAuthenticationFailed => 'बायोमेट्रिक प्रमाणीकरण अयशस्वी';

  @override
  String biometricError(String error) {
    return 'बायोमेट्रिक त्रुटी: $error';
  }

  @override
  String get pleaseEnterYourMpin => 'कृपया आपला MPIN प्रविष्ट करा';

  @override
  String get registrationIdNotFoundPleaseReregister =>
      'नोंदणी ID सापडली नाही. कृपया पुन्हा नोंदणी करा.';

  @override
  String get accessTokenNotFoundPleaseRelogin =>
      'ऍक्सेस टोकन सापडले नाही. कृपया पुन्हा लॉग इन करा.';

  @override
  String get loginSuccessful => 'लॉगिन यशस्वी!';

  @override
  String get failedToVerifyMpinPleaseTryAgainLater =>
      'MPIN सत्यापित करण्यात अयशस्वी. कृपया नंतर पुन्हा प्रयत्न करा.';

  @override
  String errorOccurredDuringMpinVerification(String error) {
    return 'MPIN सत्यापन दरम्यान त्रुटी आली: $error';
  }

  @override
  String get invalidMpin => 'अवैध MPIN';

  @override
  String get pleaseEnterCorrectMpin => 'कृपया योग्य MPIN प्रविष्ट करा';

  @override
  String get setYourPin => 'तुमचा PIN सेट करा';

  @override
  String get enterNewMpin => 'नवीन mPin प्रविष्ट करा';

  @override
  String get enter4DigitMpin => '4 अंकांचा mPin प्रविष्ट करा';

  @override
  String get setPin => 'PIN सेट करा';

  @override
  String get pleaseEnterValid4DigitPin =>
      'कृपया वैध 4 अंकांचा PIN प्रविष्ट करा';

  @override
  String somethingWentWrongWithError(String error) {
    return 'काहीतरी चुकीचे झाले: $error';
  }

  @override
  String get changeNewMpin => 'नवीन MPIN बदला';

  @override
  String get enter4DigitPin => '4 अंकांचा PIN प्रविष्ट करा';

  @override
  String errorWithPlaceholder(String error) {
    return 'त्रुटी: $error';
  }

  @override
  String couldNotLaunchUrl(String url) {
    return 'URL लॉन्च करू शकले नाही: $url';
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
  String get gameWinRatioForAllBids => 'सर्व बोलींसाठी गेम जीत गुणोत्तर';

  @override
  String get starlineWinRatioForAllBids =>
      'सर्व बोलींसाठी स्टारलाइन जीत गुणोत्तर';

  @override
  String get jackpotWinRatio => 'जॅकपॉट जीत गुणोत्तर';

  @override
  String rateFormat(String label, String value) {
    return '$label: 10 चा $value';
  }

  @override
  String failedToLoadGameRates(int statusCode) {
    return 'गेम दर लोड करण्यात अयशस्वी: $statusCode';
  }

  @override
  String youCanWithdrawBetween(String startTime, String endTime) {
    return 'तुम्ही $startTime आणि $endTime दरम्यान निकासी करू शकता.';
  }

  @override
  String bidForJodiAddedSuccessfully(String jodi) {
    return 'Jodi $jodi साठी बोली यशस्वीरित्या जोडली!';
  }

  @override
  String get bidFailed => 'बोली अयशस्वी.';

  @override
  String get submitBid => 'बोली सबमिट करा';

  @override
  String totalBidsWithCount(int count) {
    return 'एकूण बोल्या:\n$count';
  }

  @override
  String get pleaseEnterAtLeastOneThreeDigitPanaNumber =>
      'कृपया किमान एक 3-अंकी पन्ना नंबर प्रविष्ट करा.';

  @override
  String get enterPanaNumberColon => 'पन्ना क्रमांक प्रविष्ट करा:';

  @override
  String invalidPanaWithDigit(String digit) {
    return 'अवैध पन्ना: $digit';
  }

  @override
  String get noValidPanasReturnedFromServer =>
      'सर्व्हरकडून कोणतेही वैध पन्ना परत आले नाहीत.';

  @override
  String addedBidsCount(int count) {
    return '$count बोली(जोड) जोडली.';
  }

  @override
  String removedPanaDigit(String digit) {
    return 'काढले: $digit';
  }

  @override
  String get networkErrorCheckInternet =>
      'नेटवर्क त्रुटी. कृपया आपले इंटरनेट कनेक्शन तपासा.';

  @override
  String get enterPanaExampleHint => 'उदा., 123, 445';

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
  String get half => 'अर्धा';

  @override
  String get full => 'पूर्ण';

  @override
  String get bidsColon => 'Bids:';

  @override
  String get totalColon => 'एकूण:';

  @override
  String get placeBidFailed => 'बोली ठेवण्यात अयशस्वी';

  @override
  String get pleaseEnterValidNumberMinimum3Digits =>
      'Please enter a valid number (minimum 3 digits).';

  @override
  String get bidsAddedFromApi => 'API वरून बोली जोडल्या.';

  @override
  String get requestFailed => 'विनंती अयशस्वी.';

  @override
  String get pleaseEnterAllThreeDigits => 'कृपया तीनही अंक प्रविष्ट करा.';

  @override
  String get eachDigitMustBeSingleNumber =>
      'प्रत्येक अंक एक एकल संख्या (0-9) असणे आवश्यक आहे.';

  @override
  String get pleaseSelectSPDPTP => 'कृपया SP, DP किंवा TP निवडा.';

  @override
  String get pleaseSelectOpenClose => 'कृपया OPEN/CLOSE निवडा.';

  @override
  String get spMustHave3UniqueDigits =>
      'SP मध्ये 3 अद्वितीय अंक असणे आवश्यक आहे.';

  @override
  String get dpMustHaveExactlyTwoSameDigits =>
      'DP मध्ये नक्की दोन समान अंक असणे आवश्यक आहे.';

  @override
  String get tpMustHaveAll3DigitsSame =>
      'TP मध्ये सर्व 3 अंक समान असणे आवश्यक आहे.';

  @override
  String updatedPannaCategorySession(
    String panna,
    String category,
    String session,
  ) {
    return 'अद्यतनित: $panna ($category $session)';
  }

  @override
  String addedPannaCategorySession(
    String panna,
    String category,
    String session,
  ) {
    return 'जोडले: $panna ($category $session)';
  }

  @override
  String removedPannaCategorySession(
    String panna,
    String category,
    String session,
  ) {
    return 'काढले: $panna ($category $session)';
  }

  @override
  String get enterLeftDigit => 'डावा अंक प्रविष्ट करा';

  @override
  String get enterMiddleDigit => 'मध्य अंक प्रविष्ट करा';

  @override
  String get enterRightDigit => 'उजवा अंक प्रविष्ट करा';

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
  String get leftDigit => 'डावा अंक';

  @override
  String get rightDigit => 'उजवा अंक';

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
  String get enterTwoDigits => 'दो अंक प्रविष्ट करा:';

  @override
  String get sabBidsSuccessfullySubmitHoGaye =>
      'All bids submitted successfully!';

  @override
  String get bidSubmitFailHoGaya => 'Bid submission failed.';

  @override
  String get pleaseEnterAmount => 'Please enter an Amount.';

  @override
  String get unexpectedErrorDuringBidSubmission =>
      'बोली सबमिशन दरम्यान अप्रत्याशित त्रुटी आली.';

  @override
  String get enterSingleDigit => 'एक अंक प्रविष्ट करा:';

  @override
  String get enterSingleDigitHint => 'एक अंक प्रविष्ट करा';

  @override
  String get errorColon => 'त्रुटी:';

  @override
  String get points10To1000KeBechDo => 'Points must be between 10 and 1000.';

  @override
  String get easyMode => 'सोपा मोड';

  @override
  String get specialMode => 'विशेष मोड';

  @override
  String get enterSinglePanna => 'सिंगल पन्ना प्रविष्ट करा:';

  @override
  String get bidPanna => 'बोली पन्ना';

  @override
  String get totalPointsColon => 'एकूण गुण:';

  @override
  String get biddingIsClosedForThisSlot => 'या स्लॉटसाठी बोली बंद आहे.';

  @override
  String get pleaseFillAllFields => 'कृपया सर्व फील्ड भरा.';

  @override
  String get pleaseEnterValidSinglePanna =>
      'कृपया वैध सिंगल पन्ना क्रमांक प्रविष्ट करा.';

  @override
  String get updatedAmountForPanna => 'पन्ना साठी अद्यतनित रक्कम:';

  @override
  String get addedBidPanna => 'बोली जोडली: पन्ना';

  @override
  String get pleaseAddAtLeastOneBidToConfirm =>
      'कृपया पुष्टी करण्यासाठी किमान एक बोली जोडा.';

  @override
  String get insufficientWalletBalanceForAllBids =>
      'सर्व बोलीसाठी अपुरे वॉलेट शिल्लक.';

  @override
  String get and => 'आणि';

  @override
  String get enterYourMobileNumber => 'तुमचा मोबाइल नंबर प्रविष्ट करा';

  @override
  String get registerAndLogin => 'नोंदणी करा आणि लॉगिन करा';

  @override
  String get username => 'वापरकर्तानाव';

  @override
  String get password => 'पासवर्ड';

  @override
  String get enterValidMobileNumber => 'वैध मोबाइल नंबर प्रविष्ट करा';

  @override
  String get createNewAccount => 'नवीन खाते तयार करा';
}
