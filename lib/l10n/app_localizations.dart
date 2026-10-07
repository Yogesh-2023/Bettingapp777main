import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('te'),
  ];

  /// Title for language selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Hindi language name
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// Bengali language name
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get bengali;

  /// Marathi language name
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get marathi;

  /// Telugu language name
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get telugu;

  /// Tamil language name
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// Welcome text on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome To'**
  String get welcomeTo;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'India\'s best Satta Matka Application\nWelcomes you !!!'**
  String get indiasBestSattaMatka;

  /// Phone number label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Phone number hint
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get enterPhoneNumber;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// Trust badge text
  ///
  /// In en, this message translates to:
  /// **'Trusted by 1 Lakh Users'**
  String get trustedBy1LakhUsers;

  /// Validation error for empty mobile
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get mobileNumberRequired;

  /// Validation error for invalid mobile
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get enterValid10DigitMobile;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server Error: {statusCode}'**
  String serverError(int statusCode);

  /// Timeout error message
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Check internet.'**
  String get requestTimedOut;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// Home menu item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// My Bids menu item
  ///
  /// In en, this message translates to:
  /// **'My Bids'**
  String get myBids;

  /// MPIN menu item
  ///
  /// In en, this message translates to:
  /// **'M-PIN'**
  String get mpin;

  /// Passbook menu item
  ///
  /// In en, this message translates to:
  /// **'Passbook'**
  String get passbook;

  /// Funds menu item
  ///
  /// In en, this message translates to:
  /// **'Funds'**
  String get funds;

  /// Videos menu item
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// Game Rates menu item
  ///
  /// In en, this message translates to:
  /// **'Game Rates'**
  String get gameRates;

  /// Charts menu item
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get charts;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Share app menu item
  ///
  /// In en, this message translates to:
  /// **'Share Application'**
  String get shareApplication;

  /// Logout menu item
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// King Starline button
  ///
  /// In en, this message translates to:
  /// **'KING STARLINE'**
  String get kingStarline;

  /// King Jackpot button
  ///
  /// In en, this message translates to:
  /// **'King Jackpot'**
  String get kingJackpot;

  /// Play game button
  ///
  /// In en, this message translates to:
  /// **'Play Game'**
  String get playGame;

  /// Open bid label
  ///
  /// In en, this message translates to:
  /// **'Open Bid'**
  String get openBid;

  /// Betting is running status
  ///
  /// In en, this message translates to:
  /// **'Betting is running'**
  String get bettingIsRunning;

  /// Close bid label
  ///
  /// In en, this message translates to:
  /// **'Close Bid'**
  String get closeBid;

  /// Market closed status
  ///
  /// In en, this message translates to:
  /// **'Market Closed'**
  String get marketClosed;

  /// Open bids time label
  ///
  /// In en, this message translates to:
  /// **'Open Bids:'**
  String get openBids;

  /// Close bids time label
  ///
  /// In en, this message translates to:
  /// **'Close Bids:'**
  String get closeBids;

  /// Error message when data fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading data.'**
  String get errorLoadingData;

  /// Message when no games are available
  ///
  /// In en, this message translates to:
  /// **'No game data available.'**
  String get noGameDataAvailable;

  /// Notification settings section title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Main notification toggle
  ///
  /// In en, this message translates to:
  /// **'Main Notification'**
  String get mainNotification;

  /// Game notification toggle
  ///
  /// In en, this message translates to:
  /// **'Game Notification'**
  String get gameNotification;

  /// King Starline notification toggle
  ///
  /// In en, this message translates to:
  /// **'King Starline Notification'**
  String get kingStarlineNotification;

  /// King Jackpot notification toggle
  ///
  /// In en, this message translates to:
  /// **'King Jackpot Notification'**
  String get kingJackpotNotification;

  /// Language settings section title
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Market closed message
  ///
  /// In en, this message translates to:
  /// **'Closed for Today'**
  String get closedForToday;

  /// Open bid last time label
  ///
  /// In en, this message translates to:
  /// **'Open Bid Last Time'**
  String get openBidLastTime;

  /// Open result time label
  ///
  /// In en, this message translates to:
  /// **'Open Result Time'**
  String get openResultTime;

  /// Close bid last time label
  ///
  /// In en, this message translates to:
  /// **'Close Bid Last Time'**
  String get closeBidLastTime;

  /// Close result time label
  ///
  /// In en, this message translates to:
  /// **'Close Result Time'**
  String get closeResultTime;

  /// Good luck message
  ///
  /// In en, this message translates to:
  /// **'Good Luck'**
  String get goodLuck;

  /// Bid success message
  ///
  /// In en, this message translates to:
  /// **'Bids Placed Successfully'**
  String get bidsPlacedSuccessfully;

  /// Bid failure title
  ///
  /// In en, this message translates to:
  /// **'Bid Placement Failed!'**
  String get bidPlacementFailed;

  /// Please try again message
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get pleaseTryAgain;

  /// Dismiss button
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Market closed message with game name
  ///
  /// In en, this message translates to:
  /// **'{gameName} market is closed.'**
  String marketClosedMessage(String gameName);

  /// No bids added message
  ///
  /// In en, this message translates to:
  /// **'No Bids Added'**
  String get noBidsAdded;

  /// No data added yet message
  ///
  /// In en, this message translates to:
  /// **'No data added yet'**
  String get noDataAddedYet;

  /// Submit button
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get submit;

  /// Odd label
  ///
  /// In en, this message translates to:
  /// **'Odd'**
  String get odd;

  /// Even label
  ///
  /// In en, this message translates to:
  /// **'Even'**
  String get even;

  /// Game type label
  ///
  /// In en, this message translates to:
  /// **'Game Type'**
  String get gameType;

  /// Digit label
  ///
  /// In en, this message translates to:
  /// **'Digit'**
  String get digit;

  /// Points label
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// Bid ID label
  ///
  /// In en, this message translates to:
  /// **'Bid ID'**
  String get bidId;

  /// Bid date label
  ///
  /// In en, this message translates to:
  /// **'Bid Date'**
  String get bidDate;

  /// No entries message
  ///
  /// In en, this message translates to:
  /// **'No entries found.'**
  String get noEntriesFound;

  /// No chart data message
  ///
  /// In en, this message translates to:
  /// **'No chart data found.'**
  String get noChartDataFound;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No results message
  ///
  /// In en, this message translates to:
  /// **'No results for this date.'**
  String get noResultsForThisDate;

  /// Bids label (plural)
  ///
  /// In en, this message translates to:
  /// **'Bids'**
  String bids(Object count);

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String total(Object amount);

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile Page'**
  String get profilePage;

  /// History page title
  ///
  /// In en, this message translates to:
  /// **'History Page'**
  String get historyPage;

  /// Market bid history description
  ///
  /// In en, this message translates to:
  /// **'You can view your market bid history'**
  String get youCanViewYourMarketBidHistory;

  /// Starline bid history description
  ///
  /// In en, this message translates to:
  /// **'You can view your starline bid history'**
  String get youCanViewYourStarlineBidHistory;

  /// Jackpot bid history description
  ///
  /// In en, this message translates to:
  /// **'You can view your jackpot bid history'**
  String get youCanViewYourJackpotBidHistory;

  /// Permission granted message
  ///
  /// In en, this message translates to:
  /// **'{permission} permission granted!'**
  String permissionGranted(String permission);

  /// WhatsApp error message
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number not found.'**
  String get whatsappNumberNotFound;

  /// WhatsApp not installed message
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp. Please install the app.'**
  String get couldNotOpenWhatsapp;

  /// No videos message
  ///
  /// In en, this message translates to:
  /// **'No videos available for this language'**
  String get noVideosAvailable;

  /// No app found message
  ///
  /// In en, this message translates to:
  /// **'No app found to open this link'**
  String get noAppFoundToOpenLink;

  /// Cannot handle link message
  ///
  /// In en, this message translates to:
  /// **'Cannot handle this link'**
  String get cannotHandleLink;

  /// Screenshot saved message
  ///
  /// In en, this message translates to:
  /// **'Screenshot saved to gallery'**
  String get screenshotSavedToGallery;

  /// Screenshot failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to save screenshot'**
  String get failedToSaveScreenshot;

  /// QR payment title
  ///
  /// In en, this message translates to:
  /// **'QR Payment'**
  String get qrPayment;

  /// Save QR button
  ///
  /// In en, this message translates to:
  /// **'Save QR to Gallery'**
  String get saveQrToGallery;

  /// No deposit history message
  ///
  /// In en, this message translates to:
  /// **'No deposit history found'**
  String get noDepositHistoryFound;

  /// No withdraw history message
  ///
  /// In en, this message translates to:
  /// **'No withdraw history found.'**
  String get noWithdrawHistoryFound;

  /// Register ID missing message
  ///
  /// In en, this message translates to:
  /// **'Register ID missing. Please log in again.'**
  String get registerIdMissing;

  /// Access token not found error message
  ///
  /// In en, this message translates to:
  /// **'Access token not found. Please log in again.'**
  String get accessTokenNotFound;

  /// Register ID not found error message
  ///
  /// In en, this message translates to:
  /// **'Register ID not found. Please log in again.'**
  String get registerIdNotFound;

  /// No bids yet message
  ///
  /// In en, this message translates to:
  /// **'No bids yet'**
  String get noBidsYet;

  /// Half Sangam B label
  ///
  /// In en, this message translates to:
  /// **'Half Sangam B'**
  String get halfSangamB;

  /// Screen not found error
  ///
  /// In en, this message translates to:
  /// **'Error: Screen not found'**
  String get screenNotFound;

  /// Wallet label
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// Chat menu item
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Validation error for digit number
  ///
  /// In en, this message translates to:
  /// **'Enter valid 3–7 digit number'**
  String get enterValid3To7DigitNumber;

  /// Validation error for unique digits
  ///
  /// In en, this message translates to:
  /// **'Number must have at least 2 unique digits'**
  String get numberMustHaveAtLeast2UniqueDigits;

  /// Validation error for 3 digit number
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 3-digit number.'**
  String get enterValid3DigitNumber;

  /// Invalid triple panna number message
  ///
  /// In en, this message translates to:
  /// **'Invalid Triple Panna number.'**
  String get invalidTriplePannaNumber;

  /// Validation error for open panna
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 3-digit Open Panna.'**
  String get pleaseEnterValid3DigitOpenPanna;

  /// Validation error for close panna
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 3-digit Close Panna.'**
  String get pleaseEnterValid3DigitClosePanna;

  /// Points validation error
  ///
  /// In en, this message translates to:
  /// **'Points must be between {min} and 1000.'**
  String pointsMustBeBetween(int min);

  /// Open digit validation in Hindi
  ///
  /// In en, this message translates to:
  /// **'Open Digit ek hi hona chahiye (0-9).'**
  String get openDigitEkHiHonaChahiye;

  /// Open digit range validation in Hindi
  ///
  /// In en, this message translates to:
  /// **'Open Digit 0 se 9 ke beech do.'**
  String get openDigit0Se9KeBeechDo;

  /// Panna validation in Hindi
  ///
  /// In en, this message translates to:
  /// **'Valid 3-digit Panna do (e.g. 123).'**
  String get valid3DigitPannaDo;

  /// Points validation in Hindi
  ///
  /// In en, this message translates to:
  /// **'Points {min} se 1000 ke beech do.'**
  String pointsMinSe1000KeBeechDo(int min);

  /// Payment failure title
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// WhatsApp number unavailable message
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number not available'**
  String get whatsappNumberNotAvailable;

  /// WhatsApp launch error
  ///
  /// In en, this message translates to:
  /// **'Error launching WhatsApp'**
  String get errorLaunchingWhatsapp;

  /// Mobile number unavailable
  ///
  /// In en, this message translates to:
  /// **'Mobile number is not available'**
  String get mobileNumberNotAvailable;

  /// Share app subject
  ///
  /// In en, this message translates to:
  /// **'Check out the Sara 777 App!'**
  String get checkOutSara777App;

  /// Share app message
  ///
  /// In en, this message translates to:
  /// **'I\'m loving Sara 777 App\n\nDownload App now\n\nFrom:-\nhttps://admin.mhmatka.app'**
  String get imLovingSara777App;

  /// Open session
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Close session
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Session label
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// Remove button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Please wait message
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Failed message
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next page button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextPage;

  /// Previous button
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter button
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Sort button
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No internet message
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Insufficient balance message
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get insufficientBalance;

  /// Invalid input message
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInput;

  /// Select game type label without colon
  ///
  /// In en, this message translates to:
  /// **'Select Game Type'**
  String get selectGameType;

  /// Select digit prompt
  ///
  /// In en, this message translates to:
  /// **'Select Digit'**
  String get selectDigit;

  /// Enter points label
  ///
  /// In en, this message translates to:
  /// **'Enter Points:'**
  String get enterPoints;

  /// Total points label
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// Total amount label
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// Wallet balance before deduction label
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance Before Deduction'**
  String get walletBalanceBeforeDeduction;

  /// Wallet balance after deduction label
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance After Deduction'**
  String get walletBalanceAfterDeduction;

  /// Note about bid cancellation
  ///
  /// In en, this message translates to:
  /// **'*Note: Bid Once Played Will Not Be Cancelled'**
  String get noteBidOncePlayedWillNotBeCancelled;

  /// Confirm bid button
  ///
  /// In en, this message translates to:
  /// **'Confirm Bid'**
  String get confirmBid;

  /// Bid details title
  ///
  /// In en, this message translates to:
  /// **'Bid Details'**
  String get bidDetails;

  /// Game name label
  ///
  /// In en, this message translates to:
  /// **'Game Name'**
  String get gameName;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Result label
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// Win status
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get win;

  /// Loss status
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get loss;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Enter open panna label
  ///
  /// In en, this message translates to:
  /// **'Enter Open Panna :'**
  String get enterOpenPanna;

  /// Enter close panna label
  ///
  /// In en, this message translates to:
  /// **'Enter Close Panna :'**
  String get enterClosePanna;

  /// Sangam label
  ///
  /// In en, this message translates to:
  /// **'Sangam'**
  String get sangam;

  /// Bid label
  ///
  /// In en, this message translates to:
  /// **'Bid'**
  String get bid;

  /// Please add at least one bid message
  ///
  /// In en, this message translates to:
  /// **'Please add at least one bid.'**
  String get pleaseAddAtLeastOneBid;

  /// Insufficient wallet balance to place bid message
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance to place this bid.'**
  String get insufficientWalletBalanceToPlaceBid;

  /// Updated points message
  ///
  /// In en, this message translates to:
  /// **'Updated points for {sangam}.'**
  String updatedPointsFor(String sangam);

  /// Added bid message
  ///
  /// In en, this message translates to:
  /// **'Added bid: {sangam} with {points} points.'**
  String addedBidWithPoints(String sangam, String points);

  /// Bid removed message
  ///
  /// In en, this message translates to:
  /// **'Bid for {sangam} removed from list.'**
  String bidRemovedFromList(String sangam);

  /// Screen not mounted error
  ///
  /// In en, this message translates to:
  /// **'Screen not mounted.'**
  String get screenNotMounted;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication error: Please log in again.'**
  String get authenticationErrorPleaseLoginAgain;

  /// No valid bids message
  ///
  /// In en, this message translates to:
  /// **'No valid bids to submit.'**
  String get noValidBidsToSubmit;

  /// Unexpected error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedErrorOccurred(String error);

  /// Ank label
  ///
  /// In en, this message translates to:
  /// **'Ank'**
  String get ank;

  /// Pana label
  ///
  /// In en, this message translates to:
  /// **'Pana'**
  String get pana;

  /// Add bid button
  ///
  /// In en, this message translates to:
  /// **'ADD BID'**
  String get addBid;

  /// Panna Ank label
  ///
  /// In en, this message translates to:
  /// **'Panna - Ank'**
  String get pannaAnk;

  /// Panna Digit label
  ///
  /// In en, this message translates to:
  /// **'Panna - Digit'**
  String get pannaDigit;

  /// Type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Half Sangam A label
  ///
  /// In en, this message translates to:
  /// **'Half Sangam A'**
  String get halfSangamA;

  /// No bids added yet message
  ///
  /// In en, this message translates to:
  /// **'No Bids Added Yet'**
  String get noBidsAddedYet;

  /// No bids placed message
  ///
  /// In en, this message translates to:
  /// **'No Bids Placed'**
  String get noBidsPlaced;

  /// Ank one digit required message
  ///
  /// In en, this message translates to:
  /// **'Ank 1 digit ka do (0–9).'**
  String get ankOneDigitRequired;

  /// Ank between 0 and 9 message
  ///
  /// In en, this message translates to:
  /// **'Ank 0 se 9 ke beech do.'**
  String get ankBetween0And9;

  /// Adding will exceed wallet balance message
  ///
  /// In en, this message translates to:
  /// **'Itna add karne se total wallet se zyada ho jayega.'**
  String get addingThisWillExceedWalletBalance;

  /// Updated ank panna message
  ///
  /// In en, this message translates to:
  /// **'Updated: {ank}-{panna}.'**
  String updatedAnkPanna(String ank, String panna);

  /// Added ank panna with points message
  ///
  /// In en, this message translates to:
  /// **'Added: {ank}-{panna} — {pts} pts.'**
  String addedAnkPannaWithPoints(String ank, String panna, String pts);

  /// Removed ank panna message
  ///
  /// In en, this message translates to:
  /// **'Removed {ank}-{panna}.'**
  String removedAnkPanna(String ank, String panna);

  /// Please add at least one bid first message
  ///
  /// In en, this message translates to:
  /// **'Pehle kam se kam 1 bid add karo.'**
  String get pleaseAddAtLeastOneBidFirst;

  /// Wallet balance low message
  ///
  /// In en, this message translates to:
  /// **'Wallet balance is low.'**
  String get walletBalanceLow;

  /// Auth issue please login again message
  ///
  /// In en, this message translates to:
  /// **'Auth issue — login dobara karo.'**
  String get authIssuePleaseLoginAgain;

  /// Enter open digit label
  ///
  /// In en, this message translates to:
  /// **'Enter Open Digit :'**
  String get enterOpenDigit;

  /// Removed sangam message
  ///
  /// In en, this message translates to:
  /// **'Removed {sangam}.'**
  String removedSangam(String sangam);

  /// Enter amount hint text
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// Insufficient wallet balance message
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance.'**
  String get insufficientWalletBalance;

  /// No bids to submit message
  ///
  /// In en, this message translates to:
  /// **'No bids to submit.'**
  String get noBidsToSubmit;

  /// No panas returned message
  ///
  /// In en, this message translates to:
  /// **'No panas returned for this digit.'**
  String get noPanasReturnedForDigit;

  /// Bids for digit added message
  ///
  /// In en, this message translates to:
  /// **'{count} bids for digit {digit} added!'**
  String bidsForDigitAdded(int count, String digit);

  /// Failed to add bulk bids message
  ///
  /// In en, this message translates to:
  /// **'Failed to add bulk bids.'**
  String get failedToAddBulkBids;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error: {error}'**
  String networkError(String error);

  /// Bid for pana removed message
  ///
  /// In en, this message translates to:
  /// **'Bid for Pana {pana} removed.'**
  String bidForPanaRemoved(String pana);

  /// Some or all bids failed message
  ///
  /// In en, this message translates to:
  /// **'Some or all bids failed to submit. Please try again.'**
  String get someOrAllBidsFailed;

  /// All bids submitted successfully message
  ///
  /// In en, this message translates to:
  /// **'All bids submitted successfully!'**
  String get allBidsSubmittedSuccessfully;

  /// No bids placed yet tap number message
  ///
  /// In en, this message translates to:
  /// **'No bids placed yet. Tap a number!'**
  String get noBidsPlacedYetTapNumber;

  /// Bids label (simple text)
  ///
  /// In en, this message translates to:
  /// **'Bids'**
  String get bidsLabel;

  /// Enter valid double pana message
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Double Pana (3-digit) number.'**
  String get enterValidDoublePana;

  /// Updated digit session message
  ///
  /// In en, this message translates to:
  /// **'Updated: {digit} ({session})'**
  String updatedDigitSession(String digit, String session);

  /// Added digit session message
  ///
  /// In en, this message translates to:
  /// **'Added: {digit} ({session})'**
  String addedDigitSession(String digit, String session);

  /// Removed digit session message
  ///
  /// In en, this message translates to:
  /// **'Removed: {digit} ({session})'**
  String removedDigitSession(String digit, String session);

  /// Removed digit message
  ///
  /// In en, this message translates to:
  /// **'Removed {digit}'**
  String removedDigit(String digit);

  /// No entries yet add data message
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Add some data!'**
  String get noEntriesYetAddData;

  /// Enter 3 digit number label
  ///
  /// In en, this message translates to:
  /// **'Enter 3-Digit Number'**
  String get enter3DigitNumber;

  /// Enter 3 digit number label with colon
  ///
  /// In en, this message translates to:
  /// **'Enter 3-Digit Number:'**
  String get enter3DigitNumberColon;

  /// Game type label
  ///
  /// In en, this message translates to:
  /// **'Game Type'**
  String get gameTypeLabel;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// Points label
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsLabel;

  /// Please select odd or even message
  ///
  /// In en, this message translates to:
  /// **'Please select Odd or Even.'**
  String get pleaseSelectOddOrEven;

  /// Added group session message
  ///
  /// In en, this message translates to:
  /// **'Added {group} ({session}): {digits}'**
  String addedGroupSession(String group, String session, String digits);

  /// Removed digit type message
  ///
  /// In en, this message translates to:
  /// **'Removed {digit} ({type}).'**
  String removedDigitType(String digit, String type);

  /// No bid added yet message
  ///
  /// In en, this message translates to:
  /// **'No bid added yet'**
  String get noBidAddedYet;

  /// Bidding is closed for slot message
  ///
  /// In en, this message translates to:
  /// **'Bidding is closed for this slot.'**
  String get biddingIsClosedForSlot;

  /// Please enter valid single digit message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid single digit (0-9).'**
  String get pleaseEnterValidSingleDigit;

  /// Please enter an amount message
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount.'**
  String get pleaseEnterAnAmount;

  /// Amount must be number message
  ///
  /// In en, this message translates to:
  /// **'Amount must be a number.'**
  String get amountMustBeNumber;

  /// Amount must be between message
  ///
  /// In en, this message translates to:
  /// **'Amount must be between {min} and {max}.'**
  String amountMustBeBetween(int min, int max);

  /// Insufficient wallet balance to place bids message
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance to place these bids.'**
  String get insufficientWalletBalanceToPlaceBids;

  /// Updated digit amount message
  ///
  /// In en, this message translates to:
  /// **'Updated digit {digit} amount to {points}.'**
  String updatedDigitAmount(String digit, int points);

  /// Added bid digit amount message
  ///
  /// In en, this message translates to:
  /// **'Added bid: Digit {digit}, Amount {points}.'**
  String addedBidDigitAmount(String digit, int points);

  /// Removed bid digit message
  ///
  /// In en, this message translates to:
  /// **'Removed bid: Digit {digit}.'**
  String removedBidDigit(String digit);

  /// Please add at least one bid before submitting message
  ///
  /// In en, this message translates to:
  /// **'Please add at least one bid before submitting.'**
  String get pleaseAddAtLeastOneBidBeforeSubmitting;

  /// Insufficient wallet balance to submit message
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance to submit.'**
  String get insufficientWalletBalanceToSubmit;

  /// Bid placed successfully message
  ///
  /// In en, this message translates to:
  /// **'Bid placed successfully!'**
  String get bidPlacedSuccessfully;

  /// Unknown error occurred message
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred.'**
  String get unknownErrorOccurred;

  /// Enters single digit label
  ///
  /// In en, this message translates to:
  /// **'Enters Single Digit:'**
  String get entersSingleDigit;

  /// Enter digit hint
  ///
  /// In en, this message translates to:
  /// **'Enter Digit'**
  String get enterDigit;

  /// Points 10 to 1000 ke beech do message
  ///
  /// In en, this message translates to:
  /// **'Points 10–1000 ke beech do.'**
  String get points10To1000KeBeechDo;

  /// Bid type bid added message
  ///
  /// In en, this message translates to:
  /// **'{bidType} bid added!'**
  String bidTypeBidAdded(String bidType);

  /// Entry deleted message
  ///
  /// In en, this message translates to:
  /// **'Entry deleted.'**
  String get entryDeleted;

  /// Pehle koi entry add karo message
  ///
  /// In en, this message translates to:
  /// **'Pehle koi entry add karo.'**
  String get pehleKoiEntryAddKaro;

  /// Remove bid type set tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove this {bidType} set'**
  String removeThisBidTypeSet(String bidType);

  /// Enter jodi label
  ///
  /// In en, this message translates to:
  /// **'Enter Jodi:'**
  String get enterJodi;

  /// Enter jodi hint
  ///
  /// In en, this message translates to:
  /// **'Enter Jodi'**
  String get enterJodiHint;

  /// Please enter valid 2 digit jodi message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 2-digit Jodi.'**
  String get pleaseEnterValid2DigitJodi;

  /// Jodi already exists message
  ///
  /// In en, this message translates to:
  /// **'Jodi {jodi} already exists.'**
  String jodiAlreadyExists(String jodi);

  /// Added jodi message
  ///
  /// In en, this message translates to:
  /// **'Added: {jodi}'**
  String addedJodi(String jodi);

  /// Bid for jodi removed message
  ///
  /// In en, this message translates to:
  /// **'Bid for Jodi {jodi} removed.'**
  String bidForJodiRemoved(String jodi);

  /// Please wait bid submission in progress message
  ///
  /// In en, this message translates to:
  /// **'Please wait, a bid submission is in progress.'**
  String get pleaseWaitBidSubmissionInProgress;

  /// Jodi digit must be exactly 2 numbers message
  ///
  /// In en, this message translates to:
  /// **'Jodi digit must be exactly 2 numbers (00-99).'**
  String get jodiDigitMustBeExactly2Numbers;

  /// Jodi must be number between 00 and 99 message
  ///
  /// In en, this message translates to:
  /// **'Jodi must be a number between 00 and 99.'**
  String get jodiMustBeNumberBetween00And99;

  /// Please enter valid points message
  ///
  /// In en, this message translates to:
  /// **'Please enter valid points.'**
  String get pleaseEnterValidPoints;

  /// Points must be between 10 and 10000 message
  ///
  /// In en, this message translates to:
  /// **'Points must be between 10 and 10000.'**
  String get pointsMustBeBetween10And10000;

  /// Insufficient wallet balance for this bid message
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance for this bid.'**
  String get insufficientWalletBalanceForThisBid;

  /// Jodi with points added message
  ///
  /// In en, this message translates to:
  /// **'Jodi {digit} with {points} points added.'**
  String jodiWithPointsAdded(String digit, String points);

  /// Jodi points updated message
  ///
  /// In en, this message translates to:
  /// **'Jodi {digit} points updated to {points}.'**
  String jodiPointsUpdatedTo(String digit, String points);

  /// Cannot remove bid while submission in progress message
  ///
  /// In en, this message translates to:
  /// **'Cannot remove bid while submission is in progress.'**
  String get cannotRemoveBidWhileSubmissionInProgress;

  /// Jodi removed message
  ///
  /// In en, this message translates to:
  /// **'Jodi {digit} removed.'**
  String jodiRemoved(String digit);

  /// Submitting your bids message
  ///
  /// In en, this message translates to:
  /// **'Submitting your bids...'**
  String get submittingYourBids;

  /// Bid failed please try again message
  ///
  /// In en, this message translates to:
  /// **'Bid failed. Please try again.'**
  String get bidFailedPleaseTryAgain;

  /// Network error or unexpected issue message
  ///
  /// In en, this message translates to:
  /// **'Network error or unexpected issue: {error}'**
  String networkErrorOrUnexpectedIssue(String error);

  /// Enter jodi digit label
  ///
  /// In en, this message translates to:
  /// **'Enter Jodi Digit:'**
  String get enterJodiDigit;

  /// Bid digits hint text
  ///
  /// In en, this message translates to:
  /// **'Bid Digits'**
  String get bidDigits;

  /// Please enter valid 3 digit number message
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 3-digit number.'**
  String get pleaseEnterValid3DigitNumber;

  /// No bids added to submit message
  ///
  /// In en, this message translates to:
  /// **'No bids added to submit.'**
  String get noBidsAddedToSubmit;

  /// Updated bid for digit message
  ///
  /// In en, this message translates to:
  /// **'Updated bid for {digit}.'**
  String updatedBidForDigit(String digit);

  /// Added bid digit points message
  ///
  /// In en, this message translates to:
  /// **'Added bid: {digit} - {points} points'**
  String addedBidDigitPoints(String digit, int points);

  /// Removed bid digit only message
  ///
  /// In en, this message translates to:
  /// **'Removed bid: {digit}'**
  String removedBidDigitOnly(String digit);

  /// Enter 3 digit triple panna hint
  ///
  /// In en, this message translates to:
  /// **'Enter 3-Digit Triple Panna'**
  String get enter3DigitTriplePanna;

  /// Enter 3 digit triple panna label
  ///
  /// In en, this message translates to:
  /// **'Enter 3-Digit Triple Panna:'**
  String get enter3DigitTriplePannaColon;

  /// Please select SP DP or TP message
  ///
  /// In en, this message translates to:
  /// **'Please select SP, DP, or TP.'**
  String get pleaseSelectSPDPOrTP;

  /// Digit must be number 0 to 9 message
  ///
  /// In en, this message translates to:
  /// **'Digit must be a number from 0 to 9.'**
  String get digitMustBeNumber0To9;

  /// Added bids for category message
  ///
  /// In en, this message translates to:
  /// **'{count} bids added for {category}.'**
  String addedBidsForCategory(int count, String category);

  /// Please add bids before submitting message
  ///
  /// In en, this message translates to:
  /// **'Please add bids before submitting.'**
  String get pleaseAddBidsBeforeSubmitting;

  /// Please enter number message
  ///
  /// In en, this message translates to:
  /// **'Please enter a number.'**
  String get pleaseEnterNumber;

  /// Please enter valid number message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number (3-7 digits).'**
  String get pleaseEnterValidNumber;

  /// Number must contain two unique digits message
  ///
  /// In en, this message translates to:
  /// **'The number must contain at least two unique digits.'**
  String get numberMustContainTwoUniqueDigits;

  /// No valid bids found message
  ///
  /// In en, this message translates to:
  /// **'No valid bids found for this number.'**
  String get noValidBidsFound;

  /// Added bids from API response message
  ///
  /// In en, this message translates to:
  /// **'Added {count} bids from API response.'**
  String addedBidsFromApiResponse(int count);

  /// All bids already exist message
  ///
  /// In en, this message translates to:
  /// **'All bids already exist.'**
  String get allBidsAlreadyExist;

  /// Bid request failed message
  ///
  /// In en, this message translates to:
  /// **'Bid request failed with status: {statusCode}'**
  String bidRequestFailed(int statusCode);

  /// Removed bid number type message
  ///
  /// In en, this message translates to:
  /// **'Removed bid: Number {number}, Type {type}.'**
  String removedBidNumberType(String number, String type);

  /// No bids added for selected game type message
  ///
  /// In en, this message translates to:
  /// **'No bids added for the selected game type to submit.'**
  String get noBidsAddedForSelectedGameType;

  /// Insufficient wallet balance for selected game type message
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance for selected game type.'**
  String get insufficientWalletBalanceForSelectedGameType;

  /// No valid bids message
  ///
  /// In en, this message translates to:
  /// **'No valid bids for the selected game type.'**
  String get noValidBidsForSelectedGameType;

  /// Enter number label
  ///
  /// In en, this message translates to:
  /// **'Enter Number:'**
  String get enterNumber;

  /// Hint text for number input field
  ///
  /// In en, this message translates to:
  /// **'Enter Number'**
  String get enterNumberHint;

  /// Count label
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// Wallet balance low message
  ///
  /// In en, this message translates to:
  /// **'Wallet balance is low.'**
  String get walletBalanceKamHai;

  /// Enter single pana hint
  ///
  /// In en, this message translates to:
  /// **'Enter Single Pana'**
  String get enterSinglePanaHint;

  /// Bid time label
  ///
  /// In en, this message translates to:
  /// **'Bid Time :'**
  String get bidTime;

  /// Bid result time label
  ///
  /// In en, this message translates to:
  /// **'Bid Result Time :'**
  String get bidResultTime;

  /// Payment success title
  ///
  /// In en, this message translates to:
  /// **'Payment Success'**
  String get paymentSuccess;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Account recovery title
  ///
  /// In en, this message translates to:
  /// **'Account Recovery'**
  String get accountRecovery;

  /// Account recovery message
  ///
  /// In en, this message translates to:
  /// **'Recover your existing account by setting a new MPIN\n\nDo you want to continue?'**
  String get accountRecoveryMessage;

  /// Recover button
  ///
  /// In en, this message translates to:
  /// **'RECOVER'**
  String get recover;

  /// Wallet fund history not available message
  ///
  /// In en, this message translates to:
  /// **'Wallet Fund History Not Available'**
  String get walletFundHistoryNotAvailable;

  /// Terms and conditions title
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Minimum withdraw amount term
  ///
  /// In en, this message translates to:
  /// **'Minimum Withdraw Amount is 1000 ₹'**
  String get minimumWithdrawAmount;

  /// Maximum withdraw amount term
  ///
  /// In en, this message translates to:
  /// **'& Maximum Withdraw Amount is 500000'**
  String get maximumWithdrawAmount;

  /// Above 5 lakh manual request term
  ///
  /// In en, this message translates to:
  /// **'Above 5 Lakh You Should Request Us Manually.'**
  String get above5LakhManualRequest;

  /// Withdraw request timing term
  ///
  /// In en, this message translates to:
  /// **'Withdraw Request Timing 09:00 AM To 10:00 PM'**
  String get withdrawRequestTiming;

  /// Process time term
  ///
  /// In en, this message translates to:
  /// **'Process Time Minimum 1 Hour Maximum 72 Hours.'**
  String get processTime;

  /// Withdraw available all days term
  ///
  /// In en, this message translates to:
  /// **'Withdraw Is Available On All 7 Days Of Week.'**
  String get withdrawAvailableAllDays;

  /// Accept button
  ///
  /// In en, this message translates to:
  /// **'ACCEPT'**
  String get accept;

  /// Add fund title
  ///
  /// In en, this message translates to:
  /// **'ADD FUND'**
  String get addFund;

  /// Add money button text
  ///
  /// In en, this message translates to:
  /// **'ADD MONEY'**
  String get addMoney;

  /// Available balance label
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// Add point via UPI button
  ///
  /// In en, this message translates to:
  /// **'ADD POINT - UPI'**
  String get addPointUpi;

  /// Add point via QR Paytm Gateway button
  ///
  /// In en, this message translates to:
  /// **'ADD POINT - QR - PAYTM - GATEWAY'**
  String get addPointQrPaytmGateway;

  /// How to add point button
  ///
  /// In en, this message translates to:
  /// **'HOW TO ADD POINT'**
  String get howToAddPoint;

  /// Contact support message for adding point
  ///
  /// In en, this message translates to:
  /// **'Please contact support to know how to add point.'**
  String get pleaseContactSupportToKnowHowToAddPoint;

  /// Select UPI app title
  ///
  /// In en, this message translates to:
  /// **'Select UPI App'**
  String get selectUpiApp;

  /// UPI app default name
  ///
  /// In en, this message translates to:
  /// **'UPI App'**
  String get upiApp;

  /// Add funds description
  ///
  /// In en, this message translates to:
  /// **'Add funds'**
  String get addFunds;

  /// UPI payee details not configured message
  ///
  /// In en, this message translates to:
  /// **'UPI payee details not configured.'**
  String get upiPayeeDetailsNotConfigured;

  /// Invalid UPI ID format message
  ///
  /// In en, this message translates to:
  /// **'Invalid UPI ID format'**
  String get invalidUpiIdFormat;

  /// Please enter valid amount with minimum
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount (min ₹{amount}).'**
  String pleaseEnterValidAmountMin(String amount);

  /// No UPI apps found message
  ///
  /// In en, this message translates to:
  /// **'No UPI apps found. Please install a UPI app to proceed.'**
  String get noUpiAppsFound;

  /// Payment failed or cancelled message
  ///
  /// In en, this message translates to:
  /// **'Payment failed or cancelled.'**
  String get paymentFailedOrCancelled;

  /// Error occurred during UPI payment
  ///
  /// In en, this message translates to:
  /// **'An error occurred during UPI payment: {error}'**
  String errorOccurredDuringUpiPayment(String error);

  /// RangeError occurred during UPI payment message
  ///
  /// In en, this message translates to:
  /// **'RangeError occurred during UPI payment. Please try again.'**
  String get rangeErrorOccurredDuringUpiPayment;

  /// Failed to launch UPI app message
  ///
  /// In en, this message translates to:
  /// **'Failed to launch UPI app due to unexpected error.'**
  String get failedToLaunchUpiApp;

  /// Invalid server response message
  ///
  /// In en, this message translates to:
  /// **'Invalid server response (missing paymentHash/timestamp).'**
  String get invalidServerResponse;

  /// Deposit successful message
  ///
  /// In en, this message translates to:
  /// **'Deposit successful and updated'**
  String get depositSuccessfulAndUpdated;

  /// Failed to add deposit fund message
  ///
  /// In en, this message translates to:
  /// **'Failed to add deposit fund'**
  String get failedToAddDepositFund;

  /// Failed to create fund request message
  ///
  /// In en, this message translates to:
  /// **'Failed to create fund request (HTTP {code})'**
  String failedToCreateFundRequest(int code);

  /// Failed to complete payment process message
  ///
  /// In en, this message translates to:
  /// **'Failed to complete payment process: {error}'**
  String failedToCompletePaymentProcess(String error);

  /// Please enter valid amount message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get pleaseEnterValidAmount;

  /// Please enter amount greater than or equal message
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount greater than or equal to ₹{amount}.'**
  String pleaseEnterAmountGreaterThanOrEqual(int amount);

  /// Invalid mobile number found message
  ///
  /// In en, this message translates to:
  /// **'Invalid mobile number found.'**
  String get invalidMobileNumberFound;

  /// Payment link not found message
  ///
  /// In en, this message translates to:
  /// **'Payment link not found in response.'**
  String get paymentLinkNotFoundInResponse;

  /// Failed to create transaction link message
  ///
  /// In en, this message translates to:
  /// **'Failed to create transaction link.'**
  String get failedToCreateTransactionLink;

  /// Bank details title
  ///
  /// In en, this message translates to:
  /// **'BANK DETAILS'**
  String get bankDetails;

  /// Account holder name label
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get accountHolderName;

  /// Account number label
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// Enter account number hint
  ///
  /// In en, this message translates to:
  /// **'Enter Account Number'**
  String get enterAccountNumber;

  /// IFSC code label
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get ifscCode;

  /// Bank name label
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// Enter bank name hint
  ///
  /// In en, this message translates to:
  /// **'Enter Bank Name'**
  String get enterBankName;

  /// Branch name label
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branchName;

  /// Enter branch name hint
  ///
  /// In en, this message translates to:
  /// **'Enter Branch Name'**
  String get enterBranchName;

  /// Add bank button
  ///
  /// In en, this message translates to:
  /// **'Add Bank'**
  String get addBank;

  /// Fund deposit history title
  ///
  /// In en, this message translates to:
  /// **'Fund Deposit History'**
  String get fundDepositHistory;

  /// Narration label
  ///
  /// In en, this message translates to:
  /// **'Narration'**
  String get narration;

  /// Withdraw funds option
  ///
  /// In en, this message translates to:
  /// **'Withdraw Funds'**
  String get withdrawFunds;

  /// Deposit history option
  ///
  /// In en, this message translates to:
  /// **'Deposit History'**
  String get depositHistory;

  /// Withdraw history option
  ///
  /// In en, this message translates to:
  /// **'Withdraw History'**
  String get withdrawHistory;

  /// Fund withdraw history title
  ///
  /// In en, this message translates to:
  /// **'Fund Withdraw History'**
  String get fundWithdrawHistory;

  /// Withdraw mode label
  ///
  /// In en, this message translates to:
  /// **'Withdraw Mode'**
  String get withdrawMode;

  /// UPI ID label
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get upiId;

  /// Account holder label
  ///
  /// In en, this message translates to:
  /// **'A/C Holder'**
  String get acHolder;

  /// Account number short label
  ///
  /// In en, this message translates to:
  /// **'A/C No.'**
  String get acNo;

  /// Manual approve by admin message
  ///
  /// In en, this message translates to:
  /// **'Manual approve by Admin'**
  String get manualApproveByAdmin;

  /// Enter Google Pay UPI ID hint
  ///
  /// In en, this message translates to:
  /// **'Enter Google Pay UPI ID'**
  String get enterGooglePayUpiId;

  /// Enter PhonePe UPI ID hint
  ///
  /// In en, this message translates to:
  /// **'Enter PhonePe UPI ID'**
  String get enterPhonepeUpiId;

  /// Enter Paytm number hint
  ///
  /// In en, this message translates to:
  /// **'Enter Paytm Number'**
  String get enterPaytmNumber;

  /// Enter UPI ID/Number hint
  ///
  /// In en, this message translates to:
  /// **'Enter UPI ID/Number'**
  String get enterUpiIdNumber;

  /// Please login again message
  ///
  /// In en, this message translates to:
  /// **'Please log in again to continue.'**
  String get pleaseLoginAgainToContinue;

  /// Minimum withdrawal amount message
  ///
  /// In en, this message translates to:
  /// **'Minimum withdrawal amount is ₹{amount}.'**
  String minimumWithdrawalAmountIs(int amount);

  /// Please enter Google Pay UPI ID message
  ///
  /// In en, this message translates to:
  /// **'Please enter Google Pay UPI ID.'**
  String get pleaseEnterGooglePayUpiId;

  /// Please enter PhonePe UPI ID message
  ///
  /// In en, this message translates to:
  /// **'Please enter PhonePe UPI ID.'**
  String get pleaseEnterPhonepeUpiId;

  /// Please enter Paytm number message
  ///
  /// In en, this message translates to:
  /// **'Please enter Paytm Number.'**
  String get pleaseEnterPaytmNumber;

  /// Please fill all bank details message
  ///
  /// In en, this message translates to:
  /// **'Please fill all bank details.'**
  String get pleaseFillAllBankDetails;

  /// Please select withdrawal method message
  ///
  /// In en, this message translates to:
  /// **'Please select a withdrawal method.'**
  String get pleaseSelectWithdrawalMethod;

  /// Withdrawal request submitted successfully message
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request submitted successfully!'**
  String get withdrawalRequestSubmittedSuccessfully;

  /// Withdrawal request failed message
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request failed.'**
  String get withdrawalRequestFailed;

  /// An error occurred message
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String anErrorOccurred(String error);

  /// Jackpot Dashboard title
  ///
  /// In en, this message translates to:
  /// **'Jackpot Dashboard'**
  String get jackpotDashboard;

  /// History button/label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Notifications label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Jodi label
  ///
  /// In en, this message translates to:
  /// **'Jodi'**
  String get jodi;

  /// Closed status
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// Running status
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No jackpot bid types available message
  ///
  /// In en, this message translates to:
  /// **'No jackpot bid types available or failed to load.'**
  String get noJackpotBidTypesAvailable;

  /// The market for prefix
  ///
  /// In en, this message translates to:
  /// **'The market for'**
  String get theMarketFor;

  /// is currently closed suffix
  ///
  /// In en, this message translates to:
  /// **'is currently closed.'**
  String get isCurrentlyClosed;

  /// Failed to load jackpot bid types message
  ///
  /// In en, this message translates to:
  /// **'Failed to load jackpot bid types:'**
  String get failedToLoadJackpotBidTypes;

  /// No screen configured for game type message
  ///
  /// In en, this message translates to:
  /// **'No screen configured for game type:'**
  String get noScreenConfiguredForGameType;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again later.'**
  String get networkErrorPleaseTryAgainLater;

  /// Failed to load games error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load games'**
  String get failedToLoadGames;

  /// Single Digit game name
  ///
  /// In en, this message translates to:
  /// **'Single Digit'**
  String get singleDigit;

  /// Single Pana game name
  ///
  /// In en, this message translates to:
  /// **'Single Pana'**
  String get singlePana;

  /// Double Pana game name
  ///
  /// In en, this message translates to:
  /// **'Double Pana'**
  String get doublePana;

  /// Triple Pana game name
  ///
  /// In en, this message translates to:
  /// **'Triple Pana'**
  String get triplePana;

  /// Choice SP DP TP game name
  ///
  /// In en, this message translates to:
  /// **'Choice SP DP TP'**
  String get choiceSpDpTp;

  /// SP Motor game name
  ///
  /// In en, this message translates to:
  /// **'SP Motor'**
  String get spMotor;

  /// DP Motor game name
  ///
  /// In en, this message translates to:
  /// **'DP Motor'**
  String get dpMotor;

  /// TP Motor game name
  ///
  /// In en, this message translates to:
  /// **'TP Motor'**
  String get tpMotor;

  /// Full Sangam game name
  ///
  /// In en, this message translates to:
  /// **'Full Sangam'**
  String get fullSangam;

  /// Half Sangam game name
  ///
  /// In en, this message translates to:
  /// **'Half Sangam'**
  String get halfSangam;

  /// Single Digits Bulk game name
  ///
  /// In en, this message translates to:
  /// **'Single Digits Bulk'**
  String get singleDigitsBulk;

  /// Jodi Bulk game name
  ///
  /// In en, this message translates to:
  /// **'Jodi Bulk'**
  String get jodiBulk;

  /// Single Pana Bulk game name
  ///
  /// In en, this message translates to:
  /// **'Single Pana Bulk'**
  String get singlePanaBulk;

  /// Double Pana Bulk game name
  ///
  /// In en, this message translates to:
  /// **'Double Pana Bulk'**
  String get doublePanaBulk;

  /// Two Digit Panel game name
  ///
  /// In en, this message translates to:
  /// **'Two Digit Panel'**
  String get twoDigitPanel;

  /// Odd Even game name
  ///
  /// In en, this message translates to:
  /// **'Odd Even'**
  String get oddEven;

  /// Digit Based Jodi game name
  ///
  /// In en, this message translates to:
  /// **'Digit Based Jodi'**
  String get digitBasedJodi;

  /// Panel Group game name
  ///
  /// In en, this message translates to:
  /// **'Panel Group'**
  String get panelGroup;

  /// Red Bracket game name
  ///
  /// In en, this message translates to:
  /// **'Red Bracket'**
  String get redBracket;

  /// Group Jodi game name
  ///
  /// In en, this message translates to:
  /// **'Group Jodi'**
  String get groupJodi;

  /// Main Starline Dashboard title
  ///
  /// In en, this message translates to:
  /// **'MAIN STARLINE DASHBOARD'**
  String get mainStarlineDashboard;

  /// Notification label (singular)
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// Running now status
  ///
  /// In en, this message translates to:
  /// **'Running Now'**
  String get runningNow;

  /// Bid closed at time message
  ///
  /// In en, this message translates to:
  /// **'Bid closed at {closeTime}'**
  String bidClosedAt(String closeTime);

  /// Failed to load game data error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load game data.'**
  String get failedToLoadGameData;

  /// Create account title
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccount;

  /// Enter your details subtitle
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR DETAILS'**
  String get enterYourDetails;

  /// Enter username hint
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// Enter password hint
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// Confirm password hint
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Please enter username error message
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get pleaseEnterUsername;

  /// Please enter password error message
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// Password must be at least 6 characters error message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// Passwords do not match error message
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Verify mobile number title
  ///
  /// In en, this message translates to:
  /// **'VERIFY MOBILE\nNUMBER'**
  String get verifyMobileNumber;

  /// Enter password label
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPasswordLabel;

  /// To complete registration for text
  ///
  /// In en, this message translates to:
  /// **'To complete registration for\n'**
  String get toCompleteRegistrationFor;

  /// Enter your account password error message
  ///
  /// In en, this message translates to:
  /// **'Enter your account password.'**
  String get enterYourAccountPassword;

  /// Enter your password hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Verify button text
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get verify;

  /// Missing data restart registration error message
  ///
  /// In en, this message translates to:
  /// **'Missing data. Restart registration.'**
  String get missingDataRestartRegistration;

  /// Error verifying password message
  ///
  /// In en, this message translates to:
  /// **'Error verifying password'**
  String get errorVerifyingPassword;

  /// Registration failed error message
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// Previous button text (short)
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get prev;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Previous amount label
  ///
  /// In en, this message translates to:
  /// **'Prev Amt'**
  String get prevAmt;

  /// Transaction amount label
  ///
  /// In en, this message translates to:
  /// **'Txn Amt'**
  String get txnAmt;

  /// Current amount label
  ///
  /// In en, this message translates to:
  /// **'Cur Amt'**
  String get curAmt;

  /// Bid history page title
  ///
  /// In en, this message translates to:
  /// **'Bid History'**
  String get bidHistory;

  /// No bid entries found message
  ///
  /// In en, this message translates to:
  /// **'No bid entries found.'**
  String get noBidEntriesFound;

  /// Transaction time label
  ///
  /// In en, this message translates to:
  /// **'Transaction Time:'**
  String get transactionTime;

  /// Status label prefix
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get statusLabel;

  /// Better luck next time message
  ///
  /// In en, this message translates to:
  /// **'Better Luck Next Time'**
  String get betterLuckNextTime;

  /// Current amount full label
  ///
  /// In en, this message translates to:
  /// **'Current Amount'**
  String get currentAmount;

  /// Previous amount full label
  ///
  /// In en, this message translates to:
  /// **'Previous Amount'**
  String get previousAmount;

  /// Transaction amount full label
  ///
  /// In en, this message translates to:
  /// **'Transaction Amount'**
  String get transactionAmount;

  /// Quit dialog title
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// Quit confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to quit the app?'**
  String get areYouSureYouWantToQuitTheApp;

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No notifications found message
  ///
  /// In en, this message translates to:
  /// **'No notifications found.'**
  String get noNotificationsFound;

  /// Please enter an amount first message
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount first.'**
  String get pleaseEnterAnAmountFirst;

  /// Points validation message for 10-1000 range
  ///
  /// In en, this message translates to:
  /// **'Points must be between 10 and 1000.'**
  String get pointsMustBeBetween10And1000;

  /// Bid updated message
  ///
  /// In en, this message translates to:
  /// **'Bid for Digit {digit} ({type}) updated to {points} points.'**
  String bidForDigitUpdated(String digit, String type, String points);

  /// Added bid message
  ///
  /// In en, this message translates to:
  /// **'Added bid for Digit: {digit}, Amount: {amount}'**
  String addedBidForDigit(String digit, String amount);

  /// No bids placed yet message with instruction
  ///
  /// In en, this message translates to:
  /// **'No bids placed yet. Click a number to add a bid!'**
  String get noBidsPlacedYetClickNumber;

  /// Bids submitted successfully message
  ///
  /// In en, this message translates to:
  /// **'Bids submitted successfully!'**
  String get bidsSubmittedSuccessfully;

  /// Removed bid message
  ///
  /// In en, this message translates to:
  /// **'Removed bid for Digit: {digit}, Amount: {amount}.'**
  String removedBidForDigit(String digit, String amount);

  /// Select game type label with colon
  ///
  /// In en, this message translates to:
  /// **'Select Game Type:'**
  String get selectGameTypeColon;

  /// Enter points label with colon
  ///
  /// In en, this message translates to:
  /// **'Enter Points:'**
  String get enterPointsColon;

  /// Login with MPIN title
  ///
  /// In en, this message translates to:
  /// **'Login with MPIN'**
  String get loginWithMpin;

  /// MPIN hint text
  ///
  /// In en, this message translates to:
  /// **'MPIN'**
  String get mpinHint;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Forgot MPIN link text
  ///
  /// In en, this message translates to:
  /// **'Forgot MPIN?'**
  String get forgotMpin;

  /// Biometric not available message
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication not available or supported'**
  String get biometricAuthenticationNotAvailable;

  /// Biometric authentication reason
  ///
  /// In en, this message translates to:
  /// **'Scan your fingerprint to verify'**
  String get scanYourFingerprintToVerify;

  /// Biometric authentication failed message
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get biometricAuthenticationFailed;

  /// Biometric error message
  ///
  /// In en, this message translates to:
  /// **'Biometric error: {error}'**
  String biometricError(String error);

  /// Please enter MPIN message
  ///
  /// In en, this message translates to:
  /// **'Please enter your mPIN'**
  String get pleaseEnterYourMpin;

  /// Registration ID not found message
  ///
  /// In en, this message translates to:
  /// **'Registration ID not found. Please re-register.'**
  String get registrationIdNotFoundPleaseReregister;

  /// Access token not found message
  ///
  /// In en, this message translates to:
  /// **'Access token not found. Please re-login.'**
  String get accessTokenNotFoundPleaseRelogin;

  /// Login successful message
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccessful;

  /// Failed to verify MPIN message
  ///
  /// In en, this message translates to:
  /// **'Failed to verify mPIN. Please try again later.'**
  String get failedToVerifyMpinPleaseTryAgainLater;

  /// MPIN verification error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred during mPIN verification: {error}'**
  String errorOccurredDuringMpinVerification(String error);

  /// Invalid MPIN dialog title
  ///
  /// In en, this message translates to:
  /// **'Invalid MPIN'**
  String get invalidMpin;

  /// Please enter correct MPIN message
  ///
  /// In en, this message translates to:
  /// **'Please enter correct MPIN'**
  String get pleaseEnterCorrectMpin;

  /// Set your PIN title
  ///
  /// In en, this message translates to:
  /// **'SET YOUR\nPIN'**
  String get setYourPin;

  /// Enter new MPIN label
  ///
  /// In en, this message translates to:
  /// **'Enter New mPin'**
  String get enterNewMpin;

  /// Enter 4-digit MPIN hint
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit mPin'**
  String get enter4DigitMpin;

  /// Set PIN button text
  ///
  /// In en, this message translates to:
  /// **'SET PIN'**
  String get setPin;

  /// Please enter valid 4-digit PIN validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 4-digit PIN'**
  String get pleaseEnterValid4DigitPin;

  /// Something went wrong error message with placeholder
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String somethingWentWrongWithError(String error);

  /// Change new MPIN title
  ///
  /// In en, this message translates to:
  /// **'Change New MPIN'**
  String get changeNewMpin;

  /// Enter 4-digit PIN hint
  ///
  /// In en, this message translates to:
  /// **'Enter 4-digit PIN'**
  String get enter4DigitPin;

  /// Error message with placeholder
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithPlaceholder(String error);

  /// Could not launch URL error message
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl(String url);

  /// Single game type label
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// Single Panna game type label
  ///
  /// In en, this message translates to:
  /// **'Single Panna'**
  String get singlePanna;

  /// Double Panna game type label
  ///
  /// In en, this message translates to:
  /// **'Double Panna'**
  String get doublePanna;

  /// Triple Panna game type label
  ///
  /// In en, this message translates to:
  /// **'Triple Panna'**
  String get triplePanna;

  /// Game win ratio section title
  ///
  /// In en, this message translates to:
  /// **'Game Win Ratio for All Bids'**
  String get gameWinRatioForAllBids;

  /// Starline win ratio section title
  ///
  /// In en, this message translates to:
  /// **'Starline Win Ratio for All Bids'**
  String get starlineWinRatioForAllBids;

  /// Jackpot win ratio section title
  ///
  /// In en, this message translates to:
  /// **'Jackpot Win Ratio'**
  String get jackpotWinRatio;

  /// Game rate format string
  ///
  /// In en, this message translates to:
  /// **'{label}: 10 Ka {value}'**
  String rateFormat(String label, String value);

  /// Failed to load game rates error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load game rates: {statusCode}'**
  String failedToLoadGameRates(int statusCode);

  /// Withdrawal time window message
  ///
  /// In en, this message translates to:
  /// **'You can withdraw between {startTime} and {endTime}.'**
  String youCanWithdrawBetween(String startTime, String endTime);

  /// Bid for Jodi added successfully message
  ///
  /// In en, this message translates to:
  /// **'Bid for Jodi {jodi} added successfully!'**
  String bidForJodiAddedSuccessfully(String jodi);

  /// Bid failed message
  ///
  /// In en, this message translates to:
  /// **'Bid failed.'**
  String get bidFailed;

  /// Submit bid button text
  ///
  /// In en, this message translates to:
  /// **'SUBMIT BID'**
  String get submitBid;

  /// Total bids label with count
  ///
  /// In en, this message translates to:
  /// **'Total Bids:\n{count}'**
  String totalBidsWithCount(int count);

  /// Validation message for empty pana input
  ///
  /// In en, this message translates to:
  /// **'Please enter at least one 3-digit pana number.'**
  String get pleaseEnterAtLeastOneThreeDigitPanaNumber;

  /// Enter pana number label
  ///
  /// In en, this message translates to:
  /// **'Enter Pana Number:'**
  String get enterPanaNumberColon;

  /// Invalid pana error message
  ///
  /// In en, this message translates to:
  /// **'Invalid pana: {digit}'**
  String invalidPanaWithDigit(String digit);

  /// No valid panas returned error
  ///
  /// In en, this message translates to:
  /// **'No valid panas returned from server.'**
  String get noValidPanasReturnedFromServer;

  /// Added bids success message
  ///
  /// In en, this message translates to:
  /// **'Added {count} bid(s).'**
  String addedBidsCount(int count);

  /// Removed pana digit message
  ///
  /// In en, this message translates to:
  /// **'Removed {digit}'**
  String removedPanaDigit(String digit);

  /// Network error message for connection check
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkErrorCheckInternet;

  /// Hint text for pana input field
  ///
  /// In en, this message translates to:
  /// **'e.g., 123, 445'**
  String get enterPanaExampleHint;

  /// Amount validation message for 10-10000 range
  ///
  /// In en, this message translates to:
  /// **'Amount must be between 10 and 10000.'**
  String get amountMustBeBetween10And10000;

  /// Bids added success message
  ///
  /// In en, this message translates to:
  /// **'Bids added.'**
  String get bidsAdded;

  /// Add failed error message
  ///
  /// In en, this message translates to:
  /// **'Add failed'**
  String get addFailed;

  /// Please add bids first message
  ///
  /// In en, this message translates to:
  /// **'Please add some bids first.'**
  String get pleaseAddSomeBidsFirst;

  /// Half bracket type label
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get half;

  /// Full bracket type label
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// Bids label with colon
  ///
  /// In en, this message translates to:
  /// **'Bids:'**
  String get bidsColon;

  /// Total label with colon
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get totalColon;

  /// Place bid failed error message
  ///
  /// In en, this message translates to:
  /// **'Place bid failed'**
  String get placeBidFailed;

  /// Validation message for SP Motor number input
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number (minimum 3 digits).'**
  String get pleaseEnterValidNumberMinimum3Digits;

  /// Bids added from API success message
  ///
  /// In en, this message translates to:
  /// **'Bids added from API.'**
  String get bidsAddedFromApi;

  /// Request failed error message
  ///
  /// In en, this message translates to:
  /// **'Request failed.'**
  String get requestFailed;

  /// Validation message for all three digits
  ///
  /// In en, this message translates to:
  /// **'Please enter all three digits.'**
  String get pleaseEnterAllThreeDigits;

  /// Validation message for single digit
  ///
  /// In en, this message translates to:
  /// **'Each digit must be a single number (0-9).'**
  String get eachDigitMustBeSingleNumber;

  /// Please select category message
  ///
  /// In en, this message translates to:
  /// **'Please select SP, DP or TP.'**
  String get pleaseSelectSPDPTP;

  /// Please select session message
  ///
  /// In en, this message translates to:
  /// **'Please select OPEN/CLOSE.'**
  String get pleaseSelectOpenClose;

  /// SP validation message
  ///
  /// In en, this message translates to:
  /// **'SP must have 3 unique digits.'**
  String get spMustHave3UniqueDigits;

  /// DP validation message
  ///
  /// In en, this message translates to:
  /// **'DP must have exactly two same digits.'**
  String get dpMustHaveExactlyTwoSameDigits;

  /// TP validation message
  ///
  /// In en, this message translates to:
  /// **'TP must have all 3 digits same.'**
  String get tpMustHaveAll3DigitsSame;

  /// Updated panna message
  ///
  /// In en, this message translates to:
  /// **'Updated: {panna} ({category} {session})'**
  String updatedPannaCategorySession(
    String panna,
    String category,
    String session,
  );

  /// Added panna message
  ///
  /// In en, this message translates to:
  /// **'Added: {panna} ({category} {session})'**
  String addedPannaCategorySession(
    String panna,
    String category,
    String session,
  );

  /// Removed panna message
  ///
  /// In en, this message translates to:
  /// **'Removed: {panna} ({category} {session})'**
  String removedPannaCategorySession(
    String panna,
    String category,
    String session,
  );

  /// Enter left digit label
  ///
  /// In en, this message translates to:
  /// **'Enter Left Digit'**
  String get enterLeftDigit;

  /// Enter middle digit label
  ///
  /// In en, this message translates to:
  /// **'Enter Middle Digit'**
  String get enterMiddleDigit;

  /// Enter right digit label
  ///
  /// In en, this message translates to:
  /// **'Enter Right Digit'**
  String get enterRightDigit;

  /// Panna label
  ///
  /// In en, this message translates to:
  /// **'Panna'**
  String get panna;

  /// Validation message for 2-digit Jodi input
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 2-digit Jodi (00-99).'**
  String get pleaseEnterValid2DigitJodi0099;

  /// Points minimum validation message
  ///
  /// In en, this message translates to:
  /// **'Points must be at least 10.'**
  String get pointsMustBeAtLeast10;

  /// Jodis added success message
  ///
  /// In en, this message translates to:
  /// **'Jodis added successfully!'**
  String get jodisAddedSuccessfully;

  /// Removed jodi message
  ///
  /// In en, this message translates to:
  /// **'Removed {jodi}.'**
  String removedJodi(String jodi);

  /// No entries yet message
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Add some data!'**
  String get noEntriesYetAddSomeData;

  /// Left digit label
  ///
  /// In en, this message translates to:
  /// **'Left Digit'**
  String get leftDigit;

  /// Right digit label
  ///
  /// In en, this message translates to:
  /// **'Right Digit'**
  String get rightDigit;

  /// Digits label
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get digits;

  /// Validation message for 2-digit number input
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 2-digit number (00-99).'**
  String get twoDigitNumberDo0099;

  /// Points validation message for 10-10000 range
  ///
  /// In en, this message translates to:
  /// **'Points must be between 10 and 10000.'**
  String get points10Se10000KeBechMeDo;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please log in again.'**
  String get authIssueDobaraLoginKaro;

  /// No pana found message
  ///
  /// In en, this message translates to:
  /// **'No pana found for this 2-digit number.'**
  String get is2DigitKeliyeKoiPanaNahiMila;

  /// Insufficient wallet balance message
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance.'**
  String get walletMeItnePointsNahiHai;

  /// Pana added message
  ///
  /// In en, this message translates to:
  /// **'{count} pana(s) added.'**
  String panaAddHue(int count);

  /// Amounts updated message
  ///
  /// In en, this message translates to:
  /// **'Amounts updated.'**
  String get amountsUpdateHoGaye;

  /// Pana fetch failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch pana.'**
  String get panaFetchFail;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again later.'**
  String get networkErrorThodiDerBaadTryKaro;

  /// Pana removed message
  ///
  /// In en, this message translates to:
  /// **'Pana {pana} removed.'**
  String panaRemoveHoGaya(String pana);

  /// Please add pana before submit message
  ///
  /// In en, this message translates to:
  /// **'Please add some pana before submitting.'**
  String get submitSePehleKuchPanaAddKaro;

  /// Two Digits Panel game type
  ///
  /// In en, this message translates to:
  /// **'Two Digits Panel'**
  String get twoDigitsPanel;

  /// Enter two digits label
  ///
  /// In en, this message translates to:
  /// **'Enter Two Digits:'**
  String get enterTwoDigits;

  /// All bids submitted successfully message
  ///
  /// In en, this message translates to:
  /// **'All bids submitted successfully!'**
  String get sabBidsSuccessfullySubmitHoGaye;

  /// Bid submission failed message
  ///
  /// In en, this message translates to:
  /// **'Bid submission failed.'**
  String get bidSubmitFailHoGaya;

  /// Please enter amount message
  ///
  /// In en, this message translates to:
  /// **'Please enter an Amount.'**
  String get pleaseEnterAmount;

  /// Unexpected error during bid submission message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during bid submission.'**
  String get unexpectedErrorDuringBidSubmission;

  /// Enter single digit label
  ///
  /// In en, this message translates to:
  /// **'Enter Single Digit:'**
  String get enterSingleDigit;

  /// Enter single digit hint text
  ///
  /// In en, this message translates to:
  /// **'Enter Single Digit'**
  String get enterSingleDigitHint;

  /// Error label with colon
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get errorColon;

  /// Points validation message for 10-1000 range
  ///
  /// In en, this message translates to:
  /// **'Points must be between 10 and 1000.'**
  String get points10To1000KeBechDo;

  /// Easy mode label
  ///
  /// In en, this message translates to:
  /// **'Easy Mode'**
  String get easyMode;

  /// Special mode label
  ///
  /// In en, this message translates to:
  /// **'Special Mode'**
  String get specialMode;

  /// Enter single panna label
  ///
  /// In en, this message translates to:
  /// **'Enter Single Panna:'**
  String get enterSinglePanna;

  /// Bid panna hint
  ///
  /// In en, this message translates to:
  /// **'Bid Panna'**
  String get bidPanna;

  /// Total points label with colon
  ///
  /// In en, this message translates to:
  /// **'Total Points:'**
  String get totalPointsColon;

  /// Bidding closed message
  ///
  /// In en, this message translates to:
  /// **'Bidding is closed for this slot.'**
  String get biddingIsClosedForThisSlot;

  /// Fill all fields validation
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get pleaseFillAllFields;

  /// Valid single panna validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Single Panna number.'**
  String get pleaseEnterValidSinglePanna;

  /// Updated amount message
  ///
  /// In en, this message translates to:
  /// **'Updated amount for Panna:'**
  String get updatedAmountForPanna;

  /// Added bid message
  ///
  /// In en, this message translates to:
  /// **'Added bid: Panna'**
  String get addedBidPanna;

  /// Add at least one bid message
  ///
  /// In en, this message translates to:
  /// **'Please add at least one bid to confirm.'**
  String get pleaseAddAtLeastOneBidToConfirm;

  /// Insufficient balance for all bids
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance for all bids.'**
  String get insufficientWalletBalanceForAllBids;

  /// And conjunction
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// Enter your mobile number title
  ///
  /// In en, this message translates to:
  /// **'ENTER YOUR MOBILE NUMBER'**
  String get enterYourMobileNumber;

  /// Register and login button text
  ///
  /// In en, this message translates to:
  /// **'Register & Login'**
  String get registerAndLogin;

  /// Username label/hint
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Password label/hint
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Enter valid mobile number validation message
  ///
  /// In en, this message translates to:
  /// **'Enter valid mobile number'**
  String get enterValidMobileNumber;

  /// Create new account title
  ///
  /// In en, this message translates to:
  /// **'CREATE NEW ACCOUNT'**
  String get createNewAccount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
