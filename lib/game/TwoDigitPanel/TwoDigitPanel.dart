import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../Helper/UserController.dart';
import '../../components/AnimatedMessageBar.dart';
import '../../components/BidConfirmationDialog.dart';
import '../../components/BidFailureDialog.dart';
import '../../components/BidSuccessDialog.dart';
import '../../l10n/app_localizations.dart';
import '../../ulits/Constents.dart';

class Bid {
  final String digit; 
  final String amount; 
  final String pana; 

  const Bid({required this.digit, required this.amount, required this.pana});

  Bid copyWith({String? digit, String? amount, String? pana}) {
    return Bid(
      digit: digit ?? this.digit,
      amount: amount ?? this.amount,
      pana: pana ?? this.pana,
    );
  }
}

class TwoDigitPanelScreen extends StatefulWidget {
  final String title;
  final int gameId;
  final String gameType; 

  const TwoDigitPanelScreen({
    super.key,
    required this.title,
    required this.gameId,
    this.gameType = "twoDigitsPanel",
  });

  @override
  State<TwoDigitPanelScreen> createState() => _TwoDigitPanelScreenState();
}

class _TwoDigitPanelScreenState extends State<TwoDigitPanelScreen> {
  final TextEditingController digitController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final List<Bid> _bids = <Bid>[];
  final GetStorage storage = GetStorage();
  final UserController userController = Get.find<UserController>();

  String accessToken = '';
  String registerId = '';
  bool accountStatus = false;
  int walletBalance = 0;

  static const String _deviceId = 'device_id';
  static const String _deviceName = 'device_name';

