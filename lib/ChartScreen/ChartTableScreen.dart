import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../ulits/Constents.dart';
import '../l10n/app_localizations.dart';

class ChartTableScreen extends StatefulWidget {
  final int gameId;
  final String gameType;

  const ChartTableScreen({
    super.key,
    required this.gameId,
    required this.gameType,
  });

  @override
  State<ChartTableScreen> createState() => _ChartTableScreenState();
}

class _ChartTableScreenState extends State<ChartTableScreen> {
  List<dynamic> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChartData();
  }

  Future<void> fetchChartData() async {
    final String token = GetStorage().read("accessToken");
    final String deviceId = GetStorage().read('deviceId');
    final String deviceName = GetStorage().read(
      'deviceName',
    ); // Replace with actual token

    final response = await http.post(
      Uri.parse('${Constant.apiEndpoint}table-chart'),
      headers: {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'accessStatus': '1',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'gameId': widget.gameId, 'gameType': widget.gameType}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['status'] == true) {
        setState(() {
          chartData = json['info'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } else {
      debugPrint('API Error: ${response.statusCode}');
      setState(() => isLoading = false);
    }
  }

  Widget buildHeaderRow(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xffeeeeee),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                l10n?.date ?? 'Date',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                l10n?.open ?? 'Open',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Jodi',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                l10n?.close ?? 'Close',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDataRow(Map<String, dynamic> row) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                row['date'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                row['open'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                row['digit'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ), // digit as jodi
          Expanded(
            child: Center(
              child: Text(
                row['close'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      // Apply the same gradient background as MyBidsPage.dart
      backgroundColor: Colors.transparent,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// 🔥 FULL GRADIENT BACKGROUND (Copied from MyBidsPage.dart)
        decoration: const BoxDecoration(
         color:Color(0xffFF6f00)
        ),

        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 12),

              // ⭐ OUTER ROUNDED CONTAINER WITH TOP ROUNDED CORNERS ONLY ⭐
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                  ), // Remove horizontal margin
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30), // Match MyBidsPage radius
                      topRight: Radius.circular(30), // Match MyBidsPage radius
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 🔙 Arrow + Charts (LEFT)
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
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
                                      color: Colors.grey,
                                      size: 26,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ), // gap between arrow & text

                                Text(
                                  l10n?.charts ?? 'Charts',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Chart Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(color: Colors.amber),
                                )
                              : chartData.isEmpty
                                  ? Center(
                                      child: Text(
                                        AppLocalizations.of(context)?.noChartDataFound ?? 'No chart data found.',
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        buildHeaderRow(context),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: chartData.length,
                                            itemBuilder: (context, index) {
                                              return buildDataRow(chartData[index]);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
