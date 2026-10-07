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

class TPMotorsBetScreen extends StatefulWidget {
  final String title;
  final String gameCategoryType;
  final int gameId;
  final String gameName;
  final bool selectionStatus;

  const TPMotorsBetScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameName,
    required this.gameCategoryType,
    required this.selectionStatus,
  });

  @override
  State<TPMotorsBetScreen> createState() => _TPMotorsBetScreenState();
}

class _TPMotorsBetScreenState extends State<TPMotorsBetScreen> {
  String _selectedSession = 'OPEN';
  final Map<String, TextEditingController> _controllers = {};
  final List<String> triplePanaOptions = const ["000", "111", "222", "333", "444", "555", "666", "777", "888", "999"];

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
    for (var pana in triplePanaOptions) { _controllers[pana] = TextEditingController(); }
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
    for (var c in _controllers.values) { c.dispose(); }
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    setState(() { _message = msg; _isError = isError; _messageBarKey = UniqueKey(); });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _message = null); });
  }

  List<Map<String, String>> _getBids() {
    List<Map<String, String>> bids = [];
    _controllers.forEach((pana, ctrl) {
      final text = ctrl.text.trim();
      if (text.isNotEmpty) { bids.add({'digit': pana, 'pana': pana, 'amount': text, 'type': _selectedSession}); }
    });
    return bids;
  }

  int _getTotalPoints() => _getBids().fold(0, (sum, b) => sum + (int.tryParse(b['amount']!) ?? 0));

  void _confirm() {
    final bids = _getBids();
    if (bids.isEmpty) { _showMessage('Enter points for at least one Triple Pana.', isError: true); return; }
    final total = _getTotalPoints();
    if (total > _walletBalance) { _showMessage('Insufficient balance.', isError: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: bids.map((b) => {"digit": b['digit']!, "points": b['amount']!, "type": "Triple Motor (${b['type']})", "pana": b['pana']!}).toList(),
        totalBids: bids.length,
        totalBidsAmount: total,
        walletBalanceBeforeDeduction: _walletBalance,
        walletBalanceAfterDeduction: (_walletBalance - total).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameCategoryType,
        onConfirm: () => _submitAll(total),
      ),
    );
  }

  Future<void> _submitAll(int total) async {
    setState(() => _isApiCalling = true);
    final bids = _getBids();
    Map<String, String> payload = {};
    for (var b in bids) payload[b['digit']!] = b['amount']!;

    final result = await _bidService.placeFinalBids(
      gameName: widget.title, accessToken: _accessToken, registerId: _registerId,
      deviceId: 'device_id', deviceName: 'device_name', accountStatus: _accountStatus,
      bidAmounts: payload, selectedGameType: _selectedSession,
      gameId: widget.gameId, gameType: widget.gameCategoryType, totalBidAmount: total,
    );

    if (!mounted) return;
    setState(() => _isApiCalling = false);

    if (result['status'] == true) {
      final newBal = _walletBalance - total;
      userController.walletBalance.value = newBal.toString();
      setState(() { _walletBalance = newBal; for (var c in _controllers.values) { c.clear(); } });
      showDialog(context: context, builder: (_) => const BidSuccessDialog());
    } else {
      showDialog(context: context, builder: (_) => BidFailureDialog(errorMessage: result['msg'] ?? 'Submission failed.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _getTotalPoints();
    final bidsCount = _getBids().length;

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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Select Session'),
                            const SizedBox(height: 12),
                            _buildSessionToggle(),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5),
                          itemCount: triplePanaOptions.length,
                          itemBuilder: (_, i) => _buildPannaInput(triplePanaOptions[i]),
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
              child: _buildBottomBar(bidsCount, total),
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

  Widget _buildPannaInput(String pana) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(
      children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(pana, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6))))),
        const SizedBox(width: 10),
        Expanded(child: TextField(controller: _controllers[pana], keyboardType: TextInputType.number, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600), onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'Points', hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
      ],
    ),
  );

  Widget _buildBottomBar(int bids, int points) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(children: [
        Expanded(child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Bids', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('$bids', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('$points', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isApiCalling || bids == 0 ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
