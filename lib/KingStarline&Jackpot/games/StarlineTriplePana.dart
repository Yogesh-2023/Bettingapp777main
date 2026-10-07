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

class StarlineTPMotorsScreen extends StatefulWidget {
  final String title;
  final String gameCategoryType; // e.g. "triplePana"
  final int gameId; // STARLINE session/slot id
  final String gameName; // human label like "12:30 PM"
  final bool selectionStatus; // true=open, false=closed

  const StarlineTPMotorsScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameName,
    required this.gameCategoryType,
    required this.selectionStatus,
  });

  @override
  State<StarlineTPMotorsScreen> createState() => _StarlineTPMotorsScreenState();
}

class _StarlineTPMotorsScreenState extends State<StarlineTPMotorsScreen> {
  // UI/session label only (Starline API ignores this)
  String selectedGameBetType = "OPEN";

  // Date picker
  DateTime selectedDate = DateTime.now();

  final TextEditingController digitController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();

  // Controllers for Easy Mode - one for each triple pana
  final Map<String, TextEditingController> _pannaControllers = {};
  final List<Map<String, String>> _easyModeEntries = [];

  final List<String> triplePanaOptions = const [
    "000",
    "111",
    "222",
    "333",
    "444",
    "555",
    "666",
    "777",
    "888",
    "999",
  ];
  List<String> filteredDigitOptions = [];
  bool _isDigitSuggestionsVisible = false;

  final List<Map<String, String>> addedEntries =
      []; // {digit, amount, type, gameType}
  late final GetStorage storage;
  late final StarlineBidService _bidService;

  String accessToken = '';
  String registerId = '';
  bool accountStatus = false;
  int walletBalance = 0;
  int minBid = 10;
  static const int _maxBid = 1000;

  // device headers (from storage with fallbacks)
  String get _deviceId =>
      storage.read('deviceId')?.toString() ?? 'flutter_device';
  String get _deviceName =>
      storage.read('deviceName')?.toString() ?? 'Flutter_App';

  String? _messageToShow;
  bool _isErrorForMessage = false;
  Key _messageBarKey = UniqueKey();
  Timer? _messageDismissTimer;

  bool _isApiCalling = false;

  final UserController userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  bool get _biddingClosed => !widget.selectionStatus;

  @override
  void initState() {
    super.initState();
    storage = GetStorage();
    _bidService = StarlineBidService(storage);
    _loadInitialData();
    _syncWallet();
    digitController.addListener(_onDigitChanged);

    // Initialize controllers for each triple pana
    for (String pana in triplePanaOptions) {
      _pannaControllers[pana] = TextEditingController();
    }
  }

  void _syncWallet() {
    final raw = userController.walletBalance.value;
    final n = num.tryParse(raw);
    walletBalance = n?.toInt() ?? 0;
  }

  Future<void> _loadInitialData() async {
    accessToken = storage.read('accessToken') ?? '';
    registerId = storage.read('registerId') ?? '';
    accountStatus = userController.accountStatus.value;
    minBid = int.tryParse(storage.read('minBid')?.toString() ?? '10') ?? 10;

    // live wallet sync
    storage.listenKey('walletBalance', (val) {
      final parsed = int.tryParse(val?.toString() ?? '0') ?? 0;
      if (mounted) setState(() => walletBalance = parsed);
    });

    log(
      'TPMotors init: token=${accessToken.isNotEmpty}, reg=${registerId.isNotEmpty}, acc=$accountStatus, minBid=$minBid',
    );
  }

  @override
  void dispose() {
    digitController.removeListener(_onDigitChanged);
    digitController.dispose();
    pointsController.dispose();
    for (var controller in _pannaControllers.values) {
      controller.dispose();
    }
    _messageDismissTimer?.cancel();
    super.dispose();
  }

  // ---------- messages ----------
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

  // ---------- suggestions ----------
  void _onDigitChanged() {
    final q = digitController.text.trim();
    if (q.isEmpty) {
      setState(() {
        filteredDigitOptions = [];
        _isDigitSuggestionsVisible = false;
      });
      return;
    }
    setState(() {
      filteredDigitOptions = triplePanaOptions
          .where((d) => d.startsWith(q))
          .toList();
      _isDigitSuggestionsVisible = filteredDigitOptions.isNotEmpty;
    });
  }

