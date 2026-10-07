import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletBalancePill extends StatelessWidget {
  final RxBool accountStatus;
  final RxString walletBalance;
  final double horizontalPadding;
  final double verticalPadding;

  const WalletBalancePill({
    super.key,
    required this.accountStatus,
    required this.walletBalance,
    required this.horizontalPadding,
    required this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => accountStatus.value
          ? Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white, // Premium white pill
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/images/ic_wallet.png",
                    width: 20,
                    height: 20,
                    color: const Color(0xFF0F4C81), // Royal Blue
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "₹${walletBalance.value}",
                    style: const TextStyle(
                      color: Color(0xFF0F4C81), // Royal Blue
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
