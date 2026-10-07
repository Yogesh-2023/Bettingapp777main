import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../../BidService.dart';
import '../../Helper/UserController.dart';
import '../../components/AnimatedMessageBar.dart';
import '../../components/BidConfirmationDialog.dart';
import '../../components/BidFailureDialog.dart';
import '../../components/BidSuccessDialog.dart';

enum GameType { odd, even }

class OddEvenBoardScreen extends StatefulWidget {
  final String title;
  final int gameId;
  final String gameType;
  final String gameName;
  final bool selectionStatus;

  const OddEvenBoardScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameType,
    this.gameName = "",
    required this.selectionStatus,
  });

  @override
  State<OddEvenBoardScreen> createState() => _OddEvenBoardScreenState();
}

class _OddEvenBoardScreenState extends State<OddEvenBoardScreen> {
  String _selectedSession = 'OPEN';
  GameType _gameGroup = GameType.odd;
  final TextEditingController _pointsCtrl = TextEditingController();
  final List<Map<String, String>> _entries = [];

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

  static const List<String> _odd = ['1', '3', '5', '7', '9'];
  static const List<String> _even = ['0', '2', '4', '6', '8'];

  @override
  void initState() {
    super.initState();
    _bidService = BidService(_storage);
    _loadInitial();
    if (!widget.selectionStatus) _selectedSession = 'CLOSE';
  }

  void _loadInitial() {
    _accessToken = _storage.read('accessToken') ?? '';
    _registerId = _storage.read('registerId') ?? '';
    _accountStatus = userController.accountStatus.value;
    _walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
  }

  @override
  void dispose() {
    _pointsCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    setState(() { _message = msg; _isError = isError; _messageBarKey = UniqueKey(); });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _message = null); });
  }

  void _addBids() {
    final ptsTxt = _pointsCtrl.text.trim();
    final pts = int.tryParse(ptsTxt);
    if (pts == null || pts < 10) { _showMessage('Min points 10.', isError: true); return; }

    final digits = _gameGroup == GameType.odd ? _odd : _even;
    final totalNeeded = pts * digits.length;
    if (_getTotalPoints() + totalNeeded > _walletBalance) { _showMessage('Insufficient balance.', isError: true); return; }

    setState(() {
      for (var d in digits) {
        final idx = _entries.indexWhere((e) => e['digit'] == d && e['type'] == _selectedSession);
        if (idx != -1) {
          int cur = int.parse(_entries[idx]['points']!);
          _entries[idx]['points'] = (cur + pts).toString();
        } else {
          _entries.add({'digit': d, 'points': pts.toString(), 'type': _selectedSession});
        }
      }
      _pointsCtrl.clear();
    });
    _showMessage('Added ${_gameGroup.name.toUpperCase()} bids.');
  }

  int _getTotalPoints() => _entries.fold(0, (s, e) => s + int.parse(e['points']!));

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
        bids: _entries.map((e) => {"digit": e['digit']!, "points": e['points']!, "type": "${_gameGroup.name.toUpperCase()} (${e['type']})", "pana": e['digit']!}).toList(),
        totalBids: _entries.length,
        totalBidsAmount: total,
        walletBalanceBeforeDeduction: _walletBalance,
        walletBalanceAfterDeduction: (_walletBalance - total).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameType,
        onConfirm: () => _submitAll(total),
      ),
    );
  }

  Future<void> _submitAll(int total) async {
    setState(() => _isApiCalling = true);
    
    Future<bool> send(String session) async {
      final list = _entries.where((e) => e['type'] == session).toList();
      if (list.isEmpty) return true;
      Map<String, String> payload = {};
      for (var e in list) payload[e['digit']!] = e['points']!;
      final res = await _bidService.placeFinalBids(
        gameName: widget.gameName, accessToken: _accessToken, registerId: _registerId,
        deviceId: 'device_id', deviceName: 'device_name', accountStatus: _accountStatus,
        bidAmounts: payload, selectedGameType: session,
        gameId: widget.gameId, gameType: widget.gameType, totalBidAmount: list.fold(0, (s, e) => s + int.parse(e['points']!)),
      );
      return res['status'] == true;
    }

    bool ok = await send('OPEN');
    if (ok) ok = await send('CLOSE');

    if (!mounted) return;
    setState(() => _isApiCalling = false);

    if (ok) {
      final newBal = _walletBalance - total;
      userController.walletBalance.value = newBal.toString();
      setState(() { _walletBalance = newBal; _entries.clear(); });
      showDialog(context: context, builder: (_) => const BidSuccessDialog());
    } else {
      showDialog(context: context, builder: (_) => const BidFailureDialog(errorMessage: 'Submission failed.'));
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
                            _label('Select Session'),
                            const SizedBox(height: 12),
                            _buildSessionToggle(),
                            const SizedBox(height: 24),
                            _label('Select Group'),
                            const SizedBox(height: 12),
                            _buildGroupSelection(),
                            const SizedBox(height: 24),
                            _label('Enter Points'),
                            const SizedBox(height: 8),
                            _buildInput(_pointsCtrl, 'Points'),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _isApiCalling ? null : _addBids,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: Text('ADD ODD / EVEN', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
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

  Widget _label(String text) => Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81)));

  Widget _buildSessionToggle() {
    if (!widget.selectionStatus) return _sessBtn('CLOSE', true);
    return Row(
      children: [
        Expanded(child: _sessBtn('OPEN', _selectedSession == 'OPEN')),
        const SizedBox(width: 12),
        Expanded(child: _sessBtn('CLOSE', _selectedSession == 'CLOSE')),
      ],
    );
  }

  Widget _sessBtn(String t, bool sel) => GestureDetector(
    onTap: () => setState(() => _selectedSession = t),
    child: Container(
      height: 48, alignment: Alignment.center,
      decoration: BoxDecoration(color: sel ? const Color(0xFF0F4C81) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? const Color(0xFF0F4C81) : const Color(0xFFDDDDDD))),
      child: Text(t, style: GoogleFonts.poppins(color: sel ? Colors.white : Colors.grey, fontWeight: FontWeight.w600)),
    ),
  );

  Widget _buildGroupSelection() {
    return Row(
      children: [
        Expanded(child: _groupBtn(GameType.odd, 'ODD (1,3,5,7,9)')),
        const SizedBox(width: 12),
        Expanded(child: _groupBtn(GameType.even, 'EVEN (0,2,4,6,8)')),
      ],
    );
  }

  Widget _groupBtn(GameType type, String label) {
    bool sel = _gameGroup == type;
    return GestureDetector(
      onTap: () => setState(() => _gameGroup = type),
      child: Container(
        height: 52, alignment: Alignment.center,
        decoration: BoxDecoration(color: sel ? const Color(0xFF3882F6).withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? const Color(0xFF3882F6) : const Color(0xFFDDDDDD))),
        child: Text(label, style: GoogleFonts.poppins(color: sel ? const Color(0xFF3882F6) : Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint) => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: controller, keyboardType: TextInputType.number, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _buildBidCard(Map<String, String> bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF0F4C81).withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(bid['digit']!, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F4C81))))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['points']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text('Type: ${bid['type']}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22), onPressed: () => setState(() => _entries.removeAt(i))),
    ]),
  );

  Widget _buildBottomBar() {
    final total = _getTotalPoints();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(children: [
        Expanded(child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Bids', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${_entries.length}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('$total', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isApiCalling || _entries.isEmpty ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
