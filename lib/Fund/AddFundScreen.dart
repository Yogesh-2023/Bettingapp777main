import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_pay_upi/flutter_pay_upi_manager.dart';
import 'package:flutter_pay_upi/model/upi_app_model.dart';
import 'package:flutter_pay_upi/model/upi_response.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/Fund/QRPaymentScreen.dart';
import 'package:new_sara/l10n/app_localizations.dart';
import 'package:new_sara/ulits/Constents.dart';

import '../Helper/TranslationHelper.dart';
import '../Helper/UserController.dart';

class CreateTransactionLinkResponse {
  final String msg;
  final bool status;
  final String? paymentLink;

  CreateTransactionLinkResponse({
    required this.msg,
    required this.status,
    this.paymentLink,
  });

  factory CreateTransactionLinkResponse.fromJson(Map<String, dynamic> json) {
    return CreateTransactionLinkResponse(
      msg: (json['msg'] ?? '').toString(),
      status: json['status'] == true,
      paymentLink: json['payment_link']?.toString(),
    );
  }
}

class AddFundScreen extends StatefulWidget {
  const AddFundScreen({super.key});
  @override
  State<AddFundScreen> createState() => _AddFundScreenState();
}

class _AddFundScreenState extends State<AddFundScreen>
    with WidgetsBindingObserver {
  final UserController userController = Get.find<UserController>();

  final TextEditingController amountController = TextEditingController();
  final Random _random = Random();
  final Map<String, String> _translationCache = {};
  final String currentLangCode = (GetStorage().read('language') ?? 'en')
      .toString();

  final String _apiBaseUrl = Constant.apiEndpoint;

  String _upiPayeeVPA = '';
  String _upiPayeeName = '';
  late bool QRShow;
  late bool UPIShow;
  static const String _merchantCode = "";

  bool _isProcessingPayment = false;
  int _currentTransactionAmount = 0;
  String _currentTransactionId = '';
  String _currentPaymentMethodType = '';

  List<UpiApp> _apps = [];
  Timer? _walletTimer;
  Worker? _qrWorker;
  Worker? _upiWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    userController.fetchAndUpdateUserDetails();
    userController.fetchAndUpdateFeeSettings();

    QRShow = userController.qrStatus.value;
    UPIShow = userController.upiStatus.value;

    _qrWorker = ever<bool>(userController.qrStatus, (v) {
      if (mounted) setState(() => QRShow = v);
    });
    _upiWorker = ever<bool>(userController.upiStatus, (v) {
      if (mounted) setState(() => UPIShow = v);
    });

    validateAndAssignUPIorMobile();
    _upiPayeeName = userController.accountHolderName.value;

    _fetchUpiApps();
    _startWalletAutoRefresh();
  }

  @override
  void dispose() {
    amountController.dispose();
    _stopWalletAutoRefresh();
    _qrWorker?.dispose();
    _upiWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      userController.fetchAndUpdateUserDetails();
      _startWalletAutoRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopWalletAutoRefresh();
    }
  }

  void _hideKeyboard() {
    final scope = FocusScope.of(context);
    if (!scope.hasPrimaryFocus) {
      scope.unfocus();
    }
  }

  void _startWalletAutoRefresh({
    Duration interval = const Duration(seconds: 3),
  }) {
    _walletTimer?.cancel();
    _walletTimer = Timer.periodic(interval, (_) async {
      await userController.fetchAndUpdateUserDetails();
    });
    log('▶️ AddFundScreen wallet auto-refresh started');
  }

  void _stopWalletAutoRefresh() {
    _walletTimer?.cancel();
    _walletTimer = null;
    log('⏹ AddFundScreen wallet auto-refresh stopped');
  }

  String _url(String path) {
    final base = _apiBaseUrl.endsWith('/') ? _apiBaseUrl : '$_apiBaseUrl/';
    final p = path.startsWith('/') ? path.substring(1) : path;
    return '$base$p';
  }

  Future<String> _t(String text) async {
    if (_translationCache.containsKey(text)) return _translationCache[text]!;
    final t = await TranslationHelper.translate(text, currentLangCode);
    if (mounted) _translationCache[text] = t;
    return t;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Map<String, String> _buildHeaders() {
    final deviceId = (GetStorage().read('deviceId') ?? '').toString();
    final deviceName = (GetStorage().read('deviceName') ?? '').toString();
    final accessTok = (userController.accessToken.value).toString();
    return {
      'Authorization': 'Bearer $accessTok',
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'deviceId': deviceId,
      'deviceName': deviceName,
      'accessStatus': '1',
    };
  }

  String _mapDepositType(String appName) {
    final name = appName.toLowerCase();
    if (name.contains('google') || name.contains('gpay')) return 'googlePay';
    if (name.contains('phonepe')) return 'phonePe';
    if (name.contains('paytm')) return 'paytm';
    return 'bank';
  }

  Future<Map<String, dynamic>> _postJsonSafe(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse(_url(path));
    final res = await http.post(
      uri,
      headers: _buildHeaders(),
      body: json.encode(body),
    );

    Map<String, dynamic> out;
    try {
      final decoded = json.decode(res.body);
      out = decoded is Map<String, dynamic>
          ? decoded
          : {'status': false, 'msg': 'Invalid response format'};
    } catch (_) {
      out = {'status': false, 'msg': res.body.trim()};
    }
    out['_statusCode'] = res.statusCode;
    return out;
  }

  void _fetchUpiApps() async {
    try {
      final apps = await FlutterPayUpiManager.getListOfAndroidUpiApps();
      log('UPI apps: ${apps.map((a) => a.name).toList()}');
      if (mounted) setState(() => _apps = apps);
    } catch (e) {
      log('Failed to load UPI apps: $e');
    }
  }

  void validateAndAssignUPIorMobile() {
    final gpayUpiId = userController.gpayUpiId.value;
    final phonepeUpiId = userController.phonepeUpiId.value;
    final paytmUpiId = userController.paytmUpiId.value;

    log(
      "UPI details:  Gpay $gpayUpiId  PhonePay $phonepeUpiId  payTM $paytmUpiId",
    );

    if (gpayUpiId.isNotEmpty && validateUpiId(gpayUpiId) == null) {
      _upiPayeeVPA = gpayUpiId;
    } else if (phonepeUpiId.isNotEmpty && validateUpiId(phonepeUpiId) == null) {
      _upiPayeeVPA = phonepeUpiId;
    } else if (paytmUpiId.isNotEmpty && validateUpiId(paytmUpiId) == null) {
      _upiPayeeVPA = paytmUpiId;
    }

    if (_upiPayeeVPA.isEmpty) {
      _showSnackBar(
        AppLocalizations.of(context)?.upiPayeeDetailsNotConfigured ?? 
          'UPI payee details not configured.'
      );
    }
  }

  String? validateUpiId(String upiId) {
    if (upiId.isEmpty) {
      return AppLocalizations.of(context)?.invalidUpiIdFormat ?? 
        'Invalid UPI ID format';
    }
    return null;
  }

  Future<void> _validateAndPreparePayment() async {
    _hideKeyboard();
    if (mounted) setState(() => _isProcessingPayment = true);

    final text = amountController.text.trim();
    final int? amt = int.tryParse(text);

    final minAmount =
        (double.tryParse(userController.minDeposit.value)?.toInt()) ?? 0;

    if (amt == null || amt < minAmount) {
      final l10n = AppLocalizations.of(context);
      _showSnackBar(
        l10n?.pleaseEnterValidAmountMin(userController.minDeposit.value) ??
          "Please enter a valid amount (min ₹${userController.minDeposit.value}).",
      );
      if (mounted) setState(() => _isProcessingPayment = false);
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _currentTransactionAmount = amt;
      _currentTransactionId =
          '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(9999).toString().padLeft(4, '0')}';
    });

    if (_apps.isEmpty) {
      _showSnackBar(
        AppLocalizations.of(context)?.noUpiAppsFound ?? 
          await _t("No UPI apps found. Please install a UPI app to proceed."),
      );
      setState(() => _isProcessingPayment = false);
      return;
    }

    _showUpiAppSelectionSheet();
  }

  void _showUpiAppSelectionSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)?.selectUpiApp ?? 'Select UPI App',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                itemCount: _apps.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: .9,
                ),
                itemBuilder: (_, i) {
                  final app = _apps[i];
                  final name = app.name ?? 
                    (AppLocalizations.of(context)?.upiApp ?? 'UPI App');
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _currentPaymentMethodType = name;
                      _launchUpiWithApp(app);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 48,
                          width: 48,
                          child: app.icon != null
                              ? Image.memory(app.icon!)
                              : const Icon(Icons.payment, size: 48),
                        ),
                        const SizedBox(height: 6),
                        Text(name, textAlign: TextAlign.center, maxLines: 2),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      if (_isProcessingPayment && _currentPaymentMethodType.isEmpty) {
        if (mounted) setState(() => _isProcessingPayment = false);
      }
    });
  }

  Future<void> _launchUpiWithApp(UpiApp app) async {
    setState(() {
      _isProcessingPayment = true;
      _currentPaymentMethodType = (app.name ?? '').toString();
    });

      _upiPayeeName = userController.accountHolderName.value;
      log("Payee Details: $_upiPayeeVPA \n Name $_upiPayeeName");
      if (_upiPayeeVPA.isEmpty || _upiPayeeName.isEmpty) {
        setState(() {
          _isProcessingPayment = false;
          _currentPaymentMethodType = '';
        });
        _showSnackBar(
          AppLocalizations.of(context)?.upiPayeeDetailsNotConfigured ?? 
            'UPI payee details not configured.'
        );
        return;
      }

    try {
      FlutterPayUpiManager.startPayment(
        paymentApp: app.app!,
        payeeVpa: _upiPayeeVPA,
        payeeName: _upiPayeeName,
        transactionId: _currentTransactionId,
        payeeMerchantCode: _merchantCode,
        description: AppLocalizations.of(context)?.addFunds ?? "Add funds",
        amount: amountController.text.trim(),
        response: (UpiResponse upiResponse, String rawResponse) {
          log('UPI status: ${upiResponse.status} | $rawResponse');
          if (!mounted) return;

          setState(() => _isProcessingPayment = false);

          if ((upiResponse.status ?? '').toLowerCase() == 'success') {
            _reportPaymentStatusToBackend(upiResponse);
          } else {
            _showSnackBar(
              AppLocalizations.of(context)?.paymentFailedOrCancelled ?? 
                'Payment failed or cancelled.'
            );
          }
        },
        error: (String errorMessage) {
          log('UPI error: $errorMessage');
          if (!mounted) return;
          setState(() {
            _isProcessingPayment = false;
            _currentPaymentMethodType = '';
          });
          _showSnackBar(
            AppLocalizations.of(context)?.errorOccurredDuringUpiPayment(errorMessage) ??
              'An error occurred during UPI payment: $errorMessage'
          );
        },
      );
    } catch (e) {
      log('UPI launch error: $e');
      if (!mounted) return;
      setState(() {
        _isProcessingPayment = false;
        _currentPaymentMethodType = '';
      });

      if (e is RangeError) {
        log('Caught RangeError: ${e.message}');
        _showSnackBar(
          AppLocalizations.of(context)?.rangeErrorOccurredDuringUpiPayment ?? 
            'RangeError occurred during UPI payment. Please try again.',
        );
      } else {
        _showSnackBar(
          AppLocalizations.of(context)?.failedToLaunchUpiApp ?? 
            'Failed to launch UPI app due to unexpected error.'
        );
      }
    }
  }

  Future<void> _reportPaymentStatusToBackend(UpiResponse upiResponse) async {
    final paymentHashKey =
        upiResponse.transactionReferenceId ??
        upiResponse.transactionID ??
        'default_hash_key';

    final depositType = _mapDepositType(_currentPaymentMethodType);

    final createBody = {
      "registerId": userController.registerId.value,
      "depositType": depositType,
      "amount": _currentTransactionAmount,
      "hashKey": paymentHashKey,
    };

    try {
      final createJson = await _postJsonSafe(
        'deposit-create-upi-fund-request',
        createBody,
      );

      if (createJson['status'] == true) {
        final infoRaw = createJson['info'];
        final Map<String, dynamic> info = (infoRaw is Map)
            ? Map<String, dynamic>.from(infoRaw as Map)
            : <String, dynamic>{};

        final String paymentHash = (info['paymentHash'] ?? '').toString();
        final int remark = (info['remark'] is num)
            ? (info['remark'] as num).toInt()
            : int.tryParse((info['remark'] ?? '0').toString()) ?? 0;
        final int timestamp = (info['timestamp'] is num)
            ? (info['timestamp'] as num).toInt()
            : int.tryParse((info['timestamp'] ?? '0').toString()) ?? 0;

        if (paymentHash.isEmpty || timestamp == 0) {
          _showSnackBar(
            AppLocalizations.of(context)?.invalidServerResponse ?? 
              'Invalid server response (missing paymentHash/timestamp).',
          );
          return;
        }

        final addBody = {
          "registerId": userController.registerId.value,
          "depositType": depositType,
          "amount": _currentTransactionAmount,
          "hashKey": paymentHashKey,
          "timestamp": timestamp,
          "paymentHash": paymentHash,
          "remark": remark,
        };

        final addJson = await _postJsonSafe(
          'add-upi-deposit-fund-request',
          addBody,
        );

        if (addJson['status'] == true) {
          if (mounted) {
            setState(() {
              _isProcessingPayment = false;
              _currentPaymentMethodType = '';
            });
          }
          await userController.fetchAndUpdateUserDetails();
          _softPollBalance(times: 3);

          amountController.clear();
          _showSnackBar(
            addJson['msg']?.toString() ?? 
              (AppLocalizations.of(context)?.depositSuccessfulAndUpdated ?? 
                'Deposit successful and updated'),
          );
        } else {
          _showSnackBar(
            addJson['msg']?.toString() ?? 
              (AppLocalizations.of(context)?.failedToAddDepositFund ?? 
                'Failed to add deposit fund'),
          );
        }
      } else {
        final code = createJson['_statusCode'];
        final l10n = AppLocalizations.of(context);
        _showSnackBar(
          createJson['msg']?.toString() ??
              (l10n?.failedToCreateFundRequest(code) ??
                'Failed to create fund request (HTTP $code)'),
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      _showSnackBar(
        l10n?.failedToCompletePaymentProcess(e.toString()) ??
          "Failed to complete payment process: ${e.toString()}"
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _currentPaymentMethodType = '';
        });
      }
    }
  }

  Future<void> _softPollBalance({int times = 3}) async {
    for (var i = 0; i < times; i++) {
      await Future.delayed(const Duration(seconds: 2));
      await userController.fetchAndUpdateUserDetails();
    }
  }

  Future<void> _createTransactionLink() async {
    _hideKeyboard();
    if (mounted) setState(() => _isProcessingPayment = true);

    final amountText = amountController.text.trim();
    final parsedAmount = int.tryParse(amountText);
    final parsedMobile = int.tryParse(userController.mobileNo.value);

    final minAmountInt =
        (double.tryParse(userController.minDeposit.value)?.toInt()) ?? 0;

    final l10n = AppLocalizations.of(context);
    if (parsedAmount == null) {
      _showSnackBar(l10n?.pleaseEnterValidAmount ?? "Please enter a valid amount.");
      if (mounted) setState(() => _isProcessingPayment = false);
      return;
    }
    if (parsedAmount < minAmountInt) {
      _showSnackBar(
            l10n?.pleaseEnterAmountGreaterThanOrEqual(minAmountInt) ??
              "Please enter an amount greater than or equal to ₹$minAmountInt.",
      );
      if (mounted) setState(() => _isProcessingPayment = false);
      return;
    }
    if (parsedMobile == null) {
      _showSnackBar(l10n?.invalidMobileNumberFound ?? "Invalid mobile number found.");
      if (mounted) setState(() => _isProcessingPayment = false);
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final responseJson = await _postJsonSafe('create-transaction-link', {
        'registerId': userController.registerId.value,
        'amount': parsedAmount,
        'mobile': parsedMobile,
      });

      if ((responseJson['_statusCode'] ?? 0) == 200 &&
          responseJson['status'] == true) {
        final transactionResponse = CreateTransactionLinkResponse.fromJson(
          responseJson,
        );
        final paymentLink = transactionResponse.paymentLink;
        if (paymentLink != null && mounted) {
          final shouldRefresh = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  QRPaymentScreen(paymentLink: paymentLink, amount: amountText),
            ),
          );

          if (shouldRefresh == true) {
            await userController.fetchAndUpdateUserDetails();
            _softPollBalance(times: 3);
          }
        } else {
          _showSnackBar(
            AppLocalizations.of(context)?.paymentLinkNotFoundInResponse ?? 
              'Payment link not found in response.'
          );
        }
      } else {
        _showSnackBar(
          responseJson['msg']?.toString() ??
              (AppLocalizations.of(context)?.failedToCreateTransactionLink ?? 
                'Failed to create transaction link.'),
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      _showSnackBar(
        l10n?.error(e.toString()) ?? 
          'Error: ${e.toString()}'
      );
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  // NEW: Set quick amount
  void _setQuickAmount(int amount) {
    amountController.text = amount.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final orange = const Color(0xFF3882F6);
    String currentBalance = userController.walletBalance.value;
    String userName = userController.accountHolderName.value;
    String mobileNo = userController.mobileNo.value;

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
          l10n?.addFund ?? "ADD FUND",
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
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
                                              Obx(() => Text(
                                                userController.fullName.value.isNotEmpty ? userController.fullName.value : 'User',
                                                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                              )),
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
                                      Obx(() => Text(
                                        "₹ ${userController.walletBalance.value}",
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 15),

                          Text(
                            l10n?.enterAmount ?? 'Enter Amount',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 20),
                          // Modern Amount Input
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFEEEEEE)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.currency_rupee, color: Color(0xFF3882F6), size: 24),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0F4C81)),
                                    decoration: InputDecoration(
                                      hintText: "0.00",
                                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 18),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),


                          const SizedBox(height: 10),

                          // SAME – Quick buttons, UPI, QR, Loader etc…
                          Column(
                            children: [
                              // 🔹 First Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _QuickAmountButton(
                                    amount: 300,
                                    onTap: () => _setQuickAmount(300),
                                  ),
                                  _QuickAmountButton(
                                    amount: 500,
                                    onTap: () => _setQuickAmount(500),
                                  ),
                                  _QuickAmountButton(
                                    amount: 1000,
                                    onTap: () => _setQuickAmount(1000),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // 🔹 Second Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _QuickAmountButton(
                                    amount: 2000,
                                    onTap: () => _setQuickAmount(2000),
                                  ),
                                  _QuickAmountButton(
                                    amount: 3000,
                                    onTap: () => _setQuickAmount(3000),
                                  ),
                                ],
                              ),
                            ],
                          ),



                          const SizedBox(height: 12),



                          const SizedBox(height: 40),

                          Visibility(
                            visible: UPIShow,
                            child: _WideBtn(
                              text: l10n?.addPointUpi ?? "ADD POINT - UPI",
                              onPressed: _isProcessingPayment
                                  ? null
                                  : _validateAndPreparePayment,
                              orange: orange,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Visibility(
                            visible: QRShow,
                            child: _WideBtn(
                              text: l10n?.addPointQrPaytmGateway ?? 
                                "ADD POINT - QR - PAYTM - GATEWAY",
                              onPressed: _isProcessingPayment
                                  ? null
                                  : _createTransactionLink,
                              orange: orange,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // _WideBtn(
                          //   text: l10n?.howToAddPoint ?? "HOW TO ADD POINT",
                          //   onPressed: _isProcessingPayment
                          //       ? null
                          //       : () => _showSnackBar(
                          //           l10n?.pleaseContactSupportToKnowHowToAddPoint ??
                          //             "Please contact support to know how to add point.",
                          //         ),
                          //   orange: orange,
                          // ),

                          if (_isProcessingPayment) ...[
                            const SizedBox(height: 20),
                            Center(
                              child: CircularProgressIndicator(color: orange),
                            ),
                          ],

                          const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Quick Amount Button Widget
class _QuickAmountButton extends StatelessWidget {
  final int amount;
  final VoidCallback onTap;

  const _QuickAmountButton({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Center(
              child: Text(
                amount.toString(),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF0F4C81)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Wide Button Widget (Unchanged)
class _WideBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color orange;
  const _WideBtn({required this.text, this.onPressed, required this.orange});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
