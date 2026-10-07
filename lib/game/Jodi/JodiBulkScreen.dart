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

class JodiBulkScreen extends StatefulWidget {
  final String screenTitle;
  final String gameType;
  final int gameId;
  final String gameName;

  const JodiBulkScreen({
    super.key,
    required this.screenTitle,
    required this.gameType,
    required this.gameId,
    required this.gameName,
  });

  @override
  State<JodiBulkScreen> createState() => _JodiBulkScreenState();
}

class _JodiBulkScreenState extends State<JodiBulkScreen> {
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _jodiDigitController = TextEditingController();
  final GetStorage storage = GetStorage();
  late final BidService _bidService;

  List<Map<String, String>> _bids = [];
  late String _accessToken;
  late String _registerId;
  late bool _accountStatus;
  int _walletBalance = 0;
  bool _isApiCalling = false;

  String? _msg;
  bool _msgErr = false;
  Key _msgKey = UniqueKey();

  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _bidService = BidService(storage);
    _loadInitial();
  }

  void _loadInitial() {
    _accessToken = storage.read('accessToken') ?? '';
    _registerId = storage.read('registerId') ?? '';
    _accountStatus = userController.accountStatus.value;
    _walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _jodiDigitController.dispose();
    super.dispose();
  }

  void _showMsg(String m, {bool err = false}) {
    if (!mounted) return;
    setState(() { _msg = m; _msgErr = err; _msgKey = UniqueKey(); });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _msg = null); });
  }

  void _addBulk() {
    final d = _jodiDigitController.text.trim();
    final p = _pointsController.text.trim();
    if (d.length != 2) return; // Wait for 2 digits to auto-add
    final pts = int.tryParse(p);
    if (pts == null || pts < 10) { _showMsg('Min points 10.', err: true); return; }

    setState(() {
      final idx = _bids.indexWhere((e) => e['digit'] == d);
      if (idx != -1) {
        _bids[idx]['points'] = p;
      } else {
        _bids.add({"digit": d, "points": p, "gameType": widget.gameType, "type": "Jodi"});
      }
      _jodiDigitController.clear();
    });
    _showMsg('Jodi $d updated.');
  }

  int _total() => _bids.fold(0, (s, e) => s + (int.tryParse(e['points']!) ?? 0));

  void _confirm() {
    if (_bids.isEmpty) { _showMsg('Add some bids first.', err: true); return; }
    final total = _total();
    if (total > _walletBalance) { _showMsg('Insufficient balance.', err: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.gameName,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: _bids.map((b) => {"digit": b['digit']!, "points": b['points']!, "type": "Bulk Jodi", "pana": ""}).toList(),
        totalBids: _bids.length,
        totalBidsAmount: total,
        walletBalanceBeforeDeduction: _walletBalance,
        walletBalanceAfterDeduction: (_walletBalance - total).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameType,
        onConfirm: () => _submit(total),
      ),
    );
  }

  Future<void> _submit(int total) async {
    setState(() => _isApiCalling = true);
    try {
      final result = await _bidService.placeFinalBids(
        gameName: widget.gameName, accessToken: _accessToken, registerId: _registerId,
        deviceId: 'device_id', deviceName: 'Bulk Jodi', accountStatus: _accountStatus,
        bidAmounts: {for (var b in _bids) b['digit']!: b['points']!}, selectedGameType: "OPEN",
        gameId: widget.gameId, gameType: widget.gameType, totalBidAmount: total,
      );

      if (!mounted) return;
      setState(() => _isApiCalling = false);

      if (result['status'] == true) {
        final newBal = _walletBalance - total;
        userController.walletBalance.value = newBal.toString();
        setState(() { _walletBalance = newBal; _bids.clear(); _pointsController.clear(); _jodiDigitController.clear(); });
        showDialog(context: context, builder: (_) => const BidSuccessDialog());
      } else {
        showDialog(context: context, builder: (_) => BidFailureDialog(errorMessage: result['msg'] ?? 'Failed.'));
      }
    } catch (e) {
      _showMsg('Network error.', err: true);
      setState(() => _isApiCalling = false);
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
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Enter Points'), const SizedBox(height: 8), _buildInput(_pointsController, 'Points')])),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Jodi Digit (00-99)'), const SizedBox(height: 8), _buildInput(_jodiDigitController, 'Jodi', max: 2, onChanged: (v) { if (v.length == 2 && _pointsController.text.isNotEmpty) _addBulk(); })])),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Note: Bid will be added automatically when you enter 2nd digit.', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Expanded(
                        child: _bids.isEmpty
                            ? Center(child: Text('Enter points and digit to add', style: GoogleFonts.poppins(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                itemCount: _bids.length,
                                itemBuilder: (_, i) => _buildBidCard(_bids[i], i),
                              ),
                      ),
                    ],
                  ),
                  if (_msg != null)
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: AnimatedMessageBar(key: _msgKey, message: _msg!, isError: _msgErr, onDismissed: () => setState(() => _msg = null)),
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

  Widget _buildInput(TextEditingController controller, String hint, {int? max, Function(String)? onChanged}) => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: controller, keyboardType: TextInputType.number, maxLength: max, onChanged: onChanged, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(counterText: "", hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _buildBidCard(Map<String, String> bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(bid['digit']!, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6))))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['points']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text('BULK JODI', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${_total()}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isApiCalling || _bids.isEmpty ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
