import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:new_sara/Bids/BidHistory/BidHistoryScreen.dart';
import 'package:new_sara/Bids/KingJackpotBidHis/KingJackpotHistoryScreen.dart';
import 'package:new_sara/Bids/KingJackpotResultHis/KingJackpotResultScreen.dart';
import 'package:new_sara/Bids/KingStartlineBidHis/KingStarlineBidHistoryScreen.dart';
import 'package:new_sara/game/GameResults/GameResultScreen.dart';
import 'package:new_sara/l10n/app_localizations.dart';
import '../Helper/UserController.dart';
import 'KingStarlineResultHis/KingStarlineResultHis.dart';
import '../HomeScreen/HomeScreen.dart';

class BidScreen extends StatefulWidget {
  @override
  State<BidScreen> createState() => _BidScreenState();
}

class _BidScreenState extends State<BidScreen> {
  final UserController userController = Get.put(UserController());

  List<_BidOption> _getBidOptions(AppLocalizations? l10n) {
    return [
      _BidOption(
        l10n?.historyPage ?? "BID HISTORY",
        l10n?.youCanViewYourMarketBidHistory ?? "You can view your market bid history",
        Icons.trending_up,
        "BID_HISTORY",
      ),
      _BidOption(
        "${l10n?.kingStarline ?? "KING STARLINE"} ${l10n?.historyPage ?? "Bid History"}",
        l10n?.youCanViewYourStarlineBidHistory ?? "You can view your starline bid history",
        Icons.account_balance,
        "KING_STARLINE_BID_HISTORY",
      ),
      _BidOption(
        "${l10n?.kingJackpot ?? "KING JACKPOT"} ${l10n?.historyPage ?? "Bid History"}",
        l10n?.youCanViewYourJackpotBidHistory ?? "You can view your jackpot bid history",
        Icons.attach_money,
        "KING_JACKPOT_BID_HISTORY",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF5), // Light navy blue theme
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFE8EEF5), // Light navy blue theme
        ),
        child: SafeArea(
          child: Column(
            children: [
              // -------------------- TOP HEADER --------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      l10n?.historyPage ?? 'History Page',
                      style: const TextStyle(
                        color: Color(0xFF0F4C81),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // -------------------- MAIN GLASSMORPHIC CONTAINER --------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4), // Glassy translucent
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _getBidOptions(l10n).length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _getBidOptions(l10n)[index];
                      return _buildBidListItem(item);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBidListItem(_BidOption item) {
    return InkWell(
      onTap: () {
        if (item.key == "BID_HISTORY") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => BidHistoryPage()));
        } else if (item.key == "KING_STARLINE_BID_HISTORY") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => KingStarlineBidHistoryScreen()));
        } else if (item.key == "KING_JACKPOT_BID_HISTORY") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => KingJackpotHistoryScreen()));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF0F5), Color(0xFFE3F2FD)], // Soft pink to soft blue gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 5,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          children: [
            // 🔘 Glassy Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                size: 26,
                color: const Color(0xFF5C6BC0), // Soft indigo icon
              ),
            ),
            const SizedBox(width: 18),
            // 📑 Label
            Expanded(
              child: Text(
                item.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // ⏭ Chevron
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFF48FB1), // Soft pink arrow
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _BidOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final String key;

  _BidOption(this.title, this.subtitle, this.icon, this.key);
}
