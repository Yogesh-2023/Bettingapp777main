import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_sara/Fund/BankDetailsFragment.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../Helper/TranslationHelper.dart';
import '../Helper/UserController.dart';
import 'AddFundScreen.dart';
import 'DepositHistoryPage.dart';
import 'WithdrawScreen.dart';
import 'WithdrawalHistoryPage.dart';
import '../HomeScreen/HomeScreen.dart';

class FundsScreen extends StatefulWidget {
  final void Function(String title)? onItemTap;

  FundsScreen({super.key, this.onItemTap});

  @override
  State<FundsScreen> createState() => _FundsScreenState();
}

class _FundsScreenState extends State<FundsScreen> {
  final UserController userController = Get.put(UserController());

  List<_FundOption> getFundOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      _FundOption(
        l10n?.addFund ?? "Add Fund", 
        "assets/images/add_fund.png", 
        "Add Fund"
      ),
      _FundOption(
        l10n?.withdrawFunds ?? "Withdraw Funds", 
        "assets/images/withdrawl_fund.png", 
        "Withdraw Funds"
      ),
      _FundOption(
        l10n?.bankDetails ?? "Bank Details", 
        "assets/images/add_bank_details.png", 
        "Bank Details"
      ),
      _FundOption(
        l10n?.depositHistory ?? "Deposit History", 
        "assets/images/fund_deposite_history.png", 
        "Deposit History"
      ),
      _FundOption(
        l10n?.withdrawHistory ?? "Withdraw History", 
        "assets/images/fund_withdraw_history.png", 
        "Withdraw History"
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
                      l10n?.funds ?? 'Funds',
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
                    itemCount: getFundOptions(context).length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = getFundOptions(context)[index];
                      return _buildFundListItem(item);
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

  Widget _buildFundListItem(_FundOption item) {
    return InkWell(
      onTap: () {
        switch (item.key) {
          case "Add Fund":
            Navigator.push(context, MaterialPageRoute(builder: (_) => AddFundScreen()));
            break;
          case "Withdraw Funds":
            Navigator.push(context, MaterialPageRoute(builder: (_) => WithdrawScreen()));
            break;
          case "Bank Details":
            Navigator.push(context, MaterialPageRoute(builder: (_) => BankDetailsFragment()));
            break;
          case "Deposit History":
            Navigator.push(context, MaterialPageRoute(builder: (_) => DepositHistoryPage()));
            break;
          case "Withdraw History":
            Navigator.push(context, MaterialPageRoute(builder: (_) => WithdrawalHistoryPage()));
            break;
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            // 🌸 Glassy Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                item.assetIconPath,
                width: 28,
                height: 28,
              ),
            ),
            const SizedBox(width: 18),
            // 📑 Option Label
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
            // ⏭ Chevron Icon
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

class _FundOption {
  final String title;
  final String assetIconPath;
  final String key; // For switch statement matching

  _FundOption(this.title, this.assetIconPath, this.key);
}