import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/ulits/Constents.dart';
import 'package:new_sara/l10n/app_localizations.dart';

class WithdrawalHistoryPage extends StatefulWidget {
  const WithdrawalHistoryPage({super.key});

  @override
  State<WithdrawalHistoryPage> createState() => _WithdrawalHistoryPageState();
}

class _WithdrawalHistoryPageState extends State<WithdrawalHistoryPage> {
  late Future<List<WithdrawalItem>> _withdrawFuture;
  final String apiUrl = '${Constant.apiEndpoint}withdrawal-fund-history';
  final GetStorage storage = GetStorage();
  String accessToken = '';
  String registerId = '';

  @override
  void initState() {
    super.initState();
    accessToken = storage.read('accessToken') ?? '';
    registerId = storage.read('registerId') ?? '';
    _withdrawFuture = fetchWithdrawals();
  }

  Future<List<WithdrawalItem>> fetchWithdrawals() async {
    if (accessToken.isEmpty || registerId.isEmpty) return [];

    final url = Uri.parse(apiUrl);
    final headers = {
      'deviceId': 'qwert',
      'deviceName': 'sm2233',
      'accessStatus': '1',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final body = jsonEncode({
      'registerId': registerId,
      'pageIndex': 1,
      'recordLimit': 50,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['info'] != null && responseData['info'] is Map) {
          final list = responseData['info']['list'] as List?;
          return list?.map((e) => WithdrawalItem.fromJson(e)).toList() ?? [];
        }
        return [];
      } else {
        throw Exception("Server error");
      }
    } catch (e) {
      log("Error fetching withdrawals: $e");
      return [];
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
          l10n?.fundWithdrawHistory ?? 'Withdraw History',
          style: GoogleFonts.poppins(
            color: secondaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: FutureBuilder<List<WithdrawalItem>>(
        future: _withdrawFuture,
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
                    l10n?.noWithdrawHistoryFound ?? "No withdraw history found.",
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) => _buildWithdrawCard(list[index]),
          );
        },
      ),
    );
  }

  Widget _buildWithdrawCard(WithdrawalItem item) {
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
            child: Column(
              children: [
                Row(
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
                            item.withdrawMode.isEmpty ? "Fund Withdrawal" : item.withdrawMode,
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
                      "₹${item.amount.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: const Color(0xFF0F4C81),
                      ),
                    ),
                  ],
                ),
                if (item.upiId.isNotEmpty || item.bankName.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _buildDetailRow(
                    Icons.payment_rounded,
                    item.upiId.isNotEmpty ? "UPI ID" : "Bank",
                    item.upiId.isNotEmpty ? item.upiId : item.bankName,
                  ),
                ],
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class WithdrawalItem {
  final String requestDate;
  final double amount;
  final String fundId;
  final String withdrawMode;
  final String upiId;
  final String bankName;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String requestType;
  final String statusText;

  WithdrawalItem({
    required this.requestDate,
    required this.amount,
    required this.fundId,
    required this.withdrawMode,
    required this.upiId,
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.requestType,
    required this.statusText,
  });

  factory WithdrawalItem.fromJson(Map<String, dynamic> json) {
    return WithdrawalItem(
      requestDate: json['requestDate'] as String? ?? 'N/A',
      amount: double.tryParse(json['amount']?.toString() ?? '0.0') ?? 0.0,
      fundId: json['fundId']?.toString() ?? '',
      withdrawMode: json['withdrawMode']?.toString() ?? 'N/A',
      upiId: json['upiId']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      accountHolderName: json['accountHolderName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifscCode: json['ifscCode']?.toString() ?? '',
      requestType: json['requestType']?.toString() ?? 'N/A',
      statusText: json['statusText']?.toString() ?? 'Unknown',
    );
  }
}
