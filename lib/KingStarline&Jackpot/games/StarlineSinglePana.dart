import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_sara/KingStarline&Jackpot/StarlineBidService.dart';

import '../../../components/AnimatedMessageBar.dart';
import '../../../components/BidConfirmationDialog.dart';
import '../../../components/BidFailureDialog.dart';
import '../../../components/BidSuccessDialog.dart';
import '../../Helper/UserController.dart';
import '../../l10n/app_localizations.dart';

// ---- Single Panna master list ----
const List<String> Single_Pana = [
  "120",
  "123",
  "124",
  "125",
  "126",
  "127",
  "128",
  "129",
  "130",
  "134",
  "135",
  "136",
  "137",
  "138",
  "139",
  "140",
  "145",
  "146",
  "147",
  "148",
  "149",
  "150",
  "156",
  "157",
  "158",
  "159",
  "160",
  "167",
  "168",
  "169",
  "170",
  "178",
  "179",
  "180",
  "189",
  "190",
  "230",
  "234",
  "235",
  "236",
  "237",
  "238",
  "239",
  "240",
  "245",
  "246",
  "247",
  "248",
  "249",
  "250",
  "256",
  "257",
  "258",
  "259",
  "260",
  "267",
  "268",
  "269",
  "270",
  "278",
  "279",
  "280",
  "289",
  "290",
  "340",
  "345",
  "346",
  "347",
  "348",
  "349",
  "350",
  "356",
  "357",
  "358",
  "359",
  "360",
  "367",
  "368",
  "369",
  "370",
  "378",
  "379",
  "380",
  "389",
  "390",
  "450",
  "456",
  "457",
  "458",
  "459",
  "460",
  "467",
  "468",
  "469",
  "470",
  "478",
  "479",
  "480",
  "489",
  "490",
  "560",
  "567",
  "568",
  "569",
  "570",
  "578",
  "579",
  "580",
  "589",
  "590",
  "670",
  "678",
  "679",
  "680",
  "689",
  "690",
  "780",
  "789",
  "790",
  "890",
];

class StarlineSinglePannaScreen extends StatefulWidget {
  final String title; // e.g. "Starline Single Panna"
  final int gameId; // TYPE id (send as STRING in API)
  final String gameType; // e.g. "singlePana"
  final String gameName; // label, e.g. "Starline ..." or "Jackpot ..."
  final bool selectionStatus; // true => bidding open (UI only)

  const StarlineSinglePannaScreen({
    Key? key,
    required this.title,
    required this.gameId,
    required this.gameType,
    this.gameName = "",
    required this.selectionStatus,
  }) : super(key: key);

  @override
  State<StarlineSinglePannaScreen> createState() =>
      _StarlineSinglePannaScreenState();
}

class _StarlineSinglePannaScreenState extends State<StarlineSinglePannaScreen> {
  final TextEditingController digitController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // UI label only (API does not use sessionType)
  final String selectedGameType = 'Open';

  // auth / device
  final GetStorage _box = GetStorage();
  late String accessToken;
  late String registerId;
  String deviceId = "flutter_device";
  String deviceName = "Flutter_App";
  bool accountStatus = false;

  // app state
  List<Map<String, String>> bids = []; // {digit, amount, type}
  int walletBalance = 0;

  // message bar
  String? _messageToShow;
  bool _isErrorForMessage = false;
  Key _messageBarKey = UniqueKey();
  Timer? _hideTimer;

  final UserController userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  static const int _minBet = 10;
  static const int _maxBet = 1000;

  bool get _biddingClosed => !widget.selectionStatus;

