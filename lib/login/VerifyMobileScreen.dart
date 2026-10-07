import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/Helper/Toast.dart';
import 'package:new_sara/HomeScreen/HomeScreen.dart';
import 'package:new_sara/login/LoginWithMpinScreen.dart';
import 'package:new_sara/l10n/app_localizations.dart';
import 'package:new_sara/ulits/ColorsR.dart';
import 'package:new_sara/ulits/Constents.dart';
import 'package:provider/provider.dart';

// -----------------------------
// MODEL
// -----------------------------
class AuthResponse {
  final bool status;
  final String msg;
  final AuthInfo? info;

  AuthResponse({required this.status, required this.msg, this.info});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] as bool,
      msg: json['msg'] as String,
      info: json['info'] != null ? AuthInfo.fromJson(json['info']) : null,
    );
  }
}

class AuthInfo {
  final String? registerId;
  final String? accessToken;

  AuthInfo({this.registerId, this.accessToken});

  factory AuthInfo.fromJson(Map<String, dynamic> json) {
    return AuthInfo(
      registerId: json['registerId'],
      accessToken: json['accessToken'],
    );
  }
}

// -----------------------------
// API SERVICE
// -----------------------------
class ApiService {
  final Map<String, String> _baseHeaders = {
    'deviceId': 'qwert',
    'deviceName': 'sm2233',
    'accessStatus': '1',
    'Content-Type': 'application/json',
  };

  Future<AuthResponse> registerWithPassword({
    required String fullName,
    required String mobileNo,
    required String password,
    required String securityPin,
    String? registrationFailedMsg,
  }) async {
    final Uri url = Uri.parse('${Constant.apiEndpoint}user-register');
    final body = {
      "fullName": fullName,
      "mobileNo": int.tryParse(mobileNo),
      "password": password,
      "password_confirmation": password,
      "security_pin": int.tryParse(securityPin),
    };

    try {
      final response = await http.post(url,
          headers: _baseHeaders, body: jsonEncode(body));

      log("📥 Register Response: ${response.body}");
      return AuthResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      return AuthResponse(
        status: false,
        msg: registrationFailedMsg ?? "Registration failed",
      );
    }
  }
}

// -----------------------------
// VIEWMODEL
// -----------------------------
class VerifyMobileViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final GetStorage _storage = GetStorage();

  final TextEditingController passwordController = TextEditingController();

  bool _isVerifying = false;
  String? _errorMessage;
  String? _successMessage;
  bool _registrationSuccessful = false;

  bool get isVerifying => _isVerifying;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get registrationSuccessful => _registrationSuccessful;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  Future<void> verifyPassword(BuildContext? context) async {
    final l10n = context != null ? AppLocalizations.of(context) : null;
    final pass = passwordController.text.trim();
    if (pass.isEmpty) {
      _errorMessage = l10n?.enterYourAccountPassword ?? "Enter your account password.";
      notifyListeners();
      return;
    }

    final mobile = _storage.read('mobile');
    final name = _storage.read('username');
    final pin = _storage.read('user_mpin');

    if (mobile == null || pin == null) {
      _errorMessage = l10n?.missingDataRestartRegistration ?? "Missing data. Restart registration.";
      notifyListeners();
      return;
    }

    _isVerifying = true;
    notifyListeners();

    try {
      final AuthResponse response = await _apiService.registerWithPassword(
        fullName: name ?? "User",
        mobileNo: mobile,
        password: pass,
        securityPin: pin,
        registrationFailedMsg: l10n?.registrationFailed,
      );

      if (response.status) {
        _successMessage = response.msg;
        _registrationSuccessful = true;

        if (response.info?.accessToken != null) {
          _storage.write("accessToken", response.info!.accessToken);
          _storage.write("registerId", response.info!.registerId);
        }
      } else {
        _errorMessage = response.msg;
      }
    } catch (e) {
      _errorMessage = l10n?.errorVerifyingPassword ?? "Error verifying password";
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}

// -----------------------------
// SCREEN
// -----------------------------
class VerifyMobileScreen extends StatelessWidget {
  const VerifyMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerifyMobileViewModel(),
      child: const _VerifyMobileScreenContent(),
    );
  }
}

class _VerifyMobileScreenContent extends StatefulWidget {
  const _VerifyMobileScreenContent();

  @override
  State<_VerifyMobileScreenContent> createState() =>
      _VerifyMobileScreenContentState();
}

class _VerifyMobileScreenContentState
    extends State<_VerifyMobileScreenContent> {
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<VerifyMobileViewModel>(context, listen: false);
      vm.addListener(() {
        if (vm.errorMessage != null) {
          popToast(vm.errorMessage!, 4, Colors.white, ColorsR.appColorRed);

          if (vm.errorMessage!.toLowerCase().contains("already registered")) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginWithMpinScreen()),
            );
          }

          vm.clearError();
        }

        if (vm.successMessage != null) {
          popToast(vm.successMessage!, 2, Colors.white, Colors.green);

          if (vm.registrationSuccessful) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
            );
          }

          vm.clearSuccess();
        }
      });
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = Provider.of<VerifyMobileViewModel>(context);
    final mobile = storage.read("mobile") ?? "XXXXXXXXXX";

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFE082),

      body: Column(
        children: [
          const SizedBox(height: 90),

          /// 🔥 FULL ROUNDED WHITE CONTAINER
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE082),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
              ),

              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    /// ✅ IMAGE (same family UI)
                    Image.asset(
                      'assets/images/verification_avatar.png',
                      height: 160,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 20),

                    /// TITLE
                    Text(
                      l10n?.verifyMobileNumber ?? "VERIFY MOBILE NUMBER",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F4C81),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// SUB TITLE
                    Text(
                      l10n?.toCompleteRegistrationFor ??
                          "To complete registration for",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// MOBILE
                    Text(
                      mobile,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0F4C81),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔒 PASSWORD CARD (DITTO STYLE)
                    Card(
                      elevation: 6,
                    color: Color(0xffeeeeee),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                             const Icon(
                               Icons.lock,
                               color: Color(0xFF3882F6),
                             ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: vm.passwordController,
                                obscureText: true,
                                 cursorColor: const Color(0xFF3882F6),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: l10n?.enterYourPassword ??
                                      "Enter your password",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    /// 🔥 VERIFY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: vm.isVerifying
                            ? null
                            : () => vm.verifyPassword(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3882F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: vm.isVerifying
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : Text(
                          l10n?.verify ?? "VERIFY",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    /// keyboard space
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
