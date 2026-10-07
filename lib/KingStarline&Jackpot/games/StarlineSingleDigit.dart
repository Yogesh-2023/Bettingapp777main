import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_sara/KingStarline&Jackpot/StarlineBidService.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../../Helper/UserController.dart';
import '../../components/AnimatedMessageBar.dart';
import '../../components/BidConfirmationDialog.dart';
import '../../components/BidFailureDialog.dart';
import '../../components/BidSuccessDialog.dart';

/// Simple model for Starline sessions (id + human label)
class StarlineSession {
  final int id;
  final String timeLabel; // e.g., "09:30 PM"
  StarlineSession({required this.id, required this.timeLabel});
}

class StarlineSingleDigitBetScreen extends StatefulWidget {
  final String title; // e.g., "Starline Single Digit"
  final String gameCategoryType; // e.g., "singleDigits"
  final int gameId; // TYPE id (sent as STRING)
  final String gameName; // e.g., "Starline ..." / "Jackpot ..."
  final bool selectionStatus; // true => bidding open (UI)

  /// Optional Starline time-slot info (UI only; not sent to API)
  final int? starlineSessionId;
  final String? starlineSessionTimeLabel;
  final List<StarlineSession>? sessions;
  final bool autoPickSession;

  const StarlineSingleDigitBetScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameName,
    required this.gameCategoryType,
    required this.selectionStatus,
    this.starlineSessionId,
    this.starlineSessionTimeLabel,
    this.sessions,
    this.autoPickSession = true,
  });

  @override
  State<StarlineSingleDigitBetScreen> createState() =>
      _StarlineSingleDigitBetScreenState();
}

