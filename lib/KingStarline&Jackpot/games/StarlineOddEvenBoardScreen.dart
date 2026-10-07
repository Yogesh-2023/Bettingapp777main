import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:new_sara/KingStarline&Jackpot/StarlineBidService.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../../Helper/UserController.dart';
import '../../components/AnimatedMessageBar.dart';
import '../../components/BidConfirmationDialog.dart';
import '../../components/BidFailureDialog.dart';
import '../../components/BidSuccessDialog.dart';

enum GameType { odd, even }

class StarlineOddEvenBoardScreen extends StatefulWidget {
  final String title;
  final int gameId; // TYPE id (sent as STRING in API)
  final String gameType; // e.g. "oddEven"
  final String gameName; // label
  final bool selectionStatus; // UI only

  const StarlineOddEvenBoardScreen({
    Key? key,
    required this.title,
    required this.gameId,
    required this.gameType,
    this.gameName = "",
    required this.selectionStatus,
  }) : super(key: key);

  @override
  _StarlineOddEvenBoardScreenState createState() =>
      _StarlineOddEvenBoardScreenState();
}

class _StarlineOddEvenBoardScreenState
    extends State<StarlineOddEvenBoardScreen> {
  GameType? _selectedGameType = GameType.odd; // default Odd
  final TextEditingController _pointsController = TextEditingController();

  /// Parent entries: each is one Odd/Even line with points
  /// { "points": "xx", "bidType": "Odd"|"Even" }
  final List<Map<String, String>> _entries = [];

  // services / auth
  final GetStorage storage = GetStorage();
  late final StarlineBidService _bidService;
  final UserController userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  String _accessToken = '';
  String _registerId = '';
  bool _accountStatus = false;
  int _walletBalance = 0;
  bool _isApiCalling = false;

  // messages
  String? _messageToShow;
  bool _isErrorForMessage = false;
  Key _messageBarKey = UniqueKey();
  Timer? _msgTimer;

  // UI session label only (API me sessionType nahi bhejte)
  String get _lockedSession => widget.selectionStatus ? 'OPEN' : 'CLOSE';

  @override
  void initState() {
    super.initState();
    _bidService = StarlineBidService(storage);

    _accessToken = storage.read('accessToken') ?? '';
    _registerId = storage.read('registerId') ?? '';
    _accountStatus = userController.accountStatus.value;

    final num? bal = num.tryParse(userController.walletBalance.value);
    _walletBalance = bal?.toInt() ?? 0;

    // live wallet sync
    storage.listenKey('walletBalance', (value) {
      final int newBal = int.tryParse(value?.toString() ?? '0') ?? 0;
      if (mounted) setState(() => _walletBalance = newBal);
    });
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _msgTimer?.cancel();
    super.dispose();
  }

  // ---------- messaging ----------
  void _showMessage(String message, {bool isError = false}) {
    _msgTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _messageToShow = message;
      _isErrorForMessage = isError;
      _messageBarKey = UniqueKey();
    });
    _msgTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _messageToShow = null);
    });
  }

  void _clearMessage() {
    if (!mounted) return;
    if (_messageToShow != null) setState(() => _messageToShow = null);
  }

  // ---------- helpers ----------
  Market _detectMarket() {
    final s = ('${widget.title} ${widget.gameName}').toLowerCase();
    return s.contains('jackpot') ? Market.jackpot : Market.starline;
  }

  List<String> _digitsForType(String bidType) =>
      bidType == 'Odd' ? ['1', '3', '5', '7', '9'] : ['0', '2', '4', '6', '8'];

  /// Each map: {digit, points, bidType, parentIndex}
  List<Map<String, dynamic>> _expandedRowsForUi() {
    final out = <Map<String, dynamic>>[];
    for (int i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      final pts = e['points'] ?? '0';
      final type = e['bidType'] ?? 'Odd';
      for (final d in _digitsForType(type)) {
        out.add({'digit': d, 'points': pts, 'bidType': type, 'parentIndex': i});
      }
    }
    return out;
  }

  /// Build bulk bid map for API: {digit: points} and true total
  (Map<String, String>, int) _buildBidMapAndTrueTotal() {
    final Map<String, String> out = {};
    int trueTotal = 0;
    for (final e in _entries) {
      final pts = int.tryParse(e['points'] ?? '0') ?? 0;
      if (pts <= 0) continue;
      for (final d in _digitsForType(e['bidType'] ?? 'Odd')) {
        out[d] = pts.toString();
        trueTotal += pts;
      }
    }
    return (out, trueTotal);
  }

  int _getUiTotalPoints() {
    final (_, total) = _buildBidMapAndTrueTotal();
    return total;
  }

  // ---------- add/remove ----------
  void _addEntry() {
    if (_isApiCalling) return;
    _clearMessage();

    final l10n = AppLocalizations.of(context);
    final points = _pointsController.text.trim();
    final int? parsed = int.tryParse(points);
    if (parsed == null || parsed < 10 || parsed > 1000) {
      _showMessage(
        l10n?.points10To1000KeBeechDo ?? 'Points 10–1000 ke beech do.',
        isError: true,
      );
      return;
    }

    final bidType = _selectedGameType == GameType.odd ? 'Odd' : 'Even';

    setState(() {
      // keep single row per type (replace if exists)
      _entries.removeWhere((e) => e['bidType'] == bidType);
      _entries.add({'points': points, 'bidType': bidType});
      _pointsController.clear();
    });

    _showMessage(l10n?.bidTypeBidAdded(bidType) ?? '$bidType bid added!');
  }

  void _deleteParentByIndex(int parentIndex) {
    if (_isApiCalling) return;
    _clearMessage();
    final l10n = AppLocalizations.of(context);
    if (parentIndex < 0 || parentIndex >= _entries.length) return;
    setState(() => _entries.removeAt(parentIndex));
    _showMessage(l10n?.entryDeleted ?? 'Entry deleted.');
  }

  // ---------- confirm & submit ----------
  void _showConfirmationDialog() {
    _clearMessage();
    if (_isApiCalling) return;

    final l10n = AppLocalizations.of(context);
    if (_entries.isEmpty) {
      _showMessage(
        l10n?.pehleKoiEntryAddKaro ?? 'Pehle koi entry add karo.',
        isError: true,
      );
      return;
    }

    final (bidMap, trueTotal) = _buildBidMapAndTrueTotal();
    if (_walletBalance < trueTotal) {
      _showMessage(
        l10n?.insufficientWalletBalance ?? 'Wallet balance kam hai.',
        isError: true,
      );
      return;
    }

    final rows = _expandedRowsForUi()
        .map(
          (r) => {
            'digit': r['digit'] as String,
            'pana': '',
            'points': r['points'] as String,
            'type': _lockedSession, // UI label only
            'bidType': r['bidType'] as String,
          },
        )
        .toList();

    final when = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: when,
        bids: rows,
        totalBids: rows.length,
        totalBidsAmount: trueTotal,
        walletBalanceBeforeDeduction: _walletBalance,
        walletBalanceAfterDeduction: (_walletBalance - trueTotal).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameType,
        onConfirm: () async {
          if (!mounted) return;
          setState(() => _isApiCalling = true);
          final ok = await _placeFinalBids(bidMap, trueTotal);
          if (!mounted) return;
          setState(() => _isApiCalling = false);
          if (ok) setState(() => _entries.clear());
        },
      ),
    );
  }

  Future<bool> _placeFinalBids(
    Map<String, String> bidMap,
    int trueTotal,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (_accessToken.isEmpty || _registerId.isEmpty) {
      if (!mounted) return false;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BidFailureDialog(
          errorMessage:
              l10n?.authenticationErrorPleaseLoginAgain ??
              'Authentication error. Please log in again.',
        ),
      );
      return false;
    }

    // device info from storage (fallbacks)
    final deviceId = storage.read('deviceId')?.toString() ?? 'odd_even_device';
    final deviceName =
        storage.read('deviceName')?.toString() ?? 'OddEvenBoardApp';

    try {
      final market = _detectMarket();

      // Single unified payload; only endpoint differs by market.
      final resp = await _bidService.placeFinalBids(
        market: market,
        accessToken: _accessToken,
        registerId: _registerId,
        deviceId: deviceId,
        deviceName: deviceName,
        accountStatus: _accountStatus,
        bidAmounts: bidMap, // per-digit
        gameId: widget.gameId, // TYPE id (sent as STRING)
        gameType: widget.gameType, // e.g. "oddEven"
        totalBidAmount: trueTotal,
      );

      if (resp['status'] == true) {
        // Prefer server wallet
        final dynamic updatedBalanceRaw =
            resp['updatedWalletBalance'] ??
            resp['data']?['updatedWalletBalance'] ??
            resp['data']?['wallet_balance'];
        final int newBal =
            int.tryParse(updatedBalanceRaw?.toString() ?? '') ??
            (_walletBalance - trueTotal);

        await _bidService.updateWalletBalance(newBal);
        userController.walletBalance.value = newBal.toString();

        if (mounted) {
          setState(() => _walletBalance = newBal);
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const BidSuccessDialog(),
          );
        }
        return true;
      } else {
        final l10n = AppLocalizations.of(context);
        final msg =
            (resp['msg'] ??
                    (l10n?.unknownErrorOccurred ?? 'Unknown error occurred.'))
                .toString();
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => BidFailureDialog(errorMessage: msg),
          );
        }
        return false;
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      if (!mounted) return false;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BidFailureDialog(
          errorMessage:
              l10n?.unexpectedErrorDuringBidSubmission ??
              'An unexpected error occurred during bid submission.',
        ),
      );
      return false;
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expanded = _expandedRowsForUi();

    return Scaffold(
      // Apply the same gradient background as JodiBulkScreen.dart
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// 🔥 FULL GRADIENT BACKGROUND (Copied from JodiBulkScreen.dart)
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                  ), // Remove horizontal margin
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
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
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            widget.title,
                                            style: const TextStyle(
                                              color: Color(0xFF0F4C81),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow
                                                .ellipsis, // 🔥 dot dot
                                          ),
                                        ),

                                        Obx(
                                          () =>
                                              userController.accountStatus.value
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF0B1223,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
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
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RadioListTile<GameType>(
                                            title: Text(l10n?.odd ?? 'Odd'),
                                            value: GameType.odd,
                                            groupValue: _selectedGameType,
                                            onChanged: (v) => setState(
                                              () => _selectedGameType = v,
                                            ),
                                            activeColor: Color(0xFF3882F6),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                        Expanded(
                                          child: RadioListTile<GameType>(
                                            title: Text(l10n?.even ?? 'Even'),
                                            value: GameType.even,
                                            groupValue: _selectedGameType,
                                            onChanged: (v) => setState(
                                              () => _selectedGameType = v,
                                            ),
                                            activeColor: Color(0xFF3882F6),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${l10n?.enterPoints ?? 'Enter Points'} :',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F4C81),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _pointsField(_pointsController),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      child: ElevatedButton(
                                        onPressed: _isApiCalling
                                            ? null
                                            : _addEntry,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isApiCalling
                                              ? Colors.grey
                                              : Color(0xFF3882F6),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          elevation: 3,
                                        ),
                                        child: Text(
                                          l10n?.add ?? 'ADD',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Colors.grey),

                          // Header for expanded rows
                          if (expanded.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l10n?.digit ?? 'Digit',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      l10n?.pointsLabel ?? 'Points',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      l10n?.type ?? 'Type',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      l10n?.session ?? 'Session',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0F4C81),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ),
                          if (expanded.isNotEmpty)
                            const Divider(height: 1, color: Colors.grey),

                          // Expanded rows list (each digit)
                          Expanded(
                            child: expanded.isEmpty
                                ? Center(
                                    child: Text(
                                      l10n?.noEntriesYetAddData ??
                                          'No entries yet. Add some data!',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: expanded.length,
                                    itemBuilder: (_, i) {
                                      final r = expanded[i];
                                      final l10n = AppLocalizations.of(context);
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ), // 👈 Rounded border
                                          border: Border.all(
                                            color: Colors
                                                .grey
                                                .shade400, // 👈 Grey border
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 4.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  r['digit'] as String,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF0F4C81),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  r['points'] as String,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF0F4C81),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  r['bidType'] as String,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF0F4C81),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _lockedSession,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF3882F6),
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Color(0xFF3882F6),
                                                ),
                                                tooltip:
                                                    l10n?.removeThisBidTypeSet(
                                                      r['bidType'] as String,
                                                    ) ??
                                                    'Remove this ${r['bidType']} set',
                                                onPressed: _isApiCalling
                                                    ? null
                                                    : () =>
                                                          _deleteParentByIndex(
                                                            r['parentIndex']
                                                                as int,
                                                          ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          if (expanded.isNotEmpty) _bottomBar(),
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

  Widget _pointsField(TextEditingController c) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          8,
        ), // Changed to match other screens
        border: Border.all(
          color: Colors.grey,
        ), // Changed to match other screens
      ),
      child: TextField(
        cursorColor: Color(0xFF3882F6),
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onTap: _clearMessage,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)?.enterPoints ?? 'Enter Points',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 9,
          ),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    final l10n = AppLocalizations.of(context);
    final totalBids = _expandedRowsForUi().length; // per-digit rows
    final uiTotal = _getUiTotalPoints();
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.bidsLabel ?? 'Bids',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                '$totalBids',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.pointsLabel ?? 'Points',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                '$uiTotal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _isApiCalling ? null : _showConfirmationDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isApiCalling ? Colors.grey : Color(0xFF3882F6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child: Text(
              l10n?.submit ?? 'SUBMIT',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
