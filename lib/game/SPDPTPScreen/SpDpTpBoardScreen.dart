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

import '../../Helper/UserController.dart';
import '../../components/AnimatedMessageBar.dart';
import '../../components/BidConfirmationDialog.dart';
import '../../components/BidFailureDialog.dart';
import '../../components/BidSuccessDialog.dart';
import '../../l10n/app_localizations.dart';
import '../../ulits/Constents.dart';

class SpDpTpBoardScreen extends StatefulWidget {
  final String screenTitle;
  final int gameId;
  final String gameType;
  final bool openSessionStatus;

  const SpDpTpBoardScreen({
    super.key,
    required this.screenTitle,
    required this.gameId,
    required this.gameType,
    required this.openSessionStatus,
  });

  @override
  State<SpDpTpBoardScreen> createState() => _SpDpTpBoardScreenState();
}

class _SpDpTpBoardScreenState extends State<SpDpTpBoardScreen> {
  final TextEditingController _pCtrl = TextEditingController();
  final TextEditingController _dCtrl = TextEditingController();

  bool _isSP = true;
  bool _isDP = false;
  bool _isTP = false;
  String? _session;

  final List<Map<String, String>> _bids = [];
  final GetStorage storage = GetStorage();
  final UserController userController = Get.find<UserController>();

  late String accessToken;
  late String registerId;
  late bool accountStatus;
  int walletBalance = 0;
  bool _isApiCalling = false;

  String? _msg;
  bool _msgErr = false;
  Key _msgKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  void _loadInitial() {
    accessToken = storage.read('accessToken') ?? '';
    registerId = storage.read('registerId') ?? '';
    accountStatus = userController.accountStatus.value;
    walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
    _session = widget.openSessionStatus ? 'OPEN' : 'CLOSE';
  }

