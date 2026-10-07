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

class FullSangamBoardScreen extends StatefulWidget {
  final String screenTitle;
  final int gameId;
  final String gameType;
  final String gameName;

  const FullSangamBoardScreen({
    super.key,
    required this.screenTitle,
    required this.gameType,
    required this.gameId,
    required this.gameName,
  });

  @override
  State<FullSangamBoardScreen> createState() => _FullSangamBoardScreenState();
}

class _FullSangamBoardScreenState extends State<FullSangamBoardScreen> {
  final TextEditingController _openPannaCtrl = TextEditingController();
  final TextEditingController _closePannaCtrl = TextEditingController();
  final TextEditingController _pointsCtrl = TextEditingController();

  final List<Map<String, String>> _bids = [];
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
  }

  void _loadInitial() {
    _accessToken = _storage.read('accessToken') ?? '';
    _registerId = _storage.read('registerId') ?? '';
    _accountStatus = userController.accountStatus.value;
    _walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
  }

  @override
  void dispose() {
    _openPannaCtrl.dispose();
    _closePannaCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    setState(() { _message = msg; _isError = isError; _messageBarKey = UniqueKey(); });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _message = null); });
  }

  void _addBid() {
    final open = _openPannaCtrl.text.trim();
    final close = _closePannaCtrl.text.trim();
    final ptsTxt = _pointsCtrl.text.trim();

    if (open.length != 3) { _showMessage('Enter 3-digit Open Panna.', isError: true); return; }
    if (close.length != 3) { _showMessage('Enter 3-digit Close Panna.', isError: true); return; }
    final pts = int.tryParse(ptsTxt);
    if (pts == null || pts < 10) { _showMessage('Min points 10.', isError: true); return; }

    if (_getTotalPoints() + pts > _walletBalance) { _showMessage('Insufficient balance.', isError: true); return; }

    final sangam = '$open-$close';
    setState(() {
      final idx = _bids.indexWhere((b) => b['sangam'] == sangam);
      if (idx != -1) {
        _bids[idx]['points'] = (int.parse(_bids[idx]['points']!) + pts).toString();
      } else {
        _bids.add({"sangam": sangam, "points": pts.toString(), "openPanna": open, "closePanna": close});
      }
      _openPannaCtrl.clear(); _closePannaCtrl.clear(); _pointsCtrl.clear();
    });
    _showMessage('Added Sangam $sangam.');
  }

  int _getTotalPoints() => _bids.fold(0, (s, b) => s + int.parse(b['points']!));

  void _confirm() {
    if (_bids.isEmpty) { _showMessage('Add some bids first.', isError: true); return; }
    final total = _getTotalPoints();
    if (total > _walletBalance) { _showMessage('Insufficient balance.', isError: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.screenTitle,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: _bids.map((b) => {"digit": b['closePanna']!, "points": b['points']!, "type": "FULL SANGAM", "pana": b['openPanna']!, "sangam": b['sangam']!}).toList(),
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

  Future<void> _submitAll(int total) async {
    setState(() => _isApiCalling = true);
    Map<String, String> payload = {};
    for (var b in _bids) payload[b['sangam']!] = b['points']!;

    final result = await _bidService.placeFinalBids(
      gameName: widget.gameName, accessToken: _accessToken, registerId: _registerId,
      deviceId: 'device_id', deviceName: 'Sangam', accountStatus: _accountStatus,
      bidAmounts: payload, selectedGameType: widget.gameType,
      gameId: widget.gameId, gameType: widget.gameType, totalBidAmount: total,
    );

    if (!mounted) return;
    setState(() => _isApiCalling = false);

    if (result['status'] == true) {
      final newBal = _walletBalance - total;
      userController.walletBalance.value = newBal.toString();
      setState(() { _walletBalance = newBal; _bids.clear(); });
      showDialog(context: context, builder: (_) => const BidSuccessDialog());
    } else {
      showDialog(context: context, builder: (_) => BidFailureDialog(errorMessage: result['msg'] ?? 'Failed.'));
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
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Open Panna'), const SizedBox(height: 8), _buildInput(_openPannaCtrl, 'e.g. 123', max: 3)])),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Close Panna'), const SizedBox(height: 8), _buildInput(_closePannaCtrl, 'e.g. 456', max: 3)])),
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
                                onPressed: _isApiCalling ? null : _addBid,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('ADD SANGAM', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
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

  Widget _buildInput(TextEditingController controller, String hint, {int? max}) => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: controller, keyboardType: TextInputType.number, inputFormatters: max != null ? [LengthLimitingTextInputFormatter(max)] : [], style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _buildBidCard(Map<String, String> bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(bid['sangam']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['points']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text('FULL SANGAM', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
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
        ElevatedButton(onPressed: _isApiCalling || _bids.isEmpty ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