  @override
  void initState() {
    super.initState();
    accessToken = _box.read('accessToken') ?? '';
    registerId = _box.read('registerId') ?? '';
    print("🔐 INIT → accessToken = $accessToken");
    print("👤 INIT → registerId = $registerId");
    deviceId = _box.read('deviceId')?.toString() ?? deviceId;
    deviceName = _box.read('deviceName')?.toString() ?? deviceName;
    accountStatus = userController.accountStatus.value;

    // wallet from controller (string) -> int
    final balNum = num.tryParse(userController.walletBalance.value);
    walletBalance = (balNum ?? 0).toInt();

    // live wallet sync
    _box.listenKey('walletBalance', (value) {
      final int newBal = int.tryParse(value?.toString() ?? '0') ?? 0;
      if (mounted) setState(() => walletBalance = newBal);
    });

    _loadSavedBids();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    digitController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // -------------------- storage helpers --------------------
  void _loadSavedBids() {
    final dynamic saved = _box.read('placedBids');
    if (saved is List) {
      final parsed = saved
          .whereType<Map>()
          .map(
            (e) => {
              'digit': e['digit']?.toString() ?? '',
              'amount': e['amount']?.toString() ?? '',
              'type': e['type']?.toString() ?? '',
            },
          )
          .where(
            (m) =>
                m['digit']!.isNotEmpty &&
                m['amount']!.isNotEmpty &&
                m['type']!.isNotEmpty,
          )
          .toList();
      setState(() => bids = parsed);
    }
  }

  void _saveBids() => _box.write('placedBids', bids);

  // -------------------- messages --------------------
  void _showMessage(String msg, {bool isError = false}) {
    _hideTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _messageToShow = msg;
      _isErrorForMessage = isError;
      _messageBarKey = UniqueKey();
    });
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _messageToShow = null);
    });
  }

  void _clearMessage() {
    _hideTimer?.cancel();
    if (mounted) setState(() => _messageToShow = null);
  }

  // -------------------- add/remove bids --------------------
  Future<void> _addBid() async {
    _clearMessage();
    final l10n = AppLocalizations.of(context);

    if (_biddingClosed) {
      _showMessage(l10n?.biddingIsClosedForThisSlot ?? 'Bidding is closed for this slot.', isError: true);
      return;
    }

    final digit = digitController.text.trim();
    final amount = amountController.text.trim();

    if (digit.isEmpty || amount.isEmpty) {
      _showMessage(l10n?.pleaseFillAllFields ?? 'Please fill in all fields.', isError: true);
      return;
    }
    if (!Single_Pana.contains(digit)) {
      _showMessage(l10n?.pleaseEnterValidSinglePanna ?? 'Please enter a valid Single Panna number.', isError: true);
      return;
    }
    final intAmount = int.tryParse(amount);
    if (intAmount == null || intAmount < _minBet || intAmount > _maxBet) {
      _showMessage(
        l10n?.amountMustBeBetween(_minBet, _maxBet) ?? 'Amount must be between $_minBet and $_maxBet.',
        isError: true,
      );
      return;
    }

    // wallet check with new/updated total
    final existingIdx = bids.indexWhere(
      (e) => e['digit'] == digit && e['type'] == selectedGameType,
    );
    int currentTotal = _getTotalPoints();
    if (existingIdx != -1) {
      currentTotal -= int.tryParse(bids[existingIdx]['amount'] ?? '0') ?? 0;
    }
    final nextTotal = currentTotal + intAmount;
    if (nextTotal > walletBalance) {
      _showMessage(l10n?.insufficientWalletBalance ?? 'Insufficient wallet balance.', isError: true);
      return;
    }

    setState(() {
      if (existingIdx != -1) {
        final cur = int.tryParse(bids[existingIdx]['amount']!) ?? 0;
        bids[existingIdx]['amount'] = (cur + intAmount).toString();
        _showMessage('${l10n?.updatedAmountForPanna ?? 'Updated amount for Panna:'} $digit.');
      } else {
        bids.add({
          'digit': digit,
          'amount': intAmount.toString(),
          'type': selectedGameType,
        });
        _showMessage('${l10n?.addedBidPanna ?? 'Added bid: Panna'} $digit, ${l10n?.amount ?? 'Amount'} $intAmount.');
      }
      digitController.clear();
      amountController.clear();
      FocusScope.of(context).unfocus();
      _saveBids();
    });
  }

  void _removeBid(int index) {
    _clearMessage();
    final l10n = AppLocalizations.of(context);
    final removedDigit = bids[index]['digit'] ?? '';
    setState(() => bids.removeAt(index));
    _saveBids();
    _showMessage(l10n?.bidRemovedFromList(removedDigit) ?? 'Bid for $removedDigit removed from list.');
  }

  int _getTotalPoints() =>
      bids.fold(0, (sum, e) => sum + (int.tryParse(e['amount'] ?? '0') ?? 0));

  // -------------------- confirm & submit --------------------
  void _showBidConfirmationDialog() {
    _clearMessage();
    final l10n = AppLocalizations.of(context);

    if (bids.isEmpty) {
      _showMessage(l10n?.pleaseAddAtLeastOneBidToConfirm ?? 'Please add at least one bid to confirm.', isError: true);
      return;
    }
    if (_biddingClosed) {
      _showMessage(l10n?.biddingIsClosedForThisSlot ?? 'Bidding is closed for this slot.', isError: true);
      return;
    }

    final totalPoints = _getTotalPoints();
    if (totalPoints > walletBalance) {
      _showMessage(l10n?.insufficientWalletBalanceForAllBids ?? 'Insufficient wallet balance for all bids.', isError: true);
      return;
    }

    final when = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: when,
        bids: bids, // {digit, amount, type} – your dialog already supports this
        totalBids: bids.length,
        totalBidsAmount: totalPoints,
        walletBalanceBeforeDeduction: walletBalance,
        walletBalanceAfterDeduction: (walletBalance - totalPoints).toString(),
        gameId: widget.gameId.toString(), // TYPE id as string
        gameType: widget.gameType, // "singlePana"
        onConfirm: () async {
          final ok = await _placeFinalBids();
          if (ok && mounted) {
            setState(() => bids.clear());
            _saveBids();
          }
        },
      ),
    );
  }

  Market _detectMarket() {
    final s = ('${widget.title} ${widget.gameName}').toLowerCase();
    return s.contains('jackpot') ? Market.jackpot : Market.starline;
  }

  Future<bool> _placeFinalBids() async {
    if (!mounted) return false;

    // build digit->amount map for current type
    final Map<String, String> bidPayload = {};
    int batchTotal = 0;
    for (final e in bids) {
      if ((e['type'] ?? '').toUpperCase() == selectedGameType.toUpperCase()) {
        final d = e['digit'] ?? '';
        final a = int.tryParse(e['amount'] ?? '0') ?? 0;
        if (d.isNotEmpty && a > 0) {
          bidPayload[d] = a.toString();
          batchTotal += a;
        }
      }
    }

    final l10n = AppLocalizations.of(context);
    if (bidPayload.isEmpty) {
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
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BidFailureDialog(
          errorMessage: l10n?.authenticationErrorPleaseLoginAgain ?? 'Authentication error. Please log in again.',
        ),
      );
      return false;
    }

    final service = StarlineBidService(_box); // unified: handles both endpoints
    bool success = false;
    String? err;

    try {
      final market = _detectMarket();

      final result = await service.placeFinalBids(
        market: market,
        accessToken: accessToken,
        registerId: registerId,
        deviceId: deviceId,
        deviceName: deviceName,
        accountStatus: accountStatus,
        bidAmounts: bidPayload,
        gameId: widget.gameId, // TYPE id (int here; service sends string)
        gameType: widget.gameType, // "singlePana"
        totalBidAmount: batchTotal,
      );

      if (!mounted) return false;

      success = result['status'] == true;
      if (!success) err = (result['msg'] ?? (l10n?.somethingWentWrong ?? 'Something went wrong')).toString();

      if (success) {
        // Prefer server wallet if available
        final dynamic updatedBalanceRaw =
            result['updatedWalletBalance'] ??
            result['data']?['updatedWalletBalance'] ??
            result['data']?['wallet_balance'];

        final int newBal =
            int.tryParse(updatedBalanceRaw?.toString() ?? '') ??
            (walletBalance - batchTotal);

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const BidSuccessDialog(),
        );

        setState(() => walletBalance = newBal);
        await service.updateWalletBalance(newBal);
        userController.walletBalance.value = newBal.toString();

        return true;
      }
    } catch (e) {
      log('Error during bid placement: $e', name: 'StarlineSinglePannaSubmit');
      err = l10n?.unexpectedErrorDuringBidSubmission ?? 'An unexpected error occurred during bid submission.';
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidFailureDialog(errorMessage: err ?? 'Unknown error'),
    );
    // (optional) keep bids for retry; comment this if you don't want to clear.
    // setState(() {
    //   bids.removeWhere((e) => (e['type'] ?? '').toUpperCase() == selectedGameType.toUpperCase());
    // });
    // _saveBids();
    return false;
  }

  // -------------------- UI --------------------
  Widget _inputRow(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          field,
        ],
      ),
    );
  }

  // Common input builder; digit field uses Autocomplete, amount normal textfield
  Widget _buildInputField(TextEditingController controller, String hint) {
    final isDigit = controller == digitController;

    if (!isDigit) {
      return SizedBox(
        height: 35,
        width: 150,
        child: TextFormField(
          controller: controller,
          cursorColor: Color(0xFF3882F6),
          keyboardType: TextInputType.number,
          onTap: _clearMessage,
          textAlignVertical: TextAlignVertical.center,
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
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      );
    }

    // Digit field with Autocomplete over Single_Pana
    return SizedBox(
      height: 35,
      width: 150,
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue tev) {
          if (tev.text.isEmpty) return const Iterable<String>.empty();
          return Single_Pana.where((p) => p.startsWith(tev.text));
        },
        onSelected: (sel) {
          digitController.text = sel;
          _clearMessage();
          FocusScope.of(context).unfocus();
        },
        fieldViewBuilder: (context, textCtrl, focusNode, onSubmit) {
          // keep external controller in sync
          textCtrl.addListener(() {
            if (digitController.text != textCtrl.text) {
              digitController.text = textCtrl.text;
              digitController.selection = textCtrl.selection;
            }
          });
          return TextFormField(
            controller: textCtrl,
            focusNode: focusNode,
            cursorColor: Color(0xFF3882F6),
            keyboardType: TextInputType.number,
            onTap: _clearMessage,
            textAlignVertical: TextAlignVertical.center,
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
            style: GoogleFonts.poppins(fontSize: 14),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(30),
              child: SizedBox(
                width: 150,
                height: 200,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (_, i) {
                    final opt = options.elementAt(i);
                    return InkWell(
                      onTap: () => onSelected(opt),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(opt, style: GoogleFonts.poppins()),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              l10n?.panna ?? 'Panna',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Color(0xFF0F4C81)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              l10n?.amount ?? 'Amount',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Color(0xFF0F4C81)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              l10n?.gameType ?? 'Game Type',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Color(0xFF0F4C81)),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
         color: Colors.white,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F4C81),
                                      ),
                                  ),
                                ),
                                Obx(
                                  () => userController.accountStatus.value
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0B1223),
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                "assets/images/ic_wallet.png",
                                                width: 18,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "₹${userController.walletBalance.value.isEmpty ? "0" : userController.walletBalance.value}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(width: 40),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          _inputRow(
                            l10n?.enterSinglePanna ?? 'Enter Single Panna:',
                            _buildInputField(digitController, l10n?.bidPanna ?? 'Bid Panna'),
                          ),
                          _inputRow(
                            l10n?.enterPointsColon ?? 'Enter Points:',
                            _buildInputField(amountController, l10n?.enterAmount ?? 'Enter Amount'),
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              height: 36,
                              width: 150,
                              child: ElevatedButton(
                                onPressed: _addBid,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF3882F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  l10n?.addBid ?? 'ADD BID',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          _buildTableHeader(),
                          Divider(color: Colors.grey.shade300),

                          Expanded(
                            child: bids.isEmpty
                                ? Center(
                                    child: Text(
                                      l10n?.noBidsAddedYet ?? 'No Bids Added',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black38,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: bids.length,
                                    itemBuilder: (context, index) {
                                      final bid = bids[index];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 0,
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
                                            horizontal: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  bid['digit']!,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(color: Color(0xFF0F4C81)),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  bid['amount']!,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(color: Color(0xFF0F4C81)),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  bid['type']!,
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.poppins(color: Color(0xFF0F4C81)),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Color(0xFF3882F6),
                                                ),
                                                onPressed: () =>
                                                    _removeBid(index),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          if (bids.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 3,
                                  ),
                                ],
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n?.totalPointsColon ?? 'Total Points:',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F4C81),
                                    ),
                                  ),
                                  Text(
                                    "${_getTotalPoints()}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F4C81),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _showBidConfirmationDialog,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF3882F6),
                                    ),
                                    child: Text(
                                      l10n?.confirm ?? 'CONFIRM',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
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
}