  @override
  void dispose() {
    _pCtrl.dispose(); _dCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String m, {bool err = false}) {
    if (!mounted) return;
    setState(() { _msg = m; _msgErr = err; _msgKey = UniqueKey(); });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _msg = null); });
  }

  int _totalPoints() => _bids.fold(0, (s, e) => s + (int.tryParse(e['amount'] ?? '0') ?? 0));

  Future<void> _onAdd() async {
    final d = _dCtrl.text.trim();
    final p = _pCtrl.text.trim();
    if (d.isEmpty) { _showMsg('Enter digit.', err: true); return; }
    final pts = int.tryParse(p);
    if (pts == null || pts < 10) { _showMsg('Min points 10.', err: true); return; }

    setState(() => _isApiCalling = true);
    try {
      final cat = _isSP ? 'SP' : (_isDP ? 'DP' : 'TP');
      final endpoint = cat == 'SP' ? 'single-pana-bulk' : (cat == 'DP' ? 'double-pana-bulk' : 'triple-pana-bulk');
      
      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'deviceId': 'device_id',
          'deviceName': 'SpDpTp',
          'accessStatus': accountStatus ? '1' : '0',
        },
        body: jsonEncode({"game_id": widget.gameId.toString(), "register_id": registerId, "session_type": _session!.toLowerCase(), "digit": int.parse(d), "amount": pts}),
      );

      final map = jsonDecode(resp.body);
      if (resp.statusCode == 200 && map['status'] == true) {
        final List info = map['info'] ?? [];
        setState(() {
          for (var item in info) {
            final panna = item['pana'].toString();
            final idx = _bids.indexWhere((e) => e['digit'] == panna && e['gameType'] == cat && e['session'] == _session);
            if (idx != -1) {
              _bids[idx]['amount'] = (int.parse(_bids[idx]['amount']!) + pts).toString();
            } else {
              _bids.add({'digit': panna, 'amount': pts.toString(), 'gameType': cat, 'session': _session!});
            }
          }
          _dCtrl.clear(); _pCtrl.clear();
        });
        _showMsg('Added ${info.length} bids.');
      } else {
        _showMsg(map['msg'] ?? 'Failed.', err: true);
      }
    } catch (e) {
      _showMsg('Network error.', err: true);
    } finally {
      if (mounted) setState(() => _isApiCalling = false);
    }
  }

  void _confirm() {
    if (_bids.isEmpty) { _showMsg('Add some bids first.', err: true); return; }
    final total = _totalPoints();
    if (walletBalance < total) { _showMsg('Insufficient balance.', err: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.screenTitle,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: _bids.map((b) => {'digit': b['digit']!, 'points': b['amount']!, 'type': '${b['gameType']} (${b['session']})', 'pana': b['digit']!}).toList(),
        totalBids: _bids.length,
        totalBidsAmount: total,
        walletBalanceBeforeDeduction: walletBalance,
        walletBalanceAfterDeduction: (walletBalance - total).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameType,
        onConfirm: () => _submitAll(total),
      ),
    );
  }

  Future<void> _submitAll(int totalPoints) async {
    setState(() => _isApiCalling = true);
    try {
      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}place-bid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'deviceId': 'device_id',
          'deviceName': 'SpDpTp',
          'accessStatus': accountStatus ? '1' : '0',
        },
        body: jsonEncode({
          "registerId": registerId,
          "gameId": widget.gameId.toString(),
          "bidAmount": totalPoints,
          "gameType": widget.gameType,
          "bid": _bids.map((b) => {"sessionType": b['session'], "digit": b['digit'], "pana": b['digit'], "bidAmount": int.parse(b['amount']!)}).toList(),
        }),
      );

      final map = jsonDecode(resp.body);
      if (resp.statusCode == 200 && (map['status'] == true || map['status'] == 'true')) {
        final newBal = walletBalance - totalPoints;
        userController.walletBalance.value = newBal.toString();
        setState(() { walletBalance = newBal; _bids.clear(); });
        showDialog(context: context, builder: (_) => const BidSuccessDialog());
      } else {
        showDialog(context: context, builder: (_) => BidFailureDialog(errorMessage: map['msg'] ?? 'Failed.'));
      }
    } catch (e) {
      _showMsg('Submit error.', err: true);
    } finally {
      if (mounted) setState(() => _isApiCalling = false);
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _catCheck('SP', _isSP, (v) => setState(() { _isSP = v; _isDP = false; _isTP = false; })),
                                _catCheck('DP', _isDP, (v) => setState(() { _isDP = v; _isSP = false; _isTP = false; })),
                                _catCheck('TP', _isTP, (v) => setState(() { _isTP = v; _isSP = false; _isDP = false; })),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Digit (0-9)'), const SizedBox(height: 8), _buildInput(_dCtrl, 'Digit', max: 1)])),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Points'), const SizedBox(height: 8), _buildInput(_pCtrl, 'Points')])),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _label('Select Session'),
                            const SizedBox(height: 8),
                            _buildSessionDrop(),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _isApiCalling ? null : _onAdd,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('ADD BID', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
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

  Widget _buildInput(TextEditingController controller, String hint, {int? max}) => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: controller, keyboardType: TextInputType.number, inputFormatters: max != null ? [LengthLimitingTextInputFormatter(max)] : [], style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _catCheck(String label, bool val, Function(bool) onChanged) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Checkbox(value: val, activeColor: const Color(0xFF3882F6), onChanged: (v) => onChanged(v ?? false)),
      Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))),
    ],
  );

  Widget _buildSessionDrop() => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: _session, isExpanded: true,
      onChanged: (v) => setState(() => _session = v),
      items: (widget.openSessionStatus ? ['OPEN', 'CLOSE'] : ['CLOSE']).map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)))).toList(),
    )),
  );

  Widget _buildBidCard(Map<String, String> bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(bid['digit']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['amount']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text('${bid['gameType']} (${bid['session']})', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${_totalPoints()}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isApiCalling || _bids.isEmpty ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}