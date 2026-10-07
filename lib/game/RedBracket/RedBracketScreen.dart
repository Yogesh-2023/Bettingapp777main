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
import 'package:new_sara/l10n/app_localizations.dart';

import '../../Helper/UserController.dart';
import '../../components/AnimatedMessageBar.dart';
import '../../components/BidConfirmationDialog.dart';
import '../../components/BidFailureDialog.dart';
import '../../components/BidSuccessDialog.dart';
import '../../ulits/Constents.dart';

enum BracketType { half, full }

class RedBracketBoardScreen extends StatefulWidget {
  final String screenTitle;
  final int gameId;
  final String gameType;

  const RedBracketBoardScreen({
    super.key,
    required this.screenTitle,
    required this.gameId,
    required this.gameType,
  });

  @override
  State<RedBracketBoardScreen> createState() => _RedBracketBoardScreenState();
}

class _RedBracketBoardScreenState extends State<RedBracketBoardScreen> {
  final TextEditingController _amountController = TextEditingController();
  final List<Map<String, String>> _bids = [];
  BracketType _bracketType = BracketType.half;

  final GetStorage _storage = GetStorage();
  final UserController userController = Get.find<UserController>();

  late String _accessToken;
  late String _registerId;
  late bool _accountStatus;
  late int _walletBalance;
  bool _isBusy = false;

  String? _message;
  bool _isError = false;
  Key _messageBarKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initAuthAndWallet();
  }

  void _initAuthAndWallet() {
    _accessToken = _storage.read('accessToken')?.toString() ?? '';
    _registerId = _storage.read('registerId')?.toString() ?? '';
    _accountStatus = userController.accountStatus.value;
    _walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
  }

  @override
  void dispose() {
    _amountController.dispose();
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

  int _getTotalPoints() => _bids.fold(0, (s, e) => s + (int.tryParse(e['points'] ?? '0') ?? 0));

  Future<void> _addBid() async {
    final amtText = _amountController.text.trim();
    final int? amt = int.tryParse(amtText);
    if (amt == null || amt < 10) { _showMessage('Min points 10.', isError: true); return; }

    setState(() => _isBusy = true);
    try {
      final type = _bracketType == BracketType.half ? 'halfBracket' : 'fullBracket';
      final source = _bracketType == BracketType.half ? 'HALF' : 'FULL';

      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}red-bracket-jodi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
          'deviceId': 'device_red_bracket',
          'deviceName': 'RedBracketScreen',
          'accessStatus': _accountStatus ? '1' : '0',
        },
        body: jsonEncode({'type': type, 'amount': amt}),
      );

      final map = jsonDecode(resp.body);
      if (resp.statusCode == 200 && map['status'] == true) {
        final List info = map['info'] ?? [];
        setState(() {
          for (final it in info) {
            final d = it['pana'].toString();
            final a = int.parse(it['amount'].toString());
            final i = _bids.indexWhere((b) => b['digit'] == d && b['source'] == source);
            if (i >= 0) {
              final cur = int.tryParse(_bids[i]['points'] ?? '0') ?? 0;
              _bids[i]['points'] = (cur + a).toString();
            } else {
              _bids.add({'digit': d, 'points': a.toString(), 'source': source});
            }
          }
          _amountController.clear();
        });
        _showMessage('Bids added.');
      } else {
        _showMessage(map['msg'] ?? 'Add failed.', isError: true);
      }
    } catch (e) {
      _showMessage('Network error.', isError: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _confirm() {
    if (_bids.isEmpty) { _showMessage('Add some bids first.', isError: true); return; }
    final total = _getTotalPoints();
    if (_walletBalance < total) { _showMessage('Insufficient balance.', isError: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.screenTitle,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: _bids.map((b) => {'digit': b['digit']!, 'pana': b['digit']!, 'points': b['points']!, 'type': 'RED BRACKET (${b['source']})', 'jodi': b['digit']!}).toList(),
        totalBids: _bids.length,
        totalBidsAmount: total,
        walletBalanceBeforeDeduction: _walletBalance,
        walletBalanceAfterDeduction: (_walletBalance - total).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameType,
        onConfirm: () => _submitAll(total),
      ),
    );
  }

  Future<void> _submitAll(int totalPoints) async {
    setState(() => _isBusy = true);
    try {
      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}place-bid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
          'deviceId': 'device_red_bracket',
          'deviceName': 'RedBracketScreen',
          'accessStatus': _accountStatus ? '1' : '0',
        },
        body: jsonEncode({
          "registerId": _registerId,
          "gameId": widget.gameId,
          "bidAmount": totalPoints,
          "gameType": "redBracket",
          "bid": _bids.map((b) => {"sessionType": "redBracket", "digit": b['digit'], "pana": b['digit'], "bidAmount": int.parse(b['points']!)}).toList(),
        }),
      );

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && (data['status'] == true || data['status'] == 'true')) {
        final newBal = _walletBalance - totalPoints;
        userController.walletBalance.value = newBal.toString();
        setState(() {
          _walletBalance = newBal;
          _bids.clear();
        });
        showDialog(context: context, builder: (_) => const BidSuccessDialog());
      } else {
        showDialog(context: context, builder: (_) => BidFailureDialog(errorMessage: data['msg'] ?? 'Failed.'));
      }
    } catch (e) {
      _showMessage('Submit error.', isError: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
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
        title: Text(widget.screenTitle, style: GoogleFonts.poppins(color: const Color(0xFF0F4C81), fontSize: 18, fontWeight: FontWeight.w600)),
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
                                _radio(BracketType.half, 'Half Red Bracket'),
                                const SizedBox(width: 16),
                                _radio(BracketType.full, 'Full Red Bracket'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _label('Enter Points'),
                            const SizedBox(height: 8),
                            _buildInput(_amountController, 'Points'),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _isBusy ? null : _addBid,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: _isBusy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('ADD BID', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
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

  Widget _buildInput(TextEditingController controller, String hint) => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: controller, keyboardType: TextInputType.number, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _radio(BracketType type, String label) => GestureDetector(
    onTap: () => setState(() => _bracketType = type),
    child: Row(
      children: [
        Radio<BracketType>(value: type, groupValue: _bracketType, onChanged: (v) => setState(() => _bracketType = v!), activeColor: const Color(0xFF3882F6)),
        Text(label, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF0F4C81), fontWeight: FontWeight.w500)),
      ],
    ),
  );

  Widget _buildBidCard(Map<String, String> bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(bid['digit']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['points']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text('Source: ${bid['source']}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${_getTotalPoints()}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isBusy || _bids.isEmpty ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isBusy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}