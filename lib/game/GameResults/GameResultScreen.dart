import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'market_result.dart';

class GameResultScreen extends StatefulWidget {
  const GameResultScreen({super.key});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  DateTime selectedDate = DateTime.now();
  late Future<List<MarketResult>> futureResults;

  @override
  void initState() {
    super.initState();
    futureResults = fetchResultsByDate(formattedDate);
  }

  String get formattedDate => DateFormat('dd/MM/yyyy').format(selectedDate);

  Future<List<MarketResult>> fetchResultsByDate(String date) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate loading

    // Mock data
    return [
      MarketResult(market: "KALYAN", result: "123-45-678"),
      MarketResult(market: "RAJDHANI", result: "234-56-789"),
      MarketResult(market: "MILAN", result: "345-67-890"),
    ];
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        futureResults = fetchResultsByDate(formattedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE082),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFFFE082),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F4C81)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "MARKET RESULT HISTORY",
          style: TextStyle(color: Color(0xFF0F4C81), fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF0F4C81)),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: Text("5", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F4C81))),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Color(0xFFFFE082),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Date",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F4C81)),
                  ),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFE082),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Color(0xFF0F4C81)),
                      ),
                      child: Text(formattedDate, style: TextStyle(color: Color(0xFF0F4C81))),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                color: Color(0xFFFFE082),
                child: FutureBuilder<List<MarketResult>>(
                  future: futureResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF3882F6)),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Color(0xFF0F4C81))));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No results for this date.', style: TextStyle(color: Color(0xFF0F4C81))),
                      );
                    }

                    final results = snapshot.data!;
                    return ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 5),
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          color: Color(0xFFFFE082),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.market.isNotEmpty ? item.market : "--",
                                style: GoogleFonts.poppins(
                                  color: Color(0xFF0F4C81),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item.result.isNotEmpty
                                    ? item.result
                                    : "***-**-***",
                                style: GoogleFonts.poppins(
                                  color: Color(0xFF0F4C81),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
