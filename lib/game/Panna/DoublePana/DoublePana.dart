import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../BidService.dart';
import '../../../Helper/UserController.dart';
import '../../../components/AnimatedMessageBar.dart';
import '../../../components/BidConfirmationDialog.dart';
import '../../../components/BidFailureDialog.dart';
import '../../../components/BidSuccessDialog.dart';
import '../../../l10n/app_localizations.dart';

class DoublePanaBetScreen extends StatefulWidget {
  final String title;
  final String gameCategoryType;
  final int gameId;
  final String gameName;
  final bool selectionStatus;

  const DoublePanaBetScreen({
    super.key,
    required this.title,
    required this.gameId,
    required this.gameName,
    required this.gameCategoryType,
    required this.selectionStatus,
  });

  @override
  State<DoublePanaBetScreen> createState() => _DoublePanaBetScreenState();
}

class _DoublePanaBetScreenState extends State<DoublePanaBetScreen> {
  String _selectedSession = 'OPEN';
  final TextEditingController _panaCtrl = TextEditingController();
  final FocusNode _panaFocusNode = FocusNode();
  final TextEditingController _amountCtrl = TextEditingController();

  final List<String> doublePanaOptions = const [
    "100","110","112","113","114","115","116","117","118","119","122","133","144","155","166","177","188","199","200","220","223","224","225","226","227","228","229","233","244","255","266","277","288","299","300","330","334","335","336","337","338","339","344","355","366","377","388","399","400","440","445","446","447","448","449","455","466","477","488","499","500","550","556","557","558","559","566","577","588","599","600","660","667","668","669","677","688","699","700","770","778","779","788","799","800","880","889","899","900","990",
  ];

  final List<Map<String, String>> _bids = [];
  final GetStorage _storage = GetStorage();
  late final BidService _bidService;
  final userController = Get.find<UserController>();

  late String _accessToken;
  late String _registerId;
  late bool _accountStatus;
  int _walletBalance = 0;
  bool _isApiCalling = false;

  String? _msg;
  bool _msgError = false;
  Key _msgKey = UniqueKey();

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
    if (!widget.selectionStatus) _selectedSession = 'CLOSE';
  }

  @override
  void dispose() {
    _panaCtrl.dispose();
    _panaFocusNode.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _showMsg(String m, {bool err = false}) {
    if (!mounted) return;
    setState(() { _msg = m; _msgError = err; _msgKey = UniqueKey(); });
    Future.delayed(const Duration(seconds: 3), () { if (mounted) setState(() => _msg = null); });
  }

  void _addBid() {
    final p = _panaCtrl.text.trim();
    final a = _amountCtrl.text.trim();
    if (!doublePanaOptions.contains(p)) { _showMsg('Enter valid Double Pana.', err: true); return; }
    final pts = int.tryParse(a);
    if (pts == null || pts < 10) { _showMsg('Min points 10.', err: true); return; }

    if (_getTotalPoints() + pts > _walletBalance) { _showMsg('Insufficient balance.', err: true); return; }

    setState(() {
      final idx = _bids.indexWhere((b) => b['digit'] == p && b['type'] == _selectedSession);
      if (idx != -1) {
        _bids[idx]['amount'] = (int.parse(_bids[idx]['amount']!) + pts).toString();
      } else {
        _bids.add({'digit': p, 'amount': a, 'type': _selectedSession});
      }
      _panaCtrl.clear(); _amountCtrl.clear();
    });
    _showMsg('Added Pana $p.');
  }

  int _getTotalPoints() => _bids.fold(0, (s, e) => s + int.parse(e['amount']!));

  void _confirm() {
    if (_bids.isEmpty) { _showMsg('Add some bids first.', err: true); return; }
    final total = _getTotalPoints();
    if (total > _walletBalance) { _showMsg('Insufficient balance.', err: true); return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BidConfirmationDialog(
        gameTitle: widget.title,
        gameDate: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
        bids: _bids.map((b) => {'digit': b['digit']!, 'pana': b['digit']!, 'points': b['amount']!, 'type': b['type']!}).toList(),
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
    for (var b in _bids) { if (b['type'] == 'OPEN') openBids[b['digit']!] = b['amount']!; else closeBids[b['digit']!] = b['amount']!; }

    Future<bool> send(String s, Map<String, String> m) async {
      final res = await _bidService.placeFinalBids(gameName: widget.title, accessToken: _accessToken, registerId: _registerId, deviceId: 'id', deviceName: 'Panna', accountStatus: _accountStatus, bidAmounts: m, selectedGameType: s, gameId: widget.gameId, gameType: widget.gameCategoryType, totalBidAmount: m.values.fold(0, (sum, e) => sum + int.parse(e)));
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
      setState(() { _walletBalance = newBal; _bids.clear(); });
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
                            Row(
                              children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Enter Pana'), const SizedBox(height: 8), _buildPanaInput()])),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Enter Points'), const SizedBox(height: 8), _buildInput(_amountCtrl, 'Points')])),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 52,
                              child: ElevatedButton(
                                onPressed: _isApiCalling ? null : _addBid,
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3882F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                child: Text('ADD BID', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
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
                      child: AnimatedMessageBar(key: _msgKey, message: _msg!, isError: _msgError, onDismissed: () => setState(() => _msg = null)),
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

  Widget _buildPanaInput() => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: RawAutocomplete<String>(
      textEditingController: _panaCtrl,
      focusNode: _panaFocusNode,
      optionsBuilder: (v) => v.text.isEmpty ? const Iterable<String>.empty() : doublePanaOptions.where((p) => p.startsWith(v.text)),
      fieldViewBuilder: (ctx, ctrl, fn, _) => TextField(controller: ctrl, focusNode: fn, keyboardType: TextInputType.number, maxLength: 3, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(counterText: "", hintText: "e.g. 100", hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero)),
      optionsViewBuilder: (ctx, onSel, opt) => Align(alignment: Alignment.topLeft, child: Material(elevation: 4, borderRadius: BorderRadius.circular(12), child: SizedBox(height: 200, width: 200, child: ListView.builder(padding: EdgeInsets.zero, itemCount: opt.length, itemBuilder: (_, i) => ListTile(title: Text(opt.elementAt(i), style: GoogleFonts.poppins(fontSize: 14)), onTap: () => onSel(opt.elementAt(i))))))),
    ),
  );

  Widget _buildInput(TextEditingController ctrl, String hint) => Container(
    height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDDDDDD))),
    child: Center(child: TextField(controller: ctrl, keyboardType: TextInputType.number, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
  );

  Widget _buildBidCard(Map<String, String> bid, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEEEEEE))),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF3882F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(bid['digit']!, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF3882F6))))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("₹${bid['amount']} Points", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81))), Text(bid['type']!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))])),
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