import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_sara/l10n/app_localizations.dart';

class BidSuccessDialog extends StatelessWidget {
  const BidSuccessDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FractionallySizedBox(
        widthFactor: 1.1, // ✅ 90% screen width
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ ORANGE CHECK ICON
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: const Color(0xFF0F4C81),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 45,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 22),

              // ✅ GOOD LUCK TEXT
              Text(
                l10n?.goodLuck ?? "Good Luck",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1C2134),
                ),
              ),

              const SizedBox(height: 10),

              // ✅ SUCCESS TEXT
              Text(
                l10n?.bidsPlacedSuccessfully ?? "Bids Placed Successfully",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 26),

              // ✅ OK BUTTON
              SizedBox(
                width: 140,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n?.ok ?? "OK",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
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
