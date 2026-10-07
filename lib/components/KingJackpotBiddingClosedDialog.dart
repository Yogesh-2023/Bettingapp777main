import 'package:flutter/material.dart';
import 'package:new_sara/l10n/app_localizations.dart';

class KingJackpotBiddingClosedDialog extends StatelessWidget {
  final String time;
  final String resultTime;
  final String bidLastTime;

  const KingJackpotBiddingClosedDialog({
    super.key,
    required this.time,
    required this.resultTime,
    required this.bidLastTime,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // ✅ Rounded dialog
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),

      ),

      // ✅ Remove default margins (for 95% width)
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.025,
      ),

      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),

      // ✅ Force width = 95%
      content: SizedBox(

        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ❌ Close Icon
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF0F4C81),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 40,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            /// ⏰ Time Title
            Text(
              time,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F4C81),
              ),
            ),

            const SizedBox(height: 6),

            /// 🔴 Closed Text
            Text(
              AppLocalizations.of(context)?.closedForToday ?? "Closed for Today",
              style: const TextStyle(
                fontSize: 16,
                color: const Color(0xFFB71C1C),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            /// 🕒 Bid Last Time
            _infoRow(
              AppLocalizations.of(context)?.bidTime ?? "Bid Time :",
              bidLastTime,
            ),

            const SizedBox(height: 10),

            /// 🕒 Result Time
            _infoRow(
              AppLocalizations.of(context)?.bidResultTime ?? "Bid Result Time :",
              resultTime,
            ),

            const SizedBox(height: 24),

            /// ✅ OK Button
            SizedBox(
              width: 120,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)?.ok ?? "OK",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔶 Styled Info Row (UI only)
  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0F4C81)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
