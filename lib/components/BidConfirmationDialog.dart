import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_sara/l10n/app_localizations.dart';

class BidConfirmationDialog extends StatelessWidget {
  final String gameTitle;
  final String gameDate;
  final List<Map<String, String>> bids;
  final int totalBids;
  final int totalBidsAmount;
  final int walletBalanceBeforeDeduction;
  final String? walletBalanceAfterDeduction;
  final String gameId;
  final String gameType;
  final VoidCallback onConfirm;

  const BidConfirmationDialog({
    super.key,
    required this.gameTitle,
    required this.gameDate,
    required this.bids,
    required this.totalBids,
    required this.totalBidsAmount,
    required this.walletBalanceBeforeDeduction,
    this.walletBalanceAfterDeduction,
    required this.gameId,
    required this.gameType,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final int finalWalletBalanceAfterDeduction =
        int.tryParse(walletBalanceAfterDeduction ?? '') ??
            (walletBalanceBeforeDeduction - totalBidsAmount);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85, // 🔥 SCROLL LIMIT
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔶 HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    color: const Color(0xFF0F4C81),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Text(
                    "$gameTitle -",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 🔹 TABLE HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n?.digit ?? "Digit",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          l10n?.points ?? "Points",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          l10n?.gameType ?? "Type",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 🔹 BID LIST (AUTO SCROLLS WITH DIALOG)
                ...bids.map(
                      (bid) => Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xffF6F6F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            bid['digit'] ?? '',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            bid['points'] ?? '',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            bid['type'] ?? '',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 🔹 SUMMARY
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    children: [
                      _summaryItem(l10n?.bids(totalBids) ?? "Total Bids: $totalBids", totalBids.toString()),
                      _summaryItem(
                        l10n?.totalAmount ?? "Total Bid Amount",
                        totalBidsAmount.toString(),
                      ),
                      const Divider(height: 1),
                      _summaryItem(
                        l10n?.walletBalanceBeforeDeduction ?? "Wallet Balance Before Deduction",
                        walletBalanceBeforeDeduction.toString(),
                      ),
                      _summaryItem(
                        l10n?.walletBalanceAfterDeduction ?? "Wallet Balance After Deduction",
                        finalWalletBalanceAfterDeduction.toString(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 🔸 NOTE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    l10n?.noteBidOncePlayedWillNotBeCancelled ?? "*Note: Bid Once Played Will Not Be Cancelled",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 🔘 BUTTONS
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C81),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            l10n?.cancel ?? "Cancel",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C81),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            l10n?.submit ?? "Submit",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
