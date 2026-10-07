// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get skip => 'Skip';

  @override
  String get continueButton => 'Continue';

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
  String get welcomeTo => 'Welcome To';

  @override
  String get indiasBestSattaMatka =>
      'India\'s best Satta Matka Application\nWelcomes you !!!';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter Phone Number';

  @override
  String get next => 'NEXT';

  @override
  String get trustedBy1LakhUsers => 'Trusted by 1 Lakh Users';

  @override
  String get mobileNumberRequired => 'Mobile number is required';

  @override
  String get enterValid10DigitMobile => 'Enter a valid 10-digit mobile number';

  @override
  String serverError(int statusCode) {
    return 'Server Error: $statusCode';
  }

  @override
  String get requestTimedOut => 'Request timed out. Check internet.';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get home => 'Home';

  @override
  String get myBids => 'My Bids';

  @override
  String get mpin => 'M-PIN';

  @override
  String get passbook => 'Passbook';

  @override
  String get funds => 'Funds';

  @override
  String get videos => 'Videos';

  @override
  String get gameRates => 'Game Rates';

  @override
  String get charts => 'Charts';

  @override
  String get settings => 'Settings';

  @override
  String get shareApplication => 'Share Application';

  @override
  String get logout => 'Logout';

  @override
  String get kingStarline => 'KING STARLINE';

  @override
  String get kingJackpot => 'King Jackpot';

  @override
  String get playGame => 'Play Game';

  @override
  String get openBid => 'Open Bid';

  @override
  String get bettingIsRunning => 'Betting is running';

  @override
  String get closeBid => 'Close Bid';

  @override
  String get marketClosed => 'Market Closed';

  @override
  String get openBids => 'Open Bids:';

  @override
  String get closeBids => 'Close Bids:';

  @override
  String get errorLoadingData => 'Error loading data.';

  @override
  String get noGameDataAvailable => 'No game data available.';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get mainNotification => 'Main Notification';

  @override
  String get gameNotification => 'Game Notification';

  @override
  String get kingStarlineNotification => 'King Starline Notification';

  @override
  String get kingJackpotNotification => 'King Jackpot Notification';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get ok => 'OK';

  @override
  String get closedForToday => 'Closed for Today';

  @override
  String get openBidLastTime => 'Open Bid Last Time';

  @override
  String get openResultTime => 'Open Result Time';

  @override
  String get closeBidLastTime => 'Close Bid Last Time';

  @override
  String get closeResultTime => 'Close Result Time';

  @override
  String get goodLuck => 'Good Luck';

  @override
  String get bidsPlacedSuccessfully => 'Bids Placed Successfully';

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
  String get noBidsAdded => 'No Bids Added';

  @override
  String get noDataAddedYet => 'No data added yet';

  @override
  String get submit => 'SUBMIT';

  @override
  String get odd => 'Odd';

  @override
  String get even => 'Even';

  @override
  String get gameType => 'Game Type';

  @override
  String get digit => 'Digit';

  @override
  String get points => 'Points';

  @override
  String get bidId => 'Bid ID';

  @override
  String get bidDate => 'Bid Date';

  @override
  String get noEntriesFound => 'No entries found.';

  @override
  String get noChartDataFound => 'No chart data found.';

  @override
  String error(String error) {
    return 'Error: $error';
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
  String get historyPage => 'History Page';

  @override
  String get youCanViewYourMarketBidHistory =>
      'You can view your market bid history';

  @override
  String get youCanViewYourStarlineBidHistory =>
      'You can view your starline bid history';

  @override
  String get youCanViewYourJackpotBidHistory =>
      'You can view your jackpot bid history';

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
  String get noWithdrawHistoryFound => 'No withdraw history found.';

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
  String get halfSangamB => 'Half Sangam B';

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
      'Please enter a valid 3-digit Open Panna.';

  @override
  String get pleaseEnterValid3DigitClosePanna =>
      'Please enter a valid 3-digit Close Panna.';

  @override
  String pointsMustBeBetween(int min) {
    return 'Points must be between $min and 1000.';
  }

  @override
  String get openDigitEkHiHonaChahiye => 'Open Digit ek hi hona chahiye (0-9).';

  @override
  String get openDigit0Se9KeBeechDo => 'Open Digit 0 se 9 ke beech do.';

  @override
  String get valid3DigitPannaDo => 'Valid 3-digit Panna do (e.g. 123).';

  @override
  String pointsMinSe1000KeBeechDo(int min) {
    return 'Points $min se 1000 ke beech do.';
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
  String get nextPage => 'Next';

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
  String get enterPoints => 'Enter Points:';

  @override
  String get totalPoints => 'Total Points';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get walletBalanceBeforeDeduction => 'Wallet Balance Before Deduction';

  @override
  String get walletBalanceAfterDeduction => 'Wallet Balance After Deduction';

  @override
  String get noteBidOncePlayedWillNotBeCancelled =>
      '*Note: Bid Once Played Will Not Be Cancelled';

  @override
  String get confirmBid => 'Confirm Bid';

  @override
  String get bidDetails => 'Bid Details';

  @override
  String get gameName => 'Game Name';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get status => 'Status';

  @override
  String get amount => 'Amount';

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
  String get enterOpenPanna => 'Enter Open Panna :';

  @override
  String get enterClosePanna => 'Enter Close Panna :';

  @override
  String get sangam => 'Sangam';

  @override
  String get bid => 'Bid';

  @override
  String get pleaseAddAtLeastOneBid => 'Please add at least one bid.';

  @override
  String get insufficientWalletBalanceToPlaceBid =>
      'Insufficient wallet balance to place this bid.';

  @override
  String updatedPointsFor(String sangam) {
    return 'Updated points for $sangam.';
  }

  @override
  String addedBidWithPoints(String sangam, String points) {
    return 'Added bid: $sangam with $points points.';
  }

  @override
  String bidRemovedFromList(String sangam) {
    return 'Bid for $sangam removed from list.';
  }

  @override
  String get screenNotMounted => 'Screen not mounted.';

  @override
  String get authenticationErrorPleaseLoginAgain =>
      'Authentication error: Please log in again.';

  @override
  String get noValidBidsToSubmit => 'No valid bids to submit.';

  @override
  String unexpectedErrorOccurred(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get ank => 'Ank';

  @override
  String get pana => 'Pana';

  @override
  String get addBid => 'ADD BID';

  @override
  String get pannaAnk => 'Panna - Ank';

  @override
  String get pannaDigit => 'Panna - Digit';

  @override
  String get type => 'Type';

  @override
  String get halfSangamA => 'Half Sangam A';

  @override
  String get noBidsAddedYet => 'No Bids Added Yet';

  @override
  String get noBidsPlaced => 'No Bids Placed';

  @override
  String get ankOneDigitRequired => 'Ank 1 digit ka do (0–9).';

  @override
  String get ankBetween0And9 => 'Ank 0 se 9 ke beech do.';

  @override
  String get addingThisWillExceedWalletBalance =>
      'Itna add karne se total wallet se zyada ho jayega.';

  @override
  String updatedAnkPanna(String ank, String panna) {
    return 'Updated: $ank-$panna.';
  }

  @override
  String addedAnkPannaWithPoints(String ank, String panna, String pts) {
    return 'Added: $ank-$panna — $pts pts.';
  }

  @override
  String removedAnkPanna(String ank, String panna) {
    return 'Removed $ank-$panna.';
  }

  @override
  String get pleaseAddAtLeastOneBidFirst => 'Pehle kam se kam 1 bid add karo.';

  @override
  String get walletBalanceLow => 'Wallet balance is low.';

  @override
  String get authIssuePleaseLoginAgain => 'Auth issue — login dobara karo.';

  @override
  String get enterOpenDigit => 'Enter Open Digit :';

  @override
  String removedSangam(String sangam) {
    return 'Removed $sangam.';
  }

  @override
  String get enterAmount => 'Enter Amount';

  @override
  String get insufficientWalletBalance => 'Insufficient wallet balance.';

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
  String get bidsLabel => 'Bids';

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
    return 'Removed: $digit ($session)';
  }

  @override
  String removedDigit(String digit) {
    return 'Removed $digit';
  }

  @override
  String get noEntriesYetAddData => 'No entries yet. Add some data!';

  @override
  String get enter3DigitNumber => 'Enter 3-Digit Number';

  @override
  String get enter3DigitNumberColon => 'Enter 3-Digit Number:';

  @override
  String get gameTypeLabel => 'Game Type';

  @override
  String get amountLabel => 'Amount';

  @override
  String get pointsLabel => 'Points';

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
      'Please enter a valid single digit (0-9).';

  @override
  String get pleaseEnterAnAmount => 'Please enter an amount.';

  @override
  String get amountMustBeNumber => 'Amount must be a number.';

  @override
  String amountMustBeBetween(int min, int max) {
    return 'Amount must be between $min and $max.';
  }

  @override
  String get insufficientWalletBalanceToPlaceBids =>
      'Insufficient wallet balance to place these bids.';

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
      'Please add at least one bid before submitting.';

  @override
  String get insufficientWalletBalanceToSubmit =>
      'Insufficient wallet balance to submit.';

  @override
  String get bidPlacedSuccessfully => 'Bid placed successfully!';

  @override
  String get unknownErrorOccurred => 'Unknown error occurred.';

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
  String get enterJodi => 'Enter Jodi:';

  @override
  String get enterJodiHint => 'Enter Jodi';

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
      'Please wait, a bid submission is in progress.';

  @override
  String get jodiDigitMustBeExactly2Numbers =>
      'Jodi digit must be exactly 2 numbers (00-99).';

  @override
  String get jodiMustBeNumberBetween00And99 =>
      'Jodi must be a number between 00 and 99.';

  @override
  String get pleaseEnterValidPoints => 'Please enter valid points.';

  @override
  String get pointsMustBeBetween10And10000 =>
      'Points must be between 10 and 10000.';

  @override
  String get insufficientWalletBalanceForThisBid =>
      'Insufficient wallet balance for this bid.';

  @override
  String jodiWithPointsAdded(String digit, String points) {
    return 'Jodi $digit with $points points added.';
  }

  @override
  String jodiPointsUpdatedTo(String digit, String points) {
    return 'Jodi $digit points updated to $points.';
  }

  @override
  String get cannotRemoveBidWhileSubmissionInProgress =>
      'Cannot remove bid while submission is in progress.';

  @override
  String jodiRemoved(String digit) {
    return 'Jodi $digit removed.';
  }

  @override
  String get submittingYourBids => 'Submitting your bids...';

  @override
  String get bidFailedPleaseTryAgain => 'Bid failed. Please try again.';

  @override
  String networkErrorOrUnexpectedIssue(String error) {
    return 'Network error or unexpected issue: $error';
  }

  @override
  String get enterJodiDigit => 'Enter Jodi Digit:';

  @override
  String get bidDigits => 'Bid Digits';

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
  String get enter3DigitTriplePanna => 'Enter 3-Digit Triple Panna';

  @override
  String get enter3DigitTriplePannaColon => 'Enter 3-Digit Triple Panna:';

  @override
  String get pleaseSelectSPDPOrTP => 'Please select SP, DP, or TP.';

  @override
  String get digitMustBeNumber0To9 => 'Digit must be a number from 0 to 9.';

  @override
  String addedBidsForCategory(int count, String category) {
    return '$count bids added for $category.';
  }

  @override
  String get pleaseAddBidsBeforeSubmitting =>
      'Please add bids before submitting.';

  @override
  String get pleaseEnterNumber => 'Please enter a number.';

  @override
  String get pleaseEnterValidNumber =>
      'Please enter a valid number (3-7 digits).';

  @override
  String get numberMustContainTwoUniqueDigits =>
      'The number must contain at least two unique digits.';

  @override
  String get noValidBidsFound => 'No valid bids found for this number.';

  @override
  String addedBidsFromApiResponse(int count) {
    return 'Added $count bids from API response.';
  }

  @override
  String get allBidsAlreadyExist => 'All bids already exist.';

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
      'No valid bids for the selected game type.';

  @override
  String get enterNumber => 'Enter Number:';

  @override
  String get enterNumberHint => 'Enter Number';

  @override
  String get count => 'Count';

  @override
  String get walletBalanceKamHai => 'Wallet balance is low.';

  @override
  String get enterSinglePanaHint => 'Enter Single Pana';

  @override
  String get bidTime => 'Bid Time :';

  @override
  String get bidResultTime => 'Bid Result Time :';

  @override
  String get paymentSuccess => 'Payment Success';

  @override
  String get done => 'Done';

  @override
  String get accountRecovery => 'Account Recovery';

  @override
  String get accountRecoveryMessage =>
      'Recover your existing account by setting a new MPIN\n\nDo you want to continue?';

  @override
  String get recover => 'RECOVER';

  @override
  String get walletFundHistoryNotAvailable =>
      'Wallet Fund History Not Available';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get minimumWithdrawAmount => 'Minimum Withdraw Amount is 1000 ₹';

  @override
  String get maximumWithdrawAmount => '& Maximum Withdraw Amount is 500000';

  @override
  String get above5LakhManualRequest =>
      'Above 5 Lakh You Should Request Us Manually.';

  @override
  String get withdrawRequestTiming =>
      'Withdraw Request Timing 09:00 AM To 10:00 PM';

  @override
  String get processTime => 'Process Time Minimum 1 Hour Maximum 72 Hours.';

  @override
  String get withdrawAvailableAllDays =>
      'Withdraw Is Available On All 7 Days Of Week.';

  @override
  String get accept => 'ACCEPT';

  @override
  String get addFund => 'ADD FUND';

  @override
  String get addMoney => 'ADD MONEY';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String get addPointUpi => 'ADD POINT - UPI';

  @override
  String get addPointQrPaytmGateway => 'ADD POINT - QR - PAYTM - GATEWAY';

  @override
  String get howToAddPoint => 'HOW TO ADD POINT';

  @override
  String get pleaseContactSupportToKnowHowToAddPoint =>
      'Please contact support to know how to add point.';

  @override
  String get selectUpiApp => 'Select UPI App';

  @override
  String get upiApp => 'UPI App';

  @override
  String get addFunds => 'Add funds';

  @override
  String get upiPayeeDetailsNotConfigured =>
      'UPI payee details not configured.';

  @override
  String get invalidUpiIdFormat => 'Invalid UPI ID format';

  @override
  String pleaseEnterValidAmountMin(String amount) {
    return 'Please enter a valid amount (min ₹$amount).';
  }

  @override
  String get noUpiAppsFound =>
      'No UPI apps found. Please install a UPI app to proceed.';

  @override
  String get paymentFailedOrCancelled => 'Payment failed or cancelled.';

  @override
  String errorOccurredDuringUpiPayment(String error) {
    return 'An error occurred during UPI payment: $error';
  }

  @override
  String get rangeErrorOccurredDuringUpiPayment =>
      'RangeError occurred during UPI payment. Please try again.';

  @override
  String get failedToLaunchUpiApp =>
      'Failed to launch UPI app due to unexpected error.';

  @override
  String get invalidServerResponse =>
      'Invalid server response (missing paymentHash/timestamp).';

  @override
  String get depositSuccessfulAndUpdated => 'Deposit successful and updated';

  @override
  String get failedToAddDepositFund => 'Failed to add deposit fund';

  @override
  String failedToCreateFundRequest(int code) {
    return 'Failed to create fund request (HTTP $code)';
  }

  @override
  String failedToCompletePaymentProcess(String error) {
    return 'Failed to complete payment process: $error';
  }

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount.';

  @override
  String pleaseEnterAmountGreaterThanOrEqual(int amount) {
    return 'Please enter an amount greater than or equal to ₹$amount.';
  }

  @override
  String get invalidMobileNumberFound => 'Invalid mobile number found.';

  @override
  String get paymentLinkNotFoundInResponse =>
      'Payment link not found in response.';

  @override
  String get failedToCreateTransactionLink =>
      'Failed to create transaction link.';

  @override
  String get bankDetails => 'BANK DETAILS';

  @override
  String get accountHolderName => 'Account Holder Name';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get enterAccountNumber => 'Enter Account Number';

  @override
  String get ifscCode => 'IFSC Code';

  @override
  String get bankName => 'Bank Name';

  @override
  String get enterBankName => 'Enter Bank Name';

  @override
  String get branchName => 'Branch Name';

  @override
  String get enterBranchName => 'Enter Branch Name';

  @override
  String get addBank => 'Add Bank';

  @override
  String get fundDepositHistory => 'Fund Deposit History';

  @override
  String get narration => 'Narration';

  @override
  String get withdrawFunds => 'Withdraw Funds';

  @override
  String get depositHistory => 'Deposit History';

  @override
  String get withdrawHistory => 'Withdraw History';

  @override
  String get fundWithdrawHistory => 'Fund Withdraw History';

  @override
  String get withdrawMode => 'Withdraw Mode';

  @override
  String get upiId => 'UPI ID';

  @override
  String get acHolder => 'A/C Holder';

  @override
  String get acNo => 'A/C No.';

  @override
  String get manualApproveByAdmin => 'Manual approve by Admin';

  @override
  String get enterGooglePayUpiId => 'Enter Google Pay UPI ID';

  @override
  String get enterPhonepeUpiId => 'Enter PhonePe UPI ID';

  @override
  String get enterPaytmNumber => 'Enter Paytm Number';

  @override
  String get enterUpiIdNumber => 'Enter UPI ID/Number';

  @override
  String get pleaseLoginAgainToContinue => 'Please log in again to continue.';

  @override
  String minimumWithdrawalAmountIs(int amount) {
    return 'Minimum withdrawal amount is ₹$amount.';
  }

  @override
  String get pleaseEnterGooglePayUpiId => 'Please enter Google Pay UPI ID.';

  @override
  String get pleaseEnterPhonepeUpiId => 'Please enter PhonePe UPI ID.';

  @override
  String get pleaseEnterPaytmNumber => 'Please enter Paytm Number.';

  @override
  String get pleaseFillAllBankDetails => 'Please fill all bank details.';

  @override
  String get pleaseSelectWithdrawalMethod =>
      'Please select a withdrawal method.';

  @override
  String get withdrawalRequestSubmittedSuccessfully =>
      'Withdrawal request submitted successfully!';

  @override
  String get withdrawalRequestFailed => 'Withdrawal request failed.';

  @override
  String anErrorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get jackpotDashboard => 'Jackpot Dashboard';

  @override
  String get history => 'History';

  @override
  String get notifications => 'Notifications';

  @override
  String get jodi => 'Jodi';

  @override
  String get closed => 'Closed';

  @override
  String get running => 'Running';

  @override
  String get noJackpotBidTypesAvailable =>
      'No jackpot bid types available or failed to load.';

  @override
  String get theMarketFor => 'The market for';

  @override
  String get isCurrentlyClosed => 'is currently closed.';

  @override
  String get failedToLoadJackpotBidTypes => 'Failed to load jackpot bid types:';

  @override
  String get noScreenConfiguredForGameType =>
      'No screen configured for game type:';

  @override
  String get networkErrorPleaseTryAgainLater =>
      'Network error. Please try again later.';

  @override
  String get failedToLoadGames => 'Failed to load games';

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
  String get createAccount => 'CREATE ACCOUNT';

  @override
  String get enterYourDetails => 'ENTER YOUR DETAILS';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get pleaseEnterUsername => 'Please enter username';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get verifyMobileNumber => 'VERIFY MOBILE\nNUMBER';

  @override
  String get enterPasswordLabel => 'Enter Password';

  @override
  String get toCompleteRegistrationFor => 'To complete registration for\n';

  @override
  String get enterYourAccountPassword => 'Enter your account password.';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get verify => 'VERIFY';

  @override
  String get missingDataRestartRegistration =>
      'Missing data. Restart registration.';

  @override
  String get errorVerifyingPassword => 'Error verifying password';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get prev => 'Prev';

  @override
  String get description => 'Description';

  @override
  String get prevAmt => 'Prev Amt';

  @override
  String get txnAmt => 'Txn Amt';

  @override
  String get curAmt => 'Cur Amt';

  @override
  String get bidHistory => 'Bid History';

  @override
  String get noBidEntriesFound => 'No bid entries found.';

  @override
  String get transactionTime => 'Transaction Time:';

  @override
  String get statusLabel => 'Status:';

  @override
  String get betterLuckNextTime => 'Better Luck Next Time';

  @override
  String get currentAmount => 'Current Amount';

  @override
  String get previousAmount => 'Previous Amount';

  @override
  String get transactionAmount => 'Transaction Amount';

  @override
  String get quit => 'Quit';

  @override
  String get areYouSureYouWantToQuitTheApp =>
      'Are you sure you want to quit the app?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get noNotificationsFound => 'No notifications found.';

  @override
  String get pleaseEnterAnAmountFirst => 'Please enter an amount first.';

  @override
  String get pointsMustBeBetween10And1000 =>
      'Points must be between 10 and 1000.';

  @override
  String bidForDigitUpdated(String digit, String type, String points) {
    return 'Bid for Digit $digit ($type) updated to $points points.';
  }

  @override
  String addedBidForDigit(String digit, String amount) {
    return 'Added bid for Digit: $digit, Amount: $amount';
  }

  @override
  String get noBidsPlacedYetClickNumber =>
      'No bids placed yet. Click a number to add a bid!';

  @override
  String get bidsSubmittedSuccessfully => 'Bids submitted successfully!';

  @override
  String removedBidForDigit(String digit, String amount) {
    return 'Removed bid for Digit: $digit, Amount: $amount.';
  }

  @override
  String get selectGameTypeColon => 'Select Game Type:';

  @override
  String get enterPointsColon => 'Enter Points:';

  @override
  String get loginWithMpin => 'Login with MPIN';

  @override
  String get mpinHint => 'MPIN';

  @override
  String get login => 'Login';

  @override
  String get forgotMpin => 'Forgot MPIN?';

  @override
  String get biometricAuthenticationNotAvailable =>
      'Biometric authentication not available or supported';

  @override
  String get scanYourFingerprintToVerify => 'Scan your fingerprint to verify';

  @override
  String get biometricAuthenticationFailed => 'Biometric authentication failed';

  @override
  String biometricError(String error) {
    return 'Biometric error: $error';
  }

  @override
  String get pleaseEnterYourMpin => 'Please enter your mPIN';

  @override
  String get registrationIdNotFoundPleaseReregister =>
      'Registration ID not found. Please re-register.';

  @override
  String get accessTokenNotFoundPleaseRelogin =>
      'Access token not found. Please re-login.';

  @override
  String get loginSuccessful => 'Login successful!';

  @override
  String get failedToVerifyMpinPleaseTryAgainLater =>
      'Failed to verify mPIN. Please try again later.';

  @override
  String errorOccurredDuringMpinVerification(String error) {
    return 'An error occurred during mPIN verification: $error';
  }

  @override
  String get invalidMpin => 'Invalid MPIN';

  @override
  String get pleaseEnterCorrectMpin => 'Please enter correct MPIN';

  @override
  String get setYourPin => 'SET YOUR\nPIN';

  @override
  String get enterNewMpin => 'Enter New mPin';

  @override
  String get enter4DigitMpin => 'Enter 4-digit mPin';

  @override
  String get setPin => 'SET PIN';

  @override
  String get pleaseEnterValid4DigitPin => 'Please enter a valid 4-digit PIN';

  @override
  String somethingWentWrongWithError(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String get changeNewMpin => 'Change New MPIN';

  @override
  String get enter4DigitPin => 'Enter 4-digit PIN';

  @override
  String errorWithPlaceholder(String error) {
    return 'Error: $error';
  }

  @override
  String couldNotLaunchUrl(String url) {
    return 'Could not launch $url';
  }

  @override
  String get single => 'Single';

  @override
  String get singlePanna => 'Single Panna';

  @override
  String get doublePanna => 'Double Panna';

  @override
  String get triplePanna => 'Triple Panna';

  @override
  String get gameWinRatioForAllBids => 'Game Win Ratio for All Bids';

  @override
  String get starlineWinRatioForAllBids => 'Starline Win Ratio for All Bids';

  @override
  String get jackpotWinRatio => 'Jackpot Win Ratio';

  @override
  String rateFormat(String label, String value) {
    return '$label: 10 Ka $value';
  }

  @override
  String failedToLoadGameRates(int statusCode) {
    return 'Failed to load game rates: $statusCode';
  }

  @override
  String youCanWithdrawBetween(String startTime, String endTime) {
    return 'You can withdraw between $startTime and $endTime.';
  }

  @override
  String bidForJodiAddedSuccessfully(String jodi) {
    return 'Bid for Jodi $jodi added successfully!';
  }

  @override
  String get bidFailed => 'Bid failed.';

  @override
  String get submitBid => 'SUBMIT BID';

  @override
  String totalBidsWithCount(int count) {
    return 'Total Bids:\n$count';
  }

  @override
  String get pleaseEnterAtLeastOneThreeDigitPanaNumber =>
      'Please enter at least one 3-digit pana number.';

  @override
  String get enterPanaNumberColon => 'Enter Pana Number:';

  @override
  String invalidPanaWithDigit(String digit) {
    return 'Invalid pana: $digit';
  }

  @override
  String get noValidPanasReturnedFromServer =>
      'No valid panas returned from server.';

  @override
  String addedBidsCount(int count) {
    return 'Added $count bid(s).';
  }

  @override
  String removedPanaDigit(String digit) {
    return 'Removed $digit';
  }

  @override
  String get networkErrorCheckInternet =>
      'Network error. Please check your internet connection.';

  @override
  String get enterPanaExampleHint => 'e.g., 123, 445';

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
  String get half => 'Half';

  @override
  String get full => 'Full';

  @override
  String get bidsColon => 'Bids:';

  @override
  String get totalColon => 'Total:';

  @override
  String get placeBidFailed => 'Place bid failed';

  @override
  String get pleaseEnterValidNumberMinimum3Digits =>
      'Please enter a valid number (minimum 3 digits).';

  @override
  String get bidsAddedFromApi => 'Bids added from API.';

  @override
  String get requestFailed => 'Request failed.';

  @override
  String get pleaseEnterAllThreeDigits => 'Please enter all three digits.';

  @override
  String get eachDigitMustBeSingleNumber =>
      'Each digit must be a single number (0-9).';

  @override
  String get pleaseSelectSPDPTP => 'Please select SP, DP or TP.';

  @override
  String get pleaseSelectOpenClose => 'Please select OPEN/CLOSE.';

  @override
  String get spMustHave3UniqueDigits => 'SP must have 3 unique digits.';

  @override
  String get dpMustHaveExactlyTwoSameDigits =>
      'DP must have exactly two same digits.';

  @override
  String get tpMustHaveAll3DigitsSame => 'TP must have all 3 digits same.';

  @override
  String updatedPannaCategorySession(
    String panna,
    String category,
    String session,
  ) {
    return 'Updated: $panna ($category $session)';
  }

  @override
  String addedPannaCategorySession(
    String panna,
    String category,
    String session,
  ) {
    return 'Added: $panna ($category $session)';
  }

  @override
  String removedPannaCategorySession(
    String panna,
    String category,
    String session,
  ) {
    return 'Removed: $panna ($category $session)';
  }

  @override
  String get enterLeftDigit => 'Enter Left Digit';

  @override
  String get enterMiddleDigit => 'Enter Middle Digit';

  @override
  String get enterRightDigit => 'Enter Right Digit';

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
  String get leftDigit => 'Left Digit';

  @override
  String get rightDigit => 'Right Digit';

  @override
  String get digits => 'Digits';

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
  String get enterTwoDigits => 'Enter Two Digits:';

  @override
  String get sabBidsSuccessfullySubmitHoGaye =>
      'All bids submitted successfully!';

  @override
  String get bidSubmitFailHoGaya => 'Bid submission failed.';

  @override
  String get pleaseEnterAmount => 'Please enter an Amount.';

  @override
  String get unexpectedErrorDuringBidSubmission =>
      'An unexpected error occurred during bid submission.';

  @override
  String get enterSingleDigit => 'Enter Single Digit:';

  @override
  String get enterSingleDigitHint => 'Enter Single Digit';

  @override
  String get errorColon => 'Error:';

  @override
  String get points10To1000KeBechDo => 'Points must be between 10 and 1000.';

  @override
  String get easyMode => 'Easy Mode';

  @override
  String get specialMode => 'Special Mode';

  @override
  String get enterSinglePanna => 'Enter Single Panna:';

  @override
  String get bidPanna => 'Bid Panna';

  @override
  String get totalPointsColon => 'Total Points:';

  @override
  String get biddingIsClosedForThisSlot => 'Bidding is closed for this slot.';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields.';

  @override
  String get pleaseEnterValidSinglePanna =>
      'Please enter a valid Single Panna number.';

  @override
  String get updatedAmountForPanna => 'Updated amount for Panna:';

  @override
  String get addedBidPanna => 'Added bid: Panna';

  @override
  String get pleaseAddAtLeastOneBidToConfirm =>
      'Please add at least one bid to confirm.';

  @override
  String get insufficientWalletBalanceForAllBids =>
      'Insufficient wallet balance for all bids.';

  @override
  String get and => 'and';

  @override
  String get enterYourMobileNumber => 'ENTER YOUR MOBILE NUMBER';

  @override
  String get registerAndLogin => 'Register & Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get enterValidMobileNumber => 'Enter valid mobile number';

  @override
  String get createNewAccount => 'CREATE NEW ACCOUNT';
}
