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

class GroupJodiScreen extends StatefulWidget {
  final String title;
  final int gameId;
  final String gameType;

  const GroupJodiScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameType,
  });

  @override
  State<GroupJodiScreen> createState() => _GroupJodiScreenState();
}

class _GroupJodiScreenState extends State<GroupJodiScreen> {
  final TextEditingController jodiController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();

  final List<Map<String, String>> _bids = [];
  final GetStorage _storage = GetStorage();
  final UserController userController = Get.find<UserController>();

  late String _accessToken;
  late String _registerId;
  late bool _accountActiveStatus;
  int _walletBalance = 0;
  bool _isApiCalling = false;

  String? _msg;
  bool _msgIsError = false;
  Key _msgKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _accessToken = _storage.read('accessToken') ?? '';
    _registerId = _storage.read('registerId') ?? '';
    _accountActiveStatus = userController.accountStatus.value;
    _walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
  }

  @override
  void dispose() {
    jodiController.dispose();
    pointsController.dispose();
    super.dispose();
  }

  void _showMsg(String m, {bool error = false}) {
    if (!mounted) return;
    setState(() { _msg = m; _msgIsError = error; _msgKey = UniqueKey(); });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _msg = null); });
  }

  String _cutDigit(String d) {
    int v = int.parse(d);
    return ((v + 5) % 10).toString();
  }

  void _addBid() {
    final j = jodiController.text.trim();
    final p = pointsController.text.trim();
    if (j.length != 2) { _showMsg('Enter 2-digit Jodi.', error: true); return; }
    final pts = int.tryParse(p);
    if (pts == null || pts < 10) { _showMsg('Min points 10.', error: true); return; }

    final d1 = j[0]; final d2 = j[1];
    final c1 = _cutDigit(d1); final c2 = _cutDigit(d2);

    final Set<String> jodis = {'$d1$d2', '$d1$c2', '$c1$d2', '$c1$c2', '$d2$d1', '$d2$c1', '$c2$d1', '$c2$c1'};
    int totalNeeded = jodis.length * pts;
    if (_total() + totalNeeded > _walletBalance) { _showMsg('Insufficient balance.', error: true); return; }

    setState(() {
      for (var g in jodis) {
        final i = _bids.indexWhere((e) => e['jodi'] == g);
        if (i != -1) {
          _bids[i]['points'] = (int.parse(_bids[i]['points']!) + pts).toString();
        } else {
          _bids.add({'jodi': g, 'points': pts.toString()});
        }
      }
      jodiController.clear(); pointsController.clear();
    });
    _showMsg('Added Group Jodi.');
  }

  int _total() => _bids.fold(0, (s, e) => s + int.parse(e['points']!));

  void _confirm() {
    if (_bids.isEmpty) { _showMsg('Add some bids first.', error: true); return; }
    final total = _total();
    if (total > _walletBalance) { _showMsg('Insufficient balance.', error: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: _bids.map((e) => {'digit': e['jodi']!, 'points': e['points']!, 'type': 'GROUP JODI', 'pana': e['jodi']!}).toList(),
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
      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}place-bid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
          'deviceId': 'device_id',
          'deviceName': 'GroupJodi',
          'accessStatus': _accountActiveStatus ? '1' : '0',
        },
        body: jsonEncode({
          'registerId': _registerId,
          'gameId': widget.gameId,
          'bidAmount': total,
          'gameType': widget.gameType,
          'bid': _bids.map((e) => {'sessionType': widget.gameType, 'digit': e['jodi'], 'pana': e['jodi'], 'bidAmount': int.parse(e['points']!)}).toList(),
        }),
      );

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && (data['status'] == true || data['status'] == 'true')) {
        final newBal = _walletBalance - total;
        userController.walletBalance.value = newBal.toString();
        setState(() { _walletBalance = newBal; _bids.clear(); });
        showDialog(context: context, builder: (_) => const BidSuccessDialog());
      } else {
        showDialog(context: context, builder: (_) => BidFailureDialog(errorMessage: data['msg'] ?? 'Failed.'));
      }
    } catch (e) {
      _showMsg('Network error.', error: true);
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
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Enter Jodi (00-99)'), const SizedBox(height: 8), _buildInput(jodiController, 'Jodi', max: 2)])),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Enter Points'), const SizedBox(height: 8), _buildInput(pointsController, 'Points')])),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _isApiCalling ? null : _addBid,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('ADD GROUP JODI', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
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
                      child: AnimatedMessageBar(key: _msgKey, message: _msg!, isError: _msgIsError, onDismissed: () => setState(() => _msg = null)),
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
      Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(bid['jodi']!, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6))))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['points']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text('GROUP JODI', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
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