  // ---------- add/remove ----------
  void _addEntry() {
    _clearMessage();
    if (_isApiCalling) return;

    final l10n = AppLocalizations.of(context);
    if (_biddingClosed) {
      _showMessage(l10n?.biddingIsClosedForSlot ?? 'Bidding is closed for this slot.', isError: true);
      return;
    }

    final digit = digitController.text.trim();
    final pointsStr = pointsController.text.trim();

    if (digit.length != 3 || int.tryParse(digit) == null) {
      _showMessage(l10n?.pleaseEnterValid3DigitNumber ?? 'Enter a valid 3-digit number.', isError: true);
      return;
    }
    if (!triplePanaOptions.contains(digit)) {
      _showMessage(l10n?.invalidTriplePannaNumber ?? 'Invalid Triple Panna number.', isError: true);
      return;
    }
    if (pointsStr.isEmpty) {
      _showMessage(l10n?.pleaseEnterAnAmount ?? 'Please enter an amount.', isError: true);
      return;
    }

    final pts = int.tryParse(pointsStr);
    if (pts == null || pts < minBid || pts > _maxBid) {
      _showMessage(
        l10n?.amountMustBeBetween(minBid, _maxBid) ?? 'Points must be between $minBid and $_maxBid.',
        isError: true,
      );
      return;
    }

    // wallet guard (with replacement logic)
    _syncWallet();
    int currentTotal = _getTotalPoints();
    final idx = addedEntries.indexWhere(
      (e) => e['digit'] == digit && e['type'] == selectedGameBetType,
    );
    if (idx != -1) {
      currentTotal -= int.tryParse(addedEntries[idx]['amount'] ?? '0') ?? 0;
    }
    if (currentTotal + pts > walletBalance) {
      _showMessage(l10n?.insufficientWalletBalance ?? 'Insufficient wallet balance.', isError: true);
      return;
    }

    setState(() {
      if (idx != -1) {
        addedEntries[idx]['amount'] = pts.toString(); // replace (not sum)
        _showMessage(l10n?.updatedBidForDigit(digit) ?? 'Updated bid for $digit.');
      } else {
        addedEntries.add({
          "digit": digit,
          "amount": pts.toString(),
          "type": selectedGameBetType, // "OPEN"
          "gameType": widget.gameCategoryType, // e.g. "triplePana"
        });
        _showMessage(l10n?.addedBidDigitPoints(digit, pts) ?? "Added bid: $digit - $pts points");
      }
      digitController.clear();
      pointsController.clear();
      _isDigitSuggestionsVisible = false;
      FocusScope.of(context).unfocus();
    });
  }

