import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../Helper/UserController.dart';
import '../../ulits/Constents.dart';

class KingJackpotResultScreen extends StatefulWidget {
  const KingJackpotResultScreen({super.key});

  @override
  State<KingJackpotResultScreen> createState() =>
      _KingJackpotResultScreenState();
}

class _KingJackpotResultScreenState extends State<KingJackpotResultScreen> {
  final UserController userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  DateTime selectedDate = DateTime.now();
  List<Map<String, String>> fullResults = [];
  bool isLoading = false;
  late final walletBalance;

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
    final num? bal = num.tryParse(userController.walletBalance.value);
    walletBalance = bal?.toInt() ?? 0;
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
      backgroundColor: Colors.transparent,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// 🔥 FULL GRADIENT THEME
        decoration: const BoxDecoration(color: Color(0xFFFFE082)),

        child: SafeArea(
          child: Column(
            children: [
              /// ---------------------------------------------------------
              /// 🔥 PREMIUM CURVED APPBAR (Same Theme)
              /// ---------------------------------------------------------
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.only(
              //     left: 14,
              //     right: 14,
              //     top: 14,
              //     bottom: 22,
              //   ),
              //   decoration: const BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [Color(0xFFFFE8D1), Color(0xFFE3F2FD)],
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //     ),
              //     borderRadius: BorderRadius.only(
              //       bottomLeft: Radius.circular(40),
              //       bottomRight: Radius.circular(40),
              //     ),
              //   ),
              //
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       /// BACK
              //       IconButton(
              //         icon: const Icon(
              //           Icons.arrow_back_ios_new,
              //           color: Colors.black,
              //         ),
              //         onPressed: () => Navigator.pop(context),
              //       ),
              //
              //       /// TITLE
              //       Expanded(
              //         child: Column(
              //           children: [
              //             Text(
              //               "KING JACKPOT RESULT",
              //               style: GoogleFonts.poppins(
              //                 fontWeight: FontWeight.w800,
              //                 fontSize: 16,
              //                 color: Colors.black,
              //               ),
              //             ),
              //             Text(
              //               "History",
              //               style: GoogleFonts.poppins(
              //                 fontSize: 13,
              //                 color: Colors.black54,
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //
              //       /// WALLET
              //       Row(
              //         children: [
              //           Image.asset(
              //             "assets/images/ic_wallet.png",
              //             width: 24,
              //             height: 24,
              //             color: Colors.black,
              //           ),
              //           const SizedBox(width: 6),
              //           Text(
              //             walletBalance.toString(),
              //             style: const TextStyle(
              //               fontWeight: FontWeight.bold,
              //               color: Colors.black,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 10),

              /// ---------------------------------------------------------
              /// 🔥 WHITE CURVED BODY
              /// ---------------------------------------------------------
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE082),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),

                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF3882F6),
                          ),
                        )
                      : Column(
                          children: [
                            Text(
                              "KING JACKPOT RESULT",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Color(0xFF0F4C81),
                              ),
                            ),
                            SizedBox(height: 5),

                            /// DATE PICKER ROW
                            Row(
                              children: [
                                Text(
                                  "Select Date",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Color(0xFF3882F6),
                                        width: 1.4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      DateFormat(
                                        "dd/MM/yyyy",
                                      ).format(selectedDate),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            /// RESULTS LIST
                            Expanded(
                              child: ListView.builder(
                                itemCount: hours.length,
                                itemBuilder: (context, index) {
                                  final time = hours[index];
                                  final result = getResultForTime(time);

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Color(0xFF3882F6),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
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
                                            fontSize: 16,
                                            color: Colors.black,
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
      ),
    );
  }
}