  String? _message;
  bool _isError = false;
  Key _messageBarKey = UniqueKey();
  bool _isAddBidApiCalling = false;
  bool _isSubmitBidApiCalling = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    accessToken = storage.read('accessToken') ?? '';
    registerId = storage.read('registerId') ?? '';
    accountStatus = userController.accountStatus.value;
    walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
  }

  @override
  void dispose() {
    digitController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _message = msg;
      _isError = isError;
      _messageBarKey = UniqueKey();
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }

  int get _totalPoints => _bids.fold(0, (sum, b) => sum + (int.tryParse(b.amount) ?? 0));

  Future<void> addBid() async {
    final l10n = AppLocalizations.of(context);
    final String twoDigit = digitController.text.trim();
    final String amountText = amountController.text.trim();

    if (twoDigit.length != 2) { _showMessage('Enter 2-digit number.', isError: true); return; }
    final int? perPana = int.tryParse(amountText);
    if (perPana == null || perPana < 10) { _showMessage('Min points 10.', isError: true); return; }

    setState(() => _isAddBidApiCalling = true);

    try {
      final url = Uri.parse('${Constant.apiEndpoint}two-digits-panel-pana');
      final resp = await http.post(
        url,
        headers: {
          'deviceId': _deviceId,
          'deviceName': _deviceName,
          'accessStatus': accountStatus ? '1' : '0',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({"digit": twoDigit, "amount": perPana}),
      );

      final map = jsonDecode(resp.body);
      if (resp.statusCode == 200 && map['status'] == true) {
        final List info = map['info'] ?? [];
        if (info.isEmpty) { _showMessage('No panna found.', isError: true); return; }

        setState(() {
          for (var it in info) {
            final String p = it['pana']?.toString() ?? '';
            final String a = it['amount']?.toString() ?? perPana.toString();
            final idx = _bids.indexWhere((e) => e.pana == p);
            if (idx >= 0) {
              _bids[idx] = _bids[idx].copyWith(amount: a, digit: twoDigit);
            } else {
              _bids.add(Bid(digit: twoDigit, amount: a, pana: p));
            }
          }
          digitController.clear();
          amountController.clear();
        });
        _showMessage('Panna added successfully.');
      } else {
        _showMessage(map['msg'] ?? 'Failed to fetch.');
      }
    } catch (e) {
      _showMessage('Network error.', isError: true);
    } finally {
      if (mounted) setState(() => _isAddBidApiCalling = false);
    }
  }

  void _confirm() {
    if (_bids.isEmpty) { _showMessage('Add some panna first.', isError: true); return; }
    if (walletBalance < _totalPoints) { _showMessage('Insufficient balance.', isError: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: _bids.map((b) => {"digit": b.pana, "points": b.amount, "type": "Two Digits Panel", "pana": b.pana}).toList(),
        totalBids: _bids.length,
        totalBidsAmount: _totalPoints,
        walletBalanceBeforeDeduction: walletBalance,
        walletBalanceAfterDeduction: (walletBalance - _totalPoints).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameType,
        onConfirm: () => _submitAll(),
      ),
    );
  }

  Future<void> _submitAll() async {
    setState(() => _isSubmitBidApiCalling = true);
    try {
      final total = _totalPoints;
      final payload = _bids.map((b) => {"sessionType": "twoDigitsPanel", "digit": b.pana, "pana": b.pana, "bidAmount": int.parse(b.amount)}).toList();
      
      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}place-bid'),
        headers: {
          'deviceId': _deviceId,
          'deviceName': _deviceName,
          'accessStatus': accountStatus ? '1' : '0',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({"registerId": registerId, "gameId": widget.gameId, "bidAmount": total, "gameType": widget.gameType, "bid": payload}),
      );

      final map = jsonDecode(resp.body);
      if (resp.statusCode == 200 && (map['status'] == true || map['status'] == 'true')) {
        final newBal = walletBalance - total;
        userController.walletBalance.value = newBal.toString();
        setState(() {
          walletBalance = newBal;
          _bids.clear();
        });
        showDialog(context: context, builder: (_) => const BidSuccessDialog());
      } else {
        showDialog(context: context, builder: (_) => BidFailureDialog(errorMessage: map['msg'] ?? 'Failed.'));
      }
    } catch (e) {
      _showMessage('Submit error.', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitBidApiCalling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3882F6).withOpacity(0.1)),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF3882F6), size: 18),
            ),
          ),
        ),
        title: Text(widget.title, style: GoogleFonts.poppins(color: const Color(0xFF0F4C81), fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          Obx(() => Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF0B1223), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Image.asset("assets/images/ic_wallet.png", width: 16, height: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text("₹${userController.walletBalance.value}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          )),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Enter Two Digits'), const SizedBox(height: 8), _buildInput(digitController, 'e.g. 07', max: 2, enabled: !_isAddBidApiCalling)])),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Enter Points'), const SizedBox(height: 8), _buildInput(amountController, 'Points', enabled: !_isAddBidApiCalling)])),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _isAddBidApiCalling || _isSubmitBidApiCalling ? null : addBid,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: _isAddBidApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('ADD BID', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Expanded(
                        child: _bids.isEmpty
                            ? Center(child: Text('No bids added yet', style: GoogleFonts.poppins(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                itemCount: _bids.length,
                                itemBuilder: (_, i) => _buildBidCard(_bids[i], i),
                              ),
                      ),
                    ],
                  ),
                  if (_message != null)
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: AnimatedMessageBar(key: _messageBarKey, message: _message!, isError: _isError, onDismissed: () => setState(() => _message = null)),
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
              child: _buildBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81)));

  Widget _buildInput(TextEditingController controller, String hint, {int? max, bool enabled = true}) => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: controller, enabled: enabled, keyboardType: TextInputType.number, inputFormatters: max != null ? [LengthLimitingTextInputFormatter(max)] : [], style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _buildBidCard(Bid bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(bid.pana, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid.amount} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text('Digit: ${bid.digit}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22), onPressed: () => setState(() => _bids.removeAt(i))),
    ]),
  );

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(children: [
        Expanded(child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Bids', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${_bids.length}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('$_totalPoints', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isSubmitBidApiCalling || _bids.isEmpty ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isSubmitBidApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
