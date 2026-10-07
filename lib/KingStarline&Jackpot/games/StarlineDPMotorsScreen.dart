import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_sara/KingStarline&Jackpot/StarlineBidService.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../../Helper/UserController.dart';
import '../../components/AnimatedMessageBar.dart';
import '../../components/BidConfirmationDialog.dart';
import '../../components/BidFailureDialog.dart';
import '../../components/BidSuccessDialog.dart';
import '../../ulits/Constents.dart';
// ⬇️ Use the unified service (same one you used on the single-digit screen)

class StarlineDPMotorsScreen extends StatefulWidget {
  final String title;
  final String gameCategoryType; // e.g. "dpMotor" (use your backend key)
  final int gameId; // TYPE id (sent as STRING in API)
  final String gameName; // label ("Starline ..." / "Jackpot ...")

  const StarlineDPMotorsScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameName,
    required this.gameCategoryType,
  });

  @override
  State<StarlineDPMotorsScreen> createState() => _StarlineDPMotorsScreenState();
}

class _StarlineDPMotorsScreenState extends State<StarlineDPMotorsScreen> {
  // UI-only tag; API me sessionType "" rehta hai (both markets)
  String selectedGameBetType = "Open";

  final TextEditingController bidController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();

  // entries from dp-motor-pana -> [{digit, amount, type, gameType}]
  final List<Map<String, String>> addedEntries = [];

  late final GetStorage storage;
  late final StarlineBidService _bidService;

  late String accessToken;
  late String registerId;
  late String preferredLanguage;
  bool accountStatus = false;
  int walletBalance = 0;

  final String _deviceId =
      GetStorage().read('deviceId')?.toString() ?? 'flutter_device';
  final String _deviceName =
      GetStorage().read('deviceName')?.toString() ?? 'Flutter_App';

  String? _messageToShow;
  bool _isErrorForMessage = false;
  Key _messageBarKey = UniqueKey();
  Timer? _messageDismissTimer;
  bool _isApiCalling = false;

  final UserController userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  @override
  void initState() {
    super.initState();
    storage = GetStorage();
    _bidService = StarlineBidService(storage);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    accessToken = storage.read('accessToken') ?? '';
    registerId = storage.read('registerId') ?? '';
    accountStatus = userController.accountStatus.value;
    preferredLanguage = storage.read('selectedLanguage') ?? 'en';

    final dynamic w =
        storage.read('walletBalance') ?? userController.walletBalance.value;
    if (w is int) {
      walletBalance = w;
    } else if (w is String) {
      walletBalance = int.tryParse(w) ?? 0;
    } else if (w is num) {
      walletBalance = w.toInt();
    } else {
      walletBalance = 0;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    bidController.dispose();
    pointsController.dispose();
    _messageDismissTimer?.cancel();
    super.dispose();
  }

  // ---------------- messaging ----------------
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
  }

  // ---------------- market detect ----------------
  Market _detectMarket() {
    final s = ('${widget.title} ${widget.gameName}').toLowerCase();
    return s.contains('jackpot') ? Market.jackpot : Market.starline;
  }

