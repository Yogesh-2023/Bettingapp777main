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

import '../../../../components/AnimatedMessageBar.dart';
import '../../../../components/BidConfirmationDialog.dart';
import '../../../../components/BidFailureDialog.dart';
import '../../../../components/BidSuccessDialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../ulits/Constents.dart';
import '../../Helper/UserController.dart';

class PanelGroupScreen extends StatefulWidget {
  final String title;
  final String gameCategoryType;
  final int gameId;
  final String gameName;

  const PanelGroupScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameName,
    required this.gameCategoryType,
  });

  @override
  State<PanelGroupScreen> createState() => _PanelGroupScreenState();
}

class _PanelGroupScreenState extends State<PanelGroupScreen> {
  final TextEditingController panaInputController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();

  final GetStorage _storage = GetStorage();
  final UserController userController = Get.find<UserController>();

  late String accessToken;
  late String registerId;
  late bool accountStatus;
  late int walletBalance;

  String? _message;
  bool _isError = false;
  Key _msgKey = UniqueKey();
  bool _isApiCalling = false;

  final List<Map<String, String>> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  void _loadInitial() {
    accessToken = _storage.read('accessToken') ?? '';
    registerId = _storage.read('registerId') ?? '';
    accountStatus = userController.accountStatus.value;
    walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
  }

  @override
  void dispose() {
    panaInputController.dispose();
    pointsController.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _message = msg;
      _isError = isError;
      _msgKey = UniqueKey();
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }

  int _totalPoints() => _entries.fold(0, (s, e) => s + (int.tryParse(e['amount'] ?? '0') ?? 0));

  Future<void> _onAddBid() async {
    final raw = panaInputController.text.trim();
    final ptsStr = pointsController.text.trim();
    if (raw.isEmpty) { _showMessage('Enter pana number.', isError: true); return; }
    
    final pts = int.tryParse(ptsStr);
    if (pts == null || pts < 10) { _showMessage('Min points 10.', isError: true); return; }

    setState(() => _isApiCalling = true);
    try {
      final seeds = raw.split(RegExp(r'[,\s]+')).where((s) => s.isNotEmpty).toList();
      final List<String> allPanas = [];
      for (final seed in seeds) {
        final expanded = await _expandPanelGroup(seed);
        allPanas.addAll(expanded);
      }

      if (allPanas.isEmpty) {
        _showMessage('No valid panas found.', isError: true);
      } else {
        setState(() {
          for (final d in allPanas) {
            final i = _entries.indexWhere((e) => e['digit'] == d);
            if (i != -1) {
              final curr = int.tryParse(_entries[i]['amount'] ?? '0') ?? 0;
              _entries[i]['amount'] = (curr + pts).toString();
            } else {
              _entries.add({'digit': d, 'amount': pts.toString(), 'type': 'OPEN'});
            }
          }
          panaInputController.clear();
          pointsController.clear();
        });
        _showMessage('Added ${allPanas.length} bids.');
      }
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isApiCalling = false);
    }
  }

  Future<List<String>> _expandPanelGroup(String digit) async {
    final resp = await http.post(
      Uri.parse('${Constant.apiEndpoint}panel-group-pana'),
      headers: {
        'deviceId': 'device_id',
        'deviceName': 'device_name',
        'accessStatus': accountStatus ? '1' : '0',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'digit': digit, 'sessionType': 'open', 'amount': 0}),
    );

    final map = jsonDecode(resp.body);
    if (resp.statusCode == 200 && map['status'] == true) {
      final List info = map['info'] ?? [];
      return info.map((e) => e['pana']?.toString()).whereType<String>().toList();
    }
    throw Exception(map['msg'] ?? 'Failed to expand.');
  }

  void _confirm() {
    if (_entries.isEmpty) { _showMessage('Add some bids first.', isError: true); return; }
    final total = _totalPoints();
    if (walletBalance < total) { _showMessage('Insufficient balance.', isError: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: _entries.map((e) => {"digit": e['digit']!, "points": e['amount']!, "type": e['type']!, "pana": e['digit']!}).toList(),
        totalBids: _entries.length,
        totalBidsAmount: total,
        walletBalanceBeforeDeduction: walletBalance,
        walletBalanceAfterDeduction: (walletBalance - total).toString(),
        gameId: widget.gameId.toString(),
        gameType: widget.gameCategoryType,
        onConfirm: () => _submitAll(),
      ),
    );
  }

  Future<void> _submitAll() async {
    setState(() => _isApiCalling = true);
    try {
      final total = _totalPoints();
      final bidRows = _entries.map((e) => {"sessionType": "OPEN", "digit": e['digit'], "pana": e['digit'], "bidAmount": int.parse(e['amount']!)}).toList();
      
      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}place-bid'),
        headers: {
          'deviceId': 'device_id',
          'deviceName': 'device_name',
          'accessStatus': accountStatus ? '1' : '0',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({"registerId": registerId, "gameId": widget.gameId, "bidAmount": total, "gameType": widget.gameCategoryType, "bid": bidRows}),
      );

      final map = jsonDecode(resp.body);
      if (resp.statusCode == 200 && (map['status'] == true || map['status'] == 'true')) {
        final newBal = walletBalance - total;
        userController.walletBalance.value = newBal.toString();
        setState(() {
          walletBalance = newBal;
          _entries.clear();
        });
        showDialog(context: context, builder: (_) => const BidSuccessDialog());
      } else {
        showDialog(context: context, builder: (_) => BidFailureDialog(errorMessage: map['msg'] ?? 'Failed.'));
      }
    } catch (e) {
      _showMessage('Submit error.', isError: true);
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
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Pana Number'), const SizedBox(height: 8), _buildInput(panaInputController, 'e.g. 123, 445')])),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Enter Points'), const SizedBox(height: 8), _buildInput(pointsController, 'Points')])),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _isApiCalling ? null : _onAddBid,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('ADD BID', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
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
                      child: AnimatedMessageBar(key: _msgKey, message: _message!, isError: _isError, onDismissed: () => setState(() => _message = null)),
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
    child: Center(child: TextField(controller: controller, keyboardType: hint.contains('e.g.') ? TextInputType.text : TextInputType.number, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _buildBidCard(Map<String, String> bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(bid['digit']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['amount']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text('Panel Group', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
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
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${_totalPoints()}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isApiCalling || _entries.isEmpty ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
