import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/l10n/app_localizations.dart';

import '../HomeScreen/HomeScreen.dart';
import '../ulits/Constents.dart';

class PassbookPage extends StatefulWidget {
  const PassbookPage({Key? key}) : super(key: key);
  @override
  State<PassbookPage> createState() => _PassbookPageState();
}

class _PassbookPageState extends State<PassbookPage> {
  int pageIndex = 1;
  final int recordLimit = 20; // Updated recordLimit to match API request
  List<PassbookEntry> entries = [];
  bool isLandscape = false;
  bool loading = false;
  int _totalPages = 1; // New state variable for total pages
  GetStorage storage = GetStorage();
  String deviceId = '';
  String deviceName = '';
  String registerId = '';
  late String token = '';
  final url = '${Constant.apiEndpoint}passbook-history';

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

  Future<void> fetchEntries() async {
    setState(() => loading = true);
    // Corrected API URL to match the domain used in other API calls
    token = storage.read("accessToken") ?? '';
    registerId = storage.read("registerId") ?? ''; // New static registerId
    deviceId = storage.read('deviceId') ?? '';
    deviceName = storage.read('deviceName') ?? '';

    log("Fetching Passbook entries...");
    log("Register Id: $registerId");
    log("Access Token: $token"); // Log the access token being used

    final requestBody = jsonEncode({
      'registerId': registerId,
      'pageIndex': pageIndex,
      'recordLimit': recordLimit,
    });

    log("Request Body: $requestBody"); // Log the request body

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {
          'deviceId': deviceId,
          'deviceName': deviceName,
          'accessStatus': '1',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      log("Response Status Code: ${res.statusCode}");
      log("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final info = data['info'] as Map<String, dynamic>?;

        if (info != null) {
          final list = info['list'] as List<dynamic>? ?? [];
          final totalPages = info['totalPages'] as int? ?? 1;

          setState(() {
            entries = list.map((e) => PassbookEntry.fromJson(e)).toList();
            _totalPages = totalPages;
          });
          log(
            "Parsed entries count: ${entries.length}",
          ); // Log parsed entries count
        } else {
          setState(() {
            entries = [];
            _totalPages = 1;
          });
          debugPrint('Info field is null in API response');
        }
      } else {
        debugPrint('Error ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('Exception: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  void _toggleOrientation() {
    isLandscape = !isLandscape;
    SystemChrome.setPreferredOrientations(
      isLandscape
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );
    setState(() {});
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white, // White theme
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7), // Light peach accent
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30), // Match FundPage radius
                topRight: Radius.circular(30), // Match FundPage radius
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LEFT SIDE (Back Icon + Text together)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ), // space between icon & text

                          Text(
                            l10n?.passbook ?? 'Passbook',
                            style: const TextStyle(
                              color: Color(0xFF0F4C81),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // RIGHT SIDE ICON
                      IconButton(
                        icon: const Icon(
                          Icons.screen_rotation,
                          color: Colors.black,
                        ),
                        onPressed: _toggleOrientation,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: loading
                       ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3882F6),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildHeader(),
                                if (entries.isEmpty)
                                  Container(
                                    width: isLandscape
                                        ? 900
                                        : MediaQuery.of(context)
                                              .size
                                              .width, // Adjust width for landscape
                                    height: 100,
                                    alignment: Alignment.center,
                                    color: Colors.white,
                                    child: Text(
                                      l10n?.noEntriesFound ??
                                          "No entries found.",
                                    ),
                                  )
                                else
                                  ...entries.map((e) => _buildRow(e)),
                              ],
                            ),
                          ),
                        ),
                ),
                _buildPagination(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: const Color(0xFF3882F6),
      child: Row(
        children: [
          _HeaderCell(l10n?.date ?? "Date", width: 130),
          _HeaderCell(l10n?.time ?? "Time", width: 130),
          _HeaderCell(l10n?.description ?? "Description", width: 250),
          _HeaderCell(
            l10n?.previousAmount ?? l10n?.prevAmt ?? "Prev Amt",
            width: 150,
          ),
          _HeaderCell(
            l10n?.transactionAmount ?? l10n?.txnAmt ?? "Txn Amt",
            width: 150,
          ),
          _HeaderCell(
            l10n?.currentAmount ?? l10n?.curAmt ?? "Cur Amt",
            width: 150,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(PassbookEntry e) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _DataCell(e.date, width: 130), // Use e.date
          _DataCell(e.time, width: 130), // Use e.time
          _DataCell(e.description, width: 250), // Use e.description
          _DataCell("₹ ${e.previousAmount}", width: 150),
          _DataCell(
            "${e.type == 'credit' ? '₹' : '₹'}${e.transactionAmount}", // Use e.type for sign
            width: 150,
            isCredit: e.isCredit,
          ),
          _DataCell("₹${e.currentAmount}", width: 150),
          // Removed _DataCell for remark
        ],
      ),
    );
  }

  Widget _buildPagination() {
    bool canGoPrev = pageIndex > 1;
    bool canGoNext = pageIndex < _totalPages;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3882F6).withOpacity(0.2), // Light brand magenta
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ⬅ PREVIOUS
            InkWell(
              onTap: canGoPrev
                  ? () {
                      setState(() {
                        pageIndex--;
                      });
                      fetchEntries();
                    }
                  : null,
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: canGoPrev ? Colors.black87 : Colors.black87,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)?.prev ?? "Prev",
                    style: TextStyle(
                      color: canGoPrev ? Colors.black87 : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ⚫ PAGE NUMBER CIRCLE
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF0F4C81),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                "($pageIndex/$_totalPages,)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ), // Use _totalPages
              ),
            ),

            // ➡ NEXT
            InkWell(
              onTap: canGoNext
                  ? () {
                      setState(() {
                        pageIndex++;
                      });
                      fetchEntries();
                    }
                  : null,
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)?.nextPage ?? "Next",
                    style: TextStyle(
                      color: canGoNext ? Colors.black87 : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: canGoNext ? Colors.black87 : Colors.black87,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(String label, bool enabled, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFF3882F6) : Colors.white70,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F4C81),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Updated PassbookEntry class to match new API response
class PassbookEntry {
  final String date;
  final String time;
  final String description;
  final String previousAmount;
  final String transactionAmount;
  final String currentAmount;
  final String type; // "credit" or "debit"

  PassbookEntry.fromJson(Map<String, dynamic> json)
    : date = json['date'] ?? '',
      time = json['time'] ?? '',
      description = json['description'] ?? '',
      previousAmount = json['previousAmount']?.toString() ?? '',
      transactionAmount = json['transactionAmount']?.toString() ?? '',
      currentAmount = json['currentAmount']?.toString() ?? '',
      type = json['type'] ?? '';

  // Helper to determine if it's a credit transaction
  bool get isCredit => type.toLowerCase() == 'credit';
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final double width;
  const _HeaderCell(this.text, {required this.width});
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(10),
    decoration: const BoxDecoration(
      border: Border(right: BorderSide(color: Colors.white, width: 1)),
    ),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool isCredit;
  // Removed showIcon as it's not present in the new API response and image
  final double width;
  const _DataCell(this.text, {this.isCredit = false, required this.width});
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 55,
    padding: const EdgeInsets.all(10),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: Colors.grey)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: isCredit ? Colors.green : Colors.black),
          ),
        ),
        // Removed if (showIcon) Icon
      ],
    ),
  );
}