  // ---------------- add via dp-motor API ----------------
  Future<void> _addEntry() async {
    _clearMessage();
    if (_isApiCalling) return;

    final l10n = AppLocalizations.of(context);
    final digit = bidController.text.trim();
    final amount = pointsController.text.trim();

    if (digit.isEmpty) {
      _showMessage(l10n?.pleaseEnterNumber ?? 'Please enter a number.', isError: true);
      return;
    }
    if (digit.length < 3 || digit.length > 7 || int.tryParse(digit) == null) {
      _showMessage(l10n?.pleaseEnterValidNumber ?? 'Please enter a valid number (3-7 digits).', isError: true);
      return;
    }
    final uniqueDigits = digit.split('').toSet();
    if (uniqueDigits.length < 2) {
      _showMessage(
        l10n?.numberMustContainTwoUniqueDigits ?? 'The number must contain at least two unique digits.',
        isError: true,
      );
      return;
    }
    if (amount.isEmpty) {
      _showMessage(l10n?.pleaseEnterAnAmount ?? 'Please enter an Amount.', isError: true);
      return;
    }
    final int? parsedAmount = int.tryParse(amount);
    if (parsedAmount == null || parsedAmount < 10 || parsedAmount > 1000) {
      _showMessage(l10n?.pointsMustBeBetween(10) ?? 'Points must be between 10 and 1000.', isError: true);
      return;
    }

    setState(() => _isApiCalling = true);

    try {
      final uri = Uri.parse('${Constant.apiEndpoint}dp-motor-pana');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'deviceId': _deviceId,
        'deviceName': _deviceName,
        'accessStatus': accountStatus ? '1' : '0',
      };
      final body = jsonEncode({
        "digit": int.parse(digit),
        "sessionType": selectedGameBetType
            .toLowerCase(), // UI only for this API
        "amount": parsedAmount,
      });

      final response = await http.post(uri, headers: headers, body: body);
      if (!mounted) return;

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      log('DP Motors fetch: $responseData');

      final l10n = AppLocalizations.of(context);
      if (response.statusCode == 200 && responseData['status'] == true) {
        final List<dynamic> info = responseData['info'] ?? [];
        if (info.isEmpty) {
          _showMessage(l10n?.noValidBidsFound ?? 'No valid bids found for this number.', isError: true);
        } else {
          int added = 0;
          setState(() {
            for (final item in info) {
              final pana = item['pana']?.toString() ?? '';
              final amtStr = item['amount']?.toString() ?? amount;

              if (pana.isEmpty) continue;

              // Merge duplicates (same digit & same UI type)
              final idx = addedEntries.indexWhere(
                (e) => e['digit'] == pana && e['type'] == selectedGameBetType,
              );
              if (idx != -1) {
                final old =
                    int.tryParse(addedEntries[idx]['amount'] ?? '0') ?? 0;
                final add = int.tryParse(amtStr) ?? parsedAmount;
                addedEntries[idx]['amount'] = (old + add).toString();
              } else {
                addedEntries.add({
                  "digit": pana,
                  "amount": (int.tryParse(amtStr) ?? parsedAmount).toString(),
                  "type": selectedGameBetType, // "Open" (UI tag)
                  "gameType": widget.gameCategoryType,
                });
              }
              added++;
            }
            bidController.clear();
            pointsController.clear();
          });

          if (added > 0) {
            _showMessage(l10n?.addedBidsFromApiResponse(added) ?? 'Added $added bids from API response.');
          } else {
            _showMessage(l10n?.allBidsAlreadyExist ?? 'All bids already exist.', isError: true);
          }
        }
      } else {
        final l10n = AppLocalizations.of(context);
        _showMessage(
          responseData['msg'] ??
              (l10n?.bidRequestFailed(response.statusCode) ?? 'Bid request failed with status: ${response.statusCode}'),
          isError: true,
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      log('Error fetching bids: $e', name: 'StarlineDPMotorsScreenAPIError');
      _showMessage(l10n?.unexpectedErrorOccurred(e.toString()) ?? 'An unexpected error occurred: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isApiCalling = false);
    }
  }

  // ---------------- remove ----------------
  void _removeEntry(int index) {
    _clearMessage();
    if (_isApiCalling || index < 0 || index >= addedEntries.length) return;

    final l10n = AppLocalizations.of(context);
    final removedEntry = addedEntries[index];
    setState(() {
      addedEntries.removeAt(index);
    });
    _showMessage(
      l10n?.removedBidNumberType(removedEntry['digit'] ?? '', removedEntry['type'] ?? '') ?? 'Removed bid: Number ${removedEntry['digit']}, Type ${removedEntry['type']}.',
    );
  }

  // ---------------- totals ----------------
  int _getTotalPoints() {
    return addedEntries.fold(
      0,
      (sum, item) => sum + (int.tryParse(item['amount'] ?? '0') ?? 0),
    );
  }

  int _getTotalPointsForSelectedGameType() {
    return addedEntries
        .where(
          (e) =>
              (e["type"] ?? "").toUpperCase() ==
              selectedGameBetType.toUpperCase(),
        )
        .fold(
          0,
          (sum, item) => sum + (int.tryParse(item['amount'] ?? '0') ?? 0),
        );
  }

  // ---------------- confirm ----------------
  void _showConfirmationDialog() {
    _clearMessage();
    if (_isApiCalling) return;

    final l10n = AppLocalizations.of(context);
    final int totalPointsForCurrentType = _getTotalPointsForSelectedGameType();
    if (totalPointsForCurrentType == 0) {
      _showMessage(
        l10n?.noBidsAddedForSelectedGameType ?? 'No bids added for the selected game type to submit.',
        isError: true,
      );
      return;
    }
    if (walletBalance < totalPointsForCurrentType) {
      _showMessage(
        l10n?.insufficientWalletBalanceForSelectedGameType ?? 'Insufficient wallet balance for selected game type.',
        isError: true,
      );
      return;
    }

    final String formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.now());

    final List<Map<String, String>> bidsToShowInDialog = addedEntries
        .where(
          (e) =>
              (e["type"] ?? "").toUpperCase() ==
              selectedGameBetType.toUpperCase(),
        )
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.gameName,
        gameDate: formattedDate,
        bids: bidsToShowInDialog.map((bid) {
          return {
            "digit": bid['digit']!,
            "points": bid['amount']!,
            "type": "${bid['gameType']} (${bid['type']})",
            "pana": bid['digit']!,
            "jodi": "",
          };
        }).toList(),
        totalBids: bidsToShowInDialog.length,
        totalBidsAmount: totalPointsForCurrentType,
        walletBalanceBeforeDeduction: walletBalance,
        walletBalanceAfterDeduction: (walletBalance - totalPointsForCurrentType)
            .toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameCategoryType,
        onConfirm: () async {
          setState(() => _isApiCalling = true);
          await _placeFinalBids();
          if (mounted) setState(() => _isApiCalling = false);
        },
      ),
    );
  }

  // ---------------- submit ----------------
  Future<bool> _placeFinalBids() async {
    // Build payload for the currently selected UI type ("Open")
    final Map<String, String> bidPayload = {};
    int currentBatchTotalPoints = 0;

    for (final entry in addedEntries) {
      if ((entry["type"] ?? "").toUpperCase() ==
          selectedGameBetType.toUpperCase()) {
        final String digit = entry["digit"] ?? "";
        final String amount = entry["amount"] ?? "0";
        if (digit.isNotEmpty && int.tryParse(amount) != null) {
          bidPayload[digit] = amount;
          currentBatchTotalPoints += int.parse(amount);
        }
      }
    }

    final l10n = AppLocalizations.of(context);
    if (bidPayload.isEmpty) {
      if (!mounted) return false;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BidFailureDialog(
          errorMessage: l10n?.noValidBidsForSelectedGameType ?? 'No valid bids for the selected game type.',
        ),
      );
      return false;
    }

    if (accessToken.isEmpty || registerId.isEmpty) {
      if (!mounted) return false;
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
        bidAmounts: bidPayload,
        gameType: widget.gameCategoryType, // e.g. "dpMotor" (backend key)
        gameId: widget.gameId, // TYPE id (sent as STRING)
        totalBidAmount: currentBatchTotalPoints,
      );

      if (!mounted) return false;

      if (result['status'] == true) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const BidSuccessDialog(),
        );

        // wallet balance
        final dynamic updatedBalanceRaw =
            result['updatedWalletBalance'] ??
            result['data']?['updatedWalletBalance'] ??
            result['data']?['wallet_balance'];
        final int updatedBalance =
            int.tryParse(updatedBalanceRaw?.toString() ?? '') ??
            (walletBalance - currentBatchTotalPoints);

        setState(() => walletBalance = updatedBalance);
        await _bidService.updateWalletBalance(updatedBalance);
        userController.walletBalance.value = updatedBalance.toString();

        // Remove only submitted type ("Open")
        setState(() {
          addedEntries.removeWhere(
            (e) =>
                (e["type"] ?? "").toUpperCase() ==
                selectedGameBetType.toUpperCase(),
          );
        });
        return true;
      } else {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => BidFailureDialog(
            errorMessage: result['msg'] ?? 'Something went wrong',
          ),
        );
        return false;
      }
    } catch (e) {
      log(
        'Error during bid placement: $e',
        name: 'StarlineDPMotorsScreenBidError',
      );
      final l10n = AppLocalizations.of(context);
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

  // ---------------- UI ----------------
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                  ), // Remove horizontal margin
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        30,
                      ), // Match JodiBulkScreen radius
                      topRight: Radius.circular(
                        30,
                      ), // Match JodiBulkScreen radius
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
                              children: [
                                // 🔙 Back Button
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

                                const SizedBox(width: 8),

                                // 📝 TITLE (dot dot)
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis, // 🔥 DOT DOT
                                    style: const TextStyle(
                                      color: Color(0xFF0F4C81),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // 💰 WALLET (ALWAYS VISIBLE)
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
                                      mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
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
                                _inputRow(
                                  "${l10n?.enterNumber ?? 'Enter Number:'}",
                                  _buildBidInputField(),
                                ),
                                const SizedBox(height: 12),
                                _inputRow(
                                  "${l10n?.enterPoints ?? 'Enter Points'}:",
                                  _buildTextField(
                                    pointsController,
                                    l10n?.enterAmount ?? "Enter Amount",
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
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
                                        onPressed: _isApiCalling
                                            ? null
                                            : _addEntry,
                                        child: _isApiCalling
                                            ? const CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
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
                          if (addedEntries.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l10n?.digit ?? "Digit",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      l10n?.amountLabel ?? "Amount",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      l10n?.gameTypeLabel ?? "Game Type",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ),
                          if (addedEntries.isNotEmpty)
                            const Divider(thickness: 1),
                          Expanded(
                            child: addedEntries.isEmpty
                                ? Center(child: Text(l10n?.noDataAddedYet ?? "No data added yet"))
                                : ListView.builder(
                                    itemCount: addedEntries.length,
                                    itemBuilder: (_, index) {
                                      final entry = addedEntries[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ), // 👈 Rounded border
                                            border: Border.all(
                                                color: Color(0xFF0F4C81), // 👈 Blue border
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    entry['digit']!,
                                                    style:
                                                        GoogleFonts.poppins(color: Color(0xFF0F4C81)),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    entry['amount']!,
                                                    style:
                                                        GoogleFonts.poppins(color: Color(0xFF0F4C81)),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    '${entry['gameType']} (${entry['type']})',
                                                    style:
                                                        GoogleFonts.poppins(color: Color(0xFF0F4C81)),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Color(0xFF3882F6),
                                                  ),
                                                  onPressed: _isApiCalling
                                                      ? null
                                                      : () =>
                                                            _removeEntry(index),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          if (addedEntries.isNotEmpty) _buildBottomBar(),
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
                  color: Color(0xFF0F4C81),
                ),
              ),
            ),
          ),
          Expanded(flex: 3, child: field),
        ],
      ),
    );
  }

  Widget _buildBidInputField() {
    return SizedBox(
      width: double.infinity,
      height: 35,
      child: TextFormField(
        controller: bidController,
        cursorColor: Color(0xFF3882F6),
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontSize: 14, color: Color(0xFF0F4C81)),
        inputFormatters: [
          LengthLimitingTextInputFormatter(7),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onTap: _clearMessage,
        enabled: !_isApiCalling,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)?.enterNumberHint ?? "Enter a number",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              8,
            ), // Changed to match other screens
            borderSide: const BorderSide(color: Color(0xFF0F4C81)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              8,
            ), // Changed to match other screens
            borderSide: const BorderSide(color: Color(0xFF0F4C81)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              8,
            ), // Changed to match other screens
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
      height: 35,
      child: TextFormField(
        controller: controller,
        cursorColor: Color(0xFF3882F6),
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(fontSize: 14, color: Color(0xFF0F4C81)),
        inputFormatters: inputFormatters,
        onTap: _clearMessage,
        enabled: !_isApiCalling,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              8,
            ), // Changed to match other screens
            borderSide: const BorderSide(color: Color(0xFF0F4C81)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              8,
            ), // Changed to match other screens
            borderSide: const BorderSide(color: Color(0xFF0F4C81)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              8,
            ), // Changed to match other screens
            borderSide: const BorderSide(color: Color(0xFF3882F6), width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context);
    final int totalBids = addedEntries.length;
    final int totalPoints = _getTotalPoints();
    final int totalPointsForSelectedType = _getTotalPointsForSelectedGameType();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          _summary(l10n?.bids(totalBids) ?? 'Bids', '$totalBids'),
          _summary((l10n?.pointsLabel?.toString() ?? 'Points') as String, '$totalPoints'),
          ElevatedButton(
            onPressed: (_isApiCalling || totalPointsForSelectedType == 0)
                ? null
                : _showConfirmationDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (_isApiCalling || totalPointsForSelectedType == 0)
                  ? Colors.grey
                  : Color(0xFF3882F6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child: _isApiCalling
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
  }

  Widget _summary(String t, String v) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        t,
        style: GoogleFonts.poppins(fontSize: 14, color: Color(0xFF0F4C81)),
      ),
      Text(
        v,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
      ),
    ],
  );
}
