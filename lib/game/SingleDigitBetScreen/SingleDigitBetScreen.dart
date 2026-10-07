import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../BidService.dart';
import '../../Helper/UserController.dart';
import '../../components/AnimatedMessageBar.dart';
import '../../components/BidConfirmationDialog.dart';
import '../../components/BidFailureDialog.dart';
import '../../components/BidSuccessDialog.dart';
import '../../l10n/app_localizations.dart';

class SingleDigitBetScreen extends StatefulWidget {
  final String title;
  final String gameCategoryType;
  final int gameId;
  final String gameName;
  final bool selectionStatus;

  const SingleDigitBetScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameName,
    required this.gameCategoryType,
    required this.selectionStatus,
  });

  @override
  State<SingleDigitBetScreen> createState() => _SingleDigitBetScreenState();
}

class _SingleDigitBetScreenState extends State<SingleDigitBetScreen> {
  String _selectedSession = 'OPEN';
  String _selectedMode = 'Easy Mode';
  final TextEditingController _pointsCtrl = TextEditingController();
  final Map<String, TextEditingController> _digitCtrls = {};
  
  // Special Mode controllers
  final TextEditingController _spDigitCtrl = TextEditingController();
  final TextEditingController _spPointsCtrl = TextEditingController();

  final List<String> _digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  List<Map<String, String>> _bids = [];

  final GetStorage _storage = GetStorage();
  late BidService _bidService;
  final UserController userController = Get.find<UserController>();

  late String _accessToken;
  late String _registerId;
  late bool _accountStatus;
  int _walletBalance = 0;
  bool _isApiCalling = false;

