import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/l10n/app_localizations.dart';

class DepositHistoryPage extends StatefulWidget {
  const DepositHistoryPage({Key? key}) : super(key: key);

  @override
  State<DepositHistoryPage> createState() => _DepositHistoryPageState();
}

class _DepositHistoryPageState extends State<DepositHistoryPage> {
  late Future<List<DepositHistoryItem>> _depositFuture;
  final storage = GetStorage();

  String accessToken = '';
  String registerId = '';

  @override
  void initState() {
    super.initState();
    accessToken = storage.read('accessToken') ?? '';
    registerId = storage.read('registerId') ?? '';
    _depositFuture = fetchDepositHistory();
  }

  Future<List<DepositHistoryItem>> fetchDepositHistory() async {
    final uri = Uri.parse('https://admin.mhmatka.app/api/v1/deposit-fund-history');
    final requestBody = jsonEncode({
      'registerId': registerId,
      'pageIndex': 1,
      'recordLimit': 50,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          'deviceId': 'qwert',
          'deviceName': 'sm2233',
          'accessStatus': '1',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: requestBody,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['status'] == true && data['info'] != null) {
          final List<dynamic> list = data['info']['list'] ?? [];
          return list.map((item) => DepositHistoryItem.fromJson(item)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception('Failed to load history');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        title: Text(
          l10n?.fundDepositHistory ?? 'Deposit History',
          style: GoogleFonts.poppins(
            color: secondaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: FutureBuilder<List<DepositHistoryItem>>(
        future: _depositFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Something went wrong', style: GoogleFonts.poppins()));
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.noDepositHistoryFound ?? 'No history found',
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) => _buildHistoryCard(list[index]),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(DepositHistoryItem item) {
    Color statusColor;
    IconData statusIcon;
    final status = item.statusText.toLowerCase();

    if (status.contains('completed') || status.contains('success')) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_rounded;
    } else if (status.contains('pending')) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending_actions_rounded;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_rounded;
    }

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.remark.isEmpty ? "Fund Deposit" : item.remark,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        item.requestDate,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "₹${item.amount}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: const Color(0xFF0F4C81),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  item.statusText.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DepositHistoryItem {
  final String txId;
  final String requestDate;
  final String amount;
  final String remark;
  final String statusText;

  DepositHistoryItem({
    required this.txId,
    required this.requestDate,
    required this.amount,
    required this.remark,
    required this.statusText,
  });

  factory DepositHistoryItem.fromJson(Map<String, dynamic> json) {
    return DepositHistoryItem(
      txId: json['txId']?.toString() ?? '',
      requestDate: json['requestDate'] ?? 'Unknown Date',
      amount: json['amount']?.toString() ?? '0',
      remark: json['remark'] ?? '',
      statusText: json['statusText'] ?? 'Unknown',
    );
  }
}
