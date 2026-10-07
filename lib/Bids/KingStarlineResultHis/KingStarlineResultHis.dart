import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_sara/ulits/Constents.dart';

class KingStarlineResultScreen extends StatefulWidget {
  const KingStarlineResultScreen({super.key});

  @override
  State<KingStarlineResultScreen> createState() =>
      _KingStarlineResultScreenState();
}

class _KingStarlineResultScreenState extends State<KingStarlineResultScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, String>> fullResults = [];
  bool isLoading = false;

  List<String> hours = [
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "01:00 PM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
    "05:00 PM",
    "06:00 PM",
    "07:00 PM",
    "08:00 PM",
    "09:00 PM",
  ];

  @override
  void initState() {
    super.initState();
    fetchResultsForDate(selectedDate);
  }

  Future<void> fetchResultsForDate(DateTime date) async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse('${Constant.apiEndpoint}get-results');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "env_type": "Prod",
          "date": DateFormat("yyyy-MM-dd").format(date),
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List resultList = jsonData['result'];

        List<Map<String, String>> mapped = resultList.map<Map<String, String>>((
          item,
        ) {
          return {"time": item["time"] ?? "", "result": item["result"] ?? "**"};
        }).toList();

        setState(() {
          fullResults = mapped;
        });
      }
    } catch (e) {
      debugPrint("Error fetching: $e");
    }

    setState(() => isLoading = false);
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3882F6), // Header color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF3882F6), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      fetchResultsForDate(picked);
    }
  }

  String getResultForTime(String time) {
    final match = fullResults.firstWhere(
      (item) => item["time"] == time,
      orElse: () => {"result": "**"},
    );
    return match["result"]!;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      // backgroundColor: const Color(0xFFF1F1F1),
      // appBar: AppBar(
      //   title: Text(
      //     "KING STARLINE RESULT HISTORY",
      //     style: GoogleFonts.poppins(
      //       color: Colors.black,
      //       fontWeight: FontWeight.w600,
      //       fontSize: 16,
      //     ),
      //   ),
      //   backgroundColor: const Color(0xFFEDEDED),
      //   elevation: 0,
      //   centerTitle: false,
      //   iconTheme: const IconThemeData(color: Colors.black),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   actions: const [
      //     Padding(
      //       padding: EdgeInsets.only(right: 12),
      //       child: Icon(Icons.account_balance_wallet_outlined),
      //     ),
      //   ],
      // ),
        body: Container(
          width: double.infinity,
          height: double.infinity,

          // 🔥 Gradient Background (Same Theme)
          decoration: const BoxDecoration(
          color: Color(0xFFFFE082)
          ),

          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // 🔥 WHITE CURVED MAIN CONTAINER
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE082),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),

                    child: Column(
                      children: [
                        Text(
                          "KING STARLINE RESULT HISTORY",
                          style: GoogleFonts.poppins(
                            color: Color(0xFF0F4C81),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        /// 🔥 TOP (Select Date)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                "Select Date",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _selectDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Color(0xFF3882F6),
                                      width: 1.4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    DateFormat("dd/MM/yyyy").format(selectedDate),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// 🔥 MAIN LIST
                        Expanded(
                          child: isLoading
                              ? const Center(
                            child: CircularProgressIndicator(color: Color(0xFF3882F6)),
                          )
                              : ListView.builder(
                            itemCount: hours.length,
                            padding: const EdgeInsets.only(top: 10),
                            itemBuilder: (context, index) {
                              final time = hours[index];
                              final result = getResultForTime(time);

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Color(0xffFF6f00),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      time,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3882F6),
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      result,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              );
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
        )

    );
  }
}
