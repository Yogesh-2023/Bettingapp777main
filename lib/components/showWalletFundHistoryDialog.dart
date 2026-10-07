import 'package:flutter/material.dart';
import 'package:new_sara/l10n/app_localizations.dart';

void showWalletFundHistoryDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Red Circle with X
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1A0000FF), // Light blue background
              ),
              child: const Icon(
                Icons.close,
                color: Colors.red,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),

            // Message
            Text(
              AppLocalizations.of(context)?.walletFundHistoryNotAvailable ?? 
                'Wallet Fund History Not Available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF0F4C81),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 30),

            // OK Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)?.ok ?? 'OK',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
