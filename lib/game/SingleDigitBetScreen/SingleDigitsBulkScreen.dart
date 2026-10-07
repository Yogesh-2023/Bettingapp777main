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

class BidEntry {
  final String digit;
  final String points;
  final String type;
  BidEntry({required this.digit, required this.points, required this.type});
}

class SingleDigitsBulkScreen extends StatefulWidget {
  final String title;
  final int gameId;
  final String gameName;
  final String gameType;
  final bool selectionStatus;

  const SingleDigitsBulkScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameName,
    required this.gameType,
    required this.selectionStatus,
  });

  @override
  State<SingleDigitsBulkScreen> createState() => _SingleDigitsBulkScreenState();
}

class _SingleDigitsBulkScreenState extends State<SingleDigitsBulkScreen> {
  String _selectedSession = 'OPEN';
  final TextEditingController pointsController = TextEditingController();
  List<BidEntry> bidEntries = [];

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
    if (!widget.selectionStatus) _selectedSession = 'CLOSE';
    _accessToken = _storage.read('accessToken') ?? '';
    _registerId = _storage.read('registerId') ?? '';
    _accountStatus = userController.accountStatus.value;
    _walletBalance = (double.tryParse(userController.walletBalance.value) ?? 0).toInt();
  }

  @override
  void dispose() {
    pointsController.dispose();
    super.dispose();
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    setState(() { _message = msg; _isError = isError; _messageBarKey = UniqueKey(); });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _message = null); });
  }

  void onNumberPressed(String number) {
    final ptsTxt = pointsController.text.trim();
    final pts = int.tryParse(ptsTxt);
    if (pts == null || pts < 10) { _showMessage('Min points 10.', isError: true); return; }

    if (_getTotalPoints() + pts > _walletBalance) { _showMessage('Insufficient balance.', isError: true); return; }

    setState(() {
      final idx = bidEntries.indexWhere((b) => b.digit == number && b.type == _selectedSession);
      if (idx != -1) {
        bidEntries[idx] = BidEntry(digit: number, points: (int.parse(bidEntries[idx].points) + pts).toString(), type: _selectedSession);
      } else {
        bidEntries.add(BidEntry(digit: number, points: ptsTxt, type: _selectedSession));
      }
    });
    _showMessage('Added Digit $number.');
  }

  int _getTotalPoints() => bidEntries.fold(0, (s, e) => s + int.parse(e.points));

  void _confirm() {
    if (bidEntries.isEmpty) { _showMessage('Add some bids first.', isError: true); return; }
    final total = _getTotalPoints();
    if (total > _walletBalance) { _showMessage('Insufficient balance.', isError: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: bidEntries.map((b) => {"digit": b.digit, "points": b.points, "type": b.type, "pana": ""}).toList(),
        totalBids: bidEntries.length,
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
    Map<String, String> openBids = {}; Map<String, String> closeBids = {};
    for (var b in bidEntries) { if (b.type == 'OPEN') openBids[b.digit] = b.points; else closeBids[b.digit] = b.points; }

    Future<bool> send(String s, Map<String, String> m) async {
      final res = await _bidService.placeFinalBids(gameName: widget.gameName, accessToken: _accessToken, registerId: _registerId, deviceId: 'id', deviceName: 'Bulk', accountStatus: _accountStatus, bidAmounts: m, selectedGameType: s, gameId: widget.gameId, gameType: widget.gameType, totalBidAmount: m.values.fold(0, (prev, e) => prev + int.parse(e)));
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
      setState(() { _walletBalance = newBal; bidEntries.clear(); });
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
                            _label('Enter Points'),
                            const SizedBox(height: 8),
                            _buildInput(),
                            const SizedBox(height: 20),
                            _label('Select Digit'),
                            const SizedBox(height: 12),
                            _buildNumberPad(),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      Expanded(
                        child: bidEntries.isEmpty
                            ? Center(child: Text('Tap a digit to add bids', style: GoogleFonts.poppins(color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                itemCount: bidEntries.length,
                                itemBuilder: (_, i) => _buildBidCard(bidEntries[i], i),
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
            Container(decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]), child: _buildBottomBar()),
          ],
        ),
      ),
    );
  }

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

  Widget _buildInput() => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: pointsController, keyboardType: TextInputType.number, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: "Points", hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _buildNumberPad() {
    final nums = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: nums.map((n) {
        final b = bidEntries.firstWhereOrNull((e) => e.digit == n && e.type == _selectedSession);
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 72) / 5, height: 50,
          child: GestureDetector(
            onTap: () => onNumberPressed(n),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(color: b != null ? const Color(0xFF3882F6) : const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(n, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: b != null ? Colors.white : const Color(0xFF0F4C81))),
                if (b != null) Text(b.points, style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBidCard(BidEntry bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(bid.digit, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6))))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid.points} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text(bid.type, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22), onPressed: () => setState(() => bidEntries.removeAt(i))),
    ]),
  );

  Widget _buildBottomBar() {
    final t = _getTotalPoints();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(children: [
        Expanded(child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Bids', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${bidEntries.length}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
          const SizedBox(width: 24),
          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Points', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)), Text('$t', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)))]),
        ])),
        ElevatedButton(onPressed: _isApiCalling || bidEntries.isEmpty ? null : _confirm, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 4), child: _isApiCalling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

extension IterableExt<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (var e in this) if (test(e)) return e;
    return null;
  }
}
