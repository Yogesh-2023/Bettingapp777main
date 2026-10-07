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

class SPMotorsBetScreen extends StatefulWidget {
  final String title;
  final String gameCategoryType;
  final int gameId;
  final String gameName;
  final bool selectionStatus;

  const SPMotorsBetScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameName,
    required this.gameCategoryType,
    required this.selectionStatus,
  });

  @override
  State<SPMotorsBetScreen> createState() => _SPMotorsBetScreenState();
}

class _SPMotorsBetScreenState extends State<SPMotorsBetScreen> {
  String _selectedSession = 'OPEN';
  final TextEditingController _bidController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  final Map<String, List<Map<String, String>>> _entriesBySession = {
    'OPEN': <Map<String, String>>[],
    'CLOSE': <Map<String, String>>[],
  };

  final GetStorage _storage = GetStorage();
  final UserController userController = Get.find<UserController>();

  late String _accessToken;
  late String _registerId;
  late bool _accountStatus;
  int _walletBalance = 0;
  bool _isApiCalling = false;

  String? _message;
  bool _isError = false;
  Key _messageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
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
    _bidController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    setState(() { _message = msg; _isError = isError; _messageKey = UniqueKey(); });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _message = null); });
  }

  Future<void> _addEntry() async {
    final digit = _bidController.text.trim();
    final pointsStr = _pointsController.text.trim();
    if (digit.length < 3 || digit.length > 7) { _showMessage('Enter 3-7 digits.', isError: true); return; }
    
    final int? points = int.tryParse(pointsStr);
    if (points == null || points < 10) { _showMessage('Min points 10.', isError: true); return; }

    setState(() => _isApiCalling = true);
    try {
      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}sp-motor-pana'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({"digit": digit, "sessionType": _selectedSession.toLowerCase(), "amount": points}),
      );

      final map = jsonDecode(resp.body);
      if (resp.statusCode == 200 && map['status'] == true) {
        final info = map['info'] as List;
        setState(() {
          for (var item in info) {
            String pana = item['pana'].toString();
            int amt = item['amount'] ?? points;
            final list = _entriesBySession[_selectedSession]!;
            final idx = list.indexWhere((e) => e['pana'] == pana);
            if (idx != -1) {
              int cur = int.tryParse(list[idx]['amount']!) ?? 0;
              list[idx]['amount'] = (cur + amt).toString();
            } else {
              list.add({"pana": pana, "amount": amt.toString(), "type": _selectedSession});
            }
          }
          _bidController.clear(); _pointsController.clear();
        });
        _showMessage('${info.length} bids added.');
      } else {
        _showMessage(map['msg'] ?? 'Error.', isError: true);
      }
    } catch (e) {
      _showMessage('Network error.', isError: true);
    } finally {
      if (mounted) setState(() => _isApiCalling = false);
    }
  }

  int _getTotalPoints() {
    int total = 0;
    _entriesBySession.forEach((_, list) { for (var e in list) total += int.parse(e['amount']!); });
    return total;
  }

  void _confirm() {
    final all = [..._entriesBySession['OPEN']!, ..._entriesBySession['CLOSE']!];
    if (all.isEmpty) { _showMessage('No bids added.', isError: true); return; }
    final total = _getTotalPoints();
    if (total > _walletBalance) { _showMessage('Insufficient balance.', isError: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: all.map((e) => {"digit": e['pana']!, "points": e['amount']!, "type": "SP Motor (${e['type']})", "pana": e['pana']!}).toList(),
        totalBids: all.length,
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
    try {
      final all = [..._entriesBySession['OPEN']!, ..._entriesBySession['CLOSE']!];
      final resp = await http.post(
        Uri.parse('${Constant.apiEndpoint}place-bid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          "registerId": _registerId,
          "gameId": widget.gameId.toString(),
          "bidAmount": total,
          "gameType": widget.gameCategoryType,
          "bid": all.map((e) => {"sessionType": e['type'], "digit": "", "pana": e['pana'], "bidAmount": int.parse(e['amount']!)}).toList(),
        }),
      );

      final data = jsonDecode(resp.body);
      if (resp.statusCode == 200 && (data['status'] == true || data['status'] == 'true')) {
        final newBal = _walletBalance - total;
        userController.walletBalance.value = newBal.toString();
        setState(() {
          _walletBalance = newBal;
          _entriesBySession['OPEN']!.clear();
          _entriesBySession['CLOSE']!.clear();
        });
        showDialog(context: context, builder: (_) => const BidSuccessDialog());
      } else {
        showDialog(context: context, builder: (_) => BidFailureDialog(errorMessage: data['msg'] ?? 'Failed.'));
      }
    } catch (e) {
      _showMessage('Submit error.', isError: true);
    } finally {
      if (mounted) setState(() => _isApiCalling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = [..._entriesBySession['OPEN']!, ..._entriesBySession['CLOSE']!];
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
                            const SizedBox(height: 8),
                            _buildSessionToggle(),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Enter Digits (3-7)'), const SizedBox(height: 8), _buildInput(_bidController, 'e.g. 12345')])),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Enter Points'), const SizedBox(height: 8), _buildInput(_pointsController, 'Points', max: null)])),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _isApiCalling ? null : _addEntry,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('ADD MOTOR', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Expanded(
                        child: all.isEmpty
                            ? Center(child: Text('No motor added yet', style: GoogleFonts.poppins(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                itemCount: all.length,
                                itemBuilder: (_, i) => _buildBidCard(all[i], i),
                              ),
                      ),
                    ],
                  ),
                  if (_message != null)
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: AnimatedMessageBar(key: _messageKey, message: _message!, isError: _isError, onDismissed: () => setState(() => _message = null)),
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

  Widget _buildInput(TextEditingController controller, String hint, {int? max = 7}) => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: controller, keyboardType: TextInputType.number, inputFormatters: max != null ? [LengthLimitingTextInputFormatter(max)] : [], style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _buildBidCard(Map<String, String> bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(bid['pana']!, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['amount']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text('Session: ${bid['type']}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22), onPressed: () => setState(() {
        _entriesBySession[bid['type']!]!.removeAt(_entriesBySession[bid['type']!]!.indexOf(bid));
      })),
    ]),
  );

  Widget _buildBottomBar() {
    final all = [..._entriesBySession['OPEN']!, ..._entriesBySession['CLOSE']!];
    final total = _getTotalPoints();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(children: [
        Expanded(child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Bids', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${all.length}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('$total', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isApiCalling || all.isEmpty ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
