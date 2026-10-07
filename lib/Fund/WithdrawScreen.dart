import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/l10n/app_localizations.dart';
import 'package:new_sara/ulits/Constents.dart';

import '../Helper/TranslationHelper.dart';
import '../Helper/UserController.dart';
import '../components/showWithdrawTermsDialog.dart'
    show showWithdrawTermsDialog;

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class WithdrawalMethod {
  static const String googlePay = "Google Pay";
  static const String phonePe = "PhonePe";
  static const String paytm = "Paytm";
  static const String bankAccount = "Bank Account";
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  // --- State ---
  int currentBalance = 0;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController paymentNumberController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController holderNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();

  final UserController userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController());

  String selectedMethod = WithdrawalMethod.googlePay;
  String currentLangCode = GetStorage().read("language")?.toString() ?? "en";
  late final int minimumWithdrawalAmount;
  final Map<String, String> _translationCache = {};

  final String _apiBaseUrl = Constant.apiEndpoint;

  bool _termsShown = false;

  @override
  void initState() {
    super.initState();
    minimumWithdrawalAmount = _readMinWithdrawalFromStorage();
    _loadCurrentBalance();
    // Ensure app settings (times/status) are present
    userController.fetchAndUpdateFeeSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    paymentNumberController.dispose();
    bankNameController.dispose();
    holderNameController.dispose();
    accountNumberController.dispose();
    ifscCodeController.dispose();
    super.dispose();
  }

  // ---- Helpers ----
  int _readMinWithdrawalFromStorage() {
    final v = GetStorage().read("minimumWithdrawalAmount");
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) {
      final parsed = int.tryParse(v);
      if (parsed != null) return parsed;
      final asDouble = double.tryParse(v);
      if (asDouble != null) return asDouble.toInt();
    }
    return 1000;
  }

  void _loadCurrentBalance({bool refreshUI = false}) {
    final dynamic raw = userController.walletBalance.value;
    final double asDouble = (raw is num)
        ? raw.toDouble()
        : double.tryParse(raw?.toString() ?? '') ?? 0.0;
    final int next = asDouble.floor();

    if (refreshUI && mounted) {
      setState(() => currentBalance = next);
    } else {
      currentBalance = next;
    }
  }

  Future<String> _t(String text) async {
    if (_translationCache.containsKey(text)) return _translationCache[text]!;
    final translated = await TranslationHelper.translate(text, currentLangCode);
    _translationCache[text] = translated;
    return translated;
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffFF6f00)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffFF6f00), width: 2),
      ),
    );
  }

  Widget _buildMethodOption(String method, String logoPath) {
    return Card(
      color: Colors.grey.shade200,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: RadioListTile<String>(
        value: method,
        groupValue: selectedMethod,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedMethod = value;
              if (value != WithdrawalMethod.bankAccount) {
                bankNameController.clear();
                holderNameController.clear();
                accountNumberController.clear();
                ifscCodeController.clear();
              } else {
                paymentNumberController.clear();
              }
            });
          }
        },
        secondary: Image.asset(
          logoPath,
          width: 36,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.payment_outlined, size: 36),
        ),
        title: Text(
          method, // Method names are typically not translated
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          AppLocalizations.of(context)?.manualApproveByAdmin ?? "Manual approve by Admin"
        ),
        activeColor: Color(0xffFF6f00),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      cursorColor: Color(0xffFF6f00),
      keyboardType: keyboardType,
      decoration: _buildInputDecoration(hint),
    );
  }

  Widget _buildBankFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField(
          bankNameController, 
          AppLocalizations.of(context)?.bankName ?? "Bank Name"
        ),
        const SizedBox(height: 12),
        _buildTextField(
          holderNameController, 
          AppLocalizations.of(context)?.accountHolderName ?? "Account Holder Name"
        ),
        const SizedBox(height: 12),
        _buildTextField(
          accountNumberController,
          AppLocalizations.of(context)?.accountNumber ?? "Account Number",
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          ifscCodeController, 
          AppLocalizations.of(context)?.ifscCode ?? "IFSC Code"
        ),
      ],
    );
  }

  Widget _buildDynamicFields() {
    final l10n = AppLocalizations.of(context);
    String selectedMethodHint;
    switch (selectedMethod) {
      case WithdrawalMethod.googlePay:
        selectedMethodHint = l10n?.enterGooglePayUpiId ?? "Enter Google Pay UPI ID";
        break;
      case WithdrawalMethod.phonePe:
        selectedMethodHint = l10n?.enterPhonepeUpiId ?? "Enter PhonePe UPI ID";
        break;
      case WithdrawalMethod.paytm:
        selectedMethodHint = l10n?.enterPaytmNumber ?? "Enter Paytm Number";
        break;
      default:
        selectedMethodHint = l10n?.enterUpiIdNumber ?? "Enter UPI ID/Number";
    }

    return Column(
      children: [
        _buildTextField(
          amountController,
          AppLocalizations.of(context)?.enterAmount ?? "Enter Amount",
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        if (selectedMethod != WithdrawalMethod.bankAccount)
          _buildTextField(
            paymentNumberController,
            selectedMethodHint,
            keyboardType: selectedMethod == WithdrawalMethod.paytm
                ? TextInputType.phone
                : TextInputType.text,
          )
        else
          _buildBankFields(),
      ],
    );
  }

  // ----------------- TIME WINDOW LOGIC -----------------

  /// Parse "h:mm AM/PM" to TimeOfDay. Returns null if bad.
  TimeOfDay? _parseAmPm(String s) {
    try {
      final parts = s.trim().split(RegExp(r'\s+'));
      if (parts.length != 2) return null;
      final hm = parts[0].split(':');
      if (hm.length != 2) return null;
      int h = int.parse(hm[0]);
      int m = int.parse(hm[1]);
      final isPm = parts[1].toUpperCase().startsWith('P');
      if (h == 12) h = 0; // 12 AM -> 0
      final hour24 = h + (isPm ? 12 : 0);
      return TimeOfDay(hour: hour24, minute: m);
    } catch (_) {
      return null;
    }
  }

  int? _toMinutes(String raw) {
    if (raw.isEmpty) return null;
    var s = raw.trim().toUpperCase();

    // Strip accidental AM/PM if hour already 24h style (e.g. "13:30 PM")
    final badSuffix = s.endsWith(" AM") || s.endsWith(" PM");
    String? suffix;
    if (badSuffix) {
      suffix = s.substring(s.length - 2); // "AM"/"PM"
      s = s.substring(0, s.length - 3).trim(); // remove trailing " AM"/" PM"
    }

    final hm = s.split(':');
    if (hm.length != 2) return null;
    final h = int.tryParse(hm[0]) ?? -1;
    final m = int.tryParse(hm[1]) ?? -1;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;

    int hour24 = h;

    // If there was AM/PM originally and hour <= 12, convert
    if (suffix != null && h >= 0 && h <= 12) {
      if (suffix == "AM") {
        hour24 = (h == 12) ? 0 : h; // 12 AM -> 00
      } else if (suffix == "PM") {
        hour24 = (h == 12) ? 12 : h + 12; // 12 PM -> 12, 1..11 PM -> +12
      }
    }

    return hour24 * 60 + m;
  }

  // Proper 12h text for UI: "1:30 PM" / "11:05 AM"
  String fmtTime12h(String raw) {
    final mins = _toMinutes(raw);
    if (mins == null) return "--:--";
    int h24 = mins ~/ 60, m = mins % 60;
    final isPM = h24 >= 12;
    int h12 = h24 % 12;
    if (h12 == 0) h12 = 12;
    final mm = m.toString().padLeft(2, '0');
    return "$h12:$mm ${isPM ? 'PM' : 'AM'}";
  }

  /// Equal open/close => CLOSED. Overnight supported.
  bool _isWithinWithdrawWindowNow() {
    final o = _toMinutes(userController.withdrawOpenTime.value.trim());
    final c = _toMinutes(userController.withdrawCloseTime.value.trim());
    if (!userController.withdrawStatus.value || o == null || c == null)
      return false;
    if (o == c) return false; // equal => closed per your rule

    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;

    if (o < c) {
      // same-day window
      return nowMin >= o && nowMin <= c;
    } else {
      // overnight window
      return nowMin >= o || nowMin <= c;
    }
  }

  /// Get formatted window text - shows backend time format as-is
  String _windowText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = userController.withdrawOpenTime.value.trim();
    final c = userController.withdrawCloseTime.value.trim();
    if (o.isEmpty || c.isEmpty) return ""; // nothing until data arrives
    return l10n?.youCanWithdrawBetween(fmtTime12h(o), fmtTime12h(c)) ??
        "You can withdraw between ${fmtTime12h(o)} and ${fmtTime12h(c)}.";
  }

  // -----------------------------------------------------

  Future<void> _performWithdrawal() async {
    // Only show timing warning when window is CLOSED
    if (!userController.withdrawStatus.value || !_isWithinWithdrawWindowNow()) {
      final timingLine = _windowText(context);
      if (timingLine.isNotEmpty && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(timingLine)));
      }
      return;
    }

    final amountText = amountController.text.trim();
    final paymentDetail = paymentNumberController.text.trim();
    final String? accessToken = GetStorage().read('accessToken')?.toString();
    final String registerId = GetStorage().read('registerId')?.toString() ?? '';

    final l10n = AppLocalizations.of(context);
    if (accessToken == null || accessToken.isEmpty || registerId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.pleaseLoginAgainToContinue ?? "Please log in again to continue."
          )
        ),
      );
      return;
    }

    if (amountText.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.pleaseEnterAnAmount ?? "Please enter an amount.")
        ),
      );
      return;
    }
    final int? amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.pleaseEnterValidAmount ?? "Please enter a valid amount.")
        ),
      );
      return;
    }

    if (amount < minimumWithdrawalAmount) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.minimumWithdrawalAmountIs(minimumWithdrawalAmount) ??
              "Minimum withdrawal amount is ₹$minimumWithdrawalAmount.",
          ),
        ),
      );
      return;
    }

    if (amount > currentBalance) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.insufficientBalance ?? "Insufficient balance.")
        ),
      );
      return;
    }

    String withdrawType;
    final Map<String, dynamic> requestBody = {
      "registerId": registerId,
      "amount": amount,
    };

    switch (selectedMethod) {
      case WithdrawalMethod.googlePay:
        withdrawType = "googlePay";
        if (paymentDetail.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.pleaseEnterGooglePayUpiId ?? "Please enter Google Pay UPI ID."
              ),
            ),
          );
          return;
        }
        requestBody["upiId"] = paymentDetail;
        break;

      case WithdrawalMethod.phonePe:
        withdrawType = "phonePe";
        if (paymentDetail.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.pleaseEnterPhonepeUpiId ?? "Please enter PhonePe UPI ID."
              )
            ),
          );
          return;
        }
        requestBody["upiId"] = paymentDetail;
        break;

      case WithdrawalMethod.paytm:
        withdrawType = "paytm";
        if (paymentDetail.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.pleaseEnterPaytmNumber ?? "Please enter Paytm Number."
              )
            ),
          );
          return;
        }
        requestBody["upiId"] = paymentDetail;
        break;

      case WithdrawalMethod.bankAccount:
        withdrawType = "bank";
        if (bankNameController.text.trim().isEmpty ||
            holderNameController.text.trim().isEmpty ||
            accountNumberController.text.trim().isEmpty ||
            ifscCodeController.text.trim().isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.pleaseFillAllBankDetails ?? "Please fill all bank details."
              )
            ),
          );
          return;
        }
        requestBody["bankName"] = bankNameController.text.trim();
        requestBody["accountHolderName"] = holderNameController.text.trim();
        requestBody["accountNumber"] = accountNumberController.text.trim();
        requestBody["ifscCode"] = ifscCodeController.text.trim();
        break;

      default:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.pleaseSelectWithdrawalMethod ?? "Please select a withdrawal method."
            ),
          ),
        );
        return;
    }

    requestBody["withdrawType"] = withdrawType;

    log("Withdraw Request Body: ${json.encode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse('${_apiBaseUrl}withdraw-fund-request'),
        headers: {
          'deviceId': 'qwert',
          'deviceName': 'sm2233',
          'accessStatus': '1',
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      log("Withdraw Response Status: ${response.statusCode}");
      log("Withdraw Response Body: ${response.body}");

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.withdrawalRequestSubmittedSuccessfully ?? 
                  "Withdrawal request submitted successfully!",
              ),
            ),
          );
          _clearFields();
          _loadCurrentBalance(refreshUI: true);
        } else {
          final String msg =
              (responseBody['msg']?.toString().trim().isNotEmpty ?? false)
              ? responseBody['msg'].toString()
              : (l10n?.withdrawalRequestFailed ?? "Withdrawal request failed.");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      } else {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.serverError(response.statusCode) ??
                "Server error: ${response.statusCode}"
            ),
          ),
        );
      }
    } catch (e) {
      log("Error during withdrawal request: $e");
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.anErrorOccurred(e.toString()) ??
              "An error occurred: $e"
          )
        ),
      );
    }
  }

  void _clearFields() {
    amountController.clear();
    paymentNumberController.clear();
    bankNameController.clear();
    holderNameController.clear();
    accountNumberController.clear();
    ifscCodeController.clear();
  }

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final timingText = _windowText(context); // Backend format (7:30 AM)
      final statusOn = userController.withdrawStatus.value;
      final withinWindow = _isWithinWithdrawWindowNow();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3882F6).withOpacity(0.1),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF3882F6), size: 18),
            ),
          ),
        ),
        title: Text(
          l10n?.withdrawFunds ?? "Withdraw Funds",
          style: GoogleFonts.poppins(
            color: const Color(0xFF0F4C81),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 20),
                          // Modern Premium Wallet Card
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3882F6), Color(0xFFD000D0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3882F6).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -20, top: -20,
                                  child: Icon(Icons.account_balance_wallet, size: 120, color: Colors.white.withOpacity(0.1)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "+${userController.mobileNo.value}",
                                                style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 13),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                            child: const Icon(Icons.wallet, color: Colors.white, size: 20),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      Text(
                                        l10n?.availableBalance ?? "Available Balance",
                                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "₹ $currentBalance",
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// Show timing card ONLY when window is CLOSED
                          //  if (!(statusOn && withinWindow) && timingText.isNotEmpty)
                          Card(
                            color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.lock_clock_rounded,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      timingText, // Shows: "You can withdraw between 7:30 AM and 7:30 PM"
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          _buildMethodOption(
                            WithdrawalMethod.googlePay,
                            "assets/images/gpay_deposit.png",
                          ),
                          _buildMethodOption(
                            WithdrawalMethod.phonePe,
                            "assets/images/phonepe_deposit.png",
                          ),
                          _buildMethodOption(
                            WithdrawalMethod.paytm,
                            "assets/images/paytm_deposit.png",
                          ),
                          _buildMethodOption(
                            WithdrawalMethod.bankAccount,
                            "assets/images/bank_emoji.png",
                          ),
                          const SizedBox(height: 10),
                          _buildDynamicFields(),
                          const SizedBox(height: 10),

                          ElevatedButton(
                            onPressed: _performWithdrawal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3882F6),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              l10n?.submit ?? "SUBMIT",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
          ],
        ),
      ),
    );
  });
}
}
