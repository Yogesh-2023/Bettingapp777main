import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/l10n/app_localizations.dart';

// Assuming 'ulits/Constents.dart' exists and contains Constant.apiEndpoint
import '../../ulits/Constents.dart';

class NoticeHistoryScreen extends StatefulWidget {
  const NoticeHistoryScreen({Key? key}) : super(key: key);

  @override
  State<NoticeHistoryScreen> createState() => _NoticeHistoryScreenState();
}

class _NoticeHistoryScreenState extends State<NoticeHistoryScreen> {
  List<NoticeEntry> entries = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchNoticeHistory();
  }

  Future<void> _fetchNoticeHistory() async {
    setState(() => loading = true);

    final String mobileNo =
        GetStorage().read("mobileNo") ??
        '7007465202'; // Using provided mobileNo from curl
    final token = GetStorage().read("accessToken") ?? '';

    // Construct the URL with query parameters for a GET request
    // Ensure mobileNo is a string for URL query parameter
    final Uri uri = Uri.parse(
      '${Constant.apiEndpoint}notice-history',
    ).replace(queryParameters: {'mobileNo': mobileNo});

    log("Fetching Notice History entries...");
    log("Mobile No: $mobileNo");
    log("Access Token: $token");
    log("Request URL: $uri"); // Log the full URL for GET request

    try {
      final res = await http.get(
        // Changed to http.get
        uri, // Use the constructed Uri
        headers: {
          'deviceId': 'qwert',
          'deviceName': 'sm2233',
          'accessStatus': '1',
          'Content-Type':
              'application/json', // Still include for consistency, though less critical for GET
          'Authorization': 'Bearer $token',
        },
      );

      log("Response Status Code: ${res.statusCode}");
      log("Response Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == true && data['info'] is List) {
          // Check if 'info' is a List
          final List<dynamic> noticeList =
              data['info']; // 'info' is directly the list
          setState(() {
            entries = noticeList.map((e) => NoticeEntry.fromJson(e)).toList();
          });
          log("Parsed Notice History entries count: ${entries.length}");
        } else {
          setState(() {
            entries = [];
          });
          debugPrint(
            'API response status is false or info field is not a List.',
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
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
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF0F4C81),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppLocalizations.of(context)?.notifications ?? 'Notifications',
                    style: const TextStyle(
                      color: Color(0xFF0F4C81),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // List Content
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3882F6), // Magenta loader
                      ),
                    )
                  : entries.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context)?.noNotificationsFound ?? "No notifications found.",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        return _buildNoticeCard(entries[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to parse text and apply bold formatting for text within asterisks
  List<TextSpan> _parseAndFormatText(String text) {
    if (text.isEmpty) {
      return [const TextSpan(text: '')];
    }
    
    // Sometimes API returns \n literally, replace with true newlines
    String cleanText = text.replaceAll(r'\n', '\n');
    
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'\*(.*?)\*'); // Regex to find text between asterisks
    int lastMatchEnd = 0;
    final matches = exp.allMatches(cleanText).toList();

    // If no matches found, return the text as-is
    if (matches.isEmpty) {
      return [TextSpan(text: cleanText)];
    }

    for (RegExpMatch match in matches) {
      // Add text before the current match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: cleanText.substring(lastMatchEnd, match.start)));
      }
      // Add the bolded text (content inside asterisks)
      spans.add(
        TextSpan(
          text: match.group(1) ?? '', // Group 1 is the content inside the parentheses
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
      lastMatchEnd = match.end;
    }

    // Add any remaining text after the last match
    if (lastMatchEnd < cleanText.length) {
      spans.add(TextSpan(text: cleanText.substring(lastMatchEnd)));
    }

    return spans.isEmpty ? [TextSpan(text: cleanText)] : spans;
  }

  Widget _buildNoticeCard(NoticeEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3882F6).withOpacity(0.3), width: 1), // Gentle magenta border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4C81).withOpacity(0.05), // Soft blue shadow
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title.toUpperCase(), // Display title
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
                color: Color(0xFF0F4C81), // Title blue
              ),
            ),
            const SizedBox(height: 12),
            // Use RichText to display formatted description
            RichText(
              text: TextSpan(
                children: _parseAndFormatText(entry.description),
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.5, // Line height makes reading large blobs much easier
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ), // Default style for the description
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data model for Notice History entries
class NoticeEntry {
  final String title;
  final String description;

  NoticeEntry({required this.title, required this.description});

  factory NoticeEntry.fromJson(Map<String, dynamic> json) {
    return NoticeEntry(
      title: json['title'] ?? 'No Title',
      description: json['msg'] ?? 'No Description', // Mapped from 'msg'
    );
  }
}

// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:http/http.dart' as http;
//
// // Assuming 'ulits/Constents.dart' exists and contains Constant.apiEndpoint
// import '../../ulits/Constents.dart';
//
// class NoticeHistoryScreen extends StatefulWidget {
//   const NoticeHistoryScreen({Key? key}) : super(key: key);
//
//   @override
//   State<NoticeHistoryScreen> createState() => _NoticeHistoryScreenState();
// }
//
// class _NoticeHistoryScreenState extends State<NoticeHistoryScreen> {
//   List<NoticeEntry> entries = [];
//   bool loading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchNoticeHistory();
//   }
//
//   Future<void> _fetchNoticeHistory() async {
//     setState(() => loading = true);
//
//     final String mobileNo =
//         GetStorage().read("mobileNo") ??
//         '7007465202'; // Using provided mobileNo from curl
//     final token = GetStorage().read("accessToken") ?? '';
//
//     // Construct the URL with query parameters for a GET request
//     // Ensure mobileNo is a string for URL query parameter
//     final Uri uri = Uri.parse(
//       '${Constant.apiEndpoint}notice-history',
//     ).replace(queryParameters: {'mobileNo': mobileNo});
//
//     log("Fetching Notice History entries...");
//     log("Mobile No: $mobileNo");
//     log("Access Token: $token");
//     log("Request URL: $uri"); // Log the full URL for GET request
//
//     try {
//       final res = await http.get(
//         // Changed to http.get
//         uri, // Use the constructed Uri
//         headers: {
//           'deviceId': 'qwert',
//           'deviceName': 'sm2233',
//           'accessStatus': '1',
//           'Content-Type':
//               'application/json', // Still include for consistency, though less critical for GET
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       log("Response Status Code: ${res.statusCode}");
//       log("Response Body: ${res.body}");
//
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         if (data['status'] == true && data['info'] is List) {
//           // Check if 'info' is a List
//           final List<dynamic> noticeList =
//               data['info']; // 'info' is directly the list
//           setState(() {
//             entries = noticeList.map((e) => NoticeEntry.fromJson(e)).toList();
//           });
//           log("Parsed Notice History entries count: ${entries.length}");
//         } else {
//           setState(() {
//             entries = [];
//           });
//           debugPrint(
//             'API response status is false or info field is not a List.',
//           );
//         }
//       } else {
//         debugPrint('Error ${res.statusCode}: ${res.body}');
//       }
//     } catch (e) {
//       debugPrint('Exception: $e');
//     } finally {
//       setState(() => loading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade200, // Lighter grey background
//       appBar: AppBar(
//         backgroundColor: Colors.white, // White app bar
//         elevation: 0.5,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           "Notifications", // Title for the screen
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: loading
//                   ? const Center(
//                       child: CircularProgressIndicator(color: Colors.red),
//                     )
//                   : entries.isEmpty
//                   ? Center(
//                       child: Text(
//                         "No notifications found.",
//                         style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(12),
//                       itemCount: entries.length,
//                       itemBuilder: (context, index) {
//                         return _buildNoticeCard(entries[index]);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNoticeCard(NoticeEntry entry) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               entry.title.toUpperCase(), // Display title
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.black,
//               ),
//             ),
//             // Date and time fields are not present in the new API response, so removed
//             // if (entry.date.isNotEmpty || entry.time.isNotEmpty) ...[
//             //   const SizedBox(height: 4),
//             //   Text(
//             //     '${entry.date} ${entry.time}', // Display date and time if available
//             //     style: const TextStyle(
//             //       fontSize: 12,
//             //       color: Colors.grey,
//             //     ),
//             //   ),
//             // ],
//             const SizedBox(height: 8),
//             Text(
//               entry
//                   .description, // Display main description (now 'msg' from API)
//               style: const TextStyle(fontSize: 14, color: Colors.black87),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Data model for Notice History entries
// class NoticeEntry {
//   final String title;
//   final String description;
//   // Removed date and time as they are not present in the new API response
//   // final String date;
//   // final String time;
//
//   NoticeEntry({
//     required this.title,
//     required this.description,
//     // this.date = '',
//     // this.time = '',
//   });
//
//   factory NoticeEntry.fromJson(Map<String, dynamic> json) {
//     return NoticeEntry(
//       title: json['title'] ?? 'No Title',
//       description: json['msg'] ?? 'No Description', // Mapped from 'msg'
//       // date: json['date'] ?? '',
//       // time: json['time'] ?? '',
//     );
//   }
// }
