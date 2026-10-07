import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../../ulits/Constents.dart';

class KingJackpotHistoryScreen extends StatefulWidget {
  const KingJackpotHistoryScreen({Key? key}) : super(key: key);
  @override
  State<KingJackpotHistoryScreen> createState() => _KingJackpotHistoryScreenState();
}

class _KingJackpotHistoryScreenState extends State<KingJackpotHistoryScreen> {
  List<BetHistoryEntry> entries = [];
  bool loading = false;
  DateTime _selectedFromDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

  Future<void> fetchEntries() async {
    setState(() => loading = true);
    final url = '${Constant.apiEndpoint}bet-history';
    final token = GetStorage().read("accessToken") ?? '';
    String registerId = GetStorage().read("registerId") ?? "";

    final String formattedFromDate = DateFormat('yyyy-MM-dd').format(_selectedFromDate);

    final requestBody = jsonEncode({
      'registerId': registerId,
      'pageIndex': 1,
      'recordLimit': 10000,
      'placeType': 'jackpot',
      'fromDate': formattedFromDate,
    });

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {
          'deviceId': 'qwert',
          'deviceName': 'sm2233',
          'accessStatus': '1',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        Map<String, dynamic>? info;
        if (data['info'] is String && data['info'].isEmpty) {
          info = null;
        } else {
          info = data['info'] as Map<String, dynamic>?;
        }

        if (info != null) {
          final list = info['list'] as List<dynamic>? ?? [];
          setState(() {
            entries = list.map((e) => BetHistoryEntry.fromJson(e)).toList();
          });
        } else {
          setState(() => entries = []);
        }
      }
    } catch (e) {
      debugPrint('Exception: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3882F6),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3882F6),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedFromDate) {
      setState(() {
        _selectedFromDate = picked;
      });
      fetchEntries();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  String _translateStatus(String status, AppLocalizations? l10n) {
    if (l10n == null) return status;
    final statusLower = status.toLowerCase();
    if (statusLower.contains('better luck') || statusLower.contains('better luck next time')) {
      return l10n.betterLuckNextTime;
    }
    if (statusLower.contains('win') || statusLower.contains('won')) {
      return l10n.win;
    }
    if (statusLower.contains('loss') || statusLower.contains('lost')) {
      return l10n.loss;
    }
    if (statusLower.contains('pending')) {
      return l10n.pending;
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel = DateFormat('dd-MM-yyyy').format(_selectedFromDate);
    const primaryColor = Color(0xFF3882F6);
    const secondaryColor = Color(0xFF0F4C81);

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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 18),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "King Jackpot",
              style: GoogleFonts.poppins(
                color: secondaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              dateLabel,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.1),
                ),
                child: const Icon(Icons.calendar_month, color: primaryColor, size: 22),
              ),
            ),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        "No bid entries found.",
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: entries.length,
                  itemBuilder: (context, index) => _buildPlayedMatchCard(entries[index], l10n),
                ),
    );
  }

  Widget _buildPlayedMatchCard(BetHistoryEntry entry, AppLocalizations? l10n) {
    final statusText = _translateStatus(entry.status, l10n);
    final isWin = entry.status.toLowerCase().contains('win') || entry.status.toLowerCase().contains('won');
    final isLoss = entry.status.toLowerCase().contains('loss') || entry.status.toLowerCase().contains('better');
    final isPending = entry.status.toLowerCase().contains('pending');

    Color statusColor = const Color(0xFF3882F6);
    if (isWin) statusColor = Colors.green;
    if (isLoss) statusColor = Colors.red;
    if (isPending) statusColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF5F5F5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF3882F6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.gameName,
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(
                  entry.bidId,
                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCol(l10n?.gameType ?? "Game Type", entry.betType),
                    _buildStatCol(l10n?.digit ?? "Digit", entry.digit),
                    _buildStatCol(l10n?.points ?? "Points", "₹${entry.amount}", isAmount: true),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          entry.transactionTime,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText.toUpperCase(),
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, {bool isAmount = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isAmount ? const Color(0xFF0F4C81) : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

class BetHistoryEntry {
  final String date;
  final String gameName;
  final String betType;
  final String digit;
  final String amount;
  final String transactionTime;
  final String bidId;
  final String winAmount;
  final String status;

  BetHistoryEntry({
    required this.date,
    required this.gameName,
    required this.betType,
    required this.digit,
    required this.amount,
    required this.transactionTime,
    required this.bidId,
    required this.winAmount,
    required this.status,
  });

  factory BetHistoryEntry.fromJson(Map<String, dynamic> json) {
    return BetHistoryEntry(
      date: json['bidDate'] ?? 'Unknown Date',
      gameName: json['title'] ?? 'Unknown Game',
      betType: json['gameType'] ?? 'N/A',
      digit: json['selectedDigit']?.toString() ?? 'N/A',
      amount: json['bidAmount']?.toString() ?? '0',
      transactionTime: json['bidTime'] ?? 'Unknown Time',
      bidId: json['bidId'] ?? 'N/A',
      winAmount: json['winAmount']?.toString() ?? '0',
      status: json['statusText'] ?? 'Pending',
    );
  }
}
