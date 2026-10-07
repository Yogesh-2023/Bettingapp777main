import 'dart:async';

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
// ⬇️ use the unified service

class StarlineJodiBidScreen extends StatefulWidget {
  final String title;
  final String gameType; // server gameType (e.g., "jodi")
  final int gameId; // TYPE id (sent as STRING)
  final String gameName; // label

  const StarlineJodiBidScreen({
    Key? key,
    required this.title,
    required this.gameType,
    required this.gameId,
    required this.gameName,
  }) : super(key: key);

  @override
  State<StarlineJodiBidScreen> createState() => _StarlineJodiBidScreenState();
}

class _StarlineJodiBidScreenState extends State<StarlineJodiBidScreen> {
  final TextEditingController digitController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  /// Local bids: [{digit, amount}]
  final List<Map<String, String>> bids = [];
  late final GetStorage storage;
  late final StarlineBidService _bidService;

  late String accessToken;
  late String registerId;
  String walletBalance = '0'; // keep as string for UI
  bool accountStatus = false;
  bool _isSubmitting = false;

  final String _deviceId =
      GetStorage().read('deviceId')?.toString() ?? 'flutter_device';
  final String _deviceName =
      GetStorage().read('deviceName')?.toString() ?? 'Flutter_App';

  String? _messageToShow;
  bool _isErrorForMessage = false;
  Key _messageBarKey = UniqueKey();
  Timer? _messageDismissTimer;

  final UserController userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  // 00..99
  final List<String> allJodiOptions = List.generate(
    100,
    (i) => i.toString().padLeft(2, '0'),
  );

  @override
  void initState() {
    super.initState();
    storage = GetStorage();
    _bidService = StarlineBidService(storage);

    // wallet (string) init
    final num? wb = num.tryParse(userController.walletBalance.value);
    walletBalance = (wb?.toInt() ?? 0).toString();
    _loadInitialData();
    _setupStorageListeners();
  }

  Future<void> _loadInitialData() async {
    accessToken = storage.read('accessToken') ?? '';
    registerId = storage.read('registerId') ?? '';
    accountStatus = userController.accountStatus.value;
  }

  void _setupStorageListeners() {
    storage.listenKey('walletBalance', (value) {
      if (!mounted) return;
      setState(() {
        walletBalance = value?.toString() ?? '0';
      });
    });
  }

  // -------------- market detect --------------
  Market _detectMarket() {
    final s = ('${widget.title} ${widget.gameName}').toLowerCase();
    return s.contains('jackpot') ? Market.jackpot : Market.starline;
  }