  void _removeEntry(int index) {
    _clearMessage();
    if (_isApiCalling || index < 0 || index >= addedEntries.length) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      final removed = addedEntries[index];
      addedEntries.removeAt(index);
      _showMessage(l10n?.removedBidDigitOnly(removed['digit'] ?? '') ?? "Removed bid: ${removed['digit']}");
    });
  }

  void _updateEasyModeBids() {
    _easyModeEntries.clear();

    for (String pana in triplePanaOptions) {
      final points = _pannaControllers[pana]!.text.trim();
      if (points.isNotEmpty) {
        final pts = int.tryParse(points);
        if (pts != null && pts >= minBid && pts <= _maxBid) {
          _easyModeEntries.add({
            'digit': pana,
            'amount': points,
            'type': selectedGameBetType,
            'gameType': widget.gameCategoryType,
          });
        }
      }
    }

    setState(() {});
  }

  List<Map<String, String>> _getCurrentEntries() {
    return _easyModeEntries;
  }

  int _getTotalPoints() {
    final entries = _getCurrentEntries();
    return entries.fold(0, (sum, item) => sum + (int.tryParse(item['amount'] ?? '0') ?? 0));
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

  // ---------- confirm & submit ----------
  void _showConfirmationDialog() {
    _clearMessage();
    final l10n = AppLocalizations.of(context);

    _updateEasyModeBids();
    final currentEntries = _getCurrentEntries();
    final int totalPoints = _getTotalPoints();
    if (_biddingClosed) {
      _showMessage(l10n?.biddingIsClosedForSlot ?? "Bidding is closed for this slot.", isError: true);
      return;
    }
    if (totalPoints == 0) {
      _showMessage(l10n?.noBidsAddedToSubmit ?? "No bids added to submit.", isError: true);
      return;
    }
    if (walletBalance < totalPoints) {
      _showMessage(l10n?.insufficientWalletBalance ?? "Insufficient wallet balance.", isError: true);
      return;
    }

    final formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: formattedDate,
        bids: currentEntries.map((bid) {
          return {
            "digit": bid['digit']!,
            "points": bid['amount']!,
            "type": "${bid['gameType']} (${bid['type']})",
            "pana": bid['digit']!,
            "jodi": "",
          };
        }).toList(),
        totalBids: currentEntries.length,
        totalBidsAmount: totalPoints,
        walletBalanceBeforeDeduction: walletBalance,
        walletBalanceAfterDeduction: (walletBalance - totalPoints).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameCategoryType,
        onConfirm: () async {
          setState(() => _isApiCalling = true);
          final ok = await _placeFinalBids();
          if (mounted) setState(() => _isApiCalling = false);
          if (ok && mounted) {
            setState(() {
              _easyModeEntries.clear();
              for (var controller in _pannaControllers.values) {
                controller.clear();
              }
            });
          }
        },
      ),
    );
  }

  Future<bool> _placeFinalBids() async {
    // Build per-digit payload
    final currentEntries = _getCurrentEntries();
    final Map<String, String> bidPayload = {};
    int total = 0;
    for (final e in currentEntries) {
      final d = e['digit'] ?? '';
      final a = int.tryParse(e['amount'] ?? '0') ?? 0;
      if (d.isNotEmpty && a > 0) {
        bidPayload[d] = a.toString();
        total += a;
      }
    }

    final l10n = AppLocalizations.of(context);
    if (bidPayload.isEmpty) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            BidFailureDialog(errorMessage: l10n?.noValidBidsToSubmit ?? 'No valid bids to submit.'),
      );
      return false;
    }

    if (accessToken.isEmpty || registerId.isEmpty) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BidFailureDialog(
          errorMessage: l10n?.authenticationErrorPleaseLoginAgain ?? 'Authentication error. Please log in again.',
        ),
      );
      return false;
    }

    try {
      // This screen is always Starline
      // ✅ NEW (exactly matches your StarlineBidService signature)
      final result = await _bidService.placeFinalBids(
        market: Market.starline,
        accessToken: accessToken,
        registerId: registerId,
        deviceId: _deviceId,
        deviceName: _deviceName,
        accountStatus: accountStatus,
        bidAmounts: bidPayload, // Map<String,String> -> {digit: amount}
        gameType: widget.gameCategoryType, // e.g. "triplePana" (server key)
        gameId: widget.gameId, // int (service will send as string)
        totalBidAmount: total, // int
      );

      if (!mounted) return false;

      if (result['status'] == true) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const BidSuccessDialog(),
        );

        // Wallet sync (prefer server field if present)
        final data = result['data'] as Map<String, dynamic>?;
        final dynamic serverBal =
            data?['updatedWalletBalance'] ?? data?['wallet_balance'];
        final int newBal =
            int.tryParse(serverBal?.toString() ?? '') ??
            (walletBalance - total);

        await _bidService.updateWalletBalance(newBal);
        userController.walletBalance.value = newBal.toString();
        if (mounted) setState(() => walletBalance = newBal);

        return true;
      } else {
        final msg = (result['msg'] ?? 'Something went wrong').toString();
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => BidFailureDialog(errorMessage: msg),
        );
        return false;
      }
    } catch (e) {
      log('TPMotors placeFinalBids error: $e', name: 'StarlineTPMotorsScreen');
      if (!mounted) return false;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BidFailureDialog(
          errorMessage: l10n?.unexpectedErrorOccurred('bid submission') ?? 'An unexpected error occurred during bid submission.',
        ),
      );
      return false;
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      // Apply the same gradient background as JodiBulkScreen.dart
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// 🔥 FULL GRADIENT BACKGROUND (Copied from JodiBulkScreen.dart)
        decoration: const BoxDecoration(
          color:Colors.white
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
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
                                    textAlign: TextAlign.center,
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
                          const SizedBox(height: 12),

                          // Date Picker (Starline doesn't need game type dropdown)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: _buildDatePicker(context),
                          ),
                          const SizedBox(height: 16),

                          // Numbers Grid
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  for (int i = 0; i < triplePanaOptions.length; i += 2)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Expanded(child: _buildPannaBox(triplePanaOptions[i])),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: i + 1 < triplePanaOptions.length
                                                ? _buildPannaBox(triplePanaOptions[i + 1])
                                                : const SizedBox(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 90),
                                ],
                              ),
                            ),
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
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: TextFormField(
        controller: digitController,
        cursorColor: Color(0xFF3882F6),
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontSize: 14),
        inputFormatters: [
          LengthLimitingTextInputFormatter(3),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onTap: () {
          _clearMessage();
          if (digitController.text.isNotEmpty) _onDigitChanged();
        },
        onChanged: (_) => _onDigitChanged(),
        enabled: !_isApiCalling && !_biddingClosed,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)?.enter3DigitTriplePanna ?? "Enter 3-Digit Triple Panna",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3882F6), width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    List<TextInputFormatter>? inputFormatters,
  }) {
    return SizedBox(
      width: 150,
      height: 40,
      child: TextFormField(
        controller: controller,
        cursorColor: Color(0xFF3882F6),
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontSize: 14),
        inputFormatters: inputFormatters,
        onTap: _clearMessage,
        enabled: !_isApiCalling && !_biddingClosed,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3882F6), width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildPannaBox(String pana) {
    return Row(
      children: [
        // Orange Panna Button
        Container(
          width: 60,
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
              pana,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Light Grey Input Field
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFCFd8dd),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _pannaControllers[pana],
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateEasyModeBids(),
              enabled: !_isApiCalling && !_biddingClosed,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppLocalizations.of(context)?.pointsLabel ?? "Points",
                hintStyle: GoogleFonts.poppins(fontSize: 12),
              ),
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    return GestureDetector(
      onTap: _isApiCalling ? null : () => _selectDate(context),
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

  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context);
    _updateEasyModeBids();
    final currentEntries = _getCurrentEntries();
    final totalBids = currentEntries.length;
    final totalPoints = _getTotalPoints();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3882F6),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (_isApiCalling || totalBids == 0 || _biddingClosed) ? null : _showConfirmationDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3882F6),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: _isApiCalling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3882F6)),
                  ),
                )
              : Text(
                  l10n?.submit ?? 'Submit',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