class _StarlineSingleDigitBetScreenState
    extends State<StarlineSingleDigitBetScreen> {
  /// Amount limits (minBid can be overridden from storage)
  static const int _defaultMinBet = 10;
  static const int _maxBet = 1000;
  String _selectedMode = 'Easy Mode'; // ✅ default


  // Mode selection

  // Date picker
  DateTime selectedDate = DateTime.now();

  final TextEditingController digitController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();

  // Controllers for Easy Mode - one for each digit
  final Map<String, TextEditingController> _digitControllers = {};
  final List<Map<String, String>> _easyModeEntries = [];

  // Special Mode controllers
  final TextEditingController _specialModeDigitController = TextEditingController();
  final TextEditingController _specialModePointsController = TextEditingController();
  final List<Map<String, String>> _specialModeEntries = [];

  final List<String> _digitOptions = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];
  List<String> _filteredDigitOptions = [];
  bool _isDigitSuggestionsVisible = false;

  /// Local entries: {digit, points}
  final List<Map<String, String>> _addedEntries = [];

  late final GetStorage _storage = GetStorage();
  late final StarlineBidService _bidService;

  late String _registerId;
  bool _accountStatus = false;
  late int _walletBalance;
  bool _isApiCalling = false;

  String? _messageToShow;
  bool _isErrorForMessage = false;
  Key _messageBarKey = UniqueKey();
  Timer? _messageDismissTimer;

  final UserController userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  // Worker to react to controller updates
  Worker? _walletWorker;

  // UI-only (if provided); not required for API
  String? _resolvedSessionTime;

  @override
  void initState() {
    super.initState();
    _bidService = StarlineBidService(_storage);

    // ---- Wallet source of truth: UserController ----
    // Initial value: try controller first, then storage (digits only)
    double walletBalance = double.parse(userController.walletBalance.value);
    int walletBalanceInt = walletBalance.toInt();
    _walletBalance = walletBalanceInt;

    _loadInitialData();
    digitController.addListener(_onDigitChanged);
    _resolveSessionLabelForUi();

    // Initialize controllers for each digit in Easy Mode
    for (String digit in _digitOptions) {
      _digitControllers[digit] = TextEditingController();
    }
  }

  void _resolveSessionLabelForUi() {
    // show a time label if we can; purely cosmetic
    _resolvedSessionTime = widget.starlineSessionTimeLabel;
    if (_resolvedSessionTime == null &&
        (widget.sessions?.isNotEmpty ?? false) &&
        widget.autoPickSession) {
      final now = DateTime.now();
      final fmt = DateFormat('hh:mm a');
      for (final s in widget.sessions!) {
        try {
          final t = fmt.parse(s.timeLabel);
          final candidate = DateTime(
            now.year,
            now.month,
            now.day,
            t.hour,
            t.minute,
          );
          if (!candidate.isBefore(now)) {
            _resolvedSessionTime = s.timeLabel;
            break;
          }
        } catch (_) {}
      }
    }
  }

  Future<void> _loadInitialData() async {
    _registerId = _storage.read('registerId') ?? '';
    _accountStatus = userController.accountStatus.value;
  }

  @override
  void dispose() {
    digitController.removeListener(_onDigitChanged);
    digitController.dispose();
    pointsController.dispose();
    _specialModeDigitController.dispose();
    _specialModePointsController.dispose();
    for (var controller in _digitControllers.values) {
      controller.dispose();
    }
    _messageDismissTimer?.cancel();
    _walletWorker?.dispose();
    super.dispose();
  }

  // -------- helpers --------
  Market _detectMarket() {
    final s = ('${widget.title} ${widget.gameName}').toLowerCase();
    return s.contains('jackpot') ? Market.jackpot : Market.starline;
  }

  bool get _biddingClosed => !widget.selectionStatus;

  void _onDigitChanged() {
    final text = digitController.text;
    if (text.isEmpty) {
      setState(() {
        _filteredDigitOptions = [];
        _isDigitSuggestionsVisible = false;
      });
      return;
    }
    setState(() {
      _filteredDigitOptions = _digitOptions
          .where((o) => o.startsWith(text))
          .toList();
      _isDigitSuggestionsVisible = _filteredDigitOptions.isNotEmpty;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    _messageDismissTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _messageToShow = message;
      _isErrorForMessage = isError;
      _messageBarKey = UniqueKey();
    });
    _messageDismissTimer = Timer(const Duration(seconds: 3), _clearMessage);
  }

  void _clearMessage() {
    if (!mounted) return;
    setState(() => _messageToShow = null);
    _messageDismissTimer?.cancel();
  }

  void _updateEasyModeBids() {
    _easyModeEntries.clear();

    for (String digit in _digitOptions) {
      final points = _digitControllers[digit]!.text.trim();
      if (points.isNotEmpty) {
        final fromStorage = int.tryParse(_storage.read('minBid')?.toString() ?? '') ?? _defaultMinBet;
        final minBid = fromStorage > 0 ? fromStorage : _defaultMinBet;
        int? parsedPoints = int.tryParse(points);
        if (parsedPoints != null && parsedPoints >= minBid && parsedPoints <= _maxBet) {
          _easyModeEntries.add({
            'digit': digit,
            'points': points,
          });
        }
      }
    }

    setState(() {});
  }

  void _addSpecialModeEntry() {
    _clearMessage();
    if (_isApiCalling) return;

    final l10n = AppLocalizations.of(context);
    if (_biddingClosed) {
      _showMessage(l10n?.biddingIsClosedForSlot ?? 'Bidding is closed for this slot.', isError: true);
      return;
    }

    final digit = _specialModeDigitController.text.trim();
    final pointsStr = _specialModePointsController.text.trim();

    if (digit.isEmpty || digit.length != 1 || !_digitOptions.contains(digit)) {
      _showMessage(l10n?.pleaseEnterValidSingleDigit ?? 'Please enter a valid single digit (0-9).', isError: true);
      return;
    }
    if (pointsStr.isEmpty) {
      _showMessage(l10n?.pleaseEnterAnAmount ?? 'Please enter an amount.', isError: true);
      return;
    }

    final fromStorage = int.tryParse(_storage.read('minBid')?.toString() ?? '') ?? _defaultMinBet;
    final minBid = fromStorage > 0 ? fromStorage : _defaultMinBet;

    final points = int.tryParse(pointsStr);
    if (points == null) {
      _showMessage(l10n?.amountMustBeNumber ?? 'Amount must be a number.', isError: true);
      return;
    }
    if (points < minBid || points > _maxBet) {
      _showMessage(
        l10n?.amountMustBeBetween(minBid, _maxBet) ?? 'Amount must be between $minBid and $_maxBet.',
        isError: true,
      );
      return;
    }

    // Wallet check
    int currentTotal = _getSpecialModeTotalPoints();
    final idx = _specialModeEntries.indexWhere((e) => e['digit'] == digit);
    if (idx != -1) {
      currentTotal -= (int.tryParse(_specialModeEntries[idx]['points'] ?? '0') ?? 0);
    }
    if (currentTotal + points > _walletBalance) {
      _showMessage(
        l10n?.insufficientWalletBalanceToPlaceBids ?? 'Insufficient wallet balance to place these bids.',
        isError: true,
      );
      return;
    }

    setState(() {
      if (idx != -1) {
        _specialModeEntries[idx]['points'] = points.toString();
        _showMessage(l10n?.updatedDigitAmount(digit, points) ?? 'Updated digit $digit amount to $points.');
      } else {
        _specialModeEntries.add({
          'digit': digit,
          'points': points.toString(),
        });
        _showMessage(l10n?.addedBidDigitAmount(digit, points) ?? 'Added bid: Digit $digit, Amount $points.');
      }
      _specialModeDigitController.clear();
      _specialModePointsController.clear();
    });
  }

  void _deleteSpecialModeEntry(int index) {
    if (_isApiCalling) return;
    setState(() {
      _specialModeEntries.removeAt(index);
    });
  }

  int _getSpecialModeTotalPoints() {
    return _specialModeEntries.fold(0, (sum, item) => sum + (int.tryParse(item['points'] ?? '0') ?? 0));
  }

  List<Map<String, String>> _getCurrentEntries() {
    if (_selectedMode == 'Easy Mode') {
      return _easyModeEntries;
    }
    return _specialModeEntries;
  }

  int _getTotalPoints() {
    final entries = _getCurrentEntries();
    return entries.fold<int>(
      0,
      (sum, e) => sum + (int.tryParse(e['points'] ?? '0') ?? 0),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3882F6),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // -------- add/remove --------
  void _addEntry() {
    _addSpecialModeEntry();
  }

  void _removeEntry(int index) {
    if (_selectedMode == 'Easy Mode') {
      _updateEasyModeBids();
    }

  }

  // -------- confirm & submit --------
  void _showConfirmationDialog() {
    FocusScope.of(context).unfocus();
    _clearMessage();
    if (_isApiCalling) return;

    if (_selectedMode == 'Special Mode') {
      // Special Mode uses Easy UI (grid), so need to update from text fields
      _updateEasyModeBids();
    }

    final l10n = AppLocalizations.of(context);
    final currentEntries = _getCurrentEntries();
    if (currentEntries.isEmpty) {
      _showMessage(
        l10n?.pleaseAddAtLeastOneBidBeforeSubmitting ?? 'Please add at least one bid before submitting.',
        isError: true,
      );
      return;
    }
    if (_biddingClosed) {
      _showMessage(l10n?.biddingIsClosedForSlot ?? 'Bidding is closed for this slot.', isError: true);
      return;
    }

    final totalPointsForConfirmation = _getTotalPoints();
    if (totalPointsForConfirmation > _walletBalance) {
      _showMessage(l10n?.insufficientWalletBalanceToSubmit ?? 'Insufficient wallet balance to submit.', isError: true);
      return;
    }

    final bidsForConfirmation = currentEntries
        .map((e) => {'digit': e['digit']!, 'points': e['points']!})
        .toList();

    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: formattedDate,
        bids: bidsForConfirmation,
        totalBids: bidsForConfirmation.length,
        totalBidsAmount: totalPointsForConfirmation,
        walletBalanceBeforeDeduction: _walletBalance,
        walletBalanceAfterDeduction:
            (_walletBalance - totalPointsForConfirmation).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameCategoryType,
        onConfirm: () async {
          await _placeFinalBids();
        },
      ),
    );
  }

  Future<void> _placeFinalBids() async {
    if (!mounted) return;

    setState(() => _isApiCalling = true);
    _clearMessage();
    FocusScope.of(context).unfocus();

    final l10n = AppLocalizations.of(context);
    final currentEntries = _getCurrentEntries();
    if (currentEntries.isEmpty) {
      _showMessage(l10n?.noBidsToSubmit ?? 'No bids to submit.', isError: true);
      if (mounted) setState(() => _isApiCalling = false);
      return;
    }

    // Read values with proper fallbacks to prevent null errors in release mode
    final accessToken = _storage.read('accessToken') as String? ?? '';
    final deviceId = _storage.read('deviceId') as String? ?? 'unknown_device';
    final deviceName =
        _storage.read('deviceName') as String? ?? 'unknown_model';

    print("TOKEN: $accessToken");
    print("DEVICE ID: $deviceId");
    print("DEVICE NAME: $deviceName");

    if (accessToken.isEmpty || deviceId.isEmpty || deviceName.isEmpty) {
      _showMessage(l10n?.authenticationErrorPleaseLoginAgain ?? 'Authentication error. Please log in again.', isError: true);
      if (mounted) setState(() => _isApiCalling = false);
      return;
    }

    // Build (digit -> amount) map
    final bidAmounts = <String, String>{};
    var totalBidAmount = 0;
    for (final bid in currentEntries) {
      final d = bid['digit'];
      final p = int.tryParse(bid['points'] ?? '0') ?? 0;
      if (d != null && p > 0) {
        bidAmounts[d] = p.toString();
        totalBidAmount += p;
      }
    }

    try {
      final market = _detectMarket();

      final resp = await _bidService.placeFinalBids(
        market: market,
        accessToken: accessToken,
        registerId: _registerId,
        deviceId: deviceId,
        deviceName: deviceName,
        accountStatus: _accountStatus,
        bidAmounts: bidAmounts,
        gameId: widget.gameId, // TYPE id (as STRING in API)
        gameType: widget.gameCategoryType, // e.g. "singleDigits"
        totalBidAmount: totalBidAmount,
      );

      if (!mounted) return;

      if (resp['status'] == true) {
        // Prefer server wallet if available
        final dynamic serverBal =
            resp['updatedWalletBalance'] ??
            resp['data']?['updatedWalletBalance'] ??
            resp['data']?['wallet_balance'];

        final int newBalance =
            int.tryParse(serverBal?.toString() ?? '') ??
            (_walletBalance - totalBidAmount);

        setState(() {
          _walletBalance = newBalance;
          _specialModeEntries.clear();
           {
            // Special Mode uses Easy UI, so clear Easy Mode entries
            _easyModeEntries.clear();
            for (var controller in _digitControllers.values) {
              controller.clear();
            }
          }
          digitController.clear();
          pointsController.clear();
          _isDigitSuggestionsVisible = false;
        });

        // Persist + broadcast
        await _bidService.updateWalletBalance(newBalance);
        userController.walletBalance.value = newBalance.toString();

        _showMessage(l10n?.allBidsSubmittedSuccessfully ?? 'All bids submitted successfully!');
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const BidSuccessDialog(),
        );
      } else {
        final err = (resp['msg'] as String?) ?? (l10n?.unknownErrorOccurred ?? 'Unknown error occurred.');
        _showMessage(err, isError: true);
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => BidFailureDialog(errorMessage: err),
        );
      }
    } catch (e) {
      log('Bid submission error: $e');
      final msg = l10n?.unexpectedErrorOccurred(e.toString()) ?? 'An unexpected error occurred: $e';
      _showMessage(msg, isError: true);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BidFailureDialog(errorMessage: msg),
      );
    } finally {
      if (mounted) setState(() => _isApiCalling = false);
    }
  }

  // -------- UI --------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async => !_isApiCalling,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Main Content Container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            // Header
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  // Back Button
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back,
                                        color: Color(0xFF0F4C81),
                                        size: 20,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  // Title
                                  Expanded(
                                    child: Text(
                                      widget.title,
                                      style: const TextStyle(
                                        color: Color(0xFF0F4C81),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Wallet
                                  Obx(
                                    () => userController.accountStatus.value
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0B1223),
                                              borderRadius: BorderRadius.circular(
                                                40,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  "assets/images/ic_wallet.png",
                                                  width: 20,
                                                  height: 20,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "₹${userController.walletBalance.value}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Bidding Closed Warning
                            if (_biddingClosed)
                              Container(
                                width: double.infinity,
                                color: Colors.amber.shade200,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Text(
                                  l10n?.biddingIsClosedForSlot ?? 'Bidding is closed for this slot.',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                            // Mode Selection Buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildModeButton(
                                      l10n?.easyMode ?? 'Easy Mode',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildModeButton(
                                      l10n?.specialMode ?? 'Special Mode',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Content based on selected mode
                            Expanded(
                              child: _selectedMode == 'Easy Mode'
                                  ? _buildSpecialModeContent() // 🔥 Easy → Special UI
                                  : _buildEasyModeContent(),   // 🔥 Special → Easy UI
                            ),



                            Divider(color: Color(0xFF3882F6), height: 1),
                            _buildBottomBar(),
                          ],
                        ),

                        if (_messageToShow != null)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: AnimatedMessageBar(
                              key: _messageBarKey,
                              message: _messageToShow!,
                              isError: _isErrorForMessage,
                              onDismissed: _clearMessage,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String modeText) {
    final l10n = AppLocalizations.of(context);

    final String englishMode =
    modeText == (l10n?.easyMode ?? 'Easy Mode')
        ? 'Easy Mode'
        : 'Special Mode';

    final bool isSelected = _selectedMode == englishMode;

    return GestureDetector(
      onTap: (_isApiCalling || _biddingClosed)
          ? null
          : () {
        setState(() {
          _selectedMode = englishMode;
          _clearMessage();
        });
      },
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3882F6) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3882F6), width: 1.5),
        ),
        child: Center(
          child: Text(
            modeText.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Color(0xFF0F4C81),
            ),
          ),
        ),
      ),
    );
  }




  Widget _buildEasyModeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Date Picker for Easy Mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: _buildDatePicker(context),
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 1, height: 1),
          const SizedBox(height: 16),

          // Digits Grid
          for (int i = 0; i < _digitOptions.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(child: _easyDigitBox(_digitOptions[i])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: i + 1 < _digitOptions.length
                        ? _easyDigitBox(_digitOptions[i + 1])
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _easyDigitBox(String digit) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF3882F6),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              digit,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          height: 48,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: _digitControllers[digit],
            keyboardType: TextInputType.number,
            onChanged: (_) => _updateEasyModeBids(),
            enabled: !_isApiCalling && !_biddingClosed,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: AppLocalizations.of(context)?.pointsLabel ?? "Points",
              hintStyle: GoogleFonts.poppins(fontSize: 12),
            ),
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialModeContent() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Date Picker
          _buildDatePicker(context),
          const SizedBox(height: 18),

          // Enter Single Digit
          Row(
            children: [
              Expanded(flex: 2, child: _label(l10n?.entersSingleDigit ?? "Enters Single Digit:")),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _roundedInput(
                  controller: _specialModeDigitController,
                  hint: l10n?.enterDigit ?? "Digit",
                  maxLen: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Enter Points
          Row(
            children: [
              Expanded(flex: 2, child: _label(l10n?.enterPointsColon ?? "Enter Points:")),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _roundedInput(
                  controller: _specialModePointsController,
                  hint: l10n?.pointsLabel ?? "Point",
                  maxLen: 4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 160,
                height: 48,
                child: ElevatedButton(
                  onPressed: (_isApiCalling || _biddingClosed) ? null : _addSpecialModeEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3882F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    l10n?.addBid ?? "Add",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Divider
          const Divider(color: Color(0xFF3882F6), thickness: 1),

          // Table Header
          _tableHeader(),

          // List
          ..._specialList(),

          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _roundedInput({
    required TextEditingController controller,
    required String hint,
    required int maxLen,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: controller,
        maxLength: maxLen,
        keyboardType: TextInputType.number,
        enabled: !_isApiCalling && !_biddingClosed,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLen),
        ],
        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 13),
        ),
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3, top: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _tableHeader() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(l10n?.digit ?? "Digit", style: TextStyle(color: Color(0xFF0F4C81))),
          ),
          Expanded(
            child: Text(l10n?.pointsLabel ?? "Point", style: TextStyle(color: Color(0xFF0F4C81))),
          ),
          Expanded(
            child: Text(l10n?.delete ?? "Delete", style: TextStyle(color: Color(0xFF0F4C81))),
          ),
        ],
      ),
    );
  }

  List<Widget> _specialList() {
    return _specialModeEntries.asMap().entries.map((e) {
      final i = e.key;
      final d = e.value;
      return Row(
        children: [
          Expanded(child: Text(d['digit']!)),
          Expanded(child: Text(d['points']!)),
          Expanded(
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: (_isApiCalling || _biddingClosed) ? null : () => _deleteSpecialModeEntry(i),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildDatePicker(BuildContext context) {
    final String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return GestureDetector(
      onTap: (_isApiCalling || _biddingClosed) ? null : () => _selectDate(context),
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF3882F6), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: Color(0xFF3882F6),
            ),
            const SizedBox(width: 8),
            Text(
              formattedDate,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputRow(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(flex: 3, child: field),
        ],
      ),
    );
  }

  Widget _buildDigitInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 150,
              height: 35,
              child: TextFormField(
                controller: digitController,
                cursorColor: Color(0xFF3882F6),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                style: GoogleFonts.poppins(fontSize: 14),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onTap: _clearMessage,
                enabled: !_isApiCalling,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.enterDigit ?? "Enter Digit",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  filled: true,
                  fillColor: Color(0xffFCFCFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Changed to match other screens
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Changed to match other screens
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Changed to match other screens
                    borderSide: const BorderSide(
                      color: Color(0xFF3882F6),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_isDigitSuggestionsVisible)
          Container(
            width: 150,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredDigitOptions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  title: Text(_filteredDigitOptions[index]),
                  onTap: () {
                    setState(() {
                      digitController.text = _filteredDigitOptions[index];
                      _isDigitSuggestionsVisible = false;
                      FocusScope.of(context).unfocus();
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAmountField(TextEditingController controller, String hint) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 150,
          height: 35,
          child: TextFormField(
            controller: controller,
            cursorColor: Color(0xFF3882F6),
            keyboardType: const TextInputType.numberWithOptions(
              signed: false,
              decimal: false,
            ),
            style: GoogleFonts.poppins(fontSize: 14),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onTap: _clearMessage,
            enabled: !_isApiCalling,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              filled: true,
              fillColor: Color(0xffFCFCFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ), // Changed to match other screens
                borderSide: const BorderSide(color: Colors.grey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ), // Changed to match other screens
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  8,
                ), // Changed to match other screens
                borderSide: const BorderSide(color: Color(0xFF3882F6), width: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context);
    final currentEntries = _getCurrentEntries();
    final totalBids = currentEntries.length;
    final totalPoints = _getTotalPoints();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n?.myBids ?? 'Bids',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '$totalBids',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F4C81),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n?.points ?? 'Points',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '$totalPoints',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F4C81),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: (_isApiCalling || totalBids == 0 || _biddingClosed)
                ? null
                : _showConfirmationDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3882F6),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: _isApiCalling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    l10n?.submit ?? 'Submit',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