  // ---------------- messaging ----------------
  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _messageToShow = msg;
      _isErrorForMessage = isError;
      _messageBarKey = UniqueKey();
    });
  }

  // void _showMessage(String msg, {bool isError = false}) {
  //   _messageDismissTimer?.cancel();
  //   if (!mounted) return;
  //   setState(() {
  //     _messageToShow = msg;
  //     _isErrorForMessage = isError;
  //     _messageBarKey = UniqueKey();
  //   });
  //   _messageDismissTimer = Timer(const Duration(seconds: 3), () {
  //     if (mounted) setState(() => _messageToShow = null);
  //   });
  // }

  void _clearMessage() {
    _messageDismissTimer?.cancel();
    if (!mounted) return;
    setState(() => _messageToShow = null);
  }

  // ---------------- data helpers ----------------
  int _getTotalPoints() {
    return bids.fold(
      0,
      (sum, b) => sum + (int.tryParse(b['amount'] ?? '0') ?? 0),
    );
  }

  Map<String, String> _buildBidMap() {
    final map = <String, String>{};
    for (final b in bids) {
      final d = b['digit'] ?? '';
      final a = b['amount'] ?? '0';
      if (d.isNotEmpty && int.tryParse(a) != null) map[d] = a;
    }
    return map;
  }

  // ---------------- add/remove ----------------
  void _addBid() {
    _clearMessage();
    if (_isSubmitting) return;

    final l10n = AppLocalizations.of(context);
    final jodi = digitController.text.trim();
    final amount = amountController.text.trim();

    if (jodi.length != 2 || int.tryParse(jodi) == null) {
      _showMessage(l10n?.pleaseEnterValid2DigitJodi ?? 'Please enter a valid 2-digit Jodi.', isError: true);
      return;
    }
    final amt = int.tryParse(amount);
    if (amt == null || amt < 10 || amt > 1000) {
      _showMessage(l10n?.pointsMustBeBetween(10) ?? 'Points must be between 10 and 1000.', isError: true);
      return;
    }
    if (bids.any((b) => b['digit'] == jodi)) {
      _showMessage(l10n?.jodiAlreadyExists(jodi) ?? 'Jodi $jodi already exists.', isError: true);
      return;
    }

    setState(() {
      bids.add({'digit': jodi, 'amount': amount});
      digitController.clear();
      amountController.clear();
      _showMessage(l10n?.addedJodi(jodi) ?? 'Added: $jodi');
    });
  }

  void _removeBid(int idx) {
    if (_isSubmitting || idx < 0 || idx >= bids.length) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      final removed = bids[idx]['digit'];
      bids.removeAt(idx);
      _showMessage(l10n?.bidForJodiRemoved(removed ?? '') ?? 'Bid for Jodi $removed removed.');
    });
  }

  // ---------------- confirm & submit ----------------
  void _showConfirmationDialog(int total) {
    _clearMessage();
    final l10n = AppLocalizations.of(context);
    if (bids.isEmpty) {
      _showMessage(l10n?.noBidsAddedYet ?? 'No bids added yet.', isError: true);
      return;
    }

    final currentBal = int.tryParse(walletBalance) ?? 0;
    if (total > currentBal) {
      _showMessage(l10n?.insufficientWalletBalance ?? 'Insufficient wallet balance.', isError: true);
      return;
    }

    final date = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    final rows = bids
        .map(
          (b) => {
            'digit': b['digit'] ?? '',
            'points': b['amount'] ?? '0',
            'type': 'Open', // UI label only
            'pana': '', // not applicable for jodi
            'jodi': b['digit'] ?? '',
          },
        )
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.gameName,
        gameDate: date,
        bids: rows,
        totalBids: rows.length,
        totalBidsAmount: total,
        walletBalanceBeforeDeduction: currentBal,
        walletBalanceAfterDeduction: (currentBal - total).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameType,
        onConfirm: _placeFinalBids,
      ),
    );
  }

  Future<bool> _placeFinalBids() async {
    if (!mounted) return false;
    setState(() => _isSubmitting = true);

    final total = _getTotalPoints();
    final bidMap = _buildBidMap();

    final l10n = AppLocalizations.of(context);
    if (bidMap.isEmpty) {
      setState(() => _isSubmitting = false);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            BidFailureDialog(errorMessage: l10n?.noValidBidsToSubmit ?? 'No valid bids to submit.'),
      );
      return false;
    }

    if (accessToken.isEmpty || registerId.isEmpty) {
      setState(() => _isSubmitting = false);
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
      final market = _detectMarket();

      final result = await _bidService.placeFinalBids(
        market: market,
        accessToken: accessToken,
        registerId: registerId,
        deviceId: _deviceId,
        deviceName: _deviceName,
        accountStatus: accountStatus,
        bidAmounts: bidMap,
        gameType: widget.gameType, // e.g. "jodi"
        gameId: widget.gameId, // TYPE id (sent as STRING)
        totalBidAmount: total,
      );

      if (!mounted) return false;

      if (result['status'] == true) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const BidSuccessDialog(),
        );

        // Prefer server wallet if present
        final dynamic serverBal =
            result['updatedWalletBalance'] ??
            result['data']?['updatedWalletBalance'] ??
            result['data']?['wallet_balance'];

        final int newBal =
            int.tryParse(serverBal?.toString() ?? '') ??
            ((int.tryParse(walletBalance) ?? 0) - total);

        setState(() {
          bids.clear();
          walletBalance = newBal.toString();
        });
        await _bidService.updateWalletBalance(newBal);
        userController.walletBalance.value = newBal.toString();

        _showMessage(l10n?.bidPlacedSuccessfully ?? "Bid placed successfully!");
        setState(() => _isSubmitting = false);
        return true;
      } else {
        final err = (result['msg'] ?? 'Something went wrong').toString();
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => BidFailureDialog(errorMessage: err),
        );
        _showMessage(err, isError: true);
        setState(() => _isSubmitting = false);
        return false;
      }
    } catch (e) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BidFailureDialog(
          errorMessage: l10n?.unexpectedErrorOccurred('bid submission') ?? 'An unexpected error occurred during bid submission.',
        ),
      );
      _showMessage(l10n?.unexpectedErrorOccurred(e.toString()) ?? 'Unexpected error: $e', isError: true);
      setState(() => _isSubmitting = false);
      return false;
    }
  }

  @override
  void dispose() {
    digitController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = _getTotalPoints();
    final hasEntries = bids.isNotEmpty;
    final canSubmit = hasEntries && !_isSubmitting;

    return Scaffold(
      // Apply the same gradient background as StarlineDoublePana.dart
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// 🔥 FULL GRADIENT BACKGROUND (Copied from StarlineDoublePana.dart)
        decoration: const BoxDecoration(
          color:Colors.white
        ),
        child: SafeArea(
          child: Column(
            children: [

              // ⭐ OUTER ROUNDED CONTAINER WITH TOP ROUNDED CORNERS ONLY ⭐
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                  ), // Remove horizontal margin
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        30,
                      ), // Match StarlineDoublePana radius
                      topRight: Radius.circular(
                        30,
                      ), // Match StarlineDoublePana radius
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                // 🔙 Back Button
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey, width: 1),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Color(0xFF0F4C81),
                                      size: 20,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // 📝 Title (Icon ke paas + dots)
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF0F4C81),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // 💰 Wallet (Right side)
                                Obx(
                                      () => userController.accountStatus.value
                                      ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0B1223),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
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


                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                _inputRow(
                                  "${l10n?.enterJodi ?? 'Enter Jodi'}:",
                                  _buildInputField(
                                    controller: digitController,
                                    hint: l10n?.enterJodiHint ?? "Enter Jodi",
                                    borderColor: Color(0xFF3882F6),
                                    selected: 'digit',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _inputRow(
                                  "${l10n?.enterPoints ?? 'Enter Points'}:",
                                  _buildInputField(
                                    controller: amountController,
                                    hint: l10n?.enterAmount ?? "Enter Amount",
                                    borderColor: Color(0xFF3882F6),
                                    selected: 'amount',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      height: 45,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF3882F6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: _isSubmitting ? null : _addBid,
                                        child: _isSubmitting
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              )
                                            : Text(
                                                l10n?.addBid ?? "ADD BID",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1),

                          // Entries list
                          Expanded(
                            child: !hasEntries
                                ? Center(
                                    child: Text(
                                      l10n?.noBidAddedYet ?? "No bid added yet",
                                      style: GoogleFonts.poppins(
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: bids.length,
                                    itemBuilder: (_, idx) =>
                                        _buildBidItem(bids[idx], idx),
                                  ),
                          ),

                          // Bottom bar
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, -3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n?.bids(0) ?? 'Bids',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                    Text(
                                      '${bids.length}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n?.pointsLabel ?? 'Points',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                    Text(
                                      '$total',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: canSubmit
                                      ? () => _showConfirmationDialog(total)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: canSubmit
                                        ? Color(0xFF3882F6)
                                        : Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: _isSubmitting
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          l10n?.submit ?? 'SUBMIT',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
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
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required Color borderColor,
    required String selected,
  }) {
    if (selected == 'digit') {
      return SizedBox(
        height: 35,
        child: RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: FocusNode(),
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty)
              return const Iterable<String>.empty();
            return allJodiOptions.where(
              (opt) => opt.startsWith(textEditingValue.text),
            );
          },
          fieldViewBuilder: (context, c, focusNode, _) {
            return TextField(
              controller: c,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              maxLength: 2,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              cursorColor: Color(0xFF3882F6),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: InputDecoration(
                counterText: "",
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF3882F6), width: 1),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (val) => controller.text = val,
        ),
      );
    } else {
      return SizedBox(
        width: 150,
        height: 35,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          cursorColor: Color(0xFF3882F6),
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            counterText: "",
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3882F6), width: 1),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTableHeader() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n?.digit ?? 'Digit',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F4C81),
              ),
            ),
          ),
          Expanded(
            child: Text(
              l10n?.pointsLabel ?? 'Points',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F4C81),
              ),
            ),
          ),
          Expanded(
            child: Text(
              l10n?.gameTypeLabel ?? 'Game Type',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F4C81),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBidItem(Map<String, String> bid, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              bid['digit'] ?? '',
              style: GoogleFonts.poppins(),
            ),
          ),
          Expanded(
            child: Text(
              bid['amount'] ?? '',
              style: GoogleFonts.poppins(),
            ),
          ),
          Expanded(
            child: Text(
              widget.gameType.toUpperCase(),
              style: GoogleFonts.poppins(),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Color(0xFF3882F6),
            ),
            onPressed: _isSubmitting ? null : () => _removeBid(index),
          ),
        ],
      ),
    );
  }


}
