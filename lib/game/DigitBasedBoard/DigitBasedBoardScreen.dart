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
import 'package:new_sara/BidsServicesBulk.dart';
import 'package:new_sara/Helper/UserController.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../../components/AnimatedMessageBar.dart';
import '../../components/BidConfirmationDialog.dart';
import '../../components/BidFailureDialog.dart';
import '../../components/BidSuccessDialog.dart';
import '../../ulits/Constents.dart';

class DigitBasedBoardScreen extends StatefulWidget {
  final String title;
  final String gameType;
  final String gameId;
  final String gameName;

  const DigitBasedBoardScreen({
    super.key,
    required this.title,
    required this.gameType,
    required this.gameId,
    required this.gameName,
  });

  @override
  State<DigitBasedBoardScreen> createState() => _DigitBasedBoardScreenState();
}

class _DigitBasedBoardScreenState extends State<DigitBasedBoardScreen> {
  final TextEditingController _leftDigitController = TextEditingController();
  final TextEditingController _rightDigitController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  final GetStorage _storage = GetStorage();
  final UserController userController = Get.find<UserController>();
  late final BidServiceBulk _bidService;

  String _accessToken = '';
  String _registerId = '';
  bool _accountStatus = false;
  int _walletBalance = 0;

  final List<Map<String, String>> _entries = [];
  bool _isAdding = false;
  bool _isSubmitting = false;

  String? _message;
  bool _isError = false;
  Key _messageBarKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _bidService = BidServiceBulk(_storage);
    _loadInitial();
  }

  void _loadInitial() {
    _accessToken = _storage.read('accessToken')?.toString() ?? '';
    _registerId = _storage.read('registerId')?.toString() ?? '';
    _accountStatus = userController.accountStatus.value;
    _walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
  }

  @override
  void dispose() {
    _leftDigitController.dispose();
    _rightDigitController.dispose();
    _pointsController.dispose();
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

  int _getTotalPoints() => _entries.fold(0, (s, e) => s + (int.tryParse(e['points'] ?? '0') ?? 0));

  Future<void> _addEntry() async {
    final leftTxt = _leftDigitController.text.trim();
    final rightTxt = _rightDigitController.text.trim();
    final ptsTxt = _pointsController.text.trim();

    if (leftTxt.isEmpty && rightTxt.isEmpty) { _showMessage('Enter Left or Right digit.', isError: true); return; }
    
    final int? pts = int.tryParse(ptsTxt);
    if (pts == null || pts < 10) { _showMessage('Min points 10.', isError: true); return; }

    setState(() => _isAdding = true);
    try {
      final body = {
        if (leftTxt.isNotEmpty) "leftDigit": int.parse(leftTxt),
        if (rightTxt.isNotEmpty) "rightDigit": int.parse(rightTxt),
        "amount": pts,
      };

      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}digit-based-jodi'),
        headers: {
          'deviceId': 'device_id',
          'deviceName': 'DigitBasedBoard',
          'accessStatus': _accountStatus ? '1' : '0',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && data['status'] == true) {
        final List info = data['info'] ?? [];
        if (info.isEmpty) { _showMessage('No jodi found.', isError: true); return; }

        setState(() {
          for (var item in info) {
            final d = item['pana']?.toString() ?? '';
            final a = int.tryParse(item['amount']?.toString() ?? '0') ?? 0;
            if (d.isNotEmpty && a > 0) {
              final idx = _entries.indexWhere((e) => e['digit'] == d);
              if (idx >= 0) {
                final cur = int.tryParse(_entries[idx]['points'] ?? '0') ?? 0;
                _entries[idx]['points'] = (cur + a).toString();
              } else {
                _entries.add({'digit': d, 'points': a.toString()});
              }
            }
          }
          _leftDigitController.clear();
          _rightDigitController.clear();
          _pointsController.clear();
        });
        _showMessage('Added successfully.');
      } else {
        _showMessage(data['msg'] ?? 'Failed.');
      }
    } catch (e) {
      _showMessage('Network error.', isError: true);
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _confirm() {
    if (_entries.isEmpty) { _showMessage('Add some bids first.', isError: true); return; }
    final total = _getTotalPoints();
    if (total > _walletBalance) { _showMessage('Insufficient balance.', isError: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: _entries.map((e) => {'digit': e['digit']!, 'points': e['points']!, 'type': 'Digit Based', 'pana': e['digit']!}).toList(),
        totalBids: _entries.length,
        totalBidsAmount: total,
        walletBalanceBeforeDeduction: _walletBalance,
        walletBalanceAfterDeduction: (_walletBalance - total).toString(),
        gameId: widget.gameId,
        gameType: widget.gameType,
        onConfirm: () => _submitBids(total),
      ),
    );
  }

  Future<bool> _submitBids(int totalPoints) async {
    setState(() => _isSubmitting = true);
    try {
      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}place-bid'),
        headers: {
          'deviceId': 'device_id',
          'deviceName': 'DigitBasedBoard',
          'accessStatus': _accountStatus ? '1' : '0',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          "registerId": _registerId,
          "gameId": int.tryParse(widget.gameId) ?? 0,
          "bidAmount": totalPoints,
          "gameType": widget.gameType,
          "bid": _entries.map((e) => {"sessionType": widget.gameType, "digit": e['digit'], "pana": e['digit'], "bidAmount": int.parse(e['points']!)}).toList(),
        }),
      );

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && (data['status'] == true || data['status'] == 'true')) {
        final newBal = _walletBalance - totalPoints;
        userController.walletBalance.value = newBal.toString();
        setState(() {
          _walletBalance = newBal;
          _entries.clear();
        });
        showDialog(context: context, builder: (_) => const BidSuccessDialog());
        return true;
      } else {
        showDialog(context: context, builder: (_) => BidFailureDialog(errorMessage: data['msg'] ?? 'Failed.'));
        return false;
      }
    } catch (e) {
      _showMessage('Submit error.', isError: true);
      return false;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Left Digit'), const SizedBox(height: 8), _buildInput(_leftDigitController, '0-9', max: 1)])),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Right Digit'), const SizedBox(height: 8), _buildInput(_rightDigitController, '0-9', max: 1)])),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _label('Enter Points'),
                            const SizedBox(height: 8),
                            _buildInput(_pointsCtrl, 'Points'),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _isAdding || _isSubmitting ? null : _addEntry,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: _isAdding ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('ADD BID', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Expanded(
                        child: _entries.isEmpty
                            ? Center(child: Text('No bids added yet', style: GoogleFonts.poppins(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                itemCount: _entries.length,
                                itemBuilder: (_, i) => _buildBidCard(_entries[i], i),
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

  // Fixing the variable name used in build
  TextEditingController get _pointsCtrl => _pointsController;

  Widget _label(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81)));

  Widget _buildInput(TextEditingController controller, String hint, {int? max}) => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: controller, keyboardType: TextInputType.number, inputFormatters: max != null ? [LengthLimitingTextInputFormatter(max)] : [], style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _buildBidCard(Map<String, String> bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(bid['digit']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['points']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text('Digit Based Jodi', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22), onPressed: () => setState(() => _entries.removeAt(i))),
    ]),
  );

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(children: [
        Expanded(child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Bids', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${_entries.length}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${_getTotalPoints()}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isSubmitting || _entries.isEmpty ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}