  String? _message;
  bool _isError = false;
  Key _messageBarKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _bidService = BidService(_storage);
    _loadInitial();
    for (var d in _digits) _digitCtrls[d] = TextEditingController();
  }

  void _loadInitial() {
    if (!widget.selectionStatus) _selectedSession = 'CLOSE';
    _accessToken = _storage.read('accessToken') ?? '';
    _registerId = _storage.read('registerId') ?? '';
    _accountStatus = userController.accountStatus.value;
    _walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
  }

  @override
  void dispose() {
    for (var ctrl in _digitCtrls.values) ctrl.dispose();
    _pointsCtrl.dispose();
    _spDigitCtrl.dispose();
    _spPointsCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    setState(() { _message = msg; _isError = isError; _messageBarKey = UniqueKey(); });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _message = null); });
  }

  void _addSpecialBid() {
    final d = _spDigitCtrl.text.trim();
    final p = _spPointsCtrl.text.trim();
    if (!_digits.contains(d)) { _showMessage('Enter digit 0-9.', isError: true); return; }
    final pts = int.tryParse(p);
    if (pts == null || pts < 10) { _showMessage('Min points 10.', isError: true); return; }

    if (_getTotalPoints() + pts > _walletBalance) { _showMessage('Insufficient balance.', isError: true); return; }

    setState(() {
      final idx = _bids.indexWhere((b) => b['digit'] == d && b['type'] == _selectedSession);
      if (idx != -1) {
        _bids[idx]['points'] = (int.parse(_bids[idx]['points']!) + pts).toString();
      } else {
        _bids.add({'digit': d, 'points': p, 'type': _selectedSession});
      }
      _spDigitCtrl.clear(); _spPointsCtrl.clear();
    });
    _showMessage('Added Digit $d.');
  }

  void _updateEasyBids() {
    List<Map<String, String>> newBids = [];
    for (var d in _digits) {
      final p = _digitCtrls[d]!.text.trim();
      if (p.isNotEmpty) {
        final pts = int.tryParse(p);
        if (pts != null && pts >= 10) {
          newBids.add({'digit': d, 'points': p, 'type': _selectedSession});
        }
      }
    }
    setState(() { _bids = newBids; });
  }

  int _getTotalPoints() {
    if (_selectedMode == 'Easy Mode') {
      return _digitCtrls.values.fold(0, (s, c) => s + (int.tryParse(c.text) ?? 0));
    }
    return _bids.fold(0, (s, b) => s + int.parse(b['points']!));
  }

  void _confirm() {
    if (_selectedMode == 'Easy Mode') _updateEasyBids();
    if (_bids.isEmpty) { _showMessage('Add some bids first.', isError: true); return; }
    final total = _getTotalPoints();
    if (total > _walletBalance) { _showMessage('Insufficient balance.', isError: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: _bids.map((b) => {"digit": b['digit']!, "points": b['points']!, "type": b['type']!, "pana": ""}).toList(),
        totalBids: _bids.length,
        totalBidsAmount: total,
        walletBalanceBeforeDeduction: _walletBalance,
        walletBalanceAfterDeduction: (_walletBalance - total).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameCategoryType,
        onConfirm: () => _submit(total),
      ),
    );
  }

  Future<void> _submit(int total) async {
    setState(() => _isApiCalling = true);
    Map<String, String> openBids = {}; Map<String, String> closeBids = {};
    for (var b in _bids) { if (b['type'] == 'OPEN') openBids[b['digit']!] = b['points']!; else closeBids[b['digit']!] = b['points']!; }

    Future<bool> send(String s, Map<String, String> m) async {
      final res = await _bidService.placeFinalBids(gameName: widget.title, accessToken: _accessToken, registerId: _registerId, deviceId: 'id', deviceName: 'Single', accountStatus: _accountStatus, bidAmounts: m, selectedGameType: s, gameId: widget.gameId, gameType: widget.gameCategoryType, totalBidAmount: m.values.fold(0, (prev, e) => prev + int.parse(e)));
      return res['status'] == true;
    }

    bool ok = true;
    if (openBids.isNotEmpty) ok = await send('OPEN', openBids);
    if (ok && closeBids.isNotEmpty) ok = await send('CLOSE', closeBids);

    if (!mounted) return;
    setState(() => _isApiCalling = false);

    if (ok) {
      final newBal = _walletBalance - total;
      userController.walletBalance.value = newBal.toString();
      setState(() { _walletBalance = newBal; _bids.clear(); for (var c in _digitCtrls.values) c.clear(); });
      showDialog(context: context, builder: (_) => const BidSuccessDialog());
    } else {
      showDialog(context: context, builder: (_) => const BidFailureDialog(errorMessage: 'Failed.'));
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Expanded(child: _buildModeBtn('Easy Mode')),
                  Expanded(child: _buildModeBtn('Special Mode')),
                ]),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  _selectedMode == 'Easy Mode' ? _buildEasyContent() : _buildSpecialContent(),
                  if (_message != null)
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: AnimatedMessageBar(key: _messageBarKey, message: _message!, isError: _isError, onDismissed: () => setState(() => _message = null)),
                    ),
                ],
              ),
            ),
            Container(decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]), child: _buildBottomBar()),
          ],
        ),
      ),
    );
  }

  Widget _buildModeBtn(String m) => GestureDetector(
    onTap: () => setState(() { _selectedMode = m; _bids.clear(); }),
    child: Container(height: 44, decoration: BoxDecoration(color: _selectedMode == m ? const Color(0xFF0F4C81) : Colors.transparent, borderRadius: BorderRadius.circular(8)), alignment: Alignment.center, child: Text(m, style: GoogleFonts.poppins(color: _selectedMode == m ? Colors.white : Colors.grey, fontWeight: FontWeight.w600, fontSize: 14))),
  );

  Widget _buildEasyContent() => Column(
    children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: _buildSessionToggle()),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: (_digits.length / 2).ceil(),
          itemBuilder: (ctx, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Expanded(child: _easyDigitBox(_digits[i * 2])),
              const SizedBox(width: 12),
              Expanded(child: i * 2 + 1 < _digits.length ? _easyDigitBox(_digits[i * 2 + 1]) : const SizedBox()),
            ]),
          ),
        ),
      ),
    ],
  );

  Widget _easyDigitBox(String d) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))]),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(d, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF3882F6))))),
      const SizedBox(width: 10),
      Expanded(child: TextField(controller: _digitCtrls[d], keyboardType: TextInputType.number, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF0F4C81), fontWeight: FontWeight.w500), decoration: InputDecoration(border: InputBorder.none, hintText: "Points", hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey), isDense: true, contentPadding: EdgeInsets.zero))),
    ]),
  );

  Widget _buildSpecialContent() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Select Session'),
            const SizedBox(height: 8),
            _buildSessionToggle(),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Digit'), const SizedBox(height: 8), _buildInput(_spDigitCtrl, "0-9", maxLen: 1)])),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Points'), const SizedBox(height: 8), _buildInput(_spPointsCtrl, "Min 10")])),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(onPressed: _addSpecialBid, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: Text('ADD BID', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15))),
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
  );

  Widget _label(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81)));

  Widget _buildSessionToggle() {
    if (!widget.selectionStatus) return _sessionChip('CLOSE', true);
    return Row(children: [
      Expanded(child: _sessionChip('OPEN', _selectedSession == 'OPEN')),
      const SizedBox(width: 12),
      Expanded(child: _sessionChip('CLOSE', _selectedSession == 'CLOSE')),
    ]);
  }

  Widget _sessionChip(String type, bool sel) => GestureDetector(
    onTap: () => setState(() => _selectedSession = type),
    child: Container(height: 48, decoration: BoxDecoration(color: sel ? const Color(0xFF0F4C81) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? const Color(0xFF0F4C81) : const Color(0xFFDDDDDD))), alignment: Alignment.center, child: Text(type, style: GoogleFonts.poppins(color: sel ? Colors.white : Colors.grey, fontWeight: FontWeight.w600))),
  );

  Widget _buildInput(TextEditingController ctrl, String hint, {int? maxLen}) => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: ctrl, keyboardType: TextInputType.number, inputFormatters: maxLen != null ? [LengthLimitingTextInputFormatter(maxLen)] : [], style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _buildBidCard(Map<String, String> bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(bid['digit']!, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6))))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['points']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text(bid['type']!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22), onPressed: () => setState(() => _bids.removeAt(i))),
    ]),
  );

  Widget _buildBottomBar() {
    final t = _getTotalPoints();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(children: [
        Expanded(child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Bids', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${_selectedMode == 'Easy Mode' ? _digitCtrls.values.where((c) => c.text.isNotEmpty).length : _bids.length}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('$t', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isApiCalling ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
