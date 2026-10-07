import 'package:flutter/material.dart';
import 'package:new_sara/l10n/app_localizations.dart';

void closeBidDialogue({
  required BuildContext context,
  required String gameName,
  required String openResultTime,
  required String openBidLastTime,
  required String closeResultTime,
  required String closeBidLastTime,
}) {
  final l10n = AppLocalizations.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Orange cross icon with sparkles
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0F4C81),
                    radius: 35,
                    child: Icon(Icons.close, size: 45, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Game name
              Text(
                gameName.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: const Color(0xFF0F4C81),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),

              // Closed for Today text
              Text(
                l10n?.closedForToday ?? "Closed for Today",
                style: const TextStyle(
                  color: const Color(0xFFB71C1C),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              // Timings Table
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0F4C81), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildTimeRow(l10n?.openBidLastTime ?? "Open Bid Last Time", openBidLastTime, isFirst: true),
                    _buildTimeRow(l10n?.openResultTime ?? "Open Result Time", openResultTime),

                    // ✅ Divider after first 2 rows
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: const Color(0xFF0F4C81),
                    ),

                    _buildTimeRow(l10n?.closeBidLastTime ?? "Close Bid Last Time", closeBidLastTime),
                    _buildTimeRow(l10n?.closeResultTime ?? "Close Result Time", closeResultTime, isLast: true),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // OK Button
              SizedBox(
                width: 130,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n?.ok ?? "OK",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildTimeRow(String label, String time, {bool isFirst = false, bool isLast = false}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label :",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          time.isNotEmpty ? time : "--:--",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